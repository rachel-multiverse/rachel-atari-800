# Rachel Atari 8-bit

A render-only client for the Rachel card game, written in 6502 assembly for the Atari 400/800/XL/XE.

## Hardware target

- **Atari 8-bit FujiNet hardware v1.0 or later**, connected to the Atari SIO
  port and running the Atari build of FujiNet firmware. The current official
  hardware revision is 1.7; the network protocol is shared by earlier released
  Atari boards.

Rachel talks directly to FujiNet SIO network device `$71`. It does not require
the optional resident `N:` CIO handler. Its only external runtime assumptions
are configured Wi-Fi and reachable raw TCP service on the entered `HOST:PORT`.

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

## Atari devices

- **E:** - Screen output (channel 0)
- **K:** - Keyboard input
- **FujiNet `$71`:** direct SIO networking (`O`, `S`, `R`, `W`, and `C`)

## Testing

- `make test` checks the assembled XEX and canonical protocol constants on every CI run.
- **Altirra** - Full-featured Atari emulator with FujiNet support
- **Atari800** - Cross-platform emulator
- **Real hardware** - Load via FujiNet or SIO2SD; no DOS network handler needed

## Original-hardware smoke test

1. Update an Atari FujiNet to the current Atari firmware and configure Wi-Fi.
2. Start a Rachel Go server reachable over unencrypted TCP from the same LAN.
3. Load `build/rachel.xex` directly from FujiNet or an SIO disk device.
4. Enter the server as `IPv4-address:port` (for example `192.168.1.20:6502`).
5. Confirm the client receives `WELCOME`, enters the lobby, and receives its
   private hand when the game starts.
6. Play and draw at least one card, then confirm a second 64-byte message is not
   lost or merged with the first.
7. Power-cycle FujiNet and repeat to prove there is no resident-handler state.

## License

MIT
