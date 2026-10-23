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
  printf '[{"name":"eDP-1","focused":true,"scale":%s,"width":%s,"height":%s,"refreshRate":120.0,"x":%s,"y":%s}]' \
    "${OMARCHY_TEST_MONITOR_SCALE:-2}" "${OMARCHY_TEST_MONITOR_WIDTH:-2880}" "${OMARCHY_TEST_MONITOR_HEIGHT:-1800}" \
    "${OMARCHY_TEST_MONITOR_X:-0}" "${OMARCHY_TEST_MONITOR_Y:-0}"
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

# An explicit multi-monitor layout keeps its position instead of resetting
# to "auto", so a scale change does not collapse side-by-side outputs.
write_monitor_config
OMARCHY_TEST_MONITOR_SCALE=1 OMARCHY_TEST_MONITOR_WIDTH=1920 OMARCHY_TEST_MONITOR_HEIGHT=1080 \
  OMARCHY_TEST_MONITOR_X=1920 OMARCHY_TEST_MONITOR_Y=0 run_scaling 1
grep -F 'position = "1920x0"' "$eval_out" >/dev/null || fail "monitor scaling preserves the explicit monitor position"
pass "monitor scaling preserves the explicit monitor position"

# The mode keeps the current refresh rate; without one Hyprland requests 60Hz.
grep -E 'mode = "1920x1080@120(\.0)?"' "$eval_out" >/dev/null || fail "monitor scaling keeps the current refresh rate"
pass "monitor scaling keeps the current refresh rate"

# An explicit per-output entry keeps its own scale, so the change survives
# a reload instead of reverting to the stale explicit value.
cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
hl.monitor({ output = "eDP-1", mode = "2880x1800", position = "0x0", scale = 1 })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800", position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists into the explicit per-output entry"
grep -Fx 'local omarchy_monitor_scale = 1' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the generic catch-all alone with an explicit entry present"
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists integer GDK scale with an explicit entry present"
pass "monitor scaling persists into the explicit per-output entry"

# An explicit entry that reads the shared variable is persisted through it.
cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
hl.monitor({ output = "eDP-1", mode = "2880x1800@120", position = "0x0", scale = omarchy_monitor_scale })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists through an explicit entry that reads omarchy_monitor_scale"
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "2880x1800@120", position = "0x0", scale = omarchy_monitor_scale })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves an explicit entry that reads omarchy_monitor_scale intact"
pass "monitor scaling persists through an explicit entry that reads omarchy_monitor_scale"

# A trailing comment that mentions a scale is not the entry's scale.
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 1
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = omarchy_monitor_scale }) -- was scale = 1
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling ignores a scale named in a trailing comment"
grep -F -- '-- was scale = 1' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves a trailing comment alone"
pass "monitor scaling ignores a scale named in a trailing comment"

# A scale written as an expression is left whole rather than half-rewritten.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 3 / 2 })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 3 / 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves a scale expression whole"
pass "monitor scaling leaves a scale expression whole"

# An explicit entry with an automatic scale takes the chosen one.
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 1
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = "auto" })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists into an explicit entry with an automatic scale"
pass "monitor scaling persists into an explicit entry with an automatic scale"

# A nested table inside the entry does not end it, so its own scale is found.
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 1
hl.monitor({ output = "eDP-1", reserved_area = { top = 24 }, position = "0x0", scale = 1.25 })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", reserved_area = { top = 24 }, position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists into an explicit entry with a nested table"
grep -Fx 'local omarchy_monitor_scale = 1' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the catch-all alone with a nested table entry present"
pass "monitor scaling persists into an explicit entry with a nested table"

# Semicolons separate fields just like commas.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1"; position = "0x0"; scale = 1.25; transform = 1 })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1"; position = "0x0"; scale = 2; transform = 1 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists into an explicit entry with semicolon separators"
pass "monitor scaling persists into an explicit entry with semicolon separators"

# A block comment inside the entry is neither a key nor a value.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", --[[ internal panel ]] position = "0x0", scale = 1.25 })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -Fx 'hl.monitor({ output = "eDP-1", --[[ internal panel ]] position = "0x0", scale = 2 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists into an explicit entry with a block comment"
pass "monitor scaling persists into an explicit entry with a block comment"

# A commented-out rule must not prevent the live variable-based rule saving.
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 1
--[[
hl.monitor({ output = "eDP-1", scale = 1.25 })
]]
hl.monitor({ output = "eDP-1", scale = omarchy_monitor_scale })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -Fx 'local omarchy_monitor_scale = 2' "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists through the live rule after a multi-line comment"
grep -Fx 'hl.monitor({ output = "eDP-1", scale = 1.25 })' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves a multi-line commented rule alone"
pass "monitor scaling ignores rules in multi-line comments"

# Lua accepts single quotes for both output names and automatic scales.
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 1
hl.monitor({ output = '', scale = omarchy_monitor_scale })
hl.monitor({ output = 'eDP-1', scale = 'auto' })
LUA
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -Fx "hl.monitor({ output = 'eDP-1', scale = 2 })" "$monitor_lua" >/dev/null ||
  fail "monitor scaling persists into a single-quoted output rule"
grep -Fx 'local omarchy_monitor_scale = 1' "$monitor_lua" >/dev/null ||
  fail "monitor scaling leaves the catch-all alone with a single-quoted output"
pass "monitor scaling supports single-quoted output names and automatic scales"

# Comments containing field-shaped text must not pose as scale fields.
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 1
hl.monitor({ output = "eDP-1", mode = "preferred", --[[ old, scale = 3, ]] position = "0x0", scale = omarchy_monitor_scale }) -- old, scale = 4,
LUA
cp "$monitor_lua" "$test_tmp/expected.lua"
sed -i 's/^local omarchy_monitor_scale = 1$/local omarchy_monitor_scale = 2/' "$test_tmp/expected.lua"
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
cmp -s "$monitor_lua" "$test_tmp/expected.lua" ||
  fail "monitor scaling ignores scale fields inside inline and trailing comments"
pass "monitor scaling ignores scale fields inside inline and trailing comments"

# The scalar terminator applies to quoted values as well as numbers.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", scale = "auto" .. "" })
LUA
cp "$monitor_lua" "$test_tmp/expected.lua"
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
cmp -s "$monitor_lua" "$test_tmp/expected.lua" ||
  fail "monitor scaling leaves a quoted scale expression whole"
pass "monitor scaling leaves a quoted scale expression whole"

# Replace only the marked live value; comments, other outputs and the shared
# default must remain byte-for-byte intact in every comment-boundary case.
assert_commented_rule_saved() {
  local description="$1" rule
  rule=$(cat)
  printf 'local omarchy_monitor_scale = 1\n%s\n' "${rule//@scale@/1.25}" >"$monitor_lua"
  printf 'local omarchy_monitor_scale = 1\n%s\n' "${rule//@scale@/2}" >"$test_tmp/expected.lua"
  OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
  cmp -s "$monitor_lua" "$test_tmp/expected.lua" || fail "$description" "$(diff -u "$test_tmp/expected.lua" "$monitor_lua")"
  pass "$description"
}

assert_commented_rule_saved "monitor scaling saves a field immediately after an inline comment" <<'LUA'
hl.monitor({ output = "eDP-1", --[[ panel ]] scale = @scale@ })
LUA

assert_commented_rule_saved "monitor scaling saves a value immediately before an inline comment" <<'LUA'
hl.monitor({ output = "eDP-1", scale = @scale@ --[[ panel ]] })
LUA

assert_commented_rule_saved "monitor scaling saves live code before a multi-line comment" <<'LUA'
hl.monitor({ output = "eDP-1", scale = @scale@ }) --[[ notes
hl.monitor({ output = "eDP-1", scale = 1.25 })
]]
LUA

assert_commented_rule_saved "monitor scaling saves live code after a multi-line comment" <<'LUA'
--[[ notes
hl.monitor({ output = "eDP-1", scale = 1.25 })
]] hl.monitor({ output = "eDP-1", scale = @scale@ })
LUA

assert_commented_rule_saved "monitor scaling treats comments around the key and value as whitespace" <<'LUA'
hl.monitor({ output = "eDP-1"; --[[ scale = 4, ]] scale --[[ key ]] = --[[ value ]] @scale@ --[[ bracket ] and scale = 3, ]] })
LUA

assert_commented_rule_saved "monitor scaling saves live rules around consecutive long comments" <<'LUA'
hl.monitor({ output = "eDP-1", scale = @scale@ }) --[=[ notes containing ]]
hl.monitor({ output = "eDP-1", scale = 1.25 })
]=] --[[ more notes
hl.monitor({ output = "eDP-1", scale = 1.25 })
]] hl.monitor({ output = "eDP-1", scale = @scale@ })
hl.monitor({ output = "DP-2", scale = 1.25 })
LUA

assert_commented_rule_saved "monitor scaling ignores comment markers and monitor rules inside strings" <<'LUA'
local double_quoted = "escaped \" --[[ hl.monitor({ output = \"eDP-1\", scale = 1.25 })"
local single_quoted = 'escaped \' --[[ hl.monitor({ output = "eDP-1", scale = 1.25 })'
local long_quoted = [=[ example containing ]]
hl.monitor({ output = "eDP-1", scale = 1.25 })
]=]
-- A line comment mentioning --[[ must not hide the next rule.
hl.monitor({ output = "eDP-1", scale = @scale@ })
LUA

# Comments are whitespace, not terminators that make an expression a scalar.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", scale = 3 --[[ , scale = 1, ]] / 2 })
hl.monitor({ output = "eDP-1", scale = "auto" --[[ , scale = 1, ]] .. "" })
LUA
cp "$monitor_lua" "$test_tmp/expected.lua"
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
cmp -s "$monitor_lua" "$test_tmp/expected.lua" ||
  fail "monitor scaling leaves expressions with embedded comments intact"
pass "monitor scaling leaves expressions with embedded comments intact"

# Hyprland reloads monitors.lua on any write, undoing the scale just applied,
# so a config with nothing to persist into must not be rewritten at all.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", scale = 1 * 1 })
LUA
written=$(stat -c '%i %y' "$monitor_lua")
rm -f "$eval_out"
OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor scaling applies 2x with nothing to persist into"
[[ $(stat -c '%i %y' "$monitor_lua") == "$written" ]] ||
  fail "monitor scaling leaves a config with nothing to persist into unwritten"
pass "monitor scaling leaves a config with nothing to persist into unwritten"

# A comment or long string must be matched whole, or the match can stretch
# into the next rule or stop inside a comment and rewrite a scale there.
assert_variable_rule_saved() {
  local description="$1"
  cat >"$monitor_lua"
  sed 's/^local omarchy_monitor_scale = 1$/local omarchy_monitor_scale = 2/' "$monitor_lua" >"$test_tmp/expected.lua"
  OMARCHY_TEST_MONITOR_SCALE=1 run_scaling 2
  cmp -s "$monitor_lua" "$test_tmp/expected.lua" || fail "$description" "$(diff -u "$test_tmp/expected.lua" "$monitor_lua")"
  pass "$description"
}

assert_variable_rule_saved "monitor scaling leaves the next rule alone after a block comment" <<'LUA'
local omarchy_monitor_scale = 1
hl.monitor({ output = "eDP-1", --[[ first ]] scale = omarchy_monitor_scale })
hl.monitor({ output = "DP-2", --[[ second ]] scale = 1.25 })
LUA

assert_variable_rule_saved "monitor scaling leaves the next rule alone after a long string" <<'LUA'
local omarchy_monitor_scale = 1
hl.monitor({ output = "eDP-1", mode = [[preferred]], scale = omarchy_monitor_scale })
hl.monitor({ output = "DP-2", mode = [[preferred]], scale = 1.25 })
LUA

assert_variable_rule_saved "monitor scaling leaves a scale inside a line comment alone" <<'LUA'
local omarchy_monitor_scale = 1
hl.monitor({ output = "eDP-1", -- previous, scale = 1.25,
  scale = omarchy_monitor_scale })
LUA
