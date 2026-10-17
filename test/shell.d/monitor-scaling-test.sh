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
  printf '[{"name":"%s","focused":true,"scale":%s,"width":%s,"height":%s,"refreshRate":%s,"x":%s,"y":%s}]' \
    "${OMARCHY_TEST_MONITOR_NAME:-eDP-1}" \
    "${OMARCHY_TEST_MONITOR_SCALE:-2}" "${OMARCHY_TEST_MONITOR_WIDTH:-2880}" "${OMARCHY_TEST_MONITOR_HEIGHT:-1800}" \
    "${OMARCHY_TEST_MONITOR_REFRESH:-120.0}" \
    "${OMARCHY_TEST_MONITOR_X:-0}" "${OMARCHY_TEST_MONITOR_Y:-0}"
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

# write_monitor_config prints a monitor config with a distinctive shared scale
# (1.5) so "the shared variable was left alone" is assertable on its own.
write_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.5
LUA
}

run_scaling() {
  HOME="$home_dir" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    OMARCHY_TEST_MONITOR_SCALE="${OMARCHY_TEST_MONITOR_SCALE:-2}" \
    OMARCHY_TEST_MONITOR_NAME="${OMARCHY_TEST_MONITOR_NAME:-eDP-1}" \
    "$ROOT/bin/omarchy-hyprland-monitor-scaling" "$@"
}

rule_line() {
  local name="$1" width="$2" height="$3" refresh="$4" position="$5" scale="$6"
  printf 'hl.monitor({ output = "%s", mode = "%sx%s@%s", position = "%s", scale = %s })' \
    "$name" "$width" "$height" "$refresh" "$position" "$scale"
}

rule_auto() { rule_line "$1" "$2" "$3" "$4" auto "$5"; }

# The scale change must land as a rule for the focused output only.
# omarchy_monitor_scale feeds the catch-all rule, so rewriting it would rescale
# every display on Hyprland's reload (omarchy#6673); it must be left alone.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling up
grep -F "scale = 3" "$eval_out" >/dev/null || fail "monitor scaling up reaches 3x"
grep -F "$(rule_auto eDP-1 2880 1800 120.0 3)" "$monitor_lua" >/dev/null ||
  fail "monitor scaling up persists a per-output 3x rule" "$(cat "$monitor_lua")"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "monitor scaling up leaves the shared scale alone" "$(cat "$monitor_lua")"
grep -Fx 'local omarchy_gdk_scale = 3' "$monitor_lua" >/dev/null || fail "monitor scaling up persists GDK scale"
grep -F $'requested=up\tcurrent=2\tnew=3\tmonitor=eDP-1' "$scale_log" >/dev/null || fail "monitor scaling up writes audit log"
pass "monitor scaling up persists a per-output rule, not the shared scale"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=3 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down recovers 3x to 2x"
grep -F "$(rule_auto eDP-1 2880 1800 120.0 2)" "$monitor_lua" >/dev/null ||
  fail "monitor scaling down persists a per-output 2x rule"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "monitor scaling down leaves the shared scale alone"
pass "monitor scaling down recovers 3x to 2x per output"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=3.0000000000000004 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down snaps floating point 3x to 2x"
grep -F "$(rule_auto eDP-1 2880 1800 120.0 2)" "$monitor_lua" >/dev/null ||
  fail "monitor scaling down persists an approximated per-output 2x rule"
pass "monitor scaling down snaps floating point 3x to 2x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 3
grep -F 'scale = 3' "$eval_out" >/dev/null || fail "monitor scaling explicit 3x remains available"
grep -F "$(rule_auto eDP-1 2880 1800 120.0 3)" "$monitor_lua" >/dev/null ||
  fail "monitor scaling explicit 3x persists per output"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "monitor scaling explicit 3x leaves the shared scale alone"
pass "monitor scaling explicit 3x persists per output"

# GTK only honors integer GDK_SCALE, so fractional monitor scales persist a
# rounded GDK scale.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
grep -F 'scale = 1.6' "$eval_out" >/dev/null || fail "monitor scaling explicit 1.6x remains available"
grep -F "$(rule_auto eDP-1 2880 1800 120.0 1.6)" "$monitor_lua" >/dev/null ||
  fail "monitor scaling explicit 1.6x persists per output"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "monitor scaling 1.6x leaves the shared scale alone"
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null || fail "monitor scaling 1.6x persists integer GDK scale 2"
pass "monitor scaling 1.6x persists a per-output rule with integer GDK scale 2"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.25
grep -F "$(rule_auto eDP-1 2880 1800 120.0 1.25)" "$monitor_lua" >/dev/null ||
  fail "monitor scaling explicit 1.25x persists per output"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "monitor scaling 1.25x leaves the shared scale alone"
grep -Fx 'local omarchy_gdk_scale = 1' "$monitor_lua" >/dev/null || fail "monitor scaling 1.25x persists integer GDK scale 1"
pass "monitor scaling 1.25x persists a per-output rule with integer GDK scale 1"

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
grep -F "$(rule_auto eDP-1 1280 800 120.0 3.2)" "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists approximated per-output 3.2x"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the shared scale alone when approximating"
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
grep -F "$(rule_auto eDP-1 1280 804 120.0 2)" "$monitor_lua" >/dev/null ||
  fail "monitor scaling down persists a per-output 2x rule after skipping duplicate approximation"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "monitor scaling down leaves the shared scale alone after skipping duplicate approximation"
pass "monitor scaling down skips duplicate approximation"

# A pure auto layout keeps position = "auto": a frozen pixel position captured
# at one neighbor scale overlaps once that neighbor scales differently
# (omarchy#6673); auto lets Hyprland re-place the outputs beside each other.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=1 OMARCHY_TEST_MONITOR_WIDTH=1920 OMARCHY_TEST_MONITOR_HEIGHT=1080 \
  OMARCHY_TEST_MONITOR_X=1920 OMARCHY_TEST_MONITOR_Y=0 run_scaling 1.6
grep -F "$(rule_line eDP-1 1920 1080 120.0 auto 1.6)" "$eval_out" >/dev/null ||
  fail "an auto layout keeps position auto in the runtime rule" "$(cat "$eval_out")"
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=1 OMARCHY_TEST_MONITOR_WIDTH=1920 OMARCHY_TEST_MONITOR_HEIGHT=1080 \
  OMARCHY_TEST_MONITOR_X=1920 OMARCHY_TEST_MONITOR_Y=0 run_scaling 1.6
grep -F "$(rule_auto eDP-1 1920 1080 120.0 1.6)" "$monitor_lua" >/dev/null ||
  fail "an auto layout keeps position auto in the persisted rule" "$(cat "$monitor_lua")"
pass "an auto layout keeps position auto, so a rescaled neighbor can never overlap"

# A pinned layout keeps each output where the config put it.
cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 1
hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "1920x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "1920x1080@60", position = "0x0", scale = 1 })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 OMARCHY_TEST_MONITOR_NAME=DP-2 \
  OMARCHY_TEST_MONITOR_WIDTH=1920 OMARCHY_TEST_MONITOR_HEIGHT=1080 OMARCHY_TEST_MONITOR_REFRESH=60.0 \
  OMARCHY_TEST_MONITOR_X=0 run_scaling 1.6
grep -F "$(rule_line DP-2 1920 1080 60.0 0x0 1.6)" "$eval_out" >/dev/null ||
  fail "a pinned output keeps its own configured position" "$(cat "$eval_out")"
OMARCHY_TEST_MONITOR_SCALE=1 OMARCHY_TEST_MONITOR_NAME=DP-1 \
  OMARCHY_TEST_MONITOR_WIDTH=2560 OMARCHY_TEST_MONITOR_HEIGHT=1440 OMARCHY_TEST_MONITOR_REFRESH=144.0 \
  OMARCHY_TEST_MONITOR_X=1920 run_scaling 1.6
grep -F "$(rule_line DP-1 2560 1440 144.0 1920x0 1.6)" "$eval_out" >/dev/null ||
  fail "the other pinned output keeps its own configured position" "$(cat "$eval_out")"
pass "a pinned layout keeps each output at its configured position"

# Stock config regression (omarchy#6673): with only the catch-all, changing
# one display's scale must leave the shared default in place for the others.
write_stock_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
}

write_stock_config
OMARCHY_TEST_MONITOR_SCALE=1.25 run_scaling 1.6
grep -F "$(rule_auto eDP-1 2880 1800 120.0 1.6)" "$monitor_lua" >/dev/null ||
  fail "stock config gets a per-output rule for the scaled display" "$(cat "$monitor_lua")"
grep -Fx 'local omarchy_monitor_scale = 1.25' "$monitor_lua" >/dev/null ||
  fail "stock config keeps the shared default for the other displays" "$(cat "$monitor_lua")"
grep -Fx 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })' "$monitor_lua" >/dev/null ||
  fail "stock config leaves the catch-all untouched" "$(cat "$monitor_lua")"
pass "stock config scales one display, leaves the shared default for the others"

# The exact #6673 repro: scale display A, then display B; A must keep its
# scale and the shared default must never move.
write_stock_config
OMARCHY_TEST_MONITOR_SCALE=1.25 run_scaling 2
OMARCHY_TEST_MONITOR_SCALE=1.25 OMARCHY_TEST_MONITOR_NAME=HDMI-A-1 \
  OMARCHY_TEST_MONITOR_WIDTH=1920 OMARCHY_TEST_MONITOR_HEIGHT=1080 OMARCHY_TEST_MONITOR_REFRESH=60.0 \
  OMARCHY_TEST_MONITOR_X=2304 run_scaling 1
grep -F "$(rule_auto eDP-1 2880 1800 120.0 2)" "$monitor_lua" >/dev/null ||
  fail "first display keeps its own scale after the second scales" "$(cat "$monitor_lua")"
grep -F "$(rule_auto HDMI-A-1 1920 1080 60.0 1)" "$monitor_lua" >/dev/null ||
  fail "second display scaled independently" "$(cat "$monitor_lua")"
grep -Fx 'local omarchy_monitor_scale = 1.25' "$monitor_lua" >/dev/null ||
  fail "shared default stayed put through both scale changes" "$(cat "$monitor_lua")"
grep -Fx 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })' "$monitor_lua" >/dev/null ||
  fail "catch-all untouched after both scale changes" "$(cat "$monitor_lua")"
pass "scaling both displays in a stock config keeps each one's scale"

# A later scaling of the same output updates its rule in place rather than
# appending a duplicate.
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
local_rules=$(grep -cF 'output = "eDP-1"' "$monitor_lua")
[[ $local_rules == 1 ]] || fail "repeated scaling keeps one rule per output" "rules: $local_rules"
grep -F "$(rule_auto eDP-1 2880 1800 120.0 1.6)" "$monitor_lua" >/dev/null ||
  fail "repeated scaling updates the existing rule" "$(cat "$monitor_lua")"
grep -F "$(rule_auto HDMI-A-1 1920 1080 60.0 1)" "$monitor_lua" >/dev/null ||
  fail "repeated scaling on one output leaves the other's rule alone" "$(cat "$monitor_lua")"
pass "repeated scaling updates the existing per-output rule in place"

# A rule naming its own literal scale is updated in place, shared or not.
cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.5
hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0", scale = 1 })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 OMARCHY_TEST_MONITOR_NAME=DP-1 \
  OMARCHY_TEST_MONITOR_WIDTH=2560 OMARCHY_TEST_MONITOR_HEIGHT=1440 OMARCHY_TEST_MONITOR_REFRESH=144 run_scaling 1.25
grep -Fx 'hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0", scale = 1.25 })' "$monitor_lua" >/dev/null ||
  fail "an existing per-output rule is updated in place" "$(cat "$monitor_lua")"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "updating a per-output rule leaves the shared scale alone" "$(cat "$monitor_lua")"
rules=$(grep -cF 'output = "DP-1"' "$monitor_lua")
[[ $rules == 1 ]] || fail "in-place update does not append a duplicate rule" "rules: $rules"
pass "an existing per-output rule is updated in place"

# A rule deferring to the shared local decouples to a literal instead of
# moving the shared local (which other displays may share).
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 1
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 1.6
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.6 })' "$monitor_lua" >/dev/null ||
  fail "a deferring rule is pinned to the new scale" "$(cat "$monitor_lua")"
grep -Fx 'local omarchy_monitor_scale = 1' "$monitor_lua" >/dev/null ||
  fail "decoupling one output leaves the shared local put" "$(cat "$monitor_lua")"
pass "a rule deferring to the shared local is pinned instead of moved"

# A commented-out rule is not a rule: the live config still gets its rule.
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 1.5
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 1.6
grep -F "$(rule_auto eDP-1 2880 1800 120.0 1.6)" "$monitor_lua" >/dev/null ||
  fail "a commented-out rule does not block persisting" "$(cat "$monitor_lua")"
grep -Fx -- '-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })' "$monitor_lua" >/dev/null ||
  fail "a commented-out rule is left alone" "$(cat "$monitor_lua")"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "a commented-out rule does not trigger a shared-scale rewrite" "$(cat "$monitor_lua")"
pass "a commented-out rule does not stand in for a live rule"

# A non-scale argument must be rejected before hyprctl or the config is touched.
rm -f "$eval_out"
write_monitor_config
set +e
run_scaling abc; bad_status=$?
run_scaling 0.5; bad_status=$(( bad_status + $? ))
run_scaling 5; bad_status=$(( bad_status + $? ))
set -e
(( bad_status != 0 )) || fail "non-scale arguments are rejected"
[[ ! -e $eval_out ]] || fail "rejected arguments must not reach hyprctl" "$(cat "$eval_out")"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "rejected arguments leave the config alone" "$(cat "$monitor_lua")"
pass "non-scale arguments are rejected"

# Three-display stock layout: scaling one display leaves the other two's
# scales and rules alone.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=1 OMARCHY_TEST_MONITOR_NAME=DP-2 \
  OMARCHY_TEST_MONITOR_WIDTH=1920 OMARCHY_TEST_MONITOR_HEIGHT=1080 OMARCHY_TEST_MONITOR_REFRESH=60.0 \
  OMARCHY_TEST_MONITOR_X=2560 run_scaling 1.25
grep -F "$(rule_auto DP-2 1920 1080 60.0 1.25)" "$monitor_lua" >/dev/null ||
  fail "second display gets its own rule" "$(cat "$monitor_lua")"
OMARCHY_TEST_MONITOR_SCALE=1 OMARCHY_TEST_MONITOR_NAME=DP-1 \
  OMARCHY_TEST_MONITOR_WIDTH=2560 OMARCHY_TEST_MONITOR_HEIGHT=1440 OMARCHY_TEST_MONITOR_REFRESH=144.0 \
  OMARCHY_TEST_MONITOR_X=0 run_scaling 1.6
grep -F "$(rule_auto DP-1 2560 1440 144.0 1.6)" "$monitor_lua" >/dev/null ||
  fail "first display gets its own rule" "$(cat "$monitor_lua")"
grep -F "$(rule_auto DP-2 1920 1080 60.0 1.25)" "$monitor_lua" >/dev/null ||
  fail "scaling one display leaves the other's rule alone" "$(cat "$monitor_lua")"
OMARCHY_TEST_MONITOR_SCALE=1.25 OMARCHY_TEST_MONITOR_NAME=DP-2 \
  OMARCHY_TEST_MONITOR_WIDTH=1920 OMARCHY_TEST_MONITOR_HEIGHT=1080 OMARCHY_TEST_MONITOR_REFRESH=60.0 \
  OMARCHY_TEST_MONITOR_X=4096 run_scaling 1
grep -F "$(rule_auto DP-2 1920 1080 60.0 1)" "$monitor_lua" >/dev/null ||
  fail "rescaling updates the display's existing rule" "$(cat "$monitor_lua")"
dp2_rules=$(grep -cF 'output = "DP-2"' "$monitor_lua")
[[ $dp2_rules == 1 ]] || fail "rescaling does not duplicate the display's rule" "rules: $dp2_rules"
grep -F "$(rule_auto DP-1 2560 1440 144.0 1.6)" "$monitor_lua" >/dev/null ||
  fail "rescaling one display leaves the first display's rule alone" "$(cat "$monitor_lua")"
pass "a three-display layout scales each output independently"

# A pinned neighbor anchors the layout, so an unpinned output keeps the
# position Hyprland gave it rather than a stale or auto re-placement.
cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 1
hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "1920x0", scale = 1 })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 OMARCHY_TEST_MONITOR_NAME=DP-2 \
  OMARCHY_TEST_MONITOR_WIDTH=1920 OMARCHY_TEST_MONITOR_HEIGHT=1080 OMARCHY_TEST_MONITOR_REFRESH=60.0 \
  OMARCHY_TEST_MONITOR_X=3840 OMARCHY_TEST_MONITOR_Y=0 run_scaling 1.25
grep -F "$(rule_line DP-2 1920 1080 60.0 3840x0 1.25)" "$eval_out" >/dev/null ||
  fail "an unpinned output keeps its current position beside a pinned neighbor" "$(cat "$eval_out")"
pass "an unpinned output keeps its current position beside pinned neighbors"

# Output names match exactly: DP-1 is inside DP-14 as a substring, not as a name.
cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 1
hl.monitor({ output = "DP-14", mode = "2560x1440@144", position = "auto", scale = 1 })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 OMARCHY_TEST_MONITOR_NAME=DP-1 \
  OMARCHY_TEST_MONITOR_WIDTH=2560 OMARCHY_TEST_MONITOR_HEIGHT=1440 OMARCHY_TEST_MONITOR_REFRESH=144.0 run_scaling 1.25
grep -Fx 'hl.monitor({ output = "DP-14", mode = "2560x1440@144", position = "auto", scale = 1 })' "$monitor_lua" >/dev/null ||
  fail "scaling DP-1 leaves the DP-14 rule alone" "$(cat "$monitor_lua")"
grep -F "$(rule_auto DP-1 2560 1440 144.0 1.25)" "$monitor_lua" >/dev/null ||
  fail "scaling DP-1 lands a rule for DP-1" "$(cat "$monitor_lua")"
OMARCHY_TEST_MONITOR_SCALE=1.25 OMARCHY_TEST_MONITOR_NAME=DP-14 \
  OMARCHY_TEST_MONITOR_WIDTH=2560 OMARCHY_TEST_MONITOR_HEIGHT=1440 OMARCHY_TEST_MONITOR_REFRESH=144.0 run_scaling 1.6
grep -Fx 'hl.monitor({ output = "DP-14", mode = "2560x1440@144", position = "auto", scale = 1.6 })' "$monitor_lua" >/dev/null ||
  fail "scaling DP-14 updates its own rule" "$(cat "$monitor_lua")"
grep -F "$(rule_auto DP-1 2560 1440 144.0 1.25)" "$monitor_lua" >/dev/null ||
  fail "scaling DP-14 leaves the DP-1 rule alone" "$(cat "$monitor_lua")"
pass "output names match exactly, prefix or suffix"

# A symlinked monitors.lua keeps its link: writes land on the target file
# (omarchy#7625).
cat >"$home_dir/.config/hypr/monitors-real.lua" <<'LUA'
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.5
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
ln -sf monitors-real.lua "$monitor_lua"
run_scaling 1.25
grep -Fx 'local omarchy_monitor_scale = 1.5' "$home_dir/.config/hypr/monitors-real.lua" >/dev/null ||
  fail "a symlinked config leaves the shared local alone" "$(cat "$home_dir/.config/hypr/monitors-real.lua")"
grep -F "$(rule_auto eDP-1 2880 1800 120.0 1.25)" "$home_dir/.config/hypr/monitors-real.lua" >/dev/null ||
  fail "a symlinked config lands the rule on the target" "$(cat "$home_dir/.config/hypr/monitors-real.lua")"
[[ -L $monitor_lua ]] || fail "a symlinked config keeps its link"
sed -i -E 's/[0-9]+\.[0-9]+/1.5/' "$home_dir/.config/hypr/monitors-real.lua"
pass "a symlinked monitors.lua keeps its link"

# No monitors.lua at all: the runtime change still lands.
rm -f "$monitor_lua"
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
grep -F 'scale = 1.6' "$eval_out" >/dev/null || fail "monitor scaling applies without monitors.lua"
pass "monitor scaling applies without a config file"
