#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$stub_bin" "$test_home"

# OMARCHY_TEST_PENDING_FILE, when set, can change mid-run, as an update
# applying the migrations does.
cat >"$stub_bin/omarchy-migrate" <<'SH'
#!/bin/bash
pending=${OMARCHY_TEST_PENDING_MIGRATIONS:-0}
[[ -z ${OMARCHY_TEST_PENDING_FILE:-} ]] || pending=$(<"$OMARCHY_TEST_PENDING_FILE")
if [[ ${1:-} == "--pending" && $pending == 1 ]]; then
  echo 200-migration.sh
  exit 0
else
  exit 1
fi
SH
chmod +x "$stub_bin/omarchy-migrate"

# The real lock helper, with the machine-wide lock moved into this test's
# directory so the machine's own is never read.
machine_lock="$test_tmp/machine/omarchy-update.lock"
sed "s#/run/omarchy-update.lock#$machine_lock#" "$ROOT/bin/omarchy-update-lock" >"$stub_bin/omarchy-update-lock"
grep -qF "machine_lock_path=$machine_lock" "$stub_bin/omarchy-update-lock" || fail "the test moves the machine-wide lock"
chmod +x "$stub_bin/omarchy-update-lock"

# Waiting for the notification server is the notifier's one long pause, so it is
# also where an update can start underneath it. Stand one up from inside the
# wait to prove the notifier re-checks afterwards instead of sending a toast it
# decided to send before the update existed.
cat >"$stub_bin/omarchy-notification-wait" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_LOCK_DURING_WAIT:-0} == 1 && ! -e $OMARCHY_TEST_LOCK_HOLDER_PID ]] || exit 0

lock="$XDG_RUNTIME_DIR/omarchy-update.lock"
held="$lock.held"
rm -f "$held"
: >"$lock"
# Hold the lock through a bash-allocated descriptor rather than `flock <file>
# <command>`: bash marks those close-on-exec, so the holder owns the lock alone
# and killing it releases immediately, with no exec'd child to outlive it. The
# holder blocks for the lock instead of taking it non-blockingly, so it cannot
# lose a startup race and leave the lock unheld.
bash -c 'exec {fd}>"$1"; flock $fd || exit 1; : >"$2"; sleep 60' _ "$lock" "$held" &
echo "$!" >"$OMARCHY_TEST_LOCK_HOLDER_PID"

# Wait on the holder's own signal rather than probing with flock. Probing would
# contend for the very lock we are waiting to see taken.
for _ in {1..200}; do
  [[ -e $held ]] && exit 0
  sleep 0.05
done

echo "stub could not establish the update lock" >&2
exit 1
SH
chmod +x "$stub_bin/omarchy-notification-wait"

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_NOTIFY_SEND:-send} == "fail" ]] && exit 1
printf '%s\n' "$@" >"$OMARCHY_TEST_NOTIFY_ARGS"
SH
chmod +x "$stub_bin/omarchy-notification-send"

runtime_dir="$test_tmp/runtime"
mkdir -p "$runtime_dir"

run_notify() {
  HOME="$test_home" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_PENDING_MIGRATIONS="$1" \
  OMARCHY_TEST_PENDING_FILE="${OMARCHY_TEST_PENDING_FILE:-}" \
  OMARCHY_TEST_NOTIFY_ARGS="$test_tmp/notify-args" \
  OMARCHY_TEST_NOTIFY_SEND="${2:-send}" \
  OMARCHY_TEST_LOCK_DURING_WAIT="${OMARCHY_TEST_LOCK_DURING_WAIT:-0}" \
  OMARCHY_TEST_LOCK_HOLDER_PID="$test_tmp/lock-holder-pid" \
    "$ROOT/bin/omarchy-migrate-notify"
}

notify_args_written() {
  [[ -s $test_tmp/notify-args ]]
}

run_notify 0 >"$test_tmp/not-pending.out" 2>"$test_tmp/not-pending.err"
[[ ! -s $test_tmp/not-pending.out ]] || fail "migration notifier stays quiet on stdout without pending migrations"
[[ ! -s $test_tmp/not-pending.err ]] || fail "migration notifier stays quiet on stderr without pending migrations"
pass "migration notifier ignores users with no pending migrations"

run_notify 1 fail >"$test_tmp/pending.out" 2>"$test_tmp/pending.err"
grep -q 'Omarchy has pending migrations' "$test_tmp/pending.err" || fail "migration notifier explains pending migrations without notification system"
grep -q '200-migration.sh' "$test_tmp/pending.err" || fail "migration notifier lists pending migration names"
pass "migration notifier reports pending migrations"

run_notify 1 >"$test_tmp/notified.out" 2>"$test_tmp/notified.err"
notify_args_written || fail "migration notifier sends a notification for pending migrations"
pass "migration notifier sends a notification for pending migrations"

# Nothing may notify while an update holds a lock this account takes -- a stale
# trigger firing mid-transaction is exactly how the retired
# omarchy-update-user-notify.path used to interrupt updates. The notifier waits
# the update out instead of leaving, then checks what is still pending. It runs
# without the test's copy of the lock, as the login service does.
notifier_waits() { # pid: still running, and nothing sent
  sleep 0.3
  kill -0 "$1" 2>/dev/null && [[ ! -e $test_tmp/notify-args ]]
}

# This account's own update applies the migrations, so afterwards there is
# nothing to say.
rm -f "$test_tmp/notify-args"
update_lock="$runtime_dir/omarchy-update.lock"
: >"$update_lock"
exec {update_lock_fd}>"$update_lock"
flock -n "$update_lock_fd" || fail "test could not hold the update lock"
echo 1 >"$test_tmp/pending"
OMARCHY_TEST_PENDING_FILE="$test_tmp/pending" run_notify 1 >"$test_tmp/during-update.out" 2>"$test_tmp/during-update.err" {update_lock_fd}>&- &
notify_pid=$!
notifier_waits "$notify_pid" || fail "migration notifier waits while omarchy update holds its lock, sending nothing"
echo 0 >"$test_tmp/pending"
exec {update_lock_fd}>&-
wait "$notify_pid" || fail "migration notifier finishes once the update releases its lock"
[[ ! -s $test_tmp/during-update.out && ! -s $test_tmp/during-update.err && ! -e $test_tmp/notify-args ]] ||
  fail "migration notifier has nothing to say once the update applied the migrations"
pass "migration notifier waits out this account's own update, which applies the migrations"

# Migrations still pending once the update has finished are prompted for then.
rm -f "$test_tmp/notify-args"
exec {update_lock_fd}>"$update_lock"
flock -n "$update_lock_fd" || fail "test could not hold the update lock"
run_notify 1 >/dev/null 2>&1 {update_lock_fd}>&- &
notify_pid=$!
notifier_waits "$notify_pid" || fail "migration notifier sends nothing while the update runs"
exec {update_lock_fd}>&-
wait "$notify_pid" || true
notify_args_written || fail "migration notifier prompts once the update releases its lock"
pass "migration notifier prompts for what is still pending once the update releases its lock"

# An update that starts while it waits for the notification server is waited
# out too, rather than notified over.
rm -f "$test_tmp/notify-args" "$test_tmp/lock-holder-pid"
OMARCHY_TEST_LOCK_DURING_WAIT=1 run_notify 1 >"$test_tmp/raced.out" 2>"$test_tmp/raced.err" &
notify_pid=$!
for _ in {1..200}; do
  [[ -s $test_tmp/lock-holder-pid ]] && break
  sleep 0.05
done
[[ -s $test_tmp/lock-holder-pid ]] || fail "the stub update starts while the notifier waits for the notification server"
notifier_waits "$notify_pid" ||
  fail "migration notifier sends no notification while an update that started during its wait runs"
kill "$(<"$test_tmp/lock-holder-pid")" 2>/dev/null || true
wait "$notify_pid" || true
notify_args_written ||
  fail "migration notifier prompts once the update that started during its wait has finished"
pass "migration notifier re-checks for an update after waiting for the notification server"

# Apart from the machine-wide lock, the guard must never read a lock outside
# this user's runtime directory. The updater falls back to
# /tmp/omarchy-update.lock without XDG_RUNTIME_DIR, and a shared /tmp path
# belongs to whoever created it first, so honouring it would let one user
# silence another user's critical notification. Hold that /tmp lock in a
# private mount namespace, so the real /tmp is never touched, and run the
# notifier with no runtime directory.
if unshare --user --map-root-user --mount true 2>/dev/null; then
  rm -f "$test_tmp/notify-args"
  unshare --user --map-root-user --mount bash -c '
    set -euo pipefail
    # A tmpfs is about to cover /tmp, where the test files and even this
    # checkout may live, so reach them through directory descriptors.
    exec {tmp_fd}<"$1" {bin_fd}<"$2"
    tmp=/proc/$$/fd/$tmp_fd bin=/proc/$$/fd/$bin_fd
    mount -t tmpfs tmpfs /tmp
    exec {lock_fd}>/tmp/omarchy-update.lock
    flock -n "$lock_fd"
    env -u XDG_RUNTIME_DIR \
      HOME="$tmp/home" \
      PATH="$tmp/bin:$bin:$PATH" \
      OMARCHY_TEST_PENDING_MIGRATIONS=1 \
      OMARCHY_TEST_NOTIFY_ARGS="$tmp/notify-args" \
      timeout 10 "$bin/omarchy-migrate-notify"
  ' _ "$test_tmp" "$ROOT/bin" >/dev/null 2>&1 || true
  notify_args_written || fail "migration notifier ignores a held update lock in shared /tmp"
  pass "migration notifier ignores a held update lock in shared /tmp"
else
  skip "no unprivileged mount namespace; skipping the shared /tmp lock check"
fi

# With several administrators the lock is the machine's, root's file that each
# of them can only read. Another administrator's update holding it is waited out
# too, and this account's own migrations, which that update doesn't apply, are
# prompted for once it has finished.
rm -f "$test_tmp/notify-args"
mkdir -p "$(dirname "$machine_lock")"
: >"$machine_lock"
chmod 444 "$machine_lock"
exec {machine_lock_fd}<"$machine_lock"
flock -n "$machine_lock_fd" || fail "test could not hold the machine-wide lock"
run_notify 1 >/dev/null 2>&1 {machine_lock_fd}<&- &
notify_pid=$!
notifier_waits "$notify_pid" ||
  fail "migration notifier sends nothing while another administrator's update holds the machine-wide lock"
exec {machine_lock_fd}<&-
wait "$notify_pid" || true
notify_args_written ||
  fail "migration notifier prompts for this account's migrations once the other administrator's update has finished"
pass "migration notifier waits out another administrator's update, then prompts for this account's migrations"
rm -f "$machine_lock"

# The notifier is a Type=oneshot with no start timeout, so it must not stay
# activating until the toast is answered. Handing the click command to the shell
# is what lets it exit immediately -- and what keeps the toast working after the
# shell restart an update performs.
rm -f "$test_tmp/notify-args"
run_notify 1 >/dev/null 2>&1
notify_args_written || fail "migration notifier sends the notification before exiting"
grep -Fx -- '--exec' "$test_tmp/notify-args" >/dev/null ||
  fail "migration notifier attaches the click command to the toast"
grep -Fx 'omarchy-launch-floating-terminal-with-presentation' "$test_tmp/notify-args" >/dev/null &&
  grep -Fx 'omarchy-migrate' "$test_tmp/notify-args" >/dev/null ||
  fail "migration notifier points the click command at omarchy-migrate"
pass "migration notifier lets the shell own the click instead of waiting for it"
