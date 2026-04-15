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
import struct
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


@dataclass
class AxisState:
    amplitude_deg: float = 0.0
    frequency_hz: float = 0.1
    phase_rad: float = 0.0
    enabled: bool = False


class FFTGyroProtocol:
    """Packet encoder for 32-byte FFT Gyro write packets.

    Current defaults (editable in this class):
    - Byte 0: 0xAA packet marker
    - Byte 1: mode (0x03 write packet type-2)
    - Byte 2: command (0x10 set position)
    - Byte 3: axis mask bit0=X bit1=Y bit2=Z
    - Byte 4..15: 3x float32 little-endian positions in degrees (X,Y,Z)
    - Byte 30: packet counter
    - Byte 31: checksum (sum of bytes[0:31] & 0xFF)
    """

    PACKET_SIZE = 32
    MODE_WRITE_TYPE2 = 0x03
    CMD_SET_POSITION = 0x10

    def __init__(self) -> None:
        self._counter = 0

    def build_set_position(self, x_deg: float, y_deg: float, z_deg: float, axis_mask: int = 0b111) -> bytes:
        pkt = bytearray(self.PACKET_SIZE)
        pkt[0] = 0xAA
        pkt[1] = self.MODE_WRITE_TYPE2
        pkt[2] = self.CMD_SET_POSITION
        pkt[3] = axis_mask & 0x07

        struct.pack_into("<fff", pkt, 4, float(x_deg), float(y_deg), float(z_deg))

        self._counter = (self._counter + 1) & 0xFF
        pkt[30] = self._counter
        pkt[31] = sum(pkt[:-1]) & 0xFF
        return bytes(pkt)


class SerialController:
    def __init__(self, protocol: FFTGyroProtocol) -> None:
        self.protocol = protocol
        self._ser = None
        self._lock = threading.Lock()

    @property
    def connected(self) -> bool:
        return self._ser is not None and self._ser.is_open

    def connect(self, port: str, baud: int = 115200) -> None:
        if serial is None:
            raise RuntimeError("pyserial is not installed. Install with: pip install pyserial")

        with self._lock:
            self.disconnect()
            self._ser = serial.Serial(port=port, baudrate=baud, timeout=0.1)

    def disconnect(self) -> None:
        with self._lock:
            if self._ser is not None:
                try:
                    self._ser.close()
                finally:
                    self._ser = None

    def send_position(self, x_deg: float, y_deg: float, z_deg: float, axis_mask: int = 0b111) -> None:
        pkt = self.protocol.build_set_position(x_deg, y_deg, z_deg, axis_mask)
        with self._lock:
            if not self.connected:
                raise RuntimeError("Serial port is not connected")
            self._ser.write(pkt)


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

        self.port_var = tk.StringVar(value="")
        self.baud_var = tk.IntVar(value=115200)
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
        ttk.Entry(top, textvariable=self.baud_var, width=10).grid(row=0, column=4, padx=(4, 12), sticky="w")

        ttk.Button(top, text="Connect", command=self.connect_serial).grid(row=0, column=5, padx=4)
        ttk.Button(top, text="Disconnect", command=self.disconnect_serial).grid(row=0, column=6, padx=4)

        ttk.Label(top, textvariable=self.status_var, foreground="#0a4").grid(row=0, column=7, padx=(20, 0), sticky="w")

        axis_container = ttk.Frame(self, padding=8)
        axis_container.pack(fill="both", expand=True)

        for idx, axis in enumerate(AXES):
            frame = AxisFrame(axis_container, axis)
            frame.grid(row=0, column=idx, sticky="nsew", padx=6, pady=6)
            self.axis_frames[axis] = frame
            axis_container.columnconfigure(idx, weight=1)

        actions = ttk.Frame(self, padding=8)
        actions.pack(fill="x")

        ttk.Button(actions, text="Start sine motion", command=self.start_sine).pack(side="left", padx=4)
        ttk.Button(actions, text="Stop sine motion", command=self.stop_sine).pack(side="left", padx=4)
        ttk.Button(actions, text="Set X", command=lambda: self.set_single_axis("X")).pack(side="left", padx=4)
        ttk.Button(actions, text="Set Y", command=lambda: self.set_single_axis("Y")).pack(side="left", padx=4)
        ttk.Button(actions, text="Set Z", command=lambda: self.set_single_axis("Z")).pack(side="left", padx=4)
        ttk.Button(actions, text="Set all", command=self.set_all_axes).pack(side="left", padx=4)

        self.refresh_ports()
        self.protocol("WM_DELETE_WINDOW", self._on_close)

    def refresh_ports(self) -> None:
        ports = []
        if list_ports is not None:
            ports = [p.device for p in list_ports.comports()]
        self.port_combo["values"] = ports
        if not self.port_var.get() and ports:
            self.port_var.set(ports[0])

    def connect_serial(self) -> None:
        try:
            self.serial.connect(self.port_var.get().strip(), int(self.baud_var.get()))
            self.status_var.set(f"Connected: {self.port_var.get()}")
        except Exception as exc:
            messagebox.showerror("Connection error", str(exc))

    def disconnect_serial(self) -> None:
        self.serial.disconnect()
        self.status_var.set("Disconnected")

    def start_sine(self) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect a COM port first")
            return
        if self._running:
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
            state = self.axis_frames[axis].get_state()
            if state.enabled:
                value = state.amplitude_deg * math.sin(2.0 * math.pi * state.frequency_hz * t)
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
        values[idx] = float(self.axis_frames[axis].position_var.get())

        try:
            self.serial.send_position(values[0], values[1], values[2], axis_mask=(1 << idx))
        except Exception as exc:
            messagebox.showerror("Serial error", str(exc))

    def set_all_axes(self) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect a COM port first")
            return

        values = [float(self.axis_frames[a].position_var.get()) for a in AXES]
        try:
            self.serial.send_position(values[0], values[1], values[2], axis_mask=0b111)
        except Exception as exc:
            messagebox.showerror("Serial error", str(exc))

    def _on_close(self) -> None:
        self.stop_sine()
        self.disconnect_serial()
        self.destroy()


if __name__ == "__main__":
    app = App()
    app.mainloop()
