#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/fns/tmux"

test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT

mkdir -p "$test_dir/first project's files" "$test_dir/second project"
log="$test_dir/tmux.log"

tmux() {
  if [[ $1 == "new-window" ]]; then
    printf 'new-pane\n'
  elif [[ $1 == "send-keys" ]]; then
    printf '%s\n' "$4" >>"$log"
  fi
}

export TMUX="test"
export TMUX_PANE="current-pane"

cd "$test_dir"
tdlm "codex --flag='value with spaces'" "claude --model sonnet"

mapfile -t commands <"$log"

expected_first=$(printf 'cd %q && tdl %q %q' \
  "$test_dir/first project's files" "codex --flag='value with spaces'" "claude --model sonnet")
expected_second=$(printf 'tdl %q %q' "codex --flag='value with spaces'" "claude --model sonnet")

[[ ${commands[0]} == "$expected_first" ]] || fail "tdlm safely quotes its first queued command"
pass "tdlm safely quotes its first queued command"

[[ ${commands[1]} == "$expected_second" ]] || fail "tdlm preserves agent argument boundaries"
pass "tdlm preserves agent argument boundaries"

: >"$log"
tdlm "codex --quiet"
mapfile -t commands <"$log"
expected_first=$(printf 'cd %q && tdl %q' "$test_dir/first project's files" "codex --quiet")

[[ ${commands[0]} == "$expected_first" ]] || fail "tdlm omits an absent second agent argument"
pass "tdlm omits an absent second agent argument"
