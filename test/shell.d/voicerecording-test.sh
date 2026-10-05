#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

tmp_dir=$(mktemp -d)
stub_bin="$tmp_dir/bin"
trap 'pkill -f "$stub_bin/ffmpeg" 2>/dev/null || true; rm -rf "$tmp_dir"' EXIT

mkdir -p "$stub_bin"

# Nothing is recording yet, so start rather than stop
cat >"$stub_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH

# Stands in for the recorder: create the output file (its last argument) the way
# ffmpeg does once capture starts, then keep running until the test ends.
cat >"$stub_bin/ffmpeg" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_FFMPEG_ARGS"
: >"${@: -1}"
sleep 5
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_NOTIFICATION_ARGS"
SH

cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$stub_bin"/*

export PATH="$stub_bin:$ROOT/bin:$PATH"
export XDG_RUNTIME_DIR="$tmp_dir/runtime"
export OMARCHY_TEST_FFMPEG_ARGS="$tmp_dir/ffmpeg-args"
export OMARCHY_TEST_NOTIFICATION_ARGS="$tmp_dir/notification-args"
mkdir -p "$XDG_RUNTIME_DIR"

recording_dir="$tmp_dir/recordings"
mkdir -p "$recording_dir"

OMARCHY_VOICERECORD_DIR="$recording_dir" "$ROOT/bin/omarchy-capture-voicerecording" >/dev/null 2>&1 ||
  fail "voice recording starts" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS" 2>/dev/null || true)"
pass "voice recording starts"

grep -Fx -- "pulse" "$OMARCHY_TEST_FFMPEG_ARGS" >/dev/null && grep -Fx -- "default" "$OMARCHY_TEST_FFMPEG_ARGS" >/dev/null ||
  fail "voice recording captures the default input" "$(cat "$OMARCHY_TEST_FFMPEG_ARGS")"
pass "voice recording captures the default input"

state_file="$XDG_RUNTIME_DIR/omarchy-voicerecord-filename"
[[ -s $state_file && $(<"$state_file") == "$recording_dir"/voicerecording-*.m4a ]] ||
  fail "the recording state file names the recording that was started" "$(cat "$state_file" 2>/dev/null || true)"
pass "the recording state file names the recording that was started"

[[ -f $(<"$state_file") ]] || fail "the recording lands in the voice recording directory" "$(ls -a "$recording_dir")"
pass "the recording lands in the voice recording directory"

grep -Fx "Voice recording started" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "starting a voice recording says so" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "starting a voice recording says so"

pkill -f "$stub_bin/ffmpeg" 2>/dev/null || true
rm -f "$OMARCHY_TEST_FFMPEG_ARGS"

if OMARCHY_VOICERECORD_DIR="$tmp_dir/missing" "$ROOT/bin/omarchy-capture-voicerecording" >/dev/null 2>&1; then
  fail "voice recording refuses a missing output directory"
fi
[[ ! -e $OMARCHY_TEST_FFMPEG_ARGS ]] || fail "voice recording does not start without an output directory"
grep -F "Voice recording directory does not exist: $tmp_dir/missing" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "voice recording reports the missing output directory" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "voice recording refuses a missing output directory"

if OMARCHY_VOICERECORD_DIR="$recording_dir" "$ROOT/bin/omarchy-capture-voicerecording" --stop-recording; then
  fail "stopping with nothing recording fails"
fi
[[ ! -e $OMARCHY_TEST_FFMPEG_ARGS ]] || fail "stopping with nothing recording does not start a recording"
pass "stopping with nothing recording fails"

# The menu, the bar indicator, and the command find the recorder by the name
# ffmpeg runs under, so all of them have to agree on it.
recorder_name=$(sed -n 's/^RECORDER_NAME="\(.*\)"$/\1/p' "$ROOT/bin/omarchy-capture-voicerecording")
[[ -n $recorder_name ]] || fail "voice recording names its recorder process"

grep -F "\"when\":\"pgrep -f '^$recorder_name '\"" "$ROOT/default/omarchy/omarchy-menu.jsonc" >/dev/null ||
  fail "the menu shows Stop Recording while the voice recorder runs"
grep -F "\"when\":\"! pgrep -f '^$recorder_name '\"" "$ROOT/default/omarchy/omarchy-menu.jsonc" >/dev/null ||
  fail "the menu hides Voice Recording while the recorder runs"
grep -F "\"^$recorder_name \"" "$ROOT/shell/plugins/bar/indicators/VoiceRecording.qml" >/dev/null ||
  fail "the bar indicator watches the voice recorder"
pass "the menu and bar indicator watch the recorder the command starts"
