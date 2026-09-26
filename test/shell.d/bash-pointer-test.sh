#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command script

# An interactive shell on a terminal asks for the arrow pointer with OSC 22.
# `script` lends the shell a pseudo-terminal so [[ -t 1 ]] holds, the way it
# does in a real terminal window.
osc22=$'\e]22;default\a'

run_shell() {
  local -a env_prefix=("$@")
  env -i HOME="$HOME" PATH="$PATH" TERM=foot OMARCHY_PATH="$ROOT" "${env_prefix[@]}" \
    script -q -c "bash --noprofile --norc -i -c 'source \"\$OMARCHY_PATH/default/bash/shell\"'" /dev/null 2>/dev/null || true
}

output=$(run_shell)
[[ $output == *"$osc22"* ]] || fail "interactive shell on a terminal requests the arrow pointer" "$(printf '%q' "$output")"
pass "interactive shell on a terminal requests the arrow pointer"

output=$(run_shell TMUX=/tmp/tmux-1000/default,1,0)
[[ $output != *"$osc22"* ]] || fail "shell inside tmux leaves the pointer to the outer shell"
pass "shell inside tmux leaves the pointer to the outer shell"

output=$(run_shell TERM=dumb)
[[ $output != *"$osc22"* ]] || fail "dumb terminal gets no pointer sequence"
pass "dumb terminal gets no pointer sequence"

# Without a terminal on stdout (a pipe, a script) nothing is emitted.
output=$(env -i HOME="$HOME" PATH="$PATH" TERM=foot OMARCHY_PATH="$ROOT" \
  bash --noprofile --norc -i -c 'source "$OMARCHY_PATH/default/bash/shell"' 2>/dev/null | cat)
[[ $output != *"$osc22"* ]] || fail "shell with stdout on a pipe gets no pointer sequence"
pass "shell with stdout on a pipe gets no pointer sequence"
