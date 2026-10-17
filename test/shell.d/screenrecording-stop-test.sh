#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

tmp=$(mktemp -d)
cleanup() {
  [[ -s $tmp/recorder-pid ]] && kill -KILL "$(<"$tmp/recorder-pid")" 2>/dev/null || true
  rm -rf "$tmp"
}
trap cleanup EXIT
mkdir -p "$tmp/bin" "$tmp/runtime" "$tmp/recordings"

cat >"$tmp/bin/omarchy-capture-screenrecording-process" <<'SH'
#!/bin/bash
[[ ${1:-} == "--pid" ]] && kill -0 "$2" 2>/dev/null || exit 1
if [[ ${3:-} == "--signal" ]]; then
  echo "$4" >>"$TEST_STATE/signals"
  kill "-$4" "$2"
fi
exit 0
SH
cat >"$tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
echo "$*" >>"$TEST_STATE/notifications"
SH
cat >"$tmp/bin/ffmpeg" <<'SH'
#!/bin/bash
touch "${@: -3:1}"
SH
for command in omarchy-shell ffprobe; do
  printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/$command"
done
# On INT, a slow recorder keeps writing its recording out for 10 seconds; a
# stalled one does nothing at all, as a recorder stopped with SIGSTOP would.
cat >"$tmp/bin/recorder" <<'SH'
#!/bin/bash
if [[ $2 == "stalled" ]]; then
  trap '' INT
  echo "$$" >"$TEST_STATE/recorder-pid"
  exec sleep 60
else
  trap 'for _ in {1..20}; do echo packet >>"$1"; sleep 0.5; done; touch "$TEST_STATE/finished"; exit 0' INT
  echo "$$" >"$TEST_STATE/recorder-pid"
  while true; do sleep 0.05; done
fi
SH
chmod +x "$tmp/bin/"*
export PATH="$tmp/bin:$ROOT/bin:$PATH" TEST_STATE="$tmp" XDG_RUNTIME_DIR="$tmp/runtime"
export OMARCHY_SCREENRECORD_DIR="$tmp/recordings"

stop_recording() {
  local recording="$tmp/recordings/$1.mp4"
  rm -f "$tmp/recorder-pid" "$tmp/signals" "$tmp/notifications" "$tmp/finished"
  : >"$recording"
  # Started from a subshell, so a recorder that exits is reaped rather than left a zombie that answers kill -0,
  # and with INT restored, which a background job otherwise starts with ignored.
  (env --default-signal=INT "$tmp/bin/recorder" "$recording" "$1" &)
  for _ in {1..100}; do
    [[ -s $tmp/recorder-pid ]] && break
    sleep 0.05
  done
  echo "$(<"$tmp/recorder-pid")" >"$XDG_RUNTIME_DIR/omarchy-screenrecord-pid"
  echo "$recording" >"$XDG_RUNTIME_DIR/omarchy-screenrecord-filename"
  sleep 0.2
  timeout 90 "$ROOT/bin/omarchy-capture-screenrecording" --stop-recording >/dev/null 2>&1 ||
    fail "a stop of the $1 recorder returns"
}

stop_recording slow
! grep -Fxq KILL "$tmp/signals" || fail "a recorder still writing out its recording is not killed" "$(<"$tmp/signals")"
[[ -e $tmp/finished ]] || fail "a slow recorder finishes writing out its recording"
grep -Fq "Screen recording saved" "$tmp/notifications" || fail "a slow recorder's recording is announced as saved" "$(<"$tmp/notifications")"
pass "stop waits for a recorder that takes more than 5 seconds to write out its recording"

stop_recording stalled
grep -Fxq KILL "$tmp/signals" || fail "a recorder that has stalled is killed" "$(cat "$tmp/signals" 2>/dev/null)"
grep -Fq "force-killed" "$tmp/notifications" || fail "a killed recorder is announced as such" "$(<"$tmp/notifications")"
pass "stop kills a recorder that has stalled"
