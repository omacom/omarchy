#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Keys that reach fzf after it has taken the terminal but before the rows are
# drawn. fzf writes its cursor-position query (ESC [ 6 n) right after switching
# the terminal to raw mode, so the keys are sent the moment that query appears.
if ! command -v fzf >/dev/null || ! command -v python3 >/dev/null; then
  skip "real fzf startup key check skipped"
  exit 0
fi

python3 - "$ROOT/bin/omarchy-confirm" <<'PY'
import fcntl, os, pty, select, signal, struct, sys, termios, time

script = sys.argv[1]

def run(keys, args):
    pid, fd = pty.fork()
    if pid == 0:
        fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
        env = os.environ.copy()
        env.pop("OMARCHY_PATH", None)
        env.pop("FZF_DEFAULT_OPTS", None)
        env.pop("FZF_DEFAULT_OPTS_FILE", None)
        env["PATH"] = os.path.dirname(script) + os.pathsep + env.get("PATH", "")
        os.execvpe(script, [script, *args], env)
    out = b""
    sent = False
    deadline = time.time() + 8
    try:
        while True:
            ready, _, _ = select.select([fd], [], [], 0.01)
            if ready:
                try:
                    out += os.read(fd, 4096)
                except OSError:
                    pass
                if not sent and b"\x1b[6n" in out:
                    os.write(fd, keys)
                    sent = True
            wpid, status = os.waitpid(pid, os.WNOHANG)
            if wpid != 0:
                return os.waitstatus_to_exitcode(status)
            if time.time() > deadline:
                os.killpg(pid, signal.SIGTERM)
                os.waitpid(pid, 0)
                return 124
    finally:
        os.close(fd)

cases = [
    (b"\r", ["--default=false", "Remove?"], 1),
    (b"l\r", ["Continue?"], 1),
    (b"n", ["Continue?"], 1),
    (b"y", ["Continue?"], 0),
]
failed = False
for keys, args, expect in cases:
    results = [run(keys, args) for _ in range(20)]
    wrong = [rc for rc in results if rc != expect]
    if wrong:
        print(f"not ok - startup keys={keys!r} args={args}: {len(wrong)} of 20 runs returned {sorted(set(wrong))}, expected {expect}", file=sys.stderr)
        failed = True
    else:
        print(f"ok - startup keys={keys!r} args={args}: 20 of 20 runs returned {expect}")
sys.exit(1 if failed else 0)
PY
pass "confirm answers keys typed while the prompt opens"
