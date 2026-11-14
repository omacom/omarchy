#!/bin/bash

# Launcher open to first frame: how long from summoning the menu until
# the compositor maps its surface at a real size. The menu is keepLoaded,
# so this is the warm open a user gets (first-open-after-start pays the
# plugin scan and is covered by the shell startup guard). Fastest of
# three opens, scaled to how fast this machine starts processes. It
# certifies the menu surface mapped, not content revealed.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "menu open budget"
require_comparable_speed "menu open budget"

BUDGET_MS=$(( ${OMARCHY_MENU_OPEN_BUDGET_MS:-150} * SPEED_PERCENT / 100 ))

setup_scratch_shell
start_scratch_shell
wait_scratch_shell

# Warm up: the first summon pays registration and content build, and
# registration itself is asynchronous, so summon until it lands.
summoned=""
for _ in {1..80}; do
  [[ $(scratch_ipc shell summon omarchy.menu '{"menu":"root"}' 2>/dev/null || true) == "ok" ]] && { summoned=1; break; }
  kill -0 "$SCRATCH_PID" 2>/dev/null || break
  sleep 0.1
done
[[ -n $summoned ]] || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "menu summons in a scratch shell"; }
wait_scratch_layer omarchy-menu mapped || fail "menu maps after warm-up summon"
scratch_ipc_quiet shell hide omarchy.menu >/dev/null 2>&1 || true
wait_scratch_layer omarchy-menu absent || fail "menu hides after warm-up"

open_ms() {
  local payload=${1:-'{"menu":"root"}'} start end
  start=$EPOCHREALTIME
  [[ $(scratch_ipc shell summon omarchy.menu "$payload") == "ok" ]] || return 1
  wait_scratch_layer omarchy-menu mapped || return 1
  end=$EPOCHREALTIME
  echo $(( (${end/[.,]/} - ${start/[.,]/}) / 1000 ))
  scratch_ipc_quiet shell hide omarchy.menu >/dev/null 2>&1 || true
  wait_scratch_layer omarchy-menu absent || return 1
}

fastest_open_ms() {
  local best="" elapsed
  for _ in 1 2 3; do
    elapsed=$(open_ms "$@") || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "menu opens and hides cleanly"; }
    if [[ -z $best ]] || (( elapsed < best )); then
      best=$elapsed
    fi
  done
  echo "$best"
}

best=$(fastest_open_ms)
(( best <= BUDGET_MS )) || fail "menu opens within ${BUDGET_MS}ms" "Fastest of three opens took ${best}ms."
pass "menu opens within ${BUDGET_MS}ms (${best}ms)"

# A select menu as long as the keybindings one, which lists a few hundred
# rows, must open in time that grows with its rows, not with their square:
# filling the list row by row reran the card's height over every row so far
# and took a thousand rows from a few dozen milliseconds to most of a second.
# Two lengths timed in the same run, so the machine's speed cancels out.
select_payload() {
  jq -nc --argjson count "$1" '{mode: "select", prompt: "Pick", options: [range($count) | "Option \(.)"], width: 800, maxHeight: 500}'
}

short=$(fastest_open_ms "$(select_payload 3)")
long=$(fastest_open_ms "$(select_payload 1000)")
(( long <= short * 5 )) ||
  fail "a thousand-row select opens within five times a three-row one" "Three rows took ${short}ms, a thousand took ${long}ms."
pass "a thousand-row select opens within five times a three-row one (${short}ms, ${long}ms)"
