#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
rm "$SUDO_TEST_ROOT/bin/omarchy-migrate"
copy_boundary_file bin/omarchy-migrate
copy_boundary_file bin/omarchy-pkg-add
printf '%s\n' '#!/bin/bash' 'exit 0' >"$SUDO_TEST_ROOT/mock/omarchy-pkg-missing"
chmod +x "$SUDO_TEST_ROOT/mock/omarchy-pkg-missing"
export OMARCHY_MIGRATION_STATE="$boundary_tmp/state"
mkdir -p "$SUDO_TEST_ROOT/migrations"

cat >"$SUDO_TEST_ROOT/migrations/100-first.sh" <<'MIGRATION'
[[ $OMARCHY_SUDO_NO_UPDATE == "1" ]]
[[ $(command -v sudo) == "$OMARCHY_PATH/default/omarchy/sudo-no-update/sudo" ]]
sudo /usr/bin/true
# The package helper resets PATH and invokes its fixed sudo path.
"$OMARCHY_PATH/bin/omarchy-pkg-add" fixture-package
printf '%s\n' migration:first >>"$SUDO_TEST_LOG"
MIGRATION
cat >"$SUDO_TEST_ROOT/migrations/200-second.sh" <<'MIGRATION'
printf '%s\n' migration:second >>"$SUDO_TEST_LOG"
MIGRATION

run_migrate() {
  "$SUDO_TEST_ROOT/bin/omarchy-migrate" "$@" >"$boundary_tmp/output" 2>&1
}

run_migrate --pending
[[ ! -s $SUDO_TEST_LOG && ! -d $OMARCHY_MIGRATION_STATE ]] || fail "pending inspection changed credentials or migration state"
grep -qx '100-first.sh' "$boundary_tmp/output" || fail "pending inspection omitted a migration"
pass "pending inspection reads migration names without credential or state changes"

touch "$SUDO_TEST_CACHE"
run_migrate || fail "migration queue failed" "$(<"$boundary_tmp/output")"
assert_boundary_cold "successful migration queue"
[[ -f $OMARCHY_MIGRATION_STATE/100-first.sh && -f $OMARCHY_MIGRATION_STATE/200-second.sh ]] || fail "successful migrations were not marked complete"
[[ $(grep '^migration:' "$SUDO_TEST_LOG") == $'migration:first\nmigration:second' ]] || fail "migration ordering changed"
expected_authorizations=2
(( EUID != 0 )) || expected_authorizations=1
[[ $(grep -c '^sudo -N ' "$SUDO_TEST_LOG") == "$expected_authorizations" ]] || fail "the direct package helper did not inherit no-update policy"
pass "ordered migrations and the fixed-path package helper use command-scoped sudo"

reset_boundary
run_migrate
if grep -q '^migration:' "$SUDO_TEST_LOG"; then fail "completed migrations ran again"; fi
if run_migrate --pending; then fail "completed queue reported pending work"; fi
pass "completed migrations remain idempotent"

for failure in exit TERM HUP INT; do
  reset_boundary
  export SUDO_TEST_MIGRATION_FAILURE=$failure
  cat >"$SUDO_TEST_ROOT/migrations/300-fail.sh" <<'MIGRATION'
touch "$SUDO_TEST_CACHE"
if [[ $SUDO_TEST_MIGRATION_FAILURE == "exit" ]]; then
  exit 23
else
  kill -"$SUDO_TEST_MIGRATION_FAILURE" "$PPID"
fi
MIGRATION
  cat >"$SUDO_TEST_ROOT/migrations/400-later.sh" <<'MIGRATION'
printf '%s\n' migration:later >>"$SUDO_TEST_LOG"
MIGRATION
  if run_migrate; then fail "$failure must fail the migration queue"; fi
  assert_boundary_cold "migration $failure"
  [[ ! -e $OMARCHY_MIGRATION_STATE/300-fail.sh && ! -e $OMARCHY_MIGRATION_STATE/400-later.sh ]] || fail "an interrupted queue advanced its completion markers"
  if grep -q '^migration:later' "$SUDO_TEST_LOG"; then fail "later migration ran after $failure"; fi
  pass "migration $failure revokes authorization and leaves the queue pending"
done

printf '%s\n' 'printf "%s\n" migration:retry >>"$SUDO_TEST_LOG"' >"$SUDO_TEST_ROOT/migrations/300-fail.sh"
reset_boundary
run_migrate
[[ -f $OMARCHY_MIGRATION_STATE/300-fail.sh && -f $OMARCHY_MIGRATION_STATE/400-later.sh ]] || fail "retry did not complete the pending queue"
pass "a corrected migration can be retried and releases later work"

reset_boundary
export SUDO_TEST_REVOKE_FAIL=1
if run_migrate; then fail "failed revocation must fail the queue"; fi
if grep -q '^migration:' "$SUDO_TEST_LOG"; then fail "queue ran after failed initial revocation"; fi
pass "failed credential revocation prevents migration execution"

reset_boundary
printf '%s\n' 'touch "$SUDO_TEST_ROOT/startup-marker"' >"$boundary_tmp/startup"
BASH_ENV="$boundary_tmp/startup" ENV="$boundary_tmp/startup" run_migrate
[[ ! -e $SUDO_TEST_ROOT/startup-marker ]] || fail "inherited startup state ran in the migration queue"
pass "migration startup and child interpreters discard inherited startup files"

for script in omarchy-migrate omarchy-pkg-add; do
  reset_boundary
  if /usr/bin/bash "$SUDO_TEST_ROOT/bin/$script" -p >"$boundary_tmp/output" 2>&1; then fail "$script accepted a decoy -p"; fi
  [[ ! -s $SUDO_TEST_LOG ]] || fail "$script reached sudo through an unsafe interpreter"
  pass "$script rejects an ordinary Bash launch"
done

reset_boundary
cat >"$SUDO_TEST_ROOT/migrations/500-revocation.sh" <<'MIGRATION'
touch "$SUDO_TEST_CACHE" "$SUDO_TEST_ROOT/revoke-fail"
MIGRATION
if run_migrate; then fail "failed post-migration revocation must fail the queue"; fi
[[ ! -e $OMARCHY_MIGRATION_STATE/500-revocation.sh ]] || fail "failed revocation incorrectly marked migration complete"
grep -q 'Could not invalidate cached sudo authorization' "$boundary_tmp/output" || fail "failed cleanup did not explain the remaining credential state"
pass "failed post-migration revocation is explicit and prevents a completion marker"
reset_boundary
printf '%s\n' true >"$SUDO_TEST_ROOT/migrations/500-revocation.sh"
run_migrate
assert_boundary_cold "retry after revocation failure"
[[ -f $OMARCHY_MIGRATION_STATE/500-revocation.sh ]] || fail "queue did not recover after revocation was restored"
pass "the queue recovers once credential revocation succeeds"
