# DIY Motion Simulator

This project provides a comprehensive guide to building a low-cost DIY motion simulator for flying RC planes and simulator games. Combining woodworking and mechatronics, it offers an affordable alternative to commercial options. The documentation includes CAD models, detailed assembly instructions, and software setup.

Support This Project: [Patreon](https://patreon.com/MichaelRechtin)

## Features
- Compatible with flight simulation games like Microsoft Flight Simulator 2020/2024 and WarThunder.
- Support for RC planes using ArduPilot.
- Modular design for portability, using a universal joint for base and chair connection.
- Open-source software and hardware design.

## Disclaimer
This is a DIY project; individual modifications may be necessary due to part availability or unique requirements. Ensure proper safety precautions, and consult professionals when needed. The author is not liable for any issues arising from the build.

## Getting Started
1. **CAD Models**: Access the full CAD design [here](https://cad.onshape.com/documents/14465a5308115755a641bf91/w/473302792caf9fe5237c9eca/e/42b5f99c290e18c70798f158?renderMode=0&uiState=67888ffc05482c0eb0b74d11).
2. **Bill of Materials**: Refer to the detailed parts list in the documentation for all required components.
3. **Tools Required**:
   - Saws (e.g., circular, jigsaw, CNC router)
   - Power drill, impact driver
   - Soldering iron, 3D printer

## Assembly
The simulator comprises two main parts:
- **Base Assembly**: Includes motor mounts, universal joint, and support structures.
- **Chair Assembly**: Features side panels, foot supports, and a universal joint for connection to the base.

Follow the detailed step-by-step instructions in the documentation.

## Electronics and Wiring
The wiring for the simulator includes:
- Motion base wiring for motors and drivers.
- Side compartment wiring for controller integration.
- Back panel connectors for ease of disassembly.

Ensure proper orientation and connections for the MPU6050 sensor and other components.

## Software Setup
- **Teensy 4.0**: Flash the provided C++ code to control pitch and roll motors.
- **Raspberry Pi**: Configure USB flight controls and autorun scripts for seamless operation.
- **PC Integration**: Install necessary Python packages for supported games. Full code and instructions are available on the [GitHub repository](https://github.com/MichaelRechtin/MotionSim).

## Supported Games and Modes
- **Simulator Games**: Microsoft Flight Simulator 2020/2024, WarThunder
- **RC Planes**: Integration with Ardupilot and MAVLINK configurations

## Additional Features
- Optional integration with Buttkicker for enhanced gaming experience.
- Flexible wiring options for custom setups.

## Resources
- [Detailed Documentation](./DIY%20Motion%20Simulator%20Documentation.pdf)
- [PCB CI/CD Documentation](./docs/PCB_CI_CD.md) - Automated PCB manufacturing file generation
- [GitHub Repository](https://github.com/MichaelRechtin/MotionSim)
- [Bill of Materials](#)

### PCB Manufacturing

This repository includes automated CI/CD workflows for generating PCB manufacturing files:

- **Automated Gerber Generation**: Manufacturing files are automatically generated from KiCad PCB designs
- **Release Management**: Semantic versioning triggers automatic GitHub releases with PCB files
- **Local Generation**: Use `./generate-pcb-files.sh` to generate files locally

See [PCB CI/CD Documentation](./docs/PCB_CI_CD.md) for detailed information.

---

Feel free to explore, modify, and enjoy your DIY Motion Simulator!
