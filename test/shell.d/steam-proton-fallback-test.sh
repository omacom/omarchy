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
# config.vdf has the empty mapping block Steam leaves when the last mapping is
# turned off, and another section that lists 100.
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

# Steam counts 100 as a Linux title through the icon a dropped port left
# behind; 400 has the same launch entries without it, so Steam runs it with
# Proton itself (Satisfactory) and nothing needs mapping.
common = {100: {"oslist": "windows", "linuxclienticon": "abc"}, 200: {"oslist": "windows"}, 300: {"oslist": "linux"}, 400: {"oslist": "windows"}}
apps = {
    100: [entry("Game.exe", "windows"), entry("Game.sh", "linux")],
    400: [entry("Other.exe", "windows"), entry("Other.sh", "linux")],
    200: [entry("Peak.exe", "windows"), entry("Peak.exe", "linux", beta="internal")],
    300: [entry("run.sh", "linux")],
}
files = {100: ["Game.exe"], 200: ["Peak.exe"], 300: ["run.sh"], 400: ["Other.exe"]}

body = b""
for appid, launch in apps.items():
    info = kv({"appinfo": {"common": common[appid], "config": {"launch": {str(i): e for i, e in enumerate(launch)}}}})
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
    '\t\t\t\t"CompatToolMapping"\n\t\t\t\t{\n\t\t\t\t}\n'
    '\t\t\t\t"depots"\n\t\t\t\t{\n\t\t\t\t\t"100"\n\t\t\t\t\t{\n\t\t\t\t\t\t"DecryptionKey"\t\t"00"\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n\t\t}\n\t}\n}\n')
EOF

scan() {
  PATH="$scratch/bin:$PATH" OMARCHY_STEAM_ROOT="$steam" OMARCHY_STEAM_PID_FILE="$scratch/none.pid" \
    "$ROOT/bin/omarchy-steam-proton-fallback" scan
}

found=$(scan)
[[ $found == $'100\tGame 100' ]] || fail "scan flags only the game whose Linux launcher is missing" "$found"
grep -Pzq '"CompatToolMapping"\n\t+\{\n\t+"100"\n\t+\{\n\t+"name"\t\t"proton_experimental"' "$steam/config/config.vdf" ||
  fail "scan maps that game to Proton in config.vdf" "$(cat "$steam/config/config.vdf")"
pass "scan maps a game Steam starts natively whose Linux launcher is missing, and leaves Proton-run, beta-only and native games alone"

[[ -z $(scan) ]] || fail "a second scan finds nothing left to map"
(( $(grep -c '"CompatToolMapping"' "$steam/config/config.vdf") == 1 )) || fail "a second scan adds no second mapping block"
pass "scan is idempotent"

# The watcher: two failed launches arrive in one write while Steam runs. Only
# the game with a Windows build to fall back on is mapped and relaunched; the
# native game whose launcher is missing (300 with run.sh removed) is left be.
rm "$steam/steamapps/common/game300/run.sh"
python3 -I - "$steam/config/config.vdf" <<'EOF2'
import re, sys
path = sys.argv[1]
text = open(path).read()
open(path, "w").write(re.sub(r'\t+"100"\n\t+\{\n\t+"name"\t\t"proton_experimental"\n(?:\t+"[^"]+"\t\t"[^"]*"\n)*\t+\}\n', "", text, count=1))
EOF2
sleep 300 &
fake_steam=$!
echo "$fake_steam" >"$scratch/steam.pid"
printf '#!/bin/bash\nif [[ $1 == "-shutdown" ]]; then kill %s; else echo "$*" >>%q; fi\n' "$fake_steam" "$scratch/launched" >"$scratch/bin/steam"
printf '#!/bin/bash\necho "$*" >>%q\n' "$scratch/relaunched" >"$scratch/bin/uwsm-app"
printf '#!/bin/bash\n' >"$scratch/bin/pgrep"
chmod +x "$scratch/bin/steam" "$scratch/bin/uwsm-app" "$scratch/bin/pgrep"
mkdir -p "$steam/logs"
: >"$steam/logs/console_log.txt"
: >"$steam/logs/content_log.txt"

PATH="$scratch/bin:$PATH" OMARCHY_STEAM_ROOT="$steam" OMARCHY_STEAM_PID_FILE="$scratch/steam.pid" \
  "$ROOT/bin/omarchy-steam-proton-fallback" watch &
watcher=$!
trap 'kill "$watcher" "$fake_steam" 2>/dev/null; rm -rf "$scratch"' EXIT
sleep 1
printf '%s\n%s\n' \
  "[2026-11-27 17:00:00] GameAction [AppID 300, ActionID 1] : LaunchApp failed with AppError_28 with \"$steam/steamapps/common/game300/run.sh\"" \
  "[2026-11-27 17:00:00] GameAction [AppID 100, ActionID 2] : LaunchApp failed with AppError_28 with \"$steam/steamapps/common/game100/Game.sh\"" \
  >>"$steam/logs/console_log.txt"

for _ in {1..50}; do
  [[ -s $scratch/relaunched ]] && break
  sleep 0.2
done
[[ $(cat "$scratch/relaunched" 2>/dev/null) == "-- steam steam://rungameid/100" ]] ||
  fail "a failed launch of a Windows-backed game restarts Steam and relaunches it" "$(cat "$scratch/relaunched" 2>/dev/null)"
grep -Pzq '"CompatToolMapping"\n\t+\{\n\t+"100"\n' "$steam/config/config.vdf" || fail "the relaunched game is mapped to Proton"
grep -q '"300"' "$steam/config/config.vdf" && fail "a native game with a missing launcher is not mapped to Proton"
pass "the watcher recovers a failed launch read in the same chunk as another, and only for a game Proton can run"

# Switching to Proton can make Steam fetch the game again, and it drops the
# relaunch that waited on that update: launch it once more when it finishes.
echo "[2026-11-27 17:00:30] AppID 100 scheduler finished : removed from schedule (result No Error, state 0xc)" >>"$steam/logs/content_log.txt"
for _ in {1..50}; do
  [[ -s $scratch/launched ]] && break
  sleep 0.2
done
[[ $(cat "$scratch/launched" 2>/dev/null) == "steam://rungameid/100" ]] ||
  fail "the game is launched again once Steam's update after the switch finishes" "$(cat "$scratch/launched" 2>/dev/null)"
pass "the watcher relaunches a recovered game after Steam's update for the switch finishes"
