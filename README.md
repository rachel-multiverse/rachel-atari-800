# Rachel Atari 8-bit

A render-only client for the Rachel card game, written in 6502 assembly for the Atari 400/800/XL/XE.

## Hardware Targets

- **FujiNet** - WiFi adapter for Atari 8-bit providing TCP/IP via N: device

## Requirements

- [Altirra](https://www.virtualdub.org/altirra.html) or [Atari800](https://atari800.github.io/) for emulation

`make` downloads a checksum-verified MADS binary pinned to an exact upstream
commit. Linux x86-64 and Apple Silicon are supported by the bootstrap script;
set `MADS=/path/to/mads` on other hosts.

## Building

```bash
make        # Build rachel.xex
make test   # Build and verify wire constants/XEX memory safety
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

Uses RUBP v1 (Rachel Unified Binary Protocol): fixed 64-byte messages over TCP,
with canonical message IDs, big-endian header fields and RachelSpec v1 action
metadata. Private hand changes arrive through `GAME_START` and `CARD_DRAWN`;
`GAME_STATE` contains public state only.

Full specification: [rachel-multiverse/protocol](https://github.com/rachel-multiverse/protocol) — also rendered at <https://rachel.stevehill.xyz/protocol>.

## Atari CIO Devices

- **E:** - Screen output (channel 0)
- **K:** - Keyboard input
- **N:** - FujiNet network device (channel 1)

## Testing

- `make test` checks the assembled XEX and canonical protocol constants on every CI run.
- **Altirra** - Full-featured Atari emulator with FujiNet support
- **Atari800** - Cross-platform emulator
- **Real hardware** - Load via FujiNet or SIO2SD

## License

MIT
