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

# 1Password is running, and there is no session runtime dir. The lock file must
# not be created under /tmp.
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/pgrep"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-cmd-present"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/1password"
chmod +x "$mock_bin/pgrep" "$mock_bin/omarchy-cmd-present" "$mock_bin/1password"
fallback="$tmpdir/fallback"
mkdir -p "$fallback/home"
env -u XDG_RUNTIME_DIR HOME="$fallback/home" XDG_STATE_HOME="$fallback/state" \
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock"
for _ in {1..20}; do
  [[ -e $fallback/state/omarchy/omarchy-1password-lock.lock ]] && break
  sleep 0.05
done
[[ -e $fallback/state/omarchy/omarchy-1password-lock.lock && ! -L $fallback/state/omarchy/omarchy-1password-lock.lock ]] ||
  fail "1password lock is kept in the private state dir"
pass "1password lock stays out of /tmp"

env -u XDG_RUNTIME_DIR HOME="$fallback/home" XDG_STATE_HOME="$fallback/state" \
  "$ROOT/bin/omarchy-update-lock" run true
[[ -e $fallback/state/omarchy/omarchy-update.lock && ! -L $fallback/state/omarchy/omarchy-update.lock ]] ||
  fail "update lock is kept in the private state dir"
pass "update lock stays out of /tmp"

# Failure to create the optional 1Password lock must not skip screen cleanup.
: >"$fallback/blocked-state"
: >"$call_log"
env -u XDG_RUNTIME_DIR HOME="$fallback/home" XDG_STATE_HOME="$fallback/blocked-state" \
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock" 2>"$tmpdir/lock-error"
rg -q '^pkill -f ' "$call_log" || fail "a state-directory error still stops the screensaver"
rg -q 'invisible = false' "$call_log" || fail "a state-directory error still restores the cursor"
pass "1password state errors do not skip screensaver cleanup"
