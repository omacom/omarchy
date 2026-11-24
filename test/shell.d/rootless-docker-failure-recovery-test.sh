#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 - <<'PY'
import copy
import importlib.util
import os
from pathlib import Path
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
PY
