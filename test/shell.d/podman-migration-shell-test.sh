#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PYTEST'
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
with tempfile.TemporaryDirectory() as directory:
    work = Path(directory)
    stubs = work / 'bin'
    stubs.mkdir()
    home = work / 'home'
    (home / '.local/state/omarchy').mkdir(parents=True)
    (home / '.local/state/omarchy/preinstalls-removed').touch()
    log = work / 'calls'
    stub = r'''#!/bin/bash
set -eu
name=${0##*/}
printf '%s|%s|%s|%s\n' "$name" "$*" "${XDG_RUNTIME_DIR:-missing}" "${DBUS_SESSION_BUS_ADDRESS:-missing}" >>"$TEST_LOG"
case "$name" in
  id)
    case "$1" in -u) echo 1000;; -nG) echo users;; *) exit 92;; esac ;;
  systemctl)
    if [[ $* == '--user show-environment' ]]; then
      [[ ${XDG_RUNTIME_DIR:-} == /run/user/1000 && ${DBUS_SESSION_BUS_ADDRESS:-} == unix:path=/run/user/1000/bus ]] || exit 93
      [[ $TEST_BUS == available ]] || exit 1
    fi ;;
  sudo)
    # No command ever reaches real sudo or changes system configuration.
    case "$1" in
      test) exit 1;;
      python3) [[ $2 != - ]] || cat >/dev/null;;
      systemctl|docker|ufw|pacman|env) exec "$@";;
      *) exit 94;;
    esac ;;
  pacman)
    [[ $TEST_ENGINE != broken ]] || exit 2
    if [[ $* == '-Qq docker' ]]; then
      [[ $TEST_ENGINE != missing ]] || exit 1
      echo "$TEST_ENGINE"
    fi ;;
  omarchy-cmd-present) [[ $1 == ufw && $TEST_UFW == available ]] ;;
  ufw) [[ $TEST_UFW == available ]] || exit 127 ;;
  python3|docker|podman|omarchy-pkg-add|omarchy-pkg-drop|omarchy-state|dbus-update-activation-environment|omarchy-refresh-pacman) ;;
  *) exit 95;;
esac
'''
    for name in ('id', 'sudo', 'systemctl', 'pacman', 'python3', 'docker', 'podman', 'ufw',
                 'omarchy-pkg-add', 'omarchy-pkg-drop', 'omarchy-state',
                 'dbus-update-activation-environment', 'omarchy-refresh-pacman', 'omarchy-cmd-present'):
        path = stubs / name
        path.write_text(stub)
        path.chmod(0o755)
    env = dict(os.environ, PATH=f'{stubs}:/usr/bin', HOME=str(home), USER='fixture',
               OMARCHY_PATH=str(root), TEST_LOG=str(log), TEST_ENGINE='docker', TEST_BUS='available', TEST_UFW='available')
    for name in ('XDG_RUNTIME_DIR', 'DBUS_SESSION_BUS_ADDRESS', 'DOCKER_HOST', 'DOCKER_CONTEXT'):
        env.pop(name, None)
    migration = root / 'migrations/1788886195.sh'
    def run(path, **settings):
        log.write_text('')
        result = subprocess.run(['/bin/bash', '-euo', 'pipefail', str(path)], env=env | settings,
                                stdin=subprocess.DEVNULL, capture_output=True, text=True)
        return result, log.read_text().splitlines()
    result, calls = run(migration, TEST_BUS='missing')
    assert result.returncode != 0
    assert 'Log in as fixture' in result.stderr, result.stderr
    assert not any(c.startswith(('sudo|', 'podman|', 'omarchy-pkg-add|')) for c in calls), calls
    result, calls = run(migration)
    assert result.returncode == 0, (result.stdout, result.stderr, calls)
    assert not any(c.startswith('omarchy-pkg-drop|docker ') for c in calls), calls
    swap = next(i for i, c in enumerate(calls) if c.startswith('pacman|-S --needed --noconfirm --ask 4 podman-docker|'))
    transfer = next(i for i, c in enumerate(calls) if c.startswith('python3|') and 'migrate-databases.py' in c and '--check' not in c)
    assert transfer < swap, calls
    assert any(c.startswith('podman|') and '|/run/user/1000|unix:path=/run/user/1000/bus' in c for c in calls)
    print('ok - migration restores the local user environment, refuses a missing bus before changes and swaps the Docker provider after transfer')

    result, calls = run(migration, TEST_UFW='missing')
    assert result.returncode == 0, (result.stderr, calls)
    assert not any(c.startswith(('ufw|', 'sudo|ufw ')) for c in calls), calls
    assert any(c.startswith('pacman|-S --needed --noconfirm --ask 4 podman-docker|') for c in calls)
    print('ok - hosts without UFW complete migration without invoking the missing firewall tool')

    repair = root / 'bin/omarchy-reinstall-pkgs'
    for engine in ('docker', 'docker-git'):
        result, calls = run(migration, TEST_ENGINE=engine)
        assert result.returncode == 0, (engine, result.stderr)
        swap = next(i for i, c in enumerate(calls) if c.startswith('pacman|-S --needed --noconfirm --ask 4 podman-docker|'))
        transfer = next((i for i, c in enumerate(calls) if c.startswith('python3|') and 'migrate-databases.py' in c and '--check' not in c), None)
        assert transfer is not None and transfer < swap, (engine, 'provider replaced without workload transfer', calls)
    print('ok - alternate Docker providers receive full workload preflight and transfer before replacement')

    for engine in ('docker', 'docker-git', 'podman-docker', 'missing'):
        result, calls = run(repair, TEST_ENGINE=engine)
        assert result.returncode == 0, result.stderr
        install = next(c.split('|')[1].split() for c in calls if c.startswith('pacman|-Syu '))
        assert 'podman-docker' not in install, (engine, install)
        assert 'podman' in install and 'podman-compose' in install, install
    print('ok - package repair retains all real Docker providers while migration is pending')
    result, calls = run(migration, TEST_ENGINE='missing')
    assert result.returncode == 0, (result.stdout, result.stderr)
    assert not any(c.startswith('pacman|-S ') and 'podman-docker' in c for c in calls), calls
    assert not any(c.startswith('dbus-update-activation-environment|') for c in calls), calls
    assert not any(c.startswith('omarchy-pkg-drop|') for c in calls), calls
    print('ok - native Podman users do not acquire optional Docker compatibility on migration')
    for path in (migration, repair):
        result, calls = run(path, TEST_ENGINE='broken')
        assert result.returncode != 0, (path, 'failed package query treated as no engine')
        assert not any(c.startswith(('omarchy-pkg-add|', 'podman|', 'pacman|-Syu ')) for c in calls), calls
    print('ok - failed provider/database queries prevent engine replacement')
PYTEST
