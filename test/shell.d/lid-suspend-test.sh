#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

toggle="$ROOT/bin/omarchy-toggle-lid-suspend"
guard="$ROOT/bin/omarchy-system-lid-guard"
tmpdir=$(mktemp -d)

cleanup() {
  if [[ -f $XDG_RUNTIME_DIR/omarchy-lid-guard/inhibit.pid ]]; then
    kill "$(cut -d' ' -f1 "$XDG_RUNTIME_DIR/omarchy-lid-guard/inhibit.pid")" 2>/dev/null || true
  fi
  if [[ -n ${innocent_pid:-} ]]; then
    kill "$innocent_pid" 2>/dev/null || true
  fi
  rm -rf "$tmpdir"
}
trap cleanup EXIT

export HOME="$tmpdir/home"
export XDG_RUNTIME_DIR="$tmpdir/runtime"
mkdir -p "$HOME" "$XDG_RUNTIME_DIR"
mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"
: >"$call_log"
export CALL_LOG="$call_log"

# Canned lid state the guard reads instead of /proc.
mkdir -p "$tmpdir/lid"
echo "state:      open" >"$tmpdir/lid/state"
export OMARCHY_LID_STATE_GLOB="$tmpdir/lid/state"

# Scenario knobs read by the mocks below.
export MOCK_HERDR_PRESENT=1 MOCK_HERDR_STATE=idle MOCK_KILL_RC=0 MOCK_ACTIVE_RC=0
export MOCK_AC=1

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ $1 == "herdr" && ${MOCK_HERDR_PRESENT:-1} == 1 ]] && exit 1
exit 0
SH

cat >"$mock_bin/herdr" <<'SH'
#!/bin/bash
case "${MOCK_HERDR_STATE:-idle}" in
  working)
    echo '{"result":{"agents":[{"agent":"opencode","agent_status":"working"},{"agent":"claude","agent_status":"idle"}]}}'
    ;;
  idle)
    echo '{"result":{"agents":[{"agent":"opencode","agent_status":"idle"}]}}'
    ;;
  *)
    echo "not json at all"
    exit 1
    ;;
esac
SH

cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash
echo "systemd-inhibit $*" >>"$CALL_LOG"
[[ $1 == "--list" ]] && exit 0
exec sleep 300
SH

cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
echo "systemctl $*" >>"$CALL_LOG"
[[ $2 == "kill" ]] && exit "${MOCK_KILL_RC:-0}"
[[ $2 == "is-active" ]] && exit "${MOCK_ACTIVE_RC:-0}"
exit 0
SH

for command in omarchy-notification-send omarchy-system-lock; do
  cat >"$mock_bin/$command" <<SH
#!/bin/bash
echo $command "\$*" >>"\$CALL_LOG"
SH
done

cat >"$mock_bin/omarchy-power-present" <<'SH'
#!/bin/bash
[[ ${MOCK_AC:-1} == 1 ]]
SH
chmod +x "$mock_bin"/*
export PATH="$mock_bin:$PATH"

inhibit_spawns() {
  grep -c "^systemd-inhibit --what=handle-lid-switch.*--mode=block" "$call_log"
}

inhibitor_pid() {
  head -n 1 "$XDG_RUNTIME_DIR/omarchy-lid-guard/inhibit.pid" | cut -d' ' -f1
}

# Manual skip arms the flag, wakes the guard, and notifies.
: >"$call_log"
"$toggle" skip-once
[[ -f $HOME/.local/state/omarchy/toggles/lid-suspend-skip-once ]] ||
  fail "skip-once arms the flag" "flag missing"
grep -q "systemctl --user kill -s USR1 omarchy-lid-guard.service" "$call_log" ||
  fail "skip-once wakes the guard" "$(cat "$call_log")"
grep -q "omarchy-notification-send" "$call_log" ||
  fail "skip-once notifies" "$(cat "$call_log")"
pass "skip-once arms the flag, wakes the guard, and notifies"

# Toggle flips the armed skip back off.
"$toggle" toggle
[[ ! -f $HOME/.local/state/omarchy/toggles/lid-suspend-skip-once ]] ||
  fail "toggle disarms an armed skip" "flag still present"
pass "toggle disarms an armed skip"

# Toggle arms when nothing is armed.
"$toggle" toggle
[[ -f $HOME/.local/state/omarchy/toggles/lid-suspend-skip-once ]] ||
  fail "toggle arms a disarmed skip" "flag missing"
pass "toggle arms a disarmed skip"

# Allow clears, and a stale flag reads as unset.
"$toggle" allow
[[ ! -f $HOME/.local/state/omarchy/toggles/lid-suspend-skip-once ]] ||
  fail "allow clears the flag" "flag still present"
pass "allow clears the flag"

# A working agent holds the lid inhibitor; a second pass reuses it.
export MOCK_HERDR_STATE=working
: >"$call_log"
"$guard" reconcile
(( $(inhibit_spawns) == 1 )) ||
  fail "working agent starts one inhibitor" "$(cat "$call_log")"
first_pid=$(inhibitor_pid)
kill -0 "$first_pid" 2>/dev/null ||
  fail "inhibitor process is alive" "pid $first_pid"
"$guard" reconcile
(( $(inhibit_spawns) == 1 )) ||
  fail "reconcile reuses a live inhibitor" "$(cat "$call_log")"
pass "working agent holds one lid inhibitor"

# Idle agents release it.
export MOCK_HERDR_STATE=idle
"$guard" reconcile
kill -0 "$first_pid" 2>/dev/null &&
  fail "idle agents release the inhibitor" "pid $first_pid still alive"
[[ ! -f $XDG_RUNTIME_DIR/omarchy-lid-guard/inhibit.pid ]] ||
  fail "idle agents drop the pidfile" "pidfile still present"
pass "idle agents release the inhibitor"

# Missing or broken herdr fails open: suspend as usual, no inhibitor.
export MOCK_HERDR_PRESENT=0
: >"$call_log"
"$guard" reconcile
(( $(inhibit_spawns) == 0 )) ||
  fail "missing herdr fails open" "$(cat "$call_log")"
export MOCK_HERDR_PRESENT=1 MOCK_HERDR_STATE=broken
"$guard" reconcile
(( $(inhibit_spawns) == 0 )) ||
  fail "unreadable herdr fails open" "$(cat "$call_log")"
pass "missing or broken herdr fails open"
export MOCK_HERDR_STATE=idle

# A manual skip inhibits even with idle agents.
: >"$call_log"
"$toggle" skip-once >/dev/null
"$guard" reconcile
(( $(inhibit_spawns) == 1 )) ||
  fail "manual skip inhibits with idle agents" "$(cat "$call_log")"
guard_pid=$(inhibitor_pid)
"$toggle" allow >/dev/null
pass "manual skip inhibits with idle agents"

# A stale pidfile never kills an unrelated process.
export MOCK_HERDR_STATE=working
sleep 300 & innocent_pid=$!
printf '%s 0\nstale reason\n' "$innocent_pid" >"$XDG_RUNTIME_DIR/omarchy-lid-guard/inhibit.pid"
kill "$guard_pid" 2>/dev/null || true
: >"$call_log"
"$guard" reconcile
kill -0 "$innocent_pid" 2>/dev/null ||
  fail "stale pidfile does not kill unrelated processes" "innocent pid $innocent_pid died"
(( $(inhibit_spawns) == 1 )) ||
  fail "stale pidfile is replaced" "$(cat "$call_log")"
[[ $(inhibitor_pid) != "$innocent_pid" ]] ||
  fail "stale pidfile is replaced" "pidfile still points at $innocent_pid"
pass "stale pidfile neither kills nor is reused"
kill "$innocent_pid" 2>/dev/null || true
unset innocent_pid
export MOCK_HERDR_STATE=idle
kill "$(inhibitor_pid)" 2>/dev/null || true
rm -f "$XDG_RUNTIME_DIR/omarchy-lid-guard/inhibit.pid"

# An expired skip reads as unset and is cleaned up.
date -u +%s >"$HOME/.local/state/omarchy/toggles/lid-suspend-skip-once"
touch -d "2 hours ago" "$HOME/.local/state/omarchy/toggles/lid-suspend-skip-once"
: >"$call_log"
"$guard" reconcile
[[ ! -f $HOME/.local/state/omarchy/toggles/lid-suspend-skip-once ]] ||
  fail "expired skip is cleaned up" "flag still present"
(( $(inhibit_spawns) == 0 )) ||
  fail "expired skip does not inhibit" "$(cat "$call_log")"
pass "expired skip reads as unset"

# Re-opening the lid consumes the one-shot skip.
date -u +%s >"$HOME/.local/state/omarchy/toggles/lid-suspend-skip-once"
echo "closed" >"$XDG_RUNTIME_DIR/omarchy-lid-guard/prev-lid"
echo "state:      open" >"$tmpdir/lid/state"
"$guard" reconcile
[[ ! -f $HOME/.local/state/omarchy/toggles/lid-suspend-skip-once ]] ||
  fail "lid reopen consumes the skip" "flag still present"
pass "lid reopen consumes the skip"

# Closing the lid while guarded locks the session.
date -u +%s >"$HOME/.local/state/omarchy/toggles/lid-suspend-skip-once"
echo "open" >"$XDG_RUNTIME_DIR/omarchy-lid-guard/prev-lid"
echo "state:      closed" >"$tmpdir/lid/state"
: >"$call_log"
"$guard" reconcile
grep -q "^omarchy-system-lock" "$call_log" ||
  fail "guarded lid close locks" "$(cat "$call_log")"
echo "state:      open" >"$tmpdir/lid/state"
"$guard" reconcile
pass "guarded lid close locks"

# The agent guard engages on AC only: never on battery.
export MOCK_HERDR_STATE=working MOCK_AC=0
: >"$call_log"
"$guard" reconcile
(( $(inhibit_spawns) == 0 )) ||
  fail "battery suspends despite working agents" "$(cat "$call_log")"
pass "battery suspends despite working agents"
export MOCK_AC=1
: >"$call_log"
"$guard" reconcile
(( $(inhibit_spawns) == 1 )) ||
  fail "AC inhibits for working agents" "$(cat "$call_log")"
grep -q "agents working on AC" "$call_log" ||
  fail "inhibitor reason names AC" "$(cat "$call_log")"
export MOCK_HERDR_STATE=idle
"$guard" reconcile
pass "AC inhibits for working agents"

# Status reports flag and inhibitor state.
status_out=$("$toggle" status)
grep -q "no skip armed" <<<"$status_out" ||
  fail "status reports a consumed skip" "$status_out"
pass "status reports flag state"
