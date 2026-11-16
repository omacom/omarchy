#!/bin/bash

# Bar panel first open and reopen: panels build their content lazily on
# first open (#15044), so the first open is the one to watch, and a
# reopen must stay instant because the content survives the close. Each
# panel is timed from its IPC open until the compositor maps its panel
# surface; budgets scale with how fast this machine starts processes.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "panel open budgets"
require_comparable_speed "panel open budgets"

FIRST_BUDGET_MS=$(( ${OMARCHY_PANEL_FIRST_OPEN_BUDGET_MS:-400} * SPEED_PERCENT / 100 ))
REOPEN_BUDGET_MS=$(( ${OMARCHY_PANEL_REOPEN_BUDGET_MS:-150} * SPEED_PERCENT / 100 ))

setup_scratch_shell
start_scratch_shell
wait_scratch_shell

# Registration is asynchronous; wait until the panels answer.
for _ in {1..80}; do
  plugins=$(scratch_ipc shell listPlugins 2>/dev/null || true)
  if jq -e 'map(.id) | contains(["omarchy.audio","omarchy.bluetooth","omarchy.monitor","omarchy.network"])' <<<"$plugins" >/dev/null 2>&1; then
    break
  fi
  kill -0 "$SCRATCH_PID" 2>/dev/null || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "panel test shell registers its panels"; }
  sleep 0.1
done

panels=(omarchy.audio omarchy.bluetooth omarchy.monitor omarchy.network)
# The power panel hides itself without a battery, so it can only be
# timed where one exists.
if "$ROOT/bin/omarchy-battery-present" >/dev/null 2>&1; then
  panels+=(omarchy.power)
else
  skip "panel omarchy.power first open and reopen (no battery)"
fi

# listPlugins reports discovered manifests, not registered IPC handlers:
# widget components load asynchronously, so wait until each panel's own
# handler answers a (harmless, already-closed) close before timing it.
for panel in "${panels[@]}"; do
  ready=""
  for _ in {1..80}; do
    if scratch_ipc "$panel" close >/dev/null 2>&1; then ready=1; break; fi
    kill -0 "$SCRATCH_PID" 2>/dev/null || break
    sleep 0.1
  done
  [[ -n $ready ]] || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "panel $panel IPC handler becomes available"; }
done

open_ms() { # panel-id -> ms on stdout, fails when it never maps
  local id="$1" start end
  start=$EPOCHREALTIME
  scratch_ipc_quiet "$id" open >/dev/null 2>&1 || true
  wait_scratch_layer omarchy-keyboard-panel mapped || return 1
  end=$EPOCHREALTIME
  echo $(( (${end/[.,]/} - ${start/[.,]/}) / 1000 ))
}

close_panel() {
  scratch_ipc_quiet "$1" close >/dev/null 2>&1 || true
  wait_scratch_layer omarchy-keyboard-panel absent || return 1
}

for panel in "${panels[@]}"; do
  first=$(open_ms "$panel") || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "panel $panel first open maps its surface"; }
  close_panel "$panel" || fail "panel $panel closes after first open"
  reopen=""
  for _ in 1 2; do
    elapsed=$(open_ms "$panel") || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "panel $panel reopen maps its surface"; }
    close_panel "$panel" || fail "panel $panel closes after reopen"
    if [[ -z $reopen ]] || (( elapsed < reopen )); then reopen=$elapsed; fi
  done
  (( first <= FIRST_BUDGET_MS )) || fail "panel $panel first open within ${FIRST_BUDGET_MS}ms" "First open took ${first}ms."
  (( reopen <= REOPEN_BUDGET_MS )) || fail "panel $panel reopen within ${REOPEN_BUDGET_MS}ms" "Fastest reopen took ${reopen}ms."
  pass "panel $panel first open ${first}ms, reopen ${reopen}ms"
done
