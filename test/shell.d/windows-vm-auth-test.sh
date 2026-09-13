#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PY'
import os
import pty
import subprocess
import tempfile
from pathlib import Path

script = r'''
set -e
set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null
priv_target() { printf '/fixture/omarchy-windows-vm\n'; }
sudo() { printf sudo >"$MODE_LOG"; printf exited; }
pkexec() { printf pkexec >"$MODE_LOG"; printf exited; }
migrate_legacy_compose() { :; }
status_windows
'''
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    (root / 'docker-compose.yml').touch()
    log = root / 'mode'
    env = dict(os.environ, OMARCHY_WINDOWS_DIR=str(root), MODE_LOG=str(log), HOME=str(root))
    for name, terminal_input, terminal_error, expected in (
            ('terminal status', True, True, 'sudo'),
            ('redirected stdin', False, True, 'sudo'),
            ('graphical caller', False, False, 'pkexec')):
        master, slave = pty.openpty()
        try:
            result = subprocess.run(['/bin/bash', '-c', script], env=env,
                                    stdin=slave if terminal_input else subprocess.DEVNULL,
                                    stdout=subprocess.PIPE,
                                    stderr=slave if terminal_error else subprocess.PIPE,
                                    text=True, timeout=10)
            assert result.returncode == 0, (name, result.stdout, result.stderr)
            assert log.read_text() == expected, (name, log.read_text(), expected)
            assert 'Windows VM is stopped' in result.stdout
        finally:
            os.close(slave)
            os.close(master)
        print(f'ok - {name} uses {expected} while privileged status output is captured')
PY
