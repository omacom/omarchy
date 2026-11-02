#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The display panel's layout map from the keyboard alone: a temporary second
# monitor gives it something to arrange, then the hint shows, ctrl+j/k/l place
# the shown display below, above and right of the other, and r opens the
# rotate menu.
original_monitors=$(hyprctl -j monitors)
primary=$(jq -r 'map(select(.focused))[0].name // .[0].name' <<<"$original_monitors")
primary_position=$(jq -r --arg name "$primary" '.[] | select(.name == $name) | "\(.x)x\(.y)"' <<<"$original_monitors")
primary_degrees=$(jq -r --arg name "$primary" '.[] | select(.name == $name) | (.transform // 0) % 4 * 90' <<<"$original_monitors")
virtual_monitor=""

# The layout and rotate commands save what they set for the next config load,
# so put the saved settings back too, not just the live arrangement.
settings="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/monitors/settings"
settings_backup=""
if [[ -f $settings ]]; then
  settings_backup=$(mktemp)
  cp "$settings" "$settings_backup"
fi

cleanup() {
  omarchy-shell shell hide omarchy.monitor >/dev/null 2>&1 || true
  if [[ -n $virtual_monitor ]]; then
    hyprctl output remove "$virtual_monitor" >/dev/null 2>&1 || true
  fi
  omarchy-hyprland-monitor-rotate --monitor "$primary" "$primary_degrees" >/dev/null 2>&1 || true
  hyprctl eval "hl.monitor({ output = \"$primary\", position = \"$primary_position\" })" >/dev/null 2>&1 || true
  # Last, since the rotate above saves settings of its own.
  if [[ -n $settings_backup ]]; then
    cp "$settings_backup" "$settings"
    rm -f "$settings_backup"
  else
    rm -f "$settings"
  fi
  hyprctl dispatch "hl.dsp.focus({ monitor = \"$primary\" })" >/dev/null 2>&1 || true
}
trap cleanup EXIT

find_virtual_monitor() {
  virtual_monitor=$(hyprctl -j monitors | jq -r --argjson previous "$original_monitors" '[.[].name | select(. as $name | $previous | map(.name) | index($name) == null)][0] // empty')
  [[ -n $virtual_monitor ]]
}

# Logical rectangles, as the layout map draws them.
primary_is() {
  hyprctl -j monitors | jq -e --arg p "$primary" --arg v "$virtual_monitor" --arg side "$1" '
    def rect: {x, y,
      w: (if (.transform % 2) == 1 then .height else .width end) / .scale,
      h: (if (.transform % 2) == 1 then .width else .height end) / .scale};
    (map(select(.name == $p))[0] | rect) as $a
    | (map(select(.name == $v))[0] | rect) as $b
    | if $side == "below" then $a.y >= $b.y + $b.h
      elif $side == "right" then $a.x >= $b.x + $b.w
      else $a.y + $a.h <= $b.y end'
}

primary_turned() {
  hyprctl -j monitors | jq -e --arg p "$primary" 'any(.[]; .name == $p and .transform == 1)'
}

hyprctl output create headless >/dev/null
wait_until "temporary second monitor appears" 15 find_virtual_monitor
hyprctl eval "hl.monitor({ output = \"$virtual_monitor\", mode = \"1920x1080@60\", position = \"auto\", scale = 1 })" >/dev/null
hyprctl dispatch "hl.dsp.focus({ monitor = \"$primary\" })" >/dev/null

omarchy-shell shell summon omarchy.monitor >/dev/null
wait_until "display panel opens" 15 layer_present "omarchy-keyboard-panel"
sleep 1

# j stops at the last row, the layout map, however many rows sit above it.
for _ in 1 2 3 4 5 6 7 8 9 10; do
  wtype j
  sleep 0.15
done
wait_until "the layout map shows its keys" 15 screen_contains "to arrange"
screenshot "success-monitor-panel-01-layout-hint"
pass "the layout map shows its keys when the keyboard reaches it"

wtype -M ctrl j -m ctrl
wait_until "ctrl+j places the shown display below the other" 15 primary_is below
screenshot "success-monitor-panel-02-below"
pass "ctrl+j places the shown display below the other"

wtype -M ctrl k -m ctrl
wait_until "ctrl+k places the shown display above the other" 15 primary_is above
screenshot "success-monitor-panel-03-above"
pass "ctrl+k places the shown display above the other"

wtype -M ctrl l -m ctrl
wait_until "ctrl+l places the shown display right of the other" 15 primary_is right
screenshot "success-monitor-panel-03b-right"
pass "ctrl+l places the shown display right of the other"

wtype r
wait_until "r opens the rotate menu" 15 screen_contains "Normal"
screenshot "success-monitor-panel-04-rotate-menu"
wtype j
sleep 0.3
wtype -k Return
wait_until "j and Enter in the rotate menu turn the display" 20 primary_turned
screenshot "success-monitor-panel-05-rotated"
pass "r, j and Enter rotate the shown display a quarter turn"

wtype -k Escape
wait_until "Escape closes the display panel" 15 layer_absent "omarchy-keyboard-panel"
pass "the display panel's layout and rotation are reachable from the keyboard"
