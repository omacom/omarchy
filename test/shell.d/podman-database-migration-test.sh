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
