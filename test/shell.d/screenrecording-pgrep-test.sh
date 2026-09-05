#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

recording="$ROOT/shell/plugins/bar/indicators/ScreenRecording.qml"
capture="$ROOT/bin/omarchy-capture-screenrecording"
menu="$ROOT/default/omarchy/omarchy-menu.jsonc"

grep -q '"pidof", "-q", "gpu-screen-recorder"' "$recording" ||
  fail "screen-recording status uses pidof so a 19-character name is visible"
if grep -q 'pgrep", "-x"' "$recording"; then
  fail "pgrep -x cannot match gpu-screen-recorder (comm is truncated to 15 characters)"
fi
grep -q 'pidof -q gpu-screen-recorder' "$capture" ||
  fail "capture helper uses the same pidof check as the indicator"
grep -Fq '"when":"pidof -q gpu-screen-recorder"' "$menu" ||
  fail "the capture menu uses the same pidof check as the indicator"
pass "screen-recording status uses pidof so a 19-character name is visible"

require_command sleep
tmp_dir=$(mktemp -d)
trap 'kill "$recorder_pid" 2>/dev/null || true; rm -rf "$tmp_dir"' EXIT
cp "$(command -v sleep)" "$tmp_dir/gpu-screen-recorder"
chmod +x "$tmp_dir/gpu-screen-recorder"
"$tmp_dir/gpu-screen-recorder" 30 &
recorder_pid=$!

if pgrep -x gpu-screen-recorder >/dev/null 2>&1; then
  fail "pgrep -x matches a 19-character recorder name (comm is truncated to 15)"
fi
pidof -q gpu-screen-recorder ||
  fail "pidof -q matches gpu-screen-recorder via comm or argv0"
pass "pidof -q matches gpu-screen-recorder via comm or argv0"
