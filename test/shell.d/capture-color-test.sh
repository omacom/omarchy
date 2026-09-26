#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"

cat >"$TMPDIR/bin/pkill" <<'SH'
#!/bin/bash
printf '%s\n' "pkill $*" >>"$TEST_LOG"
if [[ ${PKILL_RESULT:-1} == 0 ]]; then
  exit 0
fi
exit 1
SH

cat >"$TMPDIR/bin/hyprpicker" <<'SH'
#!/bin/bash
printf '%s\n' "hyprpicker $*" >>"$TEST_LOG"
if [[ ${HYPRPICKER_RESULT:-0} != 0 ]]; then
  exit "$HYPRPICKER_RESULT"
fi
printf '%s' "${HYPRPICKER_OUTPUT-#12ab34}"
SH

cat >"$TMPDIR/bin/wl-paste" <<'SH'
#!/bin/bash
printf '%s\n' 'wl-paste should not be called' >>"$TEST_LOG"
exit 1
SH

cat >"$TMPDIR/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFICATION_LOG"
SH

chmod +x "$TMPDIR/bin"/*

export TEST_LOG="$TMPDIR/commands"
export NOTIFICATION_LOG="$TMPDIR/notifications"
export PATH="$TMPDIR/bin:$ROOT/bin:$PATH"

: >"$TEST_LOG"
: >"$NOTIFICATION_LOG"
PKILL_RESULT=0 omarchy-capture-color
[[ ! -s $NOTIFICATION_LOG ]] || fail "cancelling an existing picker does not notify stale clipboard data"
pass "cancelling an existing picker does not notify stale clipboard data"
! grep -F 'wl-paste should not be called' "$TEST_LOG" >/dev/null || fail "cancellation does not read the clipboard"
grep -F 'pkill hyprpicker' "$TEST_LOG" >/dev/null || fail "cancellation stops an existing picker"
pass "cancellation does not read the clipboard"

: >"$TEST_LOG"
: >"$NOTIFICATION_LOG"
HYPRPICKER_RESULT=1 PKILL_RESULT=1 omarchy-capture-color
[[ ! -s $NOTIFICATION_LOG ]] || fail "an unsuccessful picker does not notify stale clipboard data"
pass "an unsuccessful picker does not notify stale clipboard data"
! grep -F 'wl-paste should not be called' "$TEST_LOG" >/dev/null || fail "an unsuccessful picker does not read the clipboard"

: >"$TEST_LOG"
: >"$NOTIFICATION_LOG"
HYPRPICKER_OUTPUT= PKILL_RESULT=1 omarchy-capture-color
[[ ! -s $NOTIFICATION_LOG ]] || fail "an empty successful picker result does not notify"
pass "an empty successful picker result does not notify"

: >"$TEST_LOG"
: >"$NOTIFICATION_LOG"
PKILL_RESULT=1 omarchy-capture-color
grep -F 'Color copied #12ab34 copied to clipboard' "$NOTIFICATION_LOG" >/dev/null || fail "successful selection notifies the fresh color"
pass "successful selection notifies the fresh color"
grep -F 'hyprpicker --autocopy --no-fancy' "$TEST_LOG" >/dev/null || fail "successful selection uses autocopy and plain output"
! grep -F 'wl-paste should not be called' "$TEST_LOG" >/dev/null || fail "a successful picker does not read the clipboard"

: >"$TEST_LOG"
: >"$NOTIFICATION_LOG"
PKILL_RESULT=1 omarchy-capture-color
grep -F 'Color copied #12ab34 copied to clipboard' "$NOTIFICATION_LOG" >/dev/null || fail "a repeated same-color selection still notifies"
pass "a repeated same-color selection still notifies"
