#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PY'
import copy
import importlib.util
import json
import os
import sys
import tempfile
from pathlib import Path
from types import SimpleNamespace

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('migration', os.path.join(os.environ['ROOT'], 'default/podman/migrate-databases.py'))
migration = importlib.util.module_from_spec(spec)
spec.loader.exec_module(migration)
migration.daemon_security = lambda: ['name=seccomp,profile=builtin', 'name=cgroupns']
state = tempfile.TemporaryDirectory()
migration.completion_path = lambda identity: Path(state.name) / identity
migration.oci_spec = lambda target: {'linux': {'seccomp': {'defaultAction': 'SCMP_ACT_ERRNO'}}, 'process': {'user': {'uid': 0}, 'env': []}}

container = {
    'Name': '/redis', 'Id': 'a' * 64, 'State': {'Running': True, 'StartedAt': 'start-1', 'FinishedAt': 'stop-1'},
    'Config': {'Image': 'redis:7', 'Healthcheck': {'Test': ['CMD', 'redis-cli', 'ping'], 'Interval': 5000000000, 'Timeout': 2000000000, 'Retries': 3}},
    'HostConfig': {
        'NetworkMode': 'default', 'IpcMode': 'private', 'ShmSize': 64 * 1024 * 1024,
        'PortBindings': {'6379/tcp': [{'HostIp': '127.0.0.1', 'HostPort': '6379'}]},
        'RestartPolicy': {'Name': 'unless-stopped'},
    },
    'NetworkSettings': {'Networks': {'bridge': {}}},
    'Mounts': [{'Type': 'volume', 'Driver': 'local', 'Name': 'old-data', 'Destination': '/data', 'RW': True}],
}
assert migration.validate(container) == 'redis'
stopped = copy.deepcopy(container)
stopped['State']['Running'] = False
stopped['HostConfig']['NetworkMode'] = 'bridge'
stopped['HostConfig']['Mounts'] = []
assert migration.validate(stopped) == 'redis'
for field, value in [('Privileged', True), ('Binds', ['/etc:/data']), ('DeviceCgroupRules', ['c 1:3 rwm']), ('NetworkMode', 'host')]:
    changed = copy.deepcopy(container)
    changed['HostConfig'][field] = value
    try:
        migration.validate(changed)
    except ValueError:
        pass
    else:
        raise AssertionError(f'custom {field} was silently discarded')
changed = copy.deepcopy(container)
changed['Name'] = '/project-worker'
changed['Config']['Image'] = 'local/project-worker:tested'
assert migration.validate(changed) == 'project-worker'
print('ok - eligibility follows actual configuration instead of database names and image labels')

calls = []
current_source = container
def record_run(*args, capture=False):
    calls.append(args)
    if capture:
        return '[0,0]' if args[:2] == ('sudo', 'stat') else 'verified'
migration.run = record_run
migration.subprocess.run = lambda args, **kwargs: SimpleNamespace(returncode=1)
def inspect_fixture(engine, kind, name):
    if kind == 'container':
        if engine == 'docker':
            source = copy.deepcopy(current_source)
            if any(call[:3] == ('sudo', 'docker', 'stop') for call in calls):
                source['State'].update(Running=False, ExitCode=0)
            return source
        return {'Id': 'c' * 64, 'Config': {'Env': []}, 'HostConfig': {'ShmSize': 64 * 1024 * 1024, 'PidsLimit': -1, 'Privileged': False},
                'Mounts': [{'Type': 'volume', 'Name': 'omarchy-migrated-old-data', 'Destination': '/data', 'RW': True}],
                'EffectiveCaps': [], 'BoundingCaps': []}
    return {'Mountpoint': '/var/lib/docker/volumes/old-data/_data', 'Options': None}
migration.inspect = inspect_fixture
migration.pipe = lambda producer, consumer: calls.append((tuple(producer), tuple(consumer)))

# Run the entire batch preflight with a valid database first. Neither check-only
# nor actual migration may stop that database before rejecting the second one.
custom_cases = []
for networks in ({'bridge': {}, 'project_net': {'Aliases': ['db']}}, {'project_net': {}}, {}):
    changed = copy.deepcopy(container)
    changed['NetworkSettings']['Networks'] = networks
    custom_cases.append(('network attachments', changed))
for size in (0, None):
    changed = copy.deepcopy(container)
    changed['HostConfig']['ShmSize'] = size
    custom_cases.append(('ShmSize', changed))
changed = copy.deepcopy(container)
changed['HostConfig']['Mounts'] = [{
    'Type': 'volume', 'Source': 'postgres-data', 'Target': '/data',
    'VolumeOptions': {'Subpath': 'production'},
}]
custom_cases.append(('Mounts', changed))
changed = copy.deepcopy(container)
changed['Config']['Healthcheck']['StartInterval'] = 1000000000
custom_cases.append(('health start intervals', changed))
inspect_volume = migration.inspect
for expected_error, changed in custom_cases:
    changed['Name'] = '/postgres18'
    changed['Config']['Image'] = 'postgres:18'
    changed['Id'] = 'b' * 64
    changed['Mounts'][0]['Name'] = 'postgres-data'
    records = {'redis': container, 'postgres18': changed}
    migration.inspect = lambda engine, kind, name: records[name] if kind == 'container' else inspect_volume(engine, kind, name)
    for options in ([], ['--check']):
        sys.argv = ['migrate-databases.py', *options, 'redis', 'postgres18']
        try:
            migration.main()
        except ValueError as error:
            assert expected_error in str(error), error
            assert 'postgres18' in str(error), error
        else:
            raise AssertionError(f'custom {expected_error} passed batch preflight')
        assert not calls, f'workloads changed before rejecting custom {expected_error}: {calls}'
migration.inspect = inspect_volume
print('ok - additional, replacement and disconnected networks fail preflight before any workload changes')
print('ok - missing or invalid shared-memory sizes fail preflight before any workload changes')
print('ok - volume subpaths fail preflight before any workload changes')
print('ok - unsupported health start intervals fail batch preflight before any workload changes')

migration.migrate(container)
create = next(call for call in calls if call[:2] == ('podman', 'create'))
assert '127.0.0.1:6379:6379/tcp' in create
assert 'omarchy-migrated-old-data:/data:rw,nocopy' in create
assert '--pids-limit=-1' in create
assert '--http-proxy=false' in create
assert '--env-host=false' in create
assert create[create.index('--health-cmd') + 1] == '["CMD", "redis-cli", "ping"]'
assert create[create.index('--health-interval') + 1] == '5000000000ns'
assert ('sudo', 'docker', 'stop', '-t', '120', 'a' * 64) in calls
assert ('podman', 'start', 'redis') in calls
assert ('sudo', 'docker', 'update', '--restart=no', 'a' * 64) in calls
assert not any(call[:3] == ('sudo', 'docker', 'rm') for call in calls)
assert any(call[0][:2] == ('sudo', 'tar') and call[1][:3] == ('podman', 'unshare', 'tar')
           for call in calls if isinstance(call[0], tuple))
print('ok - database transfer preserves ports, restart policy, image snapshot and numeric volume ownership without removing Docker data')

for name in ('MyDatabase', 'app..db', 'worker_' + 'x' * 250):
    calls.clear()
    migration.completion_path(container['Id']).unlink()
    renamed = copy.deepcopy(container)
    renamed['Name'] = '/' + name
    current_source = renamed
    migration.migrate(renamed)
    image = next(call[4] for call in calls if call[:3] == ('sudo', 'docker', 'commit'))
    assert image == 'localhost/omarchy-migrated:' + container['Id']
    create = next(call for call in calls if call[:2] == ('podman', 'create'))
    assert create[-1] == image
    assert create[create.index('--name') + 1] == name
print('ok - uppercase, repeated-dot and long container names use a valid image reference without changing container identity')
current_source = container

calls.clear()
try:
    migration.migrate(container)
except ValueError as error:
    assert 'destination is missing' in str(error)
else:
    raise AssertionError('a missing completed target caused stale source data to be migrated again')
assert not calls
migration.completion_path(container['Id']).unlink()
print('ok - missing completed destinations retain their recovery copies for explicit review')

inspect_clean = migration.inspect
def forced_stop(engine, kind, name):
    result = inspect_clean(engine, kind, name)
    if engine == 'docker' and kind == 'container' and any(call[:3] == ('sudo', 'docker', 'stop') for call in calls):
        result['State']['ExitCode'] = 137
    return result
migration.inspect = forced_stop
try:
    migration.migrate(container)
except RuntimeError as error:
    assert 'stop cleanly' in str(error)
else:
    raise AssertionError('SIGKILL shutdown was accepted')
assert not any(call[:3] == ('sudo', 'docker', 'commit') for call in calls)
assert ('sudo', 'docker', 'start', 'a' * 64) in calls
migration.inspect = inspect_clean
print('ok - forced shutdown aborts before copying and restarts the source')

calls.clear()
record_run = migration.run
def mismatched_manifest(*args, capture=False):
    record_run(*args, capture=capture)
    if args[:2] == ('sudo', 'stat'):
        return '[0,0]'
    if capture:
        return 'source-digest' if args[0] == 'sudo' else 'different-target-digest'
migration.run = mismatched_manifest
try:
    migration.migrate(container)
except RuntimeError as error:
    assert 'metadata verification failed' in str(error), error
else:
    raise AssertionError('mismatched volume metadata was accepted')
assert not any(call[:2] == ('podman', 'create') for call in calls)
assert ('podman', 'volume', 'rm', 'omarchy-migrated-old-data') in calls
assert ('sudo', 'docker', 'start', 'a' * 64) in calls
migration.run = record_run
print('ok - metadata mismatch removes only the new volume and restores the source before container creation')

calls.clear()
verify = migration.verify_volume
verifications = 0
def changed_after_init(*args):
    global verifications
    verifications += 1
    if verifications == 2:
        raise RuntimeError('metadata changed during runtime initialization')
    verify(*args)
migration.verify_volume = changed_after_init
try:
    migration.migrate(container)
except RuntimeError as error:
    assert 'runtime initialization' in str(error)
else:
    raise AssertionError('runtime volume changes passed verification')
assert ('podman', 'init', 'redis') in calls
assert ('podman', 'start', 'redis') not in calls
assert ('podman', 'rm', '--force', 'redis') in calls
assert ('sudo', 'docker', 'start', 'a' * 64) in calls
print('ok - post-init metadata changes roll back before starting the application')

calls.clear()
verifications = 0
def failed_cleanup(*args, capture=False):
    result = record_run(*args, capture=capture)
    if args[:2] == ('podman', 'rm'):
        raise RuntimeError('cleanup failed')
    return result
migration.run = failed_cleanup
try:
    migration.migrate(container)
except RuntimeError as error:
    assert 'runtime initialization' in str(error)
else:
    raise AssertionError('failed cleanup was reported as successful')
assert ('sudo', 'docker', 'start', 'a' * 64) in calls
assert ('podman', 'start', 'redis') not in calls
migration.run = record_run
migration.verify_volume = verify
print('ok - cleanup failures still attempt to restore the Docker workload and preserve the original error')

calls.clear()
record_completion = migration.record_completion
def failed_receipt(*args):
    raise RuntimeError('receipt storage failed')
migration.record_completion = failed_receipt
try:
    migration.migrate(container)
except RuntimeError as error:
    assert 'receipt storage failed' in str(error)
else:
    raise AssertionError('failed receipt write was accepted')
assert ('sudo', 'docker', 'update', '--restart=no', container['Id']) in calls
assert ('podman', 'start', 'redis') in calls
assert not any(call[:2] == ('podman', 'rm') or call[:3] == ('podman', 'volume', 'rm') for call in calls)
assert ('sudo', 'docker', 'update', '--restart=unless-stopped', container['Id']) not in calls
assert ('sudo', 'docker', 'start', container['Id']) not in calls
migration.record_completion = record_completion
print('ok - receipt failures retain potentially written destination data and leave the stale Docker source stopped')

calls.clear()
def uncertain_start(*args, capture=False):
    result = record_run(*args, capture=capture)
    if args[:2] == ('podman', 'start'):
        raise RuntimeError('start command failed after application launch')
    return result
migration.run = uncertain_start
try:
    migration.migrate(container)
except RuntimeError as error:
    assert 'after application launch' in str(error)
else:
    raise AssertionError('uncertain start reported successful')
assert not any(call[:2] == ('podman', 'rm') or call[:3] == ('podman', 'volume', 'rm') for call in calls)
assert ('sudo', 'docker', 'start', container['Id']) not in calls
assert ('sudo', 'docker', 'update', '--restart=unless-stopped', container['Id']) not in calls
migration.run = record_run
print('ok - even failed start attempts retain destinations rather than discarding possible application writes')

calls.clear()
def broken_pipe(producer, consumer):
    raise RuntimeError('transfer failed')
migration.pipe = broken_pipe
try:
    migration.migrate(container)
except RuntimeError:
    pass
else:
    raise AssertionError('failed transfer was reported successful')
assert ('sudo', 'docker', 'start', 'a' * 64) in calls
assert not any(call[:2] == ('podman', 'create') for call in calls)
print('ok - failed transfer restores the previously running Docker database')

calls.clear()
record_completion(container, stopped['State'])
migration.subprocess.run = lambda args, **kwargs: SimpleNamespace(returncode=0)
migration.inspect = lambda engine, *args: copy.deepcopy(current_source) if engine == 'docker' else {'Id': 'c' * 64, 'Config': {'Labels': {migration.LABEL: 'a' * 64}}}
current_source = stopped
migration.migrate(stopped)
assert not calls
for source_state in ({'Running': True, 'StartedAt': 'start-1', 'FinishedAt': 'stop-1'},
                     {'Running': False, 'StartedAt': 'start-2', 'FinishedAt': 'stop-2'}):
    resumed = copy.deepcopy(container)
    resumed['State'] = source_state
    current_source = resumed
    try:
        migration.migrate(resumed)
    except ValueError:
        pass
    else:
        raise AssertionError('a resumed source reused a stale completion receipt')
    assert not calls
print('ok - completed sources cannot resume on daemon restart and restarted sources require review even after stopping again')
migration.completion_path('a' * 64).unlink()
current_source = container
try:
    migration.migrate(container)
except ValueError as error:
    assert 'no completed transfer' in str(error)
else:
    raise AssertionError('an interrupted transfer was accepted as complete')
assert not calls
migration.inspect = lambda engine, *args: copy.deepcopy(current_source) if engine == 'docker' else {'Config': {'Labels': {migration.LABEL: 'different'}}}
try:
    migration.migrate(container)
except ValueError:
    pass
else:
    raise AssertionError('unrelated destination container was overwritten')
assert not calls
print('ok - retries require a completion receipt matching both engines and retain interrupted or unrelated destinations')

completed_source = copy.deepcopy(stopped)
completed_source['Mounts'] = []
completed_source['HostConfig']['RestartPolicy'] = {'Name': 'no'}
completed_target = {'Id': 'c' * 64, 'Config': {'Labels': {migration.LABEL: container['Id']}}}
migration.completion_path(container['Id']).write_text(json.dumps({'target': completed_target['Id'], 'source': migration.stopped_identity(stopped['State'])}))
migration.run = lambda *args, **kwargs: (_ for _ in ()).throw(AssertionError('final completion check mutated an engine'))
for change in ('none', 'running', 'restarted', 'restart-policy', 'missing-target', 'replaced-target'):
    source, target = copy.deepcopy(completed_source), copy.deepcopy(completed_target)
    if change == 'running':
        source['State']['Running'] = True
    elif change == 'restarted':
        source['State']['StartedAt'] = 'new-start'
    elif change == 'restart-policy':
        source['HostConfig']['RestartPolicy']['Name'] = 'always'
    elif change == 'replaced-target':
        target['Id'] = 'd' * 64
    migration.inspect = lambda engine, *args: copy.deepcopy(source if engine == 'docker' else target)
    migration.exists = lambda *args: change != 'missing-target'
    sys.argv = ['migrate-databases.py', '--check-completed', 'redis']
    try:
        migration.main()
    except ValueError as error:
        assert change != 'none' and 'completed transfer changed' in str(error), (change, error)
    else:
        assert change == 'none', change
print('ok - final completion check is read-only and rejects resumed sources, changed policy and missing/replaced destinations')
PY

# Source drift and final completion.
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

# Custom workload preflight, transfer and confinement.
python3 - <<'PY'
import copy
import importlib.util
import os
import sys
from types import SimpleNamespace

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('migration', os.path.join(os.environ['ROOT'], 'default/podman/migrate-databases.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
m.daemon_security = lambda: ['name=seccomp,profile=builtin', 'name=cgroupns']
m.validate_daemon(m.daemon_security())
for options in (None, [], ['name=no-new-privileges'], ['name=userns'], ['name=rootless'],
                ['name=seccomp,profile=/etc/docker/restrictive.json'], ['name=apparmor']):
    try:
        m.validate_daemon(options)
    except ValueError:
        pass
    else:
        raise AssertionError(f'daemon confinement was silently discarded: {options}')
print('ok - inherited daemon confinement and user mappings require explicit migration')
c = {
    'Name': '/project-worker', 'Id': 'b' * 64, 'State': {'Running': True},
    'Config': {'Image': 'local/custom-worker:v1', 'User': '1000', 'Env': ['PRIVATE=do-not-log']},
    'HostConfig': {
        'NetworkMode': 'bridge', 'IpcMode': 'private', 'ShmSize': 128 * 1024 * 1024,
        'Binds': ['project-data:/data:rw'], 'Memory': 128 * 1024 * 1024,
        'MemorySwap': 256 * 1024 * 1024, 'PidsLimit': 64, 'NanoCpus': 500000000,
        'CapDrop': ['ALL'], 'SecurityOpt': ['no-new-privileges'],
        'MaskedPaths': sorted(m.MASKED_PATHS), 'ReadonlyPaths': sorted(m.READONLY_PATHS),
        'Runtime': 'runc', 'CgroupnsMode': 'private', 'ConsoleSize': [0, 0],
        'LogConfig': {'Type': 'json-file', 'Config': {'max-size': '10m', 'max-file': '5'}},
    },
    'NetworkSettings': {'Networks': {'bridge': {}}},
    'Mounts': [{'Type': 'volume', 'Driver': 'local', 'Name': 'project-data', 'Destination': '/data', 'RW': True}],
}
assert m.validate(c) == 'project-worker'
args = m.runtime_arguments(c)
assert '--pids-limit=64' in args
for flag, value in [('--shm-size', '134217728'), ('--memory', '134217728'), ('--memory-swap', '268435456'), ('--cpus', '0.5'), ('--cap-drop', 'ALL')]:
    assert args[args.index(flag) + 1] == value
assert 'no-new-privileges' in args
assert m.destination_volume(c, c['Mounts'][0]) == 'project-data'
assert '--privileged' not in args and 'sudo' not in args
print('ok - custom unprivileged containers preserve resource limits, private volume names and restrictive security settings')
nonroot = copy.deepcopy(c)
nonroot['HostConfig']['CapDrop'] = []
assert '--cap-add' not in m.runtime_arguments(nonroot)
assert m.allowed_capabilities(nonroot) == set()
print('ok - non-root users do not gain effective or ambient capabilities from explicit cap-add flags')

root = copy.deepcopy(c)
root['Config']['User'] = ''
for dropped, excluded in ((['all'], m.DOCKER_CAPABILITIES),
                          (['aLl'], m.DOCKER_CAPABILITIES),
                          (['net_raw', 'cap_chown'], {'NET_RAW', 'CHOWN'}),
                          (['cAp_NeT_RaW'], {'NET_RAW'})):
    root['HostConfig']['CapDrop'] = dropped
    args = m.runtime_arguments(root)
    added = {args[index + 1] for index, argument in enumerate(args) if argument == '--cap-add'}
    assert added == m.DOCKER_CAPABILITIES - excluded, (dropped, added)
print('ok - Docker API capability drops retain their ceiling regardless of case or CAP_ prefix')

domain = copy.deepcopy(c)
domain['Config']['Domainname'] = 'fixture.test'
try:
    m.validate(domain)
except ValueError as error:
    assert 'domain name' in str(error)
else:
    raise AssertionError('unsupported domain name passed batch preflight')
print('ok - custom domain names require explicit configuration before source mutation')

cases = [('Runtime', 'nvidia'), ('Privileged', True), ('CapAdd', ['SYS_ADMIN']),
         ('Devices', [{'PathOnHost': '/dev/kvm'}]), ('DeviceRequests', [{'Driver': 'nvidia'}]),
         ('DeviceCgroupRules', ['a *:* rwm']), ('CgroupnsMode', 'host'),
         ('SecurityOpt', ['seccomp=unconfined']), ('MaskedPaths', []),
         ('ReadonlyPaths', []), ('FuturePrivilegeOption', {'enabled': True}),
         ('Binds', ['/var/run/docker.sock:/var/run/docker.sock:rw']),
         ('Binds', ['/home/example/project:/data:ro']),
         ('Binds', ['project-data:/data:rw,Z'])]
for field, value in cases:
    modified = copy.deepcopy(c)
    modified['HostConfig'][field] = value
    try:
        m.validate(modified)
    except ValueError:
        pass
    else:
        raise AssertionError(f'{field} silently passed: {value}')
for profile in ('AppArmorProfile', 'ProcessLabel'):
    modified = copy.deepcopy(c)
    modified[profile] = 'custom-confinement'
    try:
        m.validate(modified)
    except ValueError:
        pass
    else:
        raise AssertionError(f'{profile} was discarded')
print('ok - elevated privileges, devices, host sockets/mounts, confinement changes and unknown options require explicit review')

assert m.local_command(['podman', 'image', 'load']) == ['/usr/bin/podman', '--remote=false', 'image', 'load']
assert m.local_command(['sudo', 'docker', 'inspect', 'worker']) == ['sudo', '/usr/bin/docker', '--host', 'unix:///var/run/docker.sock', 'inspect', 'worker']
print('ok - migration commands pin local engines instead of following saved remote contexts')

h = copy.deepcopy(c['HostConfig'])
h['Privileged'] = False
h['CpuQuota'], h['CpuPeriod'] = 50000, 100000
target = {'Config': copy.deepcopy(c['Config']), 'HostConfig': h, 'EffectiveCaps': [], 'BoundingCaps': [], 'Mounts': copy.deepcopy(c['Mounts'])}
runtime = {'linux': {'maskedPaths': sorted(m.MASKED_PATHS), 'readonlyPaths': sorted(m.READONLY_PATHS),
                     'seccomp': {'defaultAction': 'SCMP_ACT_ERRNO'}},
           'process': {'user': {'uid': 1000}, 'noNewPrivileges': True, 'env': list(c['Config']['Env'])}}
m.oci_spec = lambda target: runtime
m.inspect = lambda *args: target
m.verify_runtime(c)
# Both inspect and the final OCI environment are checked before application start.
for environment in (target['Config']['Env'], runtime['process']['env']):
    original = list(environment)
    for values in (original + ['HTTPS_PROXY=http://fixture:secret@proxy.invalid'],
                   ['PRIVATE=changed'], [], original + ['PRIVATE=duplicate'],
                   original + ['EXTRA_CONFIG=unexpected']):
        environment[:] = values
        try:
            m.verify_runtime(c)
        except RuntimeError as error:
            assert 'secret' not in str(error) and 'PRIVATE' not in str(error)
        else:
            raise AssertionError('destination environment drift was accepted')
    environment[:] = original + ['HOME=/home/worker', 'HOSTNAME=worker', 'container=podman']
    m.verify_runtime(c)
    environment[:] = original
# A proxy explicitly present in the Docker source must survive byte-for-byte.
for config in (c['Config'], target['Config']):
    config['Env'].append('HTTPS_PROXY=http://source-proxy.invalid')
runtime['process']['env'].append('HTTPS_PROXY=http://source-proxy.invalid')
m.verify_runtime(c)
for config in (c['Config'], target['Config']):
    config['Env'].pop()
runtime['process']['env'].pop()
print('ok - both destination environments preserve source variables, reject injected proxies and allow missing-source engine defaults')
target['EffectiveCaps'], target['BoundingCaps'] = None, None
m.verify_runtime(c)
del target['EffectiveCaps']
try:
    m.verify_runtime(c)
except RuntimeError:
    pass
else:
    raise AssertionError('missing capability evidence was accepted')
target['EffectiveCaps'], target['BoundingCaps'] = [], []
runtime['process']['capabilities'] = {'ambient': ['CAP_CHOWN']}
try:
    m.verify_runtime(c)
except RuntimeError:
    pass
else:
    raise AssertionError('OCI non-root ambient capabilities were accepted')
runtime['process']['capabilities'] = {}
for field, value in [('Memory', 0), ('PidsLimit', -1), ('SecurityOpt', []), ('CpuQuota', 100000), ('Devices', [{'PathOnHost': '/dev/kvm'}])]:
    original = h.get(field)
    h[field] = value
    try:
        m.verify_runtime(c)
    except RuntimeError:
        pass
    else:
        raise AssertionError(f'ignored {field} constraint was accepted')
    h[field] = original
target['Mounts'].append({'Type': 'bind', 'Source': '/home/example', 'Destination': '/host'})
try:
    m.verify_runtime(c)
except RuntimeError:
    pass
else:
    raise AssertionError('implicit host mount from destination defaults was accepted')
target['Mounts'].pop()
for field in ('maskedPaths', 'readonlyPaths', 'seccomp'):
    original = runtime['linux'][field]
    runtime['linux'][field] = []
    try:
        m.verify_runtime(c)
    except RuntimeError:
        pass
    else:
        raise AssertionError(f'OCI {field} was not verified')
    runtime['linux'][field] = original
target['EffectiveCaps'] = ['CAP_SYS_ADMIN']
try:
    m.verify_runtime(c)
except RuntimeError:
    pass
else:
    raise AssertionError('restored capabilities were accepted')
print('ok - ignored limits, dropped confinement and added capabilities fail verification before the application starts')

first, second = copy.deepcopy(c), copy.deepcopy(c)
first['Name'], second['Name'] = '/blocked-one', '/blocked-two'
first['HostConfig']['Privileged'] = True
second['HostConfig']['Runtime'] = 'nvidia'
records = {'blocked-one': first, 'blocked-two': second}
m.inspect = lambda engine, kind, name: records[name]
m.run = lambda *args, **kwargs: (_ for _ in ()).throw(AssertionError('preflight changed a workload'))
sys.argv = ['migrate-databases.py', '--check', 'blocked-one', 'blocked-two']
try:
    m.main()
except ValueError as error:
    text = str(error)
    assert 'blocked-one' in text and 'blocked-two' in text
    assert 'PRIVATE' not in text and 'do-not-log' not in text
else:
    raise AssertionError('blocked batch passed')
m.daemon_security = lambda: ['name=no-new-privileges']
m.inspect = lambda *args: (_ for _ in ()).throw(AssertionError('daemon preflight proceeded to workloads'))
try:
    m.main()
except ValueError as error:
    assert 'daemon confinement' in str(error)
else:
    raise AssertionError('inherited daemon no-new-privileges was dropped')
m.os.geteuid = lambda: 0
try:
    m.main()
except ValueError as error:
    assert 'desktop user' in str(error)
else:
    raise AssertionError('rootful automatic migration was accepted')
print('ok - complete batch preflight reports blockers without secrets or mutations and refuses rootful execution')
PY

# Volume transfer metadata and corruption detection.
python3 - <<'PY'
import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
spec = importlib.util.spec_from_file_location('manifest', root / 'default/podman/volume-manifest.py')
manifest = importlib.util.module_from_spec(spec)
spec.loader.exec_module(manifest)
with tempfile.TemporaryDirectory() as directory:
    source, target = [Path(directory) / name for name in ('source', 'target')]
    source.mkdir(mode=0o775)
    source.chmod(0o775)
    target.mkdir(mode=0o755)
    payload = source / 'data'
    payload.write_bytes(b'database contents\n')
    payload.chmod(0o640)
    os.link(payload, source / 'hardlink')
    (source / 'symlink').symlink_to('data')
    os.setxattr(payload, 'user.migration', b'preserve-me')
    os.mkfifo(source / 'fifo')
    sparse = source / 'sparse'
    with sparse.open('wb') as output:
        output.seek(8 * 1024 * 1024)
        output.write(b'end')
    timestamp = 1720000000123456789
    for path in source.iterdir():
        os.utime(path, ns=(timestamp, timestamp), follow_symlinks=False)
    os.utime(source, ns=(timestamp, timestamp))
    spec = importlib.util.spec_from_file_location('migration', root / 'default/podman/migrate-databases.py')
    migration = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(migration)
    migration.inspect = lambda *args: {'Mountpoint': str(target)}
    # This fixture owns both trees. Strip only privilege/namespace dispatch;
    # execute the production transfer and verification with real tar/Python.
    def local(args):
        return list(args[1:] if args[0] == 'sudo' else args[2:])
    def run(*args, capture=False):
        result = subprocess.run(local(args), check=True, text=True, capture_output=capture)
        return result.stdout.strip() if capture else None
    def pipe(producer, consumer):
        with subprocess.Popen(local(producer), stdout=subprocess.PIPE) as process:
            result = subprocess.run(local(consumer), stdin=process.stdout)
            process.stdout.close()
            assert process.wait() == 0 and result.returncode == 0
    migration.run = run
    migration.pipe = pipe
    migration.transfer_volume({'Mountpoint': str(source)}, 'fixture-volume')
    expected = manifest.fingerprint(source)
    assert manifest.fingerprint(target) == expected
    assert (target / 'sparse').stat().st_blocks * 512 < (target / 'sparse').stat().st_size
    target.chmod(0o755)
    assert manifest.fingerprint(target) != expected, 'volume root permission change was missed'
    target.chmod(0o775)
    (target / 'data').write_bytes(b'different content!')
    os.utime(target / 'data', ns=(timestamp, timestamp))
    assert manifest.fingerprint(target) != expected, 'content corruption was missed'
print('ok - native volume transfer preserves root mode, timestamps, xattrs, sparse files, links and FIFO')
print('ok - verification detects volume-root permission changes and content corruption')
PY
