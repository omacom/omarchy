#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
test_tmp="$boundary_tmp"
stub_bin="$SUDO_TEST_ROOT/bin"
test_home="$SUDO_TEST_HOME"
runtime_dir="/run/user/$(id -u)"
test_run_id="test-$BASHPID-$RANDOM"
update_lock_name="omarchy-update-$test_run_id.lock"
stay_awake_dir_name="omarchy-update-stay-awake-$test_run_id"
trap 'rm -rf -- "$runtime_dir/$stay_awake_dir_name"; rm -f -- "$runtime_dir/$update_lock_name"; rm -rf -- "$boundary_tmp"' EXIT
for command in omarchy-update omarchy-update-lock omarchy-update-stay-awake; do
  rm -f "$SUDO_TEST_ROOT/bin/$command"
  copy_boundary_file "bin/$command"
done
sed -i \
  -e "s/omarchy-update\.lock/$update_lock_name/g" \
  -e "s#state_dir=\"\$state_base/omarchy-update-stay-awake\"#state_dir=\"\$state_base/$stay_awake_dir_name\"#" \
  "$SUDO_TEST_ROOT/bin/omarchy-update" \
  "$SUDO_TEST_ROOT/bin/omarchy-update-lock" \
  "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake"
cat >"$SUDO_TEST_ROOT/mock/setpriv" <<'STUB'
#!/bin/bash
while [[ ${1:-} == --* ]]; do
  case "$1" in
    --reuid|--regid) shift 2 ;;
    --clear-groups) shift ;;
    *) exit 90 ;;
  esac
done
exec "$@"
STUB
chmod +x "$SUDO_TEST_ROOT/mock/setpriv"

run_with_lock_env() {
  SUDO_TEST_HOME="$test_home" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  XDG_STATE_HOME="$test_tmp/state" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$@"
}

write_stub() {
  local name="$1"
  local body="$2"

  rm -f "$stub_bin/$name"
  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

for command in \
  omarchy-toggle-idle \
  pkexec \
  systemd-inhibit \
  omarchy-update-pkg-prune \
  omarchy-update-dev \
  omarchy-update-keyring \
  omarchy-update-system-pkgs \
  omarchy-migrate \
  omarchy-update-aur-pkgs \
  omarchy-update-mise \
  omarchy-update-orphan-pkgs \
  omarchy-update-boot \
  omarchy-hook \
  omarchy-update-analyze-logs \
  omarchy-shell \
  omarchy-update-restart; do
  write_stub "$command" 'exit 0'
done
write_stub omarchy-update-available 'exit 1'
write_stub pkexec 'exec "$@"'
ln -s ../bin/pkexec "$SUDO_TEST_ROOT/mock/pkexec"
write_stub systemd-inhibit 'while [[ $1 == --* ]]; do shift; done; exec "$@"'
ln -s ../bin/systemd-inhibit "$SUDO_TEST_ROOT/mock/systemd-inhibit"

# omarchy-update should hold the lock before snapshotting, so a second update
# cannot even enter its pre-update snapshot.
update_snapshot_marker="$test_tmp/update-snapshot-started"
write_stub omarchy-snapshot 'echo started >"$TEST_MARKER"; sleep 0.8; exit 0'

OMARCHY_UPDATE_LOGGED=1 TEST_MARKER="$update_snapshot_marker" run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$test_tmp/update-first.out" 2>&1 &
update_pid=$!

for _ in {1..50}; do
  [[ -f $update_snapshot_marker ]] && break
  sleep 0.05
done
[[ -f $update_snapshot_marker ]] || fail "first omarchy-update reached snapshot under lock"

set +e
OMARCHY_UPDATE_LOGGED=1 TEST_MARKER="$test_tmp/update-second-snapshot-started" run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$test_tmp/update-second.out" 2>&1
update_second_status=$?
set -e

wait "$update_pid"

[[ $update_second_status -ne 0 ]] || fail "second omarchy-update exits non-zero while update lock is held"
grep -q "already running" "$test_tmp/update-second.out" || fail "second omarchy-update reports held update lock"
[[ ! -f $test_tmp/update-second-snapshot-started ]] || fail "second omarchy-update did not snapshot while lock was held"
pass "omarchy-update prevents overlapping top-level updates"

# The sleep inhibitor deliberately outlives the step that starts it, so it must
# not inherit the update lock. An update killed before restore_update_inhibitors
# would otherwise leave the inhibitor holding the flock forever, blocking every
# later update and silencing omarchy-migrate-notify, which reads the same lock.
inhibit_pid_file="$test_tmp/inhibit-pid"
keyring_marker="$test_tmp/keyring-started"
write_stub omarchy-snapshot 'exit 0'
write_stub systemd-inhibit '[[ -z ${INHIBIT_PID_FILE:-} ]] || echo "$$" >"$INHIBIT_PID_FILE"; while [[ $1 == --* ]]; do shift; done; exec "$@"'
write_stub omarchy-update-keyring 'echo started >"$TEST_MARKER"; sleep 1; exit 0'

OMARCHY_UPDATE_LOGGED=1 TEST_MARKER="$keyring_marker" INHIBIT_PID_FILE="$inhibit_pid_file" \
  run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$test_tmp/update-inhibit.out" 2>&1 &
inhibit_update_pid=$!

for _ in {1..100}; do
  [[ -s $inhibit_pid_file && -f $keyring_marker ]] && break
  sleep 0.05
done
[[ -s $inhibit_pid_file ]] || fail "update starts its sleep inhibitor"

inhibitor_pid=$(<"$inhibit_pid_file")
kill -0 "$inhibitor_pid" 2>/dev/null || fail "sleep inhibitor is still running when its descriptors are inspected"

lock_target=$(readlink -f "$runtime_dir/$update_lock_name")
inhibitor_holds_lock=0
for fd in /proc/"$inhibitor_pid"/fd/*; do
  [[ -e $fd ]] || continue
  [[ $(readlink -f "$fd" 2>/dev/null) == "$lock_target" ]] && inhibitor_holds_lock=1
done

wait "$inhibit_update_pid"

(( inhibitor_holds_lock == 0 )) || fail "update keeps the update lock out of the sleep inhibitor it leaves running"
pass "omarchy-update keeps the update lock out of its sleep inhibitor"

kill -0 "$inhibitor_pid" 2>/dev/null &&
  fail "update waits for its sleep inhibitor to stop before continuing"
pass "omarchy-update waits for its sleep inhibitor to stop"

if (( EUID != 0 )); then
  sudo_log="$SUDO_TEST_LOG"
  : >"$sudo_log"
  pkexec_marker="$test_tmp/pkexec-used"
  terminal_inhibit_pid_file="$test_tmp/terminal-inhibit-pid"
  write_stub pkexec '[[ -z ${PKEXEC_MARKER:-} ]] || touch "$PKEXEC_MARKER"; exec "$@"'
  write_stub systemd-inhibit 'sleep 0.2; while [[ $1 == --* ]]; do shift; done; exec "$@"'

  # sudo -b returns before its child is ready. Require start to wait for the
  # delayed child and succeed, then stop it before script tears down the PTY.
  terminal_driver="$test_tmp/terminal-stay-awake"
  cat >"$terminal_driver" <<'SH'
#!/bin/bash
set -euo pipefail
omarchy-update-stay-awake start
[[ -s $XDG_RUNTIME_DIR/REPLACE_STAY_AWAKE_DIR/inhibit-pid ]]
omarchy-update-stay-awake stop
[[ ! -e $XDG_RUNTIME_DIR/REPLACE_STAY_AWAKE_DIR/inhibit-pid ]]
SH
  sed -i "s/REPLACE_STAY_AWAKE_DIR/$stay_awake_dir_name/g" "$terminal_driver"
  chmod +x "$terminal_driver"

  SUDO_LOG="$sudo_log" PKEXEC_MARKER="$pkexec_marker" INHIBIT_PID_FILE="$terminal_inhibit_pid_file" \
    run_with_lock_env script -qefc "$terminal_driver" /dev/null >/dev/null

  grep -q -- '^sudo -N -b -- ' "$sudo_log" || fail "terminal inhibition authenticates its background command without a reusable timestamp"
  [[ ! -e $pkexec_marker ]] || fail "terminal sleep inhibition does not use pkexec"
  run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake" stop
  pass "terminal updates use sudo instead of Polkit for sleep inhibition"

  wait_for_process_exit() {
    local process_pid="$1"

    for _ in {1..100}; do
      kill -0 "$process_pid" 2>/dev/null || return 0
      [[ $(awk '{ print $3 }' "/proc/$process_pid/stat" 2>/dev/null || true) == "Z" ]] && return 0
      sleep 0.02
    done
    return 1
  }

  delayed_marker="$test_tmp/delayed-inhibitor"
  delayed_helper_pid_file="$test_tmp/delayed-helper-pid"
  write_stub systemd-inhibit 'echo "$$" >"$DELAYED_MARKER"; sleep 0.4; while [[ $1 == --* ]]; do shift; done; exec "$@"'

  # Keep the start helper's stdin attached to the private PTY so it takes the
  # sudo -b branch, then signal only that helper before the held child publishes.
  delayed_terminal_driver="$test_tmp/delayed-terminal-stay-awake"
  cat >"$delayed_terminal_driver" <<'SH'
#!/bin/bash
set +e
omarchy-update-stay-awake start </dev/tty &
helper_pid=$!
echo "$helper_pid" >"$DELAYED_HELPER_PID_FILE"
wait "$helper_pid"
exit $?
SH
  chmod +x "$delayed_terminal_driver"
  DELAYED_MARKER="$delayed_marker" DELAYED_HELPER_PID_FILE="$delayed_helper_pid_file" \
    run_with_lock_env script -qefc "$delayed_terminal_driver" /dev/null >"$test_tmp/delayed-terminal.out" 2>&1 &
  delayed_terminal_driver_pid=$!
  for _ in {1..100}; do
    [[ -s $delayed_marker && -s $delayed_helper_pid_file ]] && break
    sleep 0.02
  done
  [[ -s $delayed_marker && -s $delayed_helper_pid_file ]] || fail "terminal cancellation reaches the delayed launch window"
  kill -TERM "$(<"$delayed_helper_pid_file")"
  wait "$delayed_terminal_driver_pid" || true
  delayed_inhibitor_pid=$(<"$delayed_marker")
  wait_for_process_exit "$delayed_inhibitor_pid" || fail "terminal cancellation leaves no delayed inhibitor"
  [[ ! -e $runtime_dir/$stay_awake_dir_name ]] || fail "terminal cancellation leaves no launch state"
  pass "terminal cancellation rolls back delayed publication"

  # With redirected stdin the same helper takes the graphical pkexec branch.
  : >"$delayed_marker"
  delayed_graphical_helper_pid_file="$test_tmp/delayed-graphical-helper-pid"
  delayed_graphical_driver="$test_tmp/delayed-graphical-stay-awake"
  cat >"$delayed_graphical_driver" <<'SH'
#!/bin/bash
echo "$$" >"$DELAYED_HELPER_PID_FILE"
exec omarchy-update-stay-awake start </dev/null
SH
  chmod +x "$delayed_graphical_driver"
  DELAYED_MARKER="$delayed_marker" DELAYED_HELPER_PID_FILE="$delayed_graphical_helper_pid_file" \
    run_with_lock_env "$delayed_graphical_driver" >"$test_tmp/delayed-graphical.out" 2>&1 &
  delayed_graphical_driver_pid=$!
  for _ in {1..100}; do
    [[ -s $delayed_marker && -s $delayed_graphical_helper_pid_file ]] && break
    sleep 0.02
  done
  [[ -s $delayed_marker && -s $delayed_graphical_helper_pid_file ]] || fail "graphical cancellation reaches the delayed launch window"
  delayed_graphical_helper_pid=$(<"$delayed_graphical_helper_pid_file")
  kill -TERM "$delayed_graphical_helper_pid"
  wait "$delayed_graphical_driver_pid" || true
  delayed_inhibitor_pid=$(<"$delayed_marker")
  wait_for_process_exit "$delayed_inhibitor_pid" || fail "graphical cancellation leaves no delayed inhibitor"
  [[ ! -e $runtime_dir/$stay_awake_dir_name ]] || fail "graphical cancellation leaves no launch state"
  pass "graphical cancellation rolls back delayed publication"
  write_stub systemd-inhibit 'while [[ $1 == --* ]]; do shift; done; exec "$@"'
fi

# Update-owned Stay Awake state must be cleared before the restart helper can
# reboot the machine, rather than relying on an EXIT trap during shutdown.
write_stub omarchy-snapshot 'exit 0'
write_stub omarchy-update-keyring 'exit 0'
write_stub omarchy-toggle-idle '
state_file="$SUDO_TEST_HOME/.local/state/omarchy/indicators/stay-awake"
case "$1" in
  stay-awake)
    mkdir -p "$(dirname "$state_file")"
    touch "$state_file"
    ;;
  allow-idle)
    rm -f "$state_file"
    ;;
esac'
write_stub omarchy-update-restart '
state_file="$SUDO_TEST_HOME/.local/state/omarchy/indicators/stay-awake"
if [[ ${1:-} == "--services-only" || ${EXPECT_STAY_AWAKE:-0} == "1" ]]; then
  [[ -f $state_file ]]
else
  [[ ! -f $state_file ]]
fi'

rm -f "$test_home/.local/state/omarchy/indicators/stay-awake"
OMARCHY_UPDATE_LOGGED=1 run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update" -y
[[ ! -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "update clears its Stay Awake state before restart handling"

mkdir -p "$test_home/.local/state/omarchy/indicators"
touch "$test_home/.local/state/omarchy/indicators/stay-awake"
OMARCHY_UPDATE_LOGGED=1 EXPECT_STAY_AWAKE=1 run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update" -y
[[ -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "update preserves pre-existing Stay Awake state"
pass "omarchy-update restores only its own Stay Awake state before restart handling"

# Model package replacement while the existing updater is still running:
# start writes the old two-field state; the transaction installs the real new
# helper, whose stop must clean that state before reboot handling.
cp "$stub_bin/omarchy-update-stay-awake" "$test_tmp/inhibitor-after-upgrade"
write_stub omarchy-update-stay-awake '
set -e
[[ $1 == "start" ]]
umask 022
state="$XDG_RUNTIME_DIR/$LEGACY_STATE_NAME"
mkdir -p "$state" "$SUDO_TEST_HOME/.local/state/omarchy/indicators"
( exec {OMARCHY_UPDATE_LOCK_FD}>&-; exec sleep infinity ) &
pid=$!
printf "%s %s\n" "$pid" "$(awk '\''{ print $22 }'\'' /proc/$pid/stat)" >"$state/inhibit-pid"
printf "%s:1:1\n" "$$" >"$state/idle-owner"
/usr/bin/cp "$state/idle-owner" "$SUDO_TEST_HOME/.local/state/omarchy/indicators/stay-awake"'
write_stub omarchy-update-system-pkgs '
/usr/bin/cp "$INHIBITOR_AFTER_UPGRADE" "$OMARCHY_PATH/bin/omarchy-update-stay-awake"'
write_stub omarchy-update-restart '
if [[ $1 == "--reboot-only" ]]; then
  [[ ! -e $SUDO_TEST_HOME/.local/state/omarchy/indicators/stay-awake ]] || exit 91
  [[ ! -e $XDG_RUNTIME_DIR/$LEGACY_STATE_NAME ]] || exit 92
  touch "$UPGRADE_RESTARTED"
fi'
rm -f "$test_home/.local/state/omarchy/indicators/stay-awake"
OMARCHY_UPDATE_LOGGED=1 LEGACY_STATE_NAME="$stay_awake_dir_name" \
  INHIBITOR_AFTER_UPGRADE="$test_tmp/inhibitor-after-upgrade" \
  UPGRADE_RESTARTED="$test_tmp/upgrade-restarted" \
  run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update" -y
[[ -e $test_tmp/upgrade-restarted ]] || fail "first upgrade did not reach reboot handling"
pass "first upgrade cleans old inhibitor state with the newly installed helper"

# Stale cleanup state from a killed update must not override a Stay Awake choice
# the user made afterward.
stay_awake_helper_state="$runtime_dir/$stay_awake_dir_name"
stay_awake_state="$test_home/.local/state/omarchy/indicators/stay-awake"
mkdir -m 700 -p "$stay_awake_helper_state"
mkdir -p "$(dirname "$stay_awake_state")"
printf '%s\n' "123:456:789" >"$stay_awake_helper_state/idle-owner"
chmod 600 "$stay_awake_helper_state/idle-owner"
printf '%s\n' "user-choice" >"$stay_awake_state"

run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake" stop
[[ $(<"$stay_awake_state") == "user-choice" ]] ||
  fail "stale update ownership does not remove a newer Stay Awake choice"
pass "stale update ownership preserves a newer Stay Awake choice"

# A stale PID is safe even if it has been reused by another process.
sleep 30 >/dev/null &
unrelated_pid=$!
unrelated_start_time=$(awk '{ print $22 }' "/proc/$unrelated_pid/stat")
mkdir -m 700 -p "$stay_awake_helper_state"
printf '1 %s %s %s %032x\n' "$unrelated_pid" "$((unrelated_start_time + 1))" "$(id -u)" 1 >"$stay_awake_helper_state/inhibit-pid"
chmod 600 "$stay_awake_helper_state/inhibit-pid"

run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake" stop
kill -0 "$unrelated_pid" 2>/dev/null ||
  fail "stale inhibitor state does not terminate a reused PID"
kill "$unrelated_pid"
wait "$unrelated_pid" 2>/dev/null || true
pass "stale inhibitor state does not terminate a reused PID"

# The hidden helper also establishes its own boundary when invoked directly.
reset_boundary
touch "$SUDO_TEST_CACHE"
run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake" stop
[[ $(head -1 "$SUDO_TEST_LOG") == "sudo -k" ]] || fail "standalone inhibitor cleanup did not start cold"
assert_boundary_cold "standalone inhibitor cleanup"
pass "standalone inhibitor cleanup revokes before and after session work"

reset_boundary
export SUDO_TEST_REVOKE_FAIL=1
if run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake" start; then
  fail "inhibitor started after failed initial revocation"
fi
[[ ! -e $stay_awake_helper_state/inhibit-pid ]] || fail "failed revocation started an inhibitor"
pass "failed initial revocation prevents standalone inhibition"

# Updates and administrators' migrations share one lock for the whole machine,
# so two administrators never run them at once. An account that can't read
# that lock, or a machine that hasn't created it yet, locks only itself.
machine_dir="$test_tmp/machine-lock"
lock_bin="$machine_dir/bin"
machine_lock="$machine_dir/machine.lock"
holder=""
mkdir -p "$lock_bin" "$machine_dir/run-a" "$machine_dir/run-b"

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
  XDG_RUNTIME_DIR="$machine_dir/run-$account" PATH="$lock_bin:$PATH" "$@"
}

hold_lock() { # a|b
  rm -f "$machine_dir/held" "$machine_dir/release"
  as_account "$1" omarchy-update-lock run bash -c ': >"$1"; until [[ -e $2 || ! -d ${2%/*} ]]; do sleep 0.05; done' _ \
    "$machine_dir/held" "$machine_dir/release" &
  holder=$!
  for _ in {1..100}; do
    [[ -e $machine_dir/held ]] && return 0
    sleep 0.05
  done
  fail "a lock holder starts"
}

release_lock() {
  touch "$machine_dir/release"
  wait "$holder" || true
  holder=""
}

# Root's file on a real machine, which an administrator can only read.
make_machine_lock() {
  rm -f "$machine_lock"
  : >"$machine_lock"
  chmod 444 "$machine_lock"
}

mkdir -p "$machine_dir/omarchy/migrations"
printf 'echo ran >>"$TEST_CALLS"\n' >"$machine_dir/omarchy/migrations/100-step.sh"
migrate_as() { # a|b [COMMAND...]: run omarchy-migrate as that account, inside COMMAND if given
  local account=$1
  shift
  rm -rf "$machine_dir/state-$account" "$machine_dir/calls-$account"
  as_account "$account" env OMARCHY_PATH="$machine_dir/omarchy" OMARCHY_MIGRATION_STATE="$machine_dir/state-$account" OMARCHY_MIGRATION_RECORD="$machine_dir/no-record" \
    TEST_CALLS="$machine_dir/calls-$account" "$@" "$ROOT/bin/omarchy-migrate"
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
migrate_as a omarchy-update-lock run bash -c ': >"$1"; chmod 444 "$1"; exec "$2"' _ "$machine_lock" >/dev/null ||
  fail "an update from before the machine-wide lock still runs its migrations once the lock appears"
[[ $(cat "$machine_dir/calls-a") == "ran" ]] || fail "that update's migration ran once"
pass "an update that started before the machine-wide lock existed runs its migrations and keeps out its account's next run"

# Its migrations carry it onto the machine-wide lock for the rest of it, so
# another account's update waits until it ends, though it holds its own alone.
rm -f "$machine_lock" "$machine_dir/held" "$machine_dir/release"
as_account a env OMARCHY_PATH="$machine_dir/omarchy" OMARCHY_MIGRATION_STATE="$machine_dir/state-carry" \
  OMARCHY_MIGRATION_RECORD="$machine_dir/no-record" TEST_CALLS="$machine_dir/calls-carry" \
  omarchy-update-lock run bash -c ': >"$3"; chmod 444 "$3"; "$4" >/dev/null; : >"$1"; until [[ -e $2 || ! -d ${2%/*} ]]; do sleep 0.05; done' _ \
  "$machine_dir/held" "$machine_dir/release" "$machine_lock" "$ROOT/bin/omarchy-migrate" &
holder=$!
for _ in {1..100}; do
  [[ -e $machine_dir/held ]] && break
  sleep 0.05
done
refused b || fail "another account's update waits for the update that installs the machine-wide lock"
release_lock
for _ in {1..100}; do
  as_account b omarchy-update-lock run true 2>/dev/null && break
  sleep 0.05
done
as_account b omarchy-update-lock run true || fail "the machine-wide lock is free once that update ends"
pass "the update that installs the machine-wide lock holds it until it ends"

# The lock can also come from one of that update's migrations, which carries
# the update onto it before the next migration runs.
mkdir -p "$machine_dir/installs/migrations"
printf ': >"$TEST_LOCK"; chmod 444 "$TEST_LOCK"\n' >"$machine_dir/installs/migrations/100-lock.sh"
printf 'if flock -n "$TEST_LOCK" true; then echo free; else echo held; fi >>"$TEST_CALLS"\n' >"$machine_dir/installs/migrations/200-next.sh"
rm -f "$machine_lock"
as_account a env OMARCHY_PATH="$machine_dir/installs" OMARCHY_MIGRATION_STATE="$machine_dir/state-installs" \
  OMARCHY_MIGRATION_RECORD="$machine_dir/no-record" TEST_CALLS="$machine_dir/calls-installs" TEST_LOCK="$machine_lock" \
  omarchy-update-lock run "$ROOT/bin/omarchy-migrate" >/dev/null || fail "an update whose migration creates the machine-wide lock runs its migrations"
[[ $(cat "$machine_dir/calls-installs") == "held" ]] || fail "the migration after the one that creates the machine-wide lock runs with it held"
for _ in {1..100}; do
  as_account b omarchy-update-lock run true 2>/dev/null && break
  sleep 0.05
done
pass "an update carries onto the machine-wide lock right after the migration that creates it"

# If another account's update holds the machine-wide lock by then, that
# update's migrations stop rather than run alongside it.
rm -f "$machine_lock" "$machine_dir/go" "$machine_dir/a-started" "$machine_dir/a-result"
as_account a env OMARCHY_PATH="$machine_dir/omarchy" OMARCHY_MIGRATION_STATE="$machine_dir/state-contended" \
  OMARCHY_MIGRATION_RECORD="$machine_dir/no-record" TEST_CALLS="$machine_dir/calls-contended" \
  omarchy-update-lock run bash -c ': >"$1"; until [[ -e $2 || ! -d ${2%/*} ]]; do sleep 0.05; done; "$4" >"$3" 2>&1; echo "rc=$?" >>"$3"' _ \
  "$machine_dir/a-started" "$machine_dir/go" "$machine_dir/a-result" "$ROOT/bin/omarchy-migrate" &
installing=$!
for _ in {1..100}; do
  [[ -e $machine_dir/a-started ]] && break
  sleep 0.05
done
make_machine_lock
hold_lock b
touch "$machine_dir/go"
wait "$installing" || true
grep -q "already running" "$machine_dir/a-result" && grep -qx "rc=1" "$machine_dir/a-result" ||
  fail "the installing update's migrations stop while another account's update holds the machine-wide lock" "$(cat "$machine_dir/a-result")"
release_lock
pass "the installing update's migrations stop while another account's update holds the machine-wide lock"

# omarchy-migrate takes the same lock for an administrator: not while another
# account's update or migration holds it, and as usual inside an update, which
# already holds it. Other accounts' migrations lock nothing.
make_machine_lock

hold_lock a
if out=$(migrate_as b 2>&1); then fail "a migration waits while another account's update runs"; fi
[[ $out == *"already running"* && ! -e $machine_dir/calls-b && ! -e $machine_dir/state-b/100-step.sh ]] ||
  fail "a migration held up by another account's update runs nothing and stays pending" "$out"
release_lock
migrate_as b >/dev/null || fail "the migration runs once the lock is free"
[[ $(cat "$machine_dir/calls-b") == "ran" && -e $machine_dir/state-b/100-step.sh ]] || fail "the migration ran once and is marked done"
migrate_as a omarchy-update-lock run >/dev/null || fail "a migration runs inside an update that holds the lock"
[[ $(cat "$machine_dir/calls-a") == "ran" ]] || fail "inside an update the migration runs once"
if (( EUID != 0 )); then
  chmod 000 "$machine_lock"
  hold_lock b
  migrate_as b >/dev/null || fail "an account that can't read the machine-wide lock migrates without taking any lock"
  [[ $(cat "$machine_dir/calls-b") == "ran" ]] || fail "that account's migration ran"
  release_lock
  chmod 444 "$machine_lock"
fi
pass "omarchy-migrate takes the same lock for an administrator, runs as usual inside an update, and locks nothing for other accounts"
