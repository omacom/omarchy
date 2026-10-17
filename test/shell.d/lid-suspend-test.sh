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
  working2)
    echo '{"result":{"agents":[{"agent":"opencode","agent_status":"done"},{"agent":"claude","agent_status":"working"}]}}'
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
[[ $2 == "start" ]] && exit "${MOCK_START_RC:-0}"
[[ $2 == "is-active" ]] && exit "${MOCK_ACTIVE_RC:-0}"
exit 0
SH

for command in omarchy-notification-send omarchy-system-lock omarchy-hyprland-monitor-clamshell; do
  cat >"$mock_bin/$command" <<SH
#!/bin/bash
echo $command "\$*" >>"\$CALL_LOG"
SH
done

cat >"$mock_bin/omarchy-hw-laptop-closed" <<'SH'
#!/bin/bash
# Lid closed when MOCK_LID_CLOSED=1, open otherwise.
[[ ${MOCK_LID_CLOSED:-0} == 1 ]]
SH

cat >"$mock_bin/omarchy-power-present" <<'SH'
#!/bin/bash
[[ ${MOCK_AC:-1} == 1 ]]
SH

cat >"$mock_bin/omarchy-hw-external-monitors" <<'SH'
#!/bin/bash
# Docked (external monitor connected) when MOCK_DOCKED=1, otherwise undocked.
[[ ${MOCK_DOCKED:-0} == 1 ]]
SH
chmod +x "$mock_bin"/*
export PATH="$mock_bin:$PATH"

inhibit_spawns() {
  grep -c "^systemd-inhibit --what=handle-lid-switch.*--mode=block" "$call_log"
}

# The mock systemd-inhibit logs from a background child, so its line can land
# just after reconcile returns. Poll briefly rather than asserting immediately.
wait_for_spawns() {
  local expected="$1"
  local _i
  for _i in {1..50}; do
    if (( $(inhibit_spawns) == expected )); then
      return 0
    fi
    sleep 0.05
  done
  return 1
}

inhibitor_pid() {
  head -n 1 "$XDG_RUNTIME_DIR/omarchy-lid-guard/inhibit.pid" | cut -d' ' -f1
}

# Manual skip arms the flag, wakes the guard, and confirms the protection.
: >"$call_log"
"$toggle" skip-once
[[ -f $HOME/.local/state/omarchy/toggles/lid-suspend-skip-once ]] ||
  fail "skip-once arms the flag" "flag missing"
grep -q "systemctl --user kill -s USR1 --kill-whom=main omarchy-lid-guard.service" "$call_log" ||
  fail "skip-once wakes the guard" "$(cat "$call_log")"
grep -q "Lid suspend skipped" "$call_log" ||
  fail "skip-once confirms the skip" "$(cat "$call_log")"
pass "skip-once arms the flag, wakes the guard, and notifies"

# A skip with no guard behind it says so instead of confirming protection.
export MOCK_KILL_RC=1 MOCK_START_RC=1
: >"$call_log"
"$toggle" skip-once >/dev/null
grep -q "Lid guard unavailable" "$call_log" ||
  fail "skip-once reports a missing guard" "$(cat "$call_log")"
export MOCK_KILL_RC=0 MOCK_START_RC=0
pass "skip-once reports a missing guard"

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
wait_for_spawns 1 ||
  fail "working agent starts one inhibitor" "$(cat "$call_log")"
first_pid=$(inhibitor_pid)
kill -0 "$first_pid" 2>/dev/null ||
  fail "inhibitor process is alive" "pid $first_pid"
"$guard" reconcile
wait_for_spawns 1 ||
  fail "reconcile reuses a live inhibitor" "$(cat "$call_log")"
pass "working agent holds one lid inhibitor"

# Idle agents release it.
export MOCK_HERDR_STATE=idle
"$guard" reconcile
# SIGTERM delivery is asynchronous; poll briefly before declaring it alive.
for _ in {1..50}; do
  kill -0 "$first_pid" 2>/dev/null || break
  sleep 0.05
done
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
wait_for_spawns 1 ||
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
wait_for_spawns 1 ||
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

# The guard never locks: the Hyprland lid-switch binding runs
# omarchy-system-lid-close on every close, which locks itself.
date -u +%s >"$HOME/.local/state/omarchy/toggles/lid-suspend-skip-once"
echo "open" >"$XDG_RUNTIME_DIR/omarchy-lid-guard/prev-lid"
echo "state:      closed" >"$tmpdir/lid/state"
: >"$call_log"
"$guard" reconcile
grep -q "^omarchy-system-lock" "$call_log" &&
  fail "guard leaves locking to the lid-close binding" "$(cat "$call_log")"
pass "guard leaves locking to the lid-close binding"

# A close that reopens between two polls still consumes the skip: the
# lid-close binding records the close synchronously for the guard.
date -u +%s >"$HOME/.local/state/omarchy/toggles/lid-suspend-skip-once"
echo "open" >"$XDG_RUNTIME_DIR/omarchy-lid-guard/prev-lid"
echo "state:      closed" >"$tmpdir/lid/state"
export MOCK_LID_CLOSED=1
"$ROOT/bin/omarchy-system-lid-close"
[[ $(cat "$XDG_RUNTIME_DIR/omarchy-lid-guard/prev-lid") == "closed" ]] ||
  fail "lid close is recorded for the guard" "$(cat "$XDG_RUNTIME_DIR/omarchy-lid-guard/prev-lid" 2>/dev/null)"
export MOCK_LID_CLOSED=0
echo "state:      open" >"$tmpdir/lid/state"
"$guard" reconcile
[[ ! -f $HOME/.local/state/omarchy/toggles/lid-suspend-skip-once ]] ||
  fail "a close between polls consumes the skip" "flag still present"
pass "a close between polls consumes the skip"

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
wait_for_spawns 1 ||
  fail "AC inhibits for working agents" "$(cat "$call_log")"
grep -q "lid suspend guard" "$call_log" ||
  fail "inhibitor reason is stable" "$(cat "$call_log")"
export MOCK_HERDR_STATE=idle
"$guard" reconcile
pass "AC inhibits for working agents"

# A change in which agents are working keeps the same live inhibitor.
export MOCK_HERDR_STATE=working
: >"$call_log"
"$guard" reconcile
first_pid=$(inhibitor_pid)
kill -0 "$first_pid" 2>/dev/null ||
  fail "working agents hold the lid" "pid $first_pid"
export MOCK_HERDR_STATE=working2
: >"$call_log"
"$guard" reconcile
# A buggy kill-and-restart would log its replacement within milliseconds; give
# it time to act before asserting nothing spawned.
sleep 0.3
(( $(inhibit_spawns) == 0 )) ||
  fail "a changed working set keeps the live inhibitor" "$(cat "$call_log")"
kill -0 "$first_pid" 2>/dev/null ||
  fail "the held inhibitor survives a change in which agents are working" "inhibitor $first_pid was replaced"
pass "the held inhibitor survives a change in which agents are working"
export MOCK_HERDR_STATE=idle
"$guard" reconcile

# Status reports flag and inhibitor state.
status_out=$("$toggle" status)
grep -q "no skip armed" <<<"$status_out" ||
  fail "status reports a consumed skip" "$status_out"
pass "status reports flag state"
