#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

recording="$ROOT/shell/plugins/bar/indicators/ScreenRecording.qml"
capture="$ROOT/bin/omarchy-capture-screenrecording"
menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
socket='${XDG_RUNTIME_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/omarchy}/omarchy-gsr.sock'

grep -Fq 'GSR_SOCKET="$RUNTIME_DIR/omarchy-gsr.sock"' "$capture" ||
  fail "capture helper uses the shared Omarchy gsr socket"
grep -Eq '^ *gpu-screen-recorder .*-ipc "\$GSR_SOCKET"' "$capture" ||
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
grep -qx 'import Quickshell' "$recording" ||
  fail "indicator imports Quickshell, which Quickshell.env needs"
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

# Run the stop path. A stub that exits 0 for the notification must not hide a
# failed gsr-cli stop, and a successful stop must still print and forget the file.
stub_bin=$(mktemp -d)
runtime=$(mktemp -d)
videos=$(mktemp -d)
trap 'rm -rf "$stub_bin" "$runtime" "$videos"' EXIT

cat >"$stub_bin/gsr-cli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${GSR_LOG:?}"
if [[ $1 == -ipc && $3 == status ]]; then
  exit 0
fi
if [[ $1 == -ipc && $3 == stop ]]; then
  exit "${GSR_STOP_STATUS:-0}"
fi
exit 1
SH
cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${NOTE_LOG:?}"
exit 0
SH
cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$stub_bin/ffprobe" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$stub_bin/ffmpeg" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$stub_bin/pkill" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${PKILL_LOG:?}"
exit 0
SH
chmod +x "$stub_bin"/*

export PATH="$stub_bin:$PATH"
export GSR_LOG="$videos/gsr.log"
export NOTE_LOG="$videos/note.log"
export PKILL_LOG="$videos/pkill.log"
export XDG_RUNTIME_DIR="$runtime"
export OMARCHY_SCREENRECORD_DIR="$videos"

clip="$videos/clip.mp4"
printf 'not a video\n' >"$clip"
printf '%s\n' "$clip" >"$runtime/omarchy-screenrecord-filename"

set +e
GSR_STOP_STATUS=1 "$capture" --stop-recording >/dev/null 2>&1
failed_status=$?
set -e
[[ $failed_status -ne 0 ]] ||
  fail "a failed gsr-cli stop does not exit successfully" "status $failed_status"
[[ -f $runtime/omarchy-screenrecord-filename ]] ||
  fail "a failed gsr-cli stop keeps the recording filename"
grep -Fq 'Could not stop the recording through gsr-cli.' "$NOTE_LOG" ||
  fail "a failed gsr-cli stop reports the error" "$(cat "$NOTE_LOG")"
pass "a failed gsr-cli stop exits non-zero and keeps the filename"

: >"$GSR_LOG"
: >"$NOTE_LOG"
printf '%s\n' "$clip" >"$runtime/omarchy-screenrecord-filename"
saved=$("$capture" --stop-recording)
[[ $saved == "$clip" ]] ||
  fail "a successful stop prints the saved recording" "$saved"
[[ ! -e $runtime/omarchy-screenrecord-filename ]] ||
  fail "a successful stop removes the recording filename"
grep -Fqx -- "-ipc $runtime/omarchy-gsr.sock stop" "$GSR_LOG" ||
  fail "a successful stop calls gsr-cli stop on the Omarchy gsr socket" "$(cat "$GSR_LOG")"
pass "a successful gsr-cli stop prints the recording and clears its filename"

grep -Fq -- '-f WebcamOverlay' "$videos/pkill.log" ||
  fail "stop cleanup does not call the stubbed pkill" "$(cat "$videos/pkill.log" 2>/dev/null || true)"
pass "stop cleanup calls the stubbed pkill instead of a live WebcamOverlay"
