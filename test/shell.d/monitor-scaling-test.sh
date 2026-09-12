#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
eval_out="$test_tmp/hyprctl-eval"
home_dir="$test_tmp/home"
monitor_lua="$home_dir/.config/hypr/monitors.lua"
scale_log="$home_dir/.local/state/omarchy/monitor-scaling.log"

mkdir -p "$stub_bin" "$home_dir/.config/hypr"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "-j" ]]; then
  printf '[{"name":"eDP-1","focused":true,"scale":%s,"width":%s,"height":%s,"refreshRate":120.0}]' \
    "${OMARCHY_TEST_MONITOR_SCALE:-2}" "${OMARCHY_TEST_MONITOR_WIDTH:-2880}" "${OMARCHY_TEST_MONITOR_HEIGHT:-1800}"
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

# Capture activation-environment updates so scale changes cannot leave GDK_SCALE
# stale in the systemd/D-Bus launch path (issue #10555).
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_SYSTEMCTL_LOG"
SH
chmod +x "$stub_bin/systemctl"

cat >"$stub_bin/dbus-update-activation-environment" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_DBUS_LOG"
SH
chmod +x "$stub_bin/dbus-update-activation-environment"

write_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 2
LUA
}

systemctl_log="$test_tmp/systemctl.log"
dbus_log="$test_tmp/dbus.log"

run_scaling() {
  : >"$systemctl_log"
  : >"$dbus_log"
  HOME="$home_dir" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    OMARCHY_TEST_SYSTEMCTL_LOG="$systemctl_log" \
    OMARCHY_TEST_DBUS_LOG="$dbus_log" \
    OMARCHY_TEST_MONITOR_SCALE="${OMARCHY_TEST_MONITOR_SCALE:-2}" \
    "$ROOT/bin/omarchy-hyprland-monitor-scaling" "$@"
}

assert_gdk_scale_activation_synced() {
  local expected="$1"

  grep -Fx -- "--user set-environment GDK_SCALE=$expected" "$systemctl_log" >/dev/null ||
    fail "monitor scaling syncs GDK_SCALE=$expected via systemctl --user set-environment" "$(cat "$systemctl_log")"
  grep -Fx -- "--systemd GDK_SCALE=$expected" "$dbus_log" >/dev/null ||
    fail "monitor scaling syncs GDK_SCALE=$expected via dbus-update-activation-environment" "$(cat "$dbus_log")"
}

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling up
grep -F 'scale = 3' "$eval_out" >/dev/null || fail "monitor scaling up reaches 3x"
grep -Fx 'local omarchy_monitor_scale = 3' "$monitor_lua" >/dev/null || fail "monitor scaling up persists 3x"
grep -F $'requested=up\tcurrent=2\tnew=3\tmonitor=eDP-1' "$scale_log" >/dev/null || fail "monitor scaling up writes audit log"
pass "monitor scaling up reaches 3x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=3 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down recovers 3x to 2x"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null || fail "monitor scaling down persists 2x from 3x"
pass "monitor scaling down recovers 3x to 2x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=3.0000000000000004 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down snaps floating point 3x to 2x"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null || fail "monitor scaling down persists 2x from floating point 3x"
pass "monitor scaling down snaps floating point 3x to 2x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 3
grep -F 'scale = 3' "$eval_out" >/dev/null || fail "monitor scaling explicit 3x remains available"
grep -Fx 'local omarchy_monitor_scale = 3' "$monitor_lua" >/dev/null || fail "monitor scaling explicit 3x persists"
grep -Fx 'local omarchy_gdk_scale = 3' "$monitor_lua" >/dev/null || fail "monitor scaling explicit 3x persists GDK scale"
assert_gdk_scale_activation_synced 3
pass "monitor scaling explicit 3x remains available"

# Scale-down to 100% must refresh the activation environment, not only monitors.lua.
# Otherwise uwsm-launched XWayland apps keep the login-time GDK_SCALE (issue #10555).
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1
grep -F 'scale = 1' "$eval_out" >/dev/null || fail "monitor scaling explicit 1x remains available"
grep -Fx 'local omarchy_monitor_scale = 1' "$monitor_lua" >/dev/null || fail "monitor scaling explicit 1x persists"
grep -Fx 'local omarchy_gdk_scale = 1' "$monitor_lua" >/dev/null || fail "monitor scaling explicit 1x persists GDK scale"
assert_gdk_scale_activation_synced 1
pass "monitor scaling explicit 1x syncs GDK_SCALE into the activation environment"

# GTK only honors integer GDK_SCALE, so fractional monitor scales persist a
# rounded GDK scale.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
grep -F 'scale = 1.6' "$eval_out" >/dev/null || fail "monitor scaling explicit 1.6x remains available"
grep -Fx 'local omarchy_monitor_scale = 1.6' "$monitor_lua" >/dev/null || fail "monitor scaling explicit 1.6x persists"
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null || fail "monitor scaling 1.6x persists integer GDK scale 2"
pass "monitor scaling 1.6x persists integer GDK scale 2"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.25
grep -Fx 'local omarchy_monitor_scale = 1.25' "$monitor_lua" >/dev/null || fail "monitor scaling explicit 1.25x persists"
grep -Fx 'local omarchy_gdk_scale = 1' "$monitor_lua" >/dev/null || fail "monitor scaling 1.25x persists integer GDK scale 1"
pass "monitor scaling 1.25x persists integer GDK scale 1"

scale=$(OMARCHY_TEST_MONITOR_SCALE=3 run_scaling)
[[ $scale == "3" ]] || fail "monitor scaling reports explicit 3x scale" "actual: $scale"
pass "monitor scaling reports explicit 3x scale"

scale=$(OMARCHY_TEST_MONITOR_SCALE=3.2 run_scaling)
[[ $scale == "3.2" ]] || fail "monitor scaling reports the actual non-preset scale" "actual: $scale"
pass "monitor scaling reports the actual non-preset scale"

# 1280x800 approximates the 3x preset as 3.2x.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 OMARCHY_TEST_MONITOR_WIDTH=1280 OMARCHY_TEST_MONITOR_HEIGHT=800 run_scaling 3
grep -F 'scale = 3.2' "$eval_out" >/dev/null || fail "monitor scaling approximates explicit 3x as 3.2x"
grep -Fx 'local omarchy_monitor_scale = 3.2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists approximated 3.2x"
pass "monitor scaling approximates explicit 3x as 3.2x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 OMARCHY_TEST_MONITOR_WIDTH=1280 OMARCHY_TEST_MONITOR_HEIGHT=800 run_scaling up
grep -F 'scale = 3.2' "$eval_out" >/dev/null || fail "monitor scaling up reaches approximated 3.2x"
pass "monitor scaling up reaches approximated 3.2x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=4 OMARCHY_TEST_MONITOR_WIDTH=1280 OMARCHY_TEST_MONITOR_HEIGHT=800 run_scaling down
grep -F 'scale = 3.2' "$eval_out" >/dev/null || fail "monitor scaling down reaches approximated 3.2x"
pass "monitor scaling down reaches approximated 3.2x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 OMARCHY_TEST_MONITOR_WIDTH=6016 OMARCHY_TEST_MONITOR_HEIGHT=3384 run_scaling 1.25
grep -F 'scale = 1.33333' "$eval_out" >/dev/null || fail "monitor scaling approximates explicit 1.25x"
pass "monitor scaling approximates explicit 1.25x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 OMARCHY_TEST_MONITOR_WIDTH=1280 OMARCHY_TEST_MONITOR_HEIGHT=800 run_scaling 3.2
grep -F 'scale = 3.2' "$eval_out" >/dev/null || fail "monitor scaling accepts displayed approximate values"
pass "monitor scaling accepts displayed approximate values"

# On a mode where both 3x and 4x resolve to 4x, the duplicate is one step.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=4 OMARCHY_TEST_MONITOR_WIDTH=1280 OMARCHY_TEST_MONITOR_HEIGHT=804 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down skips duplicate 4x approximation"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling down persists 2x after skipping duplicate approximation"
pass "monitor scaling down skips duplicate approximation"
