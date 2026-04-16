#!/usr/bin/env python3
"""FFT Gyro motor controller GUI.

Protocol implementation is based on the official FFTGyroTestTool (Processing)
and MATLAB scripts in `fft-gyro/`.
"""

from __future__ import annotations

import logging
import math
import threading
import time
import tkinter as tk
from dataclasses import dataclass
from tkinter import messagebox, ttk

try:
    import serial
    from serial.tools import list_ports
except Exception:  # pragma: no cover
    serial = None
    list_ports = None

AXES = ("X", "Y", "Z")
DEFAULT_BAUD = 9600
COMMON_BAUDS = (9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600)

DEFAULT_MAX_ANGLE_DEG = 360.0
DEFAULT_MOTOR_RES_DEG = 0.088  # MX-series used by official tool
DEFAULT_RAW_MAX = 4095

MAX_FREQUENCY_HZ = 20.0

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")
LOGGER = logging.getLogger("fft_gyro_controller")


@dataclass
class AxisCommand:
    enabled: bool
    amplitude_deg: float
    frequency_hz: float
    target_deg: float


class FFTGyroProtocol:
    PACKET_SIZE = 32
    START_BYTE = 0x7A
    END_BYTE = 0x7B

    PACKET_WRITE_1 = 0x01
    PACKET_WRITE_2 = 0x02
    PACKET_WRITE_3 = 0x03

    def __init__(self, motor_res_deg: float = DEFAULT_MOTOR_RES_DEG, raw_max: int = DEFAULT_RAW_MAX) -> None:
        self.motor_res_deg = motor_res_deg
        self.raw_max = raw_max

    @staticmethod
    def _set_u16_le(pkt: bytearray, offset: int, value: int) -> None:
        pkt[offset] = value & 0xFF
        pkt[offset + 1] = (value >> 8) & 0xFF

    def _deg_to_raw(self, degrees: float) -> int:
        raw = int(round(degrees / self.motor_res_deg))
        return max(0, min(self.raw_max, raw))

    def _new_packet(self, packet_number: int) -> bytearray:
        pkt = bytearray(self.PACKET_SIZE)
        pkt[0] = self.START_BYTE
        pkt[1] = packet_number
        pkt[31] = self.END_BYTE
        return pkt

    def build_config_joint_mode(self, axis_mask: int = 0b111) -> bytes:
        """Write packet #3 exactly as official tool style (ASCII '0'/'1'/'2')."""
        pkt = self._new_packet(self.PACKET_WRITE_3)

        pkt[2] = ord("1") if axis_mask & 0b001 else ord("0")
        pkt[3] = ord("1") if axis_mask & 0b010 else ord("0")
        pkt[4] = ord("1") if axis_mask & 0b100 else ord("0")

        pkt[5] = ord("2")  # joint mode motor 1
        pkt[6] = ord("2")  # joint mode motor 2
        pkt[7] = ord("2")  # joint mode motor 3

        pkt[14] = ord("1") if axis_mask & 0b001 else ord("0")
        pkt[15] = ord("1") if axis_mask & 0b010 else ord("0")
        pkt[16] = ord("1") if axis_mask & 0b100 else ord("0")

        pkt[30] = 0x01
        return bytes(pkt)

    def build_write1(
        self,
        *,
        axis_mask: int = 0b111,
        set_data_rate: bool = False,
        data_rate_units_10ms: int = 1,
        set_torque_limit: bool = True,
        torque_limit_raw: int = 1023,
        set_max_torque: bool = True,
        max_torque_raw: int = 1023,
    ) -> bytes:
        """Write packet #1 (matches MATLAB sendPacket1ToGyroboard semantics)."""
        pkt = self._new_packet(self.PACKET_WRITE_1)

        pkt[2] = ord("1") if set_data_rate else 0x00
        pkt[3] = max(1, min(255, data_rate_units_10ms)) if set_data_rate else 0x00

        pkt[4] = axis_mask & 0x07

        tl_mask = (axis_mask & 0x07) if set_torque_limit else 0x00
        pkt[5] = tl_mask
        tl = max(0, min(1023, torque_limit_raw))
        self._set_u16_le(pkt, 6, tl)
        self._set_u16_le(pkt, 8, tl)
        self._set_u16_le(pkt, 10, tl)

        mt_mask = (axis_mask & 0x07) if set_max_torque else 0x00
        pkt[12] = mt_mask
        mt = max(0, min(1023, max_torque_raw))
        self._set_u16_le(pkt, 13, mt)
        self._set_u16_le(pkt, 15, mt)
        self._set_u16_le(pkt, 17, mt)

        pkt[30] = 0x00
        return bytes(pkt)

    def build_position_packet(
        self,
        x_deg: float,
        y_deg: float,
        z_deg: float,
        *,
        axis_mask: int = 0b111,
        velocity_mask: int | None = None,
        velocity_raw: int = 90,
    ) -> bytes:
        """Write packet #2 for JOINT mode position control."""
        pkt = self._new_packet(self.PACKET_WRITE_2)

        # Angle-limit fields copied from official tool's SetPosition() helper.
        pkt[2] = 0x00
        pkt[3] = 0x01
        pkt[4] = 0x00
        pkt[5] = 0x01
        pkt[6] = 0x00
        pkt[7] = 0x01
        pkt[8] = 0x00
        pkt[9] = 0xFF
        pkt[10] = 0x03
        pkt[11] = 0xFF
        pkt[12] = 0x03
        pkt[13] = 0xFF
        pkt[14] = 0x03

        vel_mask = axis_mask if velocity_mask is None else velocity_mask
        pkt[15] = vel_mask & 0x07
        v = max(0, min(1023, velocity_raw))
        self._set_u16_le(pkt, 16, v)
        self._set_u16_le(pkt, 18, v)
        self._set_u16_le(pkt, 20, v)

        pkt[22] = axis_mask & 0x07
        self._set_u16_le(pkt, 23, self._deg_to_raw(x_deg))
        self._set_u16_le(pkt, 25, self._deg_to_raw(y_deg))
        self._set_u16_le(pkt, 27, self._deg_to_raw(z_deg))

        pkt[30] = 0x00
        return bytes(pkt)

    def build_read_packet(self, packet_number: int, mode_byte: int) -> bytes:
        pkt = self._new_packet(packet_number)
        pkt[30] = mode_byte & 0xFF
        return bytes(pkt)

    @staticmethod
    def _u16_le(pkt: bytes, offset: int) -> int:
        return pkt[offset] | (pkt[offset + 1] << 8)

    def parse_motor_stream_packet(self, pkt: bytes) -> dict[str, tuple[float, float, float]] | None:
        """Parse 32-byte motor telemetry packet (packet type 0x01 from device)."""
        if len(pkt) != 32 or pkt[0] != self.START_BYTE or pkt[31] != self.END_BYTE or pkt[1] != 0x01:
            return None

        pos1 = self._u16_le(pkt, 18) * self.motor_res_deg
        pos2 = self._u16_le(pkt, 20) * self.motor_res_deg
        pos3 = self._u16_le(pkt, 22) * self.motor_res_deg

        vel1 = (self._u16_le(pkt, 12) & 1023) * 0.1113
        vel2 = (self._u16_le(pkt, 14) & 1023) * 0.1113
        vel3 = (self._u16_le(pkt, 16) & 1023) * 0.1113

        tor1 = self._u16_le(pkt, 6) * 0.0977
        tor2 = self._u16_le(pkt, 8) * 0.0977
        tor3 = self._u16_le(pkt, 10) * 0.0977

        return {
            "position_deg": (pos1, pos2, pos3),
            "velocity_rpm": (vel1, vel2, vel3),
            "torque_pct": (tor1, tor2, tor3),
        }


class SerialController:
    def __init__(self, protocol: FFTGyroProtocol) -> None:
        self.protocol = protocol
        self._ser = None
        self._lock = threading.RLock()
        self._last_send_t = 0.0

    @property
    def connected(self) -> bool:
        return self._ser is not None and self._ser.is_open

    def connect(self, port: str, baud: int) -> None:
        if serial is None:
            raise RuntimeError("pyserial is not installed. Install with: pip install pyserial")
        with self._lock:
            self.disconnect()
            self._ser = serial.Serial(
                port=port,
                baudrate=baud,
                timeout=0.1,
                write_timeout=0.25,
                inter_byte_timeout=0.1,
            )
            LOGGER.info("Opened serial port %s @ %d", port, baud)

    def disconnect(self) -> None:
        with self._lock:
            if self._ser is not None:
                try:
                    self._ser.close()
                finally:
                    self._ser = None

    def send_raw(self, pkt: bytes) -> None:
        with self._lock:
            if not self.connected:
                raise RuntimeError("Serial port is not connected")
            try:
                wrote = self._ser.write(pkt)
            except serial.SerialTimeoutException as exc:
                # The device stopped draining TX; clear pending bytes so the UI thread
                # can recover quickly instead of stalling on repeated timeouts.
                try:
                    self._ser.reset_output_buffer()
                except Exception:
                    LOGGER.exception("Failed to reset serial output buffer after timeout")
                raise TimeoutError("Serial write timeout. Check controller power/cable and reconnect.") from exc
            if wrote != len(pkt):
                raise RuntimeError(f"Short serial write: expected {len(pkt)} bytes, wrote {wrote}")
            self._last_send_t = time.monotonic()

    def min_command_interval_s(self, packet_bytes: int = FFTGyroProtocol.PACKET_SIZE) -> float:
        """Minimum practical interval between writes for current baud (with safety margin)."""
        with self._lock:
            if not self.connected:
                return 0.0
            # UART usually transmits 10 bits per payload byte (start + 8 data + stop).
            tx_time_s = (packet_bytes * 10) / float(self._ser.baudrate)
            return tx_time_s * 1.25

    def initialize_for_joint_position_mode(self, axis_mask: int = 0b111) -> None:
        self.send_raw(self.protocol.build_config_joint_mode(axis_mask=axis_mask))
        time.sleep(0.2)
        self.send_raw(
            self.protocol.build_write1(
                axis_mask=axis_mask,
                set_data_rate=False,
                set_torque_limit=True,
                torque_limit_raw=1023,
                set_max_torque=True,
                max_torque_raw=1023,
            )
        )
        time.sleep(0.2)

    def send_position(self, x_deg: float, y_deg: float, z_deg: float, axis_mask: int = 0b111, velocity_raw: int = 90) -> None:
        pkt = self.protocol.build_position_packet(
            x_deg,
            y_deg,
            z_deg,
            axis_mask=axis_mask,
            velocity_mask=axis_mask,
            velocity_raw=velocity_raw,
        )
        self.send_raw(pkt)

    def _read_framed_packet(self, timeout_s: float) -> bytes:
        deadline = time.monotonic() + timeout_s
        buf = bytearray()
        while time.monotonic() < deadline:
            chunk = self._ser.read(1)
            if not chunk:
                continue
            b = chunk[0]
            if not buf:
                if b == self.protocol.START_BYTE:
                    buf.append(b)
                continue
            buf.append(b)
            if len(buf) == self.protocol.PACKET_SIZE:
                if buf[-1] == self.protocol.END_BYTE:
                    return bytes(buf)
                buf.clear()
        return bytes(buf)

    def request_feedback(self) -> tuple[bytes, bytes, dict[str, tuple[float, float, float]] | None]:
        with self._lock:
            if not self.connected:
                raise RuntimeError("Serial port is not connected")
            p1 = b""
            p2 = b""
            for mode in (0x01, 0x00, 0x02):
                self._ser.reset_input_buffer()
                self._ser.write(self.protocol.build_read_packet(0x01, mode))
                p1 = self._read_framed_packet(0.35)
                if len(p1) == 32:
                    break
            for mode in (0x01, 0x00, 0x02):
                self._ser.reset_input_buffer()
                self._ser.write(self.protocol.build_read_packet(0x02, mode))
                p2 = self._read_framed_packet(0.35)
                if len(p2) == 32:
                    break
        parsed = self.protocol.parse_motor_stream_packet(p1)
        return p1, p2, parsed


class AxisFrame(ttk.LabelFrame):
    def __init__(self, master: tk.Misc, axis_name: str) -> None:
        super().__init__(master, text=f"Axis {axis_name}")

        self.enabled_var = tk.BooleanVar(value=False)
        self.amplitude_var = tk.DoubleVar(value=15.0)
        self.frequency_var = tk.DoubleVar(value=0.3)
        self.position_var = tk.DoubleVar(value=180.0)

        ttk.Checkbutton(self, text="Enable sine", variable=self.enabled_var).grid(row=0, column=0, columnspan=2, sticky="w")
        ttk.Label(self, text="Amplitude (deg)").grid(row=1, column=0, sticky="w")
        ttk.Entry(self, textvariable=self.amplitude_var, width=10).grid(row=1, column=1, sticky="ew")
        ttk.Label(self, text="Frequency (Hz)").grid(row=2, column=0, sticky="w")
        ttk.Entry(self, textvariable=self.frequency_var, width=10).grid(row=2, column=1, sticky="ew")
        ttk.Label(self, text="Target position (deg)").grid(row=3, column=0, sticky="w")
        ttk.Entry(self, textvariable=self.position_var, width=10).grid(row=3, column=1, sticky="ew")
        self.columnconfigure(1, weight=1)

    def read(self) -> AxisCommand:
        return AxisCommand(
            enabled=bool(self.enabled_var.get()),
            amplitude_deg=float(self.amplitude_var.get()),
            frequency_hz=float(self.frequency_var.get()),
            target_deg=float(self.position_var.get()),
        )


class App(tk.Tk):
    UPDATE_PERIOD_S = 0.03

    def __init__(self) -> None:
        super().__init__()
        self.title("FFT Gyro Controller (Protocol-correct)")
        self.geometry("860x500")

        self.protocol_obj = FFTGyroProtocol()
        self.serial = SerialController(self.protocol_obj)

        self._running = False
        self._start_t = 0.0
        self._next_send_due_t = 0.0
        self._ports_cache: dict[str, object] = {}

        self.port_var = tk.StringVar(value="")
        self.baud_var = tk.StringVar(value=str(DEFAULT_BAUD))
        self.speed_raw_var = tk.IntVar(value=90)
        self.status_var = tk.StringVar(value="Disconnected")

        self.axis_frames: dict[str, AxisFrame] = {}
        self._build_ui()
        self.report_callback_exception = self._report_tk_exception

    def _build_ui(self) -> None:
        top = ttk.Frame(self, padding=8)
        top.pack(fill="x")

        ttk.Label(top, text="Port").grid(row=0, column=0, sticky="w")
        self.port_combo = ttk.Combobox(top, textvariable=self.port_var, width=16)
        self.port_combo.grid(row=0, column=1, sticky="w", padx=(4, 12))
        ttk.Button(top, text="Refresh", command=self.refresh_ports).grid(row=0, column=2, padx=(0, 12))

        ttk.Label(top, text="Baud").grid(row=0, column=3, sticky="w")
        self.baud_combo = ttk.Combobox(top, textvariable=self.baud_var, width=10, values=[str(v) for v in COMMON_BAUDS])
        self.baud_combo.grid(row=0, column=4, sticky="w", padx=(4, 12))

        ttk.Label(top, text="Speed raw (0-1023)").grid(row=0, column=5, sticky="w")
        ttk.Entry(top, textvariable=self.speed_raw_var, width=8).grid(row=0, column=6, sticky="w", padx=(4, 12))

        self.connect_btn = ttk.Button(top, text="Connect + Init", command=self.connect_serial)
        self.connect_btn.grid(row=0, column=7, padx=4)
        self.disconnect_btn = ttk.Button(top, text="Disconnect", command=self.disconnect_serial)
        self.disconnect_btn.grid(row=0, column=8, padx=4)

        ttk.Label(top, textvariable=self.status_var).grid(row=0, column=9, sticky="w", padx=(10, 0))

        body = ttk.Frame(self, padding=8)
        body.pack(fill="both", expand=True)
        for i, axis in enumerate(AXES):
            fr = AxisFrame(body, axis)
            fr.grid(row=0, column=i, sticky="nsew", padx=5)
            body.columnconfigure(i, weight=1)
            self.axis_frames[axis] = fr

        actions = ttk.Frame(self, padding=8)
        actions.pack(fill="x")
        self.start_btn = ttk.Button(actions, text="Start sine", command=self.start_sine)
        self.start_btn.pack(side="left", padx=4)
        self.stop_btn = ttk.Button(actions, text="Stop", command=self.stop_sine)
        self.stop_btn.pack(side="left", padx=4)
        ttk.Button(actions, text="Set X", command=lambda: self.set_single("X")).pack(side="left", padx=4)
        ttk.Button(actions, text="Set Y", command=lambda: self.set_single("Y")).pack(side="left", padx=4)
        ttk.Button(actions, text="Set Z", command=lambda: self.set_single("Z")).pack(side="left", padx=4)
        ttk.Button(actions, text="Set all", command=self.set_all).pack(side="left", padx=4)
        ttk.Button(actions, text="Read feedback", command=self.read_feedback).pack(side="left", padx=4)

        self.refresh_ports()
        self._update_ui_state()
        self.protocol("WM_DELETE_WINDOW", self._on_close)

    def _status(self, text: str, ok: bool = True) -> None:
        self.status_var.set(text)
        LOGGER.info(text) if ok else LOGGER.warning(text)

    def _report_tk_exception(self, exc: type[BaseException], val: BaseException, tb: object) -> None:
        LOGGER.exception("Unhandled Tk callback exception", exc_info=(exc, val, tb))
        messagebox.showerror("Application error", f"Unhandled exception: {val}")

    def _update_ui_state(self) -> None:
        connected = self.serial.connected
        self.connect_btn.configure(state="disabled" if connected else "normal")
        self.disconnect_btn.configure(state="normal" if connected else "disabled")
        state = "normal" if connected else "disabled"
        self.start_btn.configure(state=state)
        self.stop_btn.configure(state=state)

    def refresh_ports(self) -> None:
        ports: list[str] = []
        self._ports_cache.clear()
        if list_ports is not None:
            for p in list_ports.comports():
                ports.append(p.device)
                self._ports_cache[p.device] = p
        self.port_combo["values"] = ports
        if ports and self.port_var.get() not in ports:
            self.port_var.set(ports[0])

    def _axis_values(self, axis: str) -> AxisCommand:
        cmd = self.axis_frames[axis].read()
        if cmd.frequency_hz < 0 or cmd.frequency_hz > MAX_FREQUENCY_HZ:
            raise ValueError(f"{axis}: frequency must be 0..{MAX_FREQUENCY_HZ} Hz")
        if cmd.target_deg < 0 or cmd.target_deg > DEFAULT_MAX_ANGLE_DEG:
            raise ValueError(f"{axis}: target must be 0..{DEFAULT_MAX_ANGLE_DEG}°")
        if abs(cmd.amplitude_deg) > DEFAULT_MAX_ANGLE_DEG:
            raise ValueError(f"{axis}: amplitude too large")
        return cmd

    def _velocity_raw(self) -> int:
        v = int(self.speed_raw_var.get())
        if v < 0 or v > 1023:
            raise ValueError("Speed raw must be in 0..1023")
        return v

    def connect_serial(self) -> None:
        try:
            port = self.port_var.get().strip()
            if not port:
                raise ValueError("Select a serial port")
            baud = int(self.baud_var.get())
            self.serial.connect(port, baud)
            self.serial.initialize_for_joint_position_mode(0b111)
            self.serial.send_position(180.0, 180.0, 180.0, axis_mask=0b111, velocity_raw=self._velocity_raw())
            self._status(f"Connected and initialized: {port} @ {baud}", ok=True)
            self._update_ui_state()
        except Exception as exc:
            messagebox.showerror("Connection error", str(exc))

    def disconnect_serial(self) -> None:
        self.stop_sine()
        self.serial.disconnect()
        self._status("Disconnected", ok=False)
        self._update_ui_state()

    def set_single(self, axis: str) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect first")
            return
        try:
            idx = AXES.index(axis)
            vals = [180.0, 180.0, 180.0]
            vals[idx] = self._axis_values(axis).target_deg
            self.serial.send_position(vals[0], vals[1], vals[2], axis_mask=(1 << idx), velocity_raw=self._velocity_raw())
        except Exception as exc:
            messagebox.showerror("Command error", str(exc))

    def set_all(self) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect first")
            return
        try:
            vals = [self._axis_values(a).target_deg for a in AXES]
            self.serial.send_position(vals[0], vals[1], vals[2], axis_mask=0b111, velocity_raw=self._velocity_raw())
        except Exception as exc:
            messagebox.showerror("Command error", str(exc))

    def start_sine(self) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect first")
            return
        try:
            for ax in AXES:
                self._axis_values(ax)
            self._velocity_raw()
        except Exception as exc:
            messagebox.showerror("Input error", str(exc))
            return

        self._running = True
        self._start_t = time.monotonic()
        self._next_send_due_t = self._start_t
        self._tick()

    def stop_sine(self) -> None:
        self._running = False

    def _tick(self) -> None:
        if not self._running:
            return

        try:
            now = time.monotonic()
            if now < self._next_send_due_t:
                self.after(int(self.UPDATE_PERIOD_S * 1000), self._tick)
                return

            t = time.monotonic() - self._start_t
            cmds = [self._axis_values(a) for a in AXES]

            vals = []
            mask = 0
            for i, cmd in enumerate(cmds):
                if cmd.enabled:
                    # Run sine motion around the configured target position.
                    v = cmd.target_deg + cmd.amplitude_deg * math.sin(2 * math.pi * cmd.frequency_hz * t)
                    mask |= (1 << i)
                else:
                    v = cmd.target_deg
                vals.append(max(0.0, min(DEFAULT_MAX_ANGLE_DEG, v)))

            if mask:
                self.serial.send_position(vals[0], vals[1], vals[2], axis_mask=mask, velocity_raw=self._velocity_raw())
                min_interval = self.serial.min_command_interval_s()
                self._next_send_due_t = time.monotonic() + max(self.UPDATE_PERIOD_S, min_interval)
            else:
                self._next_send_due_t = time.monotonic() + self.UPDATE_PERIOD_S
        except TimeoutError as exc:
            self._running = False
            self._status(str(exc), ok=False)
            self.serial.disconnect()
            self._update_ui_state()
            messagebox.showwarning("Sine loop stopped", str(exc))
            return
        except Exception as exc:
            self._running = False
            LOGGER.exception("Sine loop failed")
            messagebox.showerror("Sine loop stopped", str(exc))
            return

        self.after(int(self.UPDATE_PERIOD_S * 1000), self._tick)

    def read_feedback(self) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect first")
            return
        try:
            p1, p2, parsed = self.serial.request_feedback()
        except Exception as exc:
            messagebox.showerror("Read error", str(exc))
            return

        parsed_txt = "No parsed motor packet (type 0x01) returned."
        if parsed is not None:
            p = parsed["position_deg"]
            v = parsed["velocity_rpm"]
            tq = parsed["torque_pct"]
            parsed_txt = (
                f"Parsed packet#1:\n"
                f"Position deg: {p[0]:.2f}, {p[1]:.2f}, {p[2]:.2f}\n"
                f"Velocity rpm: {v[0]:.2f}, {v[1]:.2f}, {v[2]:.2f}\n"
                f"Torque %: {tq[0]:.2f}, {tq[1]:.2f}, {tq[2]:.2f}"
            )

        msg = (
            f"Packet #1 ({len(p1)} bytes): {p1.hex()}\n\n"
            f"Packet #2 ({len(p2)} bytes): {p2.hex()}\n\n"
            f"{parsed_txt}"
        )
        messagebox.showinfo("Feedback", msg)

    def _on_close(self) -> None:
        self.stop_sine()
        self.serial.disconnect()
        self.destroy()


if __name__ == "__main__":
    App().mainloop()
