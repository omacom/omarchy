#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
home_dir="$test_tmp/home"
monitor_lua="$home_dir/.config/hypr/monitors.lua"
eval_log="$test_tmp/hyprctl-eval.log"
reloaded_marker="$test_tmp/reloaded"
clamshell_flag="$home_dir/.local/state/omarchy/toggles/hypr/internal-monitor-clamshell.lua"
state_dir="$home_dir/.local/state/omarchy/toggles/hypr"
scale_state="$state_dir/internal-monitor-scale"
position_state="$state_dir/internal-monitor-position"
manual_disable_flag="$state_dir/internal-monitor-disable.lua"

mkdir -p "$stub_bin" "$home_dir/.config/hypr"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]]; then
  # A real `hyprctl monitors all -j` lists every output, not just the
  # internal one -- keep an external entry in the array so selection-by-name
  # is exercised the same way it is in production, for every case below.
  external=$(printf '{"name":"%s","make":"%s","model":"%s","serial":"%s","disabled":false,"scale":1,"transform":%s,"x":%s,"y":0,"width":%s,"height":%s}' \
    "${OMARCHY_TEST_EXTERNAL_NAME:-HDMI-A-1}" "${OMARCHY_TEST_EXTERNAL_MAKE-Samsung Electric Company}" \
    "${OMARCHY_TEST_EXTERNAL_MODEL-LF24T35}" "${OMARCHY_TEST_EXTERNAL_SERIAL-HX5X721467}" \
    "${OMARCHY_TEST_EXTERNAL_TRANSFORM:-0}" "${OMARCHY_TEST_EXTERNAL_X:-1920}" \
    "${OMARCHY_TEST_EXTERNAL_WIDTH:-1920}" "${OMARCHY_TEST_EXTERNAL_HEIGHT:-1080}")
  # More outputs, as ready-made JSON objects joined by commas.
  [[ -z ${OMARCHY_TEST_EXTRA_EXTERNALS:-} ]] || external="$external,$OMARCHY_TEST_EXTRA_EXTERNALS"
  # A real reload re-enables the panel once the clamshell flag is gone, at
  # whatever position the catch-all rule gave it.
  if [[ ${OMARCHY_TEST_INTERNAL_DISABLED:-false} == "true" && ! -f $OMARCHY_TEST_RELOADED ]]; then
    printf '[%s,{"name":"eDP-1","disabled":true,"scale":null,"x":null,"y":null}]' "$external"
  else
    printf '[%s,{"name":"eDP-1","disabled":false,"scale":%s,"transform":0,"width":1920,"height":1080,"x":%s,"y":%s}]' \
      "$external" "${OMARCHY_TEST_INTERNAL_SCALE:-2}" "${OMARCHY_TEST_INTERNAL_X:-0}" "${OMARCHY_TEST_INTERNAL_Y:-0}"
  fi
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >>"$OMARCHY_TEST_HYPRCTL_EVAL_LOG"
elif [[ $1 == "reload" ]]; then
  printf 'reload\n' >>"$OMARCHY_TEST_HYPRCTL_EVAL_LOG"
  [[ -f $HOME/.local/state/omarchy/toggles/hypr/internal-monitor-clamshell.lua ]] || touch "$OMARCHY_TEST_RELOADED"
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

chmod +x "$stub_bin"/*

write_auto_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"
LUA
}

# The shipped default's own shape: the catch-all rule hands the panel a
# bare-word reference to the "auto" local.
write_default_auto_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
}

write_internal_monitor_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.25 })
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = 1 })
LUA
}

# A specific-output rule that references the omarchy_monitor_scale variable
# (the default template's pattern) instead of a literal value. The variable
# must be resolved, not captured as the literal string "omarchy_monitor_scale".
write_internal_monitor_var_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_gdk_scale = 1.5
local omarchy_monitor_scale = 1.5
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
}

# An explicit non-numeric scale on the internal rule, alongside an unrelated
# omarchy_monitor_scale local that must not be substituted for it.
write_internal_monitor_auto_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 2
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = "auto" })
LUA
}

# The internal rule names a local that does not exist. The catch-all rule below
# it never applies to an output that has its own rule, so it must not be read.
write_internal_monitor_unresolvable_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = my_scale })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# The shipped default: no rule for the internal panel, and the catch-all rule
# references the omarchy_monitor_scale local. Quoted here, and commented below.
write_catch_all_var_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = "1.5"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
}

write_commented_catch_all_var_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 1.25 -- HiDPI panel
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
}

# A position that references a local, the same pattern the scale key allows.
write_internal_monitor_position_var_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_position = "0x0"
hl.monitor({ output = "eDP-1", mode = "preferred", position = omarchy_monitor_position, scale = 1.25 })
LUA
}

# An internal rule that names no scale at all, so the catch-all supplies one.
write_internal_monitor_scaleless_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", transform = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
}

# A local holding an expression rather than a scalar. Half of it is not a scale.
write_expression_scale_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 3 / 2
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
}

# A local that happens to be named after a quoted scale value. The quotes make
# the rule's "auto" a string, so the local must not be substituted for it.
write_shadowed_auto_config() {
  cat >"$monitor_lua" <<'LUA'
local auto = 1.5
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = "auto" })
LUA
}

# An expression written straight into the rule rather than into a local.
write_expression_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 3 / 2 })
LUA
}

# Commented-out text after a rule is not a rule, and not one of its keys either.
write_commented_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1 }) -- output = "eDP-1"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.5 })
LUA
}

write_commented_internal_rule_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.25 }) -- scale = 3
LUA
}

# A nested table before the keys, and semicolons for separators. Both are Lua a
# user can reasonably write, and neither ends the rule.
write_nested_table_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", reserved_area = { top = 24 }, position = "0x0", scale = 1.25 })
LUA
}

write_block_comment_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1", --[[ internal panel ]] position = "0x0", scale = 1.25 })
LUA
}

write_semicolon_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "eDP-1"; position = "0x0"; scale = 1.25; transform = 1 })
LUA
}

# A numeric catch-all scale with no rule -- specific or catch-all -- naming a
# position at all, so read_monitor_position has nothing configured to read.
write_catchall_scale_only_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "", mode = "preferred", scale = 1.5 })
LUA
}

# The catch-all rule names a position, but read_monitor_position only ever
# consults a rule specific to the internal output -- the catch-all's position
# must not leak in as if it were configured for the internal panel.
write_catchall_position_config() {
  cat >"$monitor_lua" <<'LUA'
hl.monitor({ output = "", mode = "preferred", position = "0x0", scale = 1 })
LUA
}

remember_scale() {
  mkdir -p "$state_dir"
  printf '%s\n' "$1" >"$scale_state"
}

remember_position() {
  mkdir -p "$state_dir"
  printf '%s\n%s\n' "$1" "${2:-Samsung_Electric_Company_LF24T35_HX5X721467}" >"$position_state"
}

# OMARCHY_TEST_UNDOCK=true starts from a docked state: the clamshell flag is set
# and the panel is off until the script's reload turns it back on.
run_clamshell() {
  rm -f "$reloaded_marker" "$clamshell_flag"
  if [[ ${OMARCHY_TEST_UNDOCK:-false} == "true" ]]; then
    mkdir -p "$state_dir"
    printf 'hl.monitor({ output = "eDP-1", disabled = true })\n' >"$clamshell_flag"
  fi

  HOME="$home_dir" \
    OMARCHY_TEST_RELOADED="$reloaded_marker" \
    OMARCHY_TEST_EXTERNAL_NAME="${OMARCHY_TEST_EXTERNAL_NAME:-HDMI-A-1}" \
    OMARCHY_TEST_EXTERNAL_MAKE="${OMARCHY_TEST_EXTERNAL_MAKE-Samsung Electric Company}" \
    OMARCHY_TEST_EXTERNAL_MODEL="${OMARCHY_TEST_EXTERNAL_MODEL-LF24T35}" \
    OMARCHY_TEST_EXTERNAL_SERIAL="${OMARCHY_TEST_EXTERNAL_SERIAL-HX5X721467}" \
    OMARCHY_TEST_EXTRA_EXTERNALS="${OMARCHY_TEST_EXTRA_EXTERNALS:-}" \
    OMARCHY_TEST_EXTERNAL_X="${OMARCHY_TEST_EXTERNAL_X:-1920}" \
    OMARCHY_TEST_EXTERNAL_TRANSFORM="${OMARCHY_TEST_EXTERNAL_TRANSFORM:-0}" \
    OMARCHY_TEST_EXTERNAL_WIDTH="${OMARCHY_TEST_EXTERNAL_WIDTH:-1920}" \
    OMARCHY_TEST_EXTERNAL_HEIGHT="${OMARCHY_TEST_EXTERNAL_HEIGHT:-1080}" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_LOG="$eval_log" \
    OMARCHY_TEST_INTERNAL_SCALE="${OMARCHY_TEST_INTERNAL_SCALE:-2}" \
    OMARCHY_TEST_INTERNAL_X="${OMARCHY_TEST_INTERNAL_X:-0}" \
    OMARCHY_TEST_INTERNAL_Y="${OMARCHY_TEST_INTERNAL_Y:-0}" \
    OMARCHY_TEST_INTERNAL_DISABLED="${OMARCHY_TEST_INTERNAL_DISABLED:-false}" \
    OMARCHY_TEST_EXTERNAL_ACTIVE="${OMARCHY_TEST_EXTERNAL_ACTIVE:-false}" \
    OMARCHY_TEST_CLAMSHELL="${OMARCHY_TEST_CLAMSHELL:-false}" \
    "$ROOT/bin/omarchy-hyprland-monitor-clamshell"
}

# Regression (#7265, #7301): with scale = "auto" the compositor's resolution of
# it IS the configured scale, not a transient to correct. Forcing a number here
# made the scale flap: every idle-wake applied the fallback 2, every config
# reload resolved auto back to the panel's own value.
write_auto_monitor_config
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 run_clamshell
! grep -F 'scale = ' "$eval_log" >/dev/null || fail "clamshell recovery leaves an auto-scaled panel alone"
[[ ! -f $scale_state ]] || fail "clamshell recovery does not remember transient scale"
pass "clamshell recovery leaves an auto-scaled panel alone"

# The same delegation through the shipped default config, where "auto" reaches
# the panel via the catch-all rule's bare-word reference to the local.
write_default_auto_config
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 run_clamshell
! grep -F 'scale = ' "$eval_log" >/dev/null || fail "clamshell recovery leaves the shipped auto default alone"
pass "clamshell recovery leaves the shipped auto default alone"

# A numeric config keeps both sync behaviors: a matching active scale is not
# reapplied, and a drifted one is corrected back to the configured value.
write_internal_monitor_config
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=1.25 run_clamshell
! grep -F 'scale = ' "$eval_log" >/dev/null || fail "clamshell recovery does not reapply matching scale"
pass "clamshell recovery avoids redundant scale apply"

write_internal_monitor_config
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 run_clamshell
grep -F 'scale = 1.25' "$eval_log" >/dev/null || fail "clamshell recovery corrects a drifted numeric scale"
pass "clamshell recovery corrects a drifted numeric scale"

write_auto_monitor_config
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

# Docking with the lid shut turns the panel off, and the compositor slides the
# externals over to fill its place. What the layout keeps is where the panel sat
# relative to an external, so that is what gets remembered. Every case below uses
# the layout measured on a real machine: panel at 0, external at 1920 while both
# are on (offset -1920), then the external at 0 and the panel back at 1920 once
# the undock's reload has re-enabled it with "auto".
dock() {
  OMARCHY_TEST_INTERNAL_X="${OMARCHY_TEST_INTERNAL_X:-0}" OMARCHY_TEST_EXTERNAL_ACTIVE=true OMARCHY_TEST_CLAMSHELL=true run_clamshell
}

undock() {
  OMARCHY_TEST_UNDOCK=true OMARCHY_TEST_INTERNAL_DISABLED=true OMARCHY_TEST_EXTERNAL_ACTIVE=true \
    OMARCHY_TEST_INTERNAL_X="${OMARCHY_TEST_INTERNAL_X:-1920}" OMARCHY_TEST_EXTERNAL_X="${OMARCHY_TEST_EXTERNAL_X:-0}" run_clamshell
}

write_default_auto_config
rm -f "$position_state"
dock
[[ -f $position_state ]] || fail "clamshell disable remembers internal position"
[[ $(sed -n 1p "$position_state") == "-1920x0" ]] || fail "clamshell disable remembers the panel's offset from the external"
[[ $(sed -n 2p "$position_state") == "Samsung_Electric_Company_LF24T35_HX5X721467" ]] || fail "clamshell disable remembers the external layout beside it"
pass "clamshell disable remembers the panel's offset and the external layout"

# The undock the stock config actually sees: scale = "auto" leaves scale sync
# nothing to do, so only the dedicated restore can put the panel back.
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=2 undock
grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "undock puts the panel back on its side of the moved external"
grep -F 'scale = 2' "$eval_log" >/dev/null || fail "undock restore keeps the panel's live scale"
[[ ! -f $position_state ]] || fail "undock spends the remembered offset"
pass "undock restores the panel beside the external under the stock auto config"

# Same with a numeric scale that already matches: scale sync returns early too.
write_catchall_scale_only_config
remember_position "-1920x0"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=1.5 undock
grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "undock restores the position when the scale already matches"
pass "undock restores the position when the scale already matches"

# A panel the reload already put in the right place needs no second apply.
write_default_auto_config
remember_position "-1920x0"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_X=-1920 undock
! grep -F 'position = ' "$eval_log" >/dev/null || fail "undock does not reapply a position the panel already holds"
[[ ! -f $position_state ]] || fail "undock spends the offset even when nothing needed moving"
pass "undock skips a restore that has nothing to move"

# An offset captured at another desk must not be applied: the externals now
# present differ from those it was captured beside. It is dropped, not kept.
remember_position "-1920x0" "DP-1:1920x1080"
: >"$eval_log"
OMARCHY_TEST_EXTERNAL_NAME=DP-2 OMARCHY_TEST_EXTERNAL_MAKE= OMARCHY_TEST_EXTERNAL_MODEL= OMARCHY_TEST_EXTERNAL_SERIAL= \
  OMARCHY_TEST_EXTERNAL_WIDTH=3840 OMARCHY_TEST_EXTERNAL_HEIGHT=2160 undock
! grep -F 'position = ' "$eval_log" >/dev/null || fail "undock ignores an offset remembered beside different monitors"
[[ ! -f $position_state ]] || fail "undock drops an offset remembered beside different monitors"
pass "undock ignores an offset from a different desk"

# The offset is relative: wherever the external ended up, the panel goes the same
# distance from it, not back to the absolute spot it once held.
remember_position "-1920x0"
: >"$eval_log"
OMARCHY_TEST_EXTERNAL_X=2500 undock
grep -F 'position = "580x0"' "$eval_log" >/dev/null || fail "undock applies the offset to the external's new position"
! grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "undock does not reuse the offset as an absolute position"
pass "undock applies the remembered offset relative to the external's new position"

# Monitors that report the same identity can swap connectors while docked, so
# none of them can anchor the offset. With nothing else to measure from, nothing
# is saved; with a monitor of its own among them, that one is the anchor and the
# twins swapping places changes nothing.
twin() {
  printf '{"name":"%s","make":"Samsung Electric Company","model":"LF24T35","serial":"HX5X721467","disabled":false,"scale":1,"transform":0,"x":%s,"y":0,"width":1920,"height":1080}' "$1" "$2"
}
unique() {
  printf '{"name":"DP-1","make":"Dell","model":"U2723QE","serial":"UNIQ1","disabled":false,"scale":1,"transform":0,"x":%s,"y":0,"width":1920,"height":1080}' "$1"
}

write_default_auto_config
rm -f "$position_state"
OMARCHY_TEST_EXTRA_EXTERNALS=$(twin HDMI-A-2 3840) dock
[[ ! -f $position_state ]] || fail "clamshell disable saves nothing when every external has a twin"
pass "clamshell disable saves nothing when no external can anchor the offset"

remember_position "-1920x0" "Samsung_Electric_Company_LF24T35_HX5X721467,Samsung_Electric_Company_LF24T35_HX5X721467"
: >"$eval_log"
OMARCHY_TEST_EXTRA_EXTERNALS=$(twin HDMI-A-2 1920) undock
! grep -F 'position = ' "$eval_log" >/dev/null || fail "undock restores nothing when every external has a twin"
pass "undock restores nothing when no external can anchor the offset"

rm -f "$position_state"
OMARCHY_TEST_EXTRA_EXTERNALS="$(twin HDMI-A-2 3840),$(unique 5760)" dock
[[ $(sed -n 1p "$position_state") == "-5760x0" ]] || fail "clamshell disable anchors on the external that has no twin"
: >"$eval_log"
OMARCHY_TEST_EXTRA_EXTERNALS="$(twin HDMI-A-1 1920),$(unique 2500)" OMARCHY_TEST_EXTERNAL_NAME=HDMI-A-2 undock
grep -F 'position = "-3260x0"' "$eval_log" >/dev/null || fail "undock follows the external with no twin even when the twins swap connectors"
pass "undock anchors on the external that has no twin, whichever connectors the twins use"

# A serial names the physical monitor, so a resolution change is still the same desk.
remember_position "-1920x0"
: >"$eval_log"
OMARCHY_TEST_EXTERNAL_WIDTH=3840 OMARCHY_TEST_EXTERNAL_HEIGHT=2160 undock
grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "undock restores beside a monitor whose resolution changed"
pass "undock restores beside a monitor whose resolution changed"

# Two identical monitors are told apart by serial, wherever they are plugged in.
remember_position "-1920x0"
: >"$eval_log"
OMARCHY_TEST_EXTERNAL_SERIAL=OTHER123 undock
! grep -F 'position = ' "$eval_log" >/dev/null || fail "undock ignores an offset remembered beside an identical monitor with another serial"
pass "undock ignores an offset remembered beside an identical monitor with another serial"

# The same monitor on another port or dock is still the same desk.
remember_position "-1920x0"
: >"$eval_log"
OMARCHY_TEST_EXTERNAL_NAME=DP-3 undock
grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "undock matches the same monitor on another connector"
pass "undock matches the same monitor on another connector"

# A monitor with a blank serial matches on make, model and size; one with no
# identity at all falls back to its connector name and size.
remember_position "-1920x0" "Samsung_Electric_Company_LF24T35:1920x1080"
: >"$eval_log"
OMARCHY_TEST_EXTERNAL_SERIAL= undock
grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "undock matches a serial-less monitor on make, model and size"
remember_position "-1920x0" "HDMI-A-1:1920x1080"
: >"$eval_log"
OMARCHY_TEST_EXTERNAL_MAKE= OMARCHY_TEST_EXTERNAL_MODEL= OMARCHY_TEST_EXTERNAL_SERIAL= undock
grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "undock falls back to the connector name for a monitor with no identity"
pass "undock falls back from serial to make and model to connector name"

# Without a serial the size is all that tells two monitors of one model apart.
remember_position "-1920x0" "Samsung_Electric_Company_LF24T35:1920x1080"
: >"$eval_log"
OMARCHY_TEST_EXTERNAL_SERIAL= OMARCHY_TEST_EXTERNAL_WIDTH=3840 OMARCHY_TEST_EXTERNAL_HEIGHT=2160 undock
! grep -F 'position = ' "$eval_log" >/dev/null || fail "undock tells serial-less monitors of one model apart by size"
pass "undock tells serial-less monitors of one model apart by size"

# An offset that lands on an external is never applied, however it got there.
remember_position "-500x0"
: >"$eval_log"
undock
! grep -F 'position = ' "$eval_log" >/dev/null || fail "undock never restores a position that overlaps an external"
[[ ! -f $position_state ]] || fail "undock still spends an offset it declined to apply"
pass "undock refuses a remembered offset that would overlap an external"

# A rotated external is as wide as it is tall, in layout pixels: 1080 here, not 1920.
remember_position "1100x0"
: >"$eval_log"
undock
! grep -F 'position = ' "$eval_log" >/dev/null || fail "undock sees an unrotated external in the way"
remember_position "1100x0"
: >"$eval_log"
OMARCHY_TEST_EXTERNAL_TRANSFORM=1 undock
grep -F 'position = "1100x0"' "$eval_log" >/dev/null || fail "undock restores beside a rotated external"
pass "undock measures a rotated external by its rotated size"

# Negative coordinates on either axis round-trip.
write_default_auto_config
rm -f "$position_state"
OMARCHY_TEST_INTERNAL_Y=-1080 dock
[[ $(sed -n 1p "$position_state") == "-1920x-1080" ]] || fail "clamshell disable remembers a negative offset"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_Y=-1080 undock
grep -F 'position = "-1920x-1080"' "$eval_log" >/dev/null || fail "undock restores a remembered negative offset"
pass "clamshell disable/undock round-trips a negative offset"

# A configured position for the internal output is applied by the reload itself,
# so the restore leaves it alone -- even over a remembered one.
for config in write_internal_monitor_config write_internal_monitor_position_var_config; do
  "$config"
  remember_position "-1920x0"
  : >"$eval_log"
  OMARCHY_TEST_INTERNAL_X=0 OMARCHY_TEST_INTERNAL_SCALE=1.25 undock
  ! grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "a configured internal position wins over a remembered one ($config)"
done
pass "a configured internal position wins over a remembered one"

# A configured rule still positions a panel that scale recovery brings back.
write_internal_monitor_config
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'position = "0x0"' "$eval_log" >/dev/null || fail "clamshell recovery uses configured internal position"
grep -F 'scale = 1.25' "$eval_log" >/dev/null || fail "clamshell recovery uses configured internal scale"
pass "clamshell recovery uses configured internal monitor rule"

# Scale recovery of a panel that is still off, with nothing remembered, needs a
# number: the historical default 2, and Hyprland's own "auto" position.
write_auto_monitor_config
rm -f "$scale_state" "$position_state"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 2' "$eval_log" >/dev/null || fail "clamshell recovery falls back to the default scale"
grep -F 'position = "auto"' "$eval_log" >/dev/null || fail "clamshell recovery falls back to auto position"
pass "clamshell recovery falls back to the default scale and position"

# A corrupted or unsafe state file must not reach hyprctl verbatim.
for bad in 'not-a-position' '0x0", disabled = false }) -- '; do
  write_default_auto_config
  remember_position "$bad"
  : >"$eval_log"
  undock
  ! grep -F 'position = ' "$eval_log" >/dev/null || fail "undock never forwards a bad position state file"
  ! grep -F 'disabled = false' "$eval_log" >/dev/null || fail "undock never forwards unsafe content from the position state file"
done
remember_position "-1920x0" 'Samsung:1920x1080", disabled = false }) -- '
: >"$eval_log"
undock
! grep -F 'position = ' "$eval_log" >/dev/null || fail "undock refuses an unsafe layout line"
pass "undock ignores a corrupted or unsafe position state file"

# hyprctl is expected to report integer coordinates; anything else must not be
# written out as a trusted offset.
write_default_auto_config
rm -f "$position_state"
OMARCHY_TEST_INTERNAL_X="1920.5" dock
[[ ! -f $position_state ]] || fail "clamshell disable does not remember a non-integer position"
pass "clamshell disable ignores a non-integer reported position"

# A user-toggled manual disable owns the panel's state independently -- the
# clamshell layer must not touch scale or position at all while it is set.
write_auto_monitor_config
rm -f "$scale_state" "$position_state"
mkdir -p "$state_dir"
: >"$manual_disable_flag"
OMARCHY_TEST_INTERNAL_SCALE=1.6 dock
[[ ! -f $scale_state ]] || fail "manual disable prevents remembering internal scale"
[[ ! -f $position_state ]] || fail "manual disable prevents remembering internal position"
rm -f "$manual_disable_flag"
pass "manual disable prevents the clamshell layer from touching scale or position"

# A poll tick that re-runs disable_internal while already docked (the panel
# already off) must not clobber the remembered offset with the now-empty read
# of a disabled panel.
write_default_auto_config
rm -f "$position_state"
dock
OMARCHY_TEST_INTERNAL_DISABLED=true OMARCHY_TEST_EXTERNAL_ACTIVE=true OMARCHY_TEST_CLAMSHELL=true run_clamshell
[[ $(sed -n 1p "$position_state") == "-1920x0" ]] || fail "repeated clamshell disable does not clobber the remembered offset"
pass "repeated clamshell disable while already docked keeps the remembered offset"

# Each dock captures the panel's *current* offset, so a rearrangement made
# while undocked must not leave a stale value from an earlier dock cycle.
rm -f "$position_state"
dock
: >"$eval_log"
undock
grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "first undock restores the initial offset"

OMARCHY_TEST_INTERNAL_X=-2560 dock
: >"$eval_log"
undock
grep -F 'position = "-4480x0"' "$eval_log" >/dev/null || fail "second undock restores the rearranged offset"
! grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "second undock does not fall back to the stale first offset"
pass "successive dock/undock cycles track a rearranged offset without staleness"

# A stale offset must never leak into later scale corrections, which are
# idle-wake business and not part of leaving clamshell: they follow the panel.
write_catchall_scale_only_config
remember_position "-1920x0"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 run_clamshell
! grep -F 'position = "-1920x0"' "$eval_log" >/dev/null || fail "a live scale correction does not carry the remembered offset"
pass "a live scale correction does not reuse the remembered offset"

# Scale correction of a panel that is already on keeps its place, instead of
# sending it to the end of the layout with "auto".
rm -f "$position_state"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 OMARCHY_TEST_INTERNAL_X=0 run_clamshell
grep -F 'scale = 1.5' "$eval_log" >/dev/null || fail "a live scale correction applies the configured scale"
grep -F 'position = "0x0"' "$eval_log" >/dev/null || fail "a live scale correction keeps the panel's live position"
pass "a live scale correction keeps the panel where it is"

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

# Regression: specific-output rule referencing the omarchy_monitor_scale
# variable must resolve to the variable's value, not fall back to the default.
write_internal_monitor_var_config
rm -f "$scale_state"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.5' "$eval_log" >/dev/null || fail "clamshell recovery resolves omarchy_monitor_scale variable reference"
pass "clamshell recovery resolves omarchy_monitor_scale variable reference"

# An explicit "auto" on the internal rule is a value, not a variable reference,
# so it must not pick up an unrelated omarchy_monitor_scale local.
write_internal_monitor_auto_config
remember_scale 1.75
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.75' "$eval_log" >/dev/null || fail "clamshell recovery keeps auto scale off the omarchy_monitor_scale local"
pass "clamshell recovery keeps auto scale off the omarchy_monitor_scale local"

# The catch-all rule does not apply to an output that has its own rule.
write_internal_monitor_unresolvable_config
remember_scale 1.75
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.75' "$eval_log" >/dev/null || fail "clamshell recovery ignores the catch-all rule when the internal panel has its own"
pass "clamshell recovery ignores the catch-all rule when the internal panel has its own"

write_catch_all_var_config
rm -f "$scale_state"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.5' "$eval_log" >/dev/null || fail "clamshell recovery resolves a quoted scale through the catch-all rule"
pass "clamshell recovery resolves a quoted scale through the catch-all rule"

write_commented_catch_all_var_config
rm -f "$scale_state"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.25' "$eval_log" >/dev/null || fail "clamshell recovery ignores a trailing comment on the scale local"
pass "clamshell recovery ignores a trailing comment on the scale local"

write_internal_monitor_position_var_config
rm -f "$scale_state"
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'position = "0x0"' "$eval_log" >/dev/null || fail "clamshell recovery resolves a position variable reference"
pass "clamshell recovery resolves a position variable reference"

# An internal rule that names no scale leaves the catch-all to supply one. Only
# a rule that names a scale keeps the catch-all away from the internal panel.
write_internal_monitor_scaleless_config
remember_scale 1.75
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1' "$eval_log" >/dev/null || fail "clamshell recovery takes the catch-all scale when the internal rule omits one"
! grep -F 'scale = 1.75' "$eval_log" >/dev/null || fail "clamshell recovery prefers the catch-all scale over the remembered one"
pass "clamshell recovery takes the catch-all scale when the internal rule omits one"

# Half of `3 / 2` is not the scale the user asked for.
write_expression_scale_config
remember_scale 1.75
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.75' "$eval_log" >/dev/null || fail "clamshell recovery leaves an expression scale unresolved"
pass "clamshell recovery leaves an expression scale unresolved"

# An expression is Hyprland's to evaluate, not this parser's: like "auto", it
# names no number to correct an enabled panel toward.
write_expression_scale_config
remember_scale 1.75
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 run_clamshell
! grep -F 'scale = ' "$eval_log" >/dev/null || fail "clamshell recovery leaves an expression-scaled panel alone"
pass "clamshell recovery leaves an expression-scaled panel alone"

# A quoted value is a string, not a reference to a local of the same name.
write_shadowed_auto_config
remember_scale 1.75
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.75' "$eval_log" >/dev/null || fail "clamshell recovery does not resolve a quoted scale against a local"
pass "clamshell recovery does not resolve a quoted scale against a local"

# An explicit "auto" on the internal rule delegates just the same: while the
# panel is enabled, it is not corrected toward the remembered scale.
write_shadowed_auto_config
remember_scale 1.75
: >"$eval_log"
OMARCHY_TEST_INTERNAL_SCALE=3 run_clamshell
! grep -F 'scale = ' "$eval_log" >/dev/null || fail "clamshell recovery leaves an explicitly auto panel alone"
pass "clamshell recovery leaves an explicitly auto panel alone"

# Half of `3 / 2` is no better inside the rule than inside a local.
write_expression_rule_config
remember_scale 1.75
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.75' "$eval_log" >/dev/null || fail "clamshell recovery leaves an expression scale in a rule unresolved"
pass "clamshell recovery leaves an expression scale in a rule unresolved"

# A commented-out output must not pass for a rule the internal panel owns.
write_commented_rule_config
remember_scale 1.75
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.5' "$eval_log" >/dev/null || fail "clamshell recovery does not read a rule out of a trailing comment"
pass "clamshell recovery does not read a rule out of a trailing comment"

# Nor must a commented-out key displace the real one.
write_commented_internal_rule_config
remember_scale 1.75
: >"$eval_log"
OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
grep -F 'scale = 1.25' "$eval_log" >/dev/null || fail "clamshell recovery does not read a scale out of a trailing comment"
pass "clamshell recovery does not read a scale out of a trailing comment"

for config in nested_table semicolon block_comment; do
  "write_${config}_config"
  remember_scale 1.75
  : >"$eval_log"
  OMARCHY_TEST_INTERNAL_DISABLED=true run_clamshell
  grep -F 'position = "0x0"' "$eval_log" >/dev/null || fail "clamshell recovery reads the position out of a ${config//_/ } rule"
  grep -F 'scale = 1.25' "$eval_log" >/dev/null || fail "clamshell recovery reads the scale out of a ${config//_/ } rule"
  pass "clamshell recovery reads a ${config//_/ } rule"
done
