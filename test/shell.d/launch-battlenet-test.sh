#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
wineserver_pid=""
trap '[[ -n $wineserver_pid ]] && kill "$wineserver_pid" 2>/dev/null; rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/home"
export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"
export HOME="$tmp_dir/home"

prefix="$HOME/Games/battlenet"
mkdir -p "$prefix/drive_c/Program Files (x86)/Battle.net"
touch "$prefix/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
# umu points WINEPREFIX at pfx/, a link back to the prefix itself.
ln -s . "$prefix/pfx"

# Wine's default 96 DPI, under both keys a prefix carries it in.
write_registry() {
  cat >"$prefix/user.reg" <<'REG'
[Control Panel\\Desktop] 1793676771
#time=1dd5ff435e0edbe
"LogPixels"=dword:00000060
"MenuShowDelay"="400"

[Software\\Wine\\Fonts] 1793677064
"LogPixels"=dword:00000060
REG
}

# A fresh prefix only has the Fonts copy, which Wine writes but never reads.
write_fresh_registry() {
  cat >"$prefix/user.reg" <<'REG'
[Control Panel\\Desktop] 1793676771
#time=1dd5ff435e0edbe
"MenuShowDelay"="400"

[Software\\Wine\\Fonts] 1793677064
"LogPixels"=dword:00000060
REG
}

cat >"$tmp_dir/bin/hyprctl" <<SCRIPT
#!/bin/bash
printf '[{"name":"DP-1","focused":false,"scale":1},{"name":"HDMI-A-1","focused":true,"scale":%s}]\n' "\$(cat "$tmp_dir/scale")"
SCRIPT
cat >"$tmp_dir/bin/umu-run" <<'SCRIPT'
#!/bin/bash
printf 'umu-run:%s\n' "$*" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/bin/hyprctl" "$tmp_dir/bin/umu-run"

# A fractional scale rounds to the nearest DPI: 1.6 x 96 = 153.6, so 154.
write_registry
echo 1.6 >"$tmp_dir/scale"
"$ROOT/bin/omarchy-launch-battlenet"

[[ $(grep -c '^"LogPixels"=dword:0000009a$' "$prefix/user.reg") == "2" ]] ||
  fail "Battle.net launch matches the DPI to the focused monitor's scale" "$(cat "$prefix/user.reg")"
grep -q '^"MenuShowDelay"="400"$' "$prefix/user.reg" ||
  fail "Battle.net launch matches the DPI to the focused monitor's scale" "other registry values changed"
grep -q '^umu-run:.*Battle.net Launcher.exe$' "$TEST_LOG" ||
  fail "Battle.net launch matches the DPI to the focused monitor's scale" "launcher never started"
pass "Battle.net launch matches the DPI to the focused monitor's scale"

# A fresh prefix has no DPI under [Control Panel\\Desktop] yet, so the launch
# adds one after the key's #time line.
write_fresh_registry
echo 2 >"$tmp_dir/scale"
"$ROOT/bin/omarchy-launch-battlenet"

[[ $(sed -n '2,4p' "$prefix/user.reg") == $'#time=1dd5ff435e0edbe\n"LogPixels"=dword:000000c0\n"MenuShowDelay"="400"' ]] ||
  fail "Battle.net launch adds the DPI to a fresh prefix" "$(cat "$prefix/user.reg")"
[[ $(grep -c '^"LogPixels"=dword:000000c0$' "$prefix/user.reg") == "2" ]] ||
  fail "Battle.net launch adds the DPI to a fresh prefix" "$(cat "$prefix/user.reg")"
pass "Battle.net launch adds the DPI to a fresh prefix"

# While the prefix's wineserver runs, the registry is its to write back on
# exit, so the launch leaves it alone and still hands off to the launcher.
ln -s "$(command -v sleep)" "$tmp_dir/wineserver"
WINEPREFIX="$prefix/pfx/" "$tmp_dir/wineserver" 60 >/dev/null 2>&1 &
wineserver_pid=$!
write_registry
echo 2 >"$tmp_dir/scale"
: >"$TEST_LOG"
"$ROOT/bin/omarchy-launch-battlenet"

[[ $(grep -c '^"LogPixels"=dword:00000060$' "$prefix/user.reg") == "2" ]] ||
  fail "Battle.net launch leaves a running prefix's DPI alone" "$(cat "$prefix/user.reg")"
grep -q '^umu-run:.*Battle.net Launcher.exe$' "$TEST_LOG" ||
  fail "Battle.net launch leaves a running prefix's DPI alone" "launcher never started"
pass "Battle.net launch leaves a running prefix's DPI alone"
