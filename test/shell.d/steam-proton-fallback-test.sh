#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

steam="$scratch/Steam"
mkdir -p "$steam/config" "$steam/appcache" "$steam/steamapps/common" "$scratch/bin"
printf '#!/bin/bash\n' >"$scratch/bin/omarchy-notification-send"
chmod +x "$scratch/bin/omarchy-notification-send"

# 100: a Linux entry whose launcher was never installed, Windows build present.
# 200: a Linux entry only on a beta branch, as PEAK ships it.
# 300: a native game with its Linux launcher installed.
python3 -I - "$steam" <<'EOF'
import struct, sys
from pathlib import Path

steam = Path(sys.argv[1])
strings = []

def key(name):
    if name not in strings:
        strings.append(name)
    return struct.pack("<I", strings.index(name))

def kv(node):
    out = b""
    for name, value in node.items():
        if isinstance(value, dict):
            out += b"\x00" + key(name) + kv(value)
        else:
            out += b"\x01" + key(name) + value.encode() + b"\0"
    return out + b"\x08"

def entry(executable, oslist, beta=None):
    config = {"oslist": oslist}
    if beta:
        config["BetaKey"] = beta
    return {"executable": executable, "config": config}

apps = {
    100: [entry("Game.exe", "windows"), entry("Game.sh", "linux")],
    200: [entry("Peak.exe", "windows"), entry("Peak.exe", "linux", beta="internal")],
    300: [entry("run.sh", "linux")],
}
files = {100: ["Game.exe"], 200: ["Peak.exe"], 300: ["run.sh"]}

body = b""
for appid, launch in apps.items():
    info = kv({"appinfo": {"config": {"launch": {str(i): e for i, e in enumerate(launch)}}}})
    header = struct.pack("<IIQ", 0, 0, 0) + b"\0" * 20 + struct.pack("<I", 0) + b"\0" * 20
    body += struct.pack("<II", appid, len(header) + len(info)) + header + info
    game = steam / "steamapps/common" / f"game{appid}"
    game.mkdir(parents=True)
    for name in files[appid]:
        (game / name).touch()
    (steam / f"steamapps/appmanifest_{appid}.acf").write_text(
        f'"AppState"\n{{\n\t"appid"\t\t"{appid}"\n\t"name"\t\t"Game {appid}"\n\t"installdir"\t\t"game{appid}"\n}}\n')
body += struct.pack("<I", 0)

table = struct.pack("<I", len(strings)) + b"".join(s.encode() + b"\0" for s in strings)
(steam / "appcache/appinfo.vdf").write_bytes(struct.pack("<IIq", 0x07564429, 1, 16 + len(body)) + body + table)
(steam / "config/config.vdf").write_text(
    '"InstallConfigStore"\n{\n\t"Software"\n\t{\n\t\t"Valve"\n\t\t{\n\t\t\t"Steam"\n\t\t\t{\n'
    '\t\t\t\t"AutoUpdateWindowEnabled"\t\t"0"\n\t\t\t}\n\t\t}\n\t}\n}\n')
EOF

scan() {
  PATH="$scratch/bin:$PATH" OMARCHY_STEAM_ROOT="$steam" OMARCHY_STEAM_PID_FILE="$scratch/none.pid" \
    "$ROOT/bin/omarchy-steam-proton-fallback" scan
}

found=$(scan)
[[ $found == $'100\tGame 100' ]] || fail "scan flags only the game whose Linux launcher is missing" "$found"
grep -Pzq '"CompatToolMapping"\n\t+\{\n\t+"100"\n\t+\{\n\t+"name"\t\t"proton_experimental"' "$steam/config/config.vdf" ||
  fail "scan maps that game to Proton in config.vdf" "$(cat "$steam/config/config.vdf")"
pass "scan maps a game with a missing Linux launcher to Proton and leaves beta-only and native entries alone"

[[ -z $(scan) ]] || fail "a second scan finds nothing left to map"
(( $(grep -c '"CompatToolMapping"' "$steam/config/config.vdf") == 1 )) || fail "a second scan adds no second mapping block"
pass "scan is idempotent"
