#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/test/shell.d"
cp "$ROOT/test/"{shell,all} "$test_dir/test/"
cp "$SHELL_TEST_DIR/base-test.sh" "$test_dir/test/shell.d/"

# Run the real runners in a tiny fixture tree, without recursing into this test.
run_suite() {
  status=0
  output=$(bash "$test_dir/test/${1:-shell}" 2>&1) || status=$?
}

run_suite
(( status == 1 )) && [[ $output == *"No shell tests found"* ]] ||
  fail "an empty suite fails instead of counting the helper as a test" "$output"
pass "an empty suite fails instead of counting the helper as a test"

cat >"$test_dir/test/shell.d/a-pass-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
captured=$(skip "captured fixture output is not a skipped check")
pass "the command skips an optional action"
SH
run_suite
(( status == 0 )) && [[ $output == *"All 1 test files passed."* ]] ||
  fail "passing assertions and captured skip output do not mark a file skipped" "$output"
pass "passing assertions and captured skip output do not mark a file skipped"

cat >"$test_dir/test/shell.d/b-partial-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "static check"
skip "first unavailable runtime check"
skip "second unavailable runtime check"
pass "check after skips"
SH
cat >"$test_dir/test/shell.d/c-skipped-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
unset WAYLAND_DISPLAY
require_compositor "runtime fixture"
fail "unreachable after compositor skip"
SH
cat >"$test_dir/test/shell.d/z-last-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "last file ran"
SH
run_suite
(( status == 0 )) && [[ $output == *"4 test files completed without failures; 2 had skipped checks."* ]] ||
  fail "whole and partial skips are counted once per file and remain successful" "$output"
[[ $output == *"ok - check after skips"* && $output == *"ok - last file ran"* ]] ||
  fail "skip returns normally and later files still run" "$output"
[[ $output == *$'Skipped checks in 2 of 4 test files:\n  test/shell.d/b-partial-test.sh\n  test/shell.d/c-skipped-test.sh\n'* ]] ||
  fail "the summary identifies only files with skipped checks" "$output"
pass "whole and partial skips are visible without failing or stopping the suite"

cat >"$test_dir/test/shell.d/d-failed-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
skip "unavailable check before failure"
echo "failure detail" >&2
false
pass "unreachable after failure"
SH
run_suite
(( status == 1 )) && [[ $output == *$'1 of 5 test files failed:\n  test/shell.d/d-failed-test.sh'* ]] ||
  fail "a failure after a skip still fails the suite through the output pipe" "$output"
[[ $output == *"Skipped checks in 3 of 5 test files:"* && $output == *"failure detail"* && $output == *"ok - last file ran"* && $output != *"ok - unreachable after failure"* ]] ||
  fail "failures preserve skip reporting, diagnostics, errexit, and later tests" "$output"
pass "failures remain fatal while skips and later test results stay visible"

printf '#!/bin/bash\necho "CLI fixture passed"\n' >"$test_dir/test/cli"
chmod +x "$test_dir/test/cli"
run_suite all
(( status == 1 )) && [[ $output == *"CLI fixture passed"* && $output == *"Skipped checks in 3 of 5 test files:"* && $output == *$'1 of 2 suites failed:\n  test/shell'* ]] ||
  fail "the aggregate runner preserves shell failures and skip reporting" "$output"
pass "the aggregate runner preserves shell failures and skip reporting"
