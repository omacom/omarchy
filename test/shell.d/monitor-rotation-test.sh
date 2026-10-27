#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
eval_out="$test_tmp/hyprctl-eval"
home_dir="$test_tmp/home"
monitor_lua="$home_dir/.config/hypr/monitors.lua"

mkdir -p "$stub_bin" "$home_dir/.config/hypr"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]]; then
  printf '%s' "$(cat "$FAKE_MONITORS")"
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

run_rotation() {
  FAKE_MONITORS="$test_tmp/monitors.json" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    HOME="$home_dir" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    "$ROOT/bin/omarchy-hyprland-monitor-rotation" "$@"
}

monitors_with() {
  local transform="$1"
  cat >"$test_tmp/monitors.json" <<JSON
[{"name":"eDP-1","focused":true,"scale":2,"width":2880,"height":1800,"transform":$transform}]
JSON
}

eval_contains() {
  grep -qF "$1" "$eval_out" || fail "$2" "$(cat "$eval_out" 2>/dev/null || echo no-eval)"
  return 0
}

# The focused display's rotation, in degrees, is what a bare call reports.
monitors_with 1
[[ $(run_rotation) == "90" ]] || fail "bare call reports focused rotation"
monitors_with 3
[[ $(run_rotation) == "270" ]] || fail "bare call reports 270 for transform 3"
monitors_with 0
[[ $(run_rotation) == "0" ]] || fail "bare call reports 0 for transform 0"
pass "bare call reports the focused display's rotation"

# No config file at all: the runtime rotation still lands.
rm -f "$monitor_lua"
monitors_with 0
run_rotation up
eval_contains 'hl.monitor({ output = "eDP-1", transform = 1 })' "rotation up applies a 90 degree transform"
[[ ! -e $monitor_lua ]] || fail "rotation up without a config file creates none"
run_rotation down
eval_contains 'hl.monitor({ output = "eDP-1", transform = 3 })' "rotation down applies a 270 degree transform"
pass "rotation applies live without a config file"

# Up/down cycle relative to the current live transform: up from 270 wraps to
# 0, up from 0 reaches 90.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", transform = 3 })
LUA
monitors_with 3
run_rotation up
eval_contains 'hl.monitor({ output = "eDP-1", transform = 0 })' "up from 270 wraps to 0"
grep -F 'hl.monitor({ output = "eDP-1", transform = 0 })' "$monitor_lua" >/dev/null ||
  fail "up from 270 persists 0" "$(cat "$monitor_lua")"
monitors_with 0
run_rotation up
eval_contains 'hl.monitor({ output = "eDP-1", transform = 1 })' "up from 0 reaches 90"
pass "up/down wrap around the rotation"
# A bare monitors.lua (the stock style) gets a rotation rule for the output.
rm -f "$eval_out"
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = "auto"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
monitors_with 0
run_rotation 90
eval_contains 'hl.monitor({ output = "eDP-1", transform = 1 })' "rotation 90 applies transform 1"
grep -F 'hl.monitor({ output = "eDP-1", transform = 1 })' "$monitor_lua" >/dev/null ||
  fail "rotation 90 persists a rule" "$(cat "$monitor_lua")"
[[ $(grep -cF 'output = "eDP-1"' "$monitor_lua") == 1 ]] || fail "rotation 90 adds one rule"
pass "rotation 90 persists a per-output rule"

# Reverting to 0 keeps the explicit rule at zero rather than deleting it: two
# reloads must keep yielding the same rotation.
rm -f "$eval_out"
run_rotation 0
eval_contains 'hl.monitor({ output = "eDP-1", transform = 0 })' "rotation 0 applies transform 0"
grep -F 'hl.monitor({ output = "eDP-1", transform = 0 })' "$monitor_lua" >/dev/null ||
  fail "rotation 0 persists an explicit zero rule" "$(cat "$monitor_lua")"
pass "rotation 0 persists an explicit zero rule"

# A per-output rule without a transform gets one added in place.
rm -f "$eval_out"
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = "auto"
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
LUA
monitors_with 0
run_rotation HDMI-A-1 90
eval_contains 'hl.monitor({ output = "HDMI-A-1", transform = 1 })' "named rotation applies"
grep -F 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1, transform = 1 })' "$monitor_lua" >/dev/null ||
  fail "named rotation adds the transform to the existing rule" "$(cat "$monitor_lua")"
[[ $(grep -cF 'output = "HDMI-A-1"' "$monitor_lua") == 1 ]] || fail "named rotation does not duplicate the rule"
pass "a rule without a transform gets one added in place"

# A rule that already has a transform is updated in place.
rm -f "$eval_out"
run_rotation HDMI-A-1 270
eval_contains 'hl.monitor({ output = "HDMI-A-1", transform = 3 })' "second rotation applies"
grep -F 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1, transform = 3 })' "$monitor_lua" >/dev/null ||
  fail "second rotation updates the transform in place" "$(cat "$monitor_lua")"
[[ $(grep -cF 'output = "HDMI-A-1"' "$monitor_lua") == 1 ]] || fail "second rotation keeps one rule"
pass "a rule with a transform is updated in place"

# The transform can sit before the output field.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ transform = 1, output = "DP-2", scale = 1 })
LUA
run_rotation DP-2 180
grep -F 'hl.monitor({ transform = 2, output = "DP-2", scale = 1 })' "$monitor_lua" >/dev/null ||
  fail "a leading transform field is updated too" "$(cat "$monitor_lua")"
pass "a transform in front of the output field is updated"

# Two displays: rotating one never touches the other's rule.
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = "auto"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
hl.monitor({ output = "eDP-1", mode = "2880x1800@90", position = "0x0", scale = 1.6 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "2304x0", scale = 1, transform = 1 })
LUA
run_rotation HDMI-A-1 270
grep -F 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "2304x0", scale = 1, transform = 3 })' "$monitor_lua" >/dev/null ||
  fail "the named display rotates" "$(cat "$monitor_lua")"
grep -F 'hl.monitor({ output = "eDP-1", mode = "2880x1800@90", position = "0x0", scale = 1.6 })' "$monitor_lua" >/dev/null ||
  fail "the other display stays put" "$(cat "$monitor_lua")"
pass "rotating one display leaves the other's rule alone"

# Output names match exactly: DP-1 is inside DP-14 as a substring, not a name.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "DP-14", mode = "2560x1440@144", position = "auto", scale = 1 })
LUA
run_rotation DP-1 90
grep -Fx 'hl.monitor({ output = "DP-14", mode = "2560x1440@144", position = "auto", scale = 1 })' "$monitor_lua" >/dev/null ||
  fail "rotating DP-1 leaves the DP-14 rule alone" "$(cat "$monitor_lua")"
grep -F 'hl.monitor({ output = "DP-1", transform = 1 })' "$monitor_lua" >/dev/null ||
  fail "rotating DP-1 lands a rule for DP-1" "$(cat "$monitor_lua")"
run_rotation DP-14 270
grep -Fx 'hl.monitor({ output = "DP-1", transform = 1 })' "$monitor_lua" >/dev/null ||
  fail "rotating DP-14 leaves the DP-1 rule alone" "$(cat "$monitor_lua")"
grep -F 'transform = 3' "$monitor_lua" >/dev/null || fail "rotating DP-14 updates its own rule" "$(cat "$monitor_lua")"
pass "output names match exactly, prefix or suffix"

# A commented-out rule is not a rule: the live config still gets one.
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = "auto"
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
LUA
run_rotation eDP-1 90
grep -F 'hl.monitor({ output = "eDP-1", transform = 1 })' "$monitor_lua" >/dev/null ||
  fail "a commented-out rule does not block persisting" "$(cat "$monitor_lua")"
grep -Fx -- '-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })' "$monitor_lua" >/dev/null ||
  fail "a commented-out rule is left alone" "$(cat "$monitor_lua")"
pass "a commented-out rule does not stand in for a live rule"

# A symlinked monitors.lua keeps its link: writes land on the target file
# (omarchy#7625).
cat >"$home_dir/.config/hypr/monitors-real.lua" <<'LUA'
local omarchy_monitor_scale = "auto"
LUA
ln -sf monitors-real.lua "$monitor_lua"
run_rotation eDP-1 90
grep -F 'hl.monitor({ output = "eDP-1", transform = 1 })' "$home_dir/.config/hypr/monitors-real.lua" >/dev/null ||
  fail "a symlinked config lands the rule on the target" "$(cat "$home_dir/.config/hypr/monitors-real.lua")"
[[ -L $monitor_lua ]] || fail "a symlinked config keeps its link"
pass "a symlinked monitors.lua keeps its link"

# An unsafe name is rejected before hyprctl is called.
rm -f "$eval_out"
cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = "auto"
LUA
set +e
run_rotation 'eDP-1; rm -rf /' 90; status=$?
set -e
[[ $status -ne 0 ]] || fail "an unsafe name is rejected"
[[ ! -e $eval_out ]] || fail "a rejected name must not reach hyprctl" "$(cat "$eval_out")"
pass "an unsafe monitor name is rejected"

# A bad degree is rejected before hyprctl or the config is touched.
rm -f "$eval_out"
set +e
run_rotation abc; bad=$?
run_rotation 45; bad=$(( bad + $? ))
set -e
[[ $bad -ne 0 ]] || fail "bad degrees are rejected"
[[ ! -e $eval_out ]] || fail "bad degrees must not reach hyprctl" "$(cat "$eval_out")"
pass "bad degrees are rejected"

# With no readable Hyprland state, show and the up/down steps fail cleanly
# instead of guessing a degree or running arithmetic on nothing.
rm -f "$test_tmp/monitors.json" "$eval_out"
set +e
out=$(run_rotation 2>&1); rc=$?
set -e
[[ $rc -ne 0 ]] || fail "show fails without display state" "$out"
[[ $out == *"No Hyprland display state"* ]] || fail "show names the missing state" "$out"
set +e
run_rotation up; up_rc=$?
set -e
[[ $up_rc -ne 0 ]] || fail "up fails without display state"
[[ ! -e $eval_out ]] || fail "up without state must not reach hyprctl" "$(cat "$eval_out")"
pass "unavailable display state fails cleanly instead of guessing"

# A failed live apply must not be written into the config: the state and
# the persistence have to agree.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]]; then
  printf '%s' "$(cat "$FAKE_MONITORS")"
elif [[ $1 == "eval" ]]; then
  exit 1
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"
monitors_with 0
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", scale = 1.6, position = 0x0, mode = "preferred" })
LUA
set +e
out=$(run_rotation eDP-1 90 2>&1); rc=$?
set -e
[[ $rc -ne 0 ]] || fail "a failed apply reports failure" "$out"
[[ $out == *"Could not apply rotation"* ]] || fail "a failed apply names the trouble" "$out"
grep -q "transform" "$monitor_lua" && fail "a failed apply must not persist" "$(cat "$monitor_lua")"
! grep -q "transform" "$monitor_lua" || fail "a failed apply leaves the config untouched" "$(cat "$monitor_lua")"
pass "a failed live apply does not persist"

# A persist the system cannot complete is never reported as success. The
# failed-apply test above left a failing hyprctl stub behind, so the first
# thing to do is put a successful apply back - the point of this test is the
# persist leg, not the apply leg.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]]; then
  printf '%s' "$(cat "$FAKE_MONITORS")"
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"
monitors_with 0

# (a) Updating the transform of an existing rule needs sed to complete its
# in-place rewrite; a read-only config directory makes that impossible.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "HDMI-A-1", scale = 1, position = auto, mode = preferred })
LUA
chmod a-w "$home_dir/.config/hypr"
set +e
out=$(run_rotation HDMI-A-1 180 2>&1); rc=$?
set -e
chmod u+w "$home_dir/.config/hypr"
[[ $rc -ne 0 ]] || fail "a failed in-place update reports failure" "$out"
[[ $out == *"Could not"* ]] || fail "a failed in-place update names the trouble" "$out"

# (b) Appending a brand-new rule (no rule for the output yet) needs the file
# itself to accept writes; a read-only file makes that impossible.
cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", scale = 1, position = 0x0, mode = preferred })
LUA
chmod a-w "$monitor_lua"
set +e
out=$(run_rotation HDMI-A-1 180 2>&1); rc=$?
set -e
chmod u+w "$monitor_lua"
[[ $rc -ne 0 ]] || fail "a failed append reports failure" "$out"
[[ $out == *"Could not"* ]] || fail "a failed append names the trouble" "$out"
pass "a persist the system cannot complete is reported as failure"

