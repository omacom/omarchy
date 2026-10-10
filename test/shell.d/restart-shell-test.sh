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
restart_display_state="$test_tmp/restart-displays"
dispatch_log="$test_tmp/dispatch.log"
ipc_log="$test_tmp/ipc.log"
runtime_dir="$test_tmp/runtime"
mkdir -p "$restart_root/shell" "$restart_bin" "$runtime_dir"
touch "$restart_root/shell/shell.qml"
: >"$restart_display_state"
export OMARCHY_TEST_QS_DISPLAY_STATE="$restart_display_state"
ln -s "$ROOT/bin/omarchy-shell" "$restart_bin/omarchy-shell"
ln -s "$ROOT/bin/omarchy-launch-shell" "$restart_bin/omarchy-launch-shell"
ln -s "$ROOT/bin/omarchy-cmd-missing" "$restart_bin/omarchy-cmd-missing"
ln -s "$ROOT/bin/omarchy-hyprland-session-locked" "$restart_bin/omarchy-hyprland-session-locked"

cat >"$restart_bin/qs" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$OMARCHY_TEST_IPC_LOG"

case "$*" in
  *'shell ping')
    [[ $* == *"-p $OMARCHY_TEST_SESSION_PATH/shell"* ]] &&
      grep -Fx '303' "$OMARCHY_TEST_QS_STATE" >/dev/null &&
      [[ $(awk '$1 == 303 { display = $2 } END { print display }' "$OMARCHY_TEST_QS_DISPLAY_STATE") == "${WAYLAND_DISPLAY:-wayland-1}" ]] &&
      printf 'ok\n'
    ;;
  *'lock lock')
    touch "$OMARCHY_TEST_QS_STATE.locked"
    printf 'ok\n'
    ;;
  *'lock status')
    [[ $* == *"-p $OMARCHY_TEST_SESSION_PATH/shell"* ]] || exit 1
    if [[ -f $OMARCHY_TEST_QS_STATE.locked ]]; then
      printf '{"secure": true, "requested": true}\n'
    else
      printf '{"secure": false, "requested": false}\n'
    fi
    ;;
esac
SH

cat >"$restart_bin/quickshell" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"${OMARCHY_TEST_QS_LOG:-/dev/null}"

case " $* " in
  *' list -a -j '*)
    printf '['
    separator=""
    while IFS= read -r pid; do
      [[ $pid =~ ^[0-9]+$ ]] || continue
      kill -0 "$pid" 2>/dev/null || continue
      display=$(awk -v pid="$pid" '$1 == pid { print $2; exit }' "$OMARCHY_TEST_QS_DISPLAY_STATE")
      [[ -n $display ]] || display=wayland-1
      if [[ ${WAYLAND_DISPLAY:-wayland-1} == "$display" || $* == *"--any-display"* ]]; then
        printf '%s{"config_path":"%s/shell/shell.qml"}' "$separator" "$OMARCHY_TEST_SESSION_PATH"
        separator=,
      fi
    done <"$OMARCHY_TEST_QS_STATE"
    printf ']\n'
    ;;
  *' kill -p '*)
    [[ $* == "kill -p $OMARCHY_TEST_SESSION_PATH/shell" ]] || exit 1
    killed=0
    : >"$OMARCHY_TEST_QS_STATE.next"
    while IFS= read -r pid; do
      [[ $pid =~ ^[0-9]+$ ]] || continue
      display=$(awk -v pid="$pid" '$1 == pid { print $2; exit }' "$OMARCHY_TEST_QS_DISPLAY_STATE")
      [[ -n $display ]] || display=wayland-1
      if [[ ${WAYLAND_DISPLAY:-wayland-1} == "$display" ]]; then
        killed=1
        kill "$pid" 2>/dev/null
        while kill -0 "$pid" 2>/dev/null; do sleep 0.01; done
      else
        printf '%s\n' "$pid" >>"$OMARCHY_TEST_QS_STATE.next"
      fi
    done <"$OMARCHY_TEST_QS_STATE"
    mv "$OMARCHY_TEST_QS_STATE.next" "$OMARCHY_TEST_QS_STATE"
    (( killed == 1 )) || exit 1
    ;;
  *' -n -p '*)
    printf '%s\n' "${OMARCHY_TEST_TRANSIENT_ENV-unset}" >"$OMARCHY_TEST_QS_ENV_LOG"
    printf '303\n' >>"$OMARCHY_TEST_QS_STATE"
    printf '303 %s\n' "${WAYLAND_DISPLAY:-wayland-1}" >>"$OMARCHY_TEST_QS_DISPLAY_STATE"
    ;;
esac
SH

cat >"$restart_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ ${1:-} == "instances" && ${2:-} == "-j" ]]; then
  if [[ -n ${OMARCHY_TEST_INSTANCES:-} ]]; then
    printf '%s\n' "$OMARCHY_TEST_INSTANCES"
  else
    printf '[{"instance":"current-session","time":1,"pid":1,"wl_socket":"wayland-1"}]\n'
  fi
elif [[ ${1:-} == "repl" ]]; then
  [[ ${OMARCHY_TEST_PATH_FAIL:-0} != 1 ]] || exit 1
  printf '%s\n' "${HYPRLAND_INSTANCE_SIGNATURE:-unset}" >>"${OMARCHY_TEST_PATH_SIGNATURE_LOG:-/dev/null}"
  if [[ -n ${OMARCHY_TEST_SESSION_PATHS:-} ]]; then
    jq -er --arg signature "$HYPRLAND_INSTANCE_SIGNATURE" '.[$signature]' <<<"$OMARCHY_TEST_SESSION_PATHS"
  else
    printf '%s\n' "$OMARCHY_TEST_SESSION_PATH"
  fi
elif [[ ${1:-} == "-j" && ${2:-} == "monitors" ]]; then
  printf '%s\n' "${HYPRLAND_INSTANCE_SIGNATURE-unset}" >>"${OMARCHY_TEST_HYPR_SIGNATURE_LOG:-/dev/null}"
  if [[ ${OMARCHY_TEST_HYPR_HANG:-0} == 1 ]]; then
    sleep 5
  fi
  live_signatures=",${OMARCHY_TEST_ACTIVE_SIGNATURES:-${OMARCHY_TEST_ACTIVE_SIGNATURE:-current-session}},"
  [[ $live_signatures == *",${HYPRLAND_INSTANCE_SIGNATURE:-},"* ]] || exit 1
  # Hyprland reports an active session lock as a reason the monitor cannot hand
  # a client the whole screen, not as a workspace.
  locked_signatures=",${OMARCHY_TEST_LOCKED_SIGNATURES:-},"
  if [[ ${OMARCHY_TEST_SESSION_LOCKED:-0} == 1 || $locked_signatures == *",${HYPRLAND_INSTANCE_SIGNATURE:-},"* ]]; then
    printf '[{"name":"eDP-1","solitaryBlockedBy":["WINDOWED","LOCK","CANDIDATE"]}]\n'
  else
    printf '[{"name":"eDP-1","solitaryBlockedBy":["WINDOWED","CANDIDATE"]}]\n'
  fi
elif [[ ${1:-} == "dispatch" && ${2:-} == hl.dsp.exec_cmd* ]]; then
  printf '%s %s\n' "${HYPRLAND_INSTANCE_SIGNATURE:-unset}" "${WAYLAND_DISPLAY:-unset}" >>"$OMARCHY_TEST_DISPATCH_LOG"
  [[ ${OMARCHY_TEST_DISPATCH_FAIL:-0} != 1 ]] || exit 7
  OMARCHY_PATH="$OMARCHY_TEST_SESSION_PATH" \
    env -u OMARCHY_TEST_TRANSIENT_ENV omarchy-launch-shell
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
  printf 'OMARCHY_PATH=%s\n' "${OMARCHY_TEST_MANAGER_PATH:-$OMARCHY_TEST_SESSION_PATH}"
  if [[ ${OMARCHY_TEST_NO_SESSION_SIGNATURE:-0} != 1 ]]; then
    printf 'HYPRLAND_INSTANCE_SIGNATURE=%s\n' "${OMARCHY_TEST_MANAGER_SIGNATURE:-${OMARCHY_TEST_ACTIVE_SIGNATURE:-current-session}}"
  fi
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
  # The service was running before the restart and, when asked to, never
  # comes back afterwards.
  if [[ ${OMARCHY_TEST_NOTIFICATIONS_DIE:-0} == 1 ]]; then
    (( checks == 1 )) && echo 'b true' || echo 'b false'
    exit 0
  fi
  if (( checks == 1 || checks >= 4 )); then
    echo 'b true'
  else
    echo 'b false'
  fi
fi
SH

chmod +x "$restart_bin/qs" "$restart_bin/quickshell" "$restart_bin/hyprctl" "$restart_bin/systemd-cat" "$restart_bin/systemctl" "$restart_bin/busctl"

hypr_signature_log="$test_tmp/hypr-signatures.log"

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
OMARCHY_TEST_ACTIVE_SIGNATURE=current-session \
OMARCHY_TEST_HYPR_SIGNATURE_LOG="$hypr_signature_log" \
HYPRLAND_INSTANCE_SIGNATURE=stale-terminal-session \
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
grep -F "kill -p $restart_root/shell" "$restart_log" >/dev/null || fail "restart stops the shell from the session checkout"
[[ $(<"$restart_env_log") == "unset" ]] || fail "restart uses the Hyprland session environment for the fresh shell"
grep -Fx 'current-session wayland-1' "$dispatch_log" >/dev/null || fail "restart launches through the selected Hyprland session and display"
grep -Fx 'current-session' "$hypr_signature_log" >/dev/null || fail "restart probes the session manager's canonical compositor signature"
grep -Fx 'stale-terminal-session' "$hypr_signature_log" >/dev/null || fail "restart checks the caller signature before falling back"
grep -F "ipc -n -p $restart_root/shell call -- shell ping" "$ipc_log" >/dev/null || fail "restart checks readiness in the session checkout"
pass "restart replaces duplicate shell instances from the session checkout"
[[ $(<"$test_tmp/notification-checks") == 4 ]] || fail "restart waits for the existing notification service after core IPC is ready"
pass "restart waits for notification readiness before one-time update hooks"

# If no candidate compositor answers IPC, fail before stopping any shell.
: >"$restart_log"
printf '303\n' >"$restart_state"
preflight_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_HYPR_SIGNATURE_LOG="$hypr_signature_log" \
  OMARCHY_TEST_ACTIVE_SIGNATURE=other-live-session \
  OMARCHY_TEST_NO_SESSION_SIGNATURE=1 \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  HYPRLAND_INSTANCE_SIGNATURE=stale-terminal-session \
  "$ROOT/bin/omarchy-restart-shell" 2>&1) && fail "restart refuses when no compositor signature is responsive"
[[ $preflight_error == "No responsive Hyprland instance found; refusing to stop the Omarchy shell." ]] || fail "unresponsive compositor refusal is clear" "$preflight_error"
[[ $(<"$restart_state") == 303 ]] || fail "unresponsive compositor preflight preserves the existing shell"
[[ ! -s $restart_log ]] || fail "unresponsive compositor preflight does not kill or launch Quickshell"
pass "restart checks compositor reachability before stopping Quickshell"

# A wedged Hyprland IPC client is killed by the per-probe timeout, and the
# restart still refuses before stopping the existing shell.
: >"$restart_log"
printf '303\n' >"$restart_state"
preflight_hang_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_HYPR_SIGNATURE_LOG="$hypr_signature_log" \
  OMARCHY_TEST_HYPR_HANG=1 \
  OMARCHY_TEST_ACTIVE_SIGNATURE=current-session \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  HYPRLAND_INSTANCE_SIGNATURE=current-session \
  timeout 5 "$ROOT/bin/omarchy-restart-shell" 2>&1) && fail "restart refuses when the compositor probe hangs"
[[ $preflight_hang_error == "No responsive Hyprland instance found; refusing to stop the Omarchy shell." ]] || fail "hung compositor probe produces the normal preflight refusal" "$preflight_hang_error"
[[ $(<"$restart_state") == 303 ]] || fail "hung compositor probe preserves the existing shell"
[[ ! -s $restart_log ]] || fail "hung compositor probe does not kill or launch Quickshell"
pass "hung compositor probes time out before stopping Quickshell"

# A dispatch error is reported immediately instead of being hidden until the
# shell readiness polling expires.
: >"$restart_log"
sleep 30 &
restart_pid_one=$!
printf '%s\n' "$restart_pid_one" >"$restart_state"
dispatch_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  OMARCHY_TEST_ACTIVE_SIGNATURE=current-session \
  OMARCHY_TEST_DISPATCH_FAIL=1 \
  HYPRLAND_INSTANCE_SIGNATURE=current-session \
  "$ROOT/bin/omarchy-restart-shell" 2>&1) && fail "restart reports a failed Hyprland dispatch"
[[ $dispatch_error == "Failed to launch the Omarchy shell through Hyprland (current-session)." ]] || fail "dispatch failure is reported clearly" "$dispatch_error"
[[ ! -s $restart_state ]] || fail "failed dispatch does not report an existing shell as relaunched"
if kill -0 "$restart_pid_one" 2>/dev/null; then
  fail "failed dispatch test confirms the old shell was stopped first"
fi
wait "$restart_pid_one" 2>/dev/null || true
restart_pid_one=""
pass "Hyprland dispatch failure is reported immediately"

# With two live compositors, the caller's session controls the lock check,
# Quickshell display filter, IPC, and dispatch. A locked caller must preserve
# both shells even when the manager points at an unlocked compositor.
sleep 30 &
restart_pid_one=$!
sleep 30 &
restart_pid_two=$!
printf '%s\n%s\n' "$restart_pid_one" "$restart_pid_two" >"$restart_state"
printf '%s wayland-1\n%s wayland-2\n' "$restart_pid_one" "$restart_pid_two" >"$restart_display_state"
touch "$restart_state.locked"
multi_instances='[{"instance":"session-a","time":1,"pid":101,"wl_socket":"wayland-1"},{"instance":"session-b","time":2,"pid":202,"wl_socket":"wayland-2"}]'
multi_paths=$(jq -n --arg a "$restart_root" --arg b "$caller_root" '{"session-a": $a, "session-b": $b}')
path_signature_log="$test_tmp/path-signatures.log"
multi_locked_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$caller_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  OMARCHY_TEST_MANAGER_PATH="$caller_root" \
  OMARCHY_TEST_SESSION_PATHS="$multi_paths" \
  OMARCHY_TEST_PATH_SIGNATURE_LOG="$path_signature_log" \
  OMARCHY_TEST_ACTIVE_SIGNATURES=session-a,session-b \
  OMARCHY_TEST_LOCKED_SIGNATURES=session-a \
  OMARCHY_TEST_MANAGER_SIGNATURE=session-b \
  OMARCHY_TEST_INSTANCES="$multi_instances" \
  HYPRLAND_INSTANCE_SIGNATURE=session-a \
  "$ROOT/bin/omarchy-restart-shell" 2>&1) && fail "restart refuses to kill a locked caller session"
[[ $multi_locked_error == "Refusing to restart Omarchy shell while the session is locked." ]] || fail "restart refuses to kill a locked caller session" "$multi_locked_error"
[[ $(wc -l <"$restart_state") == 2 ]] || fail "locked caller leaves both session shells running"
if ! kill -0 "$restart_pid_one" 2>/dev/null || ! kill -0 "$restart_pid_two" 2>/dev/null; then
  fail "locked caller does not stop either live shell"
fi
pass "locked caller session is preserved when the manager points elsewhere"
[[ $(<"$path_signature_log") == "session-a" ]] || fail "locked caller path lookup addresses session A"

# Once caller A is unlocked, restart only its display. Session B remains alive.
rm -f "$restart_state.locked"
: >"$restart_log"
PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$caller_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$restart_root" \
OMARCHY_TEST_ACTIVE_SIGNATURES=session-a,session-b \
OMARCHY_TEST_MANAGER_SIGNATURE=session-b \
OMARCHY_TEST_MANAGER_PATH="$caller_root" \
OMARCHY_TEST_SESSION_PATHS="$multi_paths" \
OMARCHY_TEST_PATH_SIGNATURE_LOG="$path_signature_log" \
OMARCHY_TEST_INSTANCES="$multi_instances" \
HYPRLAND_INSTANCE_SIGNATURE=session-a \
  "$ROOT/bin/omarchy-restart-shell"
grep -Fx "$restart_pid_two" "$restart_state" >/dev/null || fail "restart leaves the other session shell tracked"
[[ $(awk '$1 == 303 { display = $2 } END { print display }' "$restart_display_state") == wayland-1 ]] || fail "new shell inherits caller session's exact Wayland display"
if kill -0 "$restart_pid_one" 2>/dev/null; then
  fail "restart stops the caller session's old shell"
fi
if ! kill -0 "$restart_pid_two" 2>/dev/null; then
  fail "restart leaves the other compositor's shell process alive"
fi
[[ $(tail -n 1 "$dispatch_log") == "session-a wayland-1" ]] || fail "dispatch uses the caller's compositor and resolved display"
grep -F "kill -p $restart_root/shell" "$restart_log" >/dev/null || fail "restart kills the selected compositor's checkout rather than the manager's checkout"
[[ $(tail -n 1 "$ipc_log") == "ipc -n -p $restart_root/shell call -- shell ping" ]] || fail "restart probes readiness in the selected compositor's checkout"
[[ $(tail -n 1 "$path_signature_log") == "session-a" ]] || fail "unlocked caller path lookup addresses session A"
kill "$restart_pid_two" 2>/dev/null || true
wait "$restart_pid_one" "$restart_pid_two" 2>/dev/null || true
restart_pid_one=""
restart_pid_two=""
pass "restart targets the caller's display and compositor checkout despite stale caller and manager paths"

# A stale caller signature must fall back to the manager session and resolve
# that session's display, leaving the other compositor's shell untouched.
sleep 30 &
restart_pid_one=$!
sleep 30 &
restart_pid_two=$!
printf '%s\n%s\n' "$restart_pid_one" "$restart_pid_two" >"$restart_state"
printf '%s wayland-1\n%s wayland-2\n' "$restart_pid_one" "$restart_pid_two" >"$restart_display_state"
: >"$restart_log"
PATH="$restart_bin:$PATH" \
OMARCHY_PATH="$restart_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
OMARCHY_TEST_QS_STATE="$restart_state" \
OMARCHY_TEST_QS_LOG="$restart_log" \
OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
OMARCHY_TEST_IPC_LOG="$ipc_log" \
OMARCHY_TEST_SESSION_PATH="$caller_root" \
OMARCHY_TEST_ACTIVE_SIGNATURES=session-a,session-b \
OMARCHY_TEST_MANAGER_SIGNATURE=session-b \
OMARCHY_TEST_MANAGER_PATH="$restart_root" \
OMARCHY_TEST_SESSION_PATHS="$multi_paths" \
OMARCHY_TEST_PATH_SIGNATURE_LOG="$path_signature_log" \
OMARCHY_TEST_INSTANCES="$multi_instances" \
HYPRLAND_INSTANCE_SIGNATURE=stale-caller-session \
  "$ROOT/bin/omarchy-restart-shell"
grep -Fx "$restart_pid_one" "$restart_state" >/dev/null || fail "stale-caller fallback preserves the unrelated display shell"
[[ $(awk '$1 == 303 { display = $2 } END { print display }' "$restart_display_state") == wayland-2 ]] || fail "stale-caller fallback launches on the manager session display"
if kill -0 "$restart_pid_one" 2>/dev/null; then
  :
else
  fail "stale-caller fallback keeps session A alive"
fi
if kill -0 "$restart_pid_two" 2>/dev/null; then
  fail "stale-caller fallback stops session B's old shell"
fi
[[ $(tail -n 1 "$dispatch_log") == "session-b wayland-2" ]] || fail "stale-caller fallback dispatches to the manager session"
[[ $(tail -n 1 "$path_signature_log") == "session-b" ]] || fail "stale-caller fallback queries the selected session B checkout"
grep -F "kill -p $caller_root/shell" "$restart_log" >/dev/null || fail "stale-caller fallback kills session B's checkout rather than the manager path"
kill "$restart_pid_one" 2>/dev/null || true
wait "$restart_pid_one" "$restart_pid_two" 2>/dev/null || true
restart_pid_one=""
restart_pid_two=""
pass "stale caller falls back to only the manager Wayland session"

# If Hyprland responds but its instance metadata cannot uniquely map the
# selected signature to a Wayland socket, refuse before stopping any shell.
sleep 30 &
restart_pid_one=$!
printf '%s\n' "$restart_pid_one" >"$restart_state"
: >"$restart_log"
display_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  OMARCHY_TEST_ACTIVE_SIGNATURE=current-session \
  OMARCHY_TEST_INSTANCES='[]' \
  HYPRLAND_INSTANCE_SIGNATURE=current-session \
  "$ROOT/bin/omarchy-restart-shell" 2>&1) && fail "restart refuses an unresolved Wayland display"
[[ $display_error == "Could not uniquely resolve the Wayland display for Hyprland (current-session); refusing to stop the Omarchy shell." ]] || fail "unresolved display refusal is clear" "$display_error"
[[ $(<"$restart_state") == "$restart_pid_one" ]] || fail "unresolved display refusal preserves the shell"
[[ ! -s $restart_log ]] || fail "unresolved display refusal does not invoke Quickshell"
kill "$restart_pid_one" 2>/dev/null || true
wait "$restart_pid_one" 2>/dev/null || true
restart_pid_one=""
pass "missing Wayland mapping refuses before stopping Quickshell"

# A responsive compositor with an unreadable launch environment must also
# preserve its shell instead of falling back to another checkout.
: >"$restart_log"
printf '303\n' >"$restart_state"
path_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  OMARCHY_TEST_PATH_FAIL=1 \
  HYPRLAND_INSTANCE_SIGNATURE=current-session \
  "$ROOT/bin/omarchy-restart-shell" 2>&1) && fail "restart refuses an unresolved session checkout"
[[ $path_error == "Could not resolve the Omarchy path for Hyprland (current-session); refusing to stop the Omarchy shell." ]] || fail "unresolved checkout refusal is clear" "$path_error"
[[ $(<"$restart_state") == 303 && ! -s $restart_log ]] || fail "unresolved checkout does not invoke Quickshell"
pass "unresolved compositor checkout refuses before stopping Quickshell"

# A successful path lookup is insufficient when the replacement configuration
# is missing. Preserve the shell rather than killing it before launch failure.
missing_root="$test_tmp/missing-config"
mkdir -p "$missing_root/shell"
: >"$restart_log"
missing_config_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_SESSION_PATH="$missing_root" \
  HYPRLAND_INSTANCE_SIGNATURE=current-session \
  "$ROOT/bin/omarchy-restart-shell" 2>&1) && fail "restart refuses a resolved checkout without shell.qml"
[[ $missing_config_error == "Omarchy shell config not found for Hyprland (current-session): $missing_root/shell; refusing to stop the Omarchy shell." ]] || fail "missing config refusal is clear" "$missing_config_error"
[[ $(<"$restart_state") == 303 && ! -s $restart_log ]] || fail "missing config does not stop or launch Quickshell"
pass "resolved checkout without shell.qml refuses before stopping Quickshell"

: >"$restart_log"
printf '303\n' >"$restart_state"
touch "$restart_state.locked"
mkdir -p "$runtime_dir/hypr/runtime-session"

locked_error=$(PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_SESSION_LOCKED=1 \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  OMARCHY_TEST_ACTIVE_SIGNATURE=runtime-session \
  OMARCHY_TEST_INSTANCES='[{"instance":"runtime-session","time":1,"pid":1,"wl_socket":"wayland-1"}]' \
  OMARCHY_TEST_NO_SESSION_SIGNATURE=1 \
  HYPRLAND_INSTANCE_SIGNATURE= \
  "$ROOT/bin/omarchy-restart-shell" 2>&1) && fail "restart refuses while the shell lock is active"

[[ $locked_error == "Refusing to restart Omarchy shell while the session is locked." ]] || fail "locked restart explains why it was refused" "$locked_error"
[[ $(<"$restart_state") == 303 ]] || fail "locked restart preserves the running shell"
[[ ! -s $restart_log ]] || fail "locked restart does not stop or launch Quickshell"
pass "restart preserves the shell while its lock is active"

# A LOCK session without an active locker — dead shell or a crash-handler
# relaunch holding no lock — is the failsafe: restart must proceed,
# re-acquire the session lock, and wait for it to report secure.
sleep 30 &
restart_pid_one=$!
printf '%s\n' "$restart_pid_one" >"$restart_state"
rm -f "$restart_state.locked"
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
OMARCHY_TEST_ACTIVE_SIGNATURE=runtime-session \
OMARCHY_TEST_INSTANCES='[{"instance":"runtime-session","time":1,"pid":1,"wl_socket":"wayland-1"}]' \
  timeout 5 "$ROOT/bin/omarchy-restart-shell" || fail "locked restart recovers when the lock client is dead"

if kill -0 "$restart_pid_one" 2>/dev/null; then
  fail "dead-lock recovery stops the stale shell instance"
fi
wait "$restart_pid_one" 2>/dev/null || true
restart_pid_one=""
[[ $(<"$restart_state") == 303 ]] || fail "dead-lock recovery leaves one fresh shell instance"
grep -F "ipc -n -p $restart_root/shell call -- lock lock" "$ipc_log" >/dev/null || fail "dead-lock recovery re-acquires the session lock"
grep -F "ipc -n -p $restart_root/shell call -- lock status" "$ipc_log" >/dev/null || fail "dead-lock recovery waits for the lock to become secure"
pass "restart recovers a locked session whose lock client died"

# Lock recovery must not wait on the notification plugin: a stranded user gets
# the lock back even when notifications never return, and the restart then
# reports the missing service rather than claiming success.
sleep 30 &
restart_pid_one=$!
printf '%s\n' "$restart_pid_one" >"$restart_state"
rm -f "$restart_state.locked" "$test_tmp/notification-checks"
: >"$restart_log"
: >"$ipc_log"

if PATH="$restart_bin:$PATH" \
  OMARCHY_PATH="$restart_root" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  OMARCHY_TEST_SESSION_LOCKED=1 \
  OMARCHY_TEST_QS_STATE="$restart_state" \
  OMARCHY_TEST_QS_LOG="$restart_log" \
  OMARCHY_TEST_QS_ENV_LOG="$restart_env_log" \
  OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
  OMARCHY_TEST_IPC_LOG="$ipc_log" \
  OMARCHY_TEST_SESSION_PATH="$restart_root" \
  OMARCHY_TEST_ACTIVE_SIGNATURE=runtime-session \
  OMARCHY_TEST_INSTANCES='[{"instance":"runtime-session","time":1,"pid":1,"wl_socket":"wayland-1"}]' \
  OMARCHY_TEST_NOTIFICATION_CHECKS="$test_tmp/notification-checks" \
  OMARCHY_TEST_NOTIFICATIONS_DIE=1 \
  timeout 10 "$ROOT/bin/omarchy-restart-shell" >"$test_tmp/dead-notifications.out" 2>&1; then
  fail "a restart whose notification service never returns must not report success"
fi
wait "$restart_pid_one" 2>/dev/null || true
restart_pid_one=""
grep -F "ipc -n -p $restart_root/shell call -- lock lock" "$ipc_log" >/dev/null || fail "lock recovery waited on the notification service" "$(cat "$ipc_log")"
[[ -f $restart_state.locked ]] || fail "lock recovery did not re-secure the session without notifications"
grep -q "notification service did not become ready" "$test_tmp/dead-notifications.out" || fail "a missing notification service is not reported" "$(cat "$test_tmp/dead-notifications.out")"
pass "restart recovers the lock even when the notification service never returns"
