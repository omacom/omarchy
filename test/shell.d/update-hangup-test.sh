#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"

# Closing the terminal while omarchy update waits at its confirmation prompt
# must end the update and release its lock. The real script(1) wrapper and lock
# run here; the prompt is a stand-in that, like gum, ignores EOF on a dead TTY
# and only a signal ends it.
runtime_dir="/run/user/$(id -u)"
test_run_id="test-$BASHPID-$RANDOM"
update_lock_name="omarchy-update-$test_run_id.lock"
update_log="$boundary_tmp/omarchy-update.log"
trap 'pkill -f -- "$boundary_tmp" 2>/dev/null && sleep 0.2; rm -f -- "$runtime_dir/$update_lock_name"; rm -rf -- "$boundary_tmp"' EXIT

for command in omarchy-update omarchy-update-lock; do
  rm -f "$SUDO_TEST_ROOT/bin/$command"
  copy_boundary_file "bin/$command"
done
sed -i \
  -e "s/omarchy-update\.lock/$update_lock_name/g" \
  -e "s#/tmp/omarchy-update\.log#$update_log#" \
  "$SUDO_TEST_ROOT/bin/omarchy-update" \
  "$SUDO_TEST_ROOT/bin/omarchy-update-lock"

prompt_pid_file="$boundary_tmp/prompt-pid"
rm -f "$SUDO_TEST_ROOT/bin/omarchy-update-confirm"
cat >"$SUDO_TEST_ROOT/bin/omarchy-update-confirm" <<'STUB'
#!/bin/bash
echo "$$" >"$PROMPT_PID_FILE"
while :; do
  read -r _ || sleep 0.05
done
STUB
chmod +x "$SUDO_TEST_ROOT/bin/omarchy-update-confirm"

# The menu and bar launch the update as one command in a fresh terminal, so
# script(1) is not that terminal's session leader. Closing the window hangs up
# its foreground process group and the terminal's side of the PTY.
PROMPT_PID_FILE="$prompt_pid_file" XDG_RUNTIME_DIR="$runtime_dir" \
  python3 - "$SUDO_TEST_ROOT/bin/omarchy-update" "$prompt_pid_file" <<'PY' ||
import os, pty, sys, time

update, prompt_pid_file = sys.argv[1:]
pid, fd = pty.fork()
if pid == 0:
    os.execvp("bash", ["bash", "-c", f"{update}; exit $?"])
if os.fork() == 0:
    try:
        while os.read(fd, 4096):
            pass
    except OSError:
        pass
    os._exit(0)

deadline = time.monotonic() + 10
while not (os.path.exists(prompt_pid_file) and os.path.getsize(prompt_pid_file)):
    if time.monotonic() > deadline:
        sys.exit("the update never reached its prompt")
    time.sleep(0.02)

os.killpg(os.tcgetpgrp(fd), 1)
os.close(fd)
os.waitpid(pid, 0)
PY
  fail "update reaches its prompt in a terminal"

prompt_pid=$(<"$prompt_pid_file")
for _ in {1..150}; do
  kill -0 "$prompt_pid" 2>/dev/null || break
  sleep 0.02
done
kill -0 "$prompt_pid" 2>/dev/null && fail "closing the terminal ends the update's waiting prompt"
pass "closing the terminal ends the update's waiting prompt"

lock_released=0
for _ in {1..150}; do
  if flock -n "$runtime_dir/$update_lock_name" true; then
    lock_released=1
    break
  fi
  sleep 0.02
done
(( lock_released )) || fail "closing the terminal releases the update lock"
pass "closing the terminal releases the update lock"
