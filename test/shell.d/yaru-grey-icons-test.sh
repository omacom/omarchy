#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
# The real builder sees only fixture state and an explicit command allowlist.
mkdir -p "$work/bin" "$work/home" "$work/runtime" "$work/tmp"
for tool in bash cp rm mkdir mktemp find readlink realpath ln mv python3; do
  ln -s "$(command -v "$tool")" "$work/bin/$tool"
done
cat >"$work/bin/gtk-update-icon-cache" <<'EOF'
#!/bin/bash
(( $# == 3 )) && [[ $1 == "-f" && $2 == "-q" && $3 == "$ICON_FIXTURE/dest/"Yaru-gr?y ]] || exit 99
EOF
chmod +x "$work/bin/gtk-update-icon-cache"
run_installer() {
  env -i HOME="$work/home" XDG_DATA_HOME="$work/home/data" \
    XDG_CONFIG_HOME="$work/home/config" XDG_CACHE_HOME="$work/home/cache" \
    XDG_STATE_HOME="$work/home/state" XDG_RUNTIME_DIR="$work/runtime" \
    TMPDIR="$work/tmp" PATH="$work/bin" ICON_FIXTURE="$work" \
    FAIL_OPERATION="${FAIL_OPERATION:-}" \
    "$ROOT/bin/omarchy-theme-install-yaru-grey" "$@"
}
source_icons="$work/source"
dest_icons="$work/dest"

python3 - "$source_icons" <<'PY'
import pathlib, struct, sys, zlib

root = pathlib.Path(sys.argv[1])

def chunk(tag, data):
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

def write_png(path, pixels, filtered=False):
    width = len(pixels[0])
    height = len(pixels)
    raw = bytearray()
    for y, row in enumerate(pixels):
        if filtered and y == 0:
            raw.append(1)
            previous = (0, 0, 0, 0)
            for pixel in row:
                stored = tuple((pixel[channel] - previous[channel]) & 255 for channel in range(4))
                raw.extend(stored)
                previous = pixel
        else:
            raw.append(0)
            for pixel in row:
                raw.extend(pixel)
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)

blue = (0, 113, 226, 255)
soft = (10, 20, 30, 128)
red = (255, 0, 0, 255)
folder = [[blue, soft]]

def index(name, inherits, directories):
    lines = [
        "[Icon Theme]",
        f"Name={name}",
        "Comment=Accent",
        f"Inherits={inherits}",
        "Example=folder",
        f"Directories={directories}",
        "",
    ]
    for directory in directories.split(","):
        lines += [f"[{directory}]", "Size=48", "Context=Places", "Type=Fixed", ""]
    return "\n".join(lines)

svg = """<svg xmlns="http://www.w3.org/2000/svg">
  <path fill="#0071e2" stroke="#e95420" style="stop-color:#19b6ee"/>
  <rect fill="url(#keep)" stroke="none"/>
  <circle fill="rgb(0, 113, 226)" stroke="rgba(233,84,32,0.5)"/>
  <page bordercolor="#666666"/>
</svg>
"""

for parent in ("Yaru", "Yaru-dark"):
    theme = root / parent
    theme.mkdir(parents=True)
    (theme / "index.theme").write_text(f"[Icon Theme]\nName={parent}\nInherits=hicolor\nDirectories=\n")

write_png(root / "Yaru-dark" / "16x16" / "status" / "dialog-error.png", [[red]])

blue_theme = root / "Yaru-blue"
write_png(blue_theme / "48x48" / "places" / "folder.png", folder, filtered=True)
(blue_theme / "48x48" / "places" / "inode-directory.png").symlink_to("folder.png")
(blue_theme / "48x48" / "places" / "absolute-folder.png").symlink_to(blue_theme / "48x48" / "places" / "folder.png")
(blue_theme / "scalable" / "devices").mkdir(parents=True)
(blue_theme / "scalable" / "devices" / "audio.svg").write_text(svg)
(blue_theme / "index.theme").write_text(index("Yaru-blue", "Yaru,hicolor", "48x48/places,scalable/devices"))
(blue_theme / "icon-theme.cache").write_text("stale")

dark = root / "Yaru-blue-dark"
write_png(dark / "48x48" / "places" / "folder.png", folder, filtered=True)
(dark / "scalable" / "devices").mkdir(parents=True)
(dark / "scalable" / "devices" / "audio.svg").write_text(svg)
(dark / "scalable" / "absolute-devices").symlink_to(dark / "scalable" / "devices")
(dark / "16x16").mkdir()
(dark / "16x16" / "status").symlink_to("../../Yaru-dark/16x16/status")
(dark / "index.theme").write_text(index("Yaru-blue-dark", "Yaru-blue,Yaru-dark,hicolor", "48x48/places,16x16/status"))
PY

source_folder="$source_icons/Yaru-blue/48x48/places/folder.png"
source_checksum=$(cksum "$source_folder")

mkdir -p "$dest_icons/Yaru-grey" "$dest_icons/Yaru-gray"
echo keep >"$dest_icons/Yaru-grey/marker"
echo keep >"$dest_icons/Yaru-gray/marker"
if run_installer "$work/missing" "$dest_icons" 2>"$work/missing.err"; then
  fail "a missing Yaru accent fails the install"
fi
grep -q "missing $work/missing/Yaru-blue" "$work/missing.err" || fail "a missing Yaru accent is reported"
[[ $(<"$dest_icons/Yaru-grey/marker") == "keep" ]] || fail "a failed install leaves the previous icon theme in place"
pass "a missing Yaru accent fails without replacing an installed theme"

(cd "$work" && run_installer ./source "$dest_icons")
[[ ! -e $dest_icons/Yaru-grey/marker && ! -e $dest_icons/Yaru-gray/marker ]] || fail "a successful install replaces the previous icon theme"
[[ $(cksum "$source_folder") == "$source_checksum" ]] || fail "building the grey theme leaves the installed Yaru icons unchanged"
pass "the monochrome themes install from the Yaru accents"

python3 - "$source_icons" "$dest_icons" <<'PY'
import pathlib, struct, sys, zlib

source = pathlib.Path(sys.argv[1])
dest = pathlib.Path(sys.argv[2])

def paeth(left, up, upper_left):
    estimate = left + up - upper_left
    distances = (abs(estimate - left), abs(estimate - up), abs(estimate - upper_left))
    if distances[0] <= distances[1] and distances[0] <= distances[2]:
        return left
    if distances[1] <= distances[2]:
        return up
    return upper_left

def read_png(path):
    data = path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", path
    pos = 8
    ihdr = None
    idat = b""
    while pos + 8 <= len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        kind = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + length]
        pos += 12 + length
        if kind == b"IHDR":
            ihdr = struct.unpack(">IIBBBBB", body)
        elif kind == b"IDAT":
            idat += body
        elif kind == b"IEND":
            break
    width, height, depth, color_type, compression, png_filter, interlace = ihdr
    assert (depth, color_type, compression, png_filter, interlace) == (8, 6, 0, 0, 0), path
    raw = zlib.decompress(idat)
    stride = width * 4
    rows = []
    previous = bytearray(stride)
    index = 0
    for _ in range(height):
        filter_type = raw[index]
        index += 1
        row = bytearray(raw[index:index + stride])
        index += stride
        for column in range(stride):
            left = row[column - 4] if column >= 4 else 0
            up = previous[column]
            upper_left = previous[column - 4] if column >= 4 else 0
            if filter_type == 1:
                row[column] = (row[column] + left) & 255
            elif filter_type == 2:
                row[column] = (row[column] + up) & 255
            elif filter_type == 3:
                row[column] = (row[column] + ((left + up) >> 1)) & 255
            elif filter_type == 4:
                row[column] = (row[column] + paeth(left, up, upper_left)) & 255
            elif filter_type != 0:
                raise SystemExit(f"filter {filter_type}")
        rows.append(row)
        previous = row
    return [tuple(row[4 * column:4 * column + 4]) for row in rows for column in range(width)]

def field(text, key):
    for line in text.splitlines():
        name, sep, value = line.strip().partition("=")
        if sep and name.strip() == key:
            return value.strip()
    raise SystemExit(f"missing {key}")

def assert_theme(theme, inherits, pixel, svg_fill):
    index_path = theme / "index.theme"
    assert index_path.is_file(), theme
    text = index_path.read_text()
    assert field(text, "Name") == theme.name, text
    assert field(text, "Inherits") == inherits, text
    for directory in field(text, "Directories").split(","):
        path = theme / directory
        assert path.is_dir(), path
    folder = read_png(theme / "48x48" / "places" / "folder.png")
    assert folder[0] == pixel, folder[0]
    assert folder[1][3] == 128 and folder[1][0] == folder[1][1] == folder[1][2], folder[1]
    svg = (theme / "scalable" / "devices" / "audio.svg").read_text()
    assert f'fill="{svg_fill}"' in svg, svg
    assert "url(#keep)" in svg, svg
    assert 'bordercolor="#666666"' in svg, svg
    for inherited in inherits.split(","):
        if inherited == "hicolor":
            continue
        assert ((dest / inherited) / "index.theme").is_file() or ((source / inherited) / "index.theme").is_file(), inherited

assert_theme(dest / "Yaru-grey", "Yaru,hicolor", (130, 130, 130, 255), "#828282")
assert_theme(dest / "Yaru-gray", "Yaru-grey,Yaru-dark,hicolor", (113, 113, 113, 255), "#717171")

grey_svg = (dest / "Yaru-grey" / "scalable" / "devices" / "audio.svg").read_text()
for snippet in ('stroke="#989898"', "stop-color:#979797", "rgb(130,130,130)", "rgba(152,152,152,0.5)"):
    assert snippet in grey_svg, snippet

link = dest / "Yaru-grey" / "48x48" / "places" / "inode-directory.png"
assert link.is_symlink() and link.readlink() == pathlib.Path("folder.png")
assert read_png(link)[0] == (130, 130, 130, 255)
absolute_link = link.with_name("absolute-folder.png")
assert absolute_link.readlink() == pathlib.Path("folder.png"), absolute_link.readlink()
assert read_png(absolute_link)[0] == (130, 130, 130, 255)
absolute_dir = dest / "Yaru-gray/scalable/absolute-devices"
assert absolute_dir.readlink() == pathlib.Path("devices"), absolute_dir.readlink()
assert 'fill="#717171"' in (absolute_dir / "audio.svg").read_text()

status = dest / "Yaru-gray" / "16x16" / "status"
assert status.is_symlink()
assert status.resolve() == (source / "Yaru-dark" / "16x16" / "status").resolve()
assert read_png(status / "dialog-error.png")[0] == (255, 0, 0, 255)
assert not (dest / "Yaru-grey" / "icon-theme.cache").exists() or (dest / "Yaru-grey" / "icon-theme.cache").read_text(errors="ignore") != "stale"
PY
pass "Yaru-grey and Yaru-gray resolve and the accent icons are monochrome"

run_installer "$source_icons" "$dest_icons"
python3 - "$dest_icons/Yaru-grey/48x48/places/folder.png" <<'PY'
import pathlib, struct, sys, zlib
data = pathlib.Path(sys.argv[1]).read_bytes()
pos = 8
ihdr = None
idat = b""
while pos + 8 <= len(data):
    length = struct.unpack(">I", data[pos:pos + 4])[0]
    kind = data[pos + 4:pos + 8]
    body = data[pos + 8:pos + 8 + length]
    pos += 12 + length
    if kind == b"IHDR":
        ihdr = body
    elif kind == b"IDAT":
        idat += body
    elif kind == b"IEND":
        break
assert ihdr is not None and zlib.decompress(idat)
PY
pass "installing the monochrome icon themes again replaces them cleanly"

# Inject filesystem failures, while forwarding only known fixture operations.
# Nothing in this PATH can run a host icon-cache update or another installer.
rm "$work/bin/cp" "$work/bin/mv"
cat >"$work/bin/file-operation" <<'PYTHON'
#!/usr/bin/python3
import os
import pathlib
import sys

operation = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
root = pathlib.Path(os.environ["ICON_FIXTURE"])
if operation == "cp":
    assert len(args) == 3 and args[0] == "-a", args
elif operation == "mv":
    assert len(args) == 4 and args[:2] == ["-T", "--"], args
else:
    raise SystemExit(99)
source, dest = map(pathlib.Path, args[-2:])
assert source.is_relative_to(root) and dest.is_relative_to(root), args
mode = os.environ["FAIL_OPERATION"]
if operation == "cp":
    # A replacement must be fully built beside the final paths before either
    # old tree is disturbed, even when TMPDIR is elsewhere.
    assert dest.parent.parent == root / "dest", dest
    assert (root / "dest/Yaru-grey/marker").read_text() == "keep\n"
    assert (root / "dest/Yaru-gray/marker").read_text() == "keep\n"
    fail = mode == "stage" and source.name == "Yaru-blue-dark"
    if fail:
        dest.mkdir()
        (dest / "partial").write_text("incomplete copy")
else:
    backup = dest.name == "old-Yaru-gray"
    publish = dest == root / "dest/Yaru-gray" and source.name == "Yaru-gray"
    restore = source.name == "old-Yaru-grey"
    fail = (
        (mode == "backup" and backup)
        or (mode in ("publish", "recovery") and publish)
        or (mode == "recovery" and restore)
    )
if fail:
    print(f"injected {mode} failure", file=sys.stderr)
    raise SystemExit(1)
os.execv("/usr/bin/" + operation, [operation, *args])
PYTHON
chmod +x "$work/bin/file-operation"
ln -s file-operation "$work/bin/cp"
ln -s file-operation "$work/bin/mv"

for operation in stage backup publish; do
  echo keep >"$dest_icons/Yaru-grey/marker"
  echo keep >"$dest_icons/Yaru-gray/marker"
  if FAIL_OPERATION=$operation run_installer "$source_icons" "$dest_icons" 2>"$work/failure.err"; then
    fail "a failed $operation is reported"
  fi
  grep -q "injected $operation failure" "$work/failure.err" || fail "the intended $operation operation failed" "$(<"$work/failure.err")"
  [[ $(<"$dest_icons/Yaru-grey/marker") == "keep" && $(<"$dest_icons/Yaru-gray/marker") == "keep" ]] || fail "a failed $operation preserves both installed themes"
  for leftover in "$dest_icons"/.omarchy-yaru-grey.*; do
    [[ ! -e $leftover ]] || fail "a failed $operation cleans up its staging directory"
  done
  pass "a failed $operation preserves both installed themes"
done

run_installer "$source_icons" "$dest_icons"
[[ ! -e $dest_icons/Yaru-grey/marker && ! -e $dest_icons/Yaru-gray/marker ]] || fail "both staged themes are published together"
pass "both replacements are built beside the old pair before successful publication"
echo keep >"$dest_icons/Yaru-grey/marker"
echo keep >"$dest_icons/Yaru-gray/marker"

if FAIL_OPERATION=recovery run_installer "$source_icons" "$dest_icons" 2>"$work/recovery.err"; then
  fail "failed rollback is reported"
fi
recovery=$(<"$work/recovery.err")
recovery=${recovery##*recovery files retained in }
[[ -d $recovery && $(<"$recovery/old-Yaru-grey/marker") == "keep" ]] || fail "failed rollback retains the old theme at the reported recovery path"
[[ $(<"$dest_icons/Yaru-gray/marker") == "keep" ]] || fail "rollback still restores the other theme"
pass "failed rollback keeps useful recovery files and reports their location"
