#!/bin/bash

# Login to a drawn bar, the segment a test can own: from the session
# launching bin/omarchy-launch-shell (what uwsm starts at login) until the
# compositor maps the default bar at a real size. Greetd and the uwsm
# compositor start are not in here -- they need a real boot and belong to
# image/acceptance testing; this guards everything after the compositor
# exists: systemd-cat spawn, launcher supervision, and shell start. Fastest
# of three cold starts, scaled to how fast this machine starts processes.
# It certifies the bar surface mapped at a real size, not a presented frame.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "shell startup budget"
require_comparable_speed "shell startup budget"

BUDGET_MS=$(( ${OMARCHY_BAR_STARTUP_BUDGET_MS:-750} * SPEED_PERCENT / 100 ))

setup_scratch_shell

LAUNCHER_PID=""

# The launcher relaunches its shell; stop it first so nothing returns.
stop_launcher() {
  if [[ -n $LAUNCHER_PID ]] && kill -0 "$LAUNCHER_PID" 2>/dev/null; then
    kill "$LAUNCHER_PID" 2>/dev/null || true
    for _ in {1..20}; do
      kill -0 "$LAUNCHER_PID" 2>/dev/null || break
      sleep 0.1
    done
    kill -KILL "$LAUNCHER_PID" 2>/dev/null || true
  fi
  LAUNCHER_PID=""
  stop_scratch_shell
}

# The shell the launcher starts: found by its scratch config path.
launcher_shell_pid() {
  pgrep -f "quickshell -n -p $SCRATCH_ROOT/shell" | head -1
}

# One cold login: launch, then poll the compositor until the launcher's
# shell has its bar surface mapped at a real size -- the bar drawn, in the
# compositor's own terms. (debugBarGeometry only fills in once every
# widget loader settles, long after the bar is on screen.) Prints elapsed
# milliseconds, or nothing when the bar never appears.
cold_login_ms() {
  local start end elapsed

  reset_scratch_home
  start=$EPOCHREALTIME
  (scratch_exec setsid "$ROOT/bin/omarchy-launch-shell") >"$SCRATCH_LOG" 2>&1 &
  LAUNCHER_PID=$!

  elapsed=""
  for _ in {1..800}; do
    # The launcher relaunches a shell that dies; follow the replacement
    # instead of timing the dead one's bar forever.
    if [[ -n $SCRATCH_PID ]] && ! kill -0 "$SCRATCH_PID" 2>/dev/null; then
      SCRATCH_PID=""
    fi
    [[ -n $SCRATCH_PID ]] || SCRATCH_PID=$(launcher_shell_pid || true)
    if [[ -n $SCRATCH_PID && $(scratch_layer_state omarchy-bar) == "mapped" ]]; then
      end=$EPOCHREALTIME
      elapsed=$(( (${end/[.,]/} - ${start/[.,]/}) / 1000 ))
      break
    fi
    kill -0 "$LAUNCHER_PID" 2>/dev/null || break
    sleep 0.01
  done

  stop_launcher
  printf '%s' "$elapsed"
}

best=""
for _ in 1 2 3; do
  elapsed=$(cold_login_ms)
  if [[ -z $elapsed ]]; then
    sed -n '1,120p' "$SCRATCH_LOG" >&2
    fail "login reaches a drawn default bar through the launcher"
  fi
  if [[ -z $best ]] || (( elapsed < best )); then
    best=$elapsed
  fi
done

(( best <= BUDGET_MS )) || fail "login reaches a drawn bar within ${BUDGET_MS}ms" "Fastest of three cold logins took ${best}ms."
pass "login reaches a drawn bar within ${BUDGET_MS}ms (${best}ms)"
