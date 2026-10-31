#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command lua
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
home_dir="$test_tmp/home"
monitor_lua="$home_dir/.config/hypr/monitors.lua"
eval_log="$test_tmp/hyprctl-eval.log"
state_dir="$home_dir/.local/state/omarchy/toggles/hypr"
scale_state="$state_dir/internal-monitor-scale"

mkdir -p "$stub_bin" "$home_dir/.config/hypr"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]]; then
  # A real `hyprctl monitors all -j` lists every output, not just the
  # internal one -- keep an external entry in the array so selection-by-name
  # is exercised the same way it is in production, for every case below.
  external=$(printf '{"name":"%s","make":"%s","model":"%s","serial":"%s","disabled":false,"scale":1,"refreshRate":60,"transform":%s,"x":%s,"y":0,"width":%s,"height":%s}' \
    "${OMARCHY_TEST_EXTERNAL_NAME:-HDMI-A-1}" "${OMARCHY_TEST_EXTERNAL_MAKE-Samsung Electric Company}" \
    "${OMARCHY_TEST_EXTERNAL_MODEL-LF24T35}" "${OMARCHY_TEST_EXTERNAL_SERIAL-HX5X721467}" \
    "${OMARCHY_TEST_EXTERNAL_TRANSFORM:-0}" "${OMARCHY_TEST_EXTERNAL_X:-1920}" \
    "${OMARCHY_TEST_EXTERNAL_WIDTH:-1920}" "${OMARCHY_TEST_EXTERNAL_HEIGHT:-1080}")
  if [[ -n ${OMARCHY_TEST_OTHER_OUTPUT:-} ]]; then
    external=$(printf '{"name":"%s","disabled":false,"scale":1}' "$OMARCHY_TEST_OTHER_OUTPUT")
  fi
  # More outputs, as ready-made JSON objects joined by commas.
  [[ -z ${OMARCHY_TEST_EXTRA_EXTERNALS:-} ]] || external="$external,$OMARCHY_TEST_EXTRA_EXTERNALS"
  # A real reload re-enables the panel once the clamshell flag is gone, at
  # whatever position the catch-all rule gave it.
  if [[ ${OMARCHY_TEST_INTERNAL_DISABLED:-false} == "true" && ! -f $OMARCHY_TEST_RELOADED ]]; then
    printf '[%s,{"name":"eDP-1","disabled":true,"scale":null,"x":null,"y":null}]' "$external"
  else
    scale="${OMARCHY_TEST_INTERNAL_SCALE:-2}"
    if [[ -n ${OMARCHY_TEST_APPLIED_SCALE:-} && -f $OMARCHY_TEST_APPLIED_MARKER ]]; then
      scale="$OMARCHY_TEST_APPLIED_SCALE"
    fi
    printf '[%s,{"name":"eDP-1","disabled":false,"scale":%s,"refreshRate":60,"transform":0,"width":1920,"height":1080,"x":%s,"y":%s}]' \
      "$external" "$scale" "${OMARCHY_TEST_INTERNAL_X:-0}" "${OMARCHY_TEST_INTERNAL_Y:-0}"
  fi
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >>"$OMARCHY_TEST_HYPRCTL_EVAL_LOG"
  touch "$OMARCHY_TEST_APPLIED_MARKER"
elif [[ $1 == "reload" ]]; then
  printf 'reload\n' >>"$OMARCHY_TEST_HYPRCTL_EVAL_LOG"
  touch "$OMARCHY_TEST_RELOADED"
elif [[ $1 == "dispatch" ]]; then
  printf 'dispatch %s\n' "$2" >>"$OMARCHY_TEST_HYPRCTL_EVAL_LOG"
else
  exit 1
fi
SH

cat >"$stub_bin/omarchy-hyprland-monitor-internal" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-hyprland-monitor-internal-mirror" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-hyprland-monitor-laptop" <<'SH'
#!/bin/bash
echo eDP-1
SH

cat >"$stub_bin/omarchy-hyprland-monitor-external-active" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_EXTERNAL_ACTIVE:-false} == "true" ]]
SH

cat >"$stub_bin/omarchy-hw-clamshell" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_CLAMSHELL:-false} == "true" ]]
SH

cat >"$stub_bin/omarchy-hw-external-monitors" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_EXTERNAL_CONNECTED:-false} == "true" ]]
SH

chmod +x "$stub_bin"/*

remember_scale() {
  mkdir -p "$state_dir"
  printf '%s\n' "$1" >"$scale_state"
}

export OMARCHY_PATH="$ROOT"

run_clamshell() {
  rm -f "$test_tmp/reloaded" "$test_tmp/applied" "$state_dir/internal-monitor-clamshell.lua"

  HOME="$home_dir" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_RELOADED="$test_tmp/reloaded" \
    OMARCHY_TEST_APPLIED_MARKER="$test_tmp/applied" \
    OMARCHY_TEST_HYPRCTL_EVAL_LOG="$eval_log" \
    OMARCHY_TEST_INTERNAL_SCALE="${OMARCHY_TEST_INTERNAL_SCALE:-2}" \
    OMARCHY_TEST_INTERNAL_DISABLED="${OMARCHY_TEST_INTERNAL_DISABLED:-false}" \
    OMARCHY_TEST_EXTERNAL_ACTIVE="${OMARCHY_TEST_EXTERNAL_ACTIVE:-false}" \
    OMARCHY_TEST_CLAMSHELL="${OMARCHY_TEST_CLAMSHELL:-false}" \
    OMARCHY_TEST_EXTERNAL_CONNECTED="${OMARCHY_TEST_EXTERNAL_CONNECTED:-false}" \
    OMARCHY_TEST_OTHER_OUTPUT="${OMARCHY_TEST_OTHER_OUTPUT:-}" \
    "$ROOT/bin/omarchy-hyprland-monitor-clamshell"
}

# Writes stdin as monitors.lua and runs a clamshell sync with the internal panel
# at scale $2 ("off" when it is disabled) and $3 remembered ("-" for nothing).
# Each remaining argument must appear in what was applied, or, with a leading
# "!", must not; "!scale = " means no scale was applied at all.
expect_sync() {
  local description=$1 active=$2 remembered=$3 expectation
  shift 3

  cat >"$monitor_lua"
  rm -f "$scale_state"
  [[ $remembered == "-" ]] || remember_scale "$remembered"
  : >"$eval_log"
  if [[ $active == "off" ]]; then
    OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
  else
    OMARCHY_TEST_INTERNAL_SCALE=$active run_clamshell
  fi

  for expectation in "$@"; do
    if [[ $expectation == !* ]]; then
      ! grep -F -- "${expectation#!}" "$eval_log" >/dev/null || fail "$description" "$(<"$eval_log")"
    else
      grep -F -- "$expectation" "$eval_log" >/dev/null || fail "$description" "$(<"$eval_log")"
    fi
  done
  pass "$description"
}

auto_config='local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"'

internal_config='hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.25 })
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = 1 })'

# A local holding an expression rather than a scalar. Half of it is not a scale.
expression_config='local omarchy_monitor_scale = 3 / 2
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })'

# A local named after a quoted scale value. The quotes make the rule's "auto" a
# string, so the local must not be substituted for it.
shadowed_auto_config='local auto = 1.5
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = "auto" })'

# Regression (#7265, #7301): with scale = "auto" the compositor's resolution of
# it IS the configured scale, not a transient to correct. Forcing a number here
# made the scale flap: every idle-wake applied the fallback 2, every config
# reload resolved auto back to the panel's own value.
expect_sync "clamshell recovery leaves an auto-scaled panel alone" 3 - '!scale = ' <<<"$auto_config"
[[ ! -f $scale_state ]] || fail "clamshell recovery does not remember transient scale"

# The shipped default, where "auto" reaches the panel via the catch-all rule's
# bare-word reference to the local.
expect_sync "clamshell recovery leaves the shipped auto default alone" 3 - '!scale = ' <<'LUA'
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA

# An expression or an explicit "auto" is Hyprland's to evaluate: it names no
# number to correct an enabled panel toward, remembered or not.
expect_sync "clamshell recovery leaves an expression-scaled panel alone" 3 1.75 '!scale = ' <<<"$expression_config"
expect_sync "clamshell recovery leaves an explicitly auto panel alone" 3 1.75 '!scale = ' <<<"$shadowed_auto_config"

# A numeric config keeps both sync behaviors: a matching active scale is not
# reapplied, and a drifted one is corrected back to the configured value.
expect_sync "clamshell recovery avoids redundant scale apply" 1.25 - '!scale = ' <<<"$internal_config"
expect_sync "clamshell recovery corrects a drifted numeric scale" 3 - 'scale = 1.25' <<<"$internal_config"

printf '%s\n' "$auto_config" >"$monitor_lua"
rm -f "$scale_state"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=1.6 OMARCHY_TEST_EXTERNAL_ACTIVE=true OMARCHY_TEST_CLAMSHELL=true run_clamshell
[[ -f $scale_state ]] || fail "clamshell disable remembers internal scale"
[[ $(<"$scale_state") == "1.6" ]] || fail "clamshell disable remembers internal scale value"
pass "clamshell disable remembers internal scale"

: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.6' "$eval_log" >/dev/null || fail "clamshell recovery uses remembered internal scale"
! grep -F 'scale = "auto"' "$eval_log" >/dev/null || fail "clamshell recovery avoids auto after disabled internal display"
pass "clamshell recovery uses remembered internal scale"

# Recovery of a panel that is off, under an auto config with nothing
# remembered, still needs a number: the historical default 2.
expect_sync "clamshell recovery falls back to the default scale" off - 'scale = 2' <<<"$auto_config"

expect_sync "clamshell recovery uses configured internal monitor rule" off - 'position = "0x0"' 'scale = 1.25' <<<"$internal_config"

# Scale correction of a panel that is already on keeps its place, instead of
# sending it to the end of the layout with "auto".
printf '%s\n' 'hl.monitor({ output = "", mode = "preferred", scale = 1.5 })' >"$monitor_lua"

: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 OMARCHY_TEST_INTERNAL_X=0 run_clamshell
grep -F 'scale = 1.5' "$eval_log" >/dev/null || fail "a live scale correction applies the configured scale"
grep -F 'position = "0x0"' "$eval_log" >/dev/null || fail "a live scale correction keeps the panel's live position"
pass "a live scale correction keeps the panel where it is"

printf '%s\n' 'hl.monitor({ output = "eDP-1", mode = "1280x720", position = "auto", scale = 1.5 })' >"$monitor_lua"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 run_clamshell
HOME="$home_dir" lua - "$eval_log" <<'LUA'
local calls = 0
hl = {
  get_monitor = function() return { width = 1280, height = 720, refresh_rate = 60, transform = 1 } end,
  monitor = function(rule)
    calls = calls + 1
    assert(rule.mode == "1280x720@60.00000", "scale correction preserves the active mode")
    assert(rule.transform == 1, "scale correction preserves the active rotation")
  end,
}
dofile(arg[1])
assert(calls == 1, "scale correction must emit one panel rule")
LUA
pass "moving or scaling a panel preserves its configured mode and rotation"
printf '%s\n' 'hl.monitor({ output = "", mode = "preferred", scale = 1.5 })' >"$monitor_lua"

# ...unless the new scale widens it into a neighbor: a 1920px panel at scale 3
# is 640 wide, and at scale 1.5 it is 1280, past an external at 700.
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 OMARCHY_TEST_INTERNAL_X=0 OMARCHY_TEST_EXTERNAL_X=700 run_clamshell
grep -F 'scale = 1.5' "$eval_log" >/dev/null || fail "an overlapping scale correction still applies the scale"
grep -F 'position = "auto"' "$eval_log" >/dev/null || fail "a scale correction that would overlap falls back to auto"
! grep -F 'position = "0x0"' "$eval_log" >/dev/null || fail "a scale correction never reapplies a position that would overlap"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 OMARCHY_TEST_INTERNAL_X=0 OMARCHY_TEST_EXTERNAL_X=1400 run_clamshell
grep -F 'position = "0x0"' "$eval_log" >/dev/null || fail "a scale correction that still fits keeps the position"
pass "a scale correction falls back to auto when the wider panel would overlap"

# Hyprland can snap a requested scale down, growing the panel beyond the fit
# predicted from that request. Check the geometry it actually applied too.
printf '%s\n' 'hl.monitor({ output = "", scale = 1.669, position = "auto" })' >"$monitor_lua"
for external_x in 1151 1152; do
  : >"$eval_log"
  OMARCHY_TEST_INTERNAL_SCALE=3 OMARCHY_TEST_APPLIED_SCALE=1.6666666 \
    OMARCHY_TEST_INTERNAL_X=0 OMARCHY_TEST_EXTERNAL_X="$external_x" run_clamshell
  lua - "$eval_log" "$external_x" <<'LUA'
local rules = {}
hl = {
  get_monitor = function() return { width = 1920, height = 1080, refresh_rate = 60, transform = 0 } end,
  monitor = function(rule) rules[#rules + 1] = rule end,
}
dofile(arg[1])
local final = assert(rules[#rules], "scale correction must emit a panel rule")
local expected = arg[2] == "1151" and "auto" or "0x0"
assert(final.position == expected, "snapped scale must fit at the final position")
LUA
done
pass "scale correction checks the applied scale and allows touching edges without overlap"

# A rule referencing a local resolves to the local's value, not the literal name.
expect_sync "clamshell recovery resolves omarchy_monitor_scale variable reference" off - 'scale = 1.5' <<'LUA'
local omarchy_gdk_scale = 1.5
local omarchy_monitor_scale = 1.5
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA

# An explicit "auto" on the internal rule is a value, not a variable reference,
# so it must not pick up an unrelated omarchy_monitor_scale local.
expect_sync "clamshell recovery keeps auto scale off the omarchy_monitor_scale local" off 1.75 'scale = 1.75' <<'LUA'
local omarchy_monitor_scale = 2
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = "auto" })
LUA

# The internal rule names a local that does not exist. The catch-all rule never
# applies to an output that has its own rule, so it must not be read.
expect_sync "clamshell recovery ignores the catch-all rule when the internal panel has its own" off 1.75 'scale = 1.75' <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = my_scale })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA

# No rule for the internal panel, and the catch-all references the local:
# quoted here, and commented below.
expect_sync "clamshell recovery resolves a quoted scale through the catch-all rule" off - 'scale = 1.5' <<'LUA'
local omarchy_monitor_scale = "1.5"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA

expect_sync "clamshell recovery ignores a trailing comment on the scale local" off - 'scale = 1.25' <<'LUA'
local omarchy_monitor_scale = 1.25 -- HiDPI panel
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA

expect_sync "clamshell recovery resolves a position variable reference" off - 'position = "0x0"' <<'LUA'
local omarchy_monitor_position = "0x0"
hl.monitor({ output = "eDP-1", mode = "preferred", position = omarchy_monitor_position, scale = 1.25 })
LUA

# An internal rule that names no scale leaves the catch-all to supply one. Only
# a rule that names a scale keeps the catch-all away from the internal panel.
expect_sync "clamshell recovery takes the catch-all scale when the internal rule omits one" off 1.75 'scale = 1' '!scale = 1.75' <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", transform = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA

expect_sync "clamshell recovery leaves an expression scale unresolved" off 1.75 'scale = 1.75' <<<"$expression_config"
expect_sync "clamshell recovery does not resolve a quoted scale against a local" off 1.75 'scale = 1.75' <<<"$shadowed_auto_config"

expect_sync "clamshell recovery leaves an expression scale in a rule unresolved" off 1.75 'scale = 1.75' <<'LUA'
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 3 / 2 })
LUA

# Commented-out text after a rule is not a rule, and not one of its keys either.
expect_sync "clamshell recovery does not read a rule out of a trailing comment" off 1.75 'scale = 1.5' <<'LUA'
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1 }) -- output = "eDP-1"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.5 })
LUA

expect_sync "clamshell recovery does not read a scale out of a trailing comment" off 1.75 'scale = 1.25' <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.25 }) -- scale = 3
LUA

# A nested table before the keys, a block comment, and semicolons for
# separators. All are Lua a user can reasonably write, and none ends the rule.
for rule in \
  'hl.monitor({ output = "eDP-1", reserved_area = { top = 24 }, position = "0x0", scale = 1.25 })' \
  'hl.monitor({ output = "eDP-1", --[[ internal panel ]] position = "0x0", scale = 1.25 })' \
  'hl.monitor({ output = "eDP-1"; position = "0x0"; scale = 1.25; transform = 1 })'; do
  expect_sync "clamshell recovery reads the position and scale out of: $rule" off 1.75 'position = "0x0"' 'scale = 1.25' <<<"$rule"
done

# A panel turned off from the Display panel is a runtime disabled = true with
# no flag. Once the external display is unplugged, the recovery's rule update
# has to say disabled = false, or the panel stays off behind Hyprland's
# FALLBACK (#16307). While an external display or a headless output is still
# there, the choice to run on it alone stands, since the docked poll reaches
# this every two seconds.
OMARCHY_TEST_OTHER_OUTPUT=FALLBACK \
  expect_sync "clamshell recovery turns a panel-disabled display back on once nothing external is connected" off - \
  'disabled = false' 'position = "0x0"' 'scale = 1.25' <<<"$internal_config"
lua - "$eval_log" <<'LUA'
local calls = 0
hl = {
  get_monitor = function() return nil end,
  monitor = function(rule)
    calls = calls + 1
    assert(rule.disabled == false, "an unplugged panel must be enabled")
    assert(rule.mode == "preferred", "an absent panel needs a preferred mode")
    assert(rule.position == "0x0" and rule.scale == 1.25, "recovery preserves configured geometry")
  end,
}
dofile(arg[1])
assert(calls == 1, "unplug recovery must emit one panel rule")
LUA
OMARCHY_TEST_EXTERNAL_CONNECTED=true OMARCHY_TEST_EXTERNAL_ACTIVE=true OMARCHY_TEST_OTHER_OUTPUT=DP-1 \
  expect_sync "clamshell recovery leaves a panel-disabled display off while an external display is connected" off - \
  'scale = 1.25' '!disabled = false' <<<"$internal_config"
OMARCHY_TEST_EXTERNAL_ACTIVE=true OMARCHY_TEST_OTHER_OUTPUT=HEADLESS-1 \
  expect_sync "clamshell recovery leaves a panel-disabled display off while a headless output is enabled" off - \
  'scale = 1.25' '!disabled = false' <<<"$internal_config"

OMARCHY_PATH="$ROOT" python3 "$SHELL_TEST_DIR/fixtures/monitor-clamshell-layout.py"
