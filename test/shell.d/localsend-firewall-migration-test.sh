#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1790062824.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ ${UFW_ABSENT:-0} != 1 ]]
STUB
# A ufw whose status query, deletes and adds can each be failed independently,
# so the migration's own error handling is what is under test.
cat >"$stub_bin/ufw" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${UFW_CALLS:?}"
case "$1" in
  status) [[ ${UFW_STATUS_FAILS:-0} == 1 ]] && exit 1; echo "Status: active"; exit 0 ;;
esac
case "$*" in
  *delete*) [[ ${UFW_DELETE_FAILS:-0} == 1 ]] && exit 1; echo "Rule deleted"; exit 0 ;;
  *allow*)  [[ ${UFW_ADD_FAILS:-0} == 1 ]] && exit 1; echo "Rule added"; exit 0 ;;
esac
exit 0
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
chmod +x "$stub_bin"/*

ufw_calls="$test_dir/ufw-calls"

run_migration() {
  : >"$ufw_calls"
  migration_status=0
  migration_output=$(env PATH="$stub_bin:$PATH" UFW_CALLS="$ufw_calls" "$@" \
    bash -euo pipefail "$migration" 2>&1) || migration_status=$?
}

# The successful path still does the work.
run_migration
(( migration_status == 0 )) || fail "migration succeeds on the normal path" "$migration_output"
(( $(grep -c "^allow in proto" "$ufw_calls") == 6 )) ||
  fail "migration installs six scoped rules" "$(cat "$ufw_calls")"
pass "normal path deletes the broad rules and installs six scoped ones"

# ufw genuinely absent is a no-op, not a failure.
run_migration UFW_ABSENT=1
(( migration_status == 0 )) || fail "absent ufw is a clean no-op" "$migration_output"
[[ ! -s $ufw_calls ]] || fail "absent ufw runs no ufw commands" "$(cat "$ufw_calls")"
pass "an absent ufw is a clean no-op"

# Each failure mode must leave the migration pending. Exiting 0 would have the
# runner mark it applied and never retry, stranding the unrestricted rules.
for mode in UFW_STATUS_FAILS UFW_DELETE_FAILS UFW_ADD_FAILS; do
  run_migration "$mode=1"
  (( migration_status != 0 )) ||
    fail "migration leaves itself pending when $mode" "exit 0: $migration_output"
  grep -q "Leaving this migration pending" <<<"$migration_output" ||
    fail "migration says why it is pending when $mode" "$migration_output"
done
pass "a failed status query, delete or add all leave the migration pending"
