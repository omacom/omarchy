#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_root="$test_tmp/omarchy"
test_home="$test_tmp/home"
stub_bin="$test_tmp/bin"
mkdir -p "$test_root/migrations" "$test_home" "$stub_bin"

cat >"$stub_bin/omarchy-notification-dismiss" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin/omarchy-notification-dismiss"

cat >"$test_root/migrations/100-migration.sh" <<'SH'
echo migration >>"$TEST_CALLS"
SH

run_migrate() {
  HOME="$test_home" \
  OMARCHY_PATH="$test_root" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  TEST_CALLS="$test_tmp/calls" \
    "$ROOT/bin/omarchy-migrate" "$@"
}

marker="$test_home/.local/state/omarchy/migrations/100-migration.sh"

# A planted empty marker must not suppress the migration.
mkdir -p "$(dirname "$marker")"
: >"$marker"
: >"$test_tmp/calls"
run_migrate --pending >"$test_tmp/pending.out" || fail "planted empty marker is treated as pending"
grep -q '^100-migration\.sh$' "$test_tmp/pending.out" || fail "planted empty marker lists the migration as pending"
pass "planted empty marker does not suppress the migration"

run_migrate >/dev/null
[[ $(cat "$test_tmp/calls") == "migration" ]] || fail "migration runs despite the planted marker"
pass "migration runs despite the planted marker"

# After a genuine run the marker holds the migration hash and the migration is skipped.
expected_hash=$(sha256sum "$test_root/migrations/100-migration.sh" | cut -d' ' -f1)
[[ $(cat "$marker") == "$expected_hash" ]] || fail "marker records the migration hash"
pass "marker records the migration hash"

: >"$test_tmp/calls"
if run_migrate --pending >"$test_tmp/not-pending.out"; then
  fail "completed migration is not listed as pending"
fi
[[ ! -s $test_tmp/not-pending.out ]] || fail "completed migration stays quiet"
[[ ! -s $test_tmp/calls ]] || fail "completed migration does not rerun"
pass "completed migration is skipped"

# A marker with the wrong content is treated as pending again.
printf 'forged\n' >"$marker"
run_migrate --pending >"$test_tmp/pending-again.out" || fail "forged marker is treated as pending"
grep -q '^100-migration\.sh$' "$test_tmp/pending-again.out" || fail "forged marker lists the migration as pending"
pass "forged marker content does not suppress the migration"
