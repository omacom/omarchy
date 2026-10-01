#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v fzf >/dev/null || ! command -v python3 >/dev/null; then
  skip "real fzf mouse check skipped"
  exit 0
fi

python3 - "$ROOT/bin/omarchy-confirm" <<'PY'
import fcntl, os, pty, select, signal, struct, sys, termios, time

script = sys.argv[1]

def click(row, args):
    pid, fd = pty.fork()
    if pid == 0:
        fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
        env = os.environ.copy()
        env.pop("OMARCHY_PATH", None)
        env.pop("FZF_DEFAULT_OPTS_FILE", None)
        env["FZF_DEFAULT_OPTS"] = "--no-mouse --tac"
        env["TERM"] = "xterm-256color"
        env["PATH"] = os.path.dirname(script) + os.pathsep + env.get("PATH", "")
        os.execvpe(script, [script, *args], env)
    out = b""
    answered_queries = 0
    clicked = False
    deadline = time.monotonic() + 8
    try:
        while True:
            ready, _, _ = select.select([fd], [], [], 0.01)
            if ready:
                try:
                    out += os.read(fd, 65536)
                except OSError:
                    pass
                # The inline widget starts at row 1: header, Yes, then No.
                # Answer every cursor query so fzf uses the same mouse origin.
                query_count = out.count(b"\x1b[6n")
                if query_count > answered_queries:
                    os.write(fd, b"\x1b[1;1R" * (query_count - answered_queries))
                    answered_queries = query_count
                if not clicked and b"Yes" in out and b"No" in out and b"\x1b[?1006h" in out:
                    # SGR left-button press and release on the visible label.
                    os.write(fd, f"\x1b[<0;3;{row}M\x1b[<0;3;{row}m".encode())
                    clicked = True
            wpid, status = os.waitpid(pid, os.WNOHANG)
            if wpid:
                return os.waitstatus_to_exitcode(status), clicked
            if time.monotonic() > deadline:
                os.killpg(pid, signal.SIGTERM)
                os.waitpid(pid, 0)
                return 124, clicked
    finally:
        os.close(fd)

cases = [
    (2, ["Continue?"], 0),
    (3, ["Continue?"], 1),
    (2, ["--default=false", "Remove?"], 0),
    (3, ["--default=false", "Remove?"], 1),
]
failed = False
for row, args, expected in cases:
    rc, clicked = click(row, args)
    if rc != expected or not clicked:
        print(f"not ok - real fzf click row={row} args={args} rc={rc} expected={expected} clicked={clicked}", file=sys.stderr)
        failed = True
    else:
        print(f"ok - real fzf click row={row} args={args} returns {expected}")
sys.exit(1 if failed else 0)
PY
pass "real mouse clicks choose Yes and No independently of the default and inherited options"
