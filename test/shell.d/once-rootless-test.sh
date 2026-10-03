#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - "$ROOT" <<'PY'
import importlib.util
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile
from types import SimpleNamespace
from unittest.mock import patch

root = Path(sys.argv[1])
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('once_launcher', root / 'default/once/launch.py')
launcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(launcher)

class Executed(Exception):
    pass

def simulate(engine='podman', uid=1000, version='v0.3.2-omarchy1', rootless=True, socket_owner=1000, engine_ready=True):
    captured = {}
    def metadata(path):
        if str(path).endswith('.sock'):
            return SimpleNamespace(st_uid=socket_owner, st_mode=stat.S_IFSOCK | 0o600)
        return SimpleNamespace(st_uid=1000, st_mode=stat.S_IFDIR | 0o700)
    def execute(binary, args, env):
        captured.update(binary=binary, args=args, env=env)
        raise Executed()
    poison = dict(os.environ, DOCKER_HOST='tcp://remote.example:2375', DOCKER_CONTEXT='remote',
                  DOCKER_API_VERSION='1.99', DOCKER_TLS_VERIFY='1', DOCKER_CERT_PATH='/remote',
                  XDG_RUNTIME_DIR='/tmp/not-the-user-runtime', ONCE_ROOTLESS='0')
    with patch.dict(os.environ, poison, clear=True), patch.object(launcher.os, 'getuid', return_value=uid), \
         patch.object(launcher.os, 'umask'), patch.object(launcher.Path, 'stat', metadata), \
         patch.object(launcher.Path, 'is_file', return_value=engine_ready), \
         patch.object(launcher.subprocess, 'check_output', return_value=version), \
         patch.object(launcher.subprocess, 'run') as start, \
         patch.object(launcher, 'engine_info', return_value={'SecurityOptions': ['name=rootless'] if rootless else []}) as info, \
         patch.object(launcher.os, 'execvpe', execute):
        try:
            launcher.main(engine, ['list'])
        except Executed:
            pass
        except RuntimeError as error:
            captured['error'] = str(error)
        captured['start_calls'] = start.call_args_list
        captured['info_calls'] = info.call_args_list
    return captured

for engine, endpoint, unit in (
    ('podman', '/run/user/1000/podman/podman.sock', 'podman.socket'),
    ('docker', '/run/user/1000/docker.sock', 'docker.service'),
):
    result = simulate(engine)
    assert result['args'] == ['once', '--namespace', 'omarchy-once', 'list'], result
    env = result['env']
    assert {k: v for k, v in env.items() if k.startswith('DOCKER_')} == {'DOCKER_HOST': 'unix://' + endpoint}
    assert env['ONCE_ROOTLESS'] == env['ONCE_NO_SELF_UPDATE'] == '1'
    assert env['XDG_RUNTIME_DIR'] == '/run/user/1000'
    assert result['start_calls'][0].args[0] == ['systemctl', '--user', 'start', unit]
    assert result['info_calls'][0].args == (endpoint,)
print('ok - ONCE pins each local engine and clears remote Docker overrides')

for options in ({'uid': 0}, {'version': 'v0.3.2'}):
    result = simulate(**options)
    assert 'error' in result and not result['start_calls'], result
for options in ({'rootless': False}, {'socket_owner': 0}):
    result = simulate(**options)
    assert 'error' in result and 'env' not in result, result
result = simulate(engine='docker', engine_ready=False)
assert 'not initialized' in result['error'] and not result['start_calls'], result
print('ok - root, an unpatched binary, uninitialized Docker, foreign sockets and rootful engines cannot launch ONCE')

with tempfile.TemporaryDirectory() as directory:
    directory = Path(directory)
    log = directory / 'calls'
    for name in ('systemctl', 'sudo', 'pacman', 'omarchy-pkg-add', 'omarchy-launch-once'):
        script = directory / name
        script.write_text('''#!/bin/bash
echo "${0##*/}|$*" >> "$TEST_LOG"
if [[ ${0##*/} == pacman ]]; then
  [[ ${TEST_ONCE_PROVIDER:-missing} != broken ]] || exit 1
  if [[ $* == "-Qq once" ]]; then
    [[ ${TEST_ONCE_PROVIDER:-missing} != missing ]] || exit 1
    echo "$TEST_ONCE_PROVIDER"
  elif [[ $* != "-Qq" ]]; then
    exit 2
  fi
elif [[ ${0##*/} == systemctl && $* == "--user is-enabled --quiet omarchy-once.service" ]]; then
  [[ ${TEST_ONCE_ENABLED:-0} == 1 ]]
elif [[ ${0##*/} == systemctl && $1 != --user ]]; then
  [[ ${TEST_LEGACY:-none} == "$1" ]]
elif [[ ${0##*/} == omarchy-launch-once && ${TEST_FAIL_LAUNCH:-0} == 1 ]]; then
  exit 1
fi
''')
        script.chmod(0o755)
    home = directory / 'home'
    marker = home / '.local/state/omarchy/rootless-docker/enabled'
    marker.parent.mkdir(parents=True)
    def install(engine_ready=True, **settings):
        if engine_ready:
            marker.touch()
        else:
            marker.unlink(missing_ok=True)
        log.write_text('')
        env = dict(os.environ, PATH=f'{directory}:/usr/bin', HOME=str(home), TEST_LOG=str(log), **settings)
        process = subprocess.run(['bash', str(root / 'bin/omarchy-install-service-once')], env=env, capture_output=True, text=True)
        return process, log.read_text().splitlines()
    for state in ('is-active', 'is-enabled'):
        result, calls = install(TEST_LEGACY=state)
        assert result.returncode != 0, result
        assert not any(call.startswith(('sudo|', 'omarchy-pkg-add|', 'omarchy-launch-once|')) for call in calls), calls
    for provider in ('once-bin', 'once-custom', 'broken'):
        result, calls = install(TEST_ONCE_PROVIDER=provider)
        assert result.returncode != 0, (provider, result)
        assert not any(call.startswith(('sudo|', 'omarchy-pkg-add|', 'omarchy-launch-once|', 'systemctl|--user')) for call in calls), calls
        if provider == 'broken':
            assert 'Cannot verify' in result.stderr, result.stderr
        else:
            assert 'backup/restore migration' in result.stderr, result.stderr
    for provider in ('once', 'missing'):
        result, calls = install(TEST_ONCE_PROVIDER=provider)
        assert result.returncode == 0, (provider, result.stderr, calls)
        assert calls.index('pacman|-Qq once') < calls.index('omarchy-pkg-add|once'), calls
    result, calls = install(engine_ready=False)
    assert result.returncode != 0 and 'not initialized' in result.stderr, result
    assert not any(call.startswith(('sudo|', 'omarchy-pkg-add|', 'omarchy-launch-once|', 'systemctl|--user')) for call in calls), calls
    result, calls = install(TEST_FAIL_LAUNCH='1')
    assert result.returncode != 0
    assert not any('enable --now' in call or call.startswith('sudo|') for call in calls), calls
    result, calls = install()
    assert result.returncode == 0, (result.stderr, calls)
    assert 'omarchy-pkg-add|once' in calls
    assert calls.index('omarchy-launch-once|list') < calls.index('systemctl|--user enable --now omarchy-once.service')
    assert not any('sudo|once' in call or 'docker.socket' in call for call in calls), calls
    menu_line = next(line for line in (root / 'default/omarchy/omarchy-menu.jsonc').read_text().splitlines()
                     if '"install.service.once":' in line)
    menu = json.loads('{' + menu_line.strip().rstrip(',') + '}')['install.service.once']
    for enabled in ('0', '1'):
        result = subprocess.run(['bash', '-c', menu['disabled']],
                                env=dict(os.environ, PATH=f'{directory}:/usr/bin', TEST_LOG=str(log), TEST_ONCE_ENABLED=enabled),
                                capture_output=True, text=True)
        assert (result.returncode == 0) == (enabled == '1'), result
print('ok - ONCE setup remains available from the menu until its user service is enabled')
print('ok - installer preserves legacy services, validates startup, and enables only user background tasks')
print('ok - installer accepts only the source ONCE package or an absent package, preserving foreign providers and refusing database failures')
PY
