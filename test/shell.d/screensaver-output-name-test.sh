#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmpdir=$(mktemp -d)
# The screensaver backgrounds a watcher that can still be writing as the test
# ends, so tolerate a losing race against it.
trap 'rm -rf "$tmpdir" 2>/dev/null || true' EXIT

stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
monitors_json="$tmpdir/monitors.json"
dispatch_log="$tmpdir/dispatch.log"
mkdir -p "$stub_dir" "$home_dir" "$tmpdir/run"

make_stub() {
  local name=$1
  local body=$2
  printf '#!/bin/bash\n%s\n' "$body" >"$stub_dir/$name"
  chmod +x "$stub_dir/$name"
}

make_stub pgrep 'exit 1'
make_stub omarchy-toggle-enabled 'exit 1'
make_stub omarchy-cmd-missing 'exit 1'
make_stub omarchy-notification-send ':'
make_stub omarchy-hyprland-monitor-focused 'printf "%s\n" "eDP-1"'
make_stub xdg-terminal-exec 'printf "%s\n" "Alacritty"'
make_stub socat 'sleep 1'
make_stub hyprctl 'case "$1" in
  monitors) cat "$MONITORS_JSON" ;;
  clients) printf "%s\n" "[]" ;;
  dispatch) printf "%s\n" "$2" >>"$DISPATCH_LOG" ;;
esac'

run_screensaver() {
  : >"$dispatch_log"
  HOME="$home_dir" \
    OMARCHY_PATH="$ROOT" \
    MONITORS_JSON="$monitors_json" \
    DISPATCH_LOG="$dispatch_log" \
    XDG_RUNTIME_DIR="$tmpdir/run" \
    HYPRLAND_INSTANCE_SIGNATURE=test \
    PATH="$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-launch-screensaver" force
}

printf '[{"name":"eDP-1","specialWorkspace":{"name":""}}]\n' >"$monitors_json"
run_screensaver
grep -F 'hl.dsp.focus({ monitor = "eDP-1" })' "$dispatch_log" >/dev/null ||
  fail "screensaver accepts a plain connector name"
pass "screensaver accepts a plain connector name"

# Hyprland accepts a headless output whose name carries Lua metacharacters, and
# hyprctl hands the name back verbatim, so it reaches the dispatch string as-is.
printf '[{"name":"eDP-1\\" })os.execute(\\"calc\\")--","specialWorkspace":{"name":""}}]\n' >"$monitors_json"
run_screensaver
if grep -F 'os.execute' "$dispatch_log" >/dev/null; then
  fail "an unsafe monitor name is not written as Lua"
fi
pass "screensaver refuses an unsafe monitor name"

printf '[{"name":"eDP-1","specialWorkspace":{"name":"special:x\\"]]),os.execute(\\"calc\\")--"}}]\n' >"$monitors_json"
run_screensaver
if grep -F 'os.execute' "$dispatch_log" >/dev/null; then
  fail "an unsafe special workspace name is not written as Lua"
fi
pass "screensaver refuses an unsafe special workspace name"
