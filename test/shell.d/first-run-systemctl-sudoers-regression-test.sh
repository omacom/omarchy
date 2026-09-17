#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# #5708: older first-run mode planted
#   USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl
# with no argument filter. That writer is gone; migrations/1788025225.sh removes
# leftover generated first-run sudoers. Lock both properties so the grant cannot
# return.

unrestricted=$(
  grep -RInE --exclude-dir=.git \
    'NOPASSWD:[[:space:]]*/usr/bin/systemctl[[:space:]]*$' \
    "$ROOT/install" "$ROOT/bin" 2>/dev/null || true
)
[[ -z $unrestricted ]] ||
  fail "install and bin must not plant unrestricted NOPASSWD systemctl grants" "$unrestricted"
pass "install and bin do not plant unrestricted NOPASSWD systemctl grants"

writers=$(
  grep -RInE --exclude-dir=.git \
    '(tee|cat >|install |printf ).*sudoers\.d/first-run|sudoers\.d/first-run.*>' \
    "$ROOT/install" "$ROOT/bin" 2>/dev/null || true
)
[[ -z $writers ]] ||
  fail "no install/bin path may recreate /etc/sudoers.d/first-run" "$writers"
pass "no install/bin path recreates /etc/sudoers.d/first-run"

migration="$ROOT/migrations/1788025225.sh"
[[ -f $migration ]] || fail "retired installer artifact migration exists"
grep -Fq 'first_run_sudoers_is_generated' "$migration" ||
  fail "migration recognizes generated first-run sudoers"
grep -Fq '"/usr/bin/systemctl"' "$migration" ||
  fail "migration treats unrestricted systemctl as a generated first-run grant"
grep -Fq 'inspect_sudoers_file "$first_run_sudoers"' "$migration" ||
  fail "migration removes generated first-run sudoers"
pass "migration 1788025225 removes leftover unrestricted first-run systemctl grants"

grep -Fq 'NOPASSWD: /usr/bin/systemctl' \
  "$ROOT/test/shell.d/retired-installer-artifacts-migration-test.sh" ||
  fail "retired-installer migration test covers unrestricted systemctl grants"
pass "retired-installer migration test covers unrestricted first-run systemctl grants"
