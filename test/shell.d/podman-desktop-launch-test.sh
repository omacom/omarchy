#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PY'
import os
from pathlib import Path
import socket
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    binary = fixture / 'bin';binary.mkdir()
    adapter = fixture / 'source/default/podman/desktop';adapter.mkdir(parents=True)
    runtime = fixture / 'runtime/podman';runtime.mkdir(parents=True)
    log = fixture / 'calls'
    environment = dict(os.environ, OMARCHY_PATH=str(fixture / 'source'),
                       XDG_RUNTIME_DIR=str(fixture / 'runtime'), TEST_LOG=str(log),
                       PATH=str(binary) + ':' + os.environ['PATH'])
    def script(path, contents):
        path.write_text(contents);path.chmod(0o755)
    script(binary / 'systemctl', '''#!/bin/bash
printf 'systemctl %s\\n' "$*" >>"$TEST_LOG"
[[ ${FAIL_SOCKET:-0} == 0 ]] || exit 1
if [[ $* == '--user restart podman.socket' ]]; then
  python3 -c 'import os,socket; s=socket.socket(socket.AF_UNIX); s.bind(os.environ["XDG_RUNTIME_DIR"]+"/podman/podman.sock")'
fi
''')
    script(binary / 'real-podman', '#!/bin/bash\nprintf "backend %s\\n" "$*" >>"$TEST_LOG"\n')
    script(binary / 'desktop', '#!/bin/bash\nprintf "desktop %s\\n" "$*" >>"$TEST_LOG"\npodman system service --time=0\npodman version\n')
    script(adapter / 'podman', (root / 'default/podman/desktop/podman').read_text().replace('/usr/bin/podman', str(binary / 'real-podman')))
    launcher = fixture / 'launch'
    script(launcher, (root / 'bin/omarchy-launch-podman').read_text().replace('/usr/bin/podman-desktop', str(binary / 'desktop')))
    endpoint = runtime / 'podman.sock'
    with socket.socket(socket.AF_UNIX) as server:
        server.bind(str(endpoint))
        inode = endpoint.stat().st_ino
        subprocess.run([str(launcher), '--test-argument'], env=environment, check=True)
        assert endpoint.stat().st_ino == inode
    calls = log.read_text()
    assert 'desktop --test-argument' in calls and 'backend version' in calls
    assert 'backend system service' not in calls
    assert 'stop podman.service' not in calls
    endpoint.unlink();log.write_text('')
    subprocess.run([str(launcher)], env=environment, check=True)
    calls = log.read_text()
    assert calls.index('stop podman.service') < calls.index('restart podman.socket') < calls.index('desktop ')
    log.write_text('')
    result = subprocess.run([str(launcher)], env=dict(environment, FAIL_SOCKET='1'))
    assert result.returncode != 0 and 'desktop ' not in log.read_text()
    script(binary / 'omarchy-launch-tui', '''#!/bin/bash
printf '%s\\n' "$@" >>"$TEST_LOG"
''')
    script(binary / 'podman', '''#!/bin/bash
[[ ${FAIL_CONNECTIONS:-0} == 0 ]] || exit 1
if [[ $* == 'system connection list --format {{.Name}}' ]]; then
  printf '%s' "${EXISTING_CONNECTIONS:-}"
else
  printf '%s\\n' "$*" >>"$TEST_LOG"
fi
''')
    script(launcher, (root / 'bin/omarchy-launch-podman-tui').read_text())
    log.write_text('')
    subprocess.run([str(launcher), '--log-file', 'path with spaces'], env=environment, check=True)
    calls = log.read_text()
    assert calls.splitlines() == ['systemctl --user start podman.socket',
                                 'system connection add omarchy-local unix://' + str(endpoint),
                                 'podman-tui', '--log-file', 'path with spaces'], calls
    log.write_text('')
    subprocess.run([str(launcher)], env=dict(environment, EXISTING_CONNECTIONS='my-server'), check=True)
    assert 'connection add' not in log.read_text()
    log.write_text('')
    result = subprocess.run([str(launcher)], env=dict(environment, FAIL_CONNECTIONS='1'))
    assert result.returncode != 0 and 'podman-tui' not in log.read_text()
    endpoint.unlink();log.write_text('')
    subprocess.run([str(launcher)], env=environment, check=True)
    calls = log.read_text()
    assert calls.index('stop podman.service') < calls.index('restart podman.socket') < calls.index('podman-tui')
    log.write_text('')
    result = subprocess.run([str(launcher)], env=dict(environment, FAIL_SOCKET='1'))
    assert result.returncode != 0 and 'podman-tui' not in log.read_text()
print('ok - Desktop reuses the managed API, forwards other commands and preserves launcher arguments')
print('ok - a missing socket is repaired without stopping containers; service failure prevents launch')
print('ok - Podman TUI uses the user socket and styled terminal, preserves arguments, and aborts on service failure')
PY
