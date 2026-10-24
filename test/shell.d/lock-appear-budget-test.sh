#!/bin/bash

# Lock screen appearing: how long from asking for the lock UI until the
# compositor maps it. Timed on the lock preview surface, which renders
# the same LockView as the real lock without engaging the session lock
# (a real WlrSessionLock in a test would lock the developer's own
# session and need a password to leave). The real lock-before-suspend
# path is bounded separately by omarchy-system-sleep-lock and its
# sleep-lock test. Fastest of three, scaled to machine process speed.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""

# Same leftover discipline as the runtime smoke test: Quickshell leaves
# children behind when it stops, so stop whatever still runs with this
# test's scratch OMARCHY_PATH once the shell is down.
leftover_pids() {
  local environ pid

  [[ -n ${test_root:-} ]] || return 0
  while IFS= read -r environ; do
    pid=${environ#/proc/}
    echo "${pid%/environ}"
  done < <(grep -lzxF -- "OMARCHY_PATH=$test_root" /proc/[0-9]*/environ 2>/dev/null || true)
}

signal_leftovers() {
  local leftovers=()

  mapfile -t leftovers < <(leftover_pids)
  (( ${#leftovers[@]} > 0 )) || return 1
  kill "$1" "${leftovers[@]}" 2>/dev/null || true
}

stop_shell() {
  local alive

  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    alive=1
    for _ in {1..30}; do
      if ! kill -0 "$QS_PID" 2>/dev/null; then
        alive=0
        break
      fi
      sleep 0.1
    done
    (( alive == 0 )) || kill -KILL "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  QS_PID=""
  if signal_leftovers -TERM; then
    for _ in {1..30}; do
      [[ -n $(leftover_pids) ]] || break
      sleep 0.1
    done
    signal_leftovers -KILL || true
  fi
  [[ -n ${test_root:-} ]] && rm -f "$(shell_ipc_socket "$test_root")"
  return 0
}

cleanup() {
  stop_shell
  [[ -n $TMPDIR && -d $TMPDIR ]] && rm -rf "$TMPDIR"
  return 0
}
trap cleanup EXIT

require_compositor "lock appear budget"
require_command jq
command -v quickshell >/dev/null 2>&1 || { skip "quickshell not installed; skipping lock appear budget"; exit 0; }
require_comparable_speed "lock appear budget"

BUDGET_MS=$(( ${OMARCHY_LOCK_APPEAR_BUDGET_MS:-300} * SPEED_PERCENT / 100 ))
REOPEN_BUDGET_MS=$(( ${OMARCHY_LOCK_REAPPEAR_BUDGET_MS:-150} * SPEED_PERCENT / 100 ))

TMPDIR=$(mktemp -d)
test_root="$TMPDIR/omarchy"
test_home="$TMPDIR/home"
stub_bin="$TMPDIR/bin"
log="$TMPDIR/quickshell.log"
mkdir -p "$test_root" "$test_home" "$stub_bin"
# Nobody touches the seat during a run, so without this the scratch
# shell's idle service would eventually screensave/lock the real desktop.
mkdir -p "$test_home/.local/state/omarchy/indicators"
touch "$test_home/.local/state/omarchy/indicators/stay-awake"
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$test_root/config"
ln -s "$ROOT/bin" "$test_root/bin"
ln -s "$ROOT/default" "$test_root/default"

# The scratch shell must not reach the real session: the clipboard plugin
# cleans up stale watchers at startup with a pkill whose pattern also
# matches the session shell's watchers (the idle-spawn test stubs the
# same commands for the same reason).
for name in pkill killall; do
  printf '#!/bin/bash\nexit 1\n' >"$stub_bin/$name"
  chmod +x "$stub_bin/$name"
done
# Nor may it change system state over D-Bus: the battery service applies a
# power profile when UPower reports one.
for name in omarchy-powerprofiles-set powerprofilesctl; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$name"
  chmod +x "$stub_bin/$name"
done
# The shell runs some commands under `bash -lc`, and a login shell resets
# PATH and OMARCHY_PATH from /etc/omarchy.conf, which would put the
# session's checkout and its real commands back ahead of these stubs.
printf '#!/bin/bash\n[[ ${1:-} == "-lc" ]] && shift && set -- -c "$@"\nexec /bin/bash "$@"\n' >"$stub_bin/bash"
chmod +x "$stub_bin/bash"


shell_ipc() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" "$@"
}

shell_ipc_quiet() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" -q "$@"
}

# mapped|absent|unknown: a failed compositor query proves nothing.
lock_state() {
  local layers
  layers=$(hyprctl -j layers 2>/dev/null) || { echo unknown; return; }
  [[ -n $layers ]] || { echo unknown; return; }
  if jq -e --argjson pid "$QS_PID" '
    [.. | objects | select(.namespace? == "omarchy-lock-preview" and .pid == $pid and .w > 0 and .h > 0)] | length > 0
  ' <<<"$layers" >/dev/null 2>&1; then
    echo mapped
  else
    echo absent
  fi
}

wait_lock() { # mapped|absent
  local want="$1"
  for _ in {1..300}; do
    [[ $(lock_state) == "$want" ]] && return 0
    kill -0 "$QS_PID" 2>/dev/null || return 1
    sleep 0.01
  done
  return 1
}

launch_start=$EPOCHREALTIME
OMARCHY_PATH="$test_root" \
HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config" \
XDG_CACHE_HOME="$test_home/.cache" \
XDG_STATE_HOME="$test_home/.local/state" \
PATH="$stub_bin:$ROOT/bin:$PATH" \
  quickshell -p "$test_root/shell" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  # Not the quiet form: -q succeeds even when no shell answers.
  [[ $(shell_ipc shell ping 2>/dev/null || true) == "ok" ]] && break
  kill -0 "$QS_PID" 2>/dev/null || { sed -n '1,120p' "$log" >&2; fail "lock test shell becomes available"; }
  sleep 0.1
done

# The lock handler answers once its service is registered, which is
# after the service's LockView has been built: this first measurement
# includes view construction, the rounds below only show/hide it.
ready=""
ready_ms=""
for _ in {1..80}; do
  if [[ $(shell_ipc lock status 2>/dev/null || true) == '{"locked":'* ]]; then
    ready=1
    end=$EPOCHREALTIME
    ready_ms=$(( (${end/[.,]/} - ${launch_start/[.,]/}) / 1000 ))
    break
  fi
  kill -0 "$QS_PID" 2>/dev/null || break
  sleep 0.1
done
[[ -n $ready ]] || { sed -n '1,120p' "$log" >&2; fail "lock service becomes available"; }
READY_BUDGET_MS=$(( ${OMARCHY_LOCK_READY_BUDGET_MS:-750} * SPEED_PERCENT / 100 ))
(( ready_ms <= READY_BUDGET_MS )) || fail "lock view is built within ${READY_BUDGET_MS}ms of shell start" "Lock service answered after ${ready_ms}ms."
pass "lock view is built within ${READY_BUDGET_MS}ms of shell start (${ready_ms}ms)"

appear_ms() {
  local start end
  start=$EPOCHREALTIME
  [[ $(shell_ipc lock preview) == "ok" ]] || return 1
  wait_lock mapped || return 1
  end=$EPOCHREALTIME
  echo $(( (${end/[.,]/} - ${start/[.,]/}) / 1000 ))
  shell_ipc_quiet lock hidePreview >/dev/null 2>&1 || true
  wait_lock absent || return 1
}

first=""
best=""
for round in 1 2 3; do
  elapsed=$(appear_ms) || { sed -n '1,120p' "$log" >&2; fail "lock preview appears and hides cleanly"; }
  (( round == 1 )) && first=$elapsed
  if (( round > 1 )) && { [[ -z $best ]] || (( elapsed < best )); }; then
    best=$elapsed
  fi
done

# The preview must never have engaged the real session lock.
[[ $(shell_ipc lock status) == '{"locked":false'* ]] || fail "lock preview never engages the session lock"
pass "lock preview never engages the session lock"

(( first <= BUDGET_MS )) || fail "lock screen first appears within ${BUDGET_MS}ms" "First appearance took ${first}ms."
pass "lock screen first appears within ${BUDGET_MS}ms (${first}ms)"
(( best <= REOPEN_BUDGET_MS )) || fail "lock screen reappears within ${REOPEN_BUDGET_MS}ms" "Fastest reappearance took ${best}ms."
pass "lock screen reappears within ${REOPEN_BUDGET_MS}ms (${best}ms)"
