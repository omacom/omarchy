#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

home=$(mktemp -d)
trap 'rm -rf "$home"' EXIT

bin="$home/bin"
theme="$home/.local/state/omarchy/current/theme"
output="$home/.local/state/omarchy/telegram/omarchy.tdesktop-palette"
notes="$home/notes"
present="$home/telegram-present"
mkdir -p "$bin" "$theme"

cat >"$bin/omarchy-pkg-present" <<EOF
#!/bin/bash
[[ \$1 == "telegram-desktop" && -f $present ]]
EOF
cat >"$bin/omarchy-notification-send" <<EOF
#!/bin/bash
printf '%s\n' "\$*" >>"$notes"
EOF
chmod +x "$bin/omarchy-pkg-present" "$bin/omarchy-notification-send"

run_sync() {
  PATH="$bin:$ROOT/bin:$PATH" HOME="$home" "$ROOT/bin/omarchy-theme-set-telegram"
}

run_sync || fail "telegram theme sync exits quietly when Telegram is not installed"
[[ ! -e $output ]] || fail "telegram theme sync writes nothing when Telegram is not installed"
pass "telegram theme sync writes nothing when Telegram is not installed"

touch "$present"
run_sync || fail "telegram theme sync exits quietly when the palette is missing"
[[ ! -e $output ]] || fail "telegram theme sync writes nothing when the palette is missing"
pass "telegram theme sync writes nothing when the palette is missing"

printf 'windowBg: #1a1b26;\nwindowFg: #c0caf5;\n' >"$theme/colors.tdesktop-theme"
run_sync || fail "telegram theme sync writes the palette package"
[[ -f $output ]] || fail "telegram theme sync writes the palette package"

/usr/bin/python3 - "$output" <<'PY' || fail "telegram theme sync packs the palette and a wallpaper"
import sys
import zipfile

archive = zipfile.ZipFile(sys.argv[1])
names = set(archive.namelist())
if names != {"colors.tdesktop-theme", "background.png"}:
    sys.exit(f"entries: {sorted(names)}")
palette = archive.read("colors.tdesktop-theme").decode()
if "windowBg: #1a1b26;" not in palette:
    sys.exit("palette lost windowBg")
if not archive.read("background.png").startswith(b"\x89PNG"):
    sys.exit("wallpaper is not a png")
PY
pass "telegram theme sync packs the palette and a wallpaper"

before=$(sha256sum "$output")
inode=$(stat -c %i "$output")
run_sync || fail "telegram theme sync accepts an unchanged palette"
[[ $(sha256sum "$output") == "$before" && $(stat -c %i "$output") == "$inode" ]] ||
  fail "telegram theme sync leaves an unchanged package in place"
[[ $(wc -l <"$notes") == 1 && $(<"$notes") == *"$output"* ]] ||
  fail "telegram theme sync asks once how to load the palette" "$(<"$notes")"
pass "telegram theme sync leaves an unchanged package in place and asks only once"

printf 'windowBg: #eff1f5;\nwindowFg: #4c4f69;\n' >"$theme/colors.tdesktop-theme"
run_sync || fail "telegram theme sync rewrites a changed palette"
[[ -f $output && $(sha256sum "$output") != "$before" ]] ||
  fail "telegram theme sync keeps a stale package"

/usr/bin/python3 - "$output" <<'PY' || fail "telegram theme sync packs the new palette and wallpaper"
import struct
import sys
import zlib
import zipfile

archive = zipfile.ZipFile(sys.argv[1])
names = set(archive.namelist())
if names != {"colors.tdesktop-theme", "background.png"}:
    sys.exit(f"entries: {sorted(names)}")
palette = archive.read("colors.tdesktop-theme").decode()
if "windowBg: #eff1f5;" not in palette:
    sys.exit("palette lost the new windowBg")
if "windowBg: #1a1b26;" in palette:
    sys.exit("palette kept the old windowBg")

png = archive.read("background.png")
if not png.startswith(b"\x89PNG\r\n\x1a\n"):
    sys.exit("wallpaper is not a png")
pos = 8
idat = b""
while pos + 8 <= len(png):
    length = struct.unpack(">I", png[pos : pos + 4])[0]
    tag = png[pos + 4 : pos + 8]
    data = png[pos + 8 : pos + 8 + length]
    if tag == b"IDAT":
        idat += data
    if tag == b"IEND":
        break
    pos += 12 + length
raw = zlib.decompress(idat)
if raw != b"\x00\xef\xf1\xf5":
    sys.exit(f"wallpaper pixel {raw.hex()}")
PY
[[ $(wc -l <"$notes") == 1 ]] ||
  fail "telegram theme sync asks again after the palette changes" "$(<"$notes")"
pass "telegram theme sync rewrites a changed palette and asks only once"
