#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
eval_out="$test_tmp/hyprctl-eval"
home_dir="$test_tmp/home"
state_dir="$home_dir/.local/state/omarchy"
monitor_lua="$home_dir/.config/hypr/monitors.lua"
settings_file="$state_dir/monitors/settings"
scale_log="$state_dir/monitors/scaling"

mkdir -p "$stub_bin" "$home_dir/.config/hypr"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "-j" && -n $OMARCHY_TEST_MONITORS_JSON ]]; then
  printf '%s' "$OMARCHY_TEST_MONITORS_JSON"
elif [[ $1 == "monitors" && $2 == "-j" ]]; then
  printf '[{"name":"eDP-1","focused":true,"x":0,"y":0,"scale":%s,"width":%s,"height":%s,"refreshRate":120.0,"availableModes":["2880x1800@120.00Hz","2880x1800@60.00Hz","1920x1200@60.00Hz"]}' \
    "${OMARCHY_TEST_MONITOR_SCALE:-2}" "${OMARCHY_TEST_MONITOR_WIDTH:-2880}" "${OMARCHY_TEST_MONITOR_HEIGHT:-1800}"
  if [[ -n $OMARCHY_TEST_OTHER_MONITOR_SCALE ]]; then
    printf ',{"name":"DP-1","focused":false,"x":1440,"y":0,"scale":%s,"width":3840,"height":2160,"refreshRate":60.0,"availableModes":["3840x2160@60.00Hz","2560x1440@60.00Hz"]}' \
      "$OMARCHY_TEST_OTHER_MONITOR_SCALE"
  fi
  printf ']'
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >>"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

# Each block starts with nothing saved and no evals; a change can eval more
# than once (a resize, then the layout closing up around it). monitors.lua is
# the user's, and only there to show it is never written.
fresh() {
  rm -f "$eval_out" "$settings_file" "$state_dir/monitors/workspaces"
  printf '%s\n' 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })' >"$monitor_lua"
}

# A monitor's saved mode|position|scale, by identity.
setting() {
  awk -F'\t' -v identity="$1" '$4 == identity { print $1 "|" $2 "|" $3 }' "$settings_file" 2>/dev/null
}

run_scaling() {
  HOME="$home_dir" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    OMARCHY_TEST_MONITOR_SCALE="${OMARCHY_TEST_MONITOR_SCALE:-2}" \
    "$ROOT/bin/omarchy-hyprland-monitor-scaling" "$@"
}

run_resolution() {
  HOME="$home_dir" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    "$ROOT/bin/omarchy-hyprland-monitor-resolution" "$@"
}

run_layout() {
  HOME="$home_dir" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    "$ROOT/bin/omarchy-hyprland-monitor-layout" "$@"
}

fresh
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling up
grep -F 'scale = 3' "$eval_out" >/dev/null || fail "monitor scaling up reaches 3x"
[[ $(setting eDP-1) == "||3" ]] || fail "monitor scaling up saves 3x" "actual: $(setting eDP-1)"
grep -F $'requested=up\tcurrent=2\tnew=3\tmonitor=eDP-1' "$scale_log" >/dev/null || fail "monitor scaling up writes audit log"
pass "monitor scaling up reaches 3x"

fresh
OMARCHY_TEST_MONITOR_SCALE=3 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down recovers 3x to 2x"
[[ $(setting eDP-1) == "||2" ]] || fail "monitor scaling down saves 2x from 3x"
pass "monitor scaling down recovers 3x to 2x"

fresh
OMARCHY_TEST_MONITOR_SCALE=3.0000000000000004 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down snaps floating point 3x to 2x"
[[ $(setting eDP-1) == "||2" ]] || fail "monitor scaling down saves 2x from floating point 3x"
pass "monitor scaling down snaps floating point 3x to 2x"

fresh
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 3
grep -F 'scale = 3' "$eval_out" >/dev/null || fail "monitor scaling explicit 3x remains available"
[[ $(setting eDP-1) == "||3" ]] || fail "monitor scaling explicit 3x saves"
pass "monitor scaling explicit 3x remains available"

fresh
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
grep -F 'scale = 1.6' "$eval_out" >/dev/null || fail "monitor scaling explicit 1.6x remains available"
[[ $(setting eDP-1) == "||1.6" ]] || fail "monitor scaling explicit 1.6x saves"
pass "monitor scaling explicit 1.6x remains available"

scale=$(OMARCHY_TEST_MONITOR_SCALE=3 run_scaling)
[[ $scale == "3" ]] || fail "monitor scaling reports explicit 3x scale" "actual: $scale"
pass "monitor scaling reports explicit 3x scale"

scale=$(OMARCHY_TEST_MONITOR_SCALE=3.2 run_scaling)
[[ $scale == "3.2" ]] || fail "monitor scaling reports the actual non-preset scale" "actual: $scale"
pass "monitor scaling reports the actual non-preset scale"

# 1280x800 approximates the 3x preset as 3.2x.
fresh
OMARCHY_TEST_MONITOR_SCALE=2 OMARCHY_TEST_MONITOR_WIDTH=1280 OMARCHY_TEST_MONITOR_HEIGHT=800 run_scaling 3
grep -F 'scale = 3.2' "$eval_out" >/dev/null || fail "monitor scaling approximates explicit 3x as 3.2x"
[[ $(setting eDP-1) == "||3.2" ]] || fail "monitor scaling saves approximated 3.2x"
pass "monitor scaling approximates explicit 3x as 3.2x"

fresh
OMARCHY_TEST_MONITOR_SCALE=2 OMARCHY_TEST_MONITOR_WIDTH=1280 OMARCHY_TEST_MONITOR_HEIGHT=800 run_scaling up
grep -F 'scale = 3.2' "$eval_out" >/dev/null || fail "monitor scaling up reaches approximated 3.2x"
pass "monitor scaling up reaches approximated 3.2x"

fresh
OMARCHY_TEST_MONITOR_SCALE=4 OMARCHY_TEST_MONITOR_WIDTH=1280 OMARCHY_TEST_MONITOR_HEIGHT=800 run_scaling down
grep -F 'scale = 3.2' "$eval_out" >/dev/null || fail "monitor scaling down reaches approximated 3.2x"
pass "monitor scaling down reaches approximated 3.2x"

fresh
OMARCHY_TEST_MONITOR_SCALE=2 OMARCHY_TEST_MONITOR_WIDTH=6016 OMARCHY_TEST_MONITOR_HEIGHT=3384 run_scaling 1.25
grep -F 'scale = 1.33333' "$eval_out" >/dev/null || fail "monitor scaling approximates explicit 1.25x"
pass "monitor scaling approximates explicit 1.25x"

fresh
OMARCHY_TEST_MONITOR_SCALE=2 OMARCHY_TEST_MONITOR_WIDTH=1280 OMARCHY_TEST_MONITOR_HEIGHT=800 run_scaling 3.2
grep -F 'scale = 3.2' "$eval_out" >/dev/null || fail "monitor scaling accepts displayed approximate values"
pass "monitor scaling accepts displayed approximate values"

# On a mode where both 3x and 4x resolve to 4x, the duplicate is one step.
fresh
OMARCHY_TEST_MONITOR_SCALE=4 OMARCHY_TEST_MONITOR_WIDTH=1280 OMARCHY_TEST_MONITOR_HEIGHT=804 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down skips duplicate 4x approximation"
[[ $(setting eDP-1) == "||2" ]] || fail "monitor scaling down saves 2x after skipping duplicate approximation"
pass "monitor scaling down skips duplicate approximation"

# A second change updates the monitor's line rather than adding another, and
# the user's monitors.lua is never written.
fresh
cp "$monitor_lua" "$test_tmp/expected.lua"
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
OMARCHY_TEST_MONITOR_SCALE=1.6 run_scaling 3
(( $(wc -l <"$settings_file") == 1 )) || fail "monitor scaling keeps one line per monitor" "actual: $(<"$settings_file")"
[[ $(setting eDP-1) == "||3" ]] || fail "monitor scaling updates the monitor's line"
cmp -s "$monitor_lua" "$test_tmp/expected.lua" || fail "monitor scaling leaves monitors.lua alone"
pass "monitor scaling saves one line per monitor, outside monitors.lua"

# Settings belong to the physical monitor, as monitor-workspaces names it, so
# they follow it to whatever connector a dock gives it next.
fresh
mkdir -p "$state_dir/monitors"
printf '0\teDP-1\tLG Display 0x0804\n' >"$state_dir/monitors/workspaces"
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 3
[[ $(setting "LG Display 0x0804") == "||3" ]] || fail "monitor scaling saves by the monitor's identity" "actual: $(<"$settings_file")"
[[ -z $(setting eDP-1) ]] || fail "monitor scaling doesn't save by connector when the identity is known"
pass "monitor scaling saves by the monitor's identity"

# A resolution without a rate takes the fastest one the monitor offers for it,
# and saves the mode with the scale.
fresh
run_resolution 2880x1800
grep -F 'mode = "2880x1800@120"' "$eval_out" >/dev/null || fail "monitor resolution picks the fastest rate"
pass "monitor resolution picks the fastest rate"

fresh
run_resolution 1920x1200
[[ $(setting eDP-1) == "1920x1200@60||2" ]] || fail "monitor resolution saves the mode" "actual: $(setting eDP-1)"
pass "monitor resolution saves the mode"

# Changing the scale afterwards keeps the chosen resolution.
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
[[ $(setting eDP-1) == "1920x1200@60||1.6" ]] || fail "monitor scaling keeps a saved resolution" "actual: $(setting eDP-1)"
pass "monitor scaling keeps a saved resolution"

fresh
if run_resolution 1280x720 2>/dev/null; then fail "monitor resolution rejects a mode the monitor lacks"; fi
[[ ! -e $eval_out ]] || fail "monitor resolution leaves an unsupported mode unapplied"
pass "monitor resolution rejects a mode the monitor lacks"

# Each screen takes only the modes it advertises itself, whichever is focused.
fresh
OMARCHY_TEST_OTHER_MONITOR_SCALE=1 run_resolution --monitor DP-1 2560x1440
grep -F 'output = "DP-1", mode = "2560x1440@60"' "$eval_out" >/dev/null || fail "monitor resolution sets an unfocused monitor"
[[ $(setting DP-1) == "2560x1440@60|1440x0|1" ]] || fail "monitor resolution saves an unfocused monitor's mode" "actual: $(setting DP-1)"
rm -f "$eval_out"
if OMARCHY_TEST_OTHER_MONITOR_SCALE=1 run_resolution --monitor DP-1 2880x1800 2>/dev/null; then
  fail "monitor resolution rejects another screen's mode"
fi
[[ ! -e $eval_out ]] || fail "monitor resolution leaves another screen's mode unapplied"
pass "monitor resolution works per screen"

# --monitor scales that screen, whichever is focused.
fresh
OMARCHY_TEST_MONITOR_SCALE=2 OMARCHY_TEST_OTHER_MONITOR_SCALE=1 run_scaling --monitor DP-1 2
grep -F 'output = "DP-1", mode = "3840x2160@60.0", position = "1440x0", scale = 2' "$eval_out" >/dev/null ||
  fail "monitor scaling sets an unfocused monitor"
[[ $(setting DP-1) == "|1440x0|2" ]] || fail "monitor scaling saves an unfocused monitor's scale" "actual: $(setting DP-1)"
scale=$(OMARCHY_TEST_OTHER_MONITOR_SCALE=1.5 run_scaling --monitor DP-1)
[[ $scale == "1.5" ]] || fail "monitor scaling reports an unfocused monitor's scale" "actual: $scale"
pass "monitor scaling works per screen"

# A layout moves every monitor in one eval and saves each position, keeping a
# chosen resolution.
fresh
run_resolution 1920x1200
OMARCHY_TEST_OTHER_MONITOR_SCALE=1 run_layout eDP-1=0x0 DP-1=960x-200
grep -Fx 'hl.monitor({ output = "eDP-1", position = "0x0" }) hl.monitor({ output = "DP-1", position = "960x-200" }) ' "$eval_out" >/dev/null ||
  fail "monitor layout moves every monitor in one eval" "actual: $(<"$eval_out")"
[[ $(setting eDP-1) == "1920x1200@60|0x0|2" ]] || fail "monitor layout saves a position and keeps the mode" "actual: $(setting eDP-1)"
[[ $(setting DP-1) == "|960x-200|1" ]] || fail "monitor layout saves a monitor's position" "actual: $(setting DP-1)"
rm -f "$eval_out"
if OMARCHY_TEST_OTHER_MONITOR_SCALE=1 run_layout 'DP-1=0x0"' 2>/dev/null; then fail "monitor layout rejects a malformed position"; fi
if run_layout HDMI-A-1=0x0 2>/dev/null; then fail "monitor layout rejects an unknown monitor"; fi
[[ ! -e $eval_out ]] || fail "monitor layout applies nothing it rejects"
pass "monitor layout moves and saves every monitor's position"

# A smaller mode beside another monitor keeps its corner and pulls the monitor
# on its right in, so no gap opens: 2880x1800 at 2x spans 1440, 1920x1200 960.
fresh
OMARCHY_TEST_OTHER_MONITOR_SCALE=1 run_resolution 1920x1200
grep -F 'output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 2' "$eval_out" >/dev/null ||
  fail "monitor resolution keeps its place beside another monitor" "actual: $(<"$eval_out")"
grep -F 'hl.monitor({ output = "DP-1", position = "960x0" })' "$eval_out" >/dev/null ||
  fail "monitor resolution moves its neighbour up to its new edge" "actual: $(<"$eval_out")"
[[ $(setting DP-1) == "|960x0|1" ]] || fail "monitor resolution saves its neighbour's new position" "actual: $(setting DP-1)"
pass "monitor resolution closes the layout up around a smaller mode"

# Two screens stacked on the left of a tall one: shrinking the top-left one
# would pull the tall one left and the lower one up onto each other, so the one
# that can go back does, and nothing overlaps.
fresh
OMARCHY_TEST_MONITORS_JSON='[{"name":"DP-1","x":0,"y":0,"width":100,"height":100,"scale":1},{"name":"DP-2","x":100,"y":0,"width":100,"height":200,"scale":1},{"name":"DP-3","x":0,"y":100,"width":100,"height":100,"scale":1}]' \
  run_layout --resized DP-1 100x100 1 100x100 2
grep -F 'hl.monitor({ output = "DP-2", position = "100x0" }) hl.monitor({ output = "DP-3", position = "0x50" })' "$eval_out" >/dev/null ||
  fail "monitor layout keeps neighbours from piling onto each other" "actual: $(<"$eval_out")"
pass "monitor layout keeps neighbours from piling onto each other"

# With a fourth screen beyond the tall one, neither overlapping screen can go
# back until the far one, which overlaps nothing, frees the tall one's spot.
fresh
OMARCHY_TEST_MONITORS_JSON='[{"name":"DP-1","x":0,"y":0,"width":1000,"height":1000,"scale":1},{"name":"DP-2","x":1000,"y":0,"width":1000,"height":2000,"scale":1},{"name":"DP-3","x":0,"y":1000,"width":1000,"height":1000,"scale":1},{"name":"DP-4","x":2000,"y":0,"width":1000,"height":2000,"scale":1}]' \
  run_layout --resized DP-1 1000x1000 1 1000x1000 2
grep -F 'hl.monitor({ output = "DP-2", position = "1000x0" }) hl.monitor({ output = "DP-3", position = "0x500" }) hl.monitor({ output = "DP-4", position = "2000x0" })' "$eval_out" >/dev/null ||
  fail "monitor layout untangles a pile-up a third screen blocks" "actual: $(<"$eval_out")"
pass "monitor layout untangles a pile-up a third screen blocks"

# The saved settings are read back on every config load, so a value out of
# place (here a flag it doesn't know, shifting a connector into the scale)
# saves nothing.
fresh
if HOME="$home_dir" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-hyprland-monitor-persist" --other eDP-1 2 2>/dev/null; then
  fail "monitor persist refuses a setting with a value out of place"
fi
[[ ! -e $settings_file ]] || fail "monitor persist saves nothing when it refuses"
pass "monitor persist refuses a setting that would misconfigure the monitor"
