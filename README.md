# Rachel Atari 8-bit

A render-only client for the Rachel card game, written in 6502 assembly for the Atari 400/800/XL/XE.

## Hardware Targets

- **FujiNet** - WiFi adapter for Atari 8-bit providing TCP/IP via N: device

## Requirements

- [MADS](https://github.com/tebe6502/Mad-Assembler) - Mad Assembler for 6502
- [Altirra](https://www.virtualdub.org/altirra.html) or [Atari800](https://atari800.github.io/) for emulation

## Building

```bash
make        # Build rachel.xex
make run    # Run in Atari800 emulator
make clean  # Remove build artifacts
```

## Output Files

- `build/rachel.xex` - Atari XEX executable

## Project Structure

```
src/
├── main.asm        # Entry point, initialization, main loop
├── equates.asm     # Atari OS equates and memory map
├── display.asm     # CIO-based E: device screen output
├── input.asm       # Keyboard handling via K: device
├── rubp.asm        # 64-byte RUBP protocol
├── game.asm        # Card and game state display
├── connect.asm     # Connection flow
└── net/
    └── fujinet.asm # FujiNet N: device driver
```

## Protocol

Uses RUBP (Rachel Unified Binary Protocol) - 64-byte fixed messages over TCP. Same protocol as the C64 and ZX Spectrum clients.

Full specification: [rachel-multiverse/protocol](https://github.com/rachel-multiverse/protocol) — also rendered at <https://rachel.stevehill.xyz/protocol>.

## Atari CIO Devices

- **E:** - Screen output (channel 0)
- **K:** - Keyboard input
- **N:** - FujiNet network device (channel 1)

## Testing

- **Altirra** - Full-featured Atari emulator with FujiNet support
- **Atari800** - Cross-platform emulator
- **Real hardware** - Load via FujiNet or SIO2SD

## License

MIT
