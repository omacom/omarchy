#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

CONFIG_FILE="$HOME/.config/omarchy/shell.json"
DEFAULTS_FILE="$OMARCHY_PATH/config/omarchy/shell.json"
config_backup=$(mktemp)
config_existed=0

if [[ -f $CONFIG_FILE ]]; then
  cp "$CONFIG_FILE" "$config_backup"
  config_existed=1
fi

restore_bar_config() {
  omarchy-shell shell hide omarchy.menu >/dev/null 2>&1 || true

  if ((config_existed)); then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cp "$config_backup" "$CONFIG_FILE"
  else
    rm -f "$CONFIG_FILE"
  fi

  omarchy-shell shell reloadConfig >/dev/null 2>&1 || true
  rm -f "$config_backup"
}

trap restore_bar_config EXIT

bar_is_vertical() {
  local width height

  read -r width height < <(hyprctl -j layers | jq -r '
    [.. | objects | select(.namespace? == "omarchy-bar")][0]
    | [.w, .h] | @tsv
  ')

  [[ $width =~ ^[0-9]+$ && $height =~ ^[0-9]+$ ]] && ((width < height))
}

bar_is_horizontal() {
  local width height

  read -r width height < <(hyprctl -j layers | jq -r '
    [.. | objects | select(.namespace? == "omarchy-bar")][0]
    | [.w, .h] | @tsv
  ')

  [[ $width =~ ^[0-9]+$ && $height =~ ^[0-9]+$ ]] && ((width > height))
}

bar_position_is() {
  local expected="$1"

  [[ $(jq -r '.bar.position // "top"' "$CONFIG_FILE") == $expected ]]
}

# Rows follow the hovered pointer, which can sit under the centred card (Hyprland
# starts it mid-screen), so move it left of the card before driving by keys.
park_pointer_off_menu() {
  local x y

  read -r x y < <(hyprctl -j monitors | jq -r '
    .[] | select(.focused)
    | [.x + (.width / .scale / 8 | floor), .y + (.height / .scale / 2 | floor)]
    | @tsv
  ') || return 0

  if [[ $x =~ ^-?[0-9]+$ && $y =~ ^-?[0-9]+$ ]]; then
    hyprctl eval "hl.dispatch(hl.dsp.cursor.move({ x = $x, y = $y }))" >/dev/null 2>&1 || true
  fi
}

source_file=$DEFAULTS_FILE
((config_existed)) && source_file=$CONFIG_FILE
original_position=$(jq -r '.bar.position // "top"' "$source_file")

park_pointer_off_menu
omarchy-shell shell summon omarchy.menu '{"menu":"root"}' >/dev/null
wait_until "root menu opens" 15 layer_on_overlay "omarchy-menu"
wait_until "root menu content is visible" 15 screen_contains "Apps"
screenshot "success-menu-01-root"

# Root: Apps, Learn, Appearance.
wtype -k Down -k Down
sleep 1
screenshot "success-menu-02-appearance-selected"
wtype -k Return

wait_until "appearance submenu is visible" 15 screen_contains "Theme"
screenshot "success-menu-03-appearance-submenu"

# Appearance: Theme, Background, Font, Menu Bar.
wtype -k Down -k Down -k Down -k Return
wait_until "menu bar submenu is visible" 15 screen_contains "Position Bar"
screenshot "success-menu-04-menu-bar-submenu"

# Menu Bar: Hide Bar or Show Bar, Position Bar.
wtype -k Down -k Return
wait_until "position submenu is visible" 15 screen_contains "Left Bar"
screenshot "success-menu-05-position-submenu"

# Position: Top Bar, Bottom Bar, Left Bar.
wtype -k Down -k Down -k Return
wait_until "menu bar position changes to left" 20 bar_position_is "left"
wait_until "menu bar becomes vertical" 20 bar_is_vertical
wait_until "menu closes after selecting a position" 15 layer_absent "omarchy-menu"
screenshot "success-menu-06-bar-left"

if ((config_existed)); then
  cp "$config_backup" "$CONFIG_FILE"
else
  rm -f "$CONFIG_FILE"
fi
omarchy-shell shell reloadConfig >/dev/null

if [[ $original_position == "left" || $original_position == "right" ]]; then
  wait_until "menu bar restores its original vertical position" 20 bar_is_vertical
else
  wait_until "menu bar restores its original horizontal position" 20 bar_is_horizontal
fi
screenshot "success-menu-07-bar-restored"

trap - EXIT
restore_bar_config
