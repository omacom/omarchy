#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

original_position=$(omarchy-bar position)
original_hidden=false
[[ -f ~/.local/state/omarchy/toggles/bar-off ]] && original_hidden=true
original_monitors=$(hyprctl -j monitors)
original_monitor=$(jq -r 'map(select(.focused))[0].name // .[0].name' <<<"$original_monitors")
temporary_monitor=""
shell_pid=$(quickshell list -a -j | jq -er 'if length == 1 then .[0].pid else error("expected one shell") end')
shell_stat=$(cat "/proc/$shell_pid/stat")
shell_start=$(awk '{print $20}' <<<"${shell_stat##*) }")

hide_panels() {
  local plugin
  for plugin in omarchy.bluetooth omarchy.audio; do
    omarchy-shell shell hide "$plugin" >/dev/null 2>&1 || true
  done
}

cleanup() {
  hide_panels
  if [[ -n $temporary_monitor ]]; then
    hyprctl output remove "$temporary_monitor" >/dev/null 2>&1 || true
  fi
  hyprctl dispatch "hl.dsp.focus({ monitor = \"$original_monitor\" })" >/dev/null 2>&1 || true
  omarchy-bar position "$original_position" >/dev/null 2>&1 || true
  if $original_hidden; then
    omarchy-toggle-bar on >/dev/null 2>&1 || true
  else
    omarchy-toggle-bar off >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

same_shell() {
  local stat pid
  stat=$(cat "/proc/$shell_pid/stat") || return 1
  [[ $(awk '{print $20}' <<<"${stat##*) }") == "$shell_start" ]] || return 1
  pid=$(quickshell list -a -j | jq -er 'if length == 1 then .[0].pid else error("expected one shell") end') || return 1
  [[ $pid == "$shell_pid" ]]
}

panel_on_monitor() {
  local layers
  layers=$(hyprctl -j layers) || return 1
  jq -nc --arg time "$(TZ=America/New_York date --iso-8601=ns)" \
    --arg monitor "$1" --argjson pid "$shell_pid" --arg start_ticks "$shell_start" \
    --argjson layers "$layers" '{time:$time,monitor:$monitor,pid:$pid,start_ticks:$start_ticks,layers:$layers}' \
    >>"$ARTIFACTS/hidden-panel-geometry.jsonl"
  jq -e --arg name "$1" '[.[$name].levels["3"][]? | select(.namespace == "omarchy-keyboard-panel" and .x >= 0 and .y >= 0 and .w > 0 and .h > 0)] | length == 1' <<<"$layers"
}

monitor_is_focused() {
  hyprctl -j monitors | jq -e --arg name "$1" 'any(.[]; .name == $name and .focused)'
}

wait_bar_state() {
  local description="$1" predicate="$2" deadline=$((SECONDS + 15)) layers
  until "$predicate" omarchy-bar >/dev/null 2>&1; do
    if ! same_shell || ((SECONDS >= deadline)); then
      layers=$(hyprctl -j layers)
      jq -nc --arg time "$(TZ=America/New_York date --iso-8601=ns)" \
        --arg description "$description" --argjson pid "$shell_pid" \
        --arg start_ticks "$shell_start" --argjson layers "$layers" \
        '{time:$time,description:$description,pid:$pid,start_ticks:$start_ticks,layers:$layers}' \
        >>"$ARTIFACTS/bar-hidden-panels.jsonl"
      sync "$ARTIFACTS/bar-hidden-panels.jsonl"
      fail "$description" "bar did not settle with the same shell within 15 seconds"
    fi
    sleep 0.1
  done
  same_shell || fail "same shell after $description"
  pass "$description"
}

exercise_panel() {
  local edge="$1" plugin="$2" monitor="$3"
  same_shell || fail "shell identity is unchanged before hidden panel"
  omarchy-shell shell toggle "$plugin" >/dev/null
  wait_until "$edge hidden $plugin opens on $monitor" 15 panel_on_monitor "$monitor"
  layer_absent omarchy-bar || fail "opening a panel leaves the bar hidden"
  # Only capture after geometry has passed; this is not a reveal wait.
  sleep 1
  screenshot "success-hidden-$edge-${plugin#omarchy.}-$monitor"
  wtype -k Escape
  wait_until "$edge hidden $plugin closes with Escape" 15 layer_absent omarchy-keyboard-panel
  same_shell || fail "shell identity is unchanged after hidden panel"
}

hide_panels
for edge in top bottom left right; do
  omarchy-bar position "$edge" >/dev/null
  omarchy-toggle-bar off >/dev/null
  wait_bar_state "$edge bar is shown" layer_on_screen
  omarchy-shell shell summon omarchy.bluetooth >/dev/null
  wait_until "$edge shown Bluetooth opens" 15 panel_on_monitor "$original_monitor"
  omarchy-toggle-bar on >/dev/null
  wait_bar_state "$edge bar unmaps with Bluetooth open" layer_absent
  panel_on_monitor "$original_monitor" || fail "$edge open panel survives hiding bar"
  sleep 1
  screenshot "success-hidden-$edge-retained-bluetooth"
  hide_panels
  wait_until "$edge retained Bluetooth closes" 15 layer_absent omarchy-keyboard-panel
  for cycle in 1 2 3; do
    for plugin in omarchy.bluetooth omarchy.audio; do
      exercise_panel "$edge-$cycle" "$plugin" "$original_monitor"
    done
  done
done

# Hidden-panel routing must still choose the focused bar instance when its
# backing window does not exist, including a newly connected output.
new_monitor_name="omarchy-hidden-panels-$BASHPID"
if jq -e --arg name "$new_monitor_name" 'any(.[]; .name == $name)' <<<"$original_monitors" >/dev/null; then
  fail "temporary monitor name is unused"
fi
# Own its name before creation: discovery itself can fail, and EXIT must
# still remove this exact output without guessing among connected monitors.
temporary_monitor=$new_monitor_name
hyprctl output create headless "$temporary_monitor" >/dev/null
find_temporary_monitor() {
  hyprctl -j monitors | jq -e --arg name "$temporary_monitor" 'any(.[]; .name == $name)'
}
wait_until "temporary monitor appears while bar hidden" 15 find_temporary_monitor
hyprctl dispatch "hl.dsp.focus({ monitor = \"$temporary_monitor\" })" >/dev/null
wait_until "temporary hidden-panel monitor is focused" 15 monitor_is_focused "$temporary_monitor"
for plugin in omarchy.bluetooth omarchy.audio; do
  exercise_panel monitor-added "$plugin" "$temporary_monitor"
done
hyprctl output remove "$temporary_monitor" >/dev/null
temporary_monitor=""
hyprctl dispatch "hl.dsp.focus({ monitor = \"$original_monitor\" })" >/dev/null
wait_until "original hidden-panel monitor is focused" 15 monitor_is_focused "$original_monitor"
for plugin in omarchy.bluetooth omarchy.audio; do
  exercise_panel monitor-removed "$plugin" "$original_monitor"
done
same_shell || fail "same shell survives hidden-panel churn"
pass "hidden panels work on all bar edges and after monitor changes"
