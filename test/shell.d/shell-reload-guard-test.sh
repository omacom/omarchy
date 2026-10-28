#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
shell_pids=()

cleanup() {
  local pid
  for pid in "${shell_pids[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  rm -rf "$test_tmp"
}
trap cleanup EXIT

root_dir="$test_tmp/omarchy"
run_root="$test_tmp/run-user"
runtime_dir="$run_root/$(id -u)"
state_dir="$test_tmp/state"
fake_bin="$test_tmp/bin"
pid_file="$test_tmp/shell-pid"
config_file="$test_tmp/shell-config"
qs_log="$test_tmp/qs.log"
kill_log="$test_tmp/kill.log"
restart_log="$test_tmp/restart.log"

mkdir -p "$root_dir/shell" "$runtime_dir" "$fake_bin"
touch "$root_dir/shell/shell.qml"
printf '%s\n' "$root_dir/shell/shell.qml" >"$config_file"
: >"$pid_file"

cat >"$fake_bin/quickshell" <<'SH'
#!/bin/bash

case " $* " in
  *' list '*)
    pid=$(<"$FAKE_PID_FILE")
    if [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null; then
      config=$(<"$FAKE_CONFIG_FILE")
      printf '[{"id":"omarchy","pid":%s,"shell_id":"shell","config_path":"%s","launch_time":"2026-01-01T00:00:00"}]\n' "$pid" "$config"
    else
      printf '[]\n'
    fi
    ;;
  *' kill '*)
    printf '%s\n' "$*" >>"$FAKE_KILL_LOG"
    pid=
    while (($#)); do
      case "$1" in
        --pid) pid=${2:-}; shift 2 ;;
        *) shift ;;
      esac
    done
    [[ -n $pid ]] && kill "$pid" 2>/dev/null || true
    ;;
esac
SH

cat >"$fake_bin/qs" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$FAKE_QS_LOG"
case ${FAKE_QS_MODE:-ok} in
  ok) printf 'ok\n' ;;
  missing) printf 'Function not found.\n' ;;
  unresponsive) exit 1 ;;
esac
SH

cat >"$fake_bin/omarchy-restart-shell" <<'SH'
#!/bin/bash

printf 'restart\n' >>"$FAKE_RESTART_LOG"
printf 'XDG_RUNTIME_DIR=%s\n' "${XDG_RUNTIME_DIR:-}" >>"$FAKE_RESTART_LOG"
printf 'WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-}" >>"$FAKE_RESTART_LOG"
printf 'HYPRLAND_INSTANCE_SIGNATURE=%s\n' "${HYPRLAND_INSTANCE_SIGNATURE:-}" >>"$FAKE_RESTART_LOG"
printf 'OMARCHY_PATH=%s\n' "${OMARCHY_PATH:-}" >>"$FAKE_RESTART_LOG"
if [[ ${FAKE_RESTART_FAIL:-0} == 1 ]]; then
  exit 1
fi
exit 0
SH

cat >"$fake_bin/omarchy-hyprland-session-locked" <<'SH'
#!/bin/bash

[[ ${FAKE_LOCKED:-0} == 1 ]]
SH

chmod 0755 "$fake_bin/quickshell" "$fake_bin/qs" \
  "$fake_bin/omarchy-restart-shell" "$fake_bin/omarchy-hyprland-session-locked"

export FAKE_PID_FILE="$pid_file"
export FAKE_CONFIG_FILE="$config_file"
export FAKE_QS_LOG="$qs_log"
export FAKE_KILL_LOG="$kill_log"
export FAKE_RESTART_LOG="$restart_log"
export OMARCHY_SHELL_RELOAD_GUARD_RUN_ROOT="$run_root"
export OMARCHY_SHELL_RELOAD_GUARD_STATE_DIR="$state_dir"
export OMARCHY_SHELL_RELOAD_GUARD_QUICKSHELL="$fake_bin/quickshell"
export OMARCHY_SHELL_RELOAD_GUARD_QS="$fake_bin/qs"
export OMARCHY_SHELL_RELOAD_GUARD_RESTART="$fake_bin/omarchy-restart-shell"
export OMARCHY_SHELL_RELOAD_GUARD_LOCKED="$fake_bin/omarchy-hyprland-session-locked"

guard="$ROOT/bin/omarchy-shell-reload-guard"

start_shell() {
  local config_root="${1:-$root_dir}"
  local env_root="${2:-$config_root}"

  env WAYLAND_DISPLAY=test-display \
    HYPRLAND_INSTANCE_SIGNATURE=test-signature \
    OMARCHY_PATH="$env_root" \
    sleep 60 &
  shell_pid=$!
  shell_pids+=("$shell_pid")
  printf '%s\n' "$shell_pid" >"$pid_file"
  printf '%s\n' "$config_root/shell/shell.qml" >"$config_file"
}

stop_shell() {
  kill "$shell_pid" 2>/dev/null || true
  wait "$shell_pid" 2>/dev/null || true
  : >"$pid_file"
}

state_actions() {
  local file
  for file in "$state_dir"/*; do
    [[ -f $file ]] || continue
    cut -f7 "$file"
  done
}

start_shell
FAKE_QS_MODE=ok "$guard" pause
[[ $(state_actions) == "paused" ]] || fail "the guard records a shell whose plugin loads it paused"
grep -F -- "--pid $shell_pid call -- shell pausePlugins" "$qs_log" >/dev/null ||
  fail "the guard pauses through the shell's own IPC target"
"$guard" paused || fail "the guard reports a transaction holding plugin loads"
[[ ! -s $restart_log ]] || fail "pausing does not restart the shell"
pass "the guard pauses plugin loads in a supported running shell"

"$guard" resume
grep -Fx 'restart' "$restart_log" >/dev/null || fail "resuming restarts the paused shell"
grep -Fx "XDG_RUNTIME_DIR=$runtime_dir" "$restart_log" >/dev/null ||
  fail "restart keeps the session runtime directory"
grep -Fx 'WAYLAND_DISPLAY=test-display' "$restart_log" >/dev/null ||
  fail "restart keeps the shell's display"
grep -Fx 'HYPRLAND_INSTANCE_SIGNATURE=test-signature' "$restart_log" >/dev/null ||
  fail "restart keeps the shell's Hyprland instance"
grep -Fx "OMARCHY_PATH=$root_dir" "$restart_log" >/dev/null ||
  fail "restart uses the shell's own Omarchy path"
[[ -z $(state_actions) ]] || fail "resuming clears the guard state"
"$guard" paused && fail "the guard reports no transaction after resume"
pass "the guard restarts the paused shell in its session and clears state"

stop_shell
: >"$qs_log"
: >"$restart_log"

start_shell
FAKE_QS_MODE=missing FAKE_LOCKED=0 "$guard" pause
grep -F -- "--pid $shell_pid" "$kill_log" >/dev/null ||
  fail "an old shell that cannot pause is stopped cleanly instead"
wait_for_exit=0
for _ in $(seq 50); do
  if ! kill -0 "$shell_pid" 2>/dev/null; then
    wait_for_exit=1
    break
  fi
  sleep 0.05
done
(( wait_for_exit )) || fail "the guard waits for the stopped shell to exit"
[[ $(state_actions) == "stopped" ]] || fail "the guard records a shell it stopped"
pass "the guard stops an old shell that cannot pause plugin loads"

"$guard" resume
grep -Fx 'restart' "$restart_log" >/dev/null || fail "resuming starts a stopped shell"
[[ -z $(state_actions) ]] || fail "resuming clears the stopped shell state"
pass "the guard starts a stopped shell after the transaction"

: >"$kill_log"
: >"$restart_log"

start_shell
FAKE_QS_MODE=missing FAKE_LOCKED=1 "$guard" pause
[[ ! -s $kill_log ]] || fail "a locked session's shell is not stopped"
[[ -z $(state_actions) ]] || fail "a locked session's shell is not recorded for restart"
pass "the guard leaves a locked session's shell running"

stop_shell
: >"$restart_log"
: >"$kill_log"

# A supported shell can pause while locked, but the post-transaction restart
# is refused to protect the lock client. Keep the state so the next restart or
# transaction can finish the job instead of losing track of the paused shell.
start_shell
FAKE_QS_MODE=ok FAKE_LOCKED=1 "$guard" pause
[[ $(state_actions) == "paused" ]] || fail "a locked session's supported shell is paused"
[[ ! -s $kill_log ]] || fail "a locked session's supported shell is not stopped"
FAKE_RESTART_FAIL=1 "$guard" resume
[[ $(state_actions) == "paused" ]] || fail "a refused restart keeps the pause state"
FAKE_RESTART_FAIL=0 "$guard" resume
[[ -z $(state_actions) ]] || fail "a later successful restart clears the kept pause state"
pass "a locked session keeps its pause until a later restart"

stop_shell
: >"$restart_log"

# A session that logged out during the transaction has no shell to restart.
mkdir -p "$state_dir"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$(id -u)" "$test_tmp/gone-runtime" "12345" "$root_dir/shell/shell.qml" "" "" "stopped" \
  >"$state_dir/gone-session"
"$guard" resume
[[ ! -e $state_dir/gone-session ]] || fail "a dead session's state is cleared without a restart"
[[ ! -s $restart_log ]] || fail "a dead session is not restarted"
pass "the guard drops state for a session that ended during the transaction"

# Another Quickshell config can also live at shell/shell.qml. Its own
# OMARCHY_PATH names a different tree, so the guard must leave it alone.
mkdir -p "$test_tmp/foreign/shell"
touch "$test_tmp/foreign/shell/shell.qml"
: >"$qs_log"
start_shell "$test_tmp/foreign" "$root_dir"
FAKE_QS_MODE=ok "$guard" pause
[[ ! -s $qs_log ]] || fail "the guard leaves another Quickshell config alone"
[[ -z $(state_actions) ]] || fail "the guard records no foreign shell"
pass "the guard only pauses Omarchy shells"
stop_shell

# A failed pacman transaction never runs PostTransaction hooks, so the update
# command's exit path must release the pause as well.
grep -F 'guard=$(command -v omarchy-shell-reload-guard)' "$ROOT/bin/omarchy-update" >/dev/null &&
  grep -F '"$guard" resume' "$ROOT/bin/omarchy-update" >/dev/null ||
  fail "a failed update resumes paused shell plugin loads"
pass "a failed update resumes paused shell plugin loads"
