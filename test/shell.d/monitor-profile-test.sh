#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
home_dir="$test_tmp/home"
runtime_dir="$test_tmp/runtime"
monitors_file="$test_tmp/monitors.json"
hyprctl_log="$test_tmp/hyprctl.log"
mkdir -p "$fake_bin" "$home_dir" "$runtime_dir"

cat >"$fake_bin/hyprctl" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$OMARCHY_TEST_HYPRCTL_LOG"

if [[ ${1:-} == "monitors" && ${2:-} == "all" && ${3:-} == "-j" ]]; then
  cat "$OMARCHY_TEST_MONITORS_FILE"
elif [[ ${1:-} == "monitors" && ${2:-} == "-j" ]]; then
  jq '[.[] | select(.disabled != true and .width > 0 and .height > 0)]' "$OMARCHY_TEST_MONITORS_FILE"
elif [[ ${1:-} == "workspaces" && ${2:-} == "-j" ]]; then
  printf '%s\n' '[{"id":1,"monitor":"DP-1"},{"id":2,"monitor":"DP-2"}]'
elif [[ ${1:-} == "eval" ]]; then
  lua="${2:-}"
  name=$(sed -n 's/.*output = "\([^"]*\)".*/\1/p' <<<"$lua")
  [[ -n $name ]] || exit 1

  if [[ $lua != *"disabled = true"* && $name == "${OMARCHY_TEST_FAIL_MONITOR:-}" ]]; then
    exit 1
  fi

  if [[ $lua == *"disabled = true"* ]]; then
    jq --arg name "$name" 'map(if .name == $name then . + {disabled:true, dpmsStatus:false, width:0, height:0, focused:false} else . end)' \
      "$OMARCHY_TEST_MONITORS_FILE" >"$OMARCHY_TEST_MONITORS_FILE.tmp"
  else
    mode=$(sed -n 's/.*mode = "\([^"]*\)".*/\1/p' <<<"$lua")
    position=$(sed -n 's/.*position = "\([^"]*\)".*/\1/p' <<<"$lua")
    scale=$(sed -n 's/.*scale = \([^,}]*\).*/\1/p' <<<"$lua" | tr -d ' ')
    transform=$(sed -n 's/.*transform = \([^,}]*\).*/\1/p' <<<"$lua" | tr -d ' ')
    width="${mode%%x*}"
    remainder="${mode#*x}"
    height="${remainder%%@*}"
    x="${position%x*}"
    y="${position##*x}"
    jq --arg name "$name" --arg mode "$mode" --argjson width "$width" --argjson height "$height" \
      --argjson x "$x" --argjson y "$y" --argjson scale "$scale" --argjson transform "$transform" '
        map(if .name == $name then . + {
          disabled:false, dpmsStatus:true, width:$width, height:$height,
          x:$x, y:$y, scale:$scale, transform:$transform, currentFormat:$mode, focused:false
        } else . end)
      ' "$OMARCHY_TEST_MONITORS_FILE" >"$OMARCHY_TEST_MONITORS_FILE.tmp"
  fi
  mv "$OMARCHY_TEST_MONITORS_FILE.tmp" "$OMARCHY_TEST_MONITORS_FILE"
elif [[ ${1:-} == "dispatch" ]]; then
  exit 0
else
  exit 1
fi
SH

cat >"$fake_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$fake_bin/sleep" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$fake_bin"/*

run_profile() {
  HOME="$home_dir" \
    XDG_CONFIG_HOME="$home_dir/.config" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$fake_bin:$PATH" \
    OMARCHY_TEST_MONITORS_FILE="$monitors_file" \
    OMARCHY_TEST_HYPRCTL_LOG="$hyprctl_log" \
    OMARCHY_TEST_FAIL_MONITOR="${OMARCHY_TEST_FAIL_MONITOR:-}" \
    "$ROOT/bin/omarchy-monitor-profile" "$@"
}

write_dual_state() {
  cat >"$monitors_file" <<'JSON'
[
  {"name":"DP-1","description":"Internal","disabled":false,"dpmsStatus":true,"focused":false,"width":1920,"height":1080,"refreshRate":60,"currentFormat":"1920x1080@60.00Hz","x":0,"y":0,"scale":1,"transform":0,"mirrorOf":"none"},
  {"name":"DP-2","description":"External","disabled":false,"dpmsStatus":true,"focused":true,"width":2560,"height":1440,"refreshRate":144,"currentFormat":"2560x1440@144.00Hz","x":1920,"y":0,"scale":1,"transform":0,"mirrorOf":"none"}
]
JSON
}

write_external_state() {
  cat >"$monitors_file" <<'JSON'
[
  {"name":"DP-1","description":"Internal","disabled":true,"dpmsStatus":false,"focused":false,"width":1920,"height":1080,"refreshRate":60,"currentFormat":"1920x1080@60.00Hz","x":0,"y":0,"scale":1,"transform":0,"mirrorOf":"none"},
  {"name":"DP-2","description":"External","disabled":false,"dpmsStatus":true,"focused":true,"width":2560,"height":1440,"refreshRate":144,"currentFormat":"2560x1440@144.00Hz","x":0,"y":0,"scale":1,"transform":0,"mirrorOf":"none"}
]
JSON
}

write_internal_state() {
  cat >"$monitors_file" <<'JSON'
[
  {"name":"DP-1","description":"Internal","disabled":false,"dpmsStatus":true,"focused":true,"width":1920,"height":1080,"refreshRate":60,"currentFormat":"1920x1080@60.00Hz","x":0,"y":0,"scale":1,"transform":0,"mirrorOf":"none"},
  {"name":"DP-2","description":"External","disabled":true,"dpmsStatus":false,"focused":false,"width":2560,"height":1440,"refreshRate":144,"currentFormat":"2560x1440@144.00Hz","x":0,"y":0,"scale":1,"transform":0,"mirrorOf":"none"}
]
JSON
}

write_dual_state
run_profile save desk
profile="$home_dir/.config/omarchy/monitor-profiles/desk.json"
[[ -r $profile ]] || fail "monitor profile saves a profile file"
jq -e '.name == "desk" and .primary == "DP-2" and [.monitors[].name] == ["DP-1", "DP-2"]' "$profile" >/dev/null ||
  fail "monitor profile captures active monitors and focus"
pass "monitor profile captures the current layout"

write_external_state
run_profile save external
jq -e '.primary == "DP-2" and [.monitors[].name] == ["DP-2"] and .monitors[0].x == 0' \
  "$home_dir/.config/omarchy/monitor-profiles/external.json" >/dev/null ||
  fail "monitor profile saves a single-output layout"
pass "monitor profile saves single-output layouts"

profiles=$(run_profile list --json)
jq -e '.active == "external" and [.profiles[].name] == ["desk", "external"]' <<<"$profiles" >/dev/null ||
  fail "monitor profile lists saved profiles and the active one" "$profiles"
pass "monitor profile lists saved profiles"

printf '%s\n' '{"version":1,"name":"broken"}' >"$home_dir/.config/omarchy/monitor-profiles/broken.json"
printf '%s\n' broken >"$home_dir/.local/state/omarchy/monitor-profile"
[[ -z $(run_profile current) ]] || fail "monitor profile accepts corrupt active state"
profiles=$(run_profile list --json)
jq -e '.active == "" and [.profiles[].name] == ["desk", "external"]' <<<"$profiles" >/dev/null ||
  fail "monitor profile lists corrupt profile data" "$profiles"
pass "monitor profile ignores corrupt saved state"

write_internal_state
: >"$hyprctl_log"
run_profile apply desk
grep -F 'output = "DP-1", mode = "1920x1080@60.00Hz", position = "5504x0"' "$hyprctl_log" >/dev/null ||
  fail "monitor profile stages the first target outside the current and desired layouts"
grep -F 'output = "DP-2", mode = "2560x1440@144.00Hz", position = "8448x0"' "$hyprctl_log" >/dev/null ||
  fail "monitor profile stages later targets after earlier ones"
pass "monitor profile stages multiple targets without overlap"

write_internal_state
: >"$hyprctl_log"
OMARCHY_TEST_FAIL_MONITOR=DP-2
if run_profile apply external >/dev/null 2>&1; then
  fail "monitor profile reports a destination modeset failure"
fi
OMARCHY_TEST_FAIL_MONITOR=""
jq -e 'any(.[]; .name == "DP-1" and .disabled == false and .x == 0 and .y == 0) and
  any(.[]; .name == "DP-2" and .disabled == true)' "$monitors_file" >/dev/null ||
  fail "monitor profile restores the previous layout after a destination failure"
grep -F 'workspace.move({ workspace = "1", monitor = "DP-1" })' "$hyprctl_log" >/dev/null ||
  fail "monitor profile rollback restores original workspace assignments"
pass "monitor profile rolls back a failed switch"

write_internal_state
: >"$hyprctl_log"
run_profile apply external

stage_line=$(grep -nF 'output = "DP-2", mode = "2560x1440@144.00Hz", position = "3584x0"' "$hyprctl_log" | cut -d: -f1)
disable_line=$(grep -nF 'output = "DP-1", disabled = true' "$hyprctl_log" | cut -d: -f1)
final_line=$(grep -nF 'output = "DP-2", mode = "2560x1440@144.00Hz", position = "0x0"' "$hyprctl_log" | cut -d: -f1 | tail -n 1)
[[ -n $stage_line && -n $disable_line && -n $final_line ]] ||
  fail "monitor profile emits the complete transactional switch" "$(<"$hyprctl_log")"
(( stage_line < disable_line && disable_line < final_line )) ||
  fail "monitor profile activates the destination before disabling the source" "$(<"$hyprctl_log")"
grep -F 'workspace.move({ workspace = "1", monitor = "DP-2" })' "$hyprctl_log" >/dev/null ||
  fail "monitor profile moves source workspaces to the destination"
pass "monitor profile applies layouts transactionally"

jq -e 'any(.[]; .name == "DP-2" and .disabled == false and .x == 0 and .y == 0) and
  any(.[]; .name == "DP-1" and .disabled == true)' "$monitors_file" >/dev/null ||
  fail "monitor profile settles into the saved layout"
[[ $(run_profile current) == "external" ]] || fail "monitor profile persists the active profile"
pass "monitor profile persists the selected layout"

jq 'map(if .name == "DP-2" then .dpmsStatus = false else . end)' "$monitors_file" >"$monitors_file.tmp"
mv "$monitors_file.tmp" "$monitors_file"
: >"$hyprctl_log"
run_profile restore
if grep -E '^(eval|dispatch)' "$hyprctl_log" >/dev/null; then
  fail "matching monitor profile restore wakes a DPMS-blanked display" "$(<"$hyprctl_log")"
fi
pass "monitor profile leaves idle display power state alone"

jq '[.[] | select(.name == "DP-1")]' "$monitors_file" >"$monitors_file.tmp"
mv "$monitors_file.tmp" "$monitors_file"
: >"$hyprctl_log"
run_profile restore
jq -e 'any(.[]; .name == "DP-1" and .disabled == false and .width > 0 and .height > 0)' \
  "$monitors_file" >/dev/null || fail "monitor profile recovery enables an available fallback output"
[[ $(run_profile current) == "external" ]] || fail "monitor profile recovery keeps the intended profile selected"
pass "monitor profile recovers a usable output when the selected display disconnects"

run_profile deactivate
[[ -z $(run_profile current) ]] || fail "monitor profile deactivates reconnect recovery"
pass "monitor profile can be deactivated"

write_external_state
jq '[.[] | select(.name == "DP-2")]' "$monitors_file" >"$monitors_file.tmp"
mv "$monitors_file.tmp" "$monitors_file"
: >"$hyprctl_log"
if run_profile apply desk >/dev/null 2>&1; then
  fail "monitor profile refuses a layout with a disconnected output"
fi
if grep -E '^(eval|dispatch)' "$hyprctl_log" >/dev/null; then
  fail "monitor profile changes nothing when a destination is disconnected" "$(<"$hyprctl_log")"
fi
pass "monitor profile leaves the current display usable when a destination is missing"

if run_profile save '../bad' >/dev/null 2>&1; then
  fail "monitor profile accepts a path as a profile name"
fi
pass "monitor profile validates profile names"

run_profile remove external
[[ ! -e $home_dir/.config/omarchy/monitor-profiles/external.json ]] ||
  fail "monitor profile remove deletes the saved profile"
pass "monitor profile removes saved profiles"
