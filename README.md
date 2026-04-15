# fft-gyro-controller

GUI controller for FFT Gyro motors.

## Features

- Control **X, Y, Z** axes independently.
- Configure **sine amplitude** and **frequency** per axis.
- Run continuous sine-wave motion around origin `(0,0,0)`.
- Set immediate target position for each axis (or all axes).
- Read back raw response packets from motors (packets #1 and #2) for protocol debugging.
- Send commands over serial as 32-byte packets.

## Run

```bash
python3 motor_gui.py
```

## Dependency

This app requires `pyserial`.

```bash
pip install pyserial
```

## Protocol implementation notes

`communication_protocol.pdf` defines fixed 32-byte packets:

- Byte 0: start byte (`0x7A`)
- Byte 1: packet number (`0x01`, `0x02`, `0x03`)
- Byte 31: final byte (`0x7B`)

The app currently sends:

- **Write packet #3** on connect to switch motors to **joint mode** and turn them on.
- **Write packet #1** on connect to enable motor torque.
- **Write packet #2** for position commands:
  - Byte 22: position mask (bit 0/1/2 => M1/M2/M3)
  - Bytes 23..28: M1/M2/M3 target positions as little-endian `uint16` values in the `0..1023` range.
- **Read packet #1 and #2** when using **Read motor feedback**:
  - Uses packet number in byte 1, with byte 30 set to `0x01` for read mode.
  - Displays raw returned packet hex and attempts to decode packet #2 bytes 23..28 as M1/M2/M3 positions.

If your board uses different field offsets or checksum logic, update only `FFTGyroProtocol` in
`motor_gui.py`.
