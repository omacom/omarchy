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
# SUDO_BROKEN=1 fails every call. SUDO_FAIL_AFTER=n serves n calls and fails
# from the next one on, which is how sudo behaves when a cached credential
# expires or a command-specific policy denies only the later invocation.
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
if [[ ${SUDO_BROKEN:-0} == 1 ]]; then
  echo "sudo: a password is required" >&2
  exit 1
fi
if [[ -n ${SUDO_FAIL_AFTER:-} ]]; then
  count=$(< "$SUDO_CALL_COUNT")
  count=$(( count + 1 ))
  printf '%s' "$count" > "$SUDO_CALL_COUNT"
  if (( count > SUDO_FAIL_AFTER )); then
    echo "sudo: a password is required" >&2
    exit 1
  fi
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

# The reviewer's case on #12883: sudo succeeds for the `test -f` probe and then
# fails at the read. `sudo grep` cannot express the difference, because grep
# exits 1 for "no lines matched" and sudo exits 1 for a denial, so a read that
# never happened used to look like an empty policy. That retired the migration
# with the global rule still in place.
sudoers_dir="$test_dir/sudoers.d"
mkdir -p "$sudoers_dir"
drop_in="$sudoers_dir/omarchy-dev-path"
printf 'Defaults secure_path="%s/checkout/bin:/usr/local/sbin:/usr/local/bin:/usr/bin"\n' \
  "$test_dir" >"$drop_in"

count_file="$test_dir/sudo-calls"
printf '0' >"$count_file"

run_migration SUDO_FAIL_AFTER=1 SUDO_CALL_COUNT="$count_file" \
  OMARCHY_DEV_SUDOERS_FILE="$drop_in"
(( migration_status != 0 )) ||
  fail "migration exits non-zero when sudo fails at the read, not the probe" \
    "exit $migration_status: $migration_output"
grep -q "Leaving this migration pending" <<<"$migration_output" ||
  fail "migration explains why it stayed pending after a failed read" "$migration_output"
[[ -s $drop_in ]] ||
  fail "migration leaves the unreadable drop-in untouched" "drop-in was modified"
pass "sudo failing at the read leaves the migration pending"
