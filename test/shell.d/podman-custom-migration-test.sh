#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

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
