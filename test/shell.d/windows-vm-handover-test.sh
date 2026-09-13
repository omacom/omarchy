#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PY'
import os
import subprocess
import tempfile
from pathlib import Path

with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    startup = fixture / 'startup.sh'
    startup.write_text('''
pacman() {
  printf 'query\\n' >>"$QUERY_LOG"
  if [[ $1 == -Qq && ${2:-} == docker ]]; then
    case "$PROVIDER" in
      absent|broken) return 1 ;;
      *) printf '%s\\n' "$PROVIDER" ;;
    esac
  else
    [[ $PROVIDER != broken ]]
  fi
}
gum() { printf 'prompt\\n' >>"$ACTION_LOG"; return 0; }
podman() { printf 'engine\\n' >>"$ACTION_LOG"; return 1; }
podman-compose() { printf 'engine\\n' >>"$ACTION_LOG"; return 0; }
sudo() { printf 'elevation\\n' >>"$ACTION_LOG"; return 1; }
pkexec() { printf 'elevation\\n' >>"$ACTION_LOG"; return 1; }
''')
    action_log = fixture / 'actions'
    query_log = fixture / 'queries'
    home = fixture / 'home'
    disk = home / '.windows/disk.img'
    env = dict(os.environ, BASH_ENV=str(startup), HOME=str(home),
               OMARCHY_WINDOWS_DIR=str(fixture / 'runtime'),
               ACTION_LOG=str(action_log), QUERY_LOG=str(query_log))

    def invoke(provider, action):
        action_log.unlink(missing_ok=True)
        query_log.unlink(missing_ok=True)
        disk.parent.mkdir(parents=True, exist_ok=True)
        disk.write_text('retained Docker disk')
        return subprocess.run(['/bin/bash', os.environ['ROOT'] + '/bin/omarchy-windows-vm', action],
                              env=dict(env, PROVIDER=provider), capture_output=True, text=True, timeout=10)

    # Removal without a compose file still reaches user-side disk cleanup.
    # Run this first so the old implementation fails without any engine call.
    for provider in ('docker', 'docker-git', 'broken'):
        for action in ('remove', 'install', 'launch', 'start', 'stop', 'down', 'status', '__priv'):
            result = invoke(provider, action)
            assert result.returncode != 0, (provider, action, result.stdout, result.stderr)
            assert disk.read_text() == 'retained Docker disk', (provider, action)
            assert not action_log.exists(), (provider, action, action_log.read_text())
            assert ('migration is pending' if provider != 'broken' else 'Cannot verify') in result.stderr
        print(f'ok - {provider} blocks every Windows action before prompts, elevation, engines or disk cleanup')

    for provider in ('podman-docker', 'absent'):
        result = invoke(provider, 'status')
        assert result.returncode == 1 and 'Windows VM not configured' in result.stdout, (provider, result.stdout, result.stderr)
        assert disk.exists()
        result = invoke(provider, 'remove')
        assert result.returncode == 0, (provider, result.stdout, result.stderr)
        assert not disk.exists(), provider
        assert action_log.read_text() == 'prompt\n'
        print(f'ok - {provider} allows ordinary status and confirmed user-side cleanup')

    result = invoke('broken', 'help')
    assert result.returncode == 0 and 'Usage:' in result.stdout
    assert not query_log.exists() and not action_log.exists() and disk.exists()
    print('ok - help remains available without querying the engine package')
PY
