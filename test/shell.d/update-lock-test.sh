#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
test_tmp="$boundary_tmp"
stub_bin="$SUDO_TEST_ROOT/bin"
test_home="$SUDO_TEST_HOME"
runtime_dir="$test_tmp/runtime"
mkdir -p "$runtime_dir"
for command in omarchy-update omarchy-update-lock omarchy-update-stay-awake; do
  rm -f "$SUDO_TEST_ROOT/bin/$command"
  copy_boundary_file "bin/$command"
done
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
  omarchy-hook \
  omarchy-update-analyze-logs \
  omarchy-shell \
  omarchy-update-restart; do
  write_stub "$command" 'exit 0'
done
write_stub omarchy-update-available 'exit 1'
write_stub pkexec 'exec "$@"'
write_stub systemd-inhibit 'while [[ $1 == --* ]]; do shift; done; exec "$@"'
ln -s ../bin/systemd-inhibit "$SUDO_TEST_ROOT/mock/systemd-inhibit"

# omarchy-update should hold the lock before snapshotting, so a second update
# cannot even enter its pre-update snapshot.
update_snapshot_marker="$test_tmp/update-snapshot-started"
write_stub omarchy-snapshot 'echo started >"$TEST_MARKER"; sleep 2; exit 0'

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
write_stub omarchy-update-keyring 'echo started >"$TEST_MARKER"; sleep 3; exit 0'

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

lock_target=$(readlink -f "$runtime_dir/omarchy-update.lock")
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
[[ -s $XDG_RUNTIME_DIR/omarchy-update-stay-awake/inhibit-pid ]]
omarchy-update-stay-awake stop
[[ ! -e $XDG_RUNTIME_DIR/omarchy-update-stay-awake/inhibit-pid ]]
SH
  chmod +x "$terminal_driver"

  SUDO_LOG="$sudo_log" PKEXEC_MARKER="$pkexec_marker" INHIBIT_PID_FILE="$terminal_inhibit_pid_file" \
    run_with_lock_env script -qefc "$terminal_driver" /dev/null >/dev/null

  grep -q -- '^sudo -N -b -- ' "$sudo_log" || fail "terminal inhibition authenticates its background command without a reusable timestamp"
  [[ ! -e $pkexec_marker ]] || fail "terminal sleep inhibition does not use pkexec"
  run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake" stop
  pass "terminal updates use sudo instead of Polkit for sleep inhibition"
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

# Stale cleanup state from a killed update must not override a Stay Awake choice
# the user made afterward.
stay_awake_helper_state="$runtime_dir/omarchy-update-stay-awake"
stay_awake_state="$test_home/.local/state/omarchy/indicators/stay-awake"
mkdir -p "$stay_awake_helper_state" "$(dirname "$stay_awake_state")"
printf '%s\n' "old-update-owner" >"$stay_awake_helper_state/idle-owner"
printf '%s\n' "user-choice" >"$stay_awake_state"

run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake" stop
[[ $(<"$stay_awake_state") == "user-choice" ]] ||
  fail "stale update ownership does not remove a newer Stay Awake choice"
pass "stale update ownership preserves a newer Stay Awake choice"

# A stale PID is safe even if it has been reused by another process.
sleep 30 &
unrelated_pid=$!
unrelated_start_time=$(awk '{ print $22 }' "/proc/$unrelated_pid/stat")
mkdir -p "$stay_awake_helper_state"
printf '%s %s\n' "$unrelated_pid" "$((unrelated_start_time + 1))" >"$stay_awake_helper_state/inhibit-pid"

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
