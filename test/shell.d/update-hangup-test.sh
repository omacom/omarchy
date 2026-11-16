#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"

# Real PTYs, script, flock and gum; no package or privileged steps can run.
# Use packaged gum, not a tool-manager shim whose config depends on HOME.
export TEST_GUM=/usr/bin/gum
[[ -x $TEST_GUM ]] || fail "packaged gum is available"
export XDG_RUNTIME_DIR="$boundary_tmp/runtime"
mkdir -m 700 "$XDG_RUNTIME_DIR"
export HOME="$SUDO_TEST_HOME"
unset OMARCHY_UPDATE_LOGGED OMARCHY_UPDATE_LOCK_FD
for command in omarchy-update omarchy-update-lock; do
  rm -f "$SUDO_TEST_ROOT/bin/$command"
  copy_boundary_file "bin/$command"
done
sed -i "s#/tmp/omarchy-update\.log#$boundary_tmp/transcript#" "$SUDO_TEST_ROOT/bin/omarchy-update"
rm -f "$SUDO_TEST_ROOT/bin/omarchy-update-confirm"
cat >"$SUDO_TEST_ROOT/bin/omarchy-update-confirm" <<'STUB'
#!/bin/bash
printf '%s\n' "$$" >"$PROMPT_PID_FILE"
exec "$TEST_GUM" confirm 'Continue with update?'
STUB
chmod +x "$SUDO_TEST_ROOT/bin/omarchy-update-confirm"

python3 - "$SUDO_TEST_ROOT/bin/omarchy-update" "$boundary_tmp" <<'PY'
import ctypes
import fcntl
import os
from pathlib import Path
import pty
import select
import shlex
import signal
import sys
import termios
import time

update, scratch = sys.argv[1:]
# Adopt/reap orphaned test children, including on failure. Never match or kill
# processes by a command substring that could name someone else's update.
if ctypes.CDLL(None, use_errno=True).prctl(36, 1, 0, 0, 0) != 0:
    raise OSError(ctypes.get_errno(), 'PR_SET_CHILD_SUBREAPER')

def children(pid):
    try:
        return [int(p) for p in Path(f'/proc/{pid}/task/{pid}/children').read_text().split()]
    except FileNotFoundError:
        return []

def alive(pid):
    try:
        return Path(f'/proc/{pid}/stat').read_text().split(') ')[1][0] != 'Z'
    except FileNotFoundError:
        return False

def until(predicate, message, fd=None):
    deadline = time.monotonic() + 10
    output = b''
    while time.monotonic() < deadline:
        if fd is not None and select.select([fd], [], [], 0.02)[0]:
            try:
                output += os.read(fd, 65536)
            except OSError:
                pass
        if predicate(output):
            return
        time.sleep(0.01)
    raise AssertionError(message + ': ' + repr(output[-4096:]))

try:
    for mode in ('close-terminal', 'kill-script'):
        marker = Path(scratch) / (mode + '.pid')
        pid, master = pty.fork()
        if pid == 0:
            termios.tcsetwinsize(0, (24, 80))
            os.environ['TERM'] = 'xterm-256color'
            os.environ['PROMPT_PID_FILE'] = str(marker)
            os.execv('/bin/bash', ['bash', '-c', shlex.quote(update) + '; exit $?'])
        try:
            until(lambda output: marker.exists() and b'Continue with update?' in output,
                  'update did not reach real gum prompt', master)
            prompt = int(marker.read_text())
            script_children = children(pid)
            assert len(script_children) == 1, script_children
            if mode == 'kill-script':
                # Model the observed missing script ancestor; its TERM/KILL
                # grace period cannot rescue the inner session in this case.
                os.kill(script_children[0], signal.SIGKILL)
            # The sole master is here: no reader child keeps the terminal alive.
        finally:
            os.close(master)
        until(lambda _: not alive(prompt), mode + ': gum survived terminal loss')
        def lock_free(_):
            lock = os.open(os.environ['XDG_RUNTIME_DIR'] + '/omarchy-update.lock', os.O_WRONLY)
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                return True
            except BlockingIOError:
                return False
            finally:
                os.close(lock)
        until(lock_free, mode + ': the update lock was never released')
        until(lambda _: not alive(pid), mode + ': launcher did not exit')
        os.waitpid(pid, 0)
        print('ok - ' + mode + ' ends real gum and releases the update lock', flush=True)
finally:
    # Killing direct children bottom-up via adoption is bounded and PID-scoped.
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        owned = children(os.getpid())
        if not owned:
            break
        for child in owned:
            try:
                os.kill(child, signal.SIGKILL)
            except ProcessLookupError:
                pass
        while True:
            try:
                if os.waitpid(-1, os.WNOHANG)[0] == 0:
                    break
            except ChildProcessError:
                break
        time.sleep(0.01)
PY

# The trusted logger shell must not change the shell seen by update steps,
# and the added trailing command must preserve the update's exit status.
rm -f "$SUDO_TEST_ROOT/bin/omarchy-update-requires-free-space"
cat >"$SUDO_TEST_ROOT/bin/omarchy-update-requires-free-space" <<'STUB'
#!/bin/bash
actual_shell=$(/usr/bin/printenv SHELL) || actual_shell=unset
[[ $actual_shell == "$EXPECTED_SHELL" ]] || exit 91
exit 37
STUB
chmod +x "$SUDO_TEST_ROOT/bin/omarchy-update-requires-free-space"
for shell_mode in exported unset; do
  (
    if [[ $shell_mode == "exported" ]]; then
      export SHELL="/not a shell/'with quotes" EXPECTED_SHELL="/not a shell/'with quotes"
    else
      unset SHELL
      export EXPECTED_SHELL=unset
    fi
    status=0
    "$SUDO_TEST_ROOT/bin/omarchy-update" >"$boundary_tmp/shell-$shell_mode.log" 2>&1 || status=$?
    (( status == 37 )) || fail "logger preserves $shell_mode SHELL and exit status" "$(<"$boundary_tmp/shell-$shell_mode.log")"
  )
  pass "logger preserves $shell_mode SHELL and exit status"
done
