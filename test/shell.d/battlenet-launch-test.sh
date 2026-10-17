#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
home="$test_tmp/home"
stub_bin="$test_tmp/bin"
mkdir -p "$home/Games/battlenet/drive_c/Program Files (x86)/Battle.net" "$stub_bin"
: >"$home/Games/battlenet/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"

cat >"$stub_bin/umu-run" <<'SH'
#!/bin/bash
printf 'umu\n' >>"$OMARCHY_BATTLENET_LOG"
SH
chmod +x "$stub_bin/umu-run"

cat >"$stub_bin/pgrep" <<'SH'
#!/bin/bash
if [[ -f $OMARCHY_BATTLENET_RUNNING ]]; then
  exit 0
fi
exit 1
SH
chmod +x "$stub_bin/pgrep"

# No Hyprland clients in the test environment.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
echo '[]'
SH
chmod +x "$stub_bin/hyprctl"
cat >"$stub_bin/jq" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin/jq"

log="$test_tmp/log"
running="$test_tmp/running"
: >"$log"

HOME="$home" PATH="$stub_bin:$ROOT/bin:$PATH" OMARCHY_BATTLENET_LOG="$log" \
  OMARCHY_BATTLENET_RUNNING="$running" omarchy-launch-battlenet
grep -q '^umu$' "$log" || fail "first launch runs umu" "$(cat "$log")"
pass "first Battle.net launch starts umu"

: >"$running"
: >"$log"
HOME="$home" PATH="$stub_bin:$ROOT/bin:$PATH" OMARCHY_BATTLENET_LOG="$log" \
  OMARCHY_BATTLENET_RUNNING="$running" omarchy-launch-battlenet
[[ ! -s $log ]] || fail "second launch does not start another umu" "$(cat "$log")"
pass "second Battle.net launch is a no-op when already running"
