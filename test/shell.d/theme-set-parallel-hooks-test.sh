#!/bin/bash

set -euo pipefail

# Applying a theme runs its post-theme hooks in parallel. One hook failing must
# not abort the theme change -- the rest of the desktop still gets retinted --
# but it must not be reported as a clean run either, or a broken hook stays
# invisible for as long as the user keeps switching themes.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

theme_set="$ROOT/bin/omarchy-theme-set"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Exercise the shipped implementation rather than a copy that can drift from it.
run_parallel_source=$(sed -n '/^run_parallel() {$/,/^}$/p' "$theme_set")
[[ -n $run_parallel_source ]] ||
  fail "run_parallel is defined in bin/omarchy-theme-set"

eval "$run_parallel_source"

stderr_file="$test_tmp/stderr"
status=0

# omarchy-theme-set does not set -e, so a hook's exit status reaches
# run_parallel there without unwinding the script. Match that here, or the
# assertions below test a shell the function never actually runs under.
call_run_parallel() {
  : >"$stderr_file"
  set +e
  run_parallel "$@" 2>"$stderr_file"
  status=$?
  set -e
}

call_run_parallel \
  "touch $test_tmp/first" \
  "exit 3" \
  "touch $test_tmp/last"

(( status == 0 )) ||
  fail "a failing hook does not abort the theme change" "run_parallel exited $status"

[[ -f $test_tmp/first && -f $test_tmp/last ]] ||
  fail "hooks either side of a failing one still run"

grep -q 'exit 3' "$stderr_file" ||
  fail "the failing hook is named on stderr" "stderr: $(<"$stderr_file")"

grep -q 'touch' "$stderr_file" &&
  fail "hooks that succeeded are not named on stderr" "stderr: $(<"$stderr_file")"

# A command that is not on PATH at all is the shape a missing helper takes, and
# it has to be reported the same way as a hook that ran and exited nonzero.
call_run_parallel "omarchy-command-that-does-not-exist"

grep -q 'omarchy-command-that-does-not-exist' "$stderr_file" ||
  fail "an unresolvable hook is named on stderr" "stderr: $(<"$stderr_file")"

call_run_parallel "true" "true"

[[ -s $stderr_file ]] &&
  fail "a run where every hook succeeds stays quiet" "stderr: $(<"$stderr_file")"

pass "run_parallel reports failing theme hooks without aborting the theme change"
