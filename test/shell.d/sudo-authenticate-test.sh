#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
pam_dir="$test_tmp/pam.d"
mkdir -p "$mock_bin" "$pam_dir"

cat >"$pam_dir/sudo-password" <<'PAM'
#%PAM-1.0
auth include system-auth
PAM

cat >"$pam_dir/sudo-fprintd" <<'PAM'
#%PAM-1.0
auth      [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth      sufficient pam_fprintd.so
auth      include system-auth
PAM

cat >"$pam_dir/sudo-fido2" <<'PAM'
#%PAM-1.0
auth    sufficient pam_u2f.so cue authfile=/etc/fido2/fido2
auth    include system-auth
PAM

cat >"$mock_bin/omarchy-pkg-missing" <<'STUB'
#!/bin/bash
exit 0
STUB

cat >"$mock_bin/omarchy-hw-laptop-closed" <<'STUB'
#!/bin/bash
exit "${TEST_LID_CLOSED_STATUS:-1}"
STUB

cat >"$mock_bin/pacman" <<'STUB'
#!/bin/bash
if [[ $1 == "-Q" ]]; then
  exit 0
fi
printf 'pacman %s\n' "$*" >>"$TEST_CALLS"
exit 0
STUB

cat >"$mock_bin/sudo" <<'STUB'
#!/bin/bash
if [[ $1 == "-n" && $2 == "true" ]]; then
  [[ -f $TEST_SUDO_CACHED ]] && exit 0
  exit 1
fi
if [[ $1 == "-S" ]]; then
  IFS= read -r pw || pw=""
  if [[ $pw == "correct" ]]; then
    : >"$TEST_SUDO_CACHED"
    exit 0
  fi
  echo "Sorry, try again." >&2
  echo "sudo: no password was provided" >&2
  exit 1
fi
if [[ $1 == "-v" ]]; then
  printf 'sudo -v\n' >>"$TEST_CALLS"
  : >"$TEST_SUDO_CACHED"
  exit "${TEST_SUDO_V_STATUS:-0}"
fi
printf 'sudo %s\n' "$*" >>"$TEST_CALLS"
exec "$@"
STUB

chmod +x "$mock_bin/omarchy-pkg-missing" "$mock_bin/omarchy-hw-laptop-closed" \
  "$mock_bin/pacman" "$mock_bin/sudo"

run_pty() {
  python3 - "$@" <<'PY'
import os
import pty
import select
import signal
import sys
import time

action = sys.argv[1]
cmd = sys.argv[2:]

pid, master = pty.fork()
if pid == 0:
    os.execvpe(cmd[0], cmd, os.environ)

buf = bytearray()
deadline = time.monotonic() + 30.0

def wait_for(needle):
    while time.monotonic() < deadline:
        if needle in buf:
            return True
        r, _, _ = select.select([master], [], [], 0.05)
        if r:
            try:
                chunk = os.read(master, 4096)
            except OSError:
                break
            if not chunk:
                break
            buf.extend(chunk)
    return needle in buf

try:
    if action == "ctrl-c":
        if not wait_for(b"[sudo] password for "):
            sys.stderr.write("never saw password prompt; output=%r\n" % bytes(buf))
            sys.exit(99)
        # bash writes the prompt before it blocks in read(). A Ctrl-C that lands
        # in between only marks the trap pending and read() never returns, so
        # let bash reach read() first.
        time.sleep(0.5)
        os.write(master, b"\x03")
    elif action == "typo-then-ok":
        if not wait_for(b"[sudo] password for "):
            sys.stderr.write("never saw first prompt; output=%r\n" % bytes(buf))
            sys.exit(99)
        os.write(master, b"wrong\n")
        if not wait_for(b"Sorry, try again."):
            sys.stderr.write("never saw retry message; output=%r\n" % bytes(buf))
            sys.exit(99)
        while time.monotonic() < deadline:
            if buf.count(b"[sudo] password for ") >= 2:
                break
            r, _, _ = select.select([master], [], [], 0.05)
            if r:
                try:
                    chunk = os.read(master, 4096)
                except OSError:
                    break
                if not chunk:
                    break
                buf.extend(chunk)
        if buf.count(b"[sudo] password for ") < 2:
            sys.stderr.write("never saw second prompt; output=%r\n" % bytes(buf))
            sys.exit(99)
        os.write(master, b"correct\n")
    elif action == "exhaust-tries":
        seen = 0
        for _ in range(2):
            while time.monotonic() < deadline:
                if buf.count(b"[sudo] password for ") > seen:
                    seen += 1
                    break
                r, _, _ = select.select([master], [], [], 0.05)
                if r:
                    try:
                        chunk = os.read(master, 4096)
                    except OSError:
                        break
                    if not chunk:
                        break
                    buf.extend(chunk)
            os.write(master, b"wrong\n")
    elif action == "none":
        pass

    # Reap the child before closing the master: closing it first hangs up the
    # terminal, and the SIGHUP races the Ctrl-C under test.
    deadline = time.monotonic() + 30.0
    while True:
        if time.monotonic() >= deadline:
            os.kill(pid, signal.SIGKILL)
            os.waitpid(pid, 0)
            sys.stderr.write("timed out waiting for exit; output=%r\n" % bytes(buf))
            sys.exit(98)
        r, _, _ = select.select([master], [], [], 0.05)
        if r:
            try:
                chunk = os.read(master, 4096)
            except OSError:
                chunk = b""
            if not chunk:
                _, status = os.waitpid(pid, 0)
                break
            buf.extend(chunk)
        else:
            wpid, status = os.waitpid(pid, os.WNOHANG)
            if wpid == pid:
                break
finally:
    os.close(master)

sys.stdout.buffer.write(buf)
if os.WIFEXITED(status):
    sys.exit(os.WEXITSTATUS(status))
if os.WIFSIGNALED(status):
    sys.exit(128 + os.WTERMSIG(status))
sys.exit(1)
PY
}

# omarchy-pkg-add runs pacman directly without sudo authentication when EUID == 0.
if (( EUID == 0 )); then
  skip "omarchy-pkg-add skips sudo authentication when running as root"
else
  # 1. Ctrl-C at the password prompt cancels omarchy-pkg-add with 130 and starts no package command.
  calls="$test_tmp/calls-ctrlc"
  cached="$test_tmp/cached-ctrlc"
  : >"$calls"
  rm -f "$cached"
  status=0
  out=$(PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_CACHED="$cached" \
    OMARCHY_SUDO_PAM_FILE="$pam_dir/sudo-password" \
    run_pty ctrl-c "$ROOT/bin/omarchy-pkg-add" demo-pkg 2>&1) || status=$?
  (( status == 130 )) || fail "Ctrl-C at the password prompt exits 130" "status=$status out=$out"
  [[ ! -s $calls ]] || fail "Ctrl-C at the password prompt starts no package command" "$(<"$calls")"
  pass "Ctrl-C at the password prompt cancels omarchy-pkg-add with 130 and starts no package command"

  # 2. A password typo retries and completes once the right password is entered.
  calls="$test_tmp/calls-retry"
  cached="$test_tmp/cached-retry"
  : >"$calls"
  rm -f "$cached"
  status=0
  out=$(PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_CACHED="$cached" \
    OMARCHY_SUDO_PAM_FILE="$pam_dir/sudo-password" \
    run_pty typo-then-ok "$ROOT/bin/omarchy-pkg-add" demo-pkg 2>&1) || status=$?
  (( status == 0 )) || fail "a password typo retries and succeeds on the next attempt" "status=$status out=$out"
  grep -Fx 'pacman -S --noconfirm --needed -- demo-pkg' "$calls" >/dev/null ||
    fail "pacman runs after password retry succeeds" "$(<"$calls")"
  pass "a password typo retries and installs after the right password"

  # 3. Exhausting password tries exits 1 without starting pacman.
  calls="$test_tmp/calls-exhaust"
  cached="$test_tmp/cached-exhaust"
  : >"$calls"
  rm -f "$cached"
  status=0
  out=$(PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_CACHED="$cached" \
    OMARCHY_SUDO_PAM_FILE="$pam_dir/sudo-password" OMARCHY_SUDO_PASSWD_TRIES=2 \
    run_pty exhaust-tries "$ROOT/bin/omarchy-pkg-add" demo-pkg 2>&1) || status=$?
  (( status == 1 )) || fail "exhausting password tries exits 1" "status=$status out=$out"
  [[ $out == *"2 incorrect password attempts"* ]] || fail "exhausting tries reports the limit" "$out"
  [[ ! -s $calls ]] || fail "exhausting password tries starts no package command" "$(<"$calls")"
  pass "exhausting password tries exits 1 without starting pacman"

  # 4. Fingerprint and FIDO2 PAM configs delegate straight to sudo -v without a password prompt.
  for kind in fprintd fido2; do
    calls="$test_tmp/calls-$kind"
    cached="$test_tmp/cached-$kind"
    : >"$calls"
    rm -f "$cached"
    status=0
    out=$(PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_CACHED="$cached" \
      OMARCHY_SUDO_PAM_FILE="$pam_dir/sudo-$kind" TEST_LID_CLOSED_STATUS=1 \
      run_pty none "$ROOT/bin/omarchy-pkg-add" demo-pkg 2>&1) || status=$?
    (( status == 0 )) || fail "$kind PAM config succeeds via sudo -v" "status=$status out=$out"
    [[ $out != *"[sudo] password for "* ]] || fail "$kind PAM config must not show shell password prompt" "$out"
    grep -Fx 'sudo -v' "$calls" >/dev/null || fail "$kind PAM config delegates to sudo -v" "$(<"$calls")"
    grep -Fx 'pacman -S --noconfirm --needed -- demo-pkg' "$calls" >/dev/null ||
      fail "$kind PAM config installs after sudo -v" "$(<"$calls")"
  done
  pass "fingerprint and FIDO2 PAM configs reach device auth without a password prompt"

  # 5. Fingerprint with closed lid (clamshell gate) falls back to the shell password prompt.
  calls="$test_tmp/calls-closed"
  cached="$test_tmp/cached-closed"
  : >"$calls"
  rm -f "$cached"
  status=0
  out=$(PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_CACHED="$cached" \
    OMARCHY_SUDO_PAM_FILE="$pam_dir/sudo-fprintd" TEST_LID_CLOSED_STATUS=0 \
    run_pty ctrl-c "$ROOT/bin/omarchy-pkg-add" demo-pkg 2>&1) || status=$?
  (( status == 130 )) || fail "clamshell-gated fingerprint uses the Ctrl-C-able password prompt" "status=$status out=$out"
  [[ ! -s $calls ]] || fail "clamshell-gated cancel runs neither sudo -v nor pacman" "$(<"$calls")"
  pass "clamshell-gated fingerprint falls back to the shell password prompt"
fi

# 6. Sourcing omarchy-sudo-keepalive cancels cleanly on Ctrl-C without running later steps.
calls="$test_tmp/calls-keepalive"
cached="$test_tmp/cached-keepalive"
: >"$calls"
rm -f "$cached"
status=0
out=$(PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_CACHED="$cached" \
  OMARCHY_SUDO_PAM_FILE="$pam_dir/sudo-password" \
  run_pty ctrl-c bash -c 'source omarchy-sudo-keepalive; printf "continued\n" >>"$TEST_CALLS"' 2>&1) || status=$?
(( status == 130 )) || fail "Ctrl-C in omarchy-sudo-keepalive exits 130" "status=$status out=$out"
[[ ! -s $calls ]] || fail "Ctrl-C in omarchy-sudo-keepalive stops before later commands" "$(<"$calls")"
pass "Ctrl-C in omarchy-sudo-keepalive exits 130 without running later commands"
