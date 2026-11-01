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
printf '%s\n' "$1" >>"$TEST_DISMISSALS"
SH
chmod +x "$stub_bin/omarchy-notification-dismiss"

cat >"$test_root/migrations/100-first.sh" <<'SH'
[[ $OMARCHY_PATH == "$TEST_EXPECTED_OMARCHY_PATH" ]]
echo first >>"$TEST_CALLS"
SH
cat >"$test_root/migrations/200-second.sh" <<'SH'
[[ $OMARCHY_PATH == "$TEST_EXPECTED_OMARCHY_PATH" ]]
echo second >>"$TEST_CALLS"
SH

calls="$test_tmp/calls"
dismissals="$test_tmp/dismissals"

# $1 is HOME, $2 is OMARCHY_PATH; the rest are omarchy-migrate's arguments.
run_migrate() {
  local home="$1" root="$2"
  shift 2
  HOME="$home" \
  OMARCHY_PATH="$root" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  TEST_EXPECTED_OMARCHY_PATH="$root" \
  TEST_CALLS="${TEST_CALLS:-$calls}" \
  TEST_DISMISSALS="$dismissals" \
    "$ROOT/bin/omarchy-migrate" "$@"
}

if ! run_migrate "$test_home" "$test_root" --pending >"$test_tmp/pending.out"; then
  fail "migration runner reports pending migrations before state exists"
fi
grep -q '^100-first\.sh$' "$test_tmp/pending.out" || fail "migration runner lists first pending migration filename"
grep -q '^200-second\.sh$' "$test_tmp/pending.out" || fail "migration runner lists second pending migration filename"
pass "migration runner detects pending migrations"

run_migrate "$test_home" "$test_root" >"$test_tmp/first-run.out"
[[ $(sed -n '1p' "$calls") == "first" ]] || fail "migration runner runs first migration"
[[ $(sed -n '2p' "$calls") == "second" ]] || fail "migration runner runs second migration"
[[ -f $test_home/.local/state/omarchy/migrations/100-first.sh ]] || fail "migration runner records first migration marker"
[[ -f $test_home/.local/state/omarchy/migrations/200-second.sh ]] || fail "migration runner records second migration marker"
pass "migration runner runs all migrations"

grep -Fx 'Omarchy Migrations' "$dismissals" >/dev/null || fail "migration runner dismisses migration notifications"
pass "migration runner clears completed migration notifications"

run_migrate "$test_home" "$test_root" >"$test_tmp/second-run.out"
(( $(wc -l <"$calls") == 2 )) || fail "migration runner skips completed migrations"
pass "migration runner skips completed migrations"

if run_migrate "$test_home" "$test_root" --pending >"$test_tmp/not-pending.out"; then
  fail "migration runner reports no pending migrations after state exists"
fi
[[ ! -s $test_tmp/not-pending.out ]] || fail "migration runner --pending stays quiet without pending migrations"
pass "migration runner detects no pending migrations"

failure_root="$test_tmp/failure-omarchy"
failure_home="$test_tmp/failure-home"
mkdir -p "$failure_root/migrations" "$failure_home"

cat >"$failure_root/migrations/500-fail.sh" <<'SH'
echo before-fail >>"$TEST_CALLS"
false
echo after-fail >>"$TEST_CALLS"
SH

set +e
run_migrate "$failure_home" "$failure_root" >"$test_tmp/failure.out" 2>"$test_tmp/failure.err"
failure_status=$?
set -e
(( failure_status != 0 )) || fail "migration runner exits non-zero when a migration fails"
[[ ! -f $failure_home/.local/state/omarchy/migrations/500-fail.sh ]] || fail "migration runner does not mark failed migration complete"
grep -q '^before-fail$' "$calls" || fail "migration runner started failing migration"
! grep -q '^after-fail$' "$calls" || fail "migration runner stops failing migration under strict mode"
pass "migration runner does not mark failed migrations complete"

stdin_root="$test_tmp/stdin-omarchy"
stdin_home="$test_tmp/stdin-home"
stdin_calls="$test_tmp/stdin-calls"
mkdir -p "$stdin_root/migrations" "$stdin_home"

cat >"$stdin_root/migrations/100-reader.sh" <<'SH'
IFS= read -r value
printf 'reader:%s\n' "$value" >>"$TEST_CALLS"
SH
cat >"$stdin_root/migrations/200-after.sh" <<'SH'
echo after-reader >>"$TEST_CALLS"
SH

printf 'migration input\n' |
  TEST_CALLS="$stdin_calls" run_migrate "$stdin_home" "$stdin_root" >"$test_tmp/stdin.out"

grep -q '^reader:migration input$' "$stdin_calls" ||
  fail "migration runner preserves the caller's stdin for a migration" "$(cat "$stdin_calls")"
grep -q '^after-reader$' "$stdin_calls" ||
  fail "a migration reading stdin does not swallow later queue entries" "$(cat "$stdin_calls")"
[[ -f $stdin_home/.local/state/omarchy/migrations/100-reader.sh &&
  -f $stdin_home/.local/state/omarchy/migrations/200-after.sh ]] ||
  fail "migration runner marks both stdin-isolated migrations complete"
pass "migration queue uses a private file descriptor instead of migration stdin"

dag_root="$test_tmp/dag-omarchy"
dag_home="$test_tmp/dag-home"
dag_calls="$test_tmp/dag-calls"
mkdir -p "$dag_root/migrations" "$dag_home"

cat >"$dag_root/migrations/100-dependent.sh" <<'SH'
# omarchy:depends_on=200-prereq.sh
echo dependent >>"$TEST_CALLS"
SH
cat >"$dag_root/migrations/200-prereq.sh" <<'SH'
echo prereq >>"$TEST_CALLS"
SH

TEST_CALLS="$dag_calls" run_migrate "$dag_home" "$dag_root" >"$test_tmp/dag.out"
[[ $(sed -n '1p' "$dag_calls") == "prereq" ]] || fail "DAG sort runs prerequisite migration first"
[[ $(sed -n '2p' "$dag_calls") == "dependent" ]] || fail "DAG sort runs dependent migration second"
pass "migration runner resolves dependencies with DAG topological sort"

order_root="$test_tmp/order-omarchy"
order_home="$test_tmp/order-home"
order_calls="$test_tmp/order-calls"
mkdir -p "$order_root/migrations" "$order_home"

cat >"$order_root/migrations/100.sh" <<'SH'
echo 100 >>"$TEST_CALLS"
SH
cat >"$order_root/migrations/200.sh" <<'SH'
# omarchy:depends_on=100.sh
echo 200 >>"$TEST_CALLS"
SH
cat >"$order_root/migrations/300.sh" <<'SH'
echo 300 >>"$TEST_CALLS"
SH

TEST_CALLS="$order_calls" run_migrate "$order_home" "$order_root" >"$test_tmp/order.out"
[[ $(sed -n '1p' "$order_calls") == "100" ]] || fail "first migration runs first"
[[ $(sed -n '2p' "$order_calls") == "200" ]] || fail "unblocked migration preserves historical order over subsequent migrations"
[[ $(sed -n '3p' "$order_calls") == "300" ]] || fail "later migration runs after earlier unblocked migration"
pass "migration runner preserves historical timestamp order for ready migrations"

missing_root="$test_tmp/missing-omarchy"
missing_home="$test_tmp/missing-home"
missing_calls="$test_tmp/missing-calls"
mkdir -p "$missing_root/migrations" "$missing_home"

cat >"$missing_root/migrations/100-blocked.sh" <<'SH'
# omarchy:depends_on=does-not-exist.sh
echo blocked >>"$TEST_CALLS"
SH

# Pending check discovers unfinished migrations even when dependencies are missing (#8395)
if ! run_migrate "$missing_home" "$missing_root" --pending >"$test_tmp/missing-pending.out"; then
  fail "migration runner --pending fails when a migration has a missing prerequisite"
fi
grep -q '^100-blocked\.sh$' "$test_tmp/missing-pending.out" || fail "--pending does not list migration with missing prerequisite"
pass "pending discovery reports unfinished migrations regardless of missing prerequisites"

set +e
missing_err="$test_tmp/missing.err"
TEST_CALLS="$missing_calls" run_migrate "$missing_home" "$missing_root" >"$test_tmp/missing.out" 2>"$missing_err"
missing_status=$?
set -e
(( missing_status != 0 )) || fail "migration runner exits non-zero when a prerequisite is missing"
grep -q "requires missing prerequisite does-not-exist\.sh" "$missing_err" || fail "migration runner warns about missing prerequisite"
[[ ! -f $missing_home/.local/state/omarchy/migrations/100-blocked.sh ]] || fail "blocked migration marker was created"
[[ ! -s $missing_calls ]] || fail "blocked migration should not have run"
pass "migration runner stops and warns before running migration with missing prerequisite"
