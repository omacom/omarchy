#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub="$tmpdir/bin"
mkdir -p "$home" "$stub"

cat >"$stub/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SHELL_LOG"
[[ ${SHELL_DOWN:-0} == "1" ]] && exit 1
if [[ $1 == "-q" ]]; then
  shift
fi
if [[ $1 == "notifications" && $2 == "dndState" ]]; then
  printf '%s\n' "${DND_STATE:-off}"
  exit 0
fi
if [[ $1 == "notifications" && $2 == "setDnd" ]]; then
  [[ ${DND_SET_FAIL:-} == "$3" ]] && exit 1
  printf '%s\n' "$3" >"$DND_SET_LOG"
  printf '%s\n' "$3"
  exit 0
fi
[[ ${BAR_SYNC_FAIL:-0} == "1" && $1 == "omarchy.bar" && $2 == "syncHidden" ]] && exit 1
exit 0
SH
cat >"$stub/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_LOG"
SH
chmod +x "$stub/omarchy-shell" "$stub/omarchy-notification-send"

run() {
  HOME="$home" PATH="$stub:$ROOT/bin:$PATH" \
    SHELL_LOG="$tmpdir/shell.log" DND_SET_LOG="$tmpdir/dnd" NOTIFY_LOG="$tmpdir/notify" \
    DND_STATE="${DND_STATE:-off}" \
    "$ROOT/bin/omarchy-toggle-presentation" "$@"
}

status=$(run on)
[[ $status == "on" ]] || fail "presentation on prints on" "$status"
[[ -f $home/.local/state/omarchy/toggles/presentation ]] ||
  fail "presentation on sets the presentation flag"
[[ -f $home/.local/state/omarchy/toggles/bar-off ]] ||
  fail "presentation on hides the bar"
[[ -f $home/.local/state/omarchy/indicators/stay-awake ]] ||
  fail "presentation on stays awake"
[[ $(<"$tmpdir/dnd") == "on" ]] ||
  fail "presentation on silences notifications" "$(cat "$tmpdir/dnd")"
grep -Fq 'Presentation mode on' "$tmpdir/notify" ||
  fail "presentation on notifies" "$(cat "$tmpdir/notify")"
pass "presentation on hides the bar, silences notifications, and stays awake"

: >"$tmpdir/dnd"
: >"$tmpdir/notify"
status=$(run off)
[[ $status == "off" ]] || fail "presentation off prints off" "$status"
[[ ! -f $home/.local/state/omarchy/toggles/presentation ]] ||
  fail "presentation off clears the presentation flag"
[[ ! -f $home/.local/state/omarchy/toggles/bar-off ]] ||
  fail "presentation off shows the bar again when it was visible"
[[ ! -f $home/.local/state/omarchy/indicators/stay-awake ]] ||
  fail "presentation off allows idle when stay-awake was off"
[[ $(<"$tmpdir/dnd") == "off" ]] ||
  fail "presentation off restores notifications" "$(cat "$tmpdir/dnd")"
pass "presentation off restores the previous bar, dnd, and idle state"

# Inactive `off` is a no-op: it must not undo state owned outside presentation.
mkdir -p "$home/.local/state/omarchy/toggles" "$home/.local/state/omarchy/indicators"
touch "$home/.local/state/omarchy/toggles/bar-off"
touch "$home/.local/state/omarchy/indicators/stay-awake"
DND_STATE=on
: >"$tmpdir/dnd"
run off >/dev/null
run off >/dev/null
[[ -f $home/.local/state/omarchy/toggles/bar-off ]] ||
  fail "inactive presentation off leaves an independently hidden bar"
[[ -f $home/.local/state/omarchy/indicators/stay-awake ]] ||
  fail "inactive presentation off leaves independent stay-awake enabled"
[[ ! -s $tmpdir/dnd ]] ||
  fail "repeated inactive presentation off leaves independent dnd enabled" "$(cat "$tmpdir/dnd")"
pass "inactive presentation off is idempotent and preserves independent state"

# Already presenting: bar hidden, dnd on, stay-awake on — turning presentation
# off must leave those alone.
mkdir -p "$home/.local/state/omarchy/toggles" "$home/.local/state/omarchy/indicators"
touch "$home/.local/state/omarchy/toggles/bar-off"
touch "$home/.local/state/omarchy/indicators/stay-awake"
DND_STATE=on
: >"$tmpdir/dnd"
run on >/dev/null
: >"$tmpdir/dnd"
run off >/dev/null
[[ -f $home/.local/state/omarchy/toggles/bar-off ]] ||
  fail "presentation off leaves a bar that was already hidden"
[[ -f $home/.local/state/omarchy/indicators/stay-awake ]] ||
  fail "presentation off leaves stay-awake that was already on"
[[ ! -s $tmpdir/dnd ]] ||
  fail "presentation off does not clear dnd that was already on" "$(cat "$tmpdir/dnd")"
pass "presentation off does not undo state it did not change"

grep -Fq '"trigger.toggle.presentation"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "presentation mode is on the Toggle menu"
pass "presentation mode is on the Toggle menu"

# A failed query must not invent an initial DND value.
rm -f "$home/.local/state/omarchy/toggles/bar-off" "$home/.local/state/omarchy/indicators/stay-awake"
DND_STATE=off
if SHELL_DOWN=1 run on >/dev/null 2>&1; then
  fail "presentation refuses an unknown notification state"
fi
[[ ! -f $home/.local/state/omarchy/toggles/presentation ]] || fail "unavailable shell leaves presentation inactive"
[[ ! -f $home/.local/state/omarchy/toggles/bar-off ]] || fail "unavailable shell leaves bar unchanged"
pass "presentation refuses an unknown notification state without changing settings"

run on >/dev/null
if SHELL_DOWN=1 run off >/dev/null 2>&1; then
  fail "failed DND restoration reports failure"
fi
[[ -f $home/.local/state/omarchy/toggles/presentation ]] || fail "failed DND restoration remains retryable"
[[ -f $home/.local/state/omarchy/presentation-restore ]] || fail "failed DND restoration retains snapshot"
run off >/dev/null
[[ ! -f $home/.local/state/omarchy/toggles/presentation ]] || fail "retry finishes restoration"
pass "failed DND restoration retains its snapshot until a successful retry"

# A shell may answer the snapshot query, then fail the activation setter.
if DND_SET_FAIL=on run on >"$tmpdir/failed-on" 2>&1; then
  fail "activation reports a failed DND setter"
fi
original_snapshot=$(sed -n '/^bar_off=/p; /^dnd=/p; /^stay_awake=/p' "$home/.local/state/omarchy/presentation-restore")
[[ ! -f $home/.local/state/omarchy/indicators/stay-awake ]] || fail "activation interruption occurs before Stay Awake"
if DND_SET_FAIL=on run on >"$tmpdir/failed-retry" 2>&1; then
  fail "retry cannot claim an interrupted activation succeeded"
fi
run on >/dev/null
[[ -f $home/.local/state/omarchy/indicators/stay-awake ]] || fail "activation retry completes Stay Awake"
[[ $(sed -n '/^bar_off=/p; /^dnd=/p; /^stay_awake=/p' "$home/.local/state/omarchy/presentation-restore") == "$original_snapshot" ]] || fail "activation retry retains original snapshot"
: >"$tmpdir/shell.log"
run on >/dev/null
[[ ! -s $tmpdir/shell.log ]] || fail "completed activation remains idempotent"
run off >/dev/null
[[ ! -f $home/.local/state/omarchy/toggles/bar-off && ! -f $home/.local/state/omarchy/indicators/stay-awake ]] || fail "retried activation restores original settings"
pass "interrupted activation retries finish settings without replacing the original snapshot"

run on >/dev/null
if DND_SET_FAIL=off run off >/dev/null 2>&1; then
  fail "DND-only restore failure reports failure"
fi
[[ -f $home/.local/state/omarchy/toggles/bar-off ]] || fail "failed DND restoration leaves bar restoration pending"
[[ -f $home/.local/state/omarchy/indicators/stay-awake ]] || fail "failed DND restoration leaves idle restoration pending"
run off >/dev/null
pass "DND restoration succeeds before changing bar and idle settings"

# Failure after one restoration must not replay that step on retry.
run on >/dev/null
if BAR_SYNC_FAIL=1 run off >/dev/null 2>&1; then
  fail "bar synchronization failure reports failure"
fi
[[ ! -f $home/.local/state/omarchy/toggles/bar-off ]] || fail "bar was restored before its synchronization failed"
touch "$home/.local/state/omarchy/toggles/bar-off"
: >"$tmpdir/dnd"
run off >/dev/null
[[ -f $home/.local/state/omarchy/toggles/bar-off ]] || fail "retry preserves bar changes made after successful restoration"
[[ ! -s $tmpdir/dnd ]] || fail "retry does not replay successful DND restoration"
rm -f "$home/.local/state/omarchy/toggles/bar-off"
pass "restoration retry skips successful steps and preserves later user choices"

# `on` after a partial `off` must reapply the mode and discard restoration
# progress, while retaining the original values for the next `off`.
run on >/dev/null
if BAR_SYNC_FAIL=1 run off >/dev/null 2>&1; then
  fail "partial restoration reaches retry state"
fi
run on >/dev/null
[[ -f $home/.local/state/omarchy/toggles/bar-off && -f $home/.local/state/omarchy/indicators/stay-awake ]] || fail "on reverses partial restoration"
run off >/dev/null
[[ ! -f $home/.local/state/omarchy/toggles/bar-off && ! -f $home/.local/state/omarchy/indicators/stay-awake ]] || fail "reversed partial restoration still restores original values"
pass "on after partial restoration starts fresh progress with the same snapshot"

# The updater hands its expired idle ownership to presentation by updating
# this existing snapshot key under the shared presentation lock.
touch "$home/.local/state/omarchy/indicators/stay-awake"
if DND_SET_FAIL=on run on >/dev/null 2>&1; then
  fail "idle handover scenario interrupts activation"
fi
sed -i 's/^stay_awake=1$/stay_awake=0/' "$home/.local/state/omarchy/presentation-restore"
run on >/dev/null
run off >/dev/null
[[ ! -f $home/.local/state/omarchy/indicators/stay-awake ]] || fail "activation resume preserves update idle handover"
pass "activation retry preserves the updater's idle handover in the original snapshot"

# Stop the first activation immediately after hiding the bar.
cat >"$stub/omarchy-toggle-bar" <<'SCRIPT'
#!/bin/bash
omarchy-toggle bar-off "$1"
if [[ $1 == "on" ]]; then
  printf '%s\n' "$PPID" >"$TEST_BARRIER"
  for _ in {1..250}; do
    [[ -f $TEST_RELEASE ]] && break
    sleep 0.02
  done
fi
SCRIPT
chmod +x "$stub/omarchy-toggle-bar"
export TEST_BARRIER="$tmpdir/barrier" TEST_RELEASE="$tmpdir/release"
run on >"$tmpdir/first" &
first_pid=$!
for _ in {1..100}; do
  [[ -f $TEST_BARRIER ]] && break
  sleep 0.02
done
[[ -f $TEST_BARRIER ]] || fail "activation reaches interruption barrier"
[[ -f $home/.local/state/omarchy/toggles/presentation ]] || fail "activation is recoverable before settings finish"
run on >"$tmpdir/second" &
second_pid=$!
touch "$TEST_RELEASE"
wait "$first_pid"
wait "$second_pid"
run off >/dev/null
[[ ! -f $home/.local/state/omarchy/toggles/bar-off ]] || fail "overlapping on preserves original visible bar"
pass "overlapping on keeps a single original snapshot"

rm -f "$TEST_BARRIER" "$TEST_RELEASE"
run on >"$tmpdir/interrupted" &
first_pid=$!
for _ in {1..100}; do
  [[ -f $TEST_BARRIER ]] && break
  sleep 0.02
done
# Release the child after terminating its parent so inherited lock fds close.
kill -KILL "$(<"$TEST_BARRIER")"
touch "$TEST_RELEASE"
wait "$first_pid" 2>/dev/null || true
run off >/dev/null
[[ ! -f $home/.local/state/omarchy/toggles/bar-off ]] || fail "interrupted on restores original bar"
pass "interrupted on remains recoverable through off"

rm -f "$TEST_BARRIER" "$TEST_RELEASE"
run on >"$tmpdir/interrupted-retry" &
first_pid=$!
for _ in {1..100}; do
  [[ -f $TEST_BARRIER ]] && break
  sleep 0.02
done
[[ -f $TEST_BARRIER ]] || fail "retry scenario reaches interruption barrier"
kill -KILL "$(<"$TEST_BARRIER")"
touch "$TEST_RELEASE"
wait "$first_pid" 2>/dev/null || true
run on >/dev/null
[[ -f $home/.local/state/omarchy/indicators/stay-awake ]] || fail "on resumes a killed activation"
run off >/dev/null
[[ ! -f $home/.local/state/omarchy/toggles/bar-off ]] || fail "killed activation retry retains original visible bar"
pass "on after process termination resumes activation with the original snapshot"
rm -f "$stub/omarchy-toggle-bar"
