#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/fns/tmux"

test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT

mkdir -p "$test_dir/first project's files" "$test_dir/second project"
log="$test_dir/tmux.log"

# Every split answers with one fixed pane id, and whatever send-keys would type
# into a pane lands in the log. tdl passes the text and C-m in one call while
# tds types with -l and sends C-m on its own, so strip options and Enter rather
# than trusting a position.
tmux() {
  local -a keys=()

  case $1 in
    split-window | new-window)
      if [[ $* == *" -P "* ]]; then
        echo "new-pane"
      fi
      ;;
    send-keys)
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

export TMUX="fake-tmux"
export TMUX_PANE="current-pane"
export EDITOR="nvim"

cd "$test_dir"

tdl
mapfile -t commands <"$log"

[[ ${commands[0]} == "omarchy-agent --inline" ]] || fail "tdl without an agent runs the default agent"
pass "tdl without an agent runs the default agent"

[[ ${commands[1]} == "nvim ." ]] || fail "tdl opens the editor"
pass "tdl opens the editor"

: >"$log"
tdl "codex --quiet"
mapfile -t commands <"$log"

[[ ${commands[0]} == "codex --quiet" ]] || fail "tdl with an agent runs that agent"
pass "tdl with an agent runs that agent"

: >"$log"
tds
mapfile -t commands <"$log"

[[ ${commands[2]} == "omarchy-agent --inline" ]] || fail "tds without an agent runs the default agent"
pass "tds without an agent runs the default agent"

: >"$log"
tds "codex --quiet"
mapfile -t commands <"$log"

[[ ${commands[2]} == "codex --quiet" ]] || fail "tds with an agent runs that agent"
pass "tds with an agent runs that agent"

: >"$log"
tdlm
mapfile -t commands <"$log"
expected_first=$(printf 'cd %q && tdl' "$test_dir/first project's files")

[[ ${commands[0]} == "$expected_first" ]] || fail "tdlm without agents queues a bare tdl"
pass "tdlm without agents queues a bare tdl"

[[ ${commands[1]} == "tdl" ]] || fail "tdlm without agents queues a bare tdl per extra subdirectory"
pass "tdlm without agents queues a bare tdl per extra subdirectory"

: >"$log"
tdlm "codex --flag='value with spaces'" "claude --model sonnet"
mapfile -t commands <"$log"
expected_first=$(printf 'cd %q && tdl %q %q' \
  "$test_dir/first project's files" "codex --flag='value with spaces'" "claude --model sonnet")
expected_second=$(printf 'tdl %q %q' "codex --flag='value with spaces'" "claude --model sonnet")

[[ ${commands[0]} == "$expected_first" ]] || fail "tdlm safely quotes its first queued command"
pass "tdlm safely quotes its first queued command"

[[ ${commands[1]} == "$expected_second" ]] || fail "tdlm preserves agent argument boundaries"
pass "tdlm preserves agent argument boundaries"
