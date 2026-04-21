# fft-gyro-controller

GUI controller for FFT Gyro motors.

## Features

- Control **X, Y, Z** axes independently in **joint mode**.
- Configure **sine amplitude** and **frequency** per axis.
- Sine frequency is automatically validated against command update rate to avoid visibly jerky motion from undersampling.
- Send immediate per-axis or all-axis position targets.
- Configure command speed field (`0..1023`) for packet #2 writes.
- Configure telemetry data-rate setup (`1..255` units of 10 ms) during initialization to prevent serial saturation.
- Read and decode motor feedback using the official packet field layout.

## Run

```bash
python3 motor_gui.py
```

## Serial settings (per manual)

- Baudrate: `9600`
- Data bits: `8`
- Parity: `None`
- Stop bits: `1`

## Dependency

This app requires `pyserial`.

```bash
pip install pyserial
```

## Protocol implementation basis

This app is implemented from the official code in `fft-gyro/`:

- `fft-gyro/FFTGYROTestTool/FFTGyroLibrary.pde`
- `fft-gyro/MATLAB and Simulink files/sendPacket1ToGyroboard.m`
- `fft-gyro/MATLAB and Simulink files/sendPacket2ToGyroboard.m`
- `fft-gyro/MATLAB and Simulink files/getDataFromGyroboard2.m`

Protocol summary used by the app:

- All packets are 32 bytes.
- Byte 0 is start `0x7A` (`'z'`), byte 31 is end `0x7B` (`'{'`).
- Byte 1 selects packet type:
  - `0x01`: torque / limits / data-rate control and motor telemetry stream format.
  - `0x02`: position/velocity/angle-limit command packet.
  - `0x03`: motor mode configuration packet.
- Joint-mode initialization sends:
  1) packet #3 (`set mode`) with ASCII mode fields (`'1'`, `'2'`),
  2) packet #1 (`torque enable + torque limits + max torque`).
- Position control sends packet #2 with:
  - set-velocity bitmask at byte 15,
  - per-motor velocity fields bytes 16..21,
  - set-position bitmask at byte 22,
  - per-motor position fields bytes 23..28 (little-endian uint16).
- Motor telemetry parsing follows official offsets from `getDataFromGyroboard2.m`.

## Important operating note

The official tool maps position as absolute motor angle (`raw = deg / 0.088`) for MX motors,
not the older centered `-150..+150` mapping. This app follows that official mapping.
