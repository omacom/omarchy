#!/bin/bash

require_quickshell "dock special workspace visibility"
require_command Hyprland
qml_fixture_scratch
nested_pid=""
cleanup_dock_fixture() {
  qml_fixture_cleanup
  if [[ -n $nested_pid ]]; then
    kill "$nested_pid" 2>/dev/null || true
    wait "$nested_pid" 2>/dev/null || true
  fi
  rm -rf "$TMPDIR"
}
trap cleanup_dock_fixture EXIT

cat >"$TMPDIR/hyprland.lua" <<'LUA'
hl.monitor({ output = "", mode = "640x480@60", position = "auto", scale = 1 })
hl.config({ animations = { enabled = false }, ecosystem = { no_update_news = true, no_donation_nag = true } })
LUA
Hyprland --config "$TMPDIR/hyprland.lua" >"$TMPDIR/hyprland.log" 2>&1 &
nested_pid=$!
for _ in {1..100}; do
  nested_instance=$(hyprctl instances -j | jq -c --argjson pid "$nested_pid" '.[] | select(.pid == $pid)')
  if [[ -n $nested_instance ]] && hyprctl -i "$(jq -r '.instance' <<<"$nested_instance")" monitors -j >/dev/null 2>&1; then
    break
  fi
  kill -0 "$nested_pid" 2>/dev/null || fail "nested Hyprland starts" "$(cat "$TMPDIR/hyprland.log")"
  sleep 0.1
done
[[ -n $nested_instance ]] || fail "nested Hyprland answers IPC" "$(cat "$TMPDIR/hyprland.log")"
export HYPRLAND_INSTANCE_SIGNATURE=$(jq -r '.instance' <<<"$nested_instance")
export WAYLAND_DISPLAY=$(jq -r '.wl_socket' <<<"$nested_instance")
hyprctl output create headless >/dev/null

# Use the real layout reader, with floating modes for both private outputs.
mkdir -p "$QML_FIXTURE_TMP/home/.local/state/omarchy/workspace-layouts"
for workspace_id in 1 2; do
  printf 'o.workspace_mode({ workspace = "%s", mode = "floating" })\n' "$workspace_id" >"$QML_FIXTURE_TMP/home/.local/state/omarchy/workspace-layouts/$workspace_id.lua"
done
run_qml_fixture dock-special-workspace "dock hides and returns with the scratchpad only on its monitor" Commons Ui plugins
