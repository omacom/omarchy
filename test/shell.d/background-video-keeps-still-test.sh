#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_compositor "background still kept for a video"
require_command quickshell
require_command magick

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/home/.local/state/omarchy/current"
ln -s "$ROOT/shell/plugins/background" "$stage/background"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
magick -size 128x128 xc:magenta "$stage/still.png"
ln -s "$stage/still.png" "$stage/home/.local/state/omarchy/current/background"
cp "$SHELL_TEST_DIR/fixtures/background-video-keeps-still/shell.qml" "$stage/shell.qml"

output=$(HOME="$stage/home" timeout 6 quickshell -p "$stage" --no-color 2>&1) || fail "video selection fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* && $output != *"RESULT fail"* ]] || fail "the still stays on screen until OWE suspends the layer" "$output"
if rg -q 'ReferenceError|TypeError|Unable to assign|Binding loop' <<<"$output"; then
  fail "video selection fixture has no QML errors" "$output"
fi
pass "a video selection keeps the still on screen until OWE suspends the layer"
