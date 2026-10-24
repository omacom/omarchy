#!/bin/bash
#
# Updates and administrators' migrations share one lock for the whole machine,
# so two administrators never run them at once. An account that can't read
# that lock, or a machine that hasn't created it yet, locks only itself.

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
holder=""
trap '[[ -z $holder ]] || kill "$holder" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT

lock_bin="$test_tmp/bin"
machine_lock="$test_tmp/machine.lock"
mkdir -p "$lock_bin" "$test_tmp/run-a" "$test_tmp/run-b"

# The helper with its machine-wide lock moved into this test's directory.
sed "s#/run/omarchy-update.lock#$machine_lock#" "$ROOT/bin/omarchy-update-lock" >"$lock_bin/omarchy-update-lock"
grep -qF "machine_lock_path=$machine_lock" "$lock_bin/omarchy-update-lock" || fail "the test moves the machine-wide lock"
for name in omarchy-sudo-allowed omarchy-notification-dismiss; do
  printf '#!/bin/bash\nexit 0\n' >"$lock_bin/$name"
done
chmod +x "$lock_bin"/*

# Two accounts differ here by their runtime directories, where each keeps its
# own lock.
as_account() { # a|b COMMAND...
  local account=$1
  shift
  XDG_RUNTIME_DIR="$test_tmp/run-$account" PATH="$lock_bin:$PATH" "$@"
}

hold_lock() { # a|b
  rm -f "$test_tmp/held" "$test_tmp/release"
  as_account "$1" omarchy-update-lock run bash -c ': >"$1"; until [[ -e $2 ]]; do sleep 0.05; done' _ \
    "$test_tmp/held" "$test_tmp/release" &
  holder=$!
  for _ in {1..100}; do
    [[ -e $test_tmp/held ]] && return 0
    sleep 0.05
  done
  fail "a lock holder starts"
}

release_lock() {
  touch "$test_tmp/release"
  wait "$holder" || true
  holder=""
}

# Root's file on a real machine, which an administrator can only read.
make_machine_lock() {
  rm -f "$machine_lock"
  : >"$machine_lock"
  chmod 444 "$machine_lock"
}

mkdir -p "$test_tmp/omarchy/migrations"
printf 'echo ran >>"$TEST_CALLS"\n' >"$test_tmp/omarchy/migrations/100-step.sh"
migrate() { # a|b [COMMAND...]: run omarchy-migrate as that account, inside COMMAND if given
  local account=$1
  shift
  rm -rf "$test_tmp/state-$account" "$test_tmp/calls-$account"
  as_account "$account" env OMARCHY_PATH="$test_tmp/omarchy" OMARCHY_MIGRATION_STATE="$test_tmp/state-$account" \
    TEST_CALLS="$test_tmp/calls-$account" "$@" "$ROOT/bin/omarchy-migrate"
}

refused() { # a|b: that account's run is turned away while the holder runs
  local out
  if out=$(as_account "$1" omarchy-update-lock run true 2>&1); then return 1; fi
  [[ $out == *"already running"* ]]
}

# A machine with the shared lock: one account's run keeps out the other's.
make_machine_lock
as_account a omarchy-update-lock shared || fail "an account that can read the machine-wide lock takes it"
hold_lock a
refused b || fail "a second account's run waits for the first's, and says why"
as_account b omarchy-update-lock busy || fail "the other account sees the machine-wide lock busy"
release_lock
as_account b omarchy-update-lock run true || fail "the lock is free once the first run ends"
as_account b omarchy-update-lock busy && fail "nothing is busy once the run ends"
pass "with the machine-wide lock, two accounts never run at once"

# Without it, each account locks only itself, as before.
rm -f "$machine_lock"
as_account a omarchy-update-lock shared && fail "without the machine-wide lock no account takes it"
hold_lock a
as_account b omarchy-update-lock run true || fail "without the machine-wide lock another account isn't held up"
refused a || fail "without the machine-wide lock an account still keeps out its own second run"
release_lock
if (( EUID != 0 )); then
  make_machine_lock
  chmod 000 "$machine_lock"
  as_account a omarchy-update-lock shared && fail "an account that can't read the machine-wide lock takes its own"
fi
pass "an account that can't read the machine-wide lock, or a machine without one, locks only itself"

# The machine-wide lock can appear while an update that started without it
# still holds only the account's own. That update's own migrations run inside
# it, and the same account's next run still waits for it.
rm -f "$machine_lock"
hold_lock a
make_machine_lock
refused a || fail "an update from before the machine-wide lock keeps out the same account's next run"
as_account a omarchy-update-lock busy || fail "the account sees its own update from before the machine-wide lock as busy"
release_lock
rm -f "$machine_lock"
migrate a omarchy-update-lock run bash -c ': >"$1"; chmod 444 "$1"; exec "$2"' _ "$machine_lock" >/dev/null ||
  fail "an update from before the machine-wide lock still runs its migrations once the lock appears"
[[ $(cat "$test_tmp/calls-a") == "ran" ]] || fail "that update's migration ran once"
pass "an update that started before the machine-wide lock existed runs its migrations and keeps out its account's next run"

# omarchy-migrate takes the same lock for an administrator: not while another
# account's update or migration holds it, and as usual inside an update, which
# already holds it. Other accounts' migrations lock nothing.
make_machine_lock

hold_lock a
if out=$(migrate b 2>&1); then fail "a migration waits while another account's update runs"; fi
[[ $out == *"already running"* && ! -e $test_tmp/calls-b && ! -e $test_tmp/state-b/100-step.sh ]] ||
  fail "a migration held up by another account's update runs nothing and stays pending" "$out"
release_lock
migrate b >/dev/null || fail "the migration runs once the lock is free"
[[ $(cat "$test_tmp/calls-b") == "ran" && -e $test_tmp/state-b/100-step.sh ]] || fail "the migration ran once and is marked done"
migrate a omarchy-update-lock run >/dev/null || fail "a migration runs inside an update that holds the lock"
[[ $(cat "$test_tmp/calls-a") == "ran" ]] || fail "inside an update the migration runs once"
if (( EUID != 0 )); then
  chmod 000 "$machine_lock"
  hold_lock b
  migrate b >/dev/null || fail "an account that can't read the machine-wide lock migrates without taking any lock"
  [[ $(cat "$test_tmp/calls-b") == "ran" ]] || fail "that account's migration ran"
  release_lock
  chmod 444 "$machine_lock"
fi
pass "omarchy-migrate takes the same lock for an administrator, runs as usual inside an update, and locks nothing for other accounts"
