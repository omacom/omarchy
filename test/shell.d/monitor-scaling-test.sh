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
  printf '[{"name":"%s","description":"%s","focused":true,"scale":%s,"width":%s,"height":%s,"refreshRate":120.0}]' \
    "${OMARCHY_TEST_MONITOR_NAME:-eDP-1}" "${OMARCHY_TEST_MONITOR_DESCRIPTION:-}" \
    "${OMARCHY_TEST_MONITOR_SCALE:-2}" "${OMARCHY_TEST_MONITOR_WIDTH:-2880}" "${OMARCHY_TEST_MONITOR_HEIGHT:-1800}"
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

write_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 2
LUA
}

run_scaling() {
  HOME="$home_dir" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    OMARCHY_TEST_MONITOR_SCALE="${OMARCHY_TEST_MONITOR_SCALE:-2}" \
    "$ROOT/bin/omarchy-hyprland-monitor-scaling" "$@"
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
pass "monitor scaling explicit 3x remains available"

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

# Separate workspaces saves the focused screen's scale and leaves the shared one alone.
mkdir -p "$home_dir/.local/state/omarchy/toggles/hypr"
touch "$home_dir/.local/state/omarchy/toggles/hypr/monitor-workspaces.lua"
write_monitor_config
OMARCHY_TEST_MONITOR_NAME=HDMI-A-2 \
  OMARCHY_TEST_MONITOR_DESCRIPTION="LG Electronics LG ULTRAGEAR" \
  OMARCHY_TEST_MONITOR_SCALE=2 \
  OMARCHY_TEST_MONITOR_WIDTH=2560 \
  OMARCHY_TEST_MONITOR_HEIGHT=1440 \
  run_scaling 1.5
grep -F 'scale = 1.6' "$eval_out" >/dev/null || fail "separate workspaces raises 1.5 to 1.6 on 2560x1440"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "separate workspaces leaves the shared scale alone"
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null ||
  fail "separate workspaces leaves GDK scale alone"
grep -F 'output = "desc:LG Electronics LG ULTRAGEAR"' "$monitor_lua" >/dev/null ||
  fail "separate workspaces records the external screen by description" "$(cat "$monitor_lua")"
grep -F 'position = "auto", scale = 1.6' "$monitor_lua" >/dev/null ||
  fail "separate workspaces saves 1.6 for the external screen" "$(cat "$monitor_lua")"
pass "separate workspaces saves the external screen at 1.6 and leaves the shared scale"

OMARCHY_TEST_MONITOR_NAME=eDP-1 \
  OMARCHY_TEST_MONITOR_DESCRIPTION="Apple Computer Inc Color LCD" \
  OMARCHY_TEST_MONITOR_SCALE=2 \
  OMARCHY_TEST_MONITOR_WIDTH=2560 \
  OMARCHY_TEST_MONITOR_HEIGHT=1600 \
  run_scaling 2
grep -F 'output = "desc:Apple Computer Inc Color LCD", mode = "preferred", position = "0x0", scale = 2' "$monitor_lua" >/dev/null ||
  fail "separate workspaces anchors the built-in screen at 2" "$(cat "$monitor_lua")"
grep -F 'scale = 1.6' "$monitor_lua" >/dev/null ||
  fail "separate workspaces keeps the external screen at 1.6" "$(cat "$monitor_lua")"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "separate workspaces still leaves the shared scale alone"
pass "separate workspaces keeps each screen's scale"

# A later change updates the scale and keeps a position the user moved.
sed -i -E 's/position = "auto"/position = "1280x0"/' "$monitor_lua"
OMARCHY_TEST_MONITOR_NAME=HDMI-A-2 \
  OMARCHY_TEST_MONITOR_DESCRIPTION="LG Electronics LG ULTRAGEAR" \
  OMARCHY_TEST_MONITOR_SCALE=1.6 \
  OMARCHY_TEST_MONITOR_WIDTH=2560 \
  OMARCHY_TEST_MONITOR_HEIGHT=1440 \
  run_scaling 1.25
grep -F 'output = "desc:LG Electronics LG ULTRAGEAR", mode = "preferred", position = "1280x0", scale = 1.25' "$monitor_lua" >/dev/null ||
  fail "separate workspaces keeps a moved position when the scale changes" "$(cat "$monitor_lua")"
pass "separate workspaces keeps a moved position when the scale changes"

# A scale written outside the managed block is the user's, and turning the
# feature off must not delete it.
sed -i '/-- omarchy-separate-monitor-scales: start/i hl.monitor({ output = "desc:Hand Written", mode = "preferred", position = "auto", scale = 2 })' "$monitor_lua"
run_scaling --clear-separate-scales
if grep -qF 'omarchy-separate-monitor-scales' "$monitor_lua"; then
  fail "clearing separate scales removes the saved per-screen rules" "$(cat "$monitor_lua")"
fi
grep -F 'output = "desc:Hand Written"' "$monitor_lua" >/dev/null ||
  fail "clearing separate scales keeps a scale the user wrote" "$(cat "$monitor_lua")"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "clearing separate scales keeps the shared scale"
pass "clearing separate scales removes the per-screen rules"

# Turning the toggle off clears those rules before Hyprland reloads.
ln -sfn "$ROOT/bin/omarchy-hyprland-monitor-scaling" "$stub_bin/omarchy-hyprland-monitor-scaling"
cat >"$stub_bin/omarchy-hyprland-toggle" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_TOGGLE_LOG"
SH
cat >"$stub_bin/omarchy-hyprland-toggle-enabled" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$stub_bin/omarchy-i18n" <<'SH'
#!/bin/bash
printf '%s\n' "$1"
SH
chmod +x "$stub_bin/omarchy-hyprland-toggle" "$stub_bin/omarchy-hyprland-toggle-enabled" \
  "$stub_bin/omarchy-notification-send" "$stub_bin/omarchy-i18n"
# Put the per-screen block back, then turn the feature off.
OMARCHY_TEST_MONITOR_NAME=HDMI-A-2 \
  OMARCHY_TEST_MONITOR_DESCRIPTION="LG Electronics LG ULTRAGEAR" \
  OMARCHY_TEST_MONITOR_SCALE=2 \
  OMARCHY_TEST_MONITOR_WIDTH=2560 \
  OMARCHY_TEST_MONITOR_HEIGHT=1440 \
  run_scaling 1.6
HOME="$home_dir" XDG_STATE_HOME="$home_dir/.local/state" \
  PATH="$stub_bin:$PATH" OMARCHY_TEST_TOGGLE_LOG="$test_tmp/toggle.log" \
  "$ROOT/bin/omarchy-toggle-monitor-workspaces" off
grep -qF 'omarchy-separate-monitor-scales' "$monitor_lua" &&
  fail "turning separate workspaces off removes the per-screen scales" "$(cat "$monitor_lua")"
grep -Fx 'monitor-workspaces off' "$test_tmp/toggle.log" >/dev/null ||
  fail "turning separate workspaces off still disables the toggle" "$(cat "$test_tmp/toggle.log")"
pass "turning separate workspaces off removes the per-screen scales"
rm -f "$home_dir/.local/state/omarchy/toggles/hypr/monitor-workspaces.lua"
