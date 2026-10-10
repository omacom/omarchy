#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

TMPDIR=$(mktemp -d)
event_pid=""
trap 'if [[ -n $event_pid ]]; then
  kill "$event_pid" 2>/dev/null || true
  wait "$event_pid" 2>/dev/null || true
fi
rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin" "$TMPDIR/home"
NOTIFY_LOG="$TMPDIR/notify-log"
QUERY_LOG="$TMPDIR/query-log"
JOURNAL_ENTRIES="$TMPDIR/journal-entries"
FAIL_COUNT="$TMPDIR/fail-count"
: >"$NOTIFY_LOG"
: >"$QUERY_LOG"
: >"$JOURNAL_ENTRIES"
printf '0\n' >"$FAIL_COUNT"

uid=$(id -u)

# One event name per line, without changing whitespace in the input.
cat >"$TMPDIR/bin/inotifywait" <<'SH'
#!/bin/bash
[[ ${!#} == "/run/omarchy-crash-events" ]] || exit 1
printf '%s\n' "$WATCH_ITEMS"
SH

# Only the requested handler invocation is returned, never a reused PID.
# Invocation 5001 is delayed twice to exercise journal delivery retries.
cat >"$TMPDIR/bin/journalctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$QUERY_LOG"
for arg in "$@"; do
  case $arg in
    -f|--follow) exit 1 ;;
    MESSAGE_ID=*) message_id=${arg#*=} ;;
    _SYSTEMD_INVOCATION_ID=*) invocation=${arg#*=} ;;
  esac
done
[[ ${message_id:-} == "fc2e22bc6ee647b6b90729ab34a250b1" ]] || exit 1
[[ -n ${invocation:-} ]] || exit 1
if [[ $invocation == "00000000000000000000000000001389" ]]; then
  fails=$(cat "$FAIL_COUNT")
  if (( fails < 2 )); then
    printf '%s\n' "$((fails + 1))" >"$FAIL_COUNT"
    exit 1
  fi
fi
jq -c --arg invocation "$invocation" \
  'select(._SYSTEMD_INVOCATION_ID == $invocation)' "$JOURNAL_ENTRIES"
SH

cat >"$TMPDIR/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
jq -cn --args '$ARGS.positional' -- "$@" >>"$NOTIFY_LOG"
SH

cat >"$TMPDIR/bin/omarchy-notification-wait" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$TMPDIR/bin/omarchy-default-agent" <<'SH'
#!/bin/bash
[[ ${NO_AGENT:-0} == 0 ]] && printf '%s\n' default-agent
SH

cat >"$TMPDIR/bin/sleep" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$TMPDIR/bin"/*

run_watch() {
  local items=$1
  shift
  (
    export PATH="$TMPDIR/bin:$ROOT/bin:$PATH"
    export WATCH_ITEMS="$items" NOTIFY_LOG="$NOTIFY_LOG" FAIL_COUNT="$FAIL_COUNT"
    export QUERY_LOG="$QUERY_LOG" JOURNAL_ENTRIES="$JOURNAL_ENTRIES" HOME="$TMPDIR/home"
    for kv in "$@"; do export "$kv"; done
    timeout 5 "$ROOT/bin/omarchy-crash-watch"
  )
}

notify_count() {
  wc -l <"$NOTIFY_LOG"
}

events() {
  printf '%032x\n' "$@"
}

# No COREDUMP_FILENAME: notification must not depend on a saved core.
crash_entry() { # invocation comm pid exe signal [uid]
  jq -cn --arg invocation "$(events "$1")" --arg comm "$2" --arg pid "$3" \
    --arg exe "$4" --arg signal "$5" --arg uid "${6:-$uid}" \
    '{_SYSTEMD_INVOCATION_ID: $invocation, _BOOT_ID: "deadbeefdeadbeefdeadbeefdeadbeef",
      COREDUMP_UID: $uid, COREDUMP_COMM: $comm, COREDUMP_PID: $pid,
      COREDUMP_EXE: $exe, COREDUMP_SIGNAL_NAME: $signal}' >>"$JOURNAL_ENTRIES"
}

announced() {
  jq -es --arg name "$1" \
    'any(.[]; .[4] == ("Process crashed: " + $name))' "$NOTIFY_LOG" >/dev/null
}

diagnosis_is() {
  jq -es --arg pid "$1" --arg name "$2" --arg exe "$3" --arg signal "$4" \
    'any(.[]; .[7:] == ["omarchy-agent-crash", $pid, $name, $exe, $signal])' \
    "$NOTIFY_LOG" >/dev/null
}

crash_entry 1001 foo-bar 1001 /usr/bin/foo-bar-real SIGSEGV
crash_entry 1002 other 1002 /usr/bin/other-real SIGABRT
crash_entry 1004 omarchy-agent-foo 1004 /usr/bin/omarchy-agent-foo SIGSEGV
crash_entry 1005 sigonly 1005 "" SIGABRT
crash_entry 1006 "" 1006 "" SIGSEGV
crash_entry 1007 .hidden 1007 "" SIGSEGV
crash_entry 1008 "foo bar" 1008 "" SIGABRT
crash_entry 1009 $'foo\tbar' 1009 "" SIGSEGV
crash_entry 3001 alien 3001 /usr/bin/alien SIGSEGV 424242
crash_entry 5001 slowcore 5001 /usr/bin/slowcore-real SIGABRT
crash_entry 6000 previous 5001 /usr/bin/previous SIGSEGV

: >"$NOTIFY_LOG"
run_watch "$(events 1001 1002)"
(( $(notify_count) == 2 )) ||
  fail "one toast per crash" "got: $(notify_count) toasts"
announced foo-bar-real ||
  fail "toast uses the executable basename, not the 15-char comm"
announced other-real ||
  fail "toast for the second crash"
diagnosis_is 1001 foo-bar-real /usr/bin/foo-bar-real SIGSEGV ||
  fail "diagnosis command carries pid, name, executable, and signal"
diagnosis_is 1002 other-real /usr/bin/other-real SIGABRT ||
  fail "diagnosis command for the second crash"
! announced foo-bar ||
  fail "truncated comm never reaches the toast when the executable is known"
pass "watcher announces crashes without core files, preserving SIG-prefixed signals"

: >"$NOTIFY_LOG"
run_watch "$(events 3001 1004 1002)" OMARCHY_CRASH_DEDUPE_SECONDS=0
(( $(notify_count) == 1 )) ||
  fail "foreign-uid and omarchy-own crashes are skipped" "got: $(notify_count) toasts"
announced other-real ||
  fail "the remaining crash is still announced"
pass "watcher skips other users' and its own crashes"

: >"$NOTIFY_LOG"
run_watch "$(events 1001 1002)" OMARCHY_CRASH_IGNORE='foo'
(( $(notify_count) == 1 )) ||
  fail "ignored patterns are not announced" "got: $(notify_count) toasts"
announced other-real ||
  fail "non-ignored crashes are still announced"
pass "watcher honors the ignore pattern"

: >"$NOTIFY_LOG"
run_watch "$(events 1001 1001)" OMARCHY_CRASH_DEDUPE_SECONDS=3600
(( $(notify_count) == 1 )) ||
  fail "duplicate events within the dedupe window are announced once" "got: $(notify_count) toasts"
pass "watcher dedupes crash loops per window"

: >"$NOTIFY_LOG"
run_watch "$(events 1001 1001)" OMARCHY_CRASH_DEDUPE_SECONDS=0
(( $(notify_count) == 2 )) ||
  fail "a zero dedupe window announces every event" "got: $(notify_count) toasts"
pass "watcher announces again outside the dedupe window"

: >"$NOTIFY_LOG"
: >"$QUERY_LOG"
run_watch "$(events 9999 1002)" 2>"$TMPDIR/warnings"
(( $(notify_count) == 1 )) || fail "missing metadata stops the next event"
grep -Fq "No crash details for coredump invocation $(events 9999)" "$TMPDIR/warnings" ||
  fail "an event with no journal metadata is dropped silently"
(( $(wc -l <"$QUERY_LOG") == 21 )) || fail "missing metadata retries are not bounded"
pass "watcher logs missing metadata, bounds retries, and processes the next event"

: >"$NOTIFY_LOG"
printf '0\n' >"$FAIL_COUNT"
: >"$QUERY_LOG"
run_watch "$(events 5001)" OMARCHY_CRASH_IGNORE='previous'
(( $(notify_count) == 1 )) ||
  fail "crash whose journal entry lands late is still announced" "got: $(notify_count) toasts"
diagnosis_is 5001 slowcore-real /usr/bin/slowcore-real SIGABRT ||
  fail "a reused PID selected the previous program instead of the new invocation"
(( $(wc -l <"$QUERY_LOG") == 3 )) || fail "late journal delivery did not retry twice"
pass "watcher waits for the exact invocation despite PID reuse within the same boot"

: >"$NOTIFY_LOG"
run_watch "$(events 1006 1002)"
(( $(notify_count) == 2 )) || fail "an empty comm shifts or drops crash fields"
diagnosis_is 1006 unknown unknown SIGSEGV || fail "an empty comm shifts diagnosis fields"
pass "watcher announces an empty comm without shifting fields or dropping the next crash"

: >"$NOTIFY_LOG"
run_watch "$(events 1005)"
(( $(notify_count) == 1 )) ||
  fail "a crash with no executable is still announced" "got: $(notify_count) toasts"
diagnosis_is 1005 sigonly unknown SIGABRT ||
  fail "a missing executable does not shift the signal into its place"
pass "watcher keeps the signal when the executable is missing"

: >"$NOTIFY_LOG"
run_watch "$(events 1007 1008 1009)"
(( $(notify_count) == 3 )) || fail "original process names are split or lost"
diagnosis_is 1007 .hidden unknown SIGSEGV || fail "a leading dot becomes a filename escape"
diagnosis_is 1008 "foo bar" unknown SIGABRT || fail "a space splits a diagnosis argument"
diagnosis_is 1009 $'foo\tbar' unknown SIGSEGV || fail "a tab splits a diagnosis argument"
pass "watcher preserves original names and argument boundaries without filename decoding"

: >"$NOTIFY_LOG"
: >"$QUERY_LOG"
run_watch $'../bad\nfoo bar\n'"$(events 1002)"
(( $(notify_count) == 1 && $(wc -l <"$QUERY_LOG") == 1 )) ||
  fail "a malformed event name reaches the journal lookup"
pass "watcher only queries valid InvocationID events"

: >"$NOTIFY_LOG"
: >"$QUERY_LOG"
run_watch "$(events 1001)" NO_AGENT=1
[[ ! -s $NOTIFY_LOG && ! -s $QUERY_LOG ]] || fail "a watcher without an agent queries crashes"
pass "watcher skips lookups and notifications until an agent is selected"

# Exercise the drop-in's actual marker commands with real inotify in a scratch
# directory. This does not install a unit, change the host, or trigger a crash.
require_command inotifywait
dropin="$ROOT/etc/systemd/system/systemd-coredump@.service.d/10-omarchy-crash-events.conf"
grep -Fxq 'RuntimeDirectoryMode=0755' "$dropin" || fail "the event directory is user-writable"
grep -Fxq 'RuntimeDirectoryPreserve=yes' "$dropin" || fail "handler exit removes the watch directory"
grep -Fxq 'd /run/omarchy-crash-events 0755 root root -' \
  "$ROOT/etc/tmpfiles.d/omarchy-crash-events.conf" || fail "events are not created root-owned at boot"

mkdir "$TMPDIR/events"
inotifywait --timeout 3 -e create --format '%f' "$TMPDIR/events" \
  >"$TMPDIR/event-name" 2>"$TMPDIR/event-log" &
event_pid=$!
for attempt in {1..50}; do
  grep -Fq 'Watches established.' "$TMPDIR/event-log" && break
  sleep 0.02
done
grep -Fq 'Watches established.' "$TMPDIR/event-log" || fail "the marker test never established its watch"

while IFS= read -r command; do
  INVOCATION_ID="$(events 1001)" bash -euc \
    "${command//\/run\/omarchy-crash-events/$TMPDIR/events}"
done < <(sed -n 's/^ExecStopPost=-//p' "$dropin")

wait "$event_pid" || fail "an ephemeral marker produces no inotify event"
event_pid=""
[[ $(cat "$TMPDIR/event-name") == "$(events 1001)" ]] || fail "the event loses its InvocationID"
[[ ! -e $TMPDIR/events/$(events 1001) ]] || fail "the hook leaves a marker behind"
pass "the completion hook emits a real inotify event without retaining a marker or a core"

require_command systemd-analyze
cp /usr/lib/systemd/system/systemd-coredump@.service "$TMPDIR/"
mkdir "$TMPDIR/systemd-coredump@.service.d"
cp "$dropin" "$TMPDIR/systemd-coredump@.service.d/"
SYSTEMD_UNIT_PATH="$TMPDIR:/usr/lib/systemd/system" \
  systemd-analyze --man=no --generators=no verify "$TMPDIR/systemd-coredump@.service" \
  >"$TMPDIR/unit-check" 2>&1 || fail "the coredump drop-in is invalid" "$(cat "$TMPDIR/unit-check")"
pass "systemd accepts the completion drop-in with the installed coredump service"
