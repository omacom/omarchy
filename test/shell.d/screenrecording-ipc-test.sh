#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

recording="$ROOT/shell/plugins/bar/indicators/ScreenRecording.qml"
capture="$ROOT/bin/omarchy-capture-screenrecording"
menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
socket='${XDG_RUNTIME_DIR:-/tmp}/omarchy-gsr.sock'

grep -Fq "GSR_SOCKET=\"$socket\"" "$capture" ||
  fail "capture helper uses the shared Omarchy gsr socket"
grep -Fq -- '-ipc "$GSR_SOCKET"' "$capture" ||
  fail "gpu-screen-recorder is launched with -ipc on the shared socket"
grep -Fq 'gsr-cli -ipc "$GSR_SOCKET" status' "$capture" ||
  fail "capture helper gates on gsr-cli status for the shared socket"
grep -Fq 'gsr-cli -ipc "$GSR_SOCKET" stop' "$capture" ||
  fail "capture helper stops via gsr-cli on the shared socket"
if grep -q 'RECORDING_PID_FILE' "$capture"; then
  fail "stop does not keep a pid file beside gsr-cli"
fi
if grep -E 'kill[[:space:]]+(-s[[:space:]]+)?(SIGINT|-INT|-9|-KILL)' "$capture" >/dev/null; then
  fail "stop does not kill the recorder; gsr-cli stop is enough"
fi

grep -Fq 'Quickshell.env("XDG_RUNTIME_DIR")' "$recording" ||
  fail "indicator builds the gsr socket from XDG_RUNTIME_DIR"
grep -Fq '"gsr-cli", "-ipc"' "$recording" ||
  fail "indicator status uses gsr-cli -ipc"
grep -Fq '"status"' "$recording" ||
  fail "indicator status asks gsr-cli for status"
grep -Fq '/omarchy-gsr.sock' "$recording" ||
  fail "indicator uses the shared Omarchy gsr socket"

grep -Fq "gsr-cli -ipc \\\"$socket\\\" status" "$menu" ||
  fail "the capture menu uses gsr-cli status on the shared socket"

for file in "$capture" "$recording" "$menu"; do
  if grep -E 'pidof[[:space:]"]+-q[[:space:]"]+gpu-screen-recorder|pgrep[[:space:]"-]+-f[[:space:]"]+\^?gpu-screen-recorder' "$file" >/dev/null; then
    fail "screen-recording gate does not use pidof or pgrep -f for gpu-screen-recorder" "$file"
  fi
done

if grep -E 'pkill[[:space:]].*-f[[:space:]"]+\^?gpu-screen-recorder' "$capture" >/dev/null; then
  fail "stop does not pkill -f gpu-screen-recorder"
fi
if grep -E 'pgrep[[:space:]].*-f[[:space:]"]+\^?gpu-screen-recorder' "$capture" >/dev/null; then
  fail "stop does not pgrep -f gpu-screen-recorder"
fi

pass "screen recording start/status/stop talk to the Omarchy gsr socket"
