#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
pids=()
cleanup() {
  if (( ${#pids[@]} )); then
    kill "${pids[@]}" 2>/dev/null || true
    wait "${pids[@]}" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
}
trap cleanup EXIT

# Use real process names and signal dispositions: the TUI catches SIGUSR2,
# while headless commands would terminate if signalled.
for subcommand in tui serve run; do
  cat >"$test_tmp/$subcommand" <<'SCRIPT'
if [[ ${0##*/} == "tui" ]]; then
  trap 'touch "$1.usr2"; exit 0' USR2
fi
: >"$1.ready"
while :; do sleep 0.05; done
SCRIPT
done

for name in opencode opencode.exe; do
  cp "$(command -v bash)" "$test_tmp/$name"
  for subcommand in tui serve run; do
    "$test_tmp/$name" "$test_tmp/$subcommand" "$test_tmp/$name-$subcommand" "Review this server" >/dev/null 2>&1 &
    pids+=("$!")
  done
done

for name in opencode opencode.exe; do
  for subcommand in tui serve run; do
    for _ in {1..40}; do [[ -f $test_tmp/$name-$subcommand.ready ]] && break; sleep 0.05; done
    [[ -f $test_tmp/$name-$subcommand.ready ]] || fail "$name $subcommand starts"
  done
done

# Keep signals inside this test, including if the command regresses to killall.
test_pid=$$
pgrep() { command pgrep --parent "$test_pid" "$@"; }
killall() { return 1; }
export test_pid
export -f pgrep killall

"$ROOT/bin/omarchy-restart-opencode"

for name in opencode opencode.exe; do
  for _ in {1..40}; do [[ -f $test_tmp/$name-tui.usr2 ]] && break; sleep 0.05; done
  [[ -f $test_tmp/$name-tui.usr2 ]] || fail "theme refresh reaches the $name TUI"
done
for index in 1 2 4 5; do
  kill -0 "${pids[index]}" 2>/dev/null || fail "theme refresh leaves headless process $index alive"
done
pass "theme refresh reaches both OpenCode TUI names and keeps headless commands alive"
