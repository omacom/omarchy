#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

tmp=$(mktemp -d)
cleanup() {
  for child in $(jobs -pr); do kill "$child" 2>/dev/null || true; done
  if [[ -f $tmp/recorder-pid ]]; then kill "$(<"$tmp/recorder-pid")" 2>/dev/null || true; fi
  rm -rf "$tmp"
}
trap cleanup EXIT
mkdir -p "$tmp/bin" "$tmp/runtime" "$tmp/recordings"
mkfifo "$tmp/release"

cat >"$tmp/bin/omarchy-capture-screenrecording-process" <<'SH'
#!/bin/bash
if [[ ${1:-} != "--pid" || $2 == "123" ]]; then
  if [[ ${TEST_ROLE:-} == "old-status" && ${2:-} == "123" ]]; then
    touch "$TEST_STATE/checked"
    read -r _ <"$TEST_STATE/release"
  fi
  exit 1
fi
[[ -f $TEST_STATE/recorder-pid && $2 == "$(<"$TEST_STATE/recorder-pid")" ]] || exit 1
if [[ ${3:-} == "--signal" ]]; then kill -TERM "$2"; else kill -0 "$2" 2>/dev/null; fi
SH
cat >"$tmp/bin/wf-recorder" <<'SH'
#!/bin/bash
echo "$$" >"$TEST_STATE/recorder-pid"
for arg in "$@"; do
  if [[ ${next:-} == 1 ]]; then [[ -n ${TEST_NEVER_READY:-} ]] || touch "$arg"; break; fi
  [[ $arg == "-f" ]] && next=1
done
if [[ -n ${TEST_IGNORE_TERM:-} ]]; then trap '' TERM; else trap 'exit 0' TERM INT; fi
while true; do sleep 0.05; done
SH
cat >"$tmp/bin/pactl" <<'SH'
#!/bin/bash
case $1 in
  get-default-sink) echo desktop ;;
  get-default-source) echo microphone ;;
  load-module)
    id=$(<"$TEST_STATE/next-module")
    echo $(( id + 1 )) >"$TEST_STATE/next-module"
    touch "$TEST_STATE/module-$id"
    echo "$id"
    ;;
  unload-module) rm -f "$TEST_STATE/module-$2" ;;
esac
SH
cat >"$tmp/bin/flock" <<'SH'
#!/bin/bash
[[ ${TEST_ROLE:-} == "new-start" ]] && touch "$TEST_STATE/lock-attempted"
exec /usr/bin/flock "$@"
SH
cat >"$tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "wf-recorder" ]]
SH
cat >"$tmp/bin/omarchy-hyprland-monitor-focused" <<'SH'
#!/bin/bash
echo Virtual-1
SH
cat >"$tmp/bin/ffmpeg" <<'SH'
#!/bin/bash
if [[ ${TEST_ROLE:-} == "old-stop" && ! -e $TEST_STATE/checked ]]; then
  touch "$TEST_STATE/checked"
  read -r _ <"$TEST_STATE/release"
fi
touch "${@: -3:1}"
SH
for command in omarchy-shell omarchy-notification-send ffprobe pkill; do
  printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/$command"
done
cat >"$tmp/bin/omarchy-shell" <<'SH'
#!/bin/bash
# A stop that finds no start pending while the start is finishing.
if [[ -n ${TEST_LATE_STOP:-} && ! -e $TEST_STATE/late-stop-sent ]]; then
  touch "$TEST_STATE/late-stop-sent"
  rm -f "$XDG_RUNTIME_DIR/omarchy-screenrecord-starting"
  TEST_LATE_STOP= "$TEST_RECORD" --stop-recording 9>&- >/dev/null 2>&1 &
  echo $! >"$TEST_STATE/late-stop-pid"
  until [[ -e $XDG_RUNTIME_DIR/omarchy-screenrecord-cancel ]]; do sleep 0.05; done
fi
if [[ -n ${TEST_PAUSE_INDICATOR:-} && ! -e $TEST_STATE/indicator-paused ]]; then
  touch "$TEST_STATE/indicator-paused"
  read -r _ <"$TEST_STATE/release"
fi
exit 0
SH
chmod +x "$tmp/bin/"*
export PATH="$tmp/bin:$ROOT/bin:$PATH" TEST_STATE="$tmp" XDG_RUNTIME_DIR="$tmp/runtime"
export OMARCHY_SCREENRECORD_DIR="$tmp/recordings"
record="$ROOT/bin/omarchy-capture-screenrecording"
export TEST_RECORD=$record

wait_for() {
  for _ in {1..200}; do
    for file in "$@"; do [[ ! -e $file ]] || return 0; done
    sleep 0.01
  done
  fail "concurrent recording command reached its barrier" "$*"
}

assert_recording() {
  [[ -s $XDG_RUNTIME_DIR/omarchy-screenrecord-pid && -s $XDG_RUNTIME_DIR/omarchy-screenrecord-filename ]] ||
    fail "the new recording retains its saved state"
  [[ -f $XDG_RUNTIME_DIR/omarchy-screenrecord-pa-modules ]] || fail "the new recording retains its audio mix"
  for module in $(<"$XDG_RUNTIME_DIR/omarchy-screenrecord-pa-modules"); do
    [[ -f $tmp/module-$module ]] || fail "the new recording's audio module stays loaded" "$module"
  done
}

echo 123 >"$XDG_RUNTIME_DIR/omarchy-screenrecord-pid"
printf '10\n11\n12\n' >"$XDG_RUNTIME_DIR/omarchy-screenrecord-pa-modules"
touch "$tmp/module-10" "$tmp/module-11" "$tmp/module-12"
echo 20 >"$tmp/next-module"
TEST_ROLE=old-status "$record" --status >/dev/null 2>&1 & old=$!
wait_for "$tmp/checked"
TEST_ROLE=new-start "$record" --fullscreen --resolution=1280x800 --with-desktop-audio --with-microphone-audio >/dev/null 2>&1 & new=$!
wait_for "$tmp/lock-attempted" "$tmp/recorder-pid"
if [[ ! -e $tmp/lock-attempted ]]; then
  wait_for "$XDG_RUNTIME_DIR/omarchy-screenrecord-pid"
  for _ in {1..200}; do
    [[ $(<"$XDG_RUNTIME_DIR/omarchy-screenrecord-pid") == 123 ]] || break
    sleep 0.01
  done
  [[ $(<"$XDG_RUNTIME_DIR/omarchy-screenrecord-pid") != 123 ]] || fail "the concurrent recording saves its PID"
fi
echo release >"$tmp/release"
status=0
wait "$old" || status=$?
(( status == 1 )) || fail "the old status reports its exited recorder" "$status"
wait "$new" || fail "the new recording starts"
assert_recording
pass "stale status cleanup cannot unload a concurrent new recording's audio"

rm -f "$tmp/checked" "$tmp/lock-attempted"
TEST_ROLE=old-stop "$record" --stop-recording >/dev/null 2>&1 & old=$!
wait_for "$tmp/checked"
rm "$tmp/recorder-pid"
stop_locked=0
if ! /usr/bin/flock -n "$XDG_RUNTIME_DIR/omarchy-screenrecord.lock" true; then stop_locked=1; fi
TEST_ROLE=new-start "$record" --fullscreen --resolution=1280x800 --with-desktop-audio --with-microphone-audio >/dev/null 2>&1 & new=$!
wait_for "$tmp/lock-attempted" "$tmp/recorder-pid"
if (( ! stop_locked )); then
  wait "$new" || fail "the concurrent recording starts while the old stop is paused"
  new=""
fi
echo release >"$tmp/release"
wait "$old" || fail "the old recording stops"
if [[ -n $new ]]; then
  wait "$new" || fail "another recording starts after stop"
fi
assert_recording
pass "a finishing stop cannot remove a concurrent new recording's state"

"$record" --stop-recording >/dev/null 2>&1 || fail "the earlier recording stops"

# A recorder that never creates its file keeps the start waiting. Another
# toggle, or a stop, cancels that start instead of queueing a new one behind it.
for second in toggle stop; do
  # Names are per second, so an earlier recording's file would look ready.
  rm -f "$tmp/recorder-pid" "$tmp/recordings/"*
  # The stop's recorder ignores TERM, so ending it needs the KILL that follows.
  ignore_term=""
  [[ $second == "stop" ]] && ignore_term=1
  TEST_IGNORE_TERM=$ignore_term TEST_NEVER_READY=1 "$record" --fullscreen --resolution=1280x800 --with-desktop-audio --with-microphone-audio >/dev/null 2>&1 & pending=$!
  wait_for "$tmp/recorder-pid"
  waiting=$(<"$tmp/recorder-pid")
  args=(--fullscreen --resolution=1280x800)
  [[ $second == "stop" ]] && args=(--stop-recording)
  timeout 5 "$record" "${args[@]}" >/dev/null 2>&1 || fail "a $second during a pending start returns at once"
  timeout 5 tail --pid="$pending" -f /dev/null || fail "the pending start ends once a $second cancels it"
  wait "$pending" || true
  ! kill -0 "$waiting" 2>/dev/null || fail "a cancelled start stops its recorder"
  [[ $(<"$tmp/recorder-pid") == "$waiting" ]] || fail "a $second during a pending start does not begin another recording"
  for state in pid filename pa-modules starting cancel; do
    [[ ! -e $XDG_RUNTIME_DIR/omarchy-screenrecord-$state ]] || fail "a cancelled start leaves no $state behind"
  done
  pass "a $second during a start that is still waiting on its recorder cancels it"
done

# A stop that arrives while the start is saving its recording as started still
# ends that recording.
rm -f "$tmp/recorder-pid" "$tmp/recordings/"* "$tmp/indicator-paused"
TEST_PAUSE_INDICATOR=1 "$record" --fullscreen --resolution=1280x800 --with-desktop-audio >/dev/null 2>&1 & pending=$!
wait_for "$tmp/indicator-paused"
committed=$(<"$tmp/recorder-pid")
timeout 5 "$record" --stop-recording >/dev/null 2>&1 || fail "a stop during the start's last step returns"
echo release >"$tmp/release"
timeout 5 tail --pid="$pending" -f /dev/null || fail "the start finishes after its last step"
wait "$pending" || true
! kill -0 "$committed" 2>/dev/null || fail "a stop during the start's last step ends the recording"
for state in pid filename pa-modules starting cancel; do
  [[ ! -e $XDG_RUNTIME_DIR/omarchy-screenrecord-$state ]] || fail "a stop during the start's last step leaves no $state behind"
done
pass "a stop while the start saves its recording as started still ends it"

# A stop that finds no start pending while the start is still finishing waits
# for the lock, and the recording ends either way.
rm -f "$tmp/recorder-pid" "$tmp/recordings/"* "$tmp/late-stop-sent" "$tmp/late-stop-pid"
TEST_LATE_STOP=1 "$record" --fullscreen --resolution=1280x800 >/dev/null 2>&1 || fail "the start with a late stop finishes"
started=$(<"$tmp/recorder-pid")
timeout 10 tail --pid="$(<"$tmp/late-stop-pid")" -f /dev/null || fail "the late stop finishes"
! kill -0 "$started" 2>/dev/null || fail "a stop waiting behind a finishing start still ends the recording"
[[ ! -e $XDG_RUNTIME_DIR/omarchy-screenrecord-pid && ! -e $XDG_RUNTIME_DIR/omarchy-screenrecord-cancel ]] ||
  fail "a late stop leaves no state behind"
pass "a stop that waits behind a finishing start still ends the recording"

"$record" --stop-recording >/dev/null 2>&1 || true

# A start that was killed leaves its marker behind. A toggle that waits on the
# lock (held here as a stop would) does not take that stale marker for a start
# still in progress: it waits its turn and starts the recording.
rm -f "$tmp/recorder-pid" "$tmp/recordings/"* "$XDG_RUNTIME_DIR/omarchy-screenrecord-cancel"
true & dead=$!
wait "$dead"
echo "$dead" >"$XDG_RUNTIME_DIR/omarchy-screenrecord-starting"
/usr/bin/flock "$XDG_RUNTIME_DIR/omarchy-screenrecord.lock" sleep 2 & holder=$!
sleep 0.3
timeout 15 "$record" --fullscreen --resolution=1280x800 >/dev/null 2>&1 || fail "a toggle behind a stale start marker finishes"
wait "$holder" || true
[[ -s $XDG_RUNTIME_DIR/omarchy-screenrecord-pid ]] && kill -0 "$(<"$tmp/recorder-pid")" 2>/dev/null ||
  fail "a toggle behind a stale start marker starts the recording instead of cancelling a start that is gone"
"$record" --stop-recording >/dev/null 2>&1 || true
pass "a killed start's leftover marker does not swallow a later toggle"
