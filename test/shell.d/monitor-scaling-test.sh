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
  # The stub is a fresh process per call, so post-eval state travels through
  # the filesystem: the eval capture file doubles as the marker that the
  # verify-read should serve the after-eval JSON.
  if [[ -n ${OMARCHY_TEST_MONITORS_JSON_AFTER_EVAL:-} && -e ${OMARCHY_TEST_HYPRCTL_EVAL_OUT:-} ]]; then
    printf '%s' "$OMARCHY_TEST_MONITORS_JSON_AFTER_EVAL"
  elif [[ -n ${OMARCHY_TEST_MONITORS_JSON:-} ]]; then
    printf '%s' "$OMARCHY_TEST_MONITORS_JSON"
  else
    internal=$(printf '{"name":"eDP-1","focused":true,"scale":%s,"width":%s,"height":%s,"refreshRate":120.0,"x":0,"y":0,"transform":0,"description":"%s","make":"%s","model":"%s","serial":"%s"}' \
      "${OMARCHY_TEST_MONITOR_SCALE:-2}" \
      "${OMARCHY_TEST_MONITOR_WIDTH:-2880}" \
      "${OMARCHY_TEST_MONITOR_HEIGHT:-1800}" \
      "${OMARCHY_TEST_MONITOR_DESCRIPTION:-BOE NE180WUM}" \
      "${OMARCHY_TEST_MONITOR_MAKE:-BOE}" \
      "${OMARCHY_TEST_MONITOR_MODEL:-NE180WUM}" \
      "${OMARCHY_TEST_MONITOR_SERIAL:-0x00000001}")
    if [[ ${OMARCHY_TEST_EXTERNAL_MONITOR:-0} == "1" ]]; then
      printf '[%s,%s]' "$internal" \
        '{"name":"HDMI-A-1","focused":false,"scale":1.6,"width":1920,"height":1080,"refreshRate":144.0,"x":-1200,"y":0,"transform":0,"description":"Samsung C27JG5x","make":"Samsung","model":"C27JG5x","serial":"H4ZM800123"}'
    else
      printf '[%s]' "$internal"
    fi
  fi
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

# The dispatch guard skips the CLI when sourced, so the geometry function can
# be unit-called directly. Only recompute_monitor_position is exercised this
# way: set_scale and the dispatch arms exit on error paths, which would kill
# this test file.
source "$ROOT/bin/omarchy-hyprland-monitor-scaling"

write_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 2
LUA
}

# The shipped pairing: the generic catch-all handing omarchy_monitor_scale to
# unlisted outputs, plus a named rule for the internal panel. Persistence must
# rewrite the named rule in place and leave the catch-all and variable alone.
write_named_rule_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 2
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })
LUA
}

# A named rule that hands its scale to the shared variable: targeting pins the
# rule to a literal while the variable itself is left alone.
write_named_var_rule_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.5
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
}

# The nwg-displays shape: a rule spread over several lines. Only the scale
# line may change; every other line stays byte-identical.
write_multiline_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "auto",
  scale = 1.5
})
LUA
}

# A transform-only rule names no scale at all, so one is inserted inside the
# closing brace rather than appended as a new rule.
write_scaleless_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", transform = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# A rule keyed by a desc: selector (with stray spaces, as Hyprland tolerates)
# that prefix-matches the stubbed monitor description.
write_desc_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "desc:  Acme  ", mode = "preferred", position = "auto", scale = 1.5 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# A rule that only exists inside a line comment is not a rule.
write_commented_rule_config() {
  cat >"$monitor_lua" <<'LUA'
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# Nor is one fenced inside a multi-line --[[ ]] block comment.
write_block_comment_rule_config() {
  cat >"$monitor_lua" <<'LUA'
--[[
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })
]]
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# Nor is one fenced inside a levelled --[==[ ]==] block comment, which Lua
# treats exactly like --[[ ]] but only closes on the matching ]==].
write_levelled_comment_rule_config() {
  cat >"$monitor_lua" <<'LUA'
--[==[
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })
]==]
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# Nor is one sitting inside a levelled [=[ ]=] long string.
write_levelled_string_rule_config() {
  cat >"$monitor_lua" <<'LUA'
local s = [=[ hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 9 }) ]=]
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# A scale key inside a nested table is not the scale of the rule: only the
# top-level scale may be rewritten.
write_nested_scale_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", extra = { scale = 99, top = 24 }, scale = 1.5 })
LUA
}

# An output selector inside a nested table does not make the rule belong to
# that output either.
write_nested_output_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ extra = { output = "eDP-1" }, output = "DP-2", scale = 1.5 })
LUA
}

# A scale handed an expression is replaced whole: truncating at the comma
# inside the call would splice invalid Lua into the file.
write_expression_scale_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = math.max(1, 1.5) })
LUA
}

# The literal catch-all only: the scale belongs on an appended named rule, not
# on the rule every unlisted output shares.
write_literal_catch_all_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# A rule for a different monitor plus the catch-all, while the target is
# unlisted: only the append may happen.
write_other_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "-1200x0", scale = 1.6 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# The named target carrying its live position before the scale key: both
# fields are rewritten and the earlier position splice must not shift the
# scale span's offsets.
write_named_position_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "-1200x0", scale = 1.6 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# The reverse key order: the edit list must be safe in both directions.
write_named_scale_first_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "HDMI-A-1", mode = "preferred", scale = 1.6, position = "-1200x0" })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# An auto position re-derives on every reload, so nothing there can go stale
# and the value is never rewritten.
write_named_auto_position_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1.6 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# A position that references a local is pinned to the recomputed literal
# while the variable itself is left alone.
write_named_var_position_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_position = "-1200x0"
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = omarchy_monitor_position, scale = 1.6 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# A literal position inside a multi-line rule: the position and scale lines
# are rewritten, every other line stays byte-identical.
write_multiline_position_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({
  output = "HDMI-A-1",
  mode = "preferred",
  position = "-1200x0",
  scale = 1.6
})
LUA
}

run_scaling() {
  HOME="$home_dir" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    OMARCHY_TEST_MONITOR_SCALE="${OMARCHY_TEST_MONITOR_SCALE:-2}" \
    OMARCHY_TEST_MONITOR_DESCRIPTION="${OMARCHY_TEST_MONITOR_DESCRIPTION:-}" \
    OMARCHY_TEST_MONITOR_MAKE="${OMARCHY_TEST_MONITOR_MAKE:-}" \
    OMARCHY_TEST_MONITOR_MODEL="${OMARCHY_TEST_MONITOR_MODEL:-}" \
    OMARCHY_TEST_MONITOR_SERIAL="${OMARCHY_TEST_MONITOR_SERIAL:-}" \
    OMARCHY_TEST_EXTERNAL_MONITOR="${OMARCHY_TEST_EXTERNAL_MONITOR:-0}" \
    OMARCHY_TEST_MONITORS_JSON="${OMARCHY_TEST_MONITORS_JSON:-}" \
    OMARCHY_TEST_MONITORS_JSON_AFTER_EVAL="${OMARCHY_TEST_MONITORS_JSON_AFTER_EVAL:-}" \
    "$ROOT/bin/omarchy-hyprland-monitor-scaling" "$@"
}

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling up
grep -F 'scale = 3' "$eval_out" >/dev/null || fail "monitor scaling up reaches 3x"
grep -F 'position = "0x0"' "$eval_out" >/dev/null || fail "monitor scaling up keeps the live position"
! grep -F 'position = "auto"' "$eval_out" >/dev/null || fail "monitor scaling up never emits auto position"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 3 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling up persists 3x on an appended eDP-1 rule"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling up leaves the shared scale variable alone"
grep -F $'requested=up\tcurrent=2\tnew=3\tmonitor=eDP-1' "$scale_log" >/dev/null || fail "monitor scaling up writes audit log"
pass "monitor scaling up reaches 3x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=3 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down recovers 3x to 2x"
grep -F 'position = "0x0"' "$eval_out" >/dev/null || fail "monitor scaling down keeps the live position"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling down persists 2x from 3x"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling down leaves the shared scale variable alone"
pass "monitor scaling down recovers 3x to 2x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=3.0000000000000004 run_scaling down
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling down snaps floating point 3x to 2x"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling down persists 2x from floating point 3x"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling down leaves the shared scale variable alone"
pass "monitor scaling down snaps floating point 3x to 2x"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 3
grep -F 'scale = 3' "$eval_out" >/dev/null || fail "monitor scaling explicit 3x remains available"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 3 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling explicit 3x persists"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling explicit 3x leaves the shared scale variable alone"
grep -Fx 'local omarchy_gdk_scale = 3' "$monitor_lua" >/dev/null || fail "monitor scaling explicit 3x persists GDK scale"
pass "monitor scaling explicit 3x remains available"

# GTK only honors integer GDK_SCALE, so fractional monitor scales persist a
# rounded GDK scale.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.6
grep -F 'scale = 1.6' "$eval_out" >/dev/null || fail "monitor scaling explicit 1.6x remains available"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 1.6 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling explicit 1.6x persists"
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null || fail "monitor scaling 1.6x persists integer GDK scale 2"
pass "monitor scaling 1.6x persists integer GDK scale 2"

write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=2 run_scaling 1.25
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 1.25 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling explicit 1.25x persists"
grep -Fx 'local omarchy_gdk_scale = 1' "$monitor_lua" >/dev/null || fail "monitor scaling 1.25x persists integer GDK scale 1"
pass "monitor scaling 1.25x persists integer GDK scale 1"

# GDK_SCALE follows the densest monitor, not the scaled one: downscaling
# HDMI-A-1 to 1.25 leaves eDP-1's 2 as the max, where the old target-derived
# value would have written 1.
write_monitor_config
rm -f "$eval_out"
OMARCHY_TEST_EXTERNAL_MONITOR=1 run_scaling 1.25 HDMI-A-1
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling keeps GDK_SCALE at the densest monitor's scale"
pass "monitor scaling derives GDK_SCALE from the densest monitor"

# With every monitor at or below 1.25 the max rounds half up to 1. The HDMI
# right edge (-80) sits 80px clear of eDP-1's left edge, so the recompute
# leaves both positions untouched and quiet.
write_monitor_config
rm -f "$eval_out"
OMARCHY_TEST_MONITORS_JSON='[{"name":"eDP-1","focused":true,"scale":1.25,"width":2880,"height":1800,"refreshRate":120.0,"x":0,"y":0,"transform":0},{"name":"HDMI-A-1","focused":false,"scale":1,"width":1920,"height":1080,"refreshRate":144.0,"x":-2000,"y":0,"transform":0}]' \
  run_scaling 1.25 eDP-1
grep -Fx 'local omarchy_gdk_scale = 1' "$monitor_lua" >/dev/null ||
  fail "monitor scaling rounds a sub-1.5 max GDK_SCALE to 1"
pass "monitor scaling rounds the max monitor scale for GDK_SCALE"

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
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "1280x800@120.0", position = "0x0", scale = 3.2 })' "$monitor_lua" >/dev/null ||
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
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "1280x804@120.0", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling down persists 2x after skipping duplicate approximation"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling down leaves the shared scale variable alone"
pass "monitor scaling down skips duplicate approximation"

# A monitor with its own hl.monitor() rule gets the scale rewritten in place:
# no appended line, and neither the catch-all nor the variable is touched.
write_named_rule_config
run_scaling 2
grep -F 'position = "0x0"' "$eval_out" >/dev/null || fail "monitor scaling a named rule keeps the live position"
! grep -F 'position = "auto"' "$eval_out" >/dev/null || fail "monitor scaling a named rule never emits auto position"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling rewrites the monitor's own rule in place"
(( $(grep -c 'hl\.monitor' "$monitor_lua") == 2 )) ||
  fail "monitor scaling rewrites in place rather than appending a second rule"
grep -Fx 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the catch-all rule untouched"
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the shared scale variable alone"
pass "monitor scaling rewrites the monitor's own hl.monitor rule"

# A named rule that references the shared variable gets the literal new scale;
# the variable itself is not the persistence target anymore.
write_named_var_rule_config
run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling pins a variable-referencing rule to the new scale"
grep -Fx 'local omarchy_monitor_scale = 1.5' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the shared scale variable alone"
(( $(grep -c 'hl\.monitor' "$monitor_lua") == 1 )) ||
  fail "monitor scaling rewrites in place rather than appending a second rule"
pass "monitor scaling pins a variable-referencing rule to the new scale"

# A multi-line rule is rewritten inside its block; every other line stays
# byte-identical.
write_multiline_rule_config
run_scaling 2
grep -Fx '  scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling rewrites the scale line inside a multi-line rule"
grep -Fx '  output = "eDP-1",' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the other lines of a multi-line rule alone"
grep -Fx 'hl.monitor({' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the opening line of a multi-line rule alone"
(( $(grep -c 'hl\.monitor' "$monitor_lua") == 1 )) ||
  fail "monitor scaling rewrites a multi-line rule in place"
pass "monitor scaling rewrites a multi-line rule in place"

# A rule without a scale key gets one inserted inside the closing brace, not
# appended as a separate line.
write_scaleless_rule_config
run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", transform = 1, scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling inserts scale into a rule that has none"
(( $(grep -c 'hl\.monitor' "$monitor_lua") == 2 )) ||
  fail "monitor scaling inserts into the rule rather than appending a new line"
pass "monitor scaling inserts scale into a rule that has none"

# A desc:-keyed rule whose trimmed selector prefix-matches the monitor
# description is rewritten in place, selector preserved.
write_desc_rule_config
OMARCHY_TEST_MONITOR_DESCRIPTION="Acme Display 3000" run_scaling 2
grep -Fx 'hl.monitor({ output = "desc:  Acme  ", mode = "preferred", position = "auto", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling rewrites a desc:-keyed rule in place"
(( $(grep -c 'hl\.monitor' "$monitor_lua") == 2 )) ||
  fail "monitor scaling rewrites a desc: rule rather than appending"
pass "monitor scaling rewrites a desc:-keyed rule in place"

# A rule that only exists inside a line comment is not a rule: it is left
# alone and the monitor gets an appended named line instead.
write_commented_rule_config
run_scaling 2
grep -Fx -- '-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves a commented-out rule alone"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling appends a named rule when only a comment names the output"
pass "monitor scaling ignores a commented-out rule and appends"

# Same for a rule fenced inside a multi-line --[[ ]] block comment.
write_block_comment_rule_config
run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves a block-commented rule alone"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling appends a named rule when only a block comment names the output"
pass "monitor scaling ignores a block-commented rule and appends"

# Same for a rule fenced inside a levelled --[==[ ]==] block comment: it is
# dead text, left byte-identical, and a named rule is appended for the
# monitor.
write_levelled_comment_rule_config
run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves a levelled-comment rule alone"
grep -Fx -- ']==]' "$monitor_lua" >/dev/null ||
  fail "monitor scaling keeps the levelled comment's closing bracket"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling appends a named rule when only a levelled comment names the output"
pass "monitor scaling ignores a levelled-comment rule and appends"

# Same for a rule inside a levelled [=[ ]=] long string: string contents are
# not keys, so the line is left alone and a named rule is appended.
write_levelled_string_rule_config
run_scaling 2
grep -Fx 'local s = [=[ hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 9 }) ]=]' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves a levelled long string byte-identical"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling appends a named rule when only a long string names the output"
pass "monitor scaling ignores a levelled-string rule and appends"

# A scale key inside a nested table is not the scale of the rule: the
# top-level scale is rewritten and the nested one stays byte-identical.
write_nested_scale_rule_config
run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", extra = { scale = 99, top = 24 }, scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling rewrites only the top-level scale of the rule"
(( $(grep -c 'hl\.monitor' "$monitor_lua") == 1 )) ||
  fail "monitor scaling rewrites a nested-scale rule in place"
pass "monitor scaling rewrites only the top-level scale of the rule"

# An output selector inside a nested table does not make the rule belong to
# eDP-1: the DP-2 rule stays byte-identical and a named rule is appended.
write_nested_output_rule_config
run_scaling 2
grep -Fx 'hl.monitor({ extra = { output = "eDP-1" }, output = "DP-2", scale = 1.5 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling does not take a nested output key as the selector of the rule"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling appends a named rule when only a nested table names the output"
pass "monitor scaling ignores a nested table output selector"

# A scale handed an expression is replaced whole: the comma inside the call
# must not truncate the value and leave invalid Lua behind.
write_expression_scale_rule_config
run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling replaces an expression-valued scale whole"
! grep -F '1.5)' "$monitor_lua" >/dev/null ||
  fail "monitor scaling does not leave the tail of an expression scale behind"
pass "monitor scaling replaces an expression-valued scale whole"

# A literal catch-all is never the persistence target either: the named
# append wins over it and the catch-all stays byte-identical.
write_literal_catch_all_config
run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling appends a named rule over a literal catch-all"
grep -Fx 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the literal catch-all byte-identical"
pass "monitor scaling appends a named rule over a literal catch-all"

# An unlisted target with another monitor's rule present appends only; the
# other rule stays byte-identical.
write_other_monitor_config
run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120.0", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling appends a rule for the unlisted target"
grep -Fx 'hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "-1200x0", scale = 1.6 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the other monitor's rule byte-identical"
pass "monitor scaling appends a rule for the unlisted target"

# Every write leaves a timestamped backup of the pre-run content.
write_named_rule_config
rm -f "$monitor_lua".bak.*
cp -- "$monitor_lua" "$test_tmp/pre-run.lua"
run_scaling 2
backup=$(compgen -G "$monitor_lua.bak.*") ||
  fail "monitor scaling writes a timestamped backup"
(( $(compgen -G "$monitor_lua.bak.*" | wc -l) == 1 )) ||
  fail "monitor scaling writes exactly one backup per run"
cmp -s "$backup" "$test_tmp/pre-run.lua" ||
  fail "monitor scaling backup preserves the pre-run content"
pass "monitor scaling backs up monitors.lua before writing"

# A symlinked monitors.lua stays a symlink and the write lands through it.
write_named_rule_config
real_lua="$home_dir/.config/hypr/monitors-real.lua"
mv "$monitor_lua" "$real_lua"
ln -s "$real_lua" "$monitor_lua"
run_scaling 2
[[ -L $monitor_lua ]] || fail "monitor scaling keeps a symlinked monitors.lua a symlink"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 2 })' "$real_lua" >/dev/null ||
  fail "monitor scaling writes through the symlink to the real file"
pass "monitor scaling writes through a symlinked monitors.lua"

# A named target monitor gets the live apply and the persisted append keyed to
# its own name, and the audit log records it. Its right edge touches eDP-1's
# left edge, so the recomputed position keeps them adjacent at the new size
# (1920/2.5 = 768 -> -768x0).
write_monitor_config
rm -f "$eval_out" "$scale_log"
OMARCHY_TEST_EXTERNAL_MONITOR=1 run_scaling 2.5 HDMI-A-1
grep -F 'output = "HDMI-A-1"' "$eval_out" >/dev/null || fail "targeted scaling evals the named monitor"
grep -F 'position = "-768x0"' "$eval_out" >/dev/null || fail "targeted scaling keeps the adjacent edge touching"
grep -Fx 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@144.0", position = "-768x0", scale = 2.5 })' "$monitor_lua" >/dev/null ||
  fail "targeted scaling persists an appended rule for the named monitor"
! grep -F 'output = "eDP-1"' "$monitor_lua" >/dev/null ||
  fail "targeted scaling does not write a rule for the focused monitor"
grep -F 'monitor=HDMI-A-1' "$scale_log" >/dev/null || fail "targeted scaling audits the named monitor"
pass "monitor scaling targets a named monitor"

# Stepping a named monitor reads that monitor's scale (1.6 -> 2), not the
# focused monitor's (2 -> 3), and the recomputed position tracks the new
# logical width (1920/2 = 960 -> -960x0).
write_monitor_config
rm -f "$eval_out"
OMARCHY_TEST_EXTERNAL_MONITOR=1 run_scaling up HDMI-A-1
grep -F 'output = "HDMI-A-1"' "$eval_out" >/dev/null || fail "targeted stepping evals the named monitor"
grep -F 'scale = 2 ' "$eval_out" >/dev/null || fail "targeted stepping reads the target's scale, not the focused one"
grep -F 'position = "-960x0"' "$eval_out" >/dev/null || fail "targeted stepping keeps the adjacent edge touching"
! grep -F 'scale = 3 ' "$eval_out" >/dev/null || fail "targeted stepping does not step the focused monitor"
pass "monitor scaling steps the named monitor's scale"

# A named rule holding the live position gets both fields rewritten in place
# with position before scale: the earlier position splice must not leave the
# scale edit pointing at stale bytes.
write_named_position_rule_config
rm -f "$eval_out"
OMARCHY_TEST_EXTERNAL_MONITOR=1 run_scaling 2.5 HDMI-A-1
grep -Fx 'hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "-768x0", scale = 2.5 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling rewrites position and scale with position first"
(( $(grep -c 'hl\.monitor' "$monitor_lua") == 2 )) ||
  fail "monitor scaling rewrites position in place rather than appending"
pass "monitor scaling rewrites position before scale in place"

# The reverse key order must land identically: edits apply highest-offset-
# first regardless of which key precedes the other.
write_named_scale_first_rule_config
rm -f "$eval_out"
OMARCHY_TEST_EXTERNAL_MONITOR=1 run_scaling 2.5 HDMI-A-1
grep -Fx 'hl.monitor({ output = "HDMI-A-1", mode = "preferred", scale = 2.5, position = "-768x0" })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling rewrites position and scale with scale first"
pass "monitor scaling rewrites scale before position in place"

# An auto position re-derives on every reload, so the moved monitor's rule
# keeps "auto" verbatim while the scale still lands.
write_named_auto_position_config
rm -f "$eval_out"
OMARCHY_TEST_EXTERNAL_MONITOR=1 run_scaling 2.5 HDMI-A-1
grep -Fx 'hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 2.5 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves an auto position verbatim"
pass "monitor scaling never rewrites an auto position"

# A variable-referencing position is pinned to the recomputed literal while
# the variable itself stays byte-identical.
write_named_var_position_config
rm -f "$eval_out"
OMARCHY_TEST_EXTERNAL_MONITOR=1 run_scaling 2.5 HDMI-A-1
grep -Fx 'hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "-768x0", scale = 2.5 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling pins a variable position to the recomputed literal"
grep -Fx 'local omarchy_monitor_position = "-1200x0"' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the position variable alone"
pass "monitor scaling rewrites a variable position to a literal"

# Inside a multi-line rule the position line is rewritten in place and every
# other line stays byte-identical.
write_multiline_position_rule_config
rm -f "$eval_out"
OMARCHY_TEST_EXTERNAL_MONITOR=1 run_scaling 2.5 HDMI-A-1
grep -Fx '  position = "-768x0",' "$monitor_lua" >/dev/null ||
  fail "monitor scaling rewrites the position line inside a multi-line rule"
grep -Fx '  scale = 2.5' "$monitor_lua" >/dev/null ||
  fail "monitor scaling rewrites the scale line inside a multi-line rule"
grep -Fx '  output = "HDMI-A-1",' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the other lines of a multi-line rule alone"
(( $(grep -c 'hl\.monitor' "$monitor_lua") == 1 )) ||
  fail "monitor scaling rewrites a multi-line rule in place"
pass "monitor scaling rewrites position inside a multi-line rule"

# When the recompute lands on the live position the position text is never
# churned: scaling 1.6 -> 1.6 keeps -1200x0 byte-identical.
write_named_position_rule_config
rm -f "$eval_out"
OMARCHY_TEST_EXTERNAL_MONITOR=1 run_scaling 1.6 HDMI-A-1
grep -Fx 'hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "-1200x0", scale = 1.6 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling does not churn an unchanged position"
pass "monitor scaling leaves an unchanged position byte-identical"

# A monitor arg absent from hyprctl fails before any eval or write.
write_named_rule_config
rm -f "$eval_out"
cp -- "$monitor_lua" "$test_tmp/pre-run.lua"
set +e
run_scaling 2 DP-9 >/dev/null 2>&1
status=$?
set -e
(( status != 0 )) || fail "monitor scaling rejects an unknown monitor name"
[[ ! -e $eval_out ]] || fail "an unknown monitor is never eval'd"
cmp -s "$monitor_lua" "$test_tmp/pre-run.lua" || fail "an unknown monitor leaves monitors.lua untouched"
pass "monitor scaling rejects an unknown monitor"

# A monitor arg with Lua metacharacters fails the same way: no eval, no write.
write_named_rule_config
rm -f "$eval_out"
cp -- "$monitor_lua" "$test_tmp/pre-run.lua"
set +e
run_scaling 2 'eDP-1" })os.execute("calc")--' >/dev/null 2>&1
status=$?
set -e
(( status != 0 )) || fail "monitor scaling rejects a monitor arg with Lua metacharacters"
[[ ! -e $eval_out ]] || fail "an unsafe monitor arg is never eval'd"
cmp -s "$monitor_lua" "$test_tmp/pre-run.lua" || fail "an unsafe monitor arg leaves monitors.lua untouched"
pass "monitor scaling refuses an unsafe monitor name"

# More than two arguments is a usage error.
write_monitor_config
rm -f "$eval_out"
set +e
run_scaling 2 eDP-1 extra 2>"$test_tmp/stderr"
status=$?
set -e
(( status != 0 )) || fail "monitor scaling rejects more than two arguments"
grep -F 'Usage:' "$test_tmp/stderr" >/dev/null || fail "monitor scaling prints usage for extra arguments"
[[ ! -e $eval_out ]] || fail "extra arguments are never eval'd"
pass "monitor scaling rejects extra arguments"

# The bare invocation keeps the monitor-state contract: exactly the focused
# monitor's scale on stdout.
scale=$(run_scaling)
[[ $scale == "2" ]] || fail "bare scaling still reports the focused monitor's scale" "actual: $scale"
pass "monitor scaling bare call reports the focused scale"

# --- recompute_monitor_position unit layer -------------------------------
# The sourced function is pure: JSON in, "XxY kind dropped" out, status codes
# only for unusable input.

# A left-adjacent monitor keeps its right edge pinned to the neighbor's left
# edge as the logical width grows (1920/1.5 = 1280).
monitors_json='[{"name":"eDP-1","x":0,"y":0,"width":2880,"height":1800,"scale":2},{"name":"HDMI-A-1","x":-1200,"y":0,"width":1920,"height":1080,"scale":1.6}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 1.5)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a left-adjacent grow"
[[ $pos == "-1280x0 adjacency -" ]] || fail "recompute keeps the left-adjacent edge touching on grow" "actual: $pos"
pass "recompute keeps left-adjacent monitor touching on grow"

# Shrinking the logical width pulls the monitor in rather than stranding a
# dead gap (1920/2 = 960).
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a left-adjacent shrink"
[[ $pos == "-960x0 adjacency -" ]] || fail "recompute keeps the left-adjacent edge touching on shrink" "actual: $pos"
pass "recompute keeps left-adjacent monitor touching on shrink"

# A deliberate 50px gap (target right edge -50, neighbor left edge 0) survives
# a shrink verbatim: the stored coordinate is preserved exactly.
monitors_json='[{"name":"eDP-1","x":0,"y":0,"width":2880,"height":1800,"scale":2},{"name":"HDMI-A-1","x":-1250,"y":0,"width":1920,"height":1080,"scale":1.6}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a deliberate gap"
[[ $pos == "-1250x0 unchanged -" ]] || fail "recompute preserves a deliberate gap verbatim" "actual: $pos"
pass "recompute preserves a deliberate gap verbatim"

# A lone monitor has no adjacency to preserve: live position, unchanged.
monitors_json='[{"name":"eDP-1","x":0,"y":0,"width":2880,"height":1800,"scale":2}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "eDP-1" 1.5)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a single monitor"
[[ $pos == "0x0 unchanged -" ]] || fail "recompute leaves a single monitor at its live position" "actual: $pos"
pass "recompute leaves a single monitor unchanged"

# A right-of monitor keeps its left edge pinned to the neighbor's right edge
# and extends right as it grows.
monitors_json='[{"name":"eDP-1","x":0,"y":0,"width":2880,"height":1800,"scale":2},{"name":"HDMI-A-1","x":1440,"y":0,"width":1920,"height":1080,"scale":1.6}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a right-of monitor"
[[ $pos == "1440x0 adjacency -" ]] || fail "recompute pins the left edge of a right-of monitor" "actual: $pos"
pass "recompute pins the left edge of a right-of monitor"

# A monitor stacked above keeps its bottom edge pinned to the neighbor's top
# edge (540-tall after 1080/2 -> y = 675 - 540 = 135).
monitors_json='[{"name":"eDP-1","x":0,"y":675,"width":2880,"height":1800,"scale":2},{"name":"HDMI-A-1","x":0,"y":0,"width":1920,"height":1080,"scale":1.6}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for an above monitor"
[[ $pos == "0x135 adjacency -" ]] || fail "recompute keeps an above monitor touching" "actual: $pos"
pass "recompute keeps an above-adjacent monitor touching"

# A monitor stacked below keeps its top edge pinned to the neighbor's bottom
# edge; only its height shrinks.
monitors_json='[{"name":"eDP-1","x":0,"y":0,"width":2880,"height":1800,"scale":2},{"name":"HDMI-A-1","x":0,"y":900,"width":1920,"height":1080,"scale":1.6}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a below monitor"
[[ $pos == "0x900 adjacency -" ]] || fail "recompute keeps a below monitor touching" "actual: $pos"
pass "recompute keeps a below-adjacent monitor touching"

# Near-touching edges within the 5px tolerance normalize to touching: a 5px
# gap and a 5px overlap both pull to -960x0 at scale 2.
for live_x in -1205 -1195 -1201 -1199; do
  monitors_json="[{\"name\":\"eDP-1\",\"x\":0,\"y\":0,\"width\":2880,\"height\":1800,\"scale\":2},{\"name\":\"HDMI-A-1\",\"x\":${live_x},\"y\":0,\"width\":1920,\"height\":1080,\"scale\":1.6}]"
  set +e
  pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
  status=$?
  set -e
  (( status == 0 )) || fail "recompute returns success at live_x=$live_x"
  [[ $pos == "-960x0 adjacency -" ]] || fail "recompute normalizes a near-touching edge at live_x=$live_x" "actual: $pos"
done
pass "recompute normalizes edges within the 5px tolerance"

# One step outside the tolerance in either direction is a deliberate layout:
# the coordinate is preserved verbatim.
for live_x in -1206 -1194; do
  monitors_json="[{\"name\":\"eDP-1\",\"x\":0,\"y\":0,\"width\":2880,\"height\":1800,\"scale\":2},{\"name\":\"HDMI-A-1\",\"x\":${live_x},\"y\":0,\"width\":1920,\"height\":1080,\"scale\":1.6}]"
  set +e
  pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
  status=$?
  set -e
  (( status == 0 )) || fail "recompute returns success at live_x=$live_x"
  [[ $pos == "${live_x}x0 unchanged -" ]] || fail "recompute preserves an edge beyond the tolerance at live_x=$live_x" "actual: $pos"
done
pass "recompute preserves edges beyond the 5px tolerance"

# A neighbor whose reported scale carries float noise (1.3333334 -> logical
# width 1440.0000x) still counts as adjacent after logical dims round.
monitors_json='[{"name":"DP-2","x":0,"y":0,"width":1920,"height":1080,"scale":1.3333334},{"name":"HDMI-A-1","x":1440,"y":0,"width":1920,"height":1080,"scale":1.6}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success beside a float-noise neighbor"
[[ $pos == "1440x0 adjacency -" ]] || fail "recompute sees adjacency through reported-scale float noise" "actual: $pos"
pass "recompute sees adjacency through reported-scale float noise"

# Sandwiched between two neighbors with unequal shared edges, the larger one
# wins (240 = 1200 - 960) and the sacrificed side lands in the dropped field.
monitors_json='[{"name":"DP-1","x":-800,"y":0,"width":800,"height":600,"scale":1},{"name":"HDMI-A-1","x":0,"y":0,"width":1920,"height":1080,"scale":1.6},{"name":"eDP-1","x":1200,"y":0,"width":1920,"height":1080,"scale":1}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a sandwich"
[[ $pos == "240x0 adjacency right-of" ]] || fail "recompute anchors a sandwich to the largest shared edge" "actual: $pos"
pass "recompute anchors a sandwich to the largest shared edge"

# On a tie the target's own top-left edge stays fixed: the right-of candidate
# (x = 0, the live position) wins and the sacrificed left-of is recorded.
monitors_json='[{"name":"DP-1","x":-800,"y":0,"width":800,"height":675,"scale":1},{"name":"HDMI-A-1","x":0,"y":0,"width":1920,"height":1080,"scale":1.6},{"name":"eDP-1","x":1200,"y":0,"width":1920,"height":1080,"scale":1}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a tied sandwich"
[[ $pos == "0x0 adjacency left-of" ]] || fail "recompute ties a sandwich toward the top-left edge" "actual: $pos"
pass "recompute ties a sandwich toward the top-left edge"

# Two different neighbors touching the same edge both lose to the larger
# right-side share, but the sacrificed side is listed once.
monitors_json='[{"name":"DP-1","x":-800,"y":0,"width":800,"height":400,"scale":1},{"name":"DP-2","x":-500,"y":400,"width":500,"height":275,"scale":1},{"name":"HDMI-A-1","x":0,"y":0,"width":1920,"height":1080,"scale":1.6},{"name":"eDP-1","x":1200,"y":0,"width":1920,"height":1080,"scale":1}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a doubled-up edge"
[[ $pos == "240x0 adjacency right-of" ]] || fail "recompute dedupes a sacrificed side shared by two neighbors" "actual: $pos"
pass "recompute dedupes a sacrificed side shared by two neighbors"

# A recompute whose picked position would overlap a third monitor (DP-1)
# aborts to the live coordinates: never a worse state than doing nothing.
monitors_json='[{"name":"eDP-1","x":0,"y":0,"width":2880,"height":1800,"scale":2},{"name":"HDMI-A-1","x":-1200,"y":0,"width":1920,"height":1080,"scale":1.6},{"name":"DP-1","x":-2000,"y":0,"width":790,"height":400,"scale":1},{"name":"DP-2","x":-1100,"y":675,"width":1100,"height":800,"scale":1}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 1.5)
status=$?
set -e
(( status == 0 )) || fail "recompute aborts in-band, not by status"
[[ $pos == "-1200x0 abort -" ]] || fail "recompute aborts to live coords on a new overlap" "actual: $pos"
pass "recompute aborts to live coords on a new overlap"

# A floating monitor whose growth would overlap a non-adjacent neighbor gets
# the smallest separating move: -1280 (delta 30) beats 1440 (delta 2690).
monitors_json='[{"name":"eDP-1","x":0,"y":0,"width":2880,"height":1800,"scale":2},{"name":"HDMI-A-1","x":-1250,"y":0,"width":1920,"height":1080,"scale":1.6}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 1.5)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a growth clamp"
[[ $pos == "-1280x0 clamp -" ]] || fail "recompute clamps growth into a non-adjacent monitor" "actual: $pos"
pass "recompute clamps growth into a non-adjacent monitor"

# A portrait target (transform = 1) swaps its pixel axes before scaling:
# 1080/2 = 540 logical width, so the pinned right edge lands at -540x0.
monitors_json='[{"name":"eDP-1","x":0,"y":0,"width":2880,"height":1800,"scale":2},{"name":"HDMI-A-1","x":-675,"y":0,"width":1920,"height":1080,"scale":1.6,"transform":1}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success for a portrait target"
[[ $pos == "-540x0 adjacency -" ]] || fail "recompute swaps a portrait target's axes" "actual: $pos"
pass "recompute swaps a portrait target's axes"

# A portrait neighbor's swapped width feeds the adjacency math: 1920 logical
# wide, so the right-of target keeps x = 1920.
monitors_json='[{"name":"DP-2","x":0,"y":0,"width":1080,"height":1920,"scale":1,"transform":1},{"name":"HDMI-A-1","x":1920,"y":0,"width":1920,"height":1080,"scale":1.6}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "HDMI-A-1" 2)
status=$?
set -e
(( status == 0 )) || fail "recompute returns success beside a portrait neighbor"
[[ $pos == "1920x0 adjacency -" ]] || fail "recompute swaps a portrait neighbor's axes" "actual: $pos"
pass "recompute swaps a portrait neighbor's axes"

# A target absent from the monitor array is unusable input: non-zero status
# (never an exit -- this file is sourced) and no output line.
monitors_json='[{"name":"eDP-1","x":0,"y":0,"width":2880,"height":1800,"scale":2}]'
set +e
pos=$(recompute_monitor_position "$monitors_json" "DP-9" 2)
status=$?
set -e
(( status != 0 )) || fail "recompute rejects a target absent from the monitor array"
[[ -z $pos ]] || fail "recompute prints nothing for an absent target" "actual: $pos"
pass "recompute rejects a target absent from the monitor array"

# --- end-to-end: atomic eval, verify-read, and audit fields ---------------

# Scale and the recomputed position ride in a single eval call: the capture
# file holds exactly one line carrying both fields.
write_monitor_config
rm -f "$eval_out" "$scale_log"
OMARCHY_TEST_EXTERNAL_MONITOR=1 run_scaling 2.5 HDMI-A-1
(( $(wc -l <"$eval_out") == 1 )) || fail "monitor scaling applies scale and position in one eval"
grep -Fx 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@144.0", position = "-768x0", scale = 2.5 })' "$eval_out" >/dev/null ||
  fail "monitor scaling evals scale and recomputed position together"
pass "monitor scaling applies scale and position in one atomic eval"

# The post-eval verify-read catches an applied scale that diverges from the
# computed one: the stub serves scale 1.9 after the eval, and the audit line
# carries note=scale-divergence with pos= and note= appended at line end.
write_monitor_config
rm -f "$eval_out" "$scale_log"
OMARCHY_TEST_MONITORS_JSON='[{"name":"eDP-1","focused":true,"scale":2,"width":2880,"height":1800,"refreshRate":120.0,"x":0,"y":0,"transform":0}]' \
OMARCHY_TEST_MONITORS_JSON_AFTER_EVAL='[{"name":"eDP-1","focused":true,"scale":1.9,"width":2880,"height":1800,"refreshRate":120.0,"x":0,"y":0,"transform":0}]' \
  run_scaling 2.5 eDP-1
grep -F 'note=scale-divergence' "$scale_log" >/dev/null ||
  fail "monitor scaling audits an applied scale that diverges from the computed one"
grep -E $'\tpos=0x0\tnote=scale-divergence$' "$scale_log" >/dev/null ||
  fail "monitor scaling appends pos= and note= after grandparent= at line end"
pass "monitor scaling audits a diverged applied scale"

# A recompute that would create a new overlap aborts to the live position:
# the eval replays -1200x0 and the audit log records pos=-1200x0 note=abort.
write_monitor_config
rm -f "$eval_out" "$scale_log"
OMARCHY_TEST_MONITORS_JSON='[{"name":"eDP-1","focused":true,"x":0,"y":0,"width":2880,"height":1800,"scale":2,"refreshRate":120.0},{"name":"HDMI-A-1","focused":false,"x":-1200,"y":0,"width":1920,"height":1080,"scale":1.6,"refreshRate":144.0},{"name":"DP-1","focused":false,"x":-2000,"y":0,"width":790,"height":400,"scale":1,"refreshRate":60.0},{"name":"DP-2","focused":false,"x":-1100,"y":675,"width":1100,"height":800,"scale":1,"refreshRate":60.0}]' \
  run_scaling 1.5 HDMI-A-1
grep -F 'position = "-1200x0"' "$eval_out" >/dev/null || fail "monitor scaling aborts to the live position in the eval"
grep -F 'pos=-1200x0' "$scale_log" >/dev/null || fail "monitor scaling audits the live position on abort"
grep -F 'note=abort' "$scale_log" >/dev/null || fail "monitor scaling audits an aborted recompute"
pass "monitor scaling audits a recompute abort"

# A sandwiched monitor records the sacrificed adjacency side in the audit
# log: keeping the larger left-of edge drops the right-of neighbor.
write_monitor_config
rm -f "$eval_out" "$scale_log"
OMARCHY_TEST_MONITORS_JSON='[{"name":"DP-1","focused":false,"x":-800,"y":0,"width":800,"height":600,"scale":1,"refreshRate":60.0},{"name":"HDMI-A-1","focused":false,"x":0,"y":0,"width":1920,"height":1080,"scale":1.6,"refreshRate":144.0},{"name":"eDP-1","focused":true,"x":1200,"y":0,"width":1920,"height":1080,"scale":1,"refreshRate":120.0}]' \
  run_scaling 2 HDMI-A-1
grep -F 'note=adjacency,drop-right-of' "$scale_log" >/dev/null ||
  fail "monitor scaling audits the sacrificed adjacency side"
grep -F 'pos=240x0' "$scale_log" >/dev/null || fail "monitor scaling audits the recomputed position"
pass "monitor scaling audits a sacrificed adjacency side"

# A rotated target keeps its transform in the eval and on the appended rule
# instead of being silently un-rotated.
write_monitor_config
rm -f "$eval_out"
OMARCHY_TEST_MONITORS_JSON='[{"name":"eDP-1","focused":true,"scale":1,"width":1920,"height":1080,"refreshRate":120.0,"x":0,"y":0,"transform":1,"description":"BOE","make":"BOE","model":"X","serial":"0x1"}]' \
  run_scaling 2 eDP-1
grep -F 'transform = 1' "$eval_out" >/dev/null || fail "monitor scaling replays a nonzero transform in the eval"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "1920x1080@120.0", position = "0x0", scale = 2, transform = 1 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists transform on an appended rule"
pass "monitor scaling replays and persists a nonzero transform"
