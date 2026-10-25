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
  if [[ ${OMARCHY_TEST_MONITOR_COUNT:-1} == "2" ]]; then
    printf '[{"name":"eDP-1","focused":true,"scale":%s,"width":%s,"height":%s,"refreshRate":120.0},' \
      "${OMARCHY_TEST_MONITOR_SCALE:-2}" "${OMARCHY_TEST_MONITOR_WIDTH:-2880}" "${OMARCHY_TEST_MONITOR_HEIGHT:-1800}"
    printf '{"name":"DP-1","focused":false,"scale":1,"width":1920,"height":1080,"refreshRate":60.0}]'
  else
    printf '[{"name":"eDP-1","focused":true,"scale":%s,"width":%s,"height":%s,"refreshRate":120.0}]' \
      "${OMARCHY_TEST_MONITOR_SCALE:-2}" "${OMARCHY_TEST_MONITOR_WIDTH:-2880}" "${OMARCHY_TEST_MONITOR_HEIGHT:-1800}"
  fi
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

# The shipped default: one scale knob behind a catch-all rule, no per-output
# rules. The catch-all applies to every output that has no rule of its own.
write_default_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
}

write_per_output_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.25 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "2048x0", scale = 1 })
LUA
}

write_monitor_rule_without_scale() {
  cat >"$monitor_lua" <<'LUA'
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0" }) -- scale = 2
LUA
}

write_commented_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
hl.env("GDK_SCALE", "1")
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.25 })
LUA
}

run_scaling() {
  HOME="$home_dir" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    OMARCHY_TEST_MONITOR_COUNT="${OMARCHY_TEST_MONITOR_COUNT:-1}" \
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

# With two outputs on the shipped config, the scale belongs to the focused
# output.
write_default_monitor_config
OMARCHY_TEST_MONITOR_COUNT=2 OMARCHY_TEST_MONITOR_SCALE=1.25 run_scaling 1.6
grep -F 'output = "eDP-1"' "$eval_out" >/dev/null ||
  fail "multi-monitor scaling applies to the focused output"
if grep -F 'output = "DP-1"' "$eval_out" >/dev/null; then
  fail "multi-monitor scaling leaves the other output out of the runtime change"
fi
grep -E '^hl\.monitor\(\{[^}]*output = "eDP-1"[^}]*scale = 1\.6[^}]*\}\)' "$monitor_lua" >/dev/null ||
  fail "multi-monitor scaling persists a per-output rule for the focused output"
grep -Fx 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })' "$monitor_lua" >/dev/null ||
  fail "multi-monitor scaling leaves the catch-all rule alone"
grep -Fx 'local omarchy_monitor_scale = 1.25' "$monitor_lua" >/dev/null ||
  fail "multi-monitor scaling leaves the single-scale knob alone"
if grep -F 'output = "DP-1"' "$monitor_lua" >/dev/null; then
  fail "multi-monitor scaling does not write a rule for the other output"
fi
grep -Fx 'local omarchy_gdk_scale = 1' "$monitor_lua" >/dev/null ||
  fail "multi-monitor scaling leaves global GDK_SCALE alone"
pass "multi-monitor scaling persists only the focused output"

# A config that already has one rule per output must be updated in place.
write_per_output_monitor_config
OMARCHY_TEST_MONITOR_COUNT=2 OMARCHY_TEST_MONITOR_SCALE=1.25 run_scaling 1.6
edp_rule=$(grep -F 'output = "eDP-1"' "$monitor_lua" || true)
[[ -n $edp_rule ]] || fail "output scaling keeps the focused output's rule"
[[ $edp_rule == *"scale = 1.6"* ]] || fail "output scaling updates the focused output's rule" "rule: $edp_rule"
[[ $edp_rule == *'position = "0x0"'* ]] || fail "output scaling preserves the focused rule's position" "rule: $edp_rule"
grep -Fx 'hl.monitor({ output = "DP-1", mode = "preferred", position = "2048x0", scale = 1 })' "$monitor_lua" >/dev/null ||
  fail "output scaling leaves the other output's rule untouched"
grep -Fx 'hl.env("GDK_SCALE", "1")' "$monitor_lua" >/dev/null ||
  fail "output scaling leaves global GDK_SCALE alone"
pass "output scaling updates only the focused output's rule"

# With one output, an existing per-output rule still wins over the legacy knob.
write_per_output_monitor_config
OMARCHY_TEST_MONITOR_SCALE=1.25 run_scaling 1.6
edp_rule=$(grep -F 'output = "eDP-1"' "$monitor_lua" || true)
[[ $edp_rule == *"scale = 1.6"* ]] ||
  fail "single-output scaling updates an existing per-output rule" "rule: $edp_rule"
grep -Fx 'hl.monitor({ output = "DP-1", mode = "preferred", position = "2048x0", scale = 1 })' "$monitor_lua" >/dev/null ||
  fail "single-output scaling leaves other output rules untouched"
grep -Fx 'hl.env("GDK_SCALE", "1")' "$monitor_lua" >/dev/null ||
  fail "single-output scaling leaves global GDK_SCALE alone"
pass "single-output scaling updates an existing per-output rule"

# A rule without a scale gets one added in place.
write_monitor_rule_without_scale
OMARCHY_TEST_MONITOR_COUNT=2 OMARCHY_TEST_MONITOR_SCALE=1.25 run_scaling 1.6
edp_rule=$(grep -F 'output = "eDP-1"' "$monitor_lua" || true)
edp_code=${edp_rule%%--*}
[[ $edp_code == *"scale = 1.6"* ]] ||
  fail "output scaling adds a missing scale to the focused rule" "rule: $edp_rule"
[[ $edp_rule == *'-- scale = 2'* ]] ||
  fail "output scaling leaves a trailing comment alone" "rule: $edp_rule"
[[ $edp_code == *'position = "0x0"'* ]] ||
  fail "output scaling preserves the focused rule's position when adding a scale" "rule: $edp_rule"
pass "output scaling adds a missing scale to the focused rule"

# A commented-out rule is not an active rule.
write_commented_monitor_config
OMARCHY_TEST_MONITOR_COUNT=2 OMARCHY_TEST_MONITOR_SCALE=1.25 run_scaling 1.6
grep -Fx -- '-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.25 })' "$monitor_lua" >/dev/null ||
  fail "output scaling leaves a commented-out rule alone"
grep -E '^hl\.monitor\(\{[^}]*output = "eDP-1"[^}]*scale = 1\.6[^}]*\}\)' "$monitor_lua" >/dev/null ||
  fail "output scaling adds an active rule beside a commented-out one"
pass "output scaling ignores a commented-out rule"

# Running it again must update that rule rather than append a duplicate.
write_per_output_monitor_config
OMARCHY_TEST_MONITOR_COUNT=2 OMARCHY_TEST_MONITOR_SCALE=1.25 run_scaling 1.6
OMARCHY_TEST_MONITOR_COUNT=2 OMARCHY_TEST_MONITOR_SCALE=1.6 run_scaling 1.6
edp_count=$(grep -cF 'output = "eDP-1"' "$monitor_lua" || true)
(( edp_count == 1 )) || fail "repeated scaling does not duplicate the focused output's rule" "count: $edp_count"
grep -E '^hl\.monitor\(\{[^}]*output = "eDP-1"[^}]*scale = 1\.6[^}]*\}\)' "$monitor_lua" >/dev/null ||
  fail "repeated scaling keeps the focused output's rule at the requested scale"
pass "repeated scaling updates the focused output's rule in place"
