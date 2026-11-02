#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 - "$ROOT/bin/omarchy-plugin-cleanup-runner" <<'PY'
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile

runner = sys.argv[1]
with tempfile.TemporaryDirectory() as scratch:
    root = Path(scratch)
    hook = root / "cleanup"
    receipt = root / "completed"
    environment = {
        b"PATH": os.fsencode(os.environ["PATH"]),
        b"HOME": os.fsencode(scratch),
        b"PRIVATE_TOKEN": b"secret with newline\n$HOME %n = value",
        b"RAW_VALUE": b"\xff",
        b"PYTHONCOERCECLOCALE": b"0",
        b"PYTHONUTF8": b"1",
    }
    payload = b"".join(key + b"=" + value + b"\0" for key, value in environment.items())

    def install(body):
        hook.write_text("#!/usr/bin/env python3\n" + body)
        hook.chmod(0o700)
        receipt.unlink(missing_ok=True)

    def run():
        return subprocess.run(
            [sys.executable, "-I", runner, "./cleanup", str(receipt)],
            input=payload, cwd=root,
            env={**os.environ, "MANAGER_ONLY": "must not reach hook"},
            capture_output=True,
        )

    install('''import os
from pathlib import Path
import sys
assert Path.cwd() == Path.home().resolve()
assert len(sys.argv) == 1
assert sys.stdin.buffer.read() == b""
assert "MANAGER_ONLY" not in os.environ
assert os.environb[b"PRIVATE_TOKEN"] == b"secret with newline\\n$HOME %n = value"
assert os.environb[b"RAW_VALUE"] == b"\\xff"
Path("cleaned").touch()
''')
    result = run()
    assert result.returncode == 0, result.stderr
    assert (root / "cleaned").is_file() and receipt.read_bytes() == b"ok\n"
    assert receipt.stat().st_mode & 0o777 == 0o600
    print("ok - runner preserves private environment bytes, cwd, arguments, and stdin EOF")

    for sig in (signal.SIGHUP, signal.SIGINT, signal.SIGTERM, signal.SIGPIPE):
        install(f"import os, signal\nsignal.signal({int(sig)}, signal.SIG_DFL)\nos.kill(os.getpid(), {int(sig)})\n")
        result = run()
        assert result.returncode != 0 and not receipt.exists(), (sig, result.returncode)
    print("ok - signal termination never produces a successful completion receipt")

    install("raise SystemExit(23)\n")
    result = run()
    assert result.returncode == 23 and not receipt.exists()
    hook.unlink()
    result = run()
    assert result.returncode != 0 and not receipt.exists()
    print("ok - nonzero exit and failure to start retain failure status without a receipt")

    # Kill only the runner we started. The hook's finite sleep prevents an
    # orphaned fixture from hanging this standalone test without systemd.
    install('''from pathlib import Path
import time
Path("started").touch()
time.sleep(1)
''')
    process = subprocess.Popen(
        [sys.executable, "-I", runner, "./cleanup", str(receipt)],
        cwd=root, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    try:
        process.stdin.write(payload)
        process.stdin.close()
        import time
        deadline = time.monotonic() + 5
        while not (root / "started").exists() and time.monotonic() < deadline:
            time.sleep(0.01)
        assert (root / "started").exists(), "hook did not start"
        process.terminate()
        assert process.wait(timeout=5) != 0 and not receipt.exists()
        # Pipe EOF also waits for the finite child to release its descriptors.
        process.stdout.read()
        process.stderr.read()
    finally:
        if process.poll() is None:
            process.kill()
            process.wait()
        process.stdout.close()
        process.stderr.close()
    print("ok - interrupted runner cannot leave a successful completion receipt")
PY
