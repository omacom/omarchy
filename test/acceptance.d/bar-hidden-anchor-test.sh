#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

plugin_dir="$HOME/.config/omarchy/plugins/acceptance.bar-panel"
[[ ! -e $plugin_dir ]] || fail "bar anchor fixture is absent before testing"
config="$HOME/.config/omarchy/shell.json"
recovery=$(mktemp -d "$ARTIFACTS/bar-anchor-recovery.XXXXXX")
cp "$config" "$recovery/shell.json"
original_hidden=false
[[ -f ~/.local/state/omarchy/toggles/bar-off ]] && original_hidden=true
original_monitor=$(hyprctl -j monitors | jq -r 'map(select(.focused))[0].name // .[0].name')
original_cursor=$(hyprctl cursorpos)
temporary_monitor=""
shell_pid=$(quickshell list -a -j | jq -er 'if length == 1 then .[0].pid else error("expected one shell") end')
shell_stat=$(cat "/proc/$shell_pid/stat")
shell_start=$(awk '{print $20}' <<<"${shell_stat##*) }")

cleanup() {
  local status=$?
  omarchy-shell shell hide acceptance.bar-panel >/dev/null 2>&1 || true
  if [[ -n $temporary_monitor ]]; then
    hyprctl output remove "$temporary_monitor" >/dev/null 2>&1 || status=1
  fi
  cp "$recovery/shell.json" "$config" || status=1
  omarchy-shell shell reloadConfig >/dev/null 2>&1 || status=1
  rm -rf -- "$plugin_dir" || status=1
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || status=1
  hyprctl dispatch "hl.dsp.focus({ monitor = \"$original_monitor\" })" >/dev/null 2>&1 || status=1
  hyprctl eval "hl.dispatch(hl.dsp.cursor.move({ x = ${original_cursor%,*}, y = ${original_cursor#*, } }))" >/dev/null 2>&1 || status=1
  if $original_hidden; then
    omarchy-toggle-bar on >/dev/null 2>&1 || status=1
  else
    omarchy-toggle-bar off >/dev/null 2>&1 || status=1
  fi
  cmp -s "$recovery/shell.json" "$config" || status=1
  exit "$status"
}
trap cleanup EXIT
cp -a "$ROOT/test/acceptance.d/fixtures/bar-panel" "$plugin_dir"
fixture_entry="run${recovery##*.}/Panel.qml"
mkdir -p "$plugin_dir/${fixture_entry%/*}"
mv "$plugin_dir/Panel.qml" "$plugin_dir/$fixture_entry"
jq --arg entry "$fixture_entry" '.entryPoints.barWidget = $entry' "$plugin_dir/manifest.json" >"$recovery/manifest.json"
cp "$recovery/manifest.json" "$plugin_dir/manifest.json"
omarchy-shell shell rescanPlugins >/dev/null
fixture_discovered() { omarchy-shell shell listPlugins | jq -e 'any(.[]; .id == "acceptance.bar-panel")'; }
wait_until "bar anchor fixture is discovered" 15 fixture_discovered
[[ $(omarchy-shell shell setPluginEnabled acceptance.bar-panel true) == "ok" ]] || fail "bar anchor fixture enables"
# Enablement writes shell.json, so add the slot only after that write finishes.
jq '.bar.layout |= with_entries(.value |= map(select((if type == "string" then . else .id end) != "acceptance.bar-panel"))) | .bar.layout.right += [{id:"acceptance.bar-panel"}]' "$config" >"$recovery/with-fixture.json"
cp "$recovery/with-fixture.json" "$config"
omarchy-shell shell reloadConfig >/dev/null

same_shell() {
  local stat
  stat=$(cat "/proc/$shell_pid/stat") || return 1
  [[ $(awk '{print $20}' <<<"${stat##*) }") == "$shell_start" ]] || return 1
  [[ $(quickshell list -a -j | jq -er 'if length == 1 then .[0].pid else error("not one shell") end') == "$shell_pid" ]]
}
monitor_exists() { hyprctl -j monitors | jq -e --arg name "$temporary_monitor" 'any(.[]; .name == $name)'; }
monitor_focused() { hyprctl -j monitors | jq -e --arg name "$temporary_monitor" 'any(.[]; .name == $name and .focused)'; }
shell_monitor_focused() {
  local actual
  actual=$(omarchy-shell acceptance.bar-panel.geometry focusedScreen) || return 1
  jq -nc --arg expected "$temporary_monitor" --arg actual "$actual" --arg cursor "$(hyprctl cursorpos)" --argjson monitors "$(hyprctl -j monitors)" '{expected:$expected,actual:$actual,cursor:$cursor,focused:[$monitors[] | select(.focused) | .name]}' >>"$ARTIFACTS/$edge-focus.jsonl"
  [[ $actual == "$temporary_monitor" ]]
}
fixture_states() { omarchy-shell acceptance.bar-panel.geometry states; }
fixture_mapped() { fixture_states | tee "$ARTIFACTS/$edge-last-states.json" | jq -e --arg monitor "$temporary_monitor" 'any(.[]; .open and .mapped and .screen == $monitor)'; }
bar_on_monitor() { hyprctl -j layers | jq -e --arg name "$temporary_monitor" 'any(.[$name].levels["2"][]?; .namespace == "omarchy-bar" and .w > 0 and .h > 0)'; }
panel_on_target() {
  local monitors layers
  monitors=$(hyprctl -j monitors) || return 1
  layers=$(hyprctl -j layers) || return 1
  jq -nc --arg time "$(TZ=America/New_York date --iso-8601=ns)" --arg monitor "$temporary_monitor" \
    --argjson monitors "$monitors" --argjson layers "$layers" \
    '{time:$time,monitor:$monitor,monitors:$monitors,layers:$layers}' >>"$ARTIFACTS/$edge-panel-surfaces.jsonl"
  jq -e --arg name "$temporary_monitor" --argjson monitors "$monitors" '
    ($monitors[] | select(.name == $name)) as $m |
    any(.[$name].levels["3"][]?; .namespace == "omarchy-keyboard-panel" and
      .x == $m.x and .y == $m.y and .w == ($m.width / $m.scale | floor) and .h == ($m.height / $m.scale | floor))' <<<"$layers"
}
wait_bar() {
  local description=$1 predicate=$2 deadline=$((SECONDS + 15))
  until "$predicate" >/dev/null 2>&1; do
    if ! same_shell || (( SECONDS >= deadline )); then
      hyprctl -j layers >"$ARTIFACTS/bar-anchor-failed-layers.json"
      fail "$description" "bar state failed before any recovery screenshot"
    fi
    sleep 0.1
  done
  same_shell || fail "same shell after $description"
}
save_card() {
  local label=$1
  # QML can retain correct local card coordinates while the compositor still
  # has the surface at the old output origin. Require both before capturing.
  wait_until "$edge $label panel surface follows its output" 15 panel_on_target
  fixture_states | jq -e --arg monitor "$temporary_monitor" 'first(.[] | select(.open and .mapped and .screen == $monitor))' >"$ARTIFACTS/$edge-$label-card.json"
  jq -e --arg monitor "$temporary_monitor" '.open and .mapped and .screen == $monitor and .anchorWidth > 0 and .anchorHeight > 0' \
    "$ARTIFACTS/$edge-$label-card.json" >/dev/null || fail "$edge $label has a laid-out card anchor"
}
matching_card() {
  jq -es '.[0].x == .[1].x and .[0].y == .[1].y and .[0].width == .[1].width and .[0].height == .[1].height and .[0].screen == .[1].screen and .[0].instanceId == .[1].instanceId' "$1" "$2" >/dev/null
}
monitor_moved() { hyprctl -j monitors | jq -e --arg name "$temporary_monitor" --argjson x "$moved_x" 'any(.[]; .name == $name and .x == $x)'; }

layer_absent_bar() { layer_absent omarchy-bar; }

for edge in top bottom left right; do
  omarchy-bar position "$edge" >/dev/null
  omarchy-toggle-bar on >/dev/null
  wait_bar "$edge bar is unmapped" layer_absent_bar
  new_monitor="omarchy-bar-anchor-$BASHPID-$edge"
  if hyprctl -j monitors | jq -e --arg name "$new_monitor" 'any(.[]; .name == $name)' >/dev/null; then
    fail "temporary anchor monitor name is unused"
  fi
  temporary_monitor=$new_monitor
  hyprctl output create headless "$temporary_monitor" >/dev/null
  wait_until "$edge new hidden monitor appears" 15 monitor_exists
  # A pointer left on the original output can immediately pull focus back.
  # Position it inside this guest output before sending panel input.
  read -r pointer_x pointer_y < <(hyprctl -j monitors | jq -r --arg name "$temporary_monitor" '.[] | select(.name == $name) | "\(.x + 64) \(.y + 64)"')
  hyprctl eval "hl.dispatch(hl.dsp.cursor.move({ x = $pointer_x, y = $pointer_y }))" >/dev/null
  hyprctl dispatch "hl.dsp.focus({ monitor = \"$temporary_monitor\" })" >/dev/null
  wait_until "$edge new monitor is focused" 15 monitor_focused
  # Synchronize the native monitor inventory after asynchronous headless
  # discovery. The geometry assertion below still requires the requested
  # output, a real card anchor, and equality with its shown reference.
  omarchy-shell acceptance.bar-panel.geometry refreshMonitors >/dev/null
  wait_until "$edge shell observes monitor focus" 15 shell_monitor_focused
  omarchy-shell shell summon acceptance.bar-panel >/dev/null
  wait_until "$edge cold hidden card maps" 15 fixture_mapped
  save_card cold
  screenshot "success-bar-anchor-$edge-cold"
  omarchy-toggle-bar off >/dev/null
  wait_bar "$edge shown reference bar maps" bar_on_monitor
  save_card shown
  matching_card "$ARTIFACTS/$edge-cold-card.json" "$ARTIFACTS/$edge-shown-card.json" || fail "$edge never-mapped card matches shown position"
  pass "$edge never-mapped card matches shown position"
  if [[ $edge == "right" ]]; then
    read -r source_x source_y < <(hyprctl -j monitors | jq -r --arg name "$temporary_monitor" '.[] | select(.name == $name) | "\(.x) \(.y)"')
    moved_x=$((source_x + 200))
    hyprctl eval "hl.monitor({ output = \"$temporary_monitor\", position = \"${moved_x}x${source_y}\" })" >/dev/null
    wait_until "open panel output moves" 15 monitor_moved
    save_card moved
    matching_card "$ARTIFACTS/$edge-shown-card.json" "$ARTIFACTS/$edge-moved-card.json" || fail "monitor move keeps the same open widget and card position"
    pass "monitor move keeps the same open widget and card position"
    hyprctl eval "hl.dispatch(hl.dsp.cursor.move({ x = $((moved_x + 64)), y = $((source_y + 64)) }))" >/dev/null
  fi
  omarchy-toggle-bar on >/dev/null
  wait_bar "$edge reference bar unmaps" layer_absent_bar
  save_card hidden
  matching_card "$ARTIFACTS/$edge-hidden-card.json" "$ARTIFACTS/$edge-shown-card.json" || fail "$edge hidden card matches shown position"
  pass "$edge hidden card matches shown position"
  screenshot "success-bar-anchor-$edge-hidden"
  wtype -k Escape
  wait_until "$edge card closes through keyboard" 15 layer_absent omarchy-keyboard-panel
  hyprctl output remove "$temporary_monitor" >/dev/null
  temporary_monitor=""
  same_shell || fail "same shell after $edge anchor test"
done
