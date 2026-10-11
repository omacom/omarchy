#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_compositor "same-path background fallback"
require_command quickshell
require_command grim
require_command magick

stage=$(mktemp -d)
qs_pid=""
cleanup() {
  [[ -z $qs_pid ]] || { kill "$qs_pid" 2>/dev/null || true; wait "$qs_pid" 2>/dev/null || true; }
  rm -rf "$stage"
}
trap cleanup EXIT
mkdir -p "$stage/home/.local/state/omarchy/current"
ln -s "$ROOT/shell/plugins/background" "$stage/background"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
cp "$SHELL_TEST_DIR/fixtures/background-instant-reload/shell.qml" "$stage/shell.qml"
magick -size 128x128 xc:magenta "$stage/still.png"
ln -s "$stage/still.png" "$stage/home/.local/state/omarchy/current/background"
: >"$stage/command"
HOME="$stage/home" RELOAD_TEST_COMMAND="$stage/command" RELOAD_TEST_RESULT="$stage/result" \
  quickshell -p "$stage" --no-color >"$stage/quickshell.log" 2>&1 &
qs_pid=$!
wait_phase() {
  for attempt in {1..100}; do
    [[ -f $stage/result && $(<"$stage/result") == "$1" ]] && return 0
    sleep 0.03
  done
  fail "same-path background reaches $1" "$(cat "$stage/quickshell.log")"
}
pixel() {
  local output
  output=$(hyprctl -j monitors | jq -r '.[0].name')
  timeout -k 1 3 grim -o "$output" "$stage/pixel.png"
  magick "$stage/pixel.png" -format '%[hex:p{32,256}]' info:
}
wait_phase initial
[[ $(pixel) == FF00FF ]] || fail "the initial background is visible"
magick -size 128x128 xc:cyan "$stage/still.png"
printf 'reload\n' >"$stage/command"
wait_phase reloaded
[[ $(pixel) == 00FFFF ]] || fail "the instant fallback reloads new pixels behind an unchanged path"
printf 'done\n' >"$stage/command"
wait "$qs_pid" || fail "the same-path reload fixture exits cleanly" "$(cat "$stage/quickshell.log")"
qs_pid=""
pass "the instant fallback reloads a replaced image at the same path"
