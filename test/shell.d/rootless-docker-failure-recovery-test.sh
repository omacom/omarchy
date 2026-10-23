#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 - <<'PY'
import copy
import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
from unittest.mock import patch

root = Path(os.environ['ROOT'])
spec = importlib.util.spec_from_file_location('migration', root / 'default/docker/rootless/migrate.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
source = {'Id': 'a' * 64, 'Name': '/fixture', 'Mounts': [],
          'Config': {'StopTimeout': 12}, 'HostConfig': {'RestartPolicy': {'Name': 'no'}},
          'State': {'Running': False, 'StartedAt': 'start', 'FinishedAt': 'finish', 'ExitCode': 0}}
for fault in ['events', 'runtime', 'receipt', 'foreign', 'durable-receipt']:
    target = {'Id': 'b' * 64, 'Config': {'Labels': {m.LABEL: source['Id'], m.OWNERSHIP_LABEL: 'c' * 64}},
              'HostConfig': {'RestartPolicy': {'Name': 'unless-stopped'}}, 'State': {'Running': False}}
    intent = {'target_running': True, 'start_attempted': False, 'target_ownership': 'c' * 64,
              'source_nofile': {'soft': 1024, 'hard': 1024}, 'volume_event': {'name': 'event'},
              'destination': {'id': target['Id']}}
    calls = []
    with tempfile.TemporaryDirectory() as directory:
        receipt = Path(directory) / 'receipt'
        def inspect(engine, kind, identity):
            return copy.deepcopy(source if engine == m.SOURCE else target)
        def run(*args):
            calls.append(args)
            assert args[0] == m.TARGET, args
            if args[1] == 'start':
                target['State']['Running'] = True
            elif args[1] == 'update':
                assert args[2:] == ('--restart=no', target['Id'])
                target['HostConfig']['RestartPolicy'] = {'Name': 'no'}
            elif args[1] == 'stop':
                assert args[-1] == target['Id']
                target['State']['Running'] = False
            else:
                raise AssertionError(args)
        def event(*args):
            if fault == 'events':
                raise RuntimeError('events')
        def runtime(*args):
            if fault == 'foreign':
                target['Config']['Labels'][m.OWNERSHIP_LABEL] = 'd' * 64
            if fault in ['runtime', 'foreign']:
                raise RuntimeError(fault)
            return copy.deepcopy(target)
        def publish(*args):
            if fault == 'durable-receipt':
                receipt.touch()
            raise RuntimeError(fault)
        with patch.object(m, 'verify_resumable_migration', return_value=(copy.deepcopy(source), copy.deepcopy(source['State']))), \
             patch.object(m, 'inspect', inspect), patch.object(m, 'run', run), \
             patch.object(m, 'snapshot_digest', return_value='same'), patch.object(m, 'persist_migration_intent'), \
             patch.object(m, 'verify_volume_event_window', event), patch.object(m, 'verify_runtime', runtime), \
             patch.object(m, 'record_completion', publish), patch.object(m, 'completion_path', return_value=receipt):
            try:
                m.resume_verified_migration(source, target, intent)
            except RuntimeError:
                pass
            else:
                raise AssertionError('fault was reported as success')
        assert intent['start_attempted'] and not source['State']['Running']
        if fault in ['foreign', 'durable-receipt']:
            assert calls == [(m.TARGET, 'start', 'fixture')], calls
        else:
            assert not target['State']['Running']
            assert target['HostConfig']['RestartPolicy']['Name'] == 'no'
            assert len(calls) == 3, calls
print('ok - resumed event/runtime/receipt faults fence the owned destination, retain both stores and never restore the source; foreign ownership and durable completion remain untouched')

script = (root / 'migrations/1789164756.sh').read_text()
start = script.index('quiesced_recovery_pending=1\n')
end = script.index('  quiesced_recovery_pending=0\n', start)
phase = script[start:end] + '\nfi\n'
phase = phase.replace('/usr/bin/python3', 'fixture_python').replace('/usr/bin/systemctl', 'systemctl').replace('/usr/bin/docker', 'docker')
prefix = r'''
set -euo pipefail
migrator=/fixture/migrate.py
windows_arg=-
windows_id=""
container_names=(alpha)
source_host=unix:///fixture
docker_inventory=inventory
sudo() {
  printf 'sudo %s\n' "$*" >>"$LOG"
  [[ $* != 'systemctl restart docker.service' || $FAULT != restart ]] || return 33
  if [[ $1 == docker ]]; then printf '%s\n' inventory; fi
}
fixture_python() {
  printf 'python %s\n' "$*" >>"$LOG"
  [[ ${2:-} != --check || $FAULT != check ]] || return 33
}
verify_rootful_listeners() { [[ $FAULT != listeners ]] || return 33; }
restrict_rootful_socket() { [[ $FAULT != socket ]] || return 33; }
verify_rootful_socket_unit() { :; }
'''
with tempfile.TemporaryDirectory() as directory:
    for fault in ['restart', 'socket', 'listeners', 'check']:
        log = Path(directory) / fault
        result = subprocess.run(['bash', '-c', prefix + phase],
                                env=dict(os.environ, FAULT=fault, LOG=str(log)), capture_output=True, text=True)
        assert result.returncode == 33, (fault, result.stderr)
        calls = log.read_text()
        assert 'python /fixture/migrate.py --restore-quiesced-all - alpha\n' in calls, (fault, calls)
print('ok - failures after quiescing in daemon restart, socket checks, listener checks or second preflight invoke journal-gated source recovery and preserve failure status')
PY
