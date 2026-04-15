#!/usr/bin/env python3
"""FFT Gyro axis controller GUI.

Primary UI is Tkinter (desktop). If Tkinter is unavailable (common on some
Homebrew Python builds), the app falls back to a browser-based local web UI
implemented with only the Python standard library.
"""

from __future__ import annotations

import html
import math
import struct
import threading
import time
import urllib.parse
import webbrowser
from dataclasses import dataclass
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

try:
    import tkinter as tk
    from tkinter import messagebox, ttk
except Exception:  # pragma: no cover - runtime/platform dependency
    tk = None
    messagebox = None
    ttk = None

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
    enabled: bool = False


class FFTGyroProtocol:
    """Packet encoder for 32-byte FFT Gyro write packets."""

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
        if not port:
            raise RuntimeError("COM port is empty")
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


class MotionEngine:
    UPDATE_PERIOD_S = 0.02

    def __init__(self, serial_controller: SerialController) -> None:
        self.serial = serial_controller
        self.axis_cfg = {
            "X": AxisState(),
            "Y": AxisState(),
            "Z": AxisState(),
        }
        self.position_setpoints = {"X": 0.0, "Y": 0.0, "Z": 0.0}
        self._lock = threading.Lock()
        self._running = False
        self._thread = None

    def set_axis(self, axis: str, enabled: bool, amplitude_deg: float, frequency_hz: float) -> None:
        with self._lock:
            self.axis_cfg[axis] = AxisState(enabled=enabled, amplitude_deg=amplitude_deg, frequency_hz=frequency_hz)

    def set_position(self, axis: str, value: float) -> None:
        with self._lock:
            self.position_setpoints[axis] = value

    def set_single_axis_now(self, axis: str) -> None:
        values = [0.0, 0.0, 0.0]
        idx = AXES.index(axis)
        with self._lock:
            values[idx] = float(self.position_setpoints[axis])
        self.serial.send_position(values[0], values[1], values[2], axis_mask=(1 << idx))

    def set_all_axes_now(self) -> None:
        with self._lock:
            values = [float(self.position_setpoints[a]) for a in AXES]
        self.serial.send_position(values[0], values[1], values[2], axis_mask=0b111)

    def start(self) -> None:
        with self._lock:
            if self._running:
                return
            self._running = True
        self._thread = threading.Thread(target=self._run, daemon=True)
        self._thread.start()

    def stop(self) -> None:
        with self._lock:
            self._running = False

    def _run(self) -> None:
        t0 = time.monotonic()
        while True:
            with self._lock:
                running = self._running
                axis_cfg = dict(self.axis_cfg)
            if not running:
                return

            t = time.monotonic() - t0
            vals = []
            mask = 0
            for i, axis in enumerate(AXES):
                cfg = axis_cfg[axis]
                if cfg.enabled:
                    vals.append(cfg.amplitude_deg * math.sin(2.0 * math.pi * cfg.frequency_hz * t))
                    mask |= (1 << i)
                else:
                    vals.append(0.0)

            if mask:
                try:
                    self.serial.send_position(vals[0], vals[1], vals[2], axis_mask=mask)
                except Exception:
                    with self._lock:
                        self._running = False
                    return

            time.sleep(self.UPDATE_PERIOD_S)


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


class TkApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("FFT Gyro Axis Controller")
        self.geometry("760x460")
        self.protocol_obj = FFTGyroProtocol()
        self.serial = SerialController(self.protocol_obj)
        self.motion = MotionEngine(self.serial)

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
        ports = [p.device for p in list_ports.comports()] if list_ports is not None else []
        self.port_combo["values"] = ports
        if not self.port_var.get() and ports:
            self.port_var.set(ports[0])

    def _sync_motion_settings(self) -> None:
        for axis in AXES:
            frame = self.axis_frames[axis]
            self.motion.set_axis(
                axis,
                enabled=bool(frame.enabled_var.get()),
                amplitude_deg=float(frame.amplitude_var.get()),
                frequency_hz=float(frame.frequency_var.get()),
            )
            self.motion.set_position(axis, float(frame.position_var.get()))

    def connect_serial(self) -> None:
        try:
            self.serial.connect(self.port_var.get().strip(), int(self.baud_var.get()))
            self.status_var.set(f"Connected: {self.port_var.get()}")
        except Exception as exc:
            messagebox.showerror("Connection error", str(exc))

    def disconnect_serial(self) -> None:
        self.motion.stop()
        self.serial.disconnect()
        self.status_var.set("Disconnected")

    def start_sine(self) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect a COM port first")
            return
        self._sync_motion_settings()
        self.motion.start()

    def stop_sine(self) -> None:
        self.motion.stop()

    def set_single_axis(self, axis: str) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect a COM port first")
            return
        self._sync_motion_settings()
        try:
            self.motion.set_single_axis_now(axis)
        except Exception as exc:
            messagebox.showerror("Serial error", str(exc))

    def set_all_axes(self) -> None:
        if not self.serial.connected:
            messagebox.showwarning("Not connected", "Connect a COM port first")
            return
        self._sync_motion_settings()
        try:
            self.motion.set_all_axes_now()
        except Exception as exc:
            messagebox.showerror("Serial error", str(exc))

    def _on_close(self) -> None:
        self.motion.stop()
        self.serial.disconnect()
        self.destroy()


class WebUI:
    """Fallback browser UI for environments without Tkinter."""

    def __init__(self) -> None:
        self.protocol = FFTGyroProtocol()
        self.serial = SerialController(self.protocol)
        self.motion = MotionEngine(self.serial)
        self.status = "Disconnected"
        self.port = ""
        self.baud = 115200

    def refresh_ports(self) -> list[str]:
        if list_ports is None:
            return []
        return [p.device for p in list_ports.comports()]

    def render(self) -> str:
        ports = self.refresh_ports()
        port_options = "".join(
            f'<option value="{html.escape(p)}" {"selected" if p == self.port else ""}>{html.escape(p)}</option>'
            for p in ports
        )
        rows = []
        for axis in AXES:
            cfg = self.motion.axis_cfg[axis]
            pos = self.motion.position_setpoints[axis]
            rows.append(
                f"""
<tr>
  <td>{axis}</td>
  <td><input type='checkbox' name='enabled_{axis}' {'checked' if cfg.enabled else ''}></td>
  <td><input name='amp_{axis}' value='{cfg.amplitude_deg}'></td>
  <td><input name='freq_{axis}' value='{cfg.frequency_hz}'></td>
  <td><input name='pos_{axis}' value='{pos}'></td>
</tr>
"""
            )
        return f"""<!doctype html>
<html><head><meta charset='utf-8'><title>FFT Gyro Controller</title>
<style>body{{font-family:Arial;margin:16px}} table{{border-collapse:collapse}} td,th{{border:1px solid #bbb;padding:6px}} input{{width:120px}}</style>
</head><body>
<h2>FFT Gyro Axis Controller (Web Fallback)</h2>
<p>Status: <b>{html.escape(self.status)}</b></p>
<form method='post' action='/action'>
<p>Port: <select name='port'><option value=''>--select--</option>{port_options}</select>
Baud: <input name='baud' value='{self.baud}' style='width:100px'>
<button name='cmd' value='refresh'>Refresh Ports</button>
<button name='cmd' value='connect'>Connect</button>
<button name='cmd' value='disconnect'>Disconnect</button></p>
<table><tr><th>Axis</th><th>Enable sine</th><th>Amplitude (deg)</th><th>Frequency (Hz)</th><th>Set position (deg)</th></tr>
{''.join(rows)}
</table>
<p>
<button name='cmd' value='start'>Start sine motion</button>
<button name='cmd' value='stop'>Stop sine motion</button>
<button name='cmd' value='set_x'>Set X</button>
<button name='cmd' value='set_y'>Set Y</button>
<button name='cmd' value='set_z'>Set Z</button>
<button name='cmd' value='set_all'>Set all</button>
</p>
</form>
</body></html>"""

    def apply_form(self, form: dict[str, list[str]]) -> None:
        self.port = form.get("port", [self.port])[0]
        try:
            self.baud = int(form.get("baud", [str(self.baud)])[0])
        except ValueError:
            pass

        for axis in AXES:
            enabled = f"enabled_{axis}" in form
            amp = float(form.get(f"amp_{axis}", ["0"])[0])
            freq = float(form.get(f"freq_{axis}", ["0.1"])[0])
            pos = float(form.get(f"pos_{axis}", ["0"])[0])
            self.motion.set_axis(axis, enabled, amp, freq)
            self.motion.set_position(axis, pos)

        cmd = form.get("cmd", [""])[0]
        try:
            if cmd == "connect":
                self.serial.connect(self.port, self.baud)
                self.status = f"Connected: {self.port}"
            elif cmd == "disconnect":
                self.motion.stop()
                self.serial.disconnect()
                self.status = "Disconnected"
            elif cmd == "start":
                if not self.serial.connected:
                    raise RuntimeError("Connect a COM port first")
                self.motion.start()
            elif cmd == "stop":
                self.motion.stop()
            elif cmd == "set_x":
                self.motion.set_single_axis_now("X")
            elif cmd == "set_y":
                self.motion.set_single_axis_now("Y")
            elif cmd == "set_z":
                self.motion.set_single_axis_now("Z")
            elif cmd == "set_all":
                self.motion.set_all_axes_now()
        except Exception as exc:
            self.status = f"Error: {exc}"


def run_web_fallback() -> None:
    app = WebUI()

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self) -> None:  # noqa: N802
            payload = app.render().encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)

        def do_POST(self) -> None:  # noqa: N802
            n = int(self.headers.get("Content-Length", "0"))
            body = self.rfile.read(n).decode("utf-8")
            form = urllib.parse.parse_qs(body)
            app.apply_form(form)
            self.send_response(303)
            self.send_header("Location", "/")
            self.end_headers()

        def log_message(self, format: str, *args: object) -> None:  # noqa: A003
            return

    server = ThreadingHTTPServer(("127.0.0.1", 8765), Handler)
    print("Tkinter is unavailable. Starting web fallback at http://127.0.0.1:8765")
    try:
        webbrowser.open("http://127.0.0.1:8765")
    except Exception:
        pass
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        app.motion.stop()
        app.serial.disconnect()
        server.server_close()


if __name__ == "__main__":
    if tk is not None:
        tk_app = TkApp()
        tk_app.mainloop()
    else:
        run_web_fallback()
