#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_root="$test_tmp/omarchy"
test_home="$test_tmp/home"
mkdir -p "$test_root/migrations" "$test_home"

cat >"$test_root/migrations/100-first.sh" <<'SH'
[[ $OMARCHY_PATH == "$TEST_EXPECTED_OMARCHY_PATH" ]]
echo first >>"$TEST_CALLS"
SH
cat >"$test_root/migrations/200-second.sh" <<'SH'
[[ $OMARCHY_PATH == "$TEST_EXPECTED_OMARCHY_PATH" ]]
echo second >>"$TEST_CALLS"
SH

calls="$test_tmp/calls"

if ! HOME="$test_home" OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-migrate" --pending >"$test_tmp/pending.out"; then
  fail "migration runner reports pending migrations before state exists"
fi
grep -q '^100-first\.sh$' "$test_tmp/pending.out" || fail "migration runner lists first pending migration filename"
grep -q '^200-second\.sh$' "$test_tmp/pending.out" || fail "migration runner lists second pending migration filename"
pass "migration runner detects pending migrations"

HOME="$test_home" \
OMARCHY_PATH="$test_root" \
TEST_EXPECTED_OMARCHY_PATH="$test_root" \
TEST_CALLS="$calls" \
  "$ROOT/bin/omarchy-migrate" >"$test_tmp/first-run.out"
[[ $(sed -n '1p' "$calls") == "first" ]] || fail "migration runner runs first migration"
[[ $(sed -n '2p' "$calls") == "second" ]] || fail "migration runner runs second migration"
[[ -f $test_home/.local/state/omarchy/migrations/100-first.sh ]] || fail "migration runner records first migration marker"
[[ -f $test_home/.local/state/omarchy/migrations/200-second.sh ]] || fail "migration runner records second migration marker"
pass "migration runner runs all migrations"

HOME="$test_home" \
OMARCHY_PATH="$test_root" \
TEST_EXPECTED_OMARCHY_PATH="$test_root" \
TEST_CALLS="$calls" \
  "$ROOT/bin/omarchy-migrate" >"$test_tmp/second-run.out"
[[ $(wc -l <"$calls") -eq 2 ]] || fail "migration runner skips completed migrations"
pass "migration runner skips completed migrations"

if HOME="$test_home" OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-migrate" --pending >"$test_tmp/not-pending.out"; then
  fail "migration runner reports no pending migrations after state exists"
fi
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
HOME="$failure_home" \
OMARCHY_PATH="$failure_root" \
TEST_CALLS="$calls" \
  "$ROOT/bin/omarchy-migrate" >"$test_tmp/failure.out" 2>"$test_tmp/failure.err"
failure_status=$?
set -e
[[ $failure_status -ne 0 ]] || fail "migration runner exits non-zero when a migration fails"
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

printf 'migration input\n' | \
  HOME="$stdin_home" \
  OMARCHY_PATH="$stdin_root" \
  TEST_CALLS="$stdin_calls" \
  "$ROOT/bin/omarchy-migrate" >"$test_tmp/stdin.out"

grep -q '^reader:migration input$' "$stdin_calls" ||
  fail "migration runner preserves the caller's stdin for a migration" "$(cat "$stdin_calls")"
grep -q '^after-reader$' "$stdin_calls" ||
  fail "a migration reading stdin does not swallow later queue entries" "$(cat "$stdin_calls")"
[[ -f $stdin_home/.local/state/omarchy/migrations/100-reader.sh &&
  -f $stdin_home/.local/state/omarchy/migrations/200-after.sh ]] ||
  fail "migration runner marks both stdin-isolated migrations complete"
pass "migration queue uses a private file descriptor instead of migration stdin"

# A migration waiting for another repository's package defers: it leaves a note
# and exits 75. It stays unmarked, the queue goes on, and it is not pending
# while it waits, until a package changes.
defer_root="$test_tmp/defer-omarchy"
defer_home="$test_tmp/defer-home"
defer_calls="$test_tmp/defer-calls"
defer_state="$defer_home/.local/state/omarchy/migrations"
package_db="$test_tmp/package-db"
mkdir -p "$defer_root/migrations" "$defer_home" "$package_db"

cat >"$defer_root/migrations/100-waits.sh" <<'SH'
echo waits >>"$TEST_CALLS"
if [[ ! -e $TEST_READY ]]; then
  echo "waiting for a package" >"$OMARCHY_MIGRATION_DEFER"
  exit 75
fi
[[ ! -e $TEST_BROKEN ]]
SH
cat >"$defer_root/migrations/200-after.sh" <<'SH'
echo after >>"$TEST_CALLS"
SH

run_defer() {
  HOME="$defer_home" OMARCHY_PATH="$defer_root" OMARCHY_PACKAGE_DB="$package_db" TEST_CALLS="$defer_calls" \
    TEST_READY="$test_tmp/defer-ready" TEST_BROKEN="$test_tmp/defer-broken" "$ROOT/bin/omarchy-migrate" "$@"
}
packages_change() {
  touch -d "@$(($(stat -c %Y "$package_db") + 60))" "$package_db"
}

run_defer >"$test_tmp/defer.out" || fail "a deferred migration does not fail the run" "$(cat "$test_tmp/defer.out")"
[[ ! -f $defer_state/100-waits.sh ]] || fail "a deferred migration is not marked complete"
[[ -f $defer_state/200-after.sh ]] || fail "the queue goes on past a deferred migration"
if run_defer --pending >"$test_tmp/defer-pending.out"; then
  fail "a deferred migration is not pending while nothing has changed" "$(cat "$test_tmp/defer-pending.out")"
fi
run_defer >/dev/null || fail "a deferred migration does not fail a later run"
(( $(grep -c '^waits$' "$defer_calls") == 2 && $(grep -c '^after$' "$defer_calls") == 1 )) ||
  fail "a deferred migration runs again on the next run, and only it" "$(cat "$defer_calls")"
pass "a deferred migration waits without stopping the queue or counting as pending"

packages_change
run_defer --pending | grep -qx '100-waits.sh' ||
  fail "a deferred migration is pending again once a package changes, so the login notifier reaches it"
run_defer >/dev/null
if run_defer --pending >/dev/null; then
  fail "deferring again after the change waits again"
fi
pass "a package change makes a deferred migration pending again until it runs"

touch "$test_tmp/defer-ready" "$test_tmp/defer-broken"
if run_defer >/dev/null 2>&1; then
  fail "a deferred migration that then fails fails the run"
fi
run_defer --pending | grep -qx '100-waits.sh' ||
  fail "a deferred migration that then fails is pending, not still waiting"
rm "$test_tmp/defer-broken"
run_defer >/dev/null || fail "a deferred migration that can finish does"
[[ -f $defer_state/100-waits.sh && ! -e $defer_state/deferred/100-waits.sh ]] ||
  fail "a deferred migration that finishes is marked complete and no longer deferred"
pass "a deferred migration that fails is pending, and one that finishes is complete"

# Exiting 75 without the note is a failure like any other: a command inside a
# migration can return 75 without meaning to wait.
accident_root="$test_tmp/accident-omarchy"
accident_home="$test_tmp/accident-home"
mkdir -p "$accident_root/migrations" "$accident_home"
cat >"$accident_root/migrations/100-accident.sh" <<'SH'
exit 75
SH
cat >"$accident_root/migrations/200-after.sh" <<'SH'
true
SH
if HOME="$accident_home" OMARCHY_PATH="$accident_root" OMARCHY_PACKAGE_DB="$package_db" "$ROOT/bin/omarchy-migrate" >/dev/null 2>&1; then
  fail "a migration that exits 75 without a note fails the run"
fi
[[ ! -e $accident_home/.local/state/omarchy/migrations/200-after.sh &&
  ! -e $accident_home/.local/state/omarchy/migrations/deferred/100-accident.sh ]] ||
  fail "a migration that exits 75 without a note stops the queue and is not deferred"
pass "only a migration that says why it waits is deferred"
