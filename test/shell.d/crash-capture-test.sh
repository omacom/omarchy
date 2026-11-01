#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
event_pid=""
trap 'if [[ -n $event_pid ]]; then
  kill "$event_pid" 2>/dev/null || true
  wait "$event_pid" 2>/dev/null || true
fi
rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"
SYSTEMCTL_LOG="$TMPDIR/systemctl-log"

cat >"$TMPDIR/bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
SH

cat >"$TMPDIR/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$TMPDIR/bin/systemctl" "$TMPDIR/bin/omarchy-notification-send"

test_home="$TMPDIR/home"
flag="$test_home/.local/state/omarchy/toggles/crash-capture-off"

toggle_crash_capture() {
  PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
  HOME="$test_home" \
    "$ROOT/bin/omarchy-toggle-crash-capture"
}

toggle_crash_capture
[[ -f $flag ]] || fail "crash capture toggle disables the watcher"
grep -Fqx -- "--user stop omarchy-crash-watch.service" "$SYSTEMCTL_LOG" ||
  fail "crash capture toggle stops the running watcher, so disabling takes effect before the next login"
pass "crash capture toggle disables the watcher"

: >"$SYSTEMCTL_LOG"
toggle_crash_capture
[[ ! -f $flag ]] || fail "crash capture toggle re-enables the watcher"
grep -Fqx -- "--user start omarchy-crash-watch.service" "$SYSTEMCTL_LOG" ||
  fail "crash capture toggle starts the watcher, so enabling takes effect before the next login"
pass "crash capture toggle re-enables the watcher"

require_command jq

# The watcher's announcements and the per-program mute, driven through the real
# watcher with stubbed events and journal: these prove what a person sees -- a
# toast arriving or not, carrying which words -- where asserting that a flag
# file was read would prove only that a flag file was read.
watch_bin="$TMPDIR/watch-bin"
watch_home="$TMPDIR/watch-home"
NOTIFY_LOG="$TMPDIR/notify-log"
QUERY_LOG="$TMPDIR/query-log"
JOURNAL_ENTRIES="$TMPDIR/journal-entries"
FAIL_COUNT="$TMPDIR/fail-count"

mkdir -p "$watch_bin" "$watch_home"
: >"$NOTIFY_LOG"
: >"$QUERY_LOG"
: >"$JOURNAL_ENTRIES"
printf '0\n' >"$FAIL_COUNT"

# One event name per line, unchanged, and only for the directory the watcher
# watches.
cat >"$watch_bin/inotifywait" <<'SH'
#!/bin/bash
[[ ${!#} == "/run/omarchy-crash-events" ]] || exit 1
printf '%s\n' "$WATCH_ITEMS"
SH

# Only the requested invocation is returned, never a reused PID. Invocation 5001
# is delayed twice so a journal delivery retry is observable.
cat >"$watch_bin/journalctl" <<'SH'
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

# The toast as the argv it was sent, so a name holding a space or a tab stays one
# argument and each diagnosis word can be asserted in its own slot.
cat >"$watch_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
jq -cn --args '$ARGS.positional' -- "$@" >>"$NOTIFY_LOG"
SH

cat >"$watch_bin/omarchy-default-agent" <<'SH'
#!/bin/bash
[[ ${NO_AGENT:-0} == 0 ]] && printf '%s\n' claude
SH

cat >"$watch_bin/omarchy-notification-wait" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$watch_bin/sleep" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$watch_bin"/*

reset_entries() {
  : >"$JOURNAL_ENTRIES"
}

events() {
  printf '%032x\n' "$@"
}

# One core dump as systemd-coredump journals it, with the invocation, pid,
# executable, signal and uid given, so a test can pin a reused PID, a missing
# executable, or another user's crash. The UID must be this user's unless the
# test means somebody else's, or the watcher discards the entry before anything
# under test.
journal_entry() { # invocation comm pid exe signal [uid]
  jq -cn --arg invocation "$(events "$1")" --arg comm "$2" --arg pid "$3" \
    --arg exe "$4" --arg signal "$5" --arg uid "${6:-$UID}" \
    '{_SYSTEMD_INVOCATION_ID: $invocation, COREDUMP_UID: $uid, COREDUMP_COMM: $comm,
      COREDUMP_PID: $pid, COREDUMP_EXE: $exe, COREDUMP_SIGNAL_NAME: $signal}' \
    >>"$JOURNAL_ENTRIES"
}

# A crash the mute tests only need by name: one invocation per entry appended.
crash_entry() { # comm exe
  journal_entry "$(( $(wc -l <"$JOURNAL_ENTRIES") + 1 ))" "$1" 4242 "$2" SIGSEGV
}

# The stubbed inotifywait ends after the events, so the watcher's loop ends too.
# Its exit status is asserted rather than discarded: a watcher that dies on one
# event notifies about nothing afterwards, which every assertion below that
# expects silence would otherwise read as success. Without explicit event names
# every journaled crash is replayed, one event per entry.
run_watch() { # [event names] [VAR=value ...]
  local items=${1-} status=0
  if (( $# )); then shift; fi
  [[ -n $items ]] || items=$(jq -r '._SYSTEMD_INVOCATION_ID' "$JOURNAL_ENTRIES")

  : >"$NOTIFY_LOG"

  (
    export PATH="$watch_bin:$ROOT/bin:$PATH"
    export WATCH_ITEMS="$items" NOTIFY_LOG="$NOTIFY_LOG" QUERY_LOG="$QUERY_LOG"
    export JOURNAL_ENTRIES="$JOURNAL_ENTRIES" FAIL_COUNT="$FAIL_COUNT" HOME="$watch_home"
    for kv in "$@"; do export "$kv"; done
    timeout 5 "$ROOT/bin/omarchy-crash-watch"
  ) || status=$?

  (( status == 0 )) ||
    fail "the watcher exited $status rather than carrying on, so one event takes the service down with it"
}

notify_count() {
  wc -l <"$NOTIFY_LOG"
}

# Through the real command rather than writing the flag by hand: these assertions
# are then the guard that the thing the diagnosis runs and the thing the watcher
# reads have not drifted apart.
mute() {
  HOME="$watch_home" PATH="$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-crash-mute" "$1" "$2" >/dev/null
}

# The summary the toast shows, in the slot the sender's argv gives it.
announced() {
  jq -es --arg name "$1" \
    'any(.[]; .[4] == ("Process crashed: " + $name))' "$NOTIFY_LOG" >/dev/null
}

# Every word the diagnosis would hand the agent, so a crash whose name holds a
# space or a tab is proven to arrive as one argument in the slot it belongs in.
diagnosis_is() { # pid name exe signal
  jq -es --arg pid "$1" --arg name "$2" --arg exe "$3" --arg signal "$4" \
    'any(.[]; .[7:] == ["omarchy-agent-crash", $pid, $name, $exe, $signal])' \
    "$NOTIFY_LOG" >/dev/null
}

reset_entries
crash_entry hyprland /usr/bin/hyprland
run_watch
announced hyprland ||
  fail "a crash nobody muted still announces itself"
pass "a crash nobody muted still announces itself"

mute hyprland on
run_watch
! announced hyprland ||
  fail "muting a program stops the crash notifications the diagnosis offered to stop"
pass "muting a program stops its crash notifications"

reset_entries
crash_entry nautilus /usr/bin/nautilus
run_watch
announced nautilus ||
  fail "muting one program silences every other program, which is the global toggle's job and not this one's"
pass "muting one program leaves every other program announcing"

mute hyprland off
reset_entries
crash_entry hyprland /usr/bin/hyprland
run_watch
announced hyprland ||
  fail "un-muting a program brings its crash notifications back"
pass "un-muting a program brings its crash notifications back"

# The diagnosis tells the user to mute the name the toast showed them, so the
# toast has to show the name the watcher checks. COMM is truncated to 15
# characters and the executable's basename is not, and announcing the truncated
# one would leave a dutifully-followed mute matching nothing forever.
reset_entries
crash_entry chromium-browse /usr/lib/chromium/chromium-browser
run_watch
announced chromium-browser ||
  fail "the toast announces a name the mute cannot be keyed on, so following the diagnosis mutes nothing"
pass "the toast announces the name the mute is keyed on"

mute chromium-browser on
run_watch
! announced chromium-browser ||
  fail "the mute is keyed on the name the notification announced, not on the truncated COMM"
pass "muting the announced name silences a program whose COMM was truncated"

# A muted crash must not end the watcher. Restart=always would paper over it
# with a five-second gap, and inotify never replays the crashes it missed while
# it was away.
reset_entries
crash_entry chromium-browse /usr/lib/chromium/chromium-browser
crash_entry nautilus /usr/bin/nautilus
run_watch
announced nautilus ||
  fail "a muted crash stops the watcher reading events, losing every crash after it"
pass "a muted crash does not stop the watcher reading the next one"

# A process can set its own comm to anything prctl takes, slashes included, and
# a crash with no recorded executable falls back to it. A name that climbed out
# of crash-ignore/ would let a crashing program silence itself against an
# unrelated flag -- and have the diagnosis write one there on the user's behalf.
# The fixture carries two slashes so that dropping only the first is not mistaken
# for dropping all of them.
reset_entries
crash_entry a/../bar-off -
sibling_flag="$watch_home/.local/state/omarchy/toggles/bar-off"
touch "$sibling_flag"
run_watch
announced bar-off ||
  fail "a comm that climbs out of crash-ignore/ reads an unrelated toggle, letting a crash suppress its own notification"
pass "a comm that climbs out of crash-ignore/ cannot reach an unrelated toggle"
rm -f "$sibling_flag"

# Stripping to the last component does not always leave a component. An empty
# name is no kind of array subscript and no kind of toast, and a dot component
# names a directory the mute would touch and then never match.
for empty_comm in / a/ . ..; do
  reset_entries
  crash_entry "$empty_comm" -
  run_watch
  announced unknown ||
    fail "a comm of '$empty_comm' leaves no usable name, so the toast cannot say what crashed and the mute has nothing to key on"
done
pass "a comm that strips down to nothing or a dot still announces under a name a mute can use"

# An empty comm is not a missing entry. Tab is IFS whitespace, so an empty field
# collapses and every field after it shifts along one -- the pid becomes a path,
# the crash reads as somebody else's, and it is dropped without a word.
reset_entries
crash_entry "" -
crash_entry nautilus /usr/bin/nautilus
run_watch
announced unknown ||
  fail "a crash whose comm is empty is dropped instead of announced, because the empty field shifted every field after it"
announced nautilus ||
  fail "an empty comm derails the next crash event"
pass "an empty comm is announced rather than parsed into the next field"

# Only "." and ".." are special. A leading dot is an ordinary filename, and
# folding those into the fallback would have one program's mute silence another.
for dotted_comm in .hidden ...; do
  reset_entries
  crash_entry "$dotted_comm" -
  run_watch
  announced "$dotted_comm" ||
    fail "'$dotted_comm' is an ordinary name, but it lands in the fallback, so muting it would silence unrelated crashes"
done
pass "a leading dot is an ordinary name rather than a special component"

reset_entries
crash_entry "foo bar" -
run_watch
announced "foo bar" || fail "a space in the original comm splits the name"
mute "foo bar" on
run_watch
! announced "foo bar" || fail "a space-containing name cannot be muted"
mute "foo bar" off
pass "a space-containing comm is announced and muted under its original name"

# And the name it settles on is mutable like any other.
mute unknown on
reset_entries
crash_entry / -
run_watch
! announced unknown ||
  fail "the fallback name cannot be muted, so the one crash most likely to repeat is the one that cannot be silenced"
pass "the fallback name can be muted like any other"
mute unknown off

# What the watcher announces, event by event, with the journal as the only
# source of truth. Each case appends the entries it needs and names the events
# the stubbed inotifywait delivers, so an event without an entry and an entry
# without an event are both expressible.
reset_entries
journal_entry 1001 foo-bar 1001 /usr/bin/foo-bar-real SIGSEGV
journal_entry 1002 other 1002 /usr/bin/other-real SIGABRT
journal_entry 1004 omarchy-agent-foo 1004 /usr/bin/omarchy-agent-foo SIGSEGV
journal_entry 1005 sigonly 1005 "" SIGABRT
journal_entry 1006 "" 1006 "" SIGSEGV
journal_entry 1007 .hidden 1007 "" SIGSEGV
journal_entry 1008 "foo bar" 1008 "" SIGABRT
journal_entry 1009 $'foo\tbar' 1009 "" SIGSEGV
journal_entry 3001 alien 3001 /usr/bin/alien SIGSEGV 424242
journal_entry 5001 slowcore 5001 /usr/bin/slowcore-real SIGABRT
journal_entry 6000 previous 5001 /usr/bin/previous SIGSEGV

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

run_watch "$(events 3001 1004 1002)" OMARCHY_CRASH_DEDUPE_SECONDS=0
(( $(notify_count) == 1 )) ||
  fail "foreign-uid and omarchy-own crashes are skipped" "got: $(notify_count) toasts"
announced other-real ||
  fail "the remaining crash is still announced"
pass "watcher skips other users' and its own crashes"

run_watch "$(events 1001 1002)" OMARCHY_CRASH_IGNORE='foo'
(( $(notify_count) == 1 )) ||
  fail "ignored patterns are not announced" "got: $(notify_count) toasts"
announced other-real ||
  fail "non-ignored crashes are still announced"
pass "watcher honors the ignore pattern"

run_watch "$(events 1001 1001)" OMARCHY_CRASH_DEDUPE_SECONDS=3600
(( $(notify_count) == 1 )) ||
  fail "duplicate events within the dedupe window are announced once" "got: $(notify_count) toasts"
pass "watcher dedupes crash loops per window"

run_watch "$(events 1001 1001)" OMARCHY_CRASH_DEDUPE_SECONDS=0
(( $(notify_count) == 2 )) ||
  fail "a zero dedupe window announces every event" "got: $(notify_count) toasts"
pass "watcher announces again outside the dedupe window"

# An event whose journal entry has not arrived yet: the toast cannot say what
# crashed, and the retries have to end so the next event is still read.
: >"$QUERY_LOG"
run_watch "$(events 9999 1002)" 2>"$TMPDIR/warnings"
(( $(notify_count) == 1 )) || fail "missing metadata stops the next event"
grep -Fq "No crash details for coredump invocation $(events 9999)" "$TMPDIR/warnings" ||
  fail "an event with no journal metadata is dropped silently"
(( $(wc -l <"$QUERY_LOG") == 21 )) || fail "missing metadata retries are not bounded"
pass "watcher logs missing metadata, bounds retries, and processes the next event"

# A PID reused within the same boot: entry 6000 carries the pid of entry 5001,
# and only the invocation the handler emitted may be announced.
printf '0\n' >"$FAIL_COUNT"
: >"$QUERY_LOG"
run_watch "$(events 5001)" OMARCHY_CRASH_IGNORE='previous'
(( $(notify_count) == 1 )) ||
  fail "crash whose journal entry lands late is still announced" "got: $(notify_count) toasts"
diagnosis_is 5001 slowcore-real /usr/bin/slowcore-real SIGABRT ||
  fail "a reused PID selected the previous program instead of the new invocation"
(( $(wc -l <"$QUERY_LOG") == 3 )) || fail "late journal delivery did not retry twice"
pass "watcher waits for the exact invocation despite PID reuse within the same boot"

run_watch "$(events 1006 1002)"
(( $(notify_count) == 2 )) || fail "an empty comm shifts or drops crash fields"
diagnosis_is 1006 unknown unknown SIGSEGV || fail "an empty comm shifts diagnosis fields"
pass "watcher announces an empty comm without shifting fields or dropping the next crash"

run_watch "$(events 1005)"
(( $(notify_count) == 1 )) ||
  fail "a crash with no executable is still announced" "got: $(notify_count) toasts"
diagnosis_is 1005 sigonly unknown SIGABRT ||
  fail "a missing executable does not shift the signal into its place"
pass "watcher keeps the signal when the executable is missing"

run_watch "$(events 1007 1008 1009)"
(( $(notify_count) == 3 )) || fail "original process names are split or lost"
diagnosis_is 1007 .hidden unknown SIGSEGV || fail "a leading dot becomes a filename escape"
diagnosis_is 1008 "foo bar" unknown SIGABRT || fail "a space splits a diagnosis argument"
diagnosis_is 1009 $'foo\tbar' unknown SIGSEGV || fail "a tab splits a diagnosis argument"
pass "watcher preserves original names and argument boundaries without filename decoding"

# An event name that is not an InvocationID is not a journal lookup.
: >"$QUERY_LOG"
run_watch $'../bad\nfoo bar\n'"$(events 1002)"
(( $(notify_count) == 1 && $(wc -l <"$QUERY_LOG") == 1 )) ||
  fail "a malformed event name reaches the journal lookup"
pass "watcher only queries valid InvocationID events"

: >"$QUERY_LOG"
run_watch "$(events 1001)" NO_AGENT=1
[[ ! -s $NOTIFY_LOG && ! -s $QUERY_LOG ]] || fail "a watcher without an agent queries crashes"
pass "watcher skips lookups and notifications until an agent is selected"

# The completion hook itself: its ExecStopPost commands run against a scratch
# directory with real inotify, so the event the watcher listens for is the one a
# coredump would produce. This installs no unit, changes no host state and
# triggers no crash.
dropin="$ROOT/etc/systemd/system/systemd-coredump@.service.d/10-omarchy-crash-events.conf"

if "$ROOT/bin/omarchy-cmd-present" inotifywait; then
  mkdir "$TMPDIR/events"
  inotifywait --timeout 3 -e create --format '%f' "$TMPDIR/events" \
    >"$TMPDIR/event-name" 2>"$TMPDIR/event-log" &
  event_pid=$!
  for attempt in {1..50}; do
    grep -Fq 'Watches established.' "$TMPDIR/event-log" && break
    sleep 0.02
  done
  grep -Fq 'Watches established.' "$TMPDIR/event-log" ||
    fail "the marker test never established its watch"

  while IFS= read -r command; do
    INVOCATION_ID="$(events 1001)" bash -euc \
      "${command//\/run\/omarchy-crash-events/$TMPDIR/events}"
  done < <(sed -n 's/^ExecStopPost=-//p' "$dropin")

  wait "$event_pid" || fail "an ephemeral marker produces no inotify event"
  event_pid=""
  [[ $(cat "$TMPDIR/event-name") == "$(events 1001)" ]] || fail "the event loses its InvocationID"
  [[ ! -e $TMPDIR/events/$(events 1001) ]] || fail "the hook leaves a marker behind"
  pass "the completion hook emits a real inotify event without retaining a marker or a core"
else
  skip "inotifywait not installed; skipping native marker event check"
fi

unit=/usr/lib/systemd/system/systemd-coredump@.service
if "$ROOT/bin/omarchy-cmd-present" systemd-analyze && [[ -r $unit ]]; then
  cp "$unit" "$TMPDIR/"
  mkdir "$TMPDIR/systemd-coredump@.service.d"
  cp "$dropin" "$TMPDIR/systemd-coredump@.service.d/"
  SYSTEMD_UNIT_PATH="$TMPDIR:/usr/lib/systemd/system" \
    systemd-analyze --man=no --generators=no verify "$TMPDIR/systemd-coredump@.service" \
    >"$TMPDIR/unit-check" 2>&1 ||
    fail "the coredump drop-in is invalid" "$(cat "$TMPDIR/unit-check")"
  pass "systemd accepts the completion drop-in with the installed coredump service"
else
  skip "systemd-analyze or coredump unit unavailable; skipping native unit validation"
fi

# What omarchy-crash-mute does on its own. That it agrees with the watcher is
# already covered above, which drives it for every mute it makes.
mute_home="$TMPDIR/mute-home"
mkdir -p "$mute_home"

crash_mute() {
  HOME="$mute_home" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-crash-mute" "$@"
}

mute_flag() {
  [[ $1 == "--" ]] && shift
  printf '%s' "$mute_home/.local/state/omarchy/toggles/crash-ignore/$1"
}

crash_mute | grep -Fq "No programs muted" ||
  fail "an empty mute list prints nothing, so a user cannot tell it from a broken command"
pass "the command says so when nothing is muted"

crash_mute hyprland >/dev/null
crash_mute | grep -Fqx hyprland ||
  fail "a muted program is missing from the list, so a mute cannot be found again to lift it"
pass "the command lists what it muted"

# The watcher keys on the basename, so the command has to take the path a crash
# recorded and land on the same flag the watcher will look for.
crash_mute /usr/lib/chromium/chromium-browser >/dev/null
[[ -f $(mute_flag chromium-browser) ]] ||
  fail "a binary's path is muted verbatim rather than by name, so the watcher never sees that flag"
pass "the command reduces a path to the name the watcher checks"

crash_mute hyprland off >/dev/null
[[ ! -f $(mute_flag hyprland) ]] ||
  fail "off leaves the program muted, making the mute a one-way door"
pass "the command un-mutes"

# Muting is not flipping. The diagnosis offers this on a program the user may
# already have muted, and asking for a mute twice has to leave it muted.
crash_mute hyprland >/dev/null
crash_mute hyprland >/dev/null
[[ -f $(mute_flag hyprland) ]] ||
  fail "muting an already-muted program un-mutes it, so offering the mute a second time turns it back on"
pass "asking to mute twice leaves it muted"

# A program may legitimately be called .hidden, and a mute nobody can see is a
# mute nobody can lift.
crash_mute .hidden >/dev/null
crash_mute | grep -Fqx .hidden ||
  fail "a mute on a dotted name is missing from the list, so it can never be found and lifted"
pass "the list shows a name that begins with a dot"

# It turns what it is given into a path, so it has to refuse whatever is not one
# component of one.
for bad_name in . .. /; do
  ! crash_mute "$bad_name" >/dev/null 2>&1 ||
    fail "'$bad_name' is taken as a program name, and the flag that writes is not one the watcher will ever read"
done
pass "the command refuses a name that is not a name"

! crash_mute hyprland sideways >/dev/null 2>&1 ||
  fail "an action it does not know is treated as a mute, so a typo silences a program"
pass "the command refuses an action it does not know"

# And says what it refused, or the user retypes the same thing. Captured rather
# than piped: the command exits non-zero here, which pipefail would surface as
# the pipeline's status and read as a failed assertion.
refusal=$(crash_mute hyprland sideways 2>&1) || true
grep -Fq "Not an action" <<<"$refusal" ||
  fail "an unknown action is refused without naming it, leaving the user nothing to correct"
pass "the command names the action it refused"

crash_mute ../bar-off >/dev/null
[[ ! -e "$mute_home/.local/state/omarchy/toggles/bar-off" ]] ||
  fail "a name that climbs out writes a sibling toggle, so muting a crash could turn off the bar instead"
pass "the command cannot be talked into writing outside crash-ignore/"

# A program may be called -h, and the router answers that with its own help
# before the command runs. A leading -- is the way through, so it has to be
# consumed rather than taken for the program name.
crash_mute -- -h >/dev/null 2>&1 ||
  fail "a leading -- is refused rather than consumed, so a program named like a flag cannot be muted at all"
[[ -f $(mute_flag -- -h) ]] ||
  fail "a leading -- is taken for the program name, so muting -h mutes something else"
pass "a leading -- lets a program named like a flag be muted"

# toggle is advertised, so it has to flip both ways rather than quietly mute.
crash_mute toggler off >/dev/null
crash_mute toggler toggle >/dev/null
[[ -f $(mute_flag toggler) ]] ||
  fail "toggle does not mute an un-muted program"
crash_mute toggler toggle >/dev/null
[[ ! -f $(mute_flag toggler) ]] ||
  fail "toggle mutes but never un-mutes, so the advertised action only goes one way"
pass "toggle flips a mute both ways"

# The listing means what the watcher means, and the watcher honours a regular
# file. Anything else in there is not a mute, however much it looks like one.
mkdir -p "$(mute_flag notactuallymuted)"
! crash_mute | grep -Fqx notactuallymuted ||
  fail "a directory is reported as muted while that program's crashes keep arriving"
pass "the listing counts only the flags the watcher honours"
rmdir "$(mute_flag notactuallymuted)"

# A mute that could not be written must not be reported as one. Without this the
# command can print success for a flag that was never created.
failing_bin="$TMPDIR/failing-bin"
mkdir -p "$failing_bin"
cat >"$failing_bin/omarchy-toggle" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$failing_bin/omarchy-toggle"

status=0
refusal=$(HOME="$mute_home" PATH="$failing_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-crash-mute" hyprland 2>&1) || status=$?
(( status != 0 )) ||
  fail "a mute that could not be written exits zero, so nothing downstream learns it failed"
! grep -Fq "Muted crash notifications" <<<"$refusal" ||
  fail "a mute that could not be written still reports success, so the user believes a program is silenced when it is not"
pass "a mute that could not be written is not reported as one"
