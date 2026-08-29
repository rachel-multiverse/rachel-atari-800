#!/usr/bin/env python3
"""Small dependency-free regression checks for the Atari RUBP client."""

from pathlib import Path
import re
import struct

ROOT = Path(__file__).resolve().parents[1]


def constants() -> dict[str, int]:
    values: dict[str, int] = {}
    for line in (ROOT / "src/equates.asm").read_text().splitlines():
        match = re.match(r"^([A-Z][A-Z0-9_]*)\s*=\s*\$([0-9A-Fa-f]+)\s*(?:;.*)?$", line)
        if match:
            values[match.group(1)] = int(match.group(2), 16)
            continue
        match = re.match(r"^([A-Z][A-Z0-9_]*)\s*=\s*([0-9]+)\s*(?:;.*)?$", line)
        if match:
            values[match.group(1)] = int(match.group(2))
    return values


def test_wire_constants() -> None:
    actual = constants()
    expected = {
        "MSG_HELLO": 0x01, "MSG_WELCOME": 0x02, "MSG_GAME_START": 0x03,
        "MSG_PLAY_CARD": 0x04, "MSG_DRAW_CARD": 0x05, "MSG_CARD_DRAWN": 0x06,
        "MSG_GAME_STATE": 0x07, "MSG_TURN_START": 0x08, "MSG_TURN_END": 0x09,
        "MSG_PLAYER_WON": 0x0A, "MSG_ERROR": 0x0B,
        "HDR_VERSION": 4, "HDR_TYPE": 5, "HDR_SEQ": 6,
        "HDR_PLAYER_ID": 8, "HDR_GAME_ID": 10, "HDR_TIMESTAMP": 12,
        "HDR_SIZE": 16, "PAYLOAD_START": 16, "PAYLOAD_SIZE": 48,
        "RACHEL_SPEC_VER": 1,
    }
    assert {key: actual[key] for key in expected} == expected


def xex_segments(data: bytes):
    offset = 0
    while offset + 2 <= len(data):
        marker = struct.unpack_from("<H", data, offset)[0]
        if marker == 0xFFFF:
            offset += 2
        if offset + 4 > len(data):
            raise AssertionError("truncated XEX segment header")
        start, end = struct.unpack_from("<HH", data, offset)
        offset += 4
        size = end - start + 1
        if end < start or offset + size > len(data):
            raise AssertionError("invalid XEX segment")
        yield start, end
        offset += size


def test_xex_avoids_iocbs() -> None:
    segments = list(xex_segments((ROOT / "build/rachel.xex").read_bytes()))
    assert segments
    assert not any(start <= 0x03BF and end >= 0x0340 for start, end in segments)


if __name__ == "__main__":
    test_wire_constants()
    test_xex_avoids_iocbs()
    print("Atari RUBP/XEX conformance checks passed")
