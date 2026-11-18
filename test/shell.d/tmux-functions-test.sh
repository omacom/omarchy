#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/fns/tmux"

test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT

first_project="$test_dir/first \"project's\" \$HOME \`true\` files"
mkdir -p "$first_project" "$test_dir/second project"
log="$test_dir/tmux.log"
focus_log="$test_dir/focus.log"

# Every split answers with one fixed pane id, whatever send-keys would type into
# a pane lands in the log, and select-pane targets go to a log of their own so
# the focus a layout leaves behind can be asserted.
tmux() {
  case $1 in
    split-window | new-window)
      if [[ $* == *" -P "* ]]; then
        echo "new-pane"
      fi
      ;;
    select-pane)
      printf '%s\n' "${3:-}" >>"$focus_log"
      ;;
    send-keys)
      printf '%s\n' "$4" >>"$log"
      ;;
  esac
}

# Run a queued line the way the pane's shell would, with a tdl that prints where it ran and what it got
run_queued() {
  bash -c 'tdl() { printf "%s\n" "$PWD" "$#" "$@"; }; eval "$1"' _ "$1" 2>&1 || true
}

export TMUX="fake-tmux"
export TMUX_PANE="current-pane"
export EDITOR="nvim"

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

: >"$log"
tdl "codex --quiet"

[[ $(<"$focus_log") == "$TMUX_PANE" ]] || fail "tdl leaves focus on the editor pane" "$(<"$focus_log")"
pass "tdl leaves focus on the editor pane"
