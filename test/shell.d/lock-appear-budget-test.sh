#!/bin/bash

# Lock screen appearing: how long from asking for the lock UI until the
# compositor maps it. Timed on the lock preview surface, which renders
# the same LockView as the real lock without engaging the session lock
# (a real WlrSessionLock in a test would lock the developer's own
# session and need a password to leave). The real lock-before-suspend
# path is bounded separately by omarchy-system-sleep-lock and its
# sleep-lock test. Fastest of three; the appearances are scaled to machine
# process speed, the view build to how fast the shell itself starts.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock appear budget"
require_comparable_speed "lock appear budget"

BUDGET_MS=$(( ${OMARCHY_LOCK_APPEAR_BUDGET_MS:-300} * SPEED_PERCENT / 100 ))
REOPEN_BUDGET_MS=$(( ${OMARCHY_LOCK_REAPPEAR_BUDGET_MS:-150} * SPEED_PERCENT / 100 ))

setup_scratch_shell

appear_ms() {
  local start end
  start=$EPOCHREALTIME
  [[ $(scratch_ipc lock preview) == "ok" ]] || return 1
  wait_scratch_layer omarchy-lock-preview mapped || return 1
  end=$EPOCHREALTIME
  echo $(( (${end/[.,]/} - ${start/[.,]/}) / 1000 ))
  scratch_ipc_quiet lock hidePreview >/dev/null 2>&1 || true
  wait_scratch_layer omarchy-lock-preview absent || return 1
}

# CPU time the scratch shell has used, in clock ticks, its render threads
# included: utime and stime, the 14th and 15th fields of its stat.
scratch_cpu_ticks() {
  local stat fields
  stat=$(</proc/"$SCRATCH_PID"/stat) || return 1
  read -r -a fields <<<"${stat##*) }"
  echo $(( fields[11] + fields[12] ))
}

# The lock service answers while the shell is still drawing its first frames
# of the wallpaper, bar and dock. A GPU draws them in milliseconds; Mesa's
# software renderer takes a second or two, and a lock timed meanwhile waits
# for those frames. Wait until the shell uses at most one tick of CPU in
# 200ms, for at most 10s, so only the lock is timed.
wait_scratch_quiet() {
  local last="" now
  for _ in {0..50}; do
    if ! now=$(scratch_cpu_ticks); then
      sed -n '1,120p' "$SCRATCH_LOG" >&2
      fail "scratch shell keeps running while it settles"
    elif [[ -n $last ]] && (( now - last <= 1 )); then
      return 0
    else
      last=$now
      sleep 0.2
    fi
  done
}

# The view build and the first appearance happen once per shell start, so
# each of their samples is a cold start; the reappearances are timed on the
# last shell.
ready_best=""
answer_best=""
first_best=""
reopen_best=""
for round in 1 2 3; do
  (( round == 1 )) || { stop_scratch_shell; reset_scratch_home; }
  launch_start=$EPOCHREALTIME
  start_scratch_shell
  wait_scratch_shell
  end=$EPOCHREALTIME
  answer_ms=$(( (${end/[.,]/} - ${launch_start/[.,]/}) / 1000 ))
  if [[ -z $answer_best ]] || (( answer_ms < answer_best )); then answer_best=$answer_ms; fi

  # The lock handler answers once its service is registered, which is
  # after the service's LockView has been built: this measurement
  # includes view construction, the reappearances only show/hide it.
  ready_ms=""
  for _ in {1..80}; do
    if [[ $(scratch_ipc lock status 2>/dev/null || true) == '{"locked":'* ]]; then
      end=$EPOCHREALTIME
      ready_ms=$(( (${end/[.,]/} - ${launch_start/[.,]/}) / 1000 ))
      break
    fi
    kill -0 "$SCRATCH_PID" 2>/dev/null || break
    sleep 0.1
  done
  [[ -n $ready_ms ]] || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "lock service becomes available"; }
  if [[ -z $ready_best ]] || (( ready_ms < ready_best )); then ready_best=$ready_ms; fi

  wait_scratch_quiet
  elapsed=$(appear_ms) || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "lock preview appears and hides cleanly"; }
  if [[ -z $first_best ]] || (( elapsed < first_best )); then first_best=$elapsed; fi
done

for _ in 1 2; do
  elapsed=$(appear_ms) || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "lock preview appears and hides cleanly"; }
  if [[ -z $reopen_best ]] || (( elapsed < reopen_best )); then reopen_best=$elapsed; fi
done

# The preview must never have engaged the real session lock.
[[ $(scratch_ipc lock status) == '{"locked":false'* ]] || fail "lock preview never engages the session lock"
pass "lock preview never engages the session lock"

# The view build is budgeted against this machine's own shell start, not its
# process speed: the shell answers once Quickshell has loaded its config, and
# the lock answers once the plugin services are built after that, both QML
# work on the same thread. Process starts do not scale like it: an Intel VM
# starts them a third faster than an AMD one and builds the shell no faster.
READY_BUDGET_MS=$(( answer_best * ${OMARCHY_LOCK_READY_BUDGET_PERCENT:-400} / 100 ))
(( ready_best <= READY_BUDGET_MS )) || fail "lock view is built within ${READY_BUDGET_MS}ms of shell start" "Fastest of three starts answered after ${ready_best}ms; the shell itself answered after ${answer_best}ms."
pass "lock view is built within ${READY_BUDGET_MS}ms of shell start (${ready_best}ms; the shell answered after ${answer_best}ms)"
(( first_best <= BUDGET_MS )) || fail "lock screen first appears within ${BUDGET_MS}ms" "Fastest of three first appearances took ${first_best}ms."
pass "lock screen first appears within ${BUDGET_MS}ms (${first_best}ms)"
(( reopen_best <= REOPEN_BUDGET_MS )) || fail "lock screen reappears within ${REOPEN_BUDGET_MS}ms" "Fastest reappearance took ${reopen_best}ms."
pass "lock screen reappears within ${REOPEN_BUDGET_MS}ms (${reopen_best}ms)"
