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
  printf '%s\n' "$3" >"$DND_SET_LOG"
  printf '%s\n' "$3"
  exit 0
fi
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
rm -f "$stub/omarchy-toggle-bar"

# The update's token expires during presentation. Presentation owns the
# remaining stay-awake time and must remove it when presentation ends.
export XDG_RUNTIME_DIR="$tmpdir/runtime"
mkdir -p "$XDG_RUNTIME_DIR/omarchy-update-stay-awake" "$home/.local/state/omarchy/indicators"
printf 'update-owner\n' >"$XDG_RUNTIME_DIR/omarchy-update-stay-awake/idle-owner"
printf 'update-owner\n' >"$home/.local/state/omarchy/indicators/stay-awake"
run on >/dev/null
HOME="$home" PATH="$stub:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-stay-awake" stop
[[ -f $home/.local/state/omarchy/indicators/stay-awake ]] || fail "update cleanup keeps presentation awake"
run off >/dev/null
[[ ! -f $home/.local/state/omarchy/indicators/stay-awake ]] || fail "presentation releases expired update ownership"
pass "update cleanup keeps presentation awake and transfers idle restoration"
