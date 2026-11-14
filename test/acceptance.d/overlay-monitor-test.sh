#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

original_monitors=$(hyprctl -j monitors)
remaining_monitor=$(jq -r 'map(select(.focused))[0].name // .[0].name' <<<"$original_monitors")
remaining_height=$(jq -r --arg name "$remaining_monitor" '.[] | select(.name == $name) | (if (.transform // 0) % 2 == 1 then .width else .height end) / .scale | ceil' <<<"$original_monitors")
# Make the source tall enough that a frozen centered menu would land below
# the remaining display, so a mapped but misplaced menu cannot pass recovery.
tall_height=$((remaining_height * 2 + 1600))
virtual_monitor=""
virtual_sequence=0
read -r original_cursor_x original_cursor_y < <(hyprctl cursorpos | tr ',' ' ')
[[ $original_cursor_x =~ ^-?[0-9]+$ && $original_cursor_y =~ ^-?[0-9]+$ ]] || fail "pointer position can be recorded"

focus_monitor() {
  local name="$1" x y
  read -r x y < <(hyprctl -j monitors | jq -er --arg name "$name" '.[] | select(.name == $name) | [.x + 64, .y + 64] | @tsv')
  [[ $x =~ ^-?[0-9]+$ && $y =~ ^-?[0-9]+$ ]] || return 1
  # Keep pointer-driven focus on the selected output throughout the probe.
  hyprctl eval "hl.dispatch(hl.dsp.cursor.move({ x = $x, y = $y }))" >/dev/null
  hyprctl dispatch "hl.dsp.focus({ monitor = \"$name\" })" >/dev/null
}

cleanup() {
  local status=$? cleanup_failed=0 x y
  trap - EXIT
  omarchy-shell shell hide omarchy.menu >/dev/null 2>&1 || { printf 'cleanup: menu close failed\n' >&2; cleanup_failed=1; }
  if [[ -n $virtual_monitor ]]; then
    hyprctl output remove "$virtual_monitor" >/dev/null 2>&1 || { printf 'cleanup: output removal failed\n' >&2; cleanup_failed=1; }
  fi
  focus_monitor "$remaining_monitor" >/dev/null 2>&1 || { printf 'cleanup: monitor focus failed\n' >&2; cleanup_failed=1; }
  hyprctl eval "hl.dispatch(hl.dsp.cursor.move({ x = $original_cursor_x, y = $original_cursor_y }))" >/dev/null 2>&1 || { printf 'cleanup: pointer move failed\n' >&2; cleanup_failed=1; }
  read -r x y < <(hyprctl cursorpos | tr ',' ' ') || { printf 'cleanup: pointer read failed\n' >&2; cleanup_failed=1; }
  if [[ $x != "$original_cursor_x" || $y != "$original_cursor_y" ]]; then
    printf 'cleanup: pointer restore mismatch: expected %s,%s; got %s,%s\n' "$original_cursor_x" "$original_cursor_y" "$x" "$y" >&2
    cleanup_failed=1
  fi
  if ((cleanup_failed)); then
    printf 'not ok - overlay monitor cleanup failed\n' >&2
    status=1
  fi
  exit "$status"
}
trap cleanup EXIT

monitor_is_present() {
  hyprctl -j monitors | jq -e --arg name "$virtual_monitor" 'any(.[]; .name == $name)'
}

monitor_is_tall() {
  hyprctl -j monitors | jq -e --arg name "$virtual_monitor" --argjson height "$tall_height" 'any(.[]; .name == $name and .height == $height and .scale == 1)'
}

monitor_is_focused() {
  hyprctl -j monitors | jq -e --arg name "$1" 'any(.[]; .name == $name and .focused)'
}

menu_on_monitor() {
  hyprctl -j layers | jq -e --arg name "$1" '[.[$name].levels["3"][]? | select(.namespace == "omarchy-menu")] | length == 1'
}

monitor_contains() {
  local monitor="$1" text="$2"
  local snapshot="$ARTIFACTS/monitor-text-$$.png"
  local status=0

  if timeout 10 grim -o "$monitor" -s 2 "$snapshot" 2>/dev/null; then
    tesseract "$snapshot" stdout --psm 11 2>/dev/null | grep -Fi -- "$text" >/dev/null || status=$?
  else
    status=1
  fi
  rm -f "$snapshot"
  return "$status"
}

create_source_monitor() {
  local name
  ((virtual_sequence += 1))
  name="omarchy-overlay-$$-$virtual_sequence"
  hyprctl -j monitors | jq -e --arg name "$name" 'all(.[]; .name != $name)' >/dev/null || fail "temporary monitor name is unused"
  virtual_monitor="$name"
  hyprctl output create headless "$virtual_monitor" >/dev/null
  wait_until "temporary overlay monitor appears" 15 monitor_is_present
  hyprctl eval "hl.monitor({ output = \"$virtual_monitor\", mode = \"1920x${tall_height}@60\", position = \"auto\", scale = 1 })" >/dev/null
  wait_until "temporary overlay monitor has tall geometry" 15 monitor_is_tall
  focus_monitor "$virtual_monitor"
  wait_until "temporary overlay monitor is focused" 15 monitor_is_focused "$virtual_monitor"
}

remove_source_monitor() {
  hyprctl output remove "$virtual_monitor" >/dev/null
  virtual_monitor=""
  focus_monitor "$remaining_monitor"
  wait_until "remaining monitor is focused" 15 monitor_is_focused "$remaining_monitor"
}

omarchy-shell shell hide omarchy.menu >/dev/null
wait_until "menu starts closed" 15 layer_absent "omarchy-menu"

# A closed overlay must drop its old output and reopen on a connected one.
create_source_monitor
omarchy-shell shell summon omarchy.menu '{"menu":"root"}' >/dev/null
wait_until "menu opens on temporary monitor" 15 menu_on_monitor "$virtual_monitor"
wait_until "menu renders on temporary monitor" 15 monitor_contains "$virtual_monitor" "Apps"
screenshot "success-overlay-monitor-01-closed-source"
omarchy-shell shell hide omarchy.menu >/dev/null
wait_until "menu unmaps before monitor removal" 15 layer_absent "omarchy-menu"
remove_source_monitor
omarchy-shell shell summon omarchy.menu '{"menu":"root"}' >/dev/null
wait_until "closed menu reopens on remaining monitor" 15 menu_on_monitor "$remaining_monitor"
wait_until "reopened menu renders on remaining monitor" 15 monitor_contains "$remaining_monitor" "Apps"
screenshot "success-overlay-monitor-02-closed-recovered"
omarchy-shell shell hide omarchy.menu >/dev/null
wait_until "reopened menu closes" 15 layer_absent "omarchy-menu"

# Typing freezes the menu's position. Recovery onto a shorter screen must
# unfreeze that position while preserving the search and keyboard handling.
create_source_monitor
omarchy-shell shell summon omarchy.menu '{"menu":"root"}' >/dev/null
wait_until "open recovery menu maps on tall monitor" 15 menu_on_monitor "$virtual_monitor"
wait_until "open recovery menu renders" 15 monitor_contains "$virtual_monitor" "Apps"
screenshot "success-overlay-monitor-03-open-root"
wtype "keybindings"
wait_until "menu search renders on tall monitor" 15 monitor_contains "$virtual_monitor" "Keybindings"
screenshot "success-overlay-monitor-04-open-search"
remove_source_monitor
wait_until "open menu moves to remaining monitor" 15 menu_on_monitor "$remaining_monitor"
wait_until "open menu search renders on shorter monitor" 15 monitor_contains "$remaining_monitor" "Keybindings"
screenshot "success-overlay-monitor-05-open-recovered"
wtype -k Escape
wait_until "recovered menu clears search through keyboard" 15 monitor_contains "$remaining_monitor" "Apps"
wtype -k Escape
wait_until "recovered menu closes through keyboard" 15 layer_absent "omarchy-menu"
