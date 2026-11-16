#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Asking a removal for help must not start removing. Each command runs with a
# PATH that holds nothing and a not-found handler that logs, so whatever it would
# have run (omarchy-pkg-drop, sudo, rm) is recorded instead of happening.
empty_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
handler="$test_tmp/not-found.sh"
mkdir -p "$empty_bin"
cat >"$handler" <<'SH'
command_not_found_handle() {
  printf '%s\n' "$*" >>"$TEST_CALLS"
  return 127
}
SH

run_remove() {
  local command="$1"
  shift
  local home="$test_tmp/home"
  rm -rf "$home"
  mkdir -p "$home"
  env -i HOME="$home" PATH="$empty_bin" BASH_ENV="$handler" TEST_CALLS="$calls" \
    "$BASH" "$command" "$@" </dev/null
}

checked=0
for command in "$ROOT"/bin/omarchy-remove-*; do
  name=$(basename "$command")

  # Commands that take what to remove as their argument (a browser, a dev
  # environment) refuse an unknown one before acting, --help included.
  grep -q '^# omarchy:args=' "$command" && continue

  : >"$calls"
  status=0
  output=$(run_remove "$command" --help 2>&1) || status=$?
  (( status == 0 )) || fail "$name --help exits 0" "$output"
  [[ ${output%%$'\n'*} == "Usage: $name" ]] || fail "$name --help prints its usage" "$output"
  [[ ! -s $calls ]] || fail "$name --help runs nothing" "$(<"$calls")"

  : >"$calls"
  status=0
  output=$(run_remove "$command" --bogus 2>&1) || status=$?
  (( status == 2 )) || fail "$name rejects an unknown option" "$output"
  [[ ! -s $calls ]] || fail "$name runs nothing for an unknown option" "$(<"$calls")"

  checked=$(( checked + 1 ))
done

(( checked > 0 )) || fail "found removal commands to check"
pass "every argument-less removal prints usage for --help and refuses unknown options without running anything ($checked commands)"
