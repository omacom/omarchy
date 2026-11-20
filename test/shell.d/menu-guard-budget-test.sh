#!/bin/bash

# The menu opens on its last guard answers, so however long the guard batch
# takes is how long a row can contradict the state it describes. This runs the
# batch for the shipped menu on this machine, against its real hardware and
# packages, and fails when it gets slow again: as a whole, or because one guard
# has turned expensive. A slow guard alone barely moves the batch, since the
# batch runs its guards side by side, but it holds up every menu evaluation.
#
# menu-guards-test.sh pins down how the batch is built; this catches what it
# can't see, such as a guard calling a command that has become slow.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command node

# The batch keeps its package snapshot in $XDG_RUNTIME_DIR, as the menu does in
# a session. Without one every run lists the package database again, which no
# menu pays, so there is nothing representative to time.
if [[ -z ${XDG_RUNTIME_DIR:-} || ! -d $XDG_RUNTIME_DIR ]]; then
  skip "no XDG_RUNTIME_DIR for the guard batch's package snapshot; skipping menu guard budgets"
  exit 0
fi

require_comparable_speed "menu guard budgets"

# On the reference laptop the batch takes about 50ms and its slowest guard, run
# alone, 30ms. Before the guards ran side by side and the hardware and network
# guards were made cheap, the batch took 380ms, and five guards alone took
# 130-150ms each. The budgets leave several times today's cost and still catch
# either, and grow with how much slower this machine starts processes.
BATCH_BUDGET_MS=$(( ${OMARCHY_MENU_GUARD_BUDGET_MS:-200} * SPEED_PERCENT / 100 ))
GUARD_BUDGET_MS=$(( ${OMARCHY_MENU_SINGLE_GUARD_BUDGET_MS:-100} * SPEED_PERCENT / 100 ))

# Prints the batch for the whole shipped menu, then one batch per guarded row,
# each as a NUL-terminated id and script.
guard_scripts() {
  node -e '
    const path = require("path")
    const fs = require("fs")
    const menu = require(path.join(process.env.ROOT, "shell/plugins/menu/MenuModel.js"))
    const shipped = menu.parseMenuJsonc(fs.readFileSync(path.join(process.env.ROOT, "default/omarchy/omarchy-menu.jsonc"), "utf8"))
    const all = {}
    for (const item of shipped) all[item.id] = item
    process.stdout.write(`menu\0${menu.guardScript(all)}\0`)
    for (const item of shipped) {
      const script = menu.guardScript({ [item.id]: item })
      if (script) process.stdout.write(`${item.id}\0${script}\0`)
    }
  '
}

# The menu runs the batch from its own checkout, so the guards call this
# checkout's commands. Prints the fastest of three runs, in milliseconds. A run
# that never returns is cut off at 10s and counts as taking all of it, so a
# stuck guard is named among the slowest instead of hanging the test.
fastest_ms() {
  local best="" start end elapsed status

  for _ in 1 2 3; do
    start=$EPOCHREALTIME
    status=0
    OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" timeout --kill-after=1s 10s bash -c "$1" >"$output" 2>/dev/null || status=$?
    end=$EPOCHREALTIME
    elapsed=$(( (${end/[.,]/} - ${start/[.,]/}) / 1000 ))
    if (( status == 124 || status == 137 )); then
      elapsed=10000
    elif (( status != 0 )); then
      # The menu throws away a batch that fails, so a fast failure is no answer.
      echo "error $status"
      return 0
    fi
    if [[ -z $best ]] || (( elapsed < best )); then
      best=$elapsed
    fi
  done
  echo "$best"
}

output=$(mktemp)
trap 'rm -f "$output"' EXIT

declare -A scripts=()
ids=()
while IFS= read -r -d '' id && IFS= read -r -d '' script; do
  scripts[$id]=$script
  [[ $id == "menu" ]] || ids+=("$id")
done < <(guard_scripts)

[[ -n ${scripts[menu]:-} ]] || fail "the shipped menu has guards to evaluate"
(( ${#ids[@]} > 0 )) || fail "the shipped menu has guarded rows"

batch_ms=$(fastest_ms "${scripts[menu]}")
[[ $batch_ms != error* ]] || fail "the shipped menu's guard batch exits cleanly" "It exited with status ${batch_ms#error }."
(( $(wc -l <"$output") >= ${#ids[@]} )) || fail "the guard batch answers every guarded row" "$(cat "$output")"

timings=()
slowest=0
failed=()
for id in "${ids[@]}"; do
  elapsed=$(fastest_ms "${scripts[$id]}")
  if [[ $elapsed == error* ]]; then
    failed+=("$id (status ${elapsed#error })")
    continue
  fi
  timings+=("$(printf '%6dms  %s' "$elapsed" "$id")")
  (( elapsed > slowest )) && slowest=$elapsed
done

(( ${#failed[@]} == 0 )) || fail "every shipped menu guard evaluates without failing its batch" "$(printf '%s\n' "${failed[@]}")"

slowest_guards() {
  printf 'Slowest guards, each run alone (fastest of three runs):\n'
  printf '%s\n' "${timings[@]}" | sort -rn | head -8
}

(( batch_ms <= BATCH_BUDGET_MS )) ||
  fail "the shipped menu's guard batch runs within ${BATCH_BUDGET_MS}ms" "$(
    printf 'Fastest of three batches took %dms.\n' "$batch_ms"
    slowest_guards
  )"
pass "the shipped menu's guard batch runs within ${BATCH_BUDGET_MS}ms (${batch_ms}ms)"

(( slowest <= GUARD_BUDGET_MS )) ||
  fail "every shipped menu guard runs within ${GUARD_BUDGET_MS}ms alone" "$(slowest_guards)"
pass "every shipped menu guard runs within ${GUARD_BUDGET_MS}ms alone (slowest ${slowest}ms)"
