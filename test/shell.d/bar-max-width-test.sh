#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "bar max width test"
require_command hyprctl

fail_with_log() {
  sed -n '1,120p' "$SCRATCH_LOG" >&2
  fail "$1"
}

setup_scratch_shell

# A cap no screen fits, so every screen's bar is a strip inset from both ends.
cap=400

# Each screen's logical size, for the strip a capped bar leaves on it.
screens=$(hyprctl -j monitors | jq -c '[.[] | {width: (.width / .scale), height: (.height / .scale)}]')

# A slot's position is in its own window's coordinates, and the window spans
# its screen, so a drawn slot of a capped bar sits inside the strip of at
# least one screen: in from both ends of the edge by that screen's inset.
# Uncapped, the first widget sits by the edge's end, inside every inset.
geometry_is() {
  local want="$1" position="$2"
  jq -e --argjson screens "$screens" --argjson cap "$cap" --arg position "$position" --arg want "$want" '
    def vertical: $position == "left" or $position == "right";
    def along: if vertical then .y else .x end;
    def extent: if vertical then .height else .width end;
    def edge: if vertical then .height else .width end;
    def inset: edge as $edge | if $cap < $edge then (($edge - $cap) / 2 | round) else 0 end;
    [.[] | select(.visible == true)] as $rows
    | ([$screens[] | inset] | min) as $least
    | ($rows | length) > 0
    and if $want == "capped" then
        all($rows[]; along as $from | (along + extent) as $to
          | any($screens[]; inset as $inset | $from >= $inset and $to <= edge - $inset))
      else
        any($rows[]; along < $least)
      end
  ' <<<"$geometry" >/dev/null 2>&1
}

# A cold start per case, each with its own shell.json: a config written while
# the shell runs races the writes of its own startup (a widget persisting its
# defaults), which can land on top of it.
bar_from() {
  local config="$1" want="$2" position="$3" description="$4"

  stop_scratch_shell
  reset_scratch_home
  mkdir -p "$SCRATCH_HOME/.config/omarchy"
  jq "$config" "$ROOT/config/omarchy/shell.json" >"$SCRATCH_HOME/.config/omarchy/shell.json"
  start_scratch_shell
  wait_scratch_shell
  wait_scratch_layer omarchy-bar mapped || fail_with_log "$description"

  geometry=""
  for _ in {1..80}; do
    geometry=$(scratch_ipc shell debugBarGeometry 2>/dev/null || true)
    if [[ -n $geometry ]] && geometry_is "$want" "$position"; then
      pass "$description"
      return 0
    fi
    kill -0 "$SCRATCH_PID" 2>/dev/null || fail_with_log "test shell exited before the bar geometry settled"
    sleep 0.1
  done
  printf 'Geometry:\n' >&2
  jq . <<<"$geometry" >&2
  fail_with_log "$description"
}

bar_from ".bar.maxWidth = $cap" capped top "a capped top bar lays its widgets out within a centered strip"
bar_from "del(.bar.maxWidth)" uncapped top "an uncapped bar runs the whole edge"
bar_from ".bar.position = \"left\" | .bar.maxWidth = $cap" capped left "a capped vertical bar lays its widgets out within a centered strip"
