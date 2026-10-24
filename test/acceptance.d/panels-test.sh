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

# Qt publishes its accessibility tree only while an assistive technology
# says it is listening, which this switch announces to every app.
set_accessibility() {
  busctl --user set-property org.a11y.Bus /org/a11y/bus org.a11y.Status IsEnabled b "$1"
}

# Wait for a panel by its name in the accessibility tree. With no tree to ask
# (no accessibility bus, or a Quickshell that publishes none), read the screen
# instead. Fall back to the screen when the tree never shows the panel.
wait_for_panel() {
  local name="$1" description="$2" status attempt

  # The shell publishes its tree a moment after accessibility is switched on.
  # libatspi aborts rather than return when there is no bus at all.
  for attempt in 1 2 3 4 5; do
    status=0
    python "$ROOT/test/acceptance.d/atspi.py" dialog "$name" 2>/dev/null || status=$?
    (( status > 1 )) || break
    sleep 1
  done
  if (( status > 1 )); then
    printf '# no accessibility tree; reading the screen for %s\n' "$name"
    wait_until "$description" 15 screen_contains "$name"
    return
  fi

  local deadline=$((SECONDS + 15))
  until python "$ROOT/test/acceptance.d/atspi.py" dialog "$name" 2>/dev/null; do
    if ((SECONDS >= deadline)); then
      if screen_contains "$name"; then
        printf '# accessibility tree lookup missed %s; panel found on screen\n' "$name"
        pass "$description"
        return
      fi
      fail "$description" "no $name panel in the accessibility tree or on screen"
    fi
    sleep 1
  done
  pass "$description"
}

restore_weather() {
  hide_panels
  set_accessibility "$accessibility_enabled" || true

  if ((weather_existed)); then
    mkdir -p "$(dirname "$WEATHER_FILE")"
    cp "$weather_backup" "$WEATHER_FILE"
  else
    rm -f "$WEATHER_FILE"
  fi

  rm -f "$weather_backup"
}

accessibility_enabled=$(busctl --user get-property org.a11y.Bus /org/a11y/bus org.a11y.Status IsEnabled | awk '{print $2}')
trap restore_weather EXIT

open_and_capture_panel() {
  local name="$1" plugin="$2"

  omarchy-shell shell summon "$plugin" >/dev/null
  wait_until "$name panel opens" 15 layer_present "omarchy-keyboard-panel"
  sleep 1
  screenshot "success-panel-$name"

  omarchy-shell shell hide "$plugin" >/dev/null
  wait_until "$name panel closes" 15 layer_absent "omarchy-keyboard-panel"
}

# Give weather deterministic coordinates so this test exercises the real
# Open-Meteo forecast instead of IP geolocation through wttr.in.
omarchy-weather-location --set "San Francisco" "37.7749,-122.4194"
omarchy-shell shell summon omarchy.weather >/dev/null
wait_until "weather panel opens" 15 layer_present "omarchy-keyboard-panel"
wait_until "weather location is visible" 30 screen_contains "SAN FRANCISCO"
wait_until "weather details are visible" 30 screen_contains "WIND"
screenshot "success-panel-weather"
omarchy-shell shell hide omarchy.weather >/dev/null
wait_until "weather panel closes" 15 layer_absent "omarchy-keyboard-panel"

status=0
panels='bluetooth|omarchy.bluetooth
network|omarchy.network
audio|omarchy.audio
monitor|omarchy.monitor'

while IFS='|' read -r name plugin; do
  if ! (trap - EXIT; open_and_capture_panel "$name" "$plugin"); then
    status=1
    hide_panels
    wait_until "$name failed panel is dismissed" 15 layer_absent "omarchy-keyboard-panel"
  fi
done <<<"$panels"

# The power widget intentionally disappears on desktops and VMs without a
# battery. Exercise it on laptops, and verify that hardware-less sessions take
# the supported no-panel path instead of treating that as a shell failure.
if upower -e | grep '/battery_' >/dev/null; then
  if ! (trap - EXIT; open_and_capture_panel "power" "omarchy.power"); then
    status=1
    hide_panels
    wait_until "power failed panel is dismissed" 15 layer_absent "omarchy-keyboard-panel"
  fi
else
  pass "power panel is hidden without battery hardware"
  screenshot "success-panel-power-unavailable"
fi

# The common panel keyboard contract uses Tab to move to the next bar panel.
set_accessibility true
omarchy-shell shell summon omarchy.bluetooth >/dev/null
wait_for_panel "Bluetooth" "panel keyboard navigation starts on bluetooth"
screenshot "success-panel-navigation-01-bluetooth"
wtype -k Tab
sleep 2
wait_until "Tab keeps a shell panel open" 15 layer_present "omarchy-keyboard-panel"
screenshot "success-panel-navigation-02-next"
hide_panels
wait_until "keyboard-navigated panel closes" 15 layer_absent "omarchy-keyboard-panel"

# Reopening during the fade keeps the layer surface mapped. Verify the focus
# prime reacquires compositor keyboard focus instead of relying on map-time
# OnDemand behavior, which would leave Escape in the previously focused app.
omarchy-shell shell summon omarchy.bluetooth >/dev/null
wait_until "focus-prime panel opens" 15 layer_present "omarchy-keyboard-panel"
if (( $(hyprctl -j monitors | jq length) == 1 )); then
  layer_absent "omarchy-keyboard-panel-dismiss" || fail "single-monitor panel has no dismissal twin"
  pass "single-monitor panel has no dismissal twin"
fi
omarchy-shell shell hide omarchy.bluetooth >/dev/null
omarchy-shell shell summon omarchy.bluetooth >/dev/null
wait_until "focus-prime panel reopens" 15 layer_present "omarchy-keyboard-panel"
sleep 1
screenshot "success-panel-focus-prime-reopened"
wtype -k Escape
wait_until "Escape closes a panel reopened during fade" 15 layer_absent "omarchy-keyboard-panel"

trap - EXIT
restore_weather
exit $status
