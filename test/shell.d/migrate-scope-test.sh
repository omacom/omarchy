#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
# A failed race assertion leaves its runners blocked; let them finish first.
trap 'touch "$test_tmp/race-release"; wait; rm -rf "$test_tmp"' EXIT

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

# Runners racing one queue. The first blocks inside a migration until released,
# with a bounded wait so a failed assertion cannot strand it.
race_root="$test_tmp/race-omarchy"
race_calls="$test_tmp/race-calls"
race_started="$test_tmp/race-started"
race_release="$test_tmp/race-release"
mkdir -p "$race_root/migrations"

cat >"$race_root/migrations/100-gated.sh" <<'SH'
echo "$TEST_RUNNER" >>"$TEST_CALLS"
[[ $TEST_RUNNER == "first" ]] || exit 0
touch "$TEST_STARTED"
for _ in {1..500}; do
  [[ -f $TEST_RELEASE ]] && break
  sleep 0.02
done
SH

# $! is the runner itself, so a signal reaches only it. A background job starts
# with SIGINT ignored, which would stop the runner from trapping it.
start_racer() {
  local name="$1"
  shift
  env --default-signal=INT -u OMARCHY_UPDATE_LOCK_FD HOME="$race_home" OMARCHY_PATH="$race_root" \
    PATH="$stub_bin:$ROOT/bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" TEST_RUNNER="$name" \
    TEST_CALLS="$race_calls" TEST_DISMISSALS="$dismissals" TEST_STARTED="$race_started" \
    TEST_RELEASE="$race_release" "$@" "$ROOT/bin/omarchy-migrate" >"$test_tmp/$name.out" 2>&1 &
}

wait_until() {
  local _
  for _ in {1..250}; do
    "$@" && return 0
    sleep 0.02
  done
  fail "timed out waiting for: $*"
}

second_reached_queue() {
  grep -q '^Waiting for another Omarchy migration run' "$test_tmp/second.out" ||
    grep -q '^second$' "$race_calls"
}

# Start the first runner and block it inside the gated migration.
start_blocked_first() {
  race_home=$(mktemp -d "$test_tmp/race-home.XXXXXX")
  rm -f "$race_calls" "$race_started" "$race_release" "$test_tmp/second.out"
  start_racer first "$@"
  first_pid=$!
  wait_until test -f "$race_started"
}

# The pause gives a runner that only printed the message time to run the migration.
start_blocked_second() {
  start_racer second
  second_pid=$!
  wait_until second_reached_queue
  sleep 0.3
  [[ $(<"$race_calls") == "first" ]] ||
    fail "concurrent runners do not execute the same migration" "$(<"$race_calls")"
  kill -0 "$second_pid" 2>/dev/null || fail "second runner waits for the active queue"
}

for wrapper in "" "$ROOT/bin/omarchy-update-lock run"; do
  start_blocked_first $wrapper
  start_blocked_second
  touch "$race_release"
  wait "$first_pid" || fail "first migration runner succeeds" "$(<"$test_tmp/first.out")"
  wait "$second_pid" || fail "waiting migration runner succeeds" "$(<"$test_tmp/second.out")"
  [[ $(<"$race_calls") == "first" ]] || fail "waiting runner rechecks completion markers" "$(<"$race_calls")"
done
pass "concurrent runners take turns, inside and outside the update lock"

for signal_name in HUP INT TERM; do
  start_blocked_first
  kill -"$signal_name" "$first_pid"
  start_blocked_second
  kill -0 "$first_pid" 2>/dev/null || fail "$signal_name keeps the lock until the active migration exits"
  touch "$race_release"
  first_status=0
  wait "$first_pid" || first_status=$?
  (( first_status == 128 + $(kill -l "$signal_name") )) || fail "runner preserves the $signal_name exit status" "$first_status"
  wait "$second_pid" || fail "runner proceeds after the $signal_name-interrupted migration" "$(<"$test_tmp/second.out")"
  [[ $(<"$race_calls") == $'first\nsecond' ]] || fail "$signal_name leaves the migration pending for a retry" "$(<"$race_calls")"
done
pass "a signal to the runner keeps the lock until its migration exits"

child_root="$test_tmp/child-omarchy"
child_home="$test_tmp/child-home"
child_calls="$test_tmp/child-calls"
child_pid_file="$test_tmp/child-pid"
mkdir -p "$child_root/migrations" "$child_home"

cat >"$child_root/migrations/100-daemon.sh" <<'SH'
sleep 3 &
echo $! >"$TEST_CHILD_PID"
SH

TEST_CHILD_PID="$child_pid_file" run_migrate "$child_home" "$child_root" >"$test_tmp/child-first.out"

cat >"$child_root/migrations/200-later.sh" <<'SH'
echo later >>"$TEST_CALLS"
SH

TEST_CALLS="$child_calls" run_migrate "$child_home" "$child_root" >"$test_tmp/child-second.out"
grep -q '^later$' "$child_calls" || fail "a later runner runs new migrations"
kill -0 "$(<"$child_pid_file")" 2>/dev/null || fail "a migration's background child does not hold the lock"
kill "$(<"$child_pid_file")"
pass "a migration's background child does not hold the lock"
