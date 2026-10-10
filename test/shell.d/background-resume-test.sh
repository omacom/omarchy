#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_compositor "background resume after a suspended intro"
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
current="$stage/home/.local/state/omarchy/current"
mkdir -p "$current" "$stage/old" "$stage/new"
ln -s "$ROOT/shell/plugins/background" "$stage/background"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
cp "$SHELL_TEST_DIR/fixtures/background-resume/shell.qml" "$stage/shell.qml"
magick -size 128x128 xc:magenta "$stage/old/still.png"
ln -s "$stage/old/still.png" "$current/background"
: >"$stage/command"
HOME="$stage/home" RESUME_TEST_COMMAND="$stage/command" RESUME_TEST_RESULT="$stage/result" \
  quickshell -p "$stage" --no-color >"$stage/quickshell.log" 2>&1 &
qs_pid=$!
wait_phase() {
  for attempt in {1..100}; do
    [[ -f $stage/result && $(<"$stage/result") == "$1" ]] && return 0
    sleep 0.03
  done
  fail "the resume fixture reaches $1" "$(cat "$stage/quickshell.log")"
}
pixel() {
  local output
  output=$(hyprctl -j monitors | jq -r '.[0].name')
  timeout -k 1 3 grim -o "$output" "$stage/pixel.png"
  magick "$stage/pixel.png" -format '%[hex:p{32,256}]' info:
}
# Image loading and the compositor take their own time, so wait for the color.
shows() {
  for attempt in {1..30}; do
    [[ $(pixel) == "$1" ]] && return 0
    sleep 0.1
  done
  return 1
}
wait_phase initial
shows FF00FF || fail "the initial background is visible"

# A theme switch removes the old theme's still and links the new one while
# OWE has the background suspended.
printf 'suspend 1\n' >"$stage/command"
wait_phase "suspend 1"
magick -size 128x128 xc:cyan "$stage/new/still.png"
ln -sfn "$stage/new/still.png" "$current/background"
rm -f "$stage/old/still.png"
printf 'resume 1\n' >"$stage/command"
wait_phase "resume 1"
shows 00FFFF || fail "resuming shows the newly linked still instead of the removed one"

# A new theme can ship a still with the same filename, replacing the pixels
# behind an unchanged path.
printf 'suspend 2\n' >"$stage/command"
wait_phase "suspend 2"
magick -size 128x128 xc:yellow "$stage/new/still.png"
printf 'resume 2\n' >"$stage/command"
wait_phase "resume 2"
shows FFFF00 || fail "resuming reloads new pixels behind an unchanged path"

printf 'done\n' >"$stage/command"
wait "$qs_pid" || fail "the resume fixture exits cleanly" "$(cat "$stage/quickshell.log")"
qs_pid=""
pass "resuming a suspended background shows the still linked during the suspension"
