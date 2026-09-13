#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PY'
import copy
import importlib.util
import os
import sys
import tempfile
from pathlib import Path

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('migration', Path(os.environ['ROOT']) / 'default/podman/migrate-databases.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

def fixture(name, identity):
    return {'Name': '/' + name, 'Id': identity * 64,
            'Config': {'User': '1000', 'Env': ['PRIVATE=fixture-secret']},
            'HostConfig': {'NetworkMode': 'bridge', 'IpcMode': 'private', 'ShmSize': 67108864,
                           'Memory': 134217728, 'RestartPolicy': {'Name': 'no'}, 'CapDrop': ['ALL']},
            'NetworkSettings': {'Networks': {'bridge': {}}}, 'Mounts': [],
            'State': {'Running': False, 'StartedAt': 'before', 'FinishedAt': 'before', 'ExitCode': 0}}

changes = {
    'start': lambda c: c['State'].update(Running=True, StartedAt='new-start'),
    'restart lifecycle': lambda c: c['State'].update(StartedAt='new-start', FinishedAt='new-stop'),
    'memory': lambda c: c['HostConfig'].update(Memory=268435456),
    'restart policy': lambda c: c['HostConfig'].update(RestartPolicy={'Name': 'always'}),
    'network': lambda c: c['NetworkSettings']['Networks'].update(custom={}),
    'environment': lambda c: c['Config'].update(Env=['PRIVATE=changed-secret']),
    'security': lambda c: c.update(AppArmorProfile='custom'),
    'rename': lambda c: c.update(Name='/renamed'),
    'health only': lambda c: c['State'].update(Health={'Status': 'healthy', 'Log': ['new probe']}, Pid=42),
}

# Actual batch and transfer code, with all external engine I/O replaced. The
# first transfer changes a later source after the complete batch was inspected.
for description, change in changes.items():
    with tempfile.TemporaryDirectory() as state:
        first, second = fixture('first', 'a'), fixture('second', 'b')
        records = {c['Id']: c for c in (first, second)}
        calls, receipts, targets = [], [], {}
        def inspect(engine, kind, name):
            if engine == 'docker':
                record = records.get(name) or next(c for c in records.values() if c['Name'] == '/' + name)
                return copy.deepcopy(record)
            return targets[name]
        def run(*args, **kwargs):
            calls.append(args)
            if args[:3] == ('sudo', 'docker', 'stop'):
                records[args[-1]]['State'].update(Running=False, FinishedAt='after-stop')
            if args[:2] == ('podman', 'create'):
                name = args[args.index('--name') + 1]
                target = copy.deepcopy(first if name == 'first' else second)
                target.update(EffectiveCaps=[], BoundingCaps=[])
                target['HostConfig'].update(Privileged=False, PidsLimit=-1)
                targets[name] = target
                if name == 'first':
                    change(second)
            return ''
        m.inspect, m.run = inspect, run
        m.exists = lambda *args: False
        m.completion_path = lambda identity: Path(state) / identity
        m.pipe = lambda *args: None
        m.record_completion = lambda container, stopped: receipts.append(container['Name'])
        m.daemon_security = lambda: ['name=seccomp,profile=builtin']
        m.oci_spec = lambda target: {'process': {'user': {'uid': 1000}, 'env': target['Config']['Env']},
                                     'linux': {'seccomp': {'defaultAction': 'SCMP_ACT_ERRNO'}}}
        sys.argv = ['migrate-databases.py', 'first', 'second']
        if description == 'health only':
            m.main()
            assert receipts == ['/first', '/second']
        else:
            try:
                m.main()
            except ValueError as error:
                assert 'changed after preflight' in str(error), error
                assert 'secret' not in str(error)
            else:
                raise AssertionError(f'{description} drift was silently migrated')
            assert receipts == ['/first']
            assert not any(args[:2] == ('sudo', 'docker') and args[-1] == second['Id'] for args in calls)
            assert not any(args[:2] == ('podman', 'create') and args[args.index('--name') + 1] == 'second' for args in calls)
        print(f'ok - batch source {description}: configuration drift stops before mutation; health observations remain eligible')

# Destination lookup itself can take time. Refresh again just before stopping,
# and do not use cached state even for an existing completion receipt.
for existing in (False, True):
    with tempfile.TemporaryDirectory() as state:
        source = fixture('source', 'c')
        initial = copy.deepcopy(source)
        m.inspect = lambda engine, *args: copy.deepcopy(source) if engine == 'docker' else {}
        m.completion_path = lambda identity: Path(state) / identity
        m.run = lambda *args, **kwargs: (_ for _ in ()).throw(AssertionError('changed source mutated'))
        def exists(*args):
            source['State']['Running'] = True
            return existing
        m.exists = exists
        m.completed = lambda container, target: True
        try:
            m.migrate(initial)
        except ValueError:
            pass
        else:
            raise AssertionError('changed source was migrated or accepted as completed')
print('ok - destination checks cannot cause stale state to be used for source mutation')
PY
