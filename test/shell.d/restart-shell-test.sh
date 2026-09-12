#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
restart_pid_one=""
restart_pid_two=""
restart_probe_pid=""

cleanup() {
  [[ -n $restart_pid_one ]] && kill "$restart_pid_one" 2>/dev/null || true
  [[ -n $restart_pid_two ]] && kill "$restart_pid_two" 2>/dev/null || true
  [[ -n $restart_probe_pid ]] && kill "$restart_probe_pid" 2>/dev/null || true
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
touch "$restart_root/shell/shell.qml"
ln -s "$ROOT/bin/omarchy-shell" "$restart_bin/omarchy-shell"
ln -s "$ROOT/bin/omarchy-launch-shell" "$restart_bin/omarchy-launch-shell"
ln -s "$ROOT/bin/omarchy-cmd-missing" "$restart_bin/omarchy-cmd-missing"
ln -s "$ROOT/bin/omarchy-hyprland-session-locked" "$restart_bin/omarchy-hyprland-session-locked"

cat >"$restart_bin/qs" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$OMARCHY_TEST_IPC_LOG"

case "$*" in
  *'shell ping')
    [[ ${OMARCHY_TEST_QS_HANG:-0} == 1 ]] && { sleep 5; exit 0; }
    [[ $* == *"-p $OMARCHY_TEST_SESSION_PATH/shell"* ]] &&
      grep -Fx '303' "$OMARCHY_TEST_QS_STATE" >/dev/null &&
      printf 'ok\n'
    ;;
  *'lock lock')
    rm -f "$OMARCHY_TEST_QS_STATE.stranded"
    touch "$OMARCHY_TEST_QS_STATE.locked"
    printf 'ok\n'
    ;;
  *'lock status')
    if [[ ${OMARCHY_TEST_LOCK_STATUS:-} == "failed" ]]; then
      exit 1
    elif [[ ${OMARCHY_TEST_LOCK_STATUS:-} == "failed-until-lock" && ! -f $OMARCHY_TEST_QS_STATE.locked ]]; then
      exit 1
    elif [[ ${OMARCHY_TEST_LOCK_STATUS:-} == "malformed" ]]; then
      printf '{"sessionLocked":"unknown"}\n'
    elif [[ -f $OMARCHY_TEST_QS_STATE.locked ]]; then
      printf '{"sessionLocked": true, "secure": true, "requested": true}\n'
    elif [[ -f $OMARCHY_TEST_QS_STATE.stranded ]]; then
      printf '{"sessionLocked": false, "secure": true, "requested": true}\n'
    else
      printf '{"sessionLocked": false, "secure": false, "requested": false}\n'
    fi
    ;;
esac
SH

cat >"$restart_bin/quickshell" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$OMARCHY_TEST_QS_LOG"

case " $* " in
  *' list --all -j '*)
    [[ ${LC_ALL:-} == "C" ]] || exit 88
    if [[ ${OMARCHY_TEST_QS_LIST_INVALID:-0} == 1 ]]; then
      printf 'not-json\n'
      exit 0
    fi
    if [[ -f $OMARCHY_TEST_QS_STATE.delayed-exit ]]; then
      count=0
      read -r count <"$OMARCHY_TEST_QS_STATE.delayed-exit"
      count=$((count + 1))
      if (( count >= 3 )); then
        pid=$(head -n 1 "$OMARCHY_TEST_QS_STATE")
        [[ ! $pid =~ ^[0-9]+$ ]] || kill "$pid" 2>/dev/null || true
        : >"$OMARCHY_TEST_QS_STATE"
        rm -f "$OMARCHY_TEST_QS_STATE.delayed-exit"
      else
        printf '%s\n' "$count" >"$OMARCHY_TEST_QS_STATE.delayed-exit"
      fi
    fi
    if [[ -n ${OMARCHY_TEST_QS_LIST_COUNT:-} ]]; then
      count=0
      [[ ! -s $OMARCHY_TEST_QS_LIST_COUNT ]] || read -r count <"$OMARCHY_TEST_QS_LIST_COUNT"
      count=$((count + 1))
      printf '%s\n' "$count" >"$OMARCHY_TEST_QS_LIST_COUNT"
      if [[ -n ${OMARCHY_TEST_QS_LIST_HANG_AFTER:-} ]] &&
        (( count > OMARCHY_TEST_QS_LIST_HANG_AFTER )); then
        sleep 5
        exit 0
      fi
    fi
    if [[ ${OMARCHY_TEST_QS_LIVE:-1} == 1 && -s $OMARCHY_TEST_QS_STATE ]]; then
      printf '[{"config_path":"%s/shell/shell.qml","pid":303}]\n' "$OMARCHY_TEST_SESSION_PATH"
    else
      # Captured from native `quickshell list --all -j` with an empty registry.
      printf 'No running instances.\n'
    fi
    ;;
  *' kill -p '*)
    if [[ ${OMARCHY_TEST_QS_KILL_HANG_AFTER:-0} == 1 ]]; then
      printf '0\n' >"$OMARCHY_TEST_QS_STATE.delayed-exit"
      sleep 10
      exit 0
    fi
    [[ ${OMARCHY_TEST_QS_KILL_HANG:-0} == 1 ]] && { sleep 10; exit 0; }
    pid=$(head -n 1 "$OMARCHY_TEST_QS_STATE")
    [[ $pid =~ ^[0-9]+$ ]] || exit 1
    kill "$pid" 2>/dev/null
    while kill -0 "$pid" 2>/dev/null; do sleep 0.01; done
    awk 'NR > 1' "$OMARCHY_TEST_QS_STATE" >"$OMARCHY_TEST_QS_STATE.next"
    mv "$OMARCHY_TEST_QS_STATE.next" "$OMARCHY_TEST_QS_STATE"
    ;;
  *' -n -p '*)
    printf '%s\n' "${OMARCHY_TEST_TRANSIENT_ENV-unset}" >"$OMARCHY_TEST_QS_ENV_LOG"
    printf '303\n' >"$OMARCHY_TEST_QS_STATE"
    ;;
esac
SH

cat >"$restart_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ ${1:-} == "-j" && ${2:-} == "monitors" ]]; then
  case ${OMARCHY_TEST_HYPR_MODE:-ok} in
    unreachable) exit 1 ;;
    malformed) printf 'not-json\n'; exit 0 ;;
    empty) printf '[]\n'; exit 0 ;;
    workspace-only) printf '[{"name":"eDP-1","solitaryBlockedBy":["WORKSPACE"]}]\n'; exit 0 ;;
    hang) sleep 5; exit 0 ;;
  esac
  # Hyprland reports an active session lock as a reason the monitor cannot hand
  # a client the whole screen, not as a workspace.
  if [[ ${OMARCHY_TEST_SESSION_LOCKED:-0} == 1 ]]; then
    printf '[{"name":"eDP-1","solitaryBlockedBy":["WINDOWED","LOCK","CANDIDATE"]}]\n'
  else
    printf '[{"name":"eDP-1","solitaryBlockedBy":["WINDOWED","CANDIDATE"]}]\n'
  fi
elif [[ ${1:-} == "dispatch" && ${2:-} == hl.dsp.exec_cmd* ]]; then
  printf '%s\n' "${2:-}" >>"$OMARCHY_TEST_DISPATCH_LOG"
  if [[ -n ${OMARCHY_TEST_DISPATCH_COUNT:-} ]]; then
    count=0
    [[ ! -s $OMARCHY_TEST_DISPATCH_COUNT ]] || read -r count <"$OMARCHY_TEST_DISPATCH_COUNT"
    count=$((count + 1))
    printf '%s\n' "$count" >"$OMARCHY_TEST_DISPATCH_COUNT"
  fi
  if [[ ${OMARCHY_TEST_DISPATCH_MODE:-ok} == hang-before-once && ${count:-0} == 1 ]]; then
    sleep 5
    exit 0
  fi
  OMARCHY_PATH="$OMARCHY_TEST_SESSION_PATH" \
    env -u OMARCHY_TEST_TRANSIENT_ENV omarchy-launch-shell
  if [[ ${OMARCHY_TEST_DISPATCH_MODE:-ok} == hang-after-launch ]]; then
    sleep 5
  fi
  printf 'ok\n'
elif [[ ${1:-} == "dispatch" ]]; then
  exit 1
fi
SH

# Keep the test hermetic where journald has no usable stream socket.
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

cat >"$restart_bin/busctl" <<'SH'
#!/bin/bash
if [[ -z ${OMARCHY_TEST_NOTIFICATION_CHECKS:-} ]]; then
  echo 'b false'
else
  checks=0
  [[ ! -f $OMARCHY_TEST_NOTIFICATION_CHECKS ]] || read -r checks <"$OMARCHY_TEST_NOTIFICATION_CHECKS"
  (( checks += 1 ))
  printf '%s\n' "$checks" >"$OMARCHY_TEST_NOTIFICATION_CHECKS"
  if (( checks == 1 || checks >= 4 )); then
    echo 'b true'
  else
    echo 'b false'
  fi
fi
SH

chmod +x "$restart_bin/qs" "$restart_bin/quickshell" "$restart_bin/hyprctl" "$restart_bin/systemd-cat" "$restart_bin/systemctl" "$restart_bin/busctl"

sleep 30 &
restart_pid_one=$!
sleep 30 &
restart_pid_two=$!
printf '%s\n%s\n' "$restart_pid_one" "$restart_pid_two" >"$restart_state"

caller_root="$test_tmp/caller-root"
mkdir -p "$caller_root/shell"
touch "$caller_root/shell/shell.qml"

PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$caller_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$restart_root" \
OMARCHY_TEST_TRANSIENT_ENV=leaked \
OMARCHY_TEST_NOTIFICATION_CHECKS="$test_tmp/notification-checks" \
  timeout 5 "$ROOT/bin/omarchy-restart-shell"

if kill -0 "$restart_pid_one" 2>/dev/null; then
  fail "restart stops the first matching shell instance"
fi
if kill -0 "$restart_pid_two" 2>/dev/null; then
  fail "restart stops duplicate matching shell instances"
fi
wait "$restart_pid_one" 2>/dev/null || true
wait "$restart_pid_two" 2>/dev/null || true
restart_pid_one=""
restart_pid_two=""
[[ $(<"$restart_state") == 303 ]] || fail "restart leaves exactly one fresh shell instance"
[[ $(grep -c '^-n -p ' "$restart_log") == 1 ]] || fail "restart launches one fresh shell process"
grep -F "kill -p $restart_root/shell --any-display" "$restart_log" >/dev/null || fail "restart stops the shell from the session checkout"
[[ $(<"$restart_env_log") == "unset" ]] || fail "restart uses the Hyprland session environment for the fresh shell"
grep -F 'hl.dsp.exec_cmd("omarchy-launch-shell")' "$dispatch_log" >/dev/null || fail "restart launches the fresh shell through Hyprland"
grep -F "ipc -n -p $restart_root/shell call -- shell ping" "$ipc_log" >/dev/null || fail "restart checks readiness in the session checkout"
pass "restart replaces duplicate shell instances from the session checkout"
pass "restart accepts Quickshell's native empty-registry response during ordinary restart"
[[ $(<"$test_tmp/notification-checks") == 4 ]] || fail "restart waits for the existing notification service after core IPC is ready"
pass "restart waits for notification readiness before one-time update hooks"

: >"$restart_log"
printf '303\n' >"$restart_state"
touch "$restart_state.locked"

locked_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_SESSION_LOCKED=1 \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  "$ROOT/bin/omarchy-restart-shell" 2>&1) && fail "restart refuses while the shell lock is active"

[[ $locked_error == "Refusing to restart Omarchy shell while the session is locked." ]] || fail "locked restart explains why it was refused" "$locked_error"
[[ $(<"$restart_state") == 303 ]] || fail "locked restart preserves the running shell"
[[ ! -s $restart_log ]] || fail "locked restart does not stop or launch Quickshell"
pass "restart preserves the shell while its lock is active"

for status_mode in failed malformed; do
  : >"$restart_log"
  unknown_error=$(PATH="$restart_bin:$PATH" \
    OMARCHY_PATH="$restart_root" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    OMARCHY_TEST_SESSION_LOCKED=1 \
    OMARCHY_TEST_LOCK_STATUS="$status_mode" \
    OMARCHY_TEST_QS_STATE="$restart_state" \
    OMARCHY_TEST_QS_LOG="$restart_log" \
    OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
    OMARCHY_TEST_IPC_LOG="$ipc_log" \
    OMARCHY_TEST_SESSION_PATH="$restart_root" \
    "$ROOT/bin/omarchy-restart-shell" 2>&1) &&
    fail "restart accepts an indeterminate $status_mode lock status"
  [[ $unknown_error == "Could not determine whether the running shell owns the session lock; refusing to restart." ]] ||
    fail "indeterminate lock status lacks a fail-closed diagnostic" "$unknown_error"
  [[ $(<"$restart_state") == 303 ]] || fail "indeterminate lock status kills the running shell"
  ! grep -Eq '(^| )kill -p |(^| )-n -p ' "$restart_log" || fail "indeterminate lock status starts a shell restart"
done
pass "restart fails closed when lock ownership status is unavailable or malformed"

for hypr_mode in unreachable malformed empty workspace-only; do
  : >"$restart_log"
  unknown_error=$(PATH="$restart_bin:$PATH" \
    OMARCHY_PATH="$restart_root" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    OMARCHY_TEST_HYPR_MODE="$hypr_mode" \
    OMARCHY_TEST_QS_STATE="$restart_state" \
    OMARCHY_TEST_QS_LOG="$restart_log" \
    OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
    OMARCHY_TEST_IPC_LOG="$ipc_log" \
    OMARCHY_TEST_SESSION_PATH="$restart_root" \
    "$ROOT/bin/omarchy-restart-shell" 2>&1) &&
    fail "restart accepts an undetermined compositor state ($hypr_mode)"
  [[ $unknown_error == "Could not determine the compositor session-lock state; refusing to restart." ]] ||
    fail "undetermined compositor state lacks a fail-closed diagnostic" "$unknown_error"
  [[ $(<"$restart_state") == 303 ]] || fail "undetermined compositor state kills the running shell"
  [[ ! -s $restart_log ]] || fail "undetermined compositor state launches a shell"
done
pass "restart distinguishes unlocked from every undetermined compositor answer"

# A LOCK session without an active locker — dead shell or a crash-handler
# relaunch holding no lock — is the failsafe: restart must proceed,
# re-acquire the session lock, and wait for it to report secure.
sleep 30 &
restart_pid_one=$!
printf '%s\n' "$restart_pid_one" >"$restart_state"
rm -f "$restart_state.locked"
touch "$restart_state.stranded"
: >"$restart_log"
: >"$ipc_log"

PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$restart_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_SESSION_LOCKED=1 \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$restart_root" \
  timeout 5 "$ROOT/bin/omarchy-restart-shell" || fail "locked restart recovers when the lock client is dead"

if kill -0 "$restart_pid_one" 2>/dev/null; then
  fail "dead-lock recovery stops the stale shell instance"
fi
wait "$restart_pid_one" 2>/dev/null || true
restart_pid_one=""
[[ $(<"$restart_state") == 303 ]] || fail "dead-lock recovery leaves one fresh shell instance"
grep -F "ipc -n -p $restart_root/shell call -- lock lock" "$ipc_log" >/dev/null || fail "dead-lock recovery re-acquires the session lock"
grep -F "ipc -n -p $restart_root/shell call -- lock status" "$ipc_log" >/dev/null || fail "dead-lock recovery waits for the lock to become secure"
pass "restart recovers a locked session whose stale service no longer owns a lock surface"

# A truly dead locker has neither IPC nor a live Quickshell registry entry.
# That is distinct from the failed-IPC live process above and must remain
# recoverable from Hyprland's stranded LOCK failsafe.
: >"$restart_state"
: >"$restart_log"
: >"$ipc_log"
rm -f "$restart_state.locked" "$restart_state.stranded"
PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$restart_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_SESSION_LOCKED=1 \
OMARCHY_TEST_LOCK_STATUS=failed-until-lock \
OMARCHY_TEST_QS_LIVE=0 \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$restart_root" \
  timeout 5 "$ROOT/bin/omarchy-restart-shell" || fail "locked restart recovers a truly dead lock client"
[[ $(<"$restart_state") == 303 ]] || fail "dead-lock recovery launches exactly one fresh shell"
grep -F "list --all -j" "$restart_log" >/dev/null || fail "dead-lock recovery checks the live Quickshell registry"
grep -F "ipc -n -p $restart_root/shell call -- lock lock" "$ipc_log" >/dev/null || fail "dead-lock recovery re-acquires the session lock"
pass "restart distinguishes a dead locker from a live but unreadable one"
pass "cold and locked recovery accept Quickshell's native empty-registry response"

for dispatch_mode in hang-after-launch hang-before-once; do
  sleep 30 &
  restart_pid_one=$!
  printf '%s\n' "$restart_pid_one" >"$restart_state"
  rm -f "$restart_state.locked" "$restart_state.stranded"
  : >"$restart_log"
  : >"$ipc_log"
  : >"$test_tmp/dispatch-count"

  PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_DISPATCH_MODE="$dispatch_mode" \
  OMARCHY_TEST_DISPATCH_COUNT="$test_tmp/dispatch-count" \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" \
  OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
    timeout 8 "$ROOT/bin/omarchy-restart-shell" ||
    fail "$dispatch_mode did not recover a replacement shell"

  if kill -0 "$restart_pid_one" 2>/dev/null; then
    fail "$dispatch_mode left the stale shell running"
  fi
  wait "$restart_pid_one" 2>/dev/null || true
  restart_pid_one=""
  [[ $(<"$restart_state") == 303 ]] ||
    fail "$dispatch_mode did not leave exactly one registered shell"
  [[ $(grep -c '^-n -p ' "$restart_log") == 1 ]] ||
    fail "$dispatch_mode launched duplicate replacement shells" "$(cat "$restart_log")"
done
[[ $(<"$test_tmp/dispatch-count") == 2 ]] ||
  fail "a no-launch timeout was not retried inside the serialized restart"
pass "ambiguous and no-launch dispatch timeouts recover without duplicate shells"

# A persistently unreadable registry must release restart serialization at one
# aggregate deadline, preserve the old process, and permit a later clean retry.
sleep 30 &
restart_pid_one=$!
printf '%s\n' "$restart_pid_one" >"$restart_state"
: >"$restart_log"
: >"$dispatch_log"
set +e
registry_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_RESTART_STOP_TIMEOUT_SECONDS=2 \
  OMARCHY_TEST_QS_LIST_INVALID=1 \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  timeout 5 "$ROOT/bin/omarchy-restart-shell" 2>&1)
registry_status=$?
set -e
(( registry_status == 1 )) || fail "persistent invalid registry state escaped the stop deadline" "$registry_status $registry_error"
[[ $registry_error == "Could not confirm that the existing Omarchy shell stopped before the restart deadline." ]] ||
  fail "persistent invalid registry state lacks its deadline diagnostic" "$registry_error"
kill -0 "$restart_pid_one" 2>/dev/null || fail "an invalid registry answer killed an unconfirmed shell"
[[ ! -s $dispatch_log ]] || fail "an invalid registry answer launched a replacement"

PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$restart_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$restart_root" \
  timeout 5 "$ROOT/bin/omarchy-restart-shell" || fail "a later retry did not acquire released restart ownership"
wait "$restart_pid_one" 2>/dev/null || true
restart_pid_one=""
[[ $(<"$restart_state") == 303 ]] || fail "a later retry did not leave one replacement shell"
pass "persistent registry ambiguity is bounded and a later retry succeeds"

# Cancellation during an ambiguous stop must not kill or replace an
# unconfirmed shell, and its bounded child probe must release serialization.
sleep 30 &
restart_pid_one=$!
printf '%s\n' "$restart_pid_one" >"$restart_state"
: >"$restart_log"
: >"$dispatch_log"
PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$restart_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_QS_LIST_INVALID=1 \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$restart_root" \
  "$ROOT/bin/omarchy-restart-shell" >"$test_tmp/interrupted.out" 2>"$test_tmp/interrupted.err" &
restart_probe_pid=$!
sleep 0.2
kill -TERM "$restart_probe_pid"
set +e
wait "$restart_probe_pid"
interrupted_status=$?
set -e
restart_probe_pid=""
(( interrupted_status == 143 )) || fail "an interrupted ambiguous stop returned the wrong status" "$interrupted_status"
kill -0 "$restart_pid_one" 2>/dev/null || fail "an interrupted ambiguous stop killed the old shell"
[[ ! -s $dispatch_log ]] || fail "an interrupted ambiguous stop launched a replacement"
sleep 1.2

PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$restart_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$restart_root" \
  timeout 5 "$ROOT/bin/omarchy-restart-shell" || fail "a retry after interrupted stop did not acquire restart ownership"
wait "$restart_pid_one" 2>/dev/null || true
restart_pid_one=""
pass "interrupted ambiguous stop preserves the old shell and permits retry"

# A timed-out kill is ambiguous: the old process may still answer ping. It
# must abort the restart instead of accepting that old answer as a replacement.
sleep 30 &
restart_pid_one=$!
printf '%s\n' "$restart_pid_one" >"$restart_state"
: >"$restart_log"
: >"$dispatch_log"
set +e
kill_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_RESTART_STOP_TIMEOUT_SECONDS=2 \
  OMARCHY_TEST_QS_KILL_HANG=1 \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  timeout 5 "$ROOT/bin/omarchy-restart-shell" 2>&1)
kill_status=$?
set -e
(( kill_status == 1 )) || fail "a pre-delivery kill wedge escaped the aggregate stop deadline" "$kill_status $kill_error"
[[ $kill_error == "Could not confirm that the existing Omarchy shell stopped before the restart deadline." ]] ||
  fail "a stop deadline failure lacks its diagnostic" "$kill_error"
kill -0 "$restart_pid_one" 2>/dev/null || fail "a timed-out kill test did not preserve its old shell"
[[ ! -s $dispatch_log ]] || fail "a timed-out kill launched a replacement shell"
kill "$restart_pid_one" 2>/dev/null || true
wait "$restart_pid_one" 2>/dev/null || true
restart_pid_one=""
pass "restart releases bounded ownership when stopping the old shell remains ambiguous"

# Quickshell can deliver the quit request and then time out waiting for the
# server to disconnect. Keep polling after that timeout; once the delayed
# registry removal lands, exactly one replacement must be launched.
sleep 30 &
restart_pid_one=$!
printf '%s\n' "$restart_pid_one" >"$restart_state"
: >"$restart_log"
: >"$dispatch_log"
PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$restart_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_QS_KILL_HANG_AFTER=1 \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$restart_root" \
  timeout 8 "$ROOT/bin/omarchy-restart-shell" ||
  fail "a kill-after-delivery timeout did not recover"
wait "$restart_pid_one" 2>/dev/null || true
restart_pid_one=""
[[ $(<"$restart_state") == 303 ]] || fail "delayed kill recovery left no fresh shell"
[[ $(grep -c '^-n -p ' "$restart_log") == 1 ]] ||
  fail "delayed kill recovery launched duplicate shells" "$(<"$restart_log")"
pass "restart survives a kill timeout after the old shell accepted shutdown"

# IPC ping and registry discovery can wedge together. Their combined latency
# is charged to one deadline rather than multiplying a nominal retry count.
: >"$restart_state"
: >"$restart_log"
: >"$dispatch_log"
: >"$test_tmp/list-count"
start_seconds=$SECONDS
set +e
deadline_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_RESTART_READY_TIMEOUT_SECONDS=2 \
  OMARCHY_TEST_QS_HANG=1 \
  OMARCHY_TEST_QS_LIST_COUNT="$test_tmp/list-count" \
  OMARCHY_TEST_QS_LIST_HANG_AFTER=1 \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  timeout 5 "$ROOT/bin/omarchy-restart-shell" 2>&1)
deadline_status=$?
set -e
elapsed_seconds=$((SECONDS - start_seconds))
(( deadline_status == 1 )) || fail "combined IPC/registry wedges escaped the readiness deadline" "$deadline_status"
[[ $deadline_error == "Omarchy shell did not become ready after restart." ]] ||
  fail "a readiness deadline failure lacks its diagnostic" "$deadline_error"
(( elapsed_seconds < 5 )) || fail "combined IPC/registry wedges held the restart lock too long" "$elapsed_seconds"
[[ ! -s $dispatch_log ]] || fail "an unknown registry state dispatched a replacement shell"
pass "restart uses one absolute deadline across wedged readiness probes"

# Poison recovery is detached and retries, so a wedged compositor probe must
# remain bounded and later attempts must not form concurrent process trees.
: >"$restart_log"
PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$restart_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_HYPR_MODE=hang \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$restart_root" \
  timeout 3 "$ROOT/bin/omarchy-restart-shell" >"$test_tmp/hung.out" 2>"$test_tmp/hung.err" &
restart_probe_pid=$!
sleep 0.1

set +e
PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$restart_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_HYPR_MODE=hang \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$restart_root" \
  timeout 1 "$ROOT/bin/omarchy-restart-shell" >"$test_tmp/concurrent.out" 2>"$test_tmp/concurrent.err"
concurrent_status=$?
wait "$restart_probe_pid"
hung_status=$?
set -e
restart_probe_pid=""

(( concurrent_status == 75 )) ||
  fail "a concurrent poisoned-shell restart was not rejected immediately" "$concurrent_status"
grep -Fxq 'Another Omarchy shell restart is already in progress.' "$test_tmp/concurrent.err" ||
  fail "a serialized shell restart did not explain its refusal"
(( hung_status == 1 )) ||
  fail "a wedged compositor probe escaped its internal bound" "$hung_status"
pass "poisoned-shell retries serialize around a bounded compositor probe"
