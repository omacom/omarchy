#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export TEST_LOG="$test_tmp/log"
export PATH="$test_tmp:$ROOT/bin:$PATH"
printf '#!/bin/bash\n:\n' >"$test_tmp/omarchy-restart-gum"
cp "$test_tmp/omarchy-restart-gum" "$test_tmp/omarchy-show-logo"
cat >"$test_tmp/setsid" <<'STUB'
#!/bin/bash
while (( $# >= 3 )); do
  if [[ $1 == "bash" && $2 == "-c" ]]; then
    exec bash -c "$3"
  fi
  shift
done
exit 97
STUB
cat >"$test_tmp/omarchy-show-done" <<'STUB'
#!/bin/bash
printf '%s\n' "$1" >>"$TEST_LOG"
STUB
chmod +x "$test_tmp"/omarchy-* "$test_tmp/setsid"

for status in 0 7 19 130; do
  : >"$TEST_LOG"
  actual=0
  "$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" "exit $status" || actual=$?
  (( actual == status )) || fail "presentation preserves exit status $status" "got $actual"
  if (( status == 130 )); then
    [[ ! -s $TEST_LOG ]] || fail "cancellation closes without a completion prompt"
  else
    [[ $(cat "$TEST_LOG") == "$status" ]] || fail "completion receives the command status"
  fi
done
pass "success, failure, explicit exits and cancellation retain their status"

actual=0
"$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" 'false && echo unreachable' || actual=$?
(( actual == 1 )) || fail "compound commands retain their failure status"
pass "shell command lists still work inside the presentation"

python3 - "$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" "$TEST_LOG" <<'PYTEST'
import os, pty, select, signal, sys, time
launcher, log = sys.argv[1:]
open(log, 'w').close()
pid, fd = pty.fork()
if pid == 0:
    os.execv(launcher, [launcher, 'printf interrupt-ready; sleep 30'])
try:
    output = b''
    deadline = time.monotonic() + 5
    while b'interrupt-ready' not in output:
        if time.monotonic() >= deadline:
            raise AssertionError('presentation command never reached its interruptible state')
        if select.select([fd], [], [], 0.1)[0]:
            output += os.read(fd, 4096)
    os.write(fd, b'\x03')
    while True:
        waited, status = os.waitpid(pid, os.WNOHANG)
        if waited:
            assert os.waitstatus_to_exitcode(status) in (130, -signal.SIGINT), status
            pid = None
            break
        if time.monotonic() >= deadline:
            raise AssertionError('Ctrl-C did not close the presentation')
        time.sleep(0.01)
    assert not open(log).read(), 'Ctrl-C displayed a completion prompt'
finally:
    if pid is not None:
        os.killpg(pid, signal.SIGKILL)
        os.waitpid(pid, 0)
    os.close(fd)
PYTEST
pass "terminal Ctrl-C closes without a completion prompt"
