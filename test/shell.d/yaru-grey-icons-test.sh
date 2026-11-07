#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

# Names yaru-icon-theme ships, plus the two monochrome accents this repo installs.
# A stock icons.theme outside this set is the missing-theme failure: GTK cannot
# resolve any icon from a directory that is not there.
allowed="Yaru Yaru-dark"
for accent in blue magenta olive prussiangreen purple red sage wartybrown yellow; do
  allowed+=" Yaru-$accent Yaru-$accent-dark"
done
allowed+=" Yaru-grey Yaru-gray"

for icons in "$ROOT"/themes/*/icons.theme; do
  name=$(tr -d '[:space:]' <"$icons")
  if [[ " $allowed " != *" $name "* ]]; then
    fail "stock icon theme is one Omarchy installs" "$icons names $name"
  fi
done
pass "every stock icons.theme names an icon theme Omarchy installs"

[[ $(tr -d '[:space:]' <"$ROOT/themes/white/icons.theme") == "Yaru-grey" ]] || fail "White names Yaru-grey"
[[ $(tr -d '[:space:]' <"$ROOT/themes/vantablack/icons.theme") == "Yaru-gray" ]] || fail "Vantablack names Yaru-gray"
pass "White and Vantablack keep the monochrome icon theme names"

grep -q 'omarchy-theme-install-yaru-grey' "$ROOT/install/user/yaru-grey-icons.sh" || fail "user setup installs the monochrome icon themes"
grep -q 'run_logged "\$OMARCHY_INSTALL/user/yaru-grey-icons.sh"' "$ROOT/install/user/all.sh" || fail "user setup runs the monochrome icon install"
grep -q 'omarchy-theme-install-yaru-grey' "$ROOT/migrations/1794058300.sh" || fail "the migration installs the monochrome icon themes"
pass "install and migration publish the monochrome icon themes"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
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
(blue_theme / "scalable" / "devices").mkdir(parents=True)
(blue_theme / "scalable" / "devices" / "audio.svg").write_text(svg)
(blue_theme / "index.theme").write_text(index("Yaru-blue", "Yaru,hicolor", "48x48/places,scalable/devices"))
(blue_theme / "icon-theme.cache").write_text("stale")

dark = root / "Yaru-blue-dark"
write_png(dark / "48x48" / "places" / "folder.png", folder, filtered=True)
(dark / "scalable" / "devices").mkdir(parents=True)
(dark / "scalable" / "devices" / "audio.svg").write_text(svg)
(dark / "16x16").mkdir()
(dark / "16x16" / "status").symlink_to("../../Yaru-dark/16x16/status")
(dark / "index.theme").write_text(index("Yaru-blue-dark", "Yaru-blue,Yaru-dark,hicolor", "48x48/places,16x16/status"))
PY

source_folder="$source_icons/Yaru-blue/48x48/places/folder.png"
source_checksum=$(cksum "$source_folder")

mkdir -p "$dest_icons/Yaru-grey"
echo keep >"$dest_icons/Yaru-grey/marker"
if "$ROOT/bin/omarchy-theme-install-yaru-grey" "$work/missing" "$dest_icons" 2>"$work/missing.err"; then
  fail "a missing Yaru accent fails the install"
fi
grep -q "missing $work/missing/Yaru-blue" "$work/missing.err" || fail "a missing Yaru accent is reported"
[[ $(<"$dest_icons/Yaru-grey/marker") == "keep" ]] || fail "a failed install leaves the previous icon theme in place"
pass "a missing Yaru accent fails without replacing an installed theme"

"$ROOT/bin/omarchy-theme-install-yaru-grey" "$source_icons" "$dest_icons"
[[ ! -e $dest_icons/Yaru-grey/marker ]] || fail "a successful install replaces the previous icon theme"
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

status = dest / "Yaru-gray" / "16x16" / "status"
assert status.is_symlink()
assert status.resolve() == (source / "Yaru-dark" / "16x16" / "status").resolve()
assert read_png(status / "dialog-error.png")[0] == (255, 0, 0, 255)
assert not (dest / "Yaru-grey" / "icon-theme.cache").exists() or (dest / "Yaru-grey" / "icon-theme.cache").read_text(errors="ignore") != "stale"
PY
pass "Yaru-grey and Yaru-gray resolve and the accent icons are monochrome"

"$ROOT/bin/omarchy-theme-install-yaru-grey" "$source_icons" "$dest_icons"
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

migration_home="$work/home"
migration_bin="$work/bin"
migration_log="$work/migration.log"
mkdir -p "$migration_bin" "$migration_home"
cat >"$migration_bin/omarchy-theme-install-yaru-grey" <<'EOF'
#!/bin/bash
printf 'install\n' >>"${MIGRATION_LOG:?}"
EOF
chmod +x "$migration_bin/omarchy-theme-install-yaru-grey"
HOME="$migration_home" PATH="$migration_bin:$PATH" MIGRATION_LOG="$migration_log" \
  bash -euo pipefail "$ROOT/migrations/1794058300.sh" >/dev/null
HOME="$migration_home" PATH="$migration_bin:$PATH" MIGRATION_LOG="$migration_log" \
  bash -euo pipefail "$ROOT/migrations/1794058300.sh" >/dev/null
[[ $(grep -c '^install$' "$migration_log") == "2" ]] || fail "the migration installs the icon themes each time it runs"
pass "the migration installs the monochrome icon themes"

cat >"$migration_bin/omarchy-theme-install-yaru-grey" <<'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "$migration_bin/omarchy-theme-install-yaru-grey"
if HOME="$migration_home" PATH="$migration_bin:$PATH" bash -euo pipefail "$ROOT/migrations/1794058300.sh" >/dev/null; then
  fail "the migration stays pending when the icon themes cannot be installed"
fi
pass "the migration stays pending when the icon themes cannot be installed"
