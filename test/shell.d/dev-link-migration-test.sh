#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1790064412.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# A sudo double. SUDO_FAIL_CALLS lists the 1-based call numbers that fail the
# way a denied or unanswered sudo does; every other call runs for real. This
# models a command-specific policy or an expired timestamp that denies only
# some of the migration's several privileged steps. `install` is special-cased
# to copy without the -o root/-g root chown a non-root test cannot perform.
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
count=$(( $(< "${SUDO_CALL_COUNT:?}") + 1 ))
printf '%s' "$count" >"$SUDO_CALL_COUNT"
for n in ${SUDO_FAIL_CALLS:-}; do
  if (( n == count )); then
    echo "sudo: a password is required" >&2
    exit 1
  fi
done
if [[ $1 == install ]]; then
  cp "${@: -2:1}" "${@: -1}"
  exit
fi
exec "$@"
STUB
# A visudo that accepts the staged rule, so the test stays hermetic and does not
# depend on the host having visudo. Syntax is exercised by the real migration in
# production; here the focus is the sudo-failure handling.
cat >"$stub_bin/visudo" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$stub_bin"/*

# Runs the migration; the caller reads $migration_status and $migration_output.
# A fresh call counter per run keeps SUDO_FAIL_CALLS numbering predictable.
run_migration() {
  printf '0' >"$test_dir/sudo-calls"
  migration_status=0
  migration_output=$(env PATH="$stub_bin:$PATH" SUDO_CALL_COUNT="$test_dir/sudo-calls" \
    "$@" bash -euo pipefail "$migration" 2>&1) || migration_status=$?
}

# A legacy global drop-in pointing at a checkout the test user owns, which is
# the exact state this migration exists to rewrite.
checkout="$test_dir/checkout"
mkdir -p "$checkout/bin"
drop_in="$test_dir/omarchy-dev-path"
legacy='Defaults secure_path="'"$checkout"'/bin:/usr/local/sbin:/usr/local/bin:/usr/bin"'
write_legacy() { printf '%s\n' "$legacy" >"$drop_in"; }

# Control: with sudo working throughout, the migration scopes the rule to the
# checkout's owner and rewrites the drop-in.
write_legacy
run_migration OMARCHY_DEV_SUDOERS_FILE="$drop_in"
(( migration_status == 0 )) ||
  fail "migration scopes the rule when sudo works throughout" "exit $migration_status: $migration_output"
grep -q "^Defaults:$(id -un) secure_path=" "$drop_in" ||
  fail "migration rewrote the drop-in to a user-scoped rule" "$(cat "$drop_in")"
pass "sudo working throughout scopes the drop-in to the owner"

# The runner records a migration as applied whenever it exits 0. A sudo that
# cannot inspect the drop-in at all (call 1 fails) must leave it pending, not
# retire it with the global rule still in place.
write_legacy
run_migration SUDO_FAIL_CALLS=1 OMARCHY_DEV_SUDOERS_FILE="$drop_in"
(( migration_status != 0 )) ||
  fail "migration exits non-zero when it cannot inspect the drop-in" "exit $migration_status"
grep -q "Leaving this migration pending" <<<"$migration_output" ||
  fail "migration says why it is leaving itself pending" "$migration_output"
[[ $(cat "$drop_in") == "$legacy" ]] ||
  fail "migration leaves the drop-in untouched when inspection failed" "$(cat "$drop_in")"
pass "a failed inspection leaves the migration pending"

# The reviewer's case on #12883: sudo succeeds for the inspection (call 1) and
# then fails at the owner lookup (call 2). `sudo stat ... || true` used to read
# that denial as an empty owner and exit 0, retiring the migration while the
# global rule stayed. It must now stay pending.
write_legacy
run_migration SUDO_FAIL_CALLS=2 OMARCHY_DEV_SUDOERS_FILE="$drop_in"
(( migration_status != 0 )) ||
  fail "migration exits non-zero when sudo fails at the owner lookup" "exit $migration_status: $migration_output"
grep -q "Leaving this migration pending" <<<"$migration_output" ||
  fail "migration stays pending after a failed owner lookup" "$migration_output"
[[ $(cat "$drop_in") == "$legacy" ]] ||
  fail "migration leaves the drop-in untouched after a failed owner lookup" "$(cat "$drop_in")"
pass "sudo failing at the owner lookup leaves the migration pending"

# With sudo usable and no drop-in present there is genuinely nothing to do, and
# the migration retires normally rather than failing every update.
rm -f "$drop_in"
run_migration OMARCHY_DEV_SUDOERS_FILE="$drop_in"
(( migration_status == 0 )) ||
  fail "migration exits cleanly when the drop-in is genuinely absent" "exit $migration_status: $migration_output"
pass "an absent drop-in is a clean no-op"
