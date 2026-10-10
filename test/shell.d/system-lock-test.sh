#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in hyprctl pkill timeout omarchy-notification-send; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
SH
done

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
if [[ $* == "lock lock" ]]; then
  echo "${MOCK_LOCK_REPLY-ok}"
  exit "${MOCK_LOCK_EXIT:-0}"
fi
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin"/*

PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock"
mapfile -t shutdown < <(rg '^(pkill|timeout) ' "$call_log")

[[ ${shutdown[0]} == "pkill -x ttfx" ]] ||
  fail "system lock stops ttfx before closing its terminal" "calls: ${shutdown[*]}"
[[ ${shutdown[1]} == "timeout 1s pidwait -x ttfx" ]] ||
  fail "system lock waits for ttfx to exit" "calls: ${shutdown[*]}"
[[ ${shutdown[2]} == "pkill -f [o]rg.omarchy.screensaver" ]] ||
  fail "system lock closes the screensaver terminal after ttfx exits" "calls: ${shutdown[*]}"
pass "system lock waits for ttfx before closing its terminal"

# Verify missing-pam failure
: >"$call_log"
stderr_log="$tmpdir/stderr"
if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" MOCK_LOCK_REPLY=missing-pam \
  "$ROOT/bin/omarchy-system-lock" 2>"$stderr_log"; then
  fail "system lock should fail when lock service reports missing-pam"
fi
grep -Fq "omarchy-apply-lock" "$stderr_log" ||
  fail "system lock stderr mentions omarchy-apply-lock on missing-pam"
grep -Fq "omarchy-notification-send -u critical -g 󰌾 Session Unsecured Lock screen password PAM service is missing" "$call_log" ||
  fail "system lock notifies when PAM service is missing"
! grep -Fq "pkill -x ttfx" "$call_log" ||
  fail "system lock does not proceed with shutdown on missing-pam"
pass "system lock fails and notifies when PAM service is missing"

# Verify failed refusal
: >"$call_log"
: >"$stderr_log"
if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" MOCK_LOCK_REPLY=failed \
  "$ROOT/bin/omarchy-system-lock" 2>"$stderr_log"; then
  fail "system lock should fail when lock service reports failed"
fi
grep -Fq "omarchy-notification-send -u critical -g 󰌾 Session Unsecured Lock service refused" "$call_log" ||
  fail "system lock notifies when lock service reports failed"
pass "system lock fails and notifies when lock service reports failed"

# Verify shell communication failure
: >"$call_log"
: >"$stderr_log"
if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" MOCK_LOCK_EXIT=1 \
  "$ROOT/bin/omarchy-system-lock" 2>"$stderr_log"; then
  fail "system lock should fail when shell IPC exits non-zero"
fi
grep -Fq "omarchy-notification-send -u critical -g 󰌾 Session Unsecured Failed to contact lock service" "$call_log" ||
  fail "system lock notifies when shell IPC fails"
pass "system lock fails and notifies when shell IPC fails"

# Verify unexpected response
: >"$call_log"
: >"$stderr_log"
if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" MOCK_LOCK_REPLY=unknown-status \
  "$ROOT/bin/omarchy-system-lock" 2>"$stderr_log"; then
  fail "system lock should fail on unknown response"
fi
grep -Fq "Unexpected response from lock service: unknown-status" "$call_log" ||
  fail "system lock notifies on unknown response"
! grep -Fq "pkill -x ttfx" "$call_log" ||
  fail "system lock skips post-lock commands on unknown response"
pass "system lock fails and notifies on unknown response"

# Verify empty response
: >"$call_log"
: >"$stderr_log"
if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" MOCK_LOCK_REPLY="" \
  "$ROOT/bin/omarchy-system-lock" 2>"$stderr_log"; then
  fail "system lock should fail on empty response"
fi
grep -Fq "Unexpected response from lock service: empty response" "$call_log" ||
  fail "system lock notifies on empty response"
! grep -Fq "pkill -x ttfx" "$call_log" ||
  fail "system lock skips post-lock commands on empty response"
pass "system lock fails and notifies on empty response"

# Verify fallback to hyprctl notify when omarchy-notification-send fails
: >"$call_log"
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 1
SH
if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" MOCK_LOCK_REPLY=failed \
  "$ROOT/bin/omarchy-system-lock" 2>/dev/null; then
  fail "system lock should still fail when notification send fails"
fi
grep -Fq "hyprctl notify 3 5000 rgb(ff5555) Session Unsecured: Lock service refused to lock the session." "$call_log" ||
  fail "system lock falls back to hyprctl notify when notification send fails"
pass "system lock falls back to hyprctl notify when notification send fails"
