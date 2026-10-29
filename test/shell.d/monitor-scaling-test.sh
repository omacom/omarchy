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
  printf '[{"name":"eDP-1","focused":true,"scale":%s,"width":%s,"height":%s,"refreshRate":120.0}' \
    "${OMARCHY_TEST_MONITOR_SCALE:-2}" "${OMARCHY_TEST_MONITOR_WIDTH:-2880}" "${OMARCHY_TEST_MONITOR_HEIGHT:-1800}"
  if [[ -n $OMARCHY_TEST_OTHER_MONITOR_SCALE ]]; then
    printf ',{"name":"DP-1","focused":false,"scale":%s,"width":3840,"height":2160,"refreshRate":60.0}' \
      "$OMARCHY_TEST_OTHER_MONITOR_SCALE"
  fi
  printf ']'
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

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
}

has_rule() {
  grep -Fx "hl.monitor({ output = \"eDP-1\", mode = \"preferred\", position = \"auto\", scale = $1 })" "$monitor_lua" >/dev/null
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
has_rule 3 || fail "monitor scaling up persists 3x"
grep -F $'requested=up\tcurrent=2\tnew=3\tmonitor=eDP-1' "$scale_log" >/dev/null || fail "monitor scaling up writes audit log"
pass "monitor scaling up reaches 3x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=3 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down recovers 3x to 2x"
has_rule 2 || fail "monitor scaling down persists 2x from 3x"
pass "monitor scaling down recovers 3x to 2x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=3.0000000000000004 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down snaps floating point 3x to 2x"
has_rule 2 || fail "monitor scaling down persists 2x from floating point 3x"
pass "monitor scaling down snaps floating point 3x to 2x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 3
grep -F 'scale = 3' "$eval_out" >/dev/null || fail "monitor scaling explicit 3x remains available"
has_rule 3 || fail "monitor scaling explicit 3x persists"
grep -Fx 'local omarchy_gdk_scale = 3' "$monitor_lua" >/dev/null || fail "monitor scaling explicit 3x persists GDK scale"
pass "monitor scaling explicit 3x remains available"

# GTK only honors integer GDK_SCALE, so fractional monitor scales persist a
# rounded GDK scale.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
grep -F 'scale = 1.6' "$eval_out" >/dev/null || fail "monitor scaling explicit 1.6x remains available"
has_rule 1.6 || fail "monitor scaling explicit 1.6x persists"
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null || fail "monitor scaling 1.6x persists integer GDK scale 2"
pass "monitor scaling 1.6x persists integer GDK scale 2"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.25
has_rule 1.25 || fail "monitor scaling explicit 1.25x persists"
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
has_rule 3.2 ||
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
has_rule 2 ||
  fail "monitor scaling down persists 2x after skipping duplicate approximation"
pass "monitor scaling down skips duplicate approximation"

# Scaling one monitor leaves the catch-all and every other monitor's rule alone,
# and a second change updates that monitor's rule instead of adding another.
write_monitor_config
printf '%s\n' 'hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })' >>"$monitor_lua"
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
OMARCHY_TEST_MONITOR_SCALE=1.6 run_scaling 3
has_rule 3 || fail "monitor scaling persists a rule for the focused monitor"
(( $(grep -c 'output = "eDP-1"' "$monitor_lua") == 1 )) || fail "monitor scaling updates the focused monitor's rule in place"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null || fail "monitor scaling leaves the catch-all scale alone"
grep -Fx 'hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves other monitors' rules alone"
pass "monitor scaling persists per monitor"

# Rules it cannot safely edit leave the config untouched instead of broken Lua.
printf '%s\n' 'hl.monitor({ output = "",' '  mode = "preferred", position = "auto", scale = 2' '})' >"$monitor_lua"
cp "$monitor_lua" "$test_tmp/expected.lua"
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 3
cmp -s "$monitor_lua" "$test_tmp/expected.lua" || fail "monitor scaling leaves a multi-line catch-all alone"
pass "monitor scaling leaves a multi-line catch-all alone"

write_monitor_config
printf '%s\n' 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = math.max(1, 2) })' >>"$monitor_lua"
cp "$monitor_lua" "$test_tmp/expected.lua"
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 3
cmp -s "$monitor_lua" "$test_tmp/expected.lua" || fail "monitor scaling leaves a scale expression alone"
pass "monitor scaling leaves a scale expression alone"

write_monitor_config
printf '%s\n' 'hl.monitor({' '  output = "eDP-1", mode = "preferred", position = "auto", scale = 2,' '})' >>"$monitor_lua"
cp "$monitor_lua" "$test_tmp/expected.lua"
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 3
cmp -s "$monitor_lua" "$test_tmp/expected.lua" || fail "monitor scaling adds no rule beside a multi-line one for the monitor"
pass "monitor scaling adds no rule beside a multi-line one for the monitor"

# The rewrite replaces the file behind a symlinked monitors.lua, keeping the link.
write_monitor_config
mv "$monitor_lua" "$test_tmp/dotfiles-monitors.lua"
ln -s "$test_tmp/dotfiles-monitors.lua" "$monitor_lua"
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 3
[[ -L $monitor_lua ]] || fail "monitor scaling keeps a symlinked monitors.lua a symlink"
has_rule 3 || fail "monitor scaling persists through a symlinked monitors.lua"
pass "monitor scaling persists through a symlinked monitors.lua"
rm "$monitor_lua"

# GDK_SCALE is session-wide, so it follows the lowest monitor scale: raising
# one screen must not oversize XWayland apps on another.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 OMARCHY_TEST_OTHER_MONITOR_SCALE=1 run_scaling 4
grep -Fx 'local omarchy_gdk_scale = 1' "$monitor_lua" >/dev/null || fail "monitor scaling keeps GDK scale at the lowest monitor"
OMARCHY_TEST_MONITOR_SCALE=4 OMARCHY_TEST_OTHER_MONITOR_SCALE=3 run_scaling 2
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null || fail "monitor scaling lowers GDK scale to the newly lowest monitor"
pass "monitor scaling sets GDK scale from the lowest monitor"
