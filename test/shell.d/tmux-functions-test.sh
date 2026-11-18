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
  local -a keys=()

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
      # tdl passes the text and C-m in one call while tds types with -l and sends
      # C-m on its own, so strip options and Enter rather than trusting a position
      shift
      while (($#)); do
        case $1 in
          -t) shift 2 ;;
          -l | C-m) shift ;;
          *) keys+=("$1"); shift ;;
        esac
      done
      if (( ${#keys[@]} )); then
        printf '%s\n' "${keys[*]}" >>"$log"
      fi
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
tdlm
mapfile -t commands <"$log"

[[ $(run_queued "${commands[1]}") == "$(printf '%s\n' "$test_dir" 0)" ]] || fail "tdlm without agents queues a bare tdl" "${commands[1]}"
pass "tdlm without agents queues a bare tdl"

: >"$log"
tdlm "" "claude --model sonnet"
mapfile -t commands <"$log"

[[ $(run_queued "${commands[1]}") == "$(printf '%s\n' "$test_dir" 2 "" "claude --model sonnet")" ]] || fail "tdlm keeps the default agent beside an explicit second agent" "${commands[1]}"
pass "tdlm keeps the default agent beside an explicit second agent"

: >"$log"
tdl "codex --quiet"
mapfile -t commands <"$log"

[[ ${commands[0]} == "codex --quiet" ]] || fail "tdl with an agent runs that agent" "${commands[0]}"
pass "tdl with an agent runs that agent"

[[ $(<"$focus_log") == "$TMUX_PANE" ]] || fail "tdl leaves focus on the editor pane" "$(<"$focus_log")"
pass "tdl leaves focus on the editor pane"

: >"$log"
tdl
mapfile -t commands <"$log"

[[ ${commands[0]} == "omarchy-agent --inline" ]] || fail "tdl without an agent runs the default agent" "${commands[0]}"
pass "tdl without an agent runs the default agent"

[[ ${commands[1]} == "$EDITOR ." ]] || fail "tdl opens the editor" "${commands[1]}"
pass "tdl opens the editor"

: >"$log"
: >"$focus_log"
tds
mapfile -t commands <"$log"

[[ ${commands[2]} == "omarchy-agent --inline" ]] || fail "tds without an agent runs the default agent" "${commands[2]}"
pass "tds without an agent runs the default agent"

[[ $(<"$focus_log") == "$TMUX_PANE" ]] || fail "tds leaves focus on the editor pane" "$(<"$focus_log")"
pass "tds leaves focus on the editor pane"

: >"$log"
tds "codex --quiet"
mapfile -t commands <"$log"

[[ ${commands[2]} == "codex --quiet" ]] || fail "tds with an agent runs that agent" "${commands[2]}"
pass "tds with an agent runs that agent"
