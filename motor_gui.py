#!/usr/bin/env python3
"""FFT Gyro axis controller GUI.

This app sends 32-byte packets to the FFT Gyro board and supports:
- Per-axis sine-wave motion around origin.
- Per-axis amplitude and frequency settings.
- Per-axis direct position command.

Protocol notes from communication_protocol.pdf used here:
- Packets are always 32 bytes.
- Byte[1] is mode.
- Write packet type-2 is intended for goal position / velocity style control.

Because the PDF's field-by-field table is image-based in this environment, this implementation keeps
packet structure centralized in FFTGyroProtocol so offsets can be adjusted easily if needed.
"""

from __future__ import annotations

import math
import logging
import threading
import time
import tkinter as tk
from dataclasses import dataclass
from tkinter import messagebox, ttk

try:
    import serial
    from serial.tools import list_ports
except Exception:  # pragma: no cover - runtime dependency
    serial = None
    list_ports = None


AXES = ("X", "Y", "Z")
DEFAULT_BAUD = 9600
COMMON_BAUDS = (9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600)

MAX_ABS_AMPLITUDE_DEG = 150.0
MAX_FREQUENCY_HZ = 20.0
MAX_ABS_POSITION_DEG = 150.0

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
LOGGER = logging.getLogger("fft_gyro_controller")


@dataclass
class AxisState:
    amplitude_deg: float = 0.0
    frequency_hz: float = 0.1
    phase_rad: float = 0.0
    enabled: bool = False


class FFTGyroProtocol:
    """Packet encoder for 32-byte FFT Gyro write packets.

    Packet format extracted from communication_protocol.pdf:
    - Byte 0: start byte 0x7A
    - Byte 1: packet number (0x01, 0x02, or 0x03)
    - Byte 31: final byte 0x7B
    """

    PACKET_SIZE = 32
    START_BYTE = 0x7A
    END_BYTE = 0x7B
    PACKET_WRITE_1 = 0x01
    PACKET_WRITE_2 = 0x02
    PACKET_WRITE_3 = 0x03
    POSITION_CENTER = 512
    DEG_PER_POSITION = 300.0 / 1023.0

    @classmethod
    def _deg_to_position(cls, degrees: float) -> int:
        motor_degrees = degrees + 150.0
        pos = int(round(motor_degrees / cls.DEG_PER_POSITION))
        return max(0, min(1023, pos))

    @staticmethod
    def _set_u16_le(pkt: bytearray, offset: int, value: int) -> None:
        pkt[offset] = value & 0xFF
        pkt[offset + 1] = (value >> 8) & 0xFF

    def _new_packet(self, packet_number: int) -> bytearray:
        pkt = bytearray(self.PACKET_SIZE)
        pkt[0] = self.START_BYTE
        pkt[1] = packet_number
        pkt[31] = self.END_BYTE
        return pkt

    def build_init_packet_set_joint_and_enable(self, axis_mask: int = 0b111, *, use_ascii_fields: bool = True) -> bytes:
        pkt = self._new_packet(self.PACKET_WRITE_3)
        one = ord("1") if use_ascii_fields else 0x01
        zero = ord("0") if use_ascii_fields else 0x00
        joint = ord("2") if use_ascii_fields else 0x02
        # bytes 2..4: set mode flags ('1' => apply mode byte for that motor)
        pkt[2] = one if (axis_mask & 0b001) else zero
        pkt[3] = one if (axis_mask & 0b010) else zero
        pkt[4] = one if (axis_mask & 0b100) else zero
        # bytes 5..7: motor mode ('2' => joint mode)
        pkt[5] = joint
        pkt[6] = joint
        pkt[7] = joint
        # bytes 14..16: turn on motors ('1' => on)
        pkt[14] = one if (axis_mask & 0b001) else zero
        pkt[15] = one if (axis_mask & 0b010) else zero
        pkt[16] = one if (axis_mask & 0b100) else zero
        # byte 30: data mode packet (0x02 => extended packet)
        pkt[30] = 0x02
        return bytes(pkt)

    def build_init_packet_enable_torque(self, axis_mask: int = 0b111) -> bytes:
        pkt = self._new_packet(self.PACKET_WRITE_1)
        # byte 4: set torque enable bitfield (bit0=M1, bit1=M2, bit2=M3)
        pkt[4] = axis_mask & 0x07
        return bytes(pkt)

    def build_set_position(self, x_deg: float, y_deg: float, z_deg: float, axis_mask: int = 0b111) -> bytes:
        pkt = self._new_packet(self.PACKET_WRITE_2)
        pkt[22] = axis_mask & 0x07

        self._set_u16_le(pkt, 23, self._deg_to_position(x_deg))
        self._set_u16_le(pkt, 25, self._deg_to_position(y_deg))
        self._set_u16_le(pkt, 27, self._deg_to_position(z_deg))
        return bytes(pkt)

    def build_read_packet(self, packet_number: int, mode_byte: int = 0x01) -> bytes:
        pkt = self._new_packet(packet_number)
        # byte 30 is protocol-version dependent across FFT Gyro firmware variants.
        # 0x01 is most common for read requests; some firmware expects 0x00/0x02.
        pkt[30] = mode_byte & 0xFF
        return bytes(pkt)

    @classmethod
    def _u16_le(cls, pkt: bytes, offset: int) -> int:
        return pkt[offset] | (pkt[offset + 1] << 8)

    @classmethod
    def position_to_degrees(cls, position: int) -> float:
        return (position * cls.DEG_PER_POSITION) - 150.0

    def parse_feedback_positions(self, pkt: bytes) -> tuple[float, float, float] | None:
        if len(pkt) != self.PACKET_SIZE:
            return None
        if pkt[0] != self.START_BYTE or pkt[31] != self.END_BYTE:
            return None
        if pkt[1] != self.PACKET_WRITE_2:
            return None

        raw_x = self._u16_le(pkt, 23)
        raw_y = self._u16_le(pkt, 25)
        raw_z = self._u16_le(pkt, 27)
        return (
            self.position_to_degrees(raw_x),
            self.position_to_degrees(raw_y),
            self.position_to_degrees(raw_z),
        )


class SerialController:
    def __init__(self, protocol: FFTGyroProtocol) -> None:
        self.protocol = protocol
        self._ser = None
        self._lock = threading.RLock()

    @property
    def connected(self) -> bool:
        return self._ser is not None and self._ser.is_open

    def connect(self, port: str, baud: int = DEFAULT_BAUD) -> None:
        if serial is None:
            raise RuntimeError("pyserial is not installed. Install with: pip install pyserial")

        with self._lock:
            self.disconnect()
            LOGGER.info("Connecting to %s @ %d", port, baud)
            self._ser = serial.Serial(
                port=port,
                baudrate=baud,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                timeout=0.1,
            )
            LOGGER.info("Connected to %s @ %d", port, baud)

    def disconnect(self) -> None:
        with self._lock:
            if self._ser is not None:
                try:
                    LOGGER.info("Disconnecting serial port %s", self._ser.port)
                    self._ser.close()
                finally:
                    self._ser = None

    def send_position(self, x_deg: float, y_deg: float, z_deg: float, axis_mask: int = 0b111) -> None:
        pkt = self.protocol.build_set_position(x_deg, y_deg, z_deg, axis_mask)
        self.send_raw(pkt)
        LOGGER.info(
            "Sent position x=%.3f y=%.3f z=%.3f mask=0x%02X packet=%s",
            x_deg,
            y_deg,
            z_deg,
            axis_mask,
            pkt.hex(),
        )

    def initialize_motors(self, axis_mask: int = 0b111) -> None:
        # Some firmware revisions expect ASCII-coded mode fields ("1"/"2"),
        # while others expect raw numeric bytes (0x01/0x02). Send both forms.
        self.send_raw(self.protocol.build_init_packet_set_joint_and_enable(axis_mask, use_ascii_fields=True))
        time.sleep(0.03)
        self.send_raw(self.protocol.build_init_packet_set_joint_and_enable(axis_mask, use_ascii_fields=False))
        time.sleep(0.03)
        self.send_raw(self.protocol.build_init_packet_enable_torque(axis_mask))
        time.sleep(0.03)
        # Send center position once so enabled motors receive a valid motion packet.
        self.send_position(0.0, 0.0, 0.0, axis_mask=axis_mask)
        LOGGER.info("Sent motor initialization packets for mask=0x%02X", axis_mask)

    def send_raw(self, pkt: bytes) -> None:
        with self._lock:
            if not self.connected:
                raise RuntimeError("Serial port is not connected")
            self._ser.write(pkt)
            LOGGER.info("Sent raw packet=%s", pkt.hex())

    def _read_framed_packet(self, timeout_s: float) -> bytes:
        deadline = time.monotonic() + timeout_s
        buf = bytearray()
        while time.monotonic() < deadline:
            chunk = self._ser.read(1)
            if not chunk:
                continue
            b = chunk[0]
            if not buf:
                if b != self.protocol.START_BYTE:
                    continue
                buf.append(b)
                continue
            buf.append(b)
            if len(buf) == self.protocol.PACKET_SIZE:
                if buf[-1] == self.protocol.END_BYTE:
                    return bytes(buf)
                # Resync on the last observed START byte.
                try:
                    start_idx = buf.index(self.protocol.START_BYTE, 1)
                    buf = bytearray(buf[start_idx:])
                except ValueError:
                    buf.clear()
        return bytes(buf)

    def query_packet(self, packet_number: int, timeout_s: float = 0.45) -> bytes:
        with self._lock:
            if not self.connected:
                raise RuntimeError("Serial port is not connected")

            old_timeout = self._ser.timeout
            self._ser.timeout = timeout_s
            try:
                reply = b""
                for mode_byte in (0x01, 0x00, 0x02):
                    req = self.protocol.build_read_packet(packet_number, mode_byte=mode_byte)
                    self._ser.reset_input_buffer()
                    self._ser.write(req)
                    candidate = self._read_framed_packet(timeout_s)
                    if (
                        len(candidate) == self.protocol.PACKET_SIZE
                        and candidate[0] == self.protocol.START_BYTE
                        and candidate[-1] == self.protocol.END_BYTE
                    ):
                        reply = candidate
                        break
                    reply = candidate
            finally:
                self._ser.timeout = old_timeout

        LOGGER.info(
            "Read request packet_number=0x%02X response=%s (len=%d)",
            packet_number,
            reply.hex(),
            len(reply),
        )
        return reply

    def query_motor_feedback(self) -> dict[str, object]:
        pkt1 = self.query_packet(self.protocol.PACKET_WRITE_1)
        pkt2 = self.query_packet(self.protocol.PACKET_WRITE_2)
        parsed = self.protocol.parse_feedback_positions(pkt2)
        return {
            "packet_1_hex": pkt1.hex(),
            "packet_2_hex": pkt2.hex(),
            "packet_2_positions_deg": parsed,
        }


class AxisFrame(ttk.LabelFrame):
    def __init__(self, master: tk.Misc, axis_name: str) -> None:
        super().__init__(master, text=f"Axis {axis_name}")

        self.enabled_var = tk.BooleanVar(value=False)
        self.amplitude_var = tk.DoubleVar(value=0.0)
        self.frequency_var = tk.DoubleVar(value=0.1)
        self.position_var = tk.DoubleVar(value=0.0)

        ttk.Checkbutton(self, text="Enable sine", variable=self.enabled_var).grid(row=0, column=0, columnspan=2, sticky="w")

        ttk.Label(self, text="Amplitude (deg)").grid(row=1, column=0, sticky="w")
        ttk.Entry(self, textvariable=self.amplitude_var, width=12).grid(row=1, column=1, sticky="ew")

        ttk.Label(self, text="Frequency (Hz)").grid(row=2, column=0, sticky="w")
        ttk.Entry(self, textvariable=self.frequency_var, width=12).grid(row=2, column=1, sticky="ew")

        ttk.Label(self, text="Set position (deg)").grid(row=3, column=0, sticky="w")
        ttk.Entry(self, textvariable=self.position_var, width=12).grid(row=3, column=1, sticky="ew")

        self.columnconfigure(1, weight=1)

    def get_state(self) -> AxisState:
        return AxisState(
            amplitude_deg=float(self.amplitude_var.get()),
            frequency_hz=float(self.frequency_var.get()),
            enabled=bool(self.enabled_var.get()),
        )


class App(tk.Tk):
    UPDATE_PERIOD_S = 0.02

    def __init__(self) -> None:
        super().__init__()
        self.title("FFT Gyro Axis Controller")
        self.geometry("760x460")

        self.protocol_obj = FFTGyroProtocol()
        self.serial = SerialController(self.protocol_obj)

        self._running = False
        self._start_time = 0.0
        self._port_details: dict[str, object] = {}

        self.port_var = tk.StringVar(value="")
        self.baud_var = tk.IntVar(value=DEFAULT_BAUD)
        self.status_var = tk.StringVar(value="Disconnected")

        self.axis_frames: dict[str, AxisFrame] = {}

        self._build_ui()

    def _build_ui(self) -> None:
        top = ttk.Frame(self, padding=8)
        top.pack(fill="x")

        ttk.Label(top, text="COM Port").grid(row=0, column=0, sticky="w")
        self.port_combo = ttk.Combobox(top, textvariable=self.port_var, width=16)
        self.port_combo.grid(row=0, column=1, padx=(4, 12), sticky="w")
        ttk.Button(top, text="Refresh", command=self.refresh_ports).grid(row=0, column=2, padx=(0, 12))

        ttk.Label(top, text="Baud").grid(row=0, column=3, sticky="w")
        self.baud_combo = ttk.Combobox(top, textvariable=self.baud_var, width=10, values=[str(b) for b in COMMON_BAUDS])
        self.baud_combo.grid(row=0, column=4, padx=(4, 12), sticky="w")

        self.connect_btn = ttk.Button(top, text="Connect", command=self.connect_serial)
        self.connect_btn.grid(row=0, column=5, padx=4)
        self.disconnect_btn = ttk.Button(top, text="Disconnect", command=self.disconnect_serial)
        self.disconnect_btn.grid(row=0, column=6, padx=4)

        self.status_label = ttk.Label(top, textvariable=self.status_var)
        self.status_label.grid(row=0, column=7, padx=(20, 0), sticky="w")

        axis_container = ttk.Frame(self, padding=8)
        axis_container.pack(fill="both", expand=True)

        for idx, axis in enumerate(AXES):
            frame = AxisFrame(axis_container, axis)
            frame.grid(row=0, column=idx, sticky="nsew", padx=6, pady=6)
            self.axis_frames[axis] = frame
            axis_container.columnconfigure(idx, weight=1)

        actions = ttk.Frame(self, padding=8)
        actions.pack(fill="x")

        self.start_btn = ttk.Button(actions, text="Start sine motion", command=self.start_sine)
        self.start_btn.pack(side="left", padx=4)
        self.stop_btn = ttk.Button(actions, text="Stop sine motion", command=self.stop_sine)
        self.stop_btn.pack(side="left", padx=4)
        self.set_x_btn = ttk.Button(actions, text="Set X", command=lambda: self.set_single_axis("X"))
        self.set_x_btn.pack(side="left", padx=4)
        self.set_y_btn = ttk.Button(actions, text="Set Y", command=lambda: self.set_single_axis("Y"))
        self.set_y_btn.pack(side="left", padx=4)
        self.set_z_btn = ttk.Button(actions, text="Set Z", command=lambda: self.set_single_axis("Z"))
        self.set_z_btn.pack(side="left", padx=4)
        self.set_all_btn = ttk.Button(actions, text="Set all", command=self.set_all_axes)
        self.set_all_btn.pack(side="left", padx=4)
        self.read_btn = ttk.Button(actions, text="Read motor feedback", command=self.read_motor_feedback)
        self.read_btn.pack(side="left", padx=4)

        self.refresh_ports()
        self._update_ui_state()
        self.protocol("WM_DELETE_WINDOW", self._on_close)

    def refresh_ports(self) -> None:
        ports = []
        self._port_details.clear()
        if list_ports is not None:
            for p in list_ports.comports():
                ports.append(p.device)
                self._port_details[p.device] = p
        self.port_combo["values"] = ports
        if not ports:
            self.port_var.set("")
            return

        preferred = self._find_preferred_port(ports)
        current = self.port_var.get().strip()
        if current not in ports:
            self.port_var.set(preferred)

    def _find_preferred_port(self, ports: list[str]) -> str:
        for port in ports:
            info = self._port_details.get(port)
            if info is None:
                continue
            hay = " ".join(
                str(v).lower()
                for v in (
                    getattr(info, "device", ""),
                    getattr(info, "description", ""),
                    getattr(info, "manufacturer", ""),
                    getattr(info, "product", ""),
                    getattr(info, "interface", ""),
                )
            )
            if any(token in hay for token in ("fft", "gyro", "cp210", "ch340", "usb serial", "uart", "ftdi")):
                return port
        return ports[0]

    def _set_status(self, text: str, ok: bool = False) -> None:
        self.status_var.set(text)
        self.status_label.configure(foreground="#0a4" if ok else "#a00")
        if ok:
            LOGGER.info(text)
        else:
            LOGGER.warning(text)

    def _update_ui_state(self) -> None:
        connected = self.serial.connected
        self.connect_btn.configure(state="disabled" if connected else "normal")
        self.disconnect_btn.configure(state="normal" if connected else "disabled")

        action_state = "normal" if connected else "disabled"
        for btn in (self.start_btn, self.stop_btn, self.set_x_btn, self.set_y_btn, self.set_z_btn, self.set_all_btn, self.read_btn):
            btn.configure(state=action_state)

    def _safe_float(self, raw: object, field_name: str) -> float:
        try:
            return float(raw)
        except Exception as exc:
            raise ValueError(f"Invalid numeric value for {field_name}: {raw!r}") from exc

    def _validated_axis_inputs(self, axis: str) -> tuple[float, float, float]:
        frame = self.axis_frames[axis]
        amplitude = self._safe_float(frame.amplitude_var.get(), f"{axis} amplitude")
        frequency = self._safe_float(frame.frequency_var.get(), f"{axis} frequency")
        position = self._safe_float(frame.position_var.get(), f"{axis} position")

        if abs(amplitude) > MAX_ABS_AMPLITUDE_DEG:
            raise ValueError(f"{axis} amplitude out of range ±{MAX_ABS_AMPLITUDE_DEG}°")
        if frequency < 0 or frequency > MAX_FREQUENCY_HZ:
            raise ValueError(f"{axis} frequency must be between 0 and {MAX_FREQUENCY_HZ} Hz")
        if abs(position) > MAX_ABS_POSITION_DEG:
            raise ValueError(f"{axis} position out of range ±{MAX_ABS_POSITION_DEG}°")

        return amplitude, frequency, position

    def _validate_all_axes(self) -> None:
        for axis in AXES:
            self._validated_axis_inputs(axis)

    def connect_serial(self) -> None:
        try:
            port = self.port_var.get().strip()
            if not port:
                raise ValueError("Select a COM port before connecting")
            baud = int(self._safe_float(self.baud_var.get(), "baud"))
            if baud <= 0:
                raise ValueError("Baud must be a positive integer")

            self.serial.connect(port, baud)
            self.serial.initialize_motors(0b111)
            self._set_status(f"Connected: {port} @ {baud}", ok=True)
            self._update_ui_state()
        except Exception as exc:
            messagebox.showerror("Connection error", str(exc))

    def disconnect_serial(self) -> None:
        self.stop_sine()
        self.serial.disconnect()
        self._set_status("Disconnected", ok=False)
        self._update_ui_state()

    def start_sine(self) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect a COM port first")
            return
        if self._running:
            return
        try:
            self._validate_all_axes()
        except ValueError as exc:
            messagebox.showerror("Input error", str(exc))
            return

        self._running = True
        self._start_time = time.monotonic()
        self._tick()

    def stop_sine(self) -> None:
        self._running = False

    def _tick(self) -> None:
        if not self._running:
            return

        t = time.monotonic() - self._start_time
        x, y, z = self._calc_sine_positions(t)
        mask = self._enabled_axis_mask()

        if mask:
            try:
                self.serial.send_position(x, y, z, axis_mask=mask)
            except Exception as exc:
                self.stop_sine()
                messagebox.showerror("Serial error", str(exc))
                return

        self.after(int(self.UPDATE_PERIOD_S * 1000), self._tick)

    def _calc_sine_positions(self, t: float) -> tuple[float, float, float]:
        out = []
        for axis in AXES:
            amplitude, frequency, _ = self._validated_axis_inputs(axis)
            state = self.axis_frames[axis].get_state()
            if state.enabled:
                value = amplitude * math.sin(2.0 * math.pi * frequency * t)
            else:
                value = 0.0
            out.append(value)
        return out[0], out[1], out[2]

    def _enabled_axis_mask(self) -> int:
        mask = 0
        for idx, axis in enumerate(AXES):
            if self.axis_frames[axis].enabled_var.get():
                mask |= (1 << idx)
        return mask

    def set_single_axis(self, axis: str) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect a COM port first")
            return

        values = [0.0, 0.0, 0.0]
        idx = AXES.index(axis)
        try:
            _, _, position = self._validated_axis_inputs(axis)
            values[idx] = position
        except Exception as exc:
            messagebox.showerror("Input error", str(exc))
            return

        try:
            self.serial.send_position(values[0], values[1], values[2], axis_mask=(1 << idx))
        except Exception as exc:
            messagebox.showerror("Serial error", str(exc))

    def set_all_axes(self) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect a COM port first")
            return

        try:
            values = [self._validated_axis_inputs(a)[2] for a in AXES]
        except Exception as exc:
            messagebox.showerror("Input error", str(exc))
            return
        try:
            self.serial.send_position(values[0], values[1], values[2], axis_mask=0b111)
        except Exception as exc:
            messagebox.showerror("Serial error", str(exc))

    def read_motor_feedback(self) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect a COM port first")
            return

        try:
            result = self.serial.query_motor_feedback()
        except Exception as exc:
            messagebox.showerror("Serial error", str(exc))
            return

        positions = result["packet_2_positions_deg"]
        if positions is None:
            parsed_text = "Unable to parse packet #2 as position feedback."
        else:
            parsed_text = (
                f"Estimated positions from packet #2:\n"
                f"X={positions[0]:.2f}°, Y={positions[1]:.2f}°, Z={positions[2]:.2f}°"
            )

        details = (
            "Read complete.\n\n"
            f"Packet #1 response ({len(result['packet_1_hex']) // 2} bytes):\n{result['packet_1_hex']}\n\n"
            f"Packet #2 response ({len(result['packet_2_hex']) // 2} bytes):\n{result['packet_2_hex']}\n\n"
            f"{parsed_text}\n\n"
            "Tip: If responses are empty or malformed, verify baud, packet layout, and read/write mode byte."
        )
        messagebox.showinfo("Motor feedback", details)

    def _on_close(self) -> None:
        self.stop_sine()
        self.disconnect_serial()
        self.destroy()


if __name__ == "__main__":
    app = App()
    app.mainloop()
