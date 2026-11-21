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

# The cases below drive the real confirm script. Packaged gum dies with the
# terminal; gum 2.0.2 catches SIGHUP and keeps reading, which is what holds
# the lock. This stub does that, and answers y/n once raw mode is on.
cat >"$SUDO_TEST_ROOT/bin/omarchy-i18n" <<'STUB'
#!/bin/bash
case "${1:-}" in
  update.continue) printf '%s\n' "Continue with update?" ;;
  update.cancelled) printf '%s\n' "Update cancelled" ;;
  common.yes) printf '%s\n' "Yes" ;;
  common.no) printf '%s\n' "No" ;;
  *) printf '%s\n' "$*" ;;
esac
STUB
chmod +x "$SUDO_TEST_ROOT/bin/omarchy-i18n"
# PATH's cp is the boundary stub, which exits without copying.
/bin/cp "$ROOT/bin/omarchy-update-confirm" "$boundary_tmp/confirm-production"
export FAKE_GUM_PY="$boundary_tmp/fakegum.py"
cat >"$FAKE_GUM_PY" <<'PY'
import os
import select
import signal
import sys
import termios
import time
import tty

signal.signal(signal.SIGHUP, lambda _signum, _frame: None)
question = os.environ.get("GUM_QUESTION", "")
fd = 0
if not os.isatty(fd):
    while True:
        time.sleep(0.5)

try:
    old = termios.tcgetattr(fd)
    tty.setraw(fd)
except (OSError, termios.error):
    while True:
        time.sleep(0.5)

# tty.setraw() flushes queued input. Announce readiness only after that, or
# the harness can lose the one key it sends.
pid_file = os.environ.get("PROMPT_PID_FILE")
if pid_file:
    with open(pid_file, "w", encoding="utf-8") as handle:
        handle.write(str(os.getpid()))
sys.stdout.write(question + "\nFAKEGUM ready\n")
sys.stdout.flush()

choice = b""
while choice not in (b"y", b"Y", b"n", b"N"):
    try:
        readable, _, _ = select.select([fd], [], [], 0.2)
    except (InterruptedError, OSError):
        continue
    if not readable:
        continue
    try:
        data = os.read(fd, 16)
    except OSError:
        continue
    if not data:
        continue
    choice = data[:1]

termios.tcsetattr(fd, termios.TCSADRAIN, old)
if choice in (b"y", b"Y"):
    sys.stdout.write("FAKEGUM yes\nFAKEGUM restored\n")
    sys.stdout.flush()
    raise SystemExit(0)
sys.stdout.write("FAKEGUM no\nFAKEGUM restored\n")
sys.stdout.flush()
raise SystemExit(1)
PY
cat >"$SUDO_TEST_ROOT/bin/gum" <<'STUB'
#!/bin/bash
if [[ ${1:-} != "confirm" ]]; then
  exit 0
fi
question=""
for argument in "$@"; do
  question=$argument
done
GUM_QUESTION=$question exec python3 "$FAKE_GUM_PY"
STUB
chmod +x "$SUDO_TEST_ROOT/bin/gum"

python3 - "$SUDO_TEST_ROOT/bin/omarchy-update" "$boundary_tmp" "$boundary_tmp/confirm-production" "$SUDO_TEST_ROOT/bin/omarchy-update-confirm" <<'PY'
import ctypes
import fcntl
import os
from pathlib import Path
import pty
import select
import shlex
import shutil
import signal
import sys
import termios
import time

update, scratch, production_confirm, confirm_path = sys.argv[1:]
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
            return output
        time.sleep(0.01)
    raise AssertionError(message + ': ' + repr(output[-4096:]))

def lock_free(_):
    lock = os.open(os.environ['XDG_RUNTIME_DIR'] + '/omarchy-update.lock', os.O_WRONLY)
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        return True
    except BlockingIOError:
        return False
    finally:
        os.close(lock)

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
        until(lock_free, mode + ': the update lock was never released')
        until(lambda _: not alive(pid), mode + ': launcher did not exit')
        os.waitpid(pid, 0)
        print('ok - ' + mode + ' ends real gum and releases the update lock', flush=True)

    # Real confirm script, same pty and lock helpers. The stub gum ignores
    # SIGHUP, so only the confirm trap can release the lock on hangup.
    shutil.copy(production_confirm, confirm_path)
    os.chmod(confirm_path, 0o755)
    log_path = os.environ['SUDO_TEST_LOG']
    for mode in ('hangup', 'yes', 'no'):
        Path(log_path).write_text('')
        marker = Path(scratch) / ('sighup-' + mode + '.pid')
        if marker.exists():
            marker.unlink()
        pid, master = pty.fork()
        if pid == 0:
            termios.tcsetwinsize(0, (24, 80))
            os.environ['TERM'] = 'xterm-256color'
            os.environ['PROMPT_PID_FILE'] = str(marker)
            os.execv('/bin/bash', ['bash', '-c', shlex.quote(update) + '; exit $?'])
        try:
            until(
                lambda output: marker.exists() and b'FAKEGUM ready' in output and b'Continue with update?' in output,
                mode + ': update did not reach the sighup-ignoring prompt',
                master,
            )
            prompt = int(marker.read_text())
            if mode == 'hangup':
                until(lambda _: not lock_free(b''), mode + ': confirm prompt did not hold the update lock')
            else:
                os.write(master, b'y' if mode == 'yes' else b'n')

                def answered(output, mode=mode):
                    if b'FAKEGUM restored' not in output or alive(pid):
                        return False
                    if mode == 'no' and b'Update cancelled' not in output:
                        return False
                    if mode == 'yes' and b'Update cancelled' in output:
                        return False
                    started = 'step:omarchy-update-pkg-prune' in Path(log_path).read_text()
                    return started if mode == 'yes' else not started

                until(answered, mode + ': answer did not finish the confirm prompt', master)
        finally:
            if mode == 'hangup':
                os.close(master)
        if mode == 'hangup':
            until(lambda _: not alive(prompt), mode + ': gum survived terminal loss')
            until(lock_free, mode + ': the update lock was never released')
            until(lambda _: not alive(pid), mode + ': launcher did not exit')
            os.waitpid(pid, 0)
            if 'step:omarchy-update-pkg-prune' in Path(log_path).read_text():
                raise AssertionError(mode + ': closing the prompt started the update')
            print('ok - closing the terminal on a sighup-ignoring prompt releases the update lock', flush=True)
        else:
            _, status = os.waitpid(pid, 0)
            os.close(master)
            code = os.waitstatus_to_exitcode(status)
            if code != 0:
                raise AssertionError(mode + ': update exit status ' + str(code))
            if mode == 'yes':
                print('ok - yes at the sighup-ignoring prompt starts the update and restores the terminal', flush=True)
            else:
                print('ok - no at the sighup-ignoring prompt cancels without starting the update', flush=True)
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
