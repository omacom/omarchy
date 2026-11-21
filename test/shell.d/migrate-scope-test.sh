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

# The login notification and omarchy-update can each start a run, and one that
# clicks through while the other is mid-migration must wait for it rather than
# run the same migration alongside it. Hold the first run inside a migration
# with a lock the test owns, start a second run against the same state, and
# release the first only once the second is seen waiting on the runner's lock.
race_root="$test_tmp/race-omarchy"
race_home="$test_tmp/race-home"
race_state="$test_tmp/race-state"
race_calls="$test_tmp/race-calls"
race_gate="$test_tmp/race-gate"
race_started="$test_tmp/race-started"
mkdir -p "$race_root/migrations" "$race_home" "$race_state"
: >"$race_gate"
mkfifo "$race_started"

cat >"$race_root/migrations/100-slow.sh" <<'SH'
echo run >>"$TEST_CALLS"
echo started >"$TEST_STARTED"
flock -s "$TEST_GATE" true
SH

# Opened read-write so the migration's writes never block on a missing reader
# and reads here can time out instead of blocking on open.
exec {race_started_fd}<>"$race_started"
exec {race_gate_fd}>"$race_gate"
flock "$race_gate_fd" || fail "test could not hold the migration gate"

race_pids=""
trap 'kill $race_pids 2>/dev/null || true; rm -rf "$test_tmp"' EXIT

# Under `timeout` so a runner that never finishes fails the file instead of
# hanging it; $! is the timeout process and the runner itself is its child.
start_race_migrate() {
  HOME="$race_home" \
  OMARCHY_PATH="$race_root" \
  OMARCHY_MIGRATION_STATE="$race_state" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  TEST_EXPECTED_OMARCHY_PATH="$race_root" \
  TEST_CALLS="$race_calls" \
  TEST_DISMISSALS="$dismissals" \
  TEST_STARTED="$race_started" \
  TEST_GATE="$race_gate" \
    timeout 30 "$ROOT/bin/omarchy-migrate" >"$test_tmp/race-$1.out" 2>&1 &
  race_pids="$race_pids $!"
}

# True once the runner under timeout process $1 has the runner's lock file
# open: it is waiting in flock, or already past it.
race_lock=$(readlink -f "$race_state")/.lock
migrate_waits_for_lock() {
  local child fd
  child=$(pgrep -P "$1") || return 1
  for fd in /proc/"$child"/fd/*; do
    [[ $(readlink "$fd" 2>/dev/null) == "$race_lock" ]] && return 0
  done
  return 1
}

start_race_migrate first
first_pid=$!
read -r -t 10 -u "$race_started_fd" _ || fail "first migration runner did not start the fixture migration"

start_race_migrate second
second_pid=$!
second_waits=0
for _ in {1..200}; do
  if read -r -t 0.05 -u "$race_started_fd" _; then
    fail "a second migration runner ran a migration the first runner was still running"
  fi
  if migrate_waits_for_lock "$second_pid"; then
    second_waits=1
    break
  fi
done
(( second_waits )) || fail "second migration runner neither waited for the runner lock nor ran the migration"

flock -u "$race_gate_fd"
wait "$first_pid" || fail "first migration runner exits 0 after a concurrent run"
wait "$second_pid" || fail "second migration runner exits 0 after waiting for the first" "$(cat "$test_tmp/race-second.out")"
(( $(wc -l <"$race_calls") == 1 )) || fail "concurrent migration runners run a migration once" "$(cat "$race_calls")"
[[ -f $race_state/100-slow.sh ]] || fail "concurrent migration runners record the migration marker"
pass "a concurrent migration runner waits for the running one instead of repeating its migration"
