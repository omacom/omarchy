#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/runtime" "$tmp/recordings"

cat >"$tmp/bin/omarchy-capture-screenrecording-process" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_HELPER_CALLS"
[[ ${1:-} == "--pid" && ${2:-} == "123" && ${TEST_RECORDER_ACTIVE:-0} == "1" ]]
SH

cat >"$tmp/bin/pactl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_AUDIO_CALLS"
SH
chmod +x "$tmp/bin/omarchy-capture-screenrecording-process" "$tmp/bin/pactl"

export PATH="$tmp/bin:$ROOT/bin:$PATH"
export XDG_RUNTIME_DIR="$tmp/runtime"
export OMARCHY_SCREENRECORD_DIR="$tmp/recordings"
export TEST_HELPER_CALLS="$tmp/helper-calls"
export TEST_AUDIO_CALLS="$tmp/audio-calls"
echo 123 >"$XDG_RUNTIME_DIR/omarchy-screenrecord-pid"

for action in --status --stop-recording; do
  printf '10\n11\n12\n' >"$XDG_RUNTIME_DIR/omarchy-screenrecord-pa-modules"
  : >"$TEST_HELPER_CALLS"
  : >"$TEST_AUDIO_CALLS"
  status=0
  "$ROOT/bin/omarchy-capture-screenrecording" "$action" >/dev/null 2>&1 || status=$?
  (( status == 1 )) || fail "$action reports no recorder after it exits" "$status"
  [[ $(<"$TEST_AUDIO_CALLS") == $'unload-module 12\nunload-module 11\nunload-module 10' ]] ||
    fail "$action releases the exited recorder's audio loopbacks before its sink" "$(<"$TEST_AUDIO_CALLS")"
  [[ ! -e $XDG_RUNTIME_DIR/omarchy-screenrecord-pa-modules ]] || fail "$action removes the stale audio module list"
  ! grep -q -- '--signal' "$TEST_HELPER_CALLS" || fail "$action signals no other recorder"
  pass "$action releases audio capture after the saved recorder exits"
done

printf '10\n11\n12\n' >"$XDG_RUNTIME_DIR/omarchy-screenrecord-pa-modules"
: >"$TEST_AUDIO_CALLS"
TEST_RECORDER_ACTIVE=1 "$ROOT/bin/omarchy-capture-screenrecording" --status || fail "status recognizes the active recorder"
[[ ! -s $TEST_AUDIO_CALLS && -e $XDG_RUNTIME_DIR/omarchy-screenrecord-pa-modules ]] ||
  fail "status leaves an active recording's audio modules loaded"
pass "status preserves the active recorder's audio capture"

rm "$XDG_RUNTIME_DIR/omarchy-screenrecord-pid"
: >"$TEST_AUDIO_CALLS"
status=0
"$ROOT/bin/omarchy-capture-screenrecording" --status >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "status reports inactive before the recorder starts"
[[ ! -s $TEST_AUDIO_CALLS && -e $XDG_RUNTIME_DIR/omarchy-screenrecord-pa-modules ]] ||
  fail "status preserves the audio mix created before the recorder starts"
pass "status leaves the starting recorder's audio mix alone"
