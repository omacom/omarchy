#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

migration="$ROOT/migrations/1790092800.sh"

run_migration() {
  OMARCHY_LEGACY_DIAGNOSTICS_TMP="$test_dir" bash -euo pipefail "$migration" >"$test_dir/output" 2>&1
}

printf 'debug\n' >"$test_dir/omarchy-debug.log"
printf 'upload\n' >"$test_dir/upload-log.txt"
printf 'info\n' >"$test_dir/system-info.txt"
printf 'keep\n' >"$test_dir/unrelated.txt"

run_migration
[[ ! -e $test_dir/omarchy-debug.log ]] || fail "migration removes the owned debug log"
[[ ! -e $test_dir/upload-log.txt ]] || fail "migration removes the owned upload log"
[[ ! -e $test_dir/system-info.txt ]] || fail "migration removes the owned system info"
[[ $(cat "$test_dir/unrelated.txt") == keep ]] || fail "migration leaves unrelated files in the same directory"
pass "migration removes owned leftover diagnostics files"

run_migration
pass "migration can be rerun when the leftovers are already gone"

secret="$test_dir/real-secret"
printf 'secret\n' >"$secret"
ln -s "$secret" "$test_dir/omarchy-debug.log"
ln -s "$secret" "$test_dir/upload-log.txt"
ln -s "$secret" "$test_dir/system-info.txt"
run_migration
[[ -L $test_dir/omarchy-debug.log && -L $test_dir/upload-log.txt && -L $test_dir/system-info.txt ]] ||
  fail "migration leaves symlinks at the legacy names"
[[ $(cat "$secret") == secret ]] ||
  fail "migration does not follow a symlink into its target" "target: $(cat "$secret")"
pass "migration leaves symlinks and their targets alone"

rm -f "$test_dir/omarchy-debug.log" "$test_dir/upload-log.txt" "$test_dir/system-info.txt"
mkdir "$test_dir/omarchy-debug.log"
printf 'inside\n' >"$test_dir/omarchy-debug.log/keep"
run_migration
[[ -d $test_dir/omarchy-debug.log && $(cat "$test_dir/omarchy-debug.log/keep") == inside ]] ||
  fail "migration leaves a directory at the legacy name"
pass "migration leaves a directory at the legacy name"

if printf 'other\n' >"$test_dir/upload-log.txt" && chown nobody "$test_dir/upload-log.txt" 2>/dev/null; then
  run_migration
  [[ -f $test_dir/upload-log.txt ]] || fail "migration leaves a file owned by someone else"
  pass "migration leaves a file owned by someone else"
else
  skip "migration leaves a file owned by someone else"
fi
