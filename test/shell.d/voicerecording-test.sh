#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

tmp_dir=$(mktemp -d)
stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"

# Stubs below replace these, so keep the real ones for the test itself
real_pgrep=$(command -v pgrep)
real_pkill=$(command -v pkill)
real_ffmpeg=$(command -v ffmpeg)
real_ffprobe=$(command -v ffprobe)

cleanup() {
  "$real_pkill" -9 -f "$tmp_dir/" 2>/dev/null || true
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

# The recorder counts as running while the process the capture stub recorded is
# alive. Anything but a lookup limited to this user's recorder is a bug.
cat >"$stub_bin/pgrep" <<'SH'
#!/bin/bash
if [[ "$*" != "-u $UID -f ^omarchy-voicerecorder " ]]; then
  echo "pgrep $*" >>"$OMARCHY_TEST_STUB_ERRORS"
  exit 2
fi
[[ -s $OMARCHY_TEST_RECORDER_PID ]] && kill -0 "$(<"$OMARCHY_TEST_RECORDER_PID")" 2>/dev/null
SH

# A bash stub can't trap the SIGINT its background launch ignores, so SIGINT is
# delivered as TERM, which the capture stub treats the way ffmpeg treats SIGINT
cat >"$stub_bin/pkill" <<'SH'
#!/bin/bash
if [[ "${*:2}" != "-u $UID -f ^omarchy-voicerecorder " ]]; then
  echo "pkill $*" >>"$OMARCHY_TEST_STUB_ERRORS"
  exit 2
fi
printf '%s\n' "$1" >>"$OMARCHY_TEST_PKILL_ARGS"
pid=$(<"$OMARCHY_TEST_RECORDER_PID")
case $1 in
-SIGINT) kill -TERM "$pid" ;;
-9) kill -9 "$pid" ;;
esac
SH

# Stands in for every ffmpeg run. The capture (-f pulse) creates its output file
# (the last argument) the way ffmpeg does once it has the microphone and runs
# until signalled; a hanging one ignores the stop, and a stalling one never gets
# the microphone and ignores TERM too. The cleanup can wait at a gate, can
# produce nothing, or can fail its loudness pass (-af) the way loudnorm does on
# a clip too short or quiet to measure. The decode check (-f null) passes what
# the cleanup wrote.
cat >"$stub_bin/ffmpeg" <<'SH'
#!/bin/bash
if [[ " $* " == *" -f null "* ]]; then
  while (($#)) && [[ $1 != "-i" ]]; do shift; done
  [[ -s $2 && $(<"$2") == @(processed|remuxed) ]]
  exit
fi

if [[ " $* " != *" pulse "* ]]; then
  printf '%s\n' "$@" >"$OMARCHY_TEST_FINALIZE_ARGS"
  echo "finalize-begin" >>"$OMARCHY_TEST_ORDER"
  if [[ -n ${OMARCHY_TEST_FINALIZE_GATE:-} ]]; then
    for _ in {1..400}; do
      [[ -e $OMARCHY_TEST_FINALIZE_GATE ]] && break
      sleep 0.05
    done
  fi
  echo "finalize-end" >>"$OMARCHY_TEST_ORDER"
  case ${OMARCHY_TEST_FINALIZE:-} in
  empty) exit 0 ;;
  unmeasurable) [[ " $* " == *" -af "* ]] && exit 234 ;;
  esac
  if [[ " $* " == *" -af "* ]]; then
    echo "processed" >"${@: -1}"
  else
    echo "remuxed" >"${@: -1}"
  fi
  exit 0
fi

printf '%s\n' "$@" >"$OMARCHY_TEST_FFMPEG_ARGS"
echo $$ >"$OMARCHY_TEST_RECORDER_PID"
echo "capture" >>"$OMARCHY_TEST_ORDER"
if [[ ${OMARCHY_TEST_RECORDER:-} == @(hangs|stalls) ]]; then
  trap '' TERM
else
  trap 'exit 0' TERM
fi
[[ ${OMARCHY_TEST_RECORDER:-} == "stalls" ]] || : >"${@: -1}"
while :; do
  sleep 0.1
done
SH

# Pins the timestamp in recording names when a test asks for it
cat >"$stub_bin/date" <<SH
#!/bin/bash
if [[ -n \${OMARCHY_TEST_DATE:-} ]]; then
  echo "\$OMARCHY_TEST_DATE"
else
  exec $(command -v date) "\$@"
fi
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >>"$OMARCHY_TEST_NOTIFICATION_ARGS"
SH

cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_SHELL_ARGS"
SH

chmod +x "$stub_bin"/*

export HOME="$tmp_dir/home"
export XDG_RUNTIME_DIR="$tmp_dir/runtime"
export OMARCHY_TEST_STUB_ERRORS="$tmp_dir/stub-errors"
export OMARCHY_TEST_RECORDER_PID="$tmp_dir/recorder-pid"
export OMARCHY_TEST_PKILL_ARGS="$tmp_dir/pkill-args"
export OMARCHY_TEST_FFMPEG_ARGS="$tmp_dir/ffmpeg-args"
export OMARCHY_TEST_FINALIZE_ARGS="$tmp_dir/finalize-args"
export OMARCHY_TEST_ORDER="$tmp_dir/order"
export OMARCHY_TEST_NOTIFICATION_ARGS="$tmp_dir/notification-args"
export OMARCHY_TEST_SHELL_ARGS="$tmp_dir/shell-args"
mkdir -p "$HOME" "$XDG_RUNTIME_DIR"

recording_dir="$tmp_dir/recordings"
mkdir -p "$recording_dir"
export OMARCHY_VOICERECORD_DIR="$recording_dir"
state_file="$XDG_RUNTIME_DIR/omarchy-voicerecord-filename"

original_path=$PATH
export PATH="$stub_bin:$ROOT/bin:$PATH"

reset_logs() {
  rm -f "$OMARCHY_TEST_PKILL_ARGS" "$OMARCHY_TEST_FFMPEG_ARGS" "$OMARCHY_TEST_FINALIZE_ARGS" "$OMARCHY_TEST_ORDER" \
    "$OMARCHY_TEST_NOTIFICATION_ARGS" "$OMARCHY_TEST_SHELL_ARGS"
}

# A deadlock fails the test instead of hanging it
voicerecording() {
  timeout 30 "$ROOT/bin/omarchy-capture-voicerecording" "$@"
}

recorder_alive() {
  [[ -s $OMARCHY_TEST_RECORDER_PID ]] && kill -0 "$(<"$OMARCHY_TEST_RECORDER_PID")" 2>/dev/null
}

# Stands in for a recorder the stop signals; the path argument is only there so
# the cleanup can find it
start_fake_recorder() {
  bash -c 'trap "exit 0" TERM; while :; do sleep 0.1; done' "$tmp_dir/fake-recorder" >/dev/null 2>&1 &
  echo $! >"$OMARCHY_TEST_RECORDER_PID"
}

# True once a process descended from PID is blocked in flock
waiting_at_lock() {
  local waiter ancestor
  for waiter in $("$real_pgrep" -x flock); do
    ancestor=$waiter
    while [[ -n $ancestor ]] && ((ancestor > 1)); do
      ((ancestor == $1)) && return 0
      ancestor=$(ps -o ppid= -p "$ancestor" 2>/dev/null | tr -d ' ')
    done
  done
  return 1
}

# Audio packets in FILE so far, 0 while there are none to count
packets() {
  local count
  count=$("$real_ffprobe" -v error -select_streams a -count_packets -show_entries stream=nb_read_packets -of csv=p=0 "$1" 2>/dev/null | head -n 1)
  [[ $count =~ ^[0-9]+$ ]] || count=0
  echo "$count"
}

wait_for_line() {
  local line=$1 file=$2
  for _ in {1..100}; do
    grep -qx -- "$line" "$file" 2>/dev/null && return 0
    sleep 0.05
  done
  return 1
}

# ---------------------------------------------------------------- start

reset_logs
voicerecording >/dev/null 2>&1 || fail "voice recording starts" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS" 2>/dev/null || true)"
pass "voice recording starts"

for arg in pulse default -frag_duration -flush_packets -n; do
  grep -Fx -- "$arg" "$OMARCHY_TEST_FFMPEG_ARGS" >/dev/null ||
    fail "voice recording records the default input into flushed fragments, never overwriting" "$(cat "$OMARCHY_TEST_FFMPEG_ARGS")"
done
pass "voice recording records the default input into flushed fragments, never overwriting"

[[ -s $state_file && $(<"$state_file") == "$recording_dir"/voicerecording-*.m4a && -f $(<"$state_file") ]] ||
  fail "the recording state file names the recording that was started" "$(cat "$state_file" 2>/dev/null || true)"
recording=$(<"$state_file")
pass "the recording state file names the recording that was started"

grep -Fx "Voice recording started" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "starting a voice recording says so" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
grep -Fx -- "-q omarchy.indicators refresh" "$OMARCHY_TEST_SHELL_ARGS" >/dev/null ||
  fail "starting a voice recording refreshes the bar indicator"
pass "starting a voice recording says so and refreshes the bar indicator"

# ---------------------------------------------------------------- stop

reset_logs
saved=$(voicerecording --stop-recording 2>/dev/null) || fail "stopping an active voice recording succeeds"

[[ $(paste -sd' ' "$OMARCHY_TEST_PKILL_ARGS") == "-SIGINT" ]] ||
  fail "stopping sends the recorder SIGINT and nothing harsher" "$(cat "$OMARCHY_TEST_PKILL_ARGS")"
! recorder_alive || fail "stopping ends the recorder"
pass "stopping sends the recorder SIGINT and nothing harsher"

grep -Fx -- "-nostdin" "$OMARCHY_TEST_FINALIZE_ARGS" >/dev/null ||
  fail "the cleanup never reads the terminal, where a q would cut it short" "$(cat "$OMARCHY_TEST_FINALIZE_ARGS")"
pass "the cleanup never reads the terminal, where a q would cut it short"

[[ $saved == "$recording" ]] || fail "stopping prints the saved recording" "expected: $recording\nactual:   $saved"
[[ $(<"$recording") == "processed" ]] || fail "stopping replaces the recording with the cleaned-up audio"
[[ $(ls -A "$recording_dir") == "$(basename "$recording")" ]] ||
  fail "stopping leaves no intermediate file behind" "$(ls -A "$recording_dir")"
pass "stopping saves the cleaned-up recording under its original name"

[[ ! -e $state_file ]] || fail "stopping removes the recording state file"
grep -Fx -- "-q omarchy.indicators refresh" "$OMARCHY_TEST_SHELL_ARGS" >/dev/null ||
  fail "stopping refreshes the bar indicator"
grep -Fx "Voice recording saved" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null &&
  grep -Fx -- "$recording" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "stopping offers to play the saved recording" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "stopping clears its state, refreshes the bar, and offers the saved recording"

# ---------------------------------------------------------------- restart

# Stopping and starting again within the same second must not reuse the name
export OMARCHY_TEST_DATE="2026-01-01_00-00-00"
reset_logs
voicerecording >/dev/null 2>&1 || fail "a recording starts within its second"
first=$(<"$state_file")
voicerecording --stop-recording >/dev/null 2>&1 || fail "a recording stops within its second"
reset_logs
voicerecording >/dev/null 2>&1 || fail "a recording starts again within the same second"
second=$(<"$state_file")
[[ $second != "$first" && -f $second && $(<"$first") == "processed" ]] ||
  fail "a new recording never takes an earlier recording's name" "first: $first\nsecond: $second"
grep -Fx "Voice recording started" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null || fail "the second recording really starts"
pass "a new recording never takes an earlier recording's name"
voicerecording --stop-recording >/dev/null 2>&1 || fail "the restarted recording stops"
unset OMARCHY_TEST_DATE

# ---------------------------------------------------------------- sidecar

# Whatever already sits next to the recording, the cleanup writes only to a
# file of its own
reset_logs
voicerecording >/dev/null 2>&1 || fail "a recording with a planted sidecar starts"
recording=$(<"$state_file")
canary="$tmp_dir/canary"
echo "untouched" >"$canary"
ln -s "$canary" "${recording%.m4a}-processed.m4a"
voicerecording --stop-recording >/dev/null 2>&1 || fail "a recording with a planted sidecar stops"
[[ $(<"$canary") == "untouched" && $(<"$recording") == "processed" ]] ||
  fail "the cleanup never writes through a file it didn't create" "canary: $(<"$canary")"
rm -f "${recording%.m4a}-processed.m4a"
pass "the cleanup never writes through a file it didn't create"

# ---------------------------------------------------------------- state write

# A recording the stop couldn't find must not be left running
reset_logs
mkdir "$state_file"
if voicerecording >/dev/null 2>&1; then
  fail "a start whose state can't be saved fails"
fi
! recorder_alive || fail "a start whose state can't be saved ends its recorder"
grep -Fx "Voice recording failed to start" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "a start whose state can't be saved says so" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
rmdir "$state_file"
pass "a start whose state can't be saved ends its recorder and says so"

# ---------------------------------------------------------------- force-kill

reset_logs
OMARCHY_TEST_RECORDER=hangs voicerecording >/dev/null 2>&1 || fail "a recorder that will hang starts"
recording=$(<"$state_file")
reset_logs
saved=$(voicerecording --stop-recording 2>/dev/null) || fail "stopping a hung recorder succeeds"

[[ $(paste -sd' ' "$OMARCHY_TEST_PKILL_ARGS") == "-SIGINT -9" ]] ||
  fail "a recorder that ignores SIGINT is force-killed" "$(cat "$OMARCHY_TEST_PKILL_ARGS")"
! recorder_alive || fail "force-killing ends the recorder"
grep -Fx "Voice recording force-stopped" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "force-killing the recorder says so" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
[[ $saved == "$recording" && $(<"$recording") == "processed" && ! -e $state_file ]] ||
  fail "a force-killed recording is still cleaned up and saved"
pass "a recorder that ignores SIGINT is force-killed and its recording still saved"

# ---------------------------------------------------------------- failed cleanup

reset_logs
voicerecording >/dev/null 2>&1 || fail "a recording whose cleanup fails starts"
recording=$(<"$state_file")
echo "as recorded" >"$recording"
reset_logs
if OMARCHY_TEST_FINALIZE=empty voicerecording --stop-recording >/dev/null 2>&1; then
  fail "a cleanup that produces no audio is reported as a failure"
fi
[[ $(<"$recording") == "as recorded" ]] || fail "a failed cleanup leaves the recording exactly as recorded"
[[ $(ls -A "$recording_dir" | grep -c '^\.') == 0 ]] || fail "a failed cleanup leaves no intermediate file behind" "$(ls -A "$recording_dir")"
grep -Fx "Voice recording may be damaged" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null &&
  ! grep -Fx "Voice recording saved" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "a failed cleanup is not announced as saved" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "a cleanup that produces no audio keeps the original and says so"

# ---------------------------------------------------------------- unmeasurable

# loudnorm can't measure a clip too short or too quiet, which isn't damage: keep
# it as recorded, rewritten as a regular .m4a, and call it saved
reset_logs
voicerecording >/dev/null 2>&1 || fail "a recording too short to measure starts"
recording=$(<"$state_file")
reset_logs
OMARCHY_TEST_FINALIZE=unmeasurable voicerecording --stop-recording >/dev/null 2>&1 ||
  fail "a recording too short to measure is saved"
[[ $(<"$recording") == "remuxed" ]] || fail "a recording too short to measure is kept as recorded" "$(<"$recording")"
grep -Fx "Voice recording saved" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "a recording too short to measure is announced as saved" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "a recording too short to measure is kept as recorded and saved"

# ---------------------------------------------------------------- stalled start

# Starting holds the lock, so a recorder that never gets the microphone must be
# given up on, or nothing could stop it. This one ignores TERM as well.
reset_logs
if OMARCHY_TEST_RECORDER=stalls voicerecording >/dev/null 2>&1; then
  fail "a recorder that never starts recording is a failed start"
fi
! recorder_alive || fail "a stalled recorder is ended, even one that ignores TERM"
[[ ! -e $state_file ]] || fail "a stalled start leaves no state behind"
grep -Fx "Voice recording failed to start" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "a stalled start says so" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
status=0
timeout 5 "$ROOT/bin/omarchy-capture-voicerecording" --stop-recording >/dev/null 2>&1 || status=$?
((status == 1)) || fail "a stalled start releases the lock" "a stop afterwards exited $status"
pass "a recorder that never starts recording is ended and the lock released"

# ---------------------------------------------------------------- interrupted start

# A start killed while it waits for the microphone takes its recorder with it,
# rather than leaving one running that no state file points at
reset_logs
OMARCHY_TEST_RECORDER=stalls "$ROOT/bin/omarchy-capture-voicerecording" >/dev/null 2>&1 &
launcher_pid=$!
wait_for_line "capture" "$OMARCHY_TEST_ORDER" || fail "an interrupted start launches its recorder"
kill -TERM "$launcher_pid"
wait "$launcher_pid" 2>/dev/null || true
! recorder_alive || fail "an interrupted start ends its recorder"
[[ ! -e $state_file ]] || fail "an interrupted start leaves no state behind"
pass "an interrupted start ends its recorder"

# ---------------------------------------------------------------- lock failure

# Without the lock, starts and stops could overlap, so refuse to run at all
reset_logs
rm -f "$XDG_RUNTIME_DIR/omarchy-voicerecord.lock"
mkdir "$XDG_RUNTIME_DIR/omarchy-voicerecord.lock"
if voicerecording >/dev/null 2>&1; then
  fail "voice recording refuses to run without its lock"
fi
[[ ! -e $OMARCHY_TEST_FFMPEG_ARGS ]] || fail "voice recording starts nothing without its lock"
rmdir "$XDG_RUNTIME_DIR/omarchy-voicerecord.lock"
pass "voice recording refuses to run without its lock"

# ---------------------------------------------------------------- overlap

# A recording started while the last one is still being cleaned up has to wait
# for that stop to finish, or the two would trade state files. The cleanup
# waits at a gate, so the second start gets every chance to overtake it.
reset_logs
voicerecording >/dev/null 2>&1 || fail "a recording to overlap starts"
first_recording=$(<"$state_file")
reset_logs
gate="$tmp_dir/finalize-gate"
OMARCHY_TEST_FINALIZE_GATE="$gate" voicerecording --stop-recording >"$tmp_dir/first-saved" 2>/dev/null &
stop_pid=$!
wait_for_line "finalize-begin" "$OMARCHY_TEST_ORDER" || fail "the first recording reaches its cleanup"

voicerecording >/dev/null 2>&1 &
start_pid=$!
# Released only once the second start is provably queued behind the lock, so a
# slow start can't pass by arriving late
for _ in {1..100}; do
  waiting_at_lock "$start_pid" && break
  sleep 0.05
done
waiting_at_lock "$start_pid" || fail "a new recording waits at the lock while the last one is saved"
if grep -qx "capture" "$OMARCHY_TEST_ORDER"; then
  fail "a new recording waits for the last one to finish saving" "$(cat "$OMARCHY_TEST_ORDER")"
fi
touch "$gate"
wait "$stop_pid" || fail "the overlapped stop succeeds"
wait "$start_pid" || fail "the waiting start succeeds"

[[ $(paste -sd' ' "$OMARCHY_TEST_ORDER") == "finalize-begin finalize-end capture" ]] ||
  fail "a new recording waits for the last one to finish saving" "$(cat "$OMARCHY_TEST_ORDER")"
[[ $(<"$tmp_dir/first-saved") == "$first_recording" ]] ||
  fail "the overlapped stop saves its own recording" "$(<"$tmp_dir/first-saved")"
[[ -s $state_file && $(<"$state_file") != "$first_recording" && -f $(<"$state_file") ]] ||
  fail "the new recording keeps its state file" "$(cat "$state_file" 2>/dev/null || echo missing)"
pass "a recording started during a save waits for it and keeps its own state"

voicerecording --stop-recording >/dev/null 2>&1 || fail "the waiting recording stops"

# ---------------------------------------------------------------- idle

reset_logs
if voicerecording --stop-recording >/dev/null 2>&1; then
  fail "stopping with nothing recording fails"
fi
[[ ! -e $OMARCHY_TEST_FFMPEG_ARGS ]] || fail "stopping with nothing recording does not start a recording"
grep -Fx -- "-q omarchy.indicators refresh" "$OMARCHY_TEST_SHELL_ARGS" >/dev/null ||
  fail "stopping with nothing recording clears a stale bar indicator"
pass "stopping with nothing recording fails and clears a stale bar indicator"

reset_logs
if OMARCHY_VOICERECORD_DIR="$tmp_dir/missing" voicerecording >/dev/null 2>&1; then
  fail "voice recording refuses a missing output directory"
fi
[[ ! -e $OMARCHY_TEST_FFMPEG_ARGS ]] || fail "voice recording does not start without an output directory"
grep -F "Voice recording directory does not exist: $tmp_dir/missing" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "voice recording reports the missing output directory" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "voice recording refuses a missing output directory"

[[ ! -s $OMARCHY_TEST_STUB_ERRORS ]] ||
  fail "every recorder lookup and signal is limited to this user's recorder" "$(cat "$OMARCHY_TEST_STUB_ERRORS")"
pass "every recorder lookup and signal is limited to this user's recorder"

# ---------------------------------------------------------------- real audio

# The rest runs the real ffmpeg cleanup on synthetic audio written with the
# recorder's fragment settings. No microphone is involved.
eval "$(sed -n 's/^\(FRAGMENT_ARGS=(.*)\)$/\1/p' "$ROOT/bin/omarchy-capture-voicerecording")"
((${#FRAGMENT_ARGS[@]})) || fail "the recorder's fragment settings can be read"

real_bin="$tmp_dir/real-bin"
mkdir -p "$real_bin"
cp "$stub_bin"/{pgrep,pkill,omarchy-notification-send,omarchy-shell} "$real_bin/"

decodes_fully() {
  "$real_ffmpeg" -nostdin -v error -xerror -i "$1" -map 0:a:0 -f null - >/dev/null 2>&1
}

# Stop the recording at FILE with the real ffmpeg cleanup
stop_with_real_ffmpeg() {
  start_fake_recorder
  echo "$1" >"$state_file"
  reset_logs
  PATH="$real_bin:$ROOT/bin:$original_path" voicerecording --stop-recording >/dev/null 2>&1
}

# Hard-kill a real ffmpeg once two seconds of fragments are on disk
synthetic="$recording_dir/voicerecording-synthetic.m4a"
"$real_ffmpeg" -nostdin -hide_banner -loglevel error -re -f lavfi -i "sine=frequency=440:sample_rate=48000" \
  -c:a aac "${FRAGMENT_ARGS[@]}" "$synthetic" >/dev/null 2>&1 &
synthetic_pid=$!
for _ in {1..200}; do
  (($(packets "$synthetic") >= 94)) && break
  sleep 0.1
done
kill -9 "$synthetic_pid"
wait "$synthetic_pid" 2>/dev/null || true

(($(packets "$synthetic") >= 94)) && decodes_fully "$synthetic" ||
  fail "a hard-killed recording still decodes, all but its last second" "packets: $(packets "$synthetic")"
pass "a hard-killed recording still decodes, all but its last second"

stop_with_real_ffmpeg "$synthetic" ||
  fail "a hard-killed recording is cleaned up and saved" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS" 2>/dev/null || true)"
decodes_fully "$synthetic" && (($(packets "$synthetic") >= 94)) || fail "the cleaned-up recording decodes"
! LC_ALL=C grep -a -q moof "$synthetic" || fail "the cleaned-up recording is a regular .m4a, not fragments"
grep -Fx "Voice recording saved" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "a cleaned-up hard-killed recording is announced as saved" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "a hard-killed recording is cleaned up into a regular .m4a"

# A second of silence is too quiet for loudnorm, so the real cleanup has to
# fall back to keeping it as recorded
quiet="$recording_dir/voicerecording-quiet.m4a"
"$real_ffmpeg" -nostdin -hide_banner -loglevel error -f lavfi -i "anullsrc=r=48000:cl=stereo" -t 1 \
  -c:a aac "${FRAGMENT_ARGS[@]}" "$quiet"
stop_with_real_ffmpeg "$quiet" ||
  fail "a short silent recording is saved" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS" 2>/dev/null || true)"
decodes_fully "$quiet" && ! LC_ALL=C grep -a -q moof "$quiet" ||
  fail "a short silent recording is saved as a regular .m4a"
pass "a short silent recording, which loudnorm can't measure, is saved as a regular .m4a"

# Audio damaged past its first packet still has its packets, so the rewrite
# the quiet clip fell back on would succeed. It mustn't count as saved.
damaged="$recording_dir/voicerecording-damaged.m4a"
"$real_ffmpeg" -nostdin -hide_banner -loglevel error -f lavfi -i "sine=frequency=440:sample_rate=48000" -t 4 \
  -c:a aac "${FRAGMENT_ARGS[@]}" "$damaged"
python3 - "$damaged" <<'PY'
import struct, sys
path = sys.argv[1]
data = bytearray(open(path, "rb").read())
offset, first = 0, True
while offset + 8 <= len(data):
    size, kind = struct.unpack(">I4s", data[offset:offset + 8])
    if size < 8:
        break
    if kind == b"mdat":
        if not first:
            data[offset + 8:offset + size] = bytes(size - 8)
        first = False
    offset += size
open(path, "wb").write(data)
PY
cp "$damaged" "$tmp_dir/damaged-original"
if stop_with_real_ffmpeg "$damaged"; then
  fail "a damaged recording is not reported as saved" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
fi
cmp -s "$damaged" "$tmp_dir/damaged-original" || fail "a damaged recording is kept exactly as recorded"
[[ $(ls -A "$recording_dir" | grep -c '^\.') == 0 ]] || fail "a damaged recording leaves no intermediate file" "$(ls -A "$recording_dir")"
grep -Fx "Voice recording may be damaged" "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "a damaged recording is reported as possibly damaged" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "a damaged recording is kept as recorded and reported, not saved"

# ---------------------------------------------------------------- leftovers

! "$real_pgrep" -f "$tmp_dir/" >/dev/null || fail "no recorder stub outlives the test" "$("$real_pgrep" -af "$tmp_dir/")"
pass "no recorder stub outlives the test"

# ---------------------------------------------------------------- wiring

# The menu, the bar indicator, and the command find the recorder by the name
# ffmpeg runs under, so all of them have to agree on it.
recorder_name=$(sed -n 's/^RECORDER_NAME="\(.*\)"$/\1/p' "$ROOT/bin/omarchy-capture-voicerecording")
[[ -n $recorder_name ]] || fail "voice recording names its recorder process"

grep -F "\"when\":\"pgrep -u \$UID -f '^$recorder_name '\"" "$ROOT/default/omarchy/omarchy-menu.jsonc" >/dev/null ||
  fail "the menu shows Stop Recording while this user's voice recorder runs"
grep -F "\"when\":\"! pgrep -u \$UID -f '^$recorder_name '\"" "$ROOT/default/omarchy/omarchy-menu.jsonc" >/dev/null ||
  fail "the menu hides Voice Recording while this user's voice recorder runs"
grep -F "pgrep --quiet -u \\\"\$UID\\\" -f '^$recorder_name '" "$ROOT/shell/plugins/bar/indicators/VoiceRecording.qml" >/dev/null ||
  fail "the bar indicator watches this user's voice recorder"
pass "the menu and bar indicator watch this user's recorder"
