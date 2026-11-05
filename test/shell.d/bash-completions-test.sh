#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# Completes the words given, with the last one being typed, against this
# checkout's commands, and prints the candidates one per line.
complete_words() {
  PATH="$ROOT/bin:$PATH" bash -c '
    source "$1"
    shift
    COMP_WORDS=("$@")
    COMP_CWORD=$(( $# - 1 ))
    _omarchy_complete
    printf "%s\n" "${COMPREPLY[@]}"
  ' bash "$ROOT/default/bash/completions" "$@"
}

# omarchy system has subcommands of its own (lock, sleep, ...) and also takes
# logout, reboot and shutdown as arguments; both kinds are offered.
system=$(complete_words omarchy system "")
for word in lock logout reboot shutdown; do
  grep -qx "$word" <<<"$system" || fail "omarchy system completes $word" "$system"
done
pass "omarchy system completes its arguments beside its subcommands"

# omarchy reboot is an alias route with no binary of its own.
re=$(complete_words omarchy re)
grep -qx reboot <<<"$re" || fail "omarchy re completes the reboot alias" "$re"
grep -qx restart <<<"$re" || fail "omarchy re still completes restart" "$re"
pass "alias routes complete like commands"
