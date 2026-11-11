#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

WEATHER_FILE="$HOME/.local/state/omarchy/settings/weather.json"
weather_backup=$(mktemp)
weather_existed=0

if [[ -f $WEATHER_FILE ]]; then
  cp "$WEATHER_FILE" "$weather_backup"
  weather_existed=1
fi

hide_panels() {
  local plugin

  for plugin in omarchy.weather omarchy.bluetooth omarchy.network omarchy.audio omarchy.monitor omarchy.power; do
    omarchy-shell shell hide "$plugin" >/dev/null 2>&1 || true
  done
}

restore_weather() {
  hide_panels

  if ((weather_existed)); then
    mkdir -p "$(dirname "$WEATHER_FILE")"
    cp "$weather_backup" "$WEATHER_FILE"
  else
    rm -f "$WEATHER_FILE"
  fi

  rm -f "$weather_backup"
}

trap restore_weather EXIT

# Panels share a surface that stays mapped between opens, so ask the shell.
panel_drawn() {
  omarchy-shell panels probe | jq -e --arg id "$1" '.drawn | index($id)' >/dev/null
}

panel_gone() {
  ! panel_drawn "$1"
}

any_panel_drawn() {
  omarchy-shell panels probe | jq -e '.drawn | length > 0' >/dev/null
}

no_panel_drawn() {
  ! any_panel_drawn
}

open_and_capture_panel() {
  local name="$1" plugin="$2"

  omarchy-shell shell summon "$plugin" >/dev/null
  wait_until "$name panel opens" 15 panel_drawn "$plugin"
  sleep 1
  screenshot "success-panel-$name"

  omarchy-shell shell hide "$plugin" >/dev/null
  wait_until "$name panel closes" 15 panel_gone "$plugin"
}

# Give weather deterministic coordinates so this test exercises the real
# Open-Meteo forecast instead of IP geolocation through wttr.in.
omarchy-weather-location --set "San Francisco" "37.7749,-122.4194"
omarchy-shell shell summon omarchy.weather >/dev/null
wait_until "weather panel opens" 15 panel_drawn omarchy.weather
wait_until "weather location is visible" 30 screen_contains "SAN FRANCISCO"
wait_until "weather details are visible" 30 screen_contains "WIND"
screenshot "success-panel-weather"
omarchy-shell shell hide omarchy.weather >/dev/null
wait_until "weather panel closes" 15 panel_gone omarchy.weather

status=0
panels='bluetooth|omarchy.bluetooth
network|omarchy.network
audio|omarchy.audio
monitor|omarchy.monitor'

while IFS='|' read -r name plugin; do
  if ! (trap - EXIT; open_and_capture_panel "$name" "$plugin"); then
    status=1
    hide_panels
    wait_until "$name failed panel is dismissed" 15 no_panel_drawn
  fi
done <<<"$panels"

# The power widget intentionally disappears on desktops and VMs without a
# battery. Exercise it on laptops, and verify that hardware-less sessions take
# the supported no-panel path instead of treating that as a shell failure.
if upower -e | grep '/battery_' >/dev/null; then
  if ! (trap - EXIT; open_and_capture_panel "power" "omarchy.power"); then
    status=1
    hide_panels
    wait_until "power failed panel is dismissed" 15 no_panel_drawn
  fi
else
  pass "power panel is hidden without battery hardware"
  screenshot "success-panel-power-unavailable"
fi

# The common panel keyboard contract uses Tab to move to the next bar panel.
omarchy-shell shell summon omarchy.bluetooth >/dev/null
wait_until "panel keyboard navigation starts on bluetooth" 15 screen_contains "Bluetooth"
screenshot "success-panel-navigation-01-bluetooth"
wtype -k Tab
sleep 2
wait_until "Tab keeps a shell panel open" 15 any_panel_drawn
screenshot "success-panel-navigation-02-next"
hide_panels
wait_until "keyboard-navigated panel closes" 15 no_panel_drawn

# The panel surface stays mapped between opens. Verify the focus prime
# reacquires compositor keyboard focus on a reopen during the fade instead of
# relying on map-time OnDemand behavior, which would leave Escape in the
# previously focused app.
omarchy-shell shell summon omarchy.bluetooth >/dev/null
wait_until "focus-prime panel opens" 15 panel_drawn omarchy.bluetooth
monitors=$(hyprctl -j monitors | jq length)
(( $(omarchy-shell panels probe | jq '[.surfaces[] | select(.mapped)] | length') == monitors )) || fail "panels share one surface per monitor"
pass "panels share one surface per monitor"
omarchy-shell shell hide omarchy.bluetooth >/dev/null
omarchy-shell shell summon omarchy.bluetooth >/dev/null
wait_until "focus-prime panel reopens" 15 panel_drawn omarchy.bluetooth
sleep 1
screenshot "success-panel-focus-prime-reopened"
wtype -k Escape
wait_until "Escape closes a panel reopened during fade" 15 panel_gone omarchy.bluetooth

# Panels on one output share a window, and with it one focused item. Elsewhen
# hands the keyboard back to its own card as it closes; the panel it was
# switched to must keep it.
omarchy-shell shell summon omarchy.elsewhen >/dev/null
wait_until "elsewhen panel opens" 15 panel_drawn omarchy.elsewhen
sleep 1
omarchy-shell shell summon omarchy.weather >/dev/null
wait_until "weather takes over from elsewhen" 15 panel_gone omarchy.elsewhen
sleep 1
wtype -k Escape
wait_until "Escape closes the panel switched to" 15 no_panel_drawn

trap - EXIT
restore_weather
exit $status
