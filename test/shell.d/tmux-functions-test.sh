#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/fns/tmux"

test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT

first_project="$test_dir/first \"project's\" \$HOME \`true\` files"
mkdir -p "$first_project" "$test_dir/second project"
log="$test_dir/tmux.log"

tmux() {
  if [[ $1 == "new-window" ]]; then
    echo "new-pane"
  elif [[ $1 == "send-keys" ]]; then
    printf '%s\n' "$4" >>"$log"
  fi
}

# Run a queued line the way the pane's shell would, with a tdl that prints where it ran and what it got
run_queued() {
  bash -c 'tdl() { printf "%s\n" "$PWD" "$#" "$@"; }; eval "$1"' _ "$1" 2>&1 || true
}

export TMUX="fake-tmux"
export TMUX_PANE="current-pane"

cd "$test_dir"
tdlm "codex --flag='value with spaces'" "claude --model sonnet"

mapfile -t commands <"$log"

expected_first=$(printf '%s\n' "$first_project" 2 "codex --flag='value with spaces'" "claude --model sonnet")
expected_second=$(printf '%s\n' "$test_dir" 2 "codex --flag='value with spaces'" "claude --model sonnet")

[[ $(run_queued "${commands[0]}") == "$expected_first" ]] || fail "tdlm runs tdl in a first folder named with quotes, \$ and backticks" "${commands[0]}"
pass "tdlm runs tdl in a first folder named with quotes, \$ and backticks"

[[ $(run_queued "${commands[1]}") == "$expected_second" ]] || fail "tdlm preserves agent argument boundaries" "${commands[1]}"
pass "tdlm preserves agent argument boundaries"

: >"$log"
tdlm "codex --quiet"
mapfile -t commands <"$log"

[[ $(run_queued "${commands[1]}") == "$(printf '%s\n' "$test_dir" 1 "codex --quiet")" ]] || fail "tdlm passes no second agent when none is given" "${commands[1]}"
pass "tdlm passes no second agent when none is given"
