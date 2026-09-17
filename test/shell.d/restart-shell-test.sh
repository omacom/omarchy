#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
restart_pid_one=""
restart_pid_two=""

cleanup() {
  [[ -n $restart_pid_one ]] && kill "$restart_pid_one" 2>/dev/null || true
  [[ -n $restart_pid_two ]] && kill "$restart_pid_two" 2>/dev/null || true
  rm -rf "$test_tmp"
}
trap cleanup EXIT

wrapper_root="$test_tmp/wrapper-root"
wrapper_bin="$test_tmp/wrapper-bin"
mkdir -p "$wrapper_root/shell" "$wrapper_bin"
touch "$wrapper_root/shell/shell.qml"

cat >"$wrapper_bin/qs" <<'SH'
#!/bin/bash

[[ -n ${OMARCHY_TEST_QS_ARGS:-} ]] && printf '%s\n' "$*" >"$OMARCHY_TEST_QS_ARGS"

if [[ ${OMARCHY_TEST_QS_HANG:-0} == 1 ]]; then
  sleep 5
elif [[ ${OMARCHY_TEST_QS_STARTING:-0} == 1 ]]; then
  printf 'Not ready to accept queries yet.\n'
else
  printf 'ok\n'
fi
SH
chmod +x "$wrapper_bin/qs"

wrapper_error=$(PATH="$wrapper_bin:$PATH" \
  OMARCHY_PATH="$wrapper_root" \
  OMARCHY_SHELL_IPC_TIMEOUT=0.1s \
  OMARCHY_TEST_QS_HANG=1 \
  "$ROOT/bin/omarchy-shell" shell ping 2>&1) && fail "hung shell IPC returns a failure"
[[ $wrapper_error == "omarchy-shell is not responding" ]] || fail "hung shell IPC reports that the shell is unresponsive" "$wrapper_error"
pass "shell IPC calls time out when Quickshell is unresponsive"

# A starting shell answers on stdout and exits 0, so a ping reads it as up.
wrapper_error=$(PATH="$wrapper_bin:$PATH" \
  OMARCHY_PATH="$wrapper_root" \
  OMARCHY_TEST_QS_STARTING=1 \
  "$ROOT/bin/omarchy-shell" shell ping 2>&1) && fail "a starting shell answers IPC calls with a failure"
[[ $wrapper_error == "omarchy-shell is not ready" ]] || fail "a starting shell reports that it is not ready" "$wrapper_error"
pass "shell IPC calls fail while Quickshell is still starting"

PATH="$wrapper_bin:$PATH" \
OMARCHY_PATH="$wrapper_root" \
OMARCHY_TEST_QS_STARTING=1 \
  "$ROOT/bin/omarchy-shell" -q shell ping >/dev/null 2>&1 ||
  fail "quiet best-effort IPC calls tolerate a starting shell"
pass "quiet best-effort IPC calls tolerate a starting shell"

wrapper_args="$test_tmp/wrapper-args"
PATH="$wrapper_bin:$PATH" \
OMARCHY_PATH="$wrapper_root" \
OMARCHY_TEST_QS_ARGS="$wrapper_args" \
  "$ROOT/bin/omarchy-shell" shell ping >/dev/null

grep -F -- 'ipc -n -p' "$wrapper_args" >/dev/null || fail "shell IPC targets the newest live Quickshell instance"
pass "shell IPC targets the newest live Quickshell instance"

restart_root="$test_tmp/restart-root"
restart_bin="$restart_root/bin"
restart_state="$test_tmp/restart-pids"
restart_log="$test_tmp/restart.log"
restart_env_log="$test_tmp/restart-env.log"
dispatch_log="$test_tmp/dispatch.log"
ipc_log="$test_tmp/ipc.log"
runtime_dir="$test_tmp/runtime"
mkdir -p "$restart_root/shell" "$restart_bin" "$runtime_dir"
touch "$restart_root/shell/shell.qml" "$restart_root/shell/lock.qml"
ln -s "$ROOT/bin/omarchy-shell" "$restart_bin/omarchy-shell"
ln -s "$ROOT/bin/omarchy-launch-shell" "$restart_bin/omarchy-launch-shell"
ln -s "$ROOT/bin/omarchy-hyprland-session-locked" "$restart_bin/omarchy-hyprland-session-locked"

cat >"$restart_bin/qs" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_IPC_LOG"
case "$*" in
  *'shell ping')
    grep -Fx 'fresh' "$OMARCHY_TEST_QS_STATE" >/dev/null || exit 1
    printf 'ok\n'
    ;;
  *'lock lock')
    grep -q '^kill ' "$OMARCHY_TEST_QS_LOG" && exit 1
    touch "$OMARCHY_TEST_QS_STATE.locked"
    printf 'ok\n'
    ;;
  *'lock status')
    if [[ $* != *'/lock.qml '* ]]; then
      if [[ -f $OMARCHY_TEST_QS_STATE.legacy ]]; then
        printf '{"secure": false, "requested": true}\n'
      else
        printf 'Target not found.\n'
      fi
    elif [[ ! -f $OMARCHY_TEST_QS_STATE.locker ]]; then
      exit 1
    elif [[ -f $OMARCHY_TEST_QS_STATE.pending ]]; then
      printf '{"secure": false, "requested": true}\n'
    elif [[ -f $OMARCHY_TEST_QS_STATE.locked ]]; then
      printf '{"secure": true, "requested": true}\n'
    else
      printf '{"secure": false, "requested": false}\n'
    fi
    ;;
esac
SH

cat >"$restart_bin/quickshell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_QS_LOG"
case " $* " in
  *' kill -p '*)
    if [[ $* == *'/lock.qml '* ]]; then
      kill "$OMARCHY_TEST_LOCKER_PID"
      exit 1
    fi
    pid=$(head -n 1 "$OMARCHY_TEST_QS_STATE")
    [[ $pid =~ ^[0-9]+$ ]] || exit 1
    kill "$pid" 2>/dev/null
    while kill -0 "$pid" 2>/dev/null; do sleep 0.01; done
    sed '1d' "$OMARCHY_TEST_QS_STATE" >"$OMARCHY_TEST_QS_STATE.next"
    mv "$OMARCHY_TEST_QS_STATE.next" "$OMARCHY_TEST_QS_STATE"
    ;;
  *' -n -p '*)
    if [[ $* == *'/lock.qml' ]]; then
      touch "$OMARCHY_TEST_QS_STATE.locker"
    else
      printf '%s\n' "${OMARCHY_TEST_TRANSIENT_ENV-unset}" >"$OMARCHY_TEST_QS_ENV_LOG"
      printf 'fresh\n' >"$OMARCHY_TEST_QS_STATE"
    fi
    ;;
esac
SH

cat >"$restart_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ ${1:-} == "-j" && ${2:-} == "monitors" ]]; then
  if [[ ${OMARCHY_TEST_SESSION_LOCKED:-0} == 1 ]]; then
    printf '[{"name":"eDP-1","solitaryBlockedBy":["LOCK"]}]\n'
  else
    printf '[{"name":"eDP-1","solitaryBlockedBy":[]}]\n'
  fi
elif [[ ${1:-} == "dispatch" && ${2:-} == hl.dsp.exec_cmd* ]]; then
  printf '%s\n' "$2" >>"$OMARCHY_TEST_DISPATCH_LOG"
  if [[ $2 == *'--lock'* ]]; then
    env -u OMARCHY_TEST_TRANSIENT_ENV OMARCHY_PATH="$OMARCHY_TEST_SESSION_PATH" omarchy-launch-shell --lock
  else
    env -u OMARCHY_TEST_TRANSIENT_ENV OMARCHY_PATH="$OMARCHY_TEST_SESSION_PATH" omarchy-launch-shell
  fi
  printf 'ok\n'
else
  exit 1
fi
SH

cat >"$restart_bin/systemd-cat" <<'SH'
#!/bin/bash
while (( $# > 0 )); do
  [[ $1 == "--" ]] && { shift; break; }
  shift
done
exec "$@"
SH

cat >"$restart_bin/systemctl" <<'SH'
#!/bin/bash
if [[ ${1:-} == "--user" && ${2:-} == "show-environment" ]]; then
  printf 'OMARCHY_PATH=%s\n' "$OMARCHY_TEST_SESSION_PATH"
elif [[ ${1:-} == "--user" && ${2:-} == "try-restart" ]]; then
  exit 0
else
  exit 1
fi
SH
chmod +x "$restart_bin/qs" "$restart_bin/quickshell" "$restart_bin/hyprctl" "$restart_bin/systemd-cat" "$restart_bin/systemctl"

caller_root="$test_tmp/caller-root"
mkdir -p "$caller_root/shell"
touch "$caller_root/shell/shell.qml"
export PATH="$restart_bin:$PATH"
export OMARCHY_PATH="$caller_root" XDG_RUNTIME_DIR="$runtime_dir"
export OMARCHY_TEST_QS_STATE="$restart_state" OMARCHY_TEST_QS_LOG="$restart_log"
export OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" OMARCHY_TEST_DISPATCH_LOG="$dispatch_log"
export OMARCHY_TEST_IPC_LOG="$ipc_log" OMARCHY_TEST_SESSION_PATH="$restart_root"
export OMARCHY_TEST_TRANSIENT_ENV=leaked

# Stand in for a separate locker with a real process. The kill stub will kill
# it if the restart ever targets its configuration, and the assertion catches it.
sleep 60 &
locker_pid=$!
export OMARCHY_TEST_LOCKER_PID="$locker_pid"
trap 'kill "$locker_pid" 2>/dev/null || true; wait "$locker_pid" 2>/dev/null || true; cleanup' EXIT
sleep 60 &
restart_pid_one=$!
sleep 60 &
restart_pid_two=$!
printf '%s\n%s\n' "$restart_pid_one" "$restart_pid_two" >"$restart_state"
touch "$restart_state.locker" "$restart_state.locked"

OMARCHY_TEST_SESSION_LOCKED=1 timeout 5 "$ROOT/bin/omarchy-restart-shell"
kill -0 "$locker_pid" || fail "the separate locker survives a shell restart while locked"
kill -0 "$restart_pid_one" 2>/dev/null && fail "restart stops the first matching shell instance"
kill -0 "$restart_pid_two" 2>/dev/null && fail "restart stops duplicate matching shell instances"
wait "$restart_pid_one" 2>/dev/null || true
wait "$restart_pid_two" 2>/dev/null || true
restart_pid_one=""
restart_pid_two=""
[[ $(<"$restart_state") == fresh ]] || fail "restart leaves one fresh shell"
[[ $(grep -c '^-n -p ' "$restart_log") == 1 ]] || fail "restart only launches the main shell"
grep -Fx "kill -p $restart_root/shell --any-display" "$restart_log" >/dev/null || fail "restart targets the session checkout"
[[ $(<"$restart_env_log") == unset ]] || fail "restart uses the session environment"
grep -F 'hl.dsp.exec_cmd("omarchy-launch-shell")' "$dispatch_log" >/dev/null || fail "restart launches through Hyprland"
if grep -F 'call -- lock lock' "$ipc_log"; then
  fail "restart does not reset an existing lock or authentication attempt"
fi
pass "restart while locked replaces the shell and preserves the separate locker"

# An older shell may still own the lock after an upgrade. A pending request is
# protected too, before Hyprland reports LOCK on a monitor.
: >"$restart_log"
: >"$dispatch_log"
touch "$restart_state.legacy"
locked_error=$(OMARCHY_TEST_SESSION_LOCKED=0 "$ROOT/bin/omarchy-restart-shell" 2>&1) && fail "restart preserves an integrated locker"
[[ $locked_error == *'integrated locker is active'* ]] || fail "legacy refusal explains how to proceed" "$locked_error"
[[ ! -s $restart_log && ! -s $dispatch_log ]] || fail "legacy refusal stops before changing either process"
kill -0 "$locker_pid" || fail "legacy refusal preserves the separate locker too"
pass "restart preserves a legacy lock, including a pending lock request"
rm "$restart_state.legacy"

# A missing locker is started independently and reclaims an orphaned lock.
rm "$restart_state.locker" "$restart_state.locked"
: >"$ipc_log"
: >"$restart_log"
OMARCHY_TEST_SESSION_LOCKED=1 timeout 5 "$ROOT/bin/omarchy-restart-shell"
grep -F 'hl.dsp.exec_cmd("omarchy-launch-shell --lock")' "$dispatch_log" >/dev/null || fail "restart starts a missing locker through Hyprland"
grep -F "ipc -n -p $restart_root/shell/lock.qml call -- lock lock" "$ipc_log" >/dev/null || fail "recovery requests the separate lock"
[[ -f $restart_state.locked ]] || fail "recovery waits for a secure lock"
kill -0 "$locker_pid" || fail "recovery never kills a separate locker"
pass "restart starts a missing locker and recovers an orphaned session lock"

# An unavailable legacy IPC endpoint is not proof that the old lock is dead.
# The separate process must own the compositor lock before the shell is stopped.
: >"$restart_log"
: >"$dispatch_log"
touch "$restart_state.pending"
waiting_status=0
OMARCHY_TEST_SESSION_LOCKED=1 timeout 1 "$ROOT/bin/omarchy-restart-shell" || waiting_status=$?
[[ $waiting_status == 124 ]] || fail "restart waits for secure lock ownership"
[[ ! -s $restart_log && ! -s $dispatch_log ]] || fail "restart does not change processes while lock ownership is unresolved"
pass "restart preserves the shell while the independent lock is still pending"
rm "$restart_state.pending"

rm "$restart_state.locker" "$restart_state.locked"
: >"$ipc_log"
OMARCHY_TEST_SESSION_LOCKED=0 timeout 5 "$ROOT/bin/omarchy-restart-shell"
grep -F 'hl.dsp.exec_cmd("omarchy-launch-shell --lock")' "$dispatch_log" >/dev/null || fail "unlocked restart starts the independent locker"
if grep -F 'call -- lock lock' "$ipc_log"; then
  fail "an unlocked restart does not lock the session"
fi
pass "unlocked restart starts a missing locker without locking"
