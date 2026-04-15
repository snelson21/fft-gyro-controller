# fft-gyro-controller

GUI controller for FFT Gyro motors.

## Features

- Control **X, Y, Z** axes independently.
- Configure **sine amplitude** and **frequency** per axis.
- Run continuous sine-wave motion around origin `(0,0,0)`.
- Set immediate target position for each axis (or all axes).
- Send commands over serial as 32-byte packets.

## Run

```bash
python3 motor_gui.py
```

## Dependency

This app requires `pyserial`.

The app uses a Tkinter desktop UI when available. On Python builds without Tk (for example some Homebrew Python installs), it automatically falls back to a local browser UI at `http://127.0.0.1:8765`.

```bash
pip install pyserial
```

## Protocol implementation notes

`communication_protocol.pdf` indicates 32-byte packets and that the second byte identifies mode.
The PDF tables with exact byte offsets are image-based in this environment, so packet encoding is
centralized in `FFTGyroProtocol` for easy adjustment if your firmware expects different offsets:

- Byte 0: marker (`0xAA`)
- Byte 1: mode (`0x03`, write type-2)
- Byte 2: command (`0x10`, set position)
- Byte 3: axis mask (bit 0/1/2 => X/Y/Z)
- Bytes 4..15: X/Y/Z target position (`float32` little-endian, degrees)
- Byte 30: packet counter
- Byte 31: checksum (`sum(bytes[0:31]) & 0xFF`)

If your board uses different field offsets or checksum logic, update only `FFTGyroProtocol` in
`motor_gui.py`.
