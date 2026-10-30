#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in hyprctl pkill omarchy-notification-send; do
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

# A screensaver that does not exit within its second.
cat >"$mock_bin/timeout" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
if [[ $1 == "--kill-after=1s" ]]; then
  shift 2
  "$@"
  exit $?
fi
exit 124
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin"/*

PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock"
mapfile -t shutdown < <(rg '^(pkill|timeout) ' "$call_log")

[[ ${shutdown[0]} == "pkill -f [/]usr/lib/omarchy-screensaver/omarchy-screensaver" ]] ||
  fail "system lock stops the native screensaver" "calls: ${shutdown[*]}"
[[ ${shutdown[1]} == "timeout 1s pidwait -f [/]usr/lib/omarchy-screensaver/omarchy-screensaver" ]] ||
  fail "system lock waits for the native screensaver to clean up" "calls: ${shutdown[*]}"
[[ ${shutdown[2]} == "pkill -KILL -f [/]usr/lib/omarchy-screensaver/omarchy-screensaver" ]] ||
  fail "system lock force-stops a stuck native screensaver" "calls: ${shutdown[*]}"
rg -A1 '^pkill -KILL ' "$call_log" | rg -q 'invisible = false' ||
  fail "system lock shows the cursor a killed screensaver left hidden" "$(<"$call_log")"
pass "system lock gives the screensaver a second to restore the cursor before killing it, then restores it itself"

screensaver='[/]usr/lib/omarchy-screensaver/omarchy-screensaver'

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
! grep -Fq "pkill -f $screensaver" "$call_log" ||
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
! grep -Fq "pkill -f $screensaver" "$call_log" ||
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
! grep -Fq "pkill -f $screensaver" "$call_log" ||
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

# Verify a stalled notification falls back promptly
: >"$call_log"
real_timeout=$(command -v timeout)
cat >"$mock_bin/timeout" <<SH
#!/bin/bash
printf '%s %s\n' "\$(basename "\$0")" "\$*" >>"\$CALL_LOG"
exec "$real_timeout" "\$@"
SH
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exec sleep 30
SH
SECONDS=0
if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" MOCK_LOCK_REPLY=failed \
  "$ROOT/bin/omarchy-system-lock" 2>/dev/null; then
  fail "system lock should still fail when notification send stalls"
fi
(( SECONDS < 10 )) ||
  fail "system lock bounds a stalled notification" "took ${SECONDS}s"
grep -Fq "hyprctl notify 3 5000 rgb(ff5555) Session Unsecured: Lock service refused to lock the session." "$call_log" ||
  fail "system lock falls back to hyprctl notify when notification send stalls"
pass "system lock falls back promptly when notification send stalls"

# 1Password is running: a FIFO lock entry or unsafe XDG_RUNTIME_DIR must not
# hang or skip screensaver cleanup.
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/pgrep"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-cmd-present"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/1password"
chmod +x "$mock_bin/pgrep" "$mock_bin/omarchy-cmd-present" "$mock_bin/1password"

fifo_runtime="$tmpdir/fifo-runtime"
mkdir -m 700 "$fifo_runtime"
mkfifo "$fifo_runtime/omarchy-1password-lock.lock"
: >"$call_log"
# Pipe stdout/stderr through cat inside timeout so any background subshell left
# blocked opening the FIFO holds the pipe open and fails the test (and timeout
# reaps the whole process group).
timeout --kill-after=1s 2s bash -c '
  XDG_RUNTIME_DIR="$1" PATH="$2" CALL_LOG="$3" "$4" 2>&1 | cat >/dev/null
' _ "$fifo_runtime" "$mock_bin:$PATH" "$call_log" "$ROOT/bin/omarchy-system-lock" ||
  fail "system lock leaves no child blocked on a FIFO 1Password lock"
rg -q '^pkill -f ' "$call_log" || fail "FIFO 1Password lock still stops the screensaver"
rg -q 'invisible = false' "$call_log" || fail "FIFO 1Password lock still restores the cursor"
pass "system lock refuses a FIFO 1Password lock without hanging or skipping cleanup"

shared_runtime="$tmpdir/shared-runtime"
mkdir -m 777 "$shared_runtime"
chmod 777 "$shared_runtime"
: >"$call_log"
XDG_RUNTIME_DIR="$shared_runtime" PATH="$mock_bin:$PATH" CALL_LOG="$call_log" \
  "$ROOT/bin/omarchy-system-lock"
[[ ! -e $shared_runtime/omarchy-1password-lock.lock ]] ||
  fail "unsafe runtime directory receives no 1Password lock file"
rg -q '^pkill -f ' "$call_log" || fail "unsafe runtime directory still stops the screensaver"
rg -q 'invisible = false' "$call_log" || fail "unsafe runtime directory still restores the cursor"
pass "system lock ignores an unsafe runtime directory and keeps screensaver cleanup"

# Without XDG_RUNTIME_DIR, the 1Password lock uses the private per-UID /tmp dir.
env -u XDG_RUNTIME_DIR PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock"
fallback_lock="/tmp/omarchy-$EUID/omarchy-1password-lock.lock"
for _ in {1..20}; do
  [[ -f $fallback_lock ]] && break
  sleep 0.05
done
[[ -f $fallback_lock && ! -L $fallback_lock ]] || fail "1Password lock is created in /tmp/omarchy-\$EUID"
[[ $(stat -c %a "/tmp/omarchy-$EUID") == "700" ]] || fail "fallback lock directory is mode 700"
pass "1Password lock uses the private per-UID directory when XDG_RUNTIME_DIR is unset"
