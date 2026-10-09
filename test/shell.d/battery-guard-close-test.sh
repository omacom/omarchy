#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/runtime/hypr/fixture_1" "$tmp_dir/power/BAT0" "$tmp_dir/power/AC"
export XDG_RUNTIME_DIR="$tmp_dir/runtime" HELPER_EVENTS="$tmp_dir/events" FIXTURE_PID=$$
export FIXTURE_POWER="$tmp_dir/power" PLUG_AFTER_CLOSE=false
export REJECT_FIRST=false
printf 'Battery\n' >"$FIXTURE_POWER/BAT0/type"
printf 'USB_PD\n' >"$FIXTURE_POWER/AC/type"
printf 'Discharging\n' >"$FIXTURE_POWER/BAT0/status"
printf '0\n' >"$FIXTURE_POWER/AC/online"
cat >"$tmp_dir/bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $* == "-j instances" ]]; then
  printf '[{"instance":"fixture_1","pid":%s,"wl_socket":"wayland-1"}]\n' "$FIXTURE_PID"
elif [[ $* == "-j clients" ]]; then
  printf '[{"address":"0xabc"},{"address":"0xdef"},{"address":"invalid;code"}]\n'
else
  printf '%s|%s|%s\n' "$HYPRLAND_INSTANCE_SIGNATURE" "$WAYLAND_DISPLAY" "$*" >>"$HELPER_EVENTS"
  if [[ $REJECT_FIRST == "true" && $* == *"0xabc"* ]]; then
    printf 'error: temporary rejection\n'
    exit 0
  fi
  if [[ $PLUG_AFTER_CLOSE == "true" ]]; then
    printf '1\n' >"$FIXTURE_POWER/AC/online"
    printf 'Charging\n' >"$FIXTURE_POWER/BAT0/status"
  fi
fi
SH
chmod +x "$tmp_dir/bin/hyprctl"
if python3 - "$tmp_dir" <<'PY'
import os, socket, sys
os.chdir(sys.argv[1])
try:
  with socket.socket(socket.AF_UNIX) as s:
    # A relative bind path avoids Linux's 108-byte AF_UNIX pathname limit.
    s.bind('runtime/hypr/fixture_1/.socket.sock')
except PermissionError:
  sys.exit(77)
PY
then
  :
else
  result=$?
  if (( result == 77 )); then
    skip "helper socket fixture denied by sandbox"
    exit 0
  fi
  fail "helper socket fixture creation failed" "$result"
fi
plan=$(PATH="$tmp_dir/bin:$PATH" bash "$ROOT/default/battery-guard/close-windows" "$FIXTURE_POWER/BAT0" --snapshot)
[[ ! -s $HELPER_EVENTS ]] || fail "snapshot must never close any window"
[[ $(wc -l <<<"$plan") == 2 ]] || fail "snapshot includes only validated original windows"
while read -r signature pid wayland address; do
  PATH="$tmp_dir/bin:$PATH" bash "$ROOT/default/battery-guard/close-windows" "$FIXTURE_POWER/BAT0" --close-one "$signature" "$pid" "$wayland" "$address"
done <<<"$plan"
[[ $(wc -l <"$HELPER_EVENTS") == 2 ]] || fail "one invocation closes exactly one window"
grep -Fx 'fixture_1|wayland-1|dispatch hl.dsp.window.close({ window = "address:0xabc" })' "$HELPER_EVENTS" >/dev/null || fail "helper uses verified Lua API and instance environment"
result=0
REJECT_FIRST=true PATH="$tmp_dir/bin:$PATH" bash "$ROOT/default/battery-guard/close-windows" "$FIXTURE_POWER/BAT0" --close-one fixture_1 "$FIXTURE_PID" wayland-1 0xabc || result=$?
[[ $result == 2 ]] || fail "explicit Hyprland rejection has retryable status"
: >"$HELPER_EVENTS"
PLUG_AFTER_CLOSE=true PATH="$tmp_dir/bin:$PATH" bash "$ROOT/default/battery-guard/close-windows" "$FIXTURE_POWER/BAT0" --close-one fixture_1 "$FIXTURE_PID" wayland-1 0xabc
result=0
PATH="$tmp_dir/bin:$PATH" bash "$ROOT/default/battery-guard/close-windows" "$FIXTURE_POWER/BAT0" --close-one fixture_1 "$FIXTURE_PID" wayland-1 0xdef || result=$?
[[ $result == 3 && $(wc -l <"$HELPER_EVENTS") == 1 ]] || fail "AC aborts subsequent window requests"
pass "two-phase user helper snapshots without dispatch and closes only the requested window"
