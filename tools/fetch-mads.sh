#!/bin/sh
set -eu

revision=7cccd6c65154a3c199eb504e1634c4ae788b04f0
base=https://raw.githubusercontent.com/tebe6502/Mad-Assembler/$revision/bin

case "$(uname -s):$(uname -m)" in
  Linux:x86_64)
    artifact=linux_x86_64/mads
    expected=4f5e3e4fa5a299d7f44611398eacaddf4cd04cb0ccf73f2455c368ec27c8b981
    ;;
  Darwin:arm64)
    artifact=macos_aarch64/mads
    expected=ba89693a2881906d9fafca1b2d2ecf800b3d69aa374ce77fe83d9cfba864d1ef
    ;;
  *)
    echo "Unsupported host; install MADS and run make MADS=/path/to/mads" >&2
    exit 1
    ;;
esac

mkdir -p .tools
temporary=.tools/mads.download
trap 'rm -f "$temporary"' EXIT HUP INT TERM
curl -fsSL "$base/$artifact" -o "$temporary"
actual=$(shasum -a 256 "$temporary" | awk '{print $1}')
if [ "$actual" != "$expected" ]; then
  echo "MADS checksum mismatch: expected $expected, got $actual" >&2
  exit 1
fi
chmod +x "$temporary"
mv "$temporary" .tools/mads
