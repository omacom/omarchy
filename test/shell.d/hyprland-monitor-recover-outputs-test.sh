#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
drm="$test_tmp/drm"
runtime_dir="$test_tmp/runtime"
call_log="$test_tmp/calls"
mkdir -p "$mock_bin" "$drm" "$runtime_dir"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]]; then
  cat "$HYPR_MONITORS_JSON"
  exit 0
fi
if [[ $1 == "dispatch" ]]; then
  printf '%s\n' "$*" >>"$CALL_LOG"
  exit 0
fi
exit 1
SH
chmod +x "$mock_bin/hyprctl"

cat >"$mock_bin/logger" <<'SH'
#!/bin/bash
printf 'logger %s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$mock_bin/logger"

write_connector() {
  local dir="$drm/$1"
  mkdir -p "$dir"
  printf '%s\n' "$2" >"$dir/status"
  printf '%s\n' "$3" >"$dir/enabled"
  printf '%s\n' "$4" >"$dir/dpms"
}

write_monitors_json() {
  cat >"$test_tmp/monitors.json"
}

run_recover() {
  CALL_LOG="$call_log" \
    HYPR_MONITORS_JSON="$test_tmp/monitors.json" \
    OMARCHY_DRM_PATH="$drm" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$mock_bin:$PATH" \
    "$ROOT/bin/omarchy-hyprland-monitor-recover-outputs" "$@"
}

write_monitors_json <<'JSON'
[
  {"name":"DP-1","disabled":false,"dpmsStatus":true},
  {"name":"HDMI-A-1","disabled":false,"dpmsStatus":true},
  {"name":"eDP-2","disabled":false,"dpmsStatus":true}
]
JSON

write_connector card1-DP-1 connected enabled On
write_connector card1-HDMI-A-1 connected disabled Off
write_connector card2-eDP-2 connected enabled On

stuck=$(run_recover --print)
[[ $stuck == "HDMI-A-1" ]] || fail "kernel-off HDMI is reported stuck" "actual: $stuck"
pass "kernel-off HDMI is reported stuck"

write_connector card1-HDMI-A-1 connected enabled On
stuck=$(run_recover --print)
[[ -z $stuck ]] || fail "kernel-on HDMI is not stuck" "actual: $stuck"
pass "kernel-on HDMI is not stuck"

write_connector card1-HDMI-A-1 connected disabled Off
write_monitors_json <<'JSON'
[
  {"name":"HDMI-A-1","disabled":false,"dpmsStatus":false}
]
JSON
stuck=$(run_recover --print)
[[ -z $stuck ]] || fail "lock-screen DPMS-off is not recovered" "actual: $stuck"
pass "lock-screen DPMS-off is not recovered"

write_monitors_json <<'JSON'
[
  {"name":"HDMI-A-1","disabled":true,"dpmsStatus":true}
]
JSON
stuck=$(run_recover --print)
[[ -z $stuck ]] || fail "hypr-disabled HDMI is not recovered" "actual: $stuck"
pass "hypr-disabled HDMI is not recovered"

write_monitors_json <<'JSON'
[
  {"name":"HDMI-A-1; rm -rf /","disabled":false,"dpmsStatus":true}
]
JSON
stuck=$(run_recover --print)
[[ -z $stuck ]] || fail "unsafe monitor names are ignored" "actual: $stuck"
pass "unsafe monitor names are ignored"

write_monitors_json <<'JSON'
[
  {"name":"HDMI-A-1","disabled":false,"dpmsStatus":true}
]
JSON
: >"$call_log"
run_recover
grep -F 'dispatch hl.dsp.dpms({ action = "off", monitor = "HDMI-A-1" })' "$call_log" >/dev/null || \
  fail "stuck HDMI is DPMS-cycled off first"
grep -F 'dispatch hl.dsp.dpms({ action = "on", monitor = "HDMI-A-1" })' "$call_log" >/dev/null || \
  fail "stuck HDMI is DPMS-cycled on"
pass "stuck HDMI is DPMS-cycled off then on"

: >"$call_log"
run_recover
if grep -F 'dispatch' "$call_log" >/dev/null; then
  fail "cooldown skips a second cycle"
fi
pass "cooldown skips a second cycle"

rg -n 'omarchy-hyprland-monitor-recover-outputs' "$ROOT/bin/omarchy-hyprland-monitor-clamshell" >/dev/null || \
  fail "clamshell invokes output recovery"
pass "clamshell invokes output recovery"
