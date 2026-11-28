#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in omarchy-shell hyprctl pkill; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
SH
done
# The lock IPC answers with $LOCK_RESULT.
echo 'echo "${LOCK_RESULT-}"' >>"$mock_bin/omarchy-shell"

# A screensaver that does not exit within its second.
cat >"$mock_bin/timeout" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
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

# --screensaver asks the lock for screensaver mode, and a lock that fails stops
# before the cleanup, so a caller never takes the screensaver for locked.
: >"$call_log"
PATH="$mock_bin:$PATH" CALL_LOG="$call_log" LOCK_RESULT=ok "$ROOT/bin/omarchy-system-lock" --screensaver ||
  fail "system lock --screensaver succeeds when the lock answers ok"
[[ $(head -1 "$call_log") == "omarchy-shell lock screensaver" ]] && rg -q '^hyprctl switchxkblayout' "$call_log" ||
  fail "system lock --screensaver locks in screensaver mode, then cleans up" "$(<"$call_log")"
for result in already-locked failed ""; do
  : >"$call_log"
  if PATH="$mock_bin:$PATH" CALL_LOG="$call_log" LOCK_RESULT=$result "$ROOT/bin/omarchy-system-lock" --screensaver 2>/dev/null; then
    fail "system lock --screensaver reports a lock that answered '$result'"
  fi
  ! rg -q '^hyprctl ' "$call_log" || fail "a failed screensaver lock stops before the cleanup" "$(<"$call_log")"
done
pass "system lock --screensaver locks in screensaver mode and fails without cleanup when the lock does"

# With the screensaver-locked toggle on, the launcher locks in screensaver mode
# instead of starting the native screensaver, and still honors screensaver-off.
home="$tmpdir/home"
mkdir -p "$home/.local/state/omarchy/toggles"
touch "$home/.local/state/omarchy/toggles/screensaver-locked"
launch() {
  : >"$call_log"
  HOME="$home" PATH="$mock_bin:$ROOT/bin:$PATH" CALL_LOG="$call_log" LOCK_RESULT=ok "$ROOT/bin/omarchy-launch-screensaver" "$@"
}
launch && [[ $(head -1 "$call_log") == "omarchy-shell lock screensaver" ]] ||
  fail "screensaver-locked runs the screensaver inside the lock" "$(<"$call_log")"
touch "$home/.local/state/omarchy/toggles/screensaver-off"
! launch && [[ ! -s $call_log ]] || fail "screensaver-off keeps the idle screensaver lock off" "$(<"$call_log")"
launch force && [[ $(head -1 "$call_log") == "omarchy-shell lock screensaver" ]] ||
  fail "force starts the screensaver lock with screensaver-off on" "$(<"$call_log")"
pass "the screensaver-locked toggle sends the launcher through the lock and keeps screensaver-off and force"
