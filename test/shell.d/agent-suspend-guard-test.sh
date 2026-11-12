#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

guard="$ROOT/bin/omarchy-agent-suspend-guard"

if ! command -v script >/dev/null; then
  skip "agent suspend guard needs util-linux script for a pseudo-terminal"
  exit 0
fi

# Runs the guard on a pty, pressing Enter (as a raw-mode CR) once a second, and
# prints what the window would show plus the guard's exit status.
run_guard() {
  local agent=$1
  local presses=$2

  for ((press = 0; press < presses; press++)); do
    sleep 1
    printf '\r'
  done | script -qec "$(printf '%q ' "$guard" sh -c "$agent"); echo \"exit=\$?\"" /dev/null | tr -d '\r'
}

output=$(run_guard 'echo ran; exit 3' 0)
[[ $output == *"ran"* && $output == *"exit=3"* && $output != *"Suspended"* ]] ||
  fail "an agent that never stops runs straight through with its exit status" "$output"
pass "an agent that never stops runs straight through with its exit status"

# Each Ctrl+Z after the first used to close the window: bash breaks out of a
# loop when a foreground job stops inside it.
output=$(run_guard 'kill -TSTP $$; echo one; kill -TSTP $$; echo two; kill -TSTP $$; echo three; exit 7' 3)
[[ $(grep -c "Suspended by Ctrl+Z" <<<"$output") == 3 &&
  $output == *"one"*"two"*"three"* && $output == *"exit=7"* ]] ||
  fail "Enter brings the agent back after every Ctrl+Z" "$output"
pass "Enter brings the agent back after every Ctrl+Z"

# An agent stopped from outside leaves the terminal raw; Enter must still work,
# and the agent must get its raw mode back.
output=$(run_guard 'stty raw -echo; kill -STOP $$; stty -a | grep -o -- -icanon; exit 0' 1)
[[ $output == *"Suspended by Ctrl+Z"* && $output == *"-icanon"* && $output == *"exit=0"* ]] ||
  fail "Enter resumes an agent stopped in raw mode and restores its terminal mode" "$output"
pass "Enter resumes an agent stopped in raw mode and restores its terminal mode"
