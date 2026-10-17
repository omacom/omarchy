#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sleep_monitor="$ROOT/bin/omarchy-system-sleep-monitor"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
mock_omarchy="$tmpdir/omarchy"
lock_log="$tmpdir/lock-log"
layout_log="$tmpdir/layout-log"
wake_log="$tmpdir/wake-log"
resume_ready="$tmpdir/resume-ready"
prepare_seen="$tmpdir/prepare-seen"
producer_pids="$tmpdir/producer-pids"
mkdir -p "$mock_bin" "$mock_omarchy/bin"

cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash
while [[ $1 == --* ]]; do shift; done
exec "$@"
SH

cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash
echo "$$" >>"$PRODUCER_PIDS"
case "${OMARCHY_SLEEP_EVENT_ROLE:-}" in
  resume)
    if [[ -n ${RESUME_SILENT:-} ]]; then
      exec sleep 30
    else
      # Subscription exists before the inhibited listener. Queue the prepare edge,
      # then keep this exact producer alive until the lock path has handled it.
      touch "$RESUME_READY"
      printf '   boolean true\n'
      for _ in {1..200}; do
        [[ -e $PREPARE_SEEN ]] && break
        sleep 0.01
      done
      printf '   boolean false\n'
      exec sleep 30
    fi
    ;;
  prepare)
    for _ in {1..200}; do
      [[ -e $RESUME_READY ]] && break
      sleep 0.01
    done
    printf '   boolean true\n'
    exec sleep 30
    ;;
  *)
    exit 2
    ;;
esac
SH

cat >"$mock_omarchy/bin/omarchy-system-sleep-lock" <<'SH'
#!/bin/bash
echo locked >>"$LOCK_LOG"
touch "$PREPARE_SEEN"
SH

cat >"$mock_omarchy/bin/omarchy-hyprland-keyboard-layout" <<'SH'
#!/bin/bash
echo "$1" >>"$LAYOUT_LOG"
SH

cat >"$mock_omarchy/bin/omarchy-system-wake" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$WAKE_LOG"
SH

chmod +x "$mock_bin/systemd-inhibit" "$mock_bin/dbus-monitor"   "$mock_omarchy/bin/omarchy-system-sleep-lock"   "$mock_omarchy/bin/omarchy-hyprland-keyboard-layout"   "$mock_omarchy/bin/omarchy-system-wake"
ln -s "$sleep_monitor" "$mock_omarchy/bin/omarchy-system-sleep-monitor"

OMARCHY_PATH="$mock_omarchy" PATH="$mock_bin:$PATH"   LOCK_LOG="$lock_log" LAYOUT_LOG="$layout_log" WAKE_LOG="$wake_log"   RESUME_READY="$resume_ready" PREPARE_SEEN="$prepare_seen" PRODUCER_PIDS="$producer_pids"   "$sleep_monitor"

# Neither subscription may outlive the cycle under the user systemd instance.
while read -r producer_pid; do
  if kill -0 "$producer_pid" 2>/dev/null; then
    kill "$producer_pid" 2>/dev/null || true
    fail "sleep monitor reaps its event producers" "producer still running: $producer_pid"
  fi
done <"$producer_pids"
pass "sleep monitor reaps its event producers"

[[ $(<"$lock_log") == "locked" ]] ||
  fail "full sleep cycle invokes the lock helper"
mapfile -t layout_calls <"$layout_log"
[[ ${layout_calls[0]:-} == save && ${layout_calls[1]:-} == restore && ${#layout_calls[@]} -eq 2 ]] ||
  fail "one subscription cycle saves before sleep and restores after resume" "$(cat "$layout_log")"
[[ $(<"$wake_log") == "--skip-keyboard" ]] ||
  fail "resume wakes the session without consuming the lock/idle keyboard receipt" "$(cat "$wake_log")"
pass "one prepare/resume subscription cycle owns both keyboard layout edges"

# The key regression: resume listener must have subscribed before the prepare
# listener can release the delay inhibitor.
[[ -e $resume_ready && -e $prepare_seen ]] ||
  fail "resume subscription was not established before prepare completed"
pass "resume subscription exists before the sleep inhibitor is released"

# Unit-mode edges remain independently testable.
: >"$layout_log"
printf '   boolean true\n' |   OMARCHY_PATH="$mock_omarchy" LAYOUT_LOG="$layout_log" LOCK_LOG="$lock_log" PREPARE_SEEN="$prepare_seen"   "$sleep_monitor" --consume-prepare
[[ $(<"$layout_log") == save ]] || fail "prepare consumer saves layout"

: >"$layout_log"
: >"$wake_log"
printf '   boolean false\n' |   OMARCHY_PATH="$mock_omarchy" LAYOUT_LOG="$layout_log" WAKE_LOG="$wake_log"   "$sleep_monitor" --consume-resume
[[ $(<"$layout_log") == restore ]] || fail "resume consumer restores layout"
[[ $(<"$wake_log") == "--skip-keyboard" ]] || fail "resume consumer skips duplicate keyboard restore"
pass "prepare and resume consumers preserve their individual edge behavior"

# A stalled resume helper must not keep the monitor from re-arming the inhibitor.
cat >"$mock_omarchy/bin/omarchy-system-wake" <<'SH'
#!/bin/bash
exec sleep 30
SH
start_us=${EPOCHREALTIME//[!0-9]/}
printf '   boolean false\n' | OMARCHY_PATH="$mock_omarchy" LAYOUT_LOG="$layout_log" \
  "$sleep_monitor" --consume-resume
elapsed_us=$((10#${EPOCHREALTIME//[!0-9]/} - 10#$start_us))
(( elapsed_us < 10000000 )) ||
  fail "resume consumer bounds a stalled wake helper" "elapsed: ${elapsed_us}us"
pass "resume consumer bounds a stalled wake helper"

# An inhibitor that never starts its listener means no sleep is coming, so the
# monitor must exit and re-arm rather than wait for a resume edge without a lock.
inhibit_ran="$tmpdir/inhibit-ran"
cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash
touch "$INHIBIT_RAN"
for _ in {1..200}; do
  [[ -s $PRODUCER_PIDS ]] && break
  sleep 0.01
done
exit 1
SH
: >"$producer_pids"
start_us=${EPOCHREALTIME//[!0-9]/}
status=0
OMARCHY_PATH="$mock_omarchy" PATH="$mock_bin:$PATH" RESUME_SILENT=1 PRODUCER_PIDS="$producer_pids" INHIBIT_RAN="$inhibit_ran" \
  timeout 20s "$sleep_monitor" || status=$?
elapsed_us=$((10#${EPOCHREALTIME//[!0-9]/} - 10#$start_us))
[[ -e $inhibit_ran && -s $producer_pids ]] ||
  fail "failed inhibitor start exercises the inhibitor with a live resume producer"
(( status == 1 )) || fail "failed inhibitor start is reported to systemd" "status: $status"
(( elapsed_us < 10000000 )) ||
  fail "monitor re-arms when the inhibitor fails to start" "elapsed: ${elapsed_us}us"
while read -r producer_pid; do
  if kill -0 "$producer_pid" 2>/dev/null; then
    kill "$producer_pid" 2>/dev/null || true
    fail "failed inhibitor start reaps the resume producer" "producer still running: $producer_pid"
  fi
done <"$producer_pids"
pass "monitor re-arms when the inhibitor fails to start"

# The prepare producer ending without an edge is the same: nothing is sleeping.
status=0
: | OMARCHY_PATH="$mock_omarchy" LAYOUT_LOG="$layout_log" "$sleep_monitor" --consume-prepare || status=$?
(( status != 0 )) || fail "prepare consumer reports a producer that ended without a prepare edge"
pass "prepare consumer reports a producer that ended without a prepare edge"

# A lock that fails does not stop the suspend, so the cycle must still be resumed.
cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash
while [[ $1 == --* ]]; do shift; done
exec "$@"
SH
cat >"$mock_omarchy/bin/omarchy-system-sleep-lock" <<'SH'
#!/bin/bash
echo failed >>"$LOCK_LOG"
touch "$PREPARE_SEEN"
exit 1
SH
cat >"$mock_omarchy/bin/omarchy-system-wake" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$WAKE_LOG"
SH
rm -f "$resume_ready" "$prepare_seen"
: >"$lock_log"
: >"$layout_log"
: >"$wake_log"
: >"$producer_pids"
OMARCHY_PATH="$mock_omarchy" PATH="$mock_bin:$PATH" \
  LOCK_LOG="$lock_log" LAYOUT_LOG="$layout_log" WAKE_LOG="$wake_log" \
  RESUME_READY="$resume_ready" PREPARE_SEEN="$prepare_seen" PRODUCER_PIDS="$producer_pids" \
  timeout 20s "$sleep_monitor" || fail "a failed lock after a prepare edge completes the cycle"
[[ $(<"$lock_log") == "failed" ]] || fail "failed lock cycle runs the lock helper" "$(cat "$lock_log")"
mapfile -t layout_calls <"$layout_log"
[[ ${layout_calls[0]:-} == "save" && ${layout_calls[1]:-} == "restore" ]] && (( ${#layout_calls[@]} == 2 )) ||
  fail "a failed lock after a prepare edge still restores on resume" "$(cat "$layout_log")"
[[ $(<"$wake_log") == "--skip-keyboard" ]] ||
  fail "a failed lock after a prepare edge still wakes on resume" "$(cat "$wake_log")"
while read -r producer_pid; do
  if kill -0 "$producer_pid" 2>/dev/null; then
    kill "$producer_pid" 2>/dev/null || true
    fail "failed lock cycle reaps its event producers" "producer still running: $producer_pid"
  fi
done <"$producer_pids"
pass "a failed lock after a prepare edge still resumes the cycle"
