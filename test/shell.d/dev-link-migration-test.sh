#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1790064412.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# A sudo that can be made to fail the way a missing credential does, so the
# migration's own error handling is what is under test.
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
if [[ ${SUDO_BROKEN:-0} == 1 ]]; then
  echo "sudo: a password is required" >&2
  exit 1
fi
exec "$@"
STUB
chmod +x "$stub_bin"/*

# Runs the migration, returning its output; the caller checks $migration_status.
run_migration() {
  migration_status=0
  migration_output=$(env PATH="$stub_bin:$PATH" "$@" bash -euo pipefail "$migration" 2>&1) ||
    migration_status=$?
}

# The runner records a migration as applied whenever it exits 0. Treating a
# failed privileged inspection as "nothing to do" would therefore retire the
# migration permanently while leaving the global rule in place.
run_migration SUDO_BROKEN=1
out=$migration_output
status=$migration_status
(( status != 0 )) ||
  fail "migration exits non-zero when it cannot inspect the drop-in" "exit $status"
grep -q "Leaving this migration pending" <<<"$out" ||
  fail "migration says why it is leaving itself pending" "$out"
pass "a failed privileged inspection leaves the migration pending"

# With sudo usable and no drop-in present there is genuinely nothing to do, and
# the migration must retire normally rather than failing every update.
run_migration
(( migration_status == 0 )) ||
  fail "migration exits cleanly when the drop-in is genuinely absent" "exit $migration_status: $migration_output"
pass "an absent drop-in is a clean no-op"
