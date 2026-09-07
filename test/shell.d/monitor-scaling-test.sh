#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
eval_out="$test_tmp/hyprctl-eval"
dbus_out="$test_tmp/dbus-update"
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
  printf '%s\n' "$2" >>"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
  if [[ $2 == 'hl.env('* && ${OMARCHY_TEST_HYPR_ENV_FAIL:-0} == 1 ]]; then
    exit 1
  fi
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

cat >"$stub_bin/dbus-update-activation-environment" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$OMARCHY_TEST_DBUS_OUT"
[[ ${OMARCHY_TEST_DBUS_FAIL:-0} == 0 ]]
SH
chmod +x "$stub_bin/dbus-update-activation-environment"

write_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 2
LUA
}

run_scaling() {
  : >"$eval_out"
  : >"$dbus_out"
  HOME="$home_dir" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    OMARCHY_TEST_DBUS_OUT="$dbus_out" \
    OMARCHY_TEST_MONITOR_SCALE="${OMARCHY_TEST_MONITOR_SCALE:-2}" \
    OMARCHY_TEST_HYPR_ENV_FAIL="${OMARCHY_TEST_HYPR_ENV_FAIL:-0}" \
    OMARCHY_TEST_DBUS_FAIL="${OMARCHY_TEST_DBUS_FAIL:-0}" \
    "$ROOT/bin/omarchy-hyprland-monitor-scaling" "$@"
}

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling up
grep -F 'scale = 3' "$eval_out" >/dev/null || fail "monitor scaling up reaches 3x"
grep -Fx 'local omarchy_monitor_scale = 3' "$monitor_lua" >/dev/null || fail "monitor scaling up persists 3x"
grep -Fx 'hl.env("GDK_SCALE", "3")' "$eval_out" >/dev/null || fail "monitor scaling up updates Hyprland GDK scale"
grep -Fx -- '--systemd GDK_SCALE=3' "$dbus_out" >/dev/null || fail "monitor scaling up updates systemd and D-Bus GDK scale"
grep -F $'requested=up\tcurrent=2\tnew=3\tmonitor=eDP-1' "$scale_log" >/dev/null || fail "monitor scaling up writes audit log"
pass "monitor scaling up reaches 3x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=3 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down recovers 3x to 2x"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null || fail "monitor scaling down persists 2x from 3x"
grep -Fx 'hl.env("GDK_SCALE", "2")' "$eval_out" >/dev/null || fail "monitor scaling down updates Hyprland GDK scale"
grep -Fx -- '--systemd GDK_SCALE=2' "$dbus_out" >/dev/null || fail "monitor scaling down updates systemd and D-Bus GDK scale"
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
pass "monitor scaling explicit 3x remains available"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1
grep -F 'scale = 1' "$eval_out" >/dev/null || fail "monitor scaling changes 2x to 1x"
grep -Fx 'local omarchy_monitor_scale = 1' "$monitor_lua" >/dev/null || fail "monitor scaling persists 1x"
grep -Fx 'hl.env("GDK_SCALE", "1")' "$eval_out" >/dev/null || fail "monitor scaling 1x updates Hyprland GDK scale"
grep -Fx -- '--systemd GDK_SCALE=1' "$dbus_out" >/dev/null || fail "monitor scaling 1x updates systemd and D-Bus GDK scale"
pass "monitor scaling propagates 2x to 1x"

# GTK only honors integer GDK_SCALE, so fractional monitor scales persist a
# rounded GDK scale.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
grep -F 'scale = 1.6' "$eval_out" >/dev/null || fail "monitor scaling explicit 1.6x remains available"
grep -Fx 'local omarchy_monitor_scale = 1.6' "$monitor_lua" >/dev/null || fail "monitor scaling explicit 1.6x persists"
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null || fail "monitor scaling 1.6x persists integer GDK scale 2"
grep -Fx 'hl.env("GDK_SCALE", "2")' "$eval_out" >/dev/null || fail "monitor scaling 1.6x propagates integer GDK scale 2"
grep -Fx -- '--systemd GDK_SCALE=2' "$dbus_out" >/dev/null || fail "monitor scaling 1.6x propagates systemd GDK scale 2"
pass "monitor scaling 1.6x persists integer GDK scale 2"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.25
grep -Fx 'local omarchy_monitor_scale = 1.25' "$monitor_lua" >/dev/null || fail "monitor scaling explicit 1.25x persists"
grep -Fx 'local omarchy_gdk_scale = 1' "$monitor_lua" >/dev/null || fail "monitor scaling 1.25x persists integer GDK scale 1"
grep -Fx 'hl.env("GDK_SCALE", "1")' "$eval_out" >/dev/null || fail "monitor scaling 1.25x propagates integer GDK scale 1"
grep -Fx -- '--systemd GDK_SCALE=1' "$dbus_out" >/dev/null || fail "monitor scaling 1.25x propagates systemd GDK scale 1"
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

cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.env("GDK_SCALE", "2")
LUA
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.25
grep -Fx 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists the legacy stock monitor scale"
grep -Fx 'hl.env("GDK_SCALE", "1")' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists the legacy stock GDK scale"
grep -Fx 'hl.env("GDK_SCALE", "1")' "$eval_out" >/dev/null ||
  fail "monitor scaling propagates the legacy stock GDK scale"
grep -Fx -- '--systemd GDK_SCALE=1' "$dbus_out" >/dev/null ||
  fail "monitor scaling propagates the legacy stock systemd GDK scale"
pass "monitor scaling persists and propagates the legacy stock config"

cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 2 })
hl.env("GDK_SCALE", "2")
LUA
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1
if grep -Fq 'hl.env(' "$eval_out" || [[ -s $dbus_out ]]; then
  fail "monitor scaling does not propagate GDK scale for a custom config"
fi
pass "monitor scaling does not propagate GDK scale for a custom config"

# sed exits successfully for the recognized variable-style config, but there
# is no GDK line to replace. The post-write check must prevent propagation.
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 2
LUA
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1
grep -Fx 'local omarchy_monitor_scale = 1' "$monitor_lua" >/dev/null ||
  fail "monitor scaling still updates the matched monitor line"
if grep -Fq 'hl.env(' "$eval_out" || [[ -s $dbus_out ]]; then
  fail "monitor scaling does not propagate when the GDK persistence target is missing"
fi
pass "monitor scaling verifies GDK persistence before propagation"

write_monitor_config
scale=$(OMARCHY_TEST_MONITOR_SCALE=2 run_scaling)
[[ $scale == "2" ]] || fail "monitor scaling query returns the current scale" "actual: $scale"
if grep -Fq 'hl.env(' "$eval_out" || [[ -s $dbus_out ]]; then
  fail "monitor scaling query does not propagate GDK scale"
fi
pass "monitor scaling query does not propagate GDK scale"

set +e
run_scaling invalid >/dev/null 2>&1
status=$?
set -e
(( status != 0 )) || fail "monitor scaling rejects invalid input"
if grep -Fq 'hl.env(' "$eval_out" || [[ -s $dbus_out ]]; then
  fail "monitor scaling invalid input does not propagate GDK scale"
fi
pass "monitor scaling invalid input does not propagate GDK scale"

write_monitor_config
set +e
OMARCHY_TEST_HYPR_ENV_FAIL=1 run_scaling 1 2>"$test_tmp/hypr-env-error"
status=$?
set -e
(( status != 0 )) || fail "monitor scaling fails when Hyprland environment sync fails"
grep -Fq 'Failed to update Hyprland GDK_SCALE environment' "$test_tmp/hypr-env-error" ||
  fail "monitor scaling reports a Hyprland environment sync failure"
grep -Fx -- '--systemd GDK_SCALE=1' "$dbus_out" >/dev/null ||
  fail "monitor scaling still attempts D-Bus sync after Hyprland sync fails"
pass "monitor scaling reports Hyprland environment sync failures"

write_monitor_config
set +e
OMARCHY_TEST_DBUS_FAIL=1 run_scaling 1 2>"$test_tmp/dbus-error"
status=$?
set -e
(( status != 0 )) || fail "monitor scaling fails when D-Bus environment sync fails"
grep -Fq 'Failed to update systemd and D-Bus GDK_SCALE environment' "$test_tmp/dbus-error" ||
  fail "monitor scaling reports a D-Bus environment sync failure"
grep -Fx 'hl.env("GDK_SCALE", "1")' "$eval_out" >/dev/null ||
  fail "monitor scaling updates Hyprland before a D-Bus sync failure"
pass "monitor scaling reports D-Bus environment sync failures"
