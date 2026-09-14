#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PY'
import copy
import importlib.util
import os
from pathlib import Path
import stat
import sys
import tempfile
from types import SimpleNamespace
from unittest.mock import patch

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('windows', Path(os.environ['ROOT']) / 'default/podman/migrate-windows.py')
w = importlib.util.module_from_spec(spec)
spec.loader.exec_module(w)

with tempfile.TemporaryDirectory() as temporary:
    home = Path(temporary)
    (home / '.windows').mkdir()
    (home / 'Windows').mkdir()
    (home / '.windows/disk.img').write_text('existing Windows disk')
    account = SimpleNamespace(pw_dir=str(home), pw_uid=os.getuid())
    environment = {'VERSION': '11', 'RAM_SIZE': '4G', 'CPU_CORES': '2', 'DISK_SIZE': '64G',
                   'USERNAME': 'omarchy', 'PASSWORD': 'secret$$value', 'PROTECT': 'Y', 'TZ': 'UTC',
                   'ARGUMENTS': '-rtc base=localtime,clock=host,driftfix=slew'}
    paths = (home / '.windows', home / 'Windows')
    service = {'image': 'dockurr/windows', 'container_name': w.NAME, 'environment': environment,
               'devices': ['/dev/kvm', '/dev/net/tun'], 'cap_add': ['NET_ADMIN'],
               'ports': ['127.0.0.1:8006:8006', '127.0.0.1:3389:3389/tcp', '127.0.0.1:3389:3389/udp'],
               'volumes': [f'{paths[0]}:/storage', f'{paths[1]}:/shared'], 'restart': 'no', 'stop_grace_period': '2m'}
    document = {'services': {'windows': service}}
    image = {'Id': 'b' * 64, 'Config': {'Env': ['PATH=/usr/bin'], 'Entrypoint': ['/run/entry.sh']}}
    container = {
        'Id': 'a' * 64, 'Name': '/' + w.NAME, 'Image': image['Id'], 'State': {'Running': True},
        'Config': {'Image': service['image'], 'Env': image['Config']['Env'] +
                   [f"{key}={value.replace('$$', '$')}" for key, value in environment.items()],
                   'Entrypoint': image['Config']['Entrypoint'], 'StopTimeout': 120},
        'HostConfig': {'Devices': [{'PathOnHost': path, 'PathInContainer': path, 'CgroupPermissions': 'rwm'} for path in service['devices']],
                       'CapAdd': ['NET_ADMIN'], 'PortBindings': copy.deepcopy(w.PORTS),
                       'RestartPolicy': {'Name': 'no', 'MaximumRetryCount': 0}, 'ShmSize': 67108864,
                       'IpcMode': 'private', 'Binds': [f'{path}:{target}:rw' for path, target in zip(paths, ('/storage', '/shared'))],
                       'NetworkMode': 'windows_default'},
        'NetworkSettings': {'Networks': {'windows_default': {'Aliases': [w.NAME, 'windows']}}},
        'Mounts': [{'Type': 'bind', 'Source': str(path), 'Destination': target, 'RW': True, 'Propagation': 'rprivate'}
                   for path, target in zip(paths, ('/storage', '/shared'))],
    }
    w.validate(container, image, document, account)
    container['Config']['User'] = ''
    container['HostConfig']['CapAdd'] = ['CAP_NET_ADMIN']
    w.validate(container, image, document, account)
    assert (home / '.windows/disk.img').read_text() == 'existing Windows disk'
    print('ok - managed legacy Windows paths and escaped credentials pass without changing the disk')

    def rejected(record=container, config=document, snapshot=image):
        try:
            w.validate(record, snapshot, config, account)
        except (ValueError, KeyError, TypeError):
            return
        raise AssertionError('custom Windows handover was accepted')

    for field, value in [('Image', 'redis:7'), ('Cmd', ['sleep', 'infinity']), ('User', '1000'), ('StopTimeout', 10), ('Hostname', 'custom-host'), ('Labels', {'custom': 'lost'})]:
        changed = copy.deepcopy(container)
        changed['Config'][field] = value
        rejected(changed)
    for field, value in [('Privileged', True), ('Memory', 128 * 1024 * 1024), ('CapDrop', ['NET_RAW']),
                         ('SecurityOpt', ['no-new-privileges']), ('NetworkMode', 'host'), ('ShmSize', 128 * 1024 * 1024),
                         ('CapAdd', ['SYS_ADMIN']), ('Devices', []), ('Binds', ['/tmp/custom:/storage:rw']),
                         ('FutureOption', 'custom')]:
        changed = copy.deepcopy(container)
        changed['HostConfig'][field] = value
        rejected(changed)
    changed = copy.deepcopy(container)
    changed['Config']['Env'].append('CUSTOM=lost')
    rejected(changed)
    changed = copy.deepcopy(container)
    changed['Mounts'].append({'Type': 'volume', 'Name': 'custom-data', 'Destination': '/extra'})
    rejected(changed)
    changed = copy.deepcopy(container)
    changed['Mounts'][0]['Source'] = str(home / 'different-disk')
    rejected(changed)
    changed = copy.deepcopy(container)
    changed['NetworkSettings']['Networks']['windows_default']['Aliases'].append('custom-service')
    rejected(changed)
    print('ok - name impostors, custom images/processes/resources/security/networking and mounts require review')

    for field, value in [('image', 'local/windows:custom'), ('volumes', ['/tmp/custom:/storage', f'{paths[1]}:/shared']),
                         ('extra_hosts', ['host:1.2.3.4']), ('restart', 'always')]:
        changed = copy.deepcopy(document)
        changed['services']['windows'][field] = value
        rejected(config=changed)
    changed = copy.deepcopy(document)
    changed['services']['windows']['environment']['PASSWORD'] = '${PASSWORD}'
    rejected(config=changed)
    try:
        w.yaml.load('services: {}\nservices: {}\n', Loader=w.UniqueLoader)
    except ValueError:
        pass
    else:
        raise AssertionError('duplicate compose keys were accepted')
    print('ok - only the managed compose schema is accepted, without interpolation or duplicate keys')

    # Exercise root-file trust with simulated metadata; no privileged writes.
    compose = home / 'compose.yml'
    compose.write_text(w.yaml.safe_dump(document))
    original_stat = Path.stat
    parents = set(compose.parents)
    root_directory = SimpleNamespace(st_uid=0, st_mode=stat.S_IFDIR | 0o755)
    def parent_stat(path, *args, **kwargs):
        return root_directory if path in parents else original_stat(path, *args, **kwargs)
    with patch.object(Path, 'stat', parent_stat):
        for uid, mode in ((0, 0o600), (0, 0o640)):
            with patch.object(w.os, 'fstat', return_value=SimpleNamespace(st_uid=uid, st_mode=stat.S_IFREG | mode)):
                assert w.trusted_compose(compose) == document
        for uid, mode in ((os.getuid(), 0o600), (0, 0o666), (0, 0o644)):
            with patch.object(w.os, 'fstat', return_value=SimpleNamespace(st_uid=uid, st_mode=stat.S_IFREG | mode)):
                try:
                    w.trusted_compose(compose)
                except ValueError:
                    pass
                else:
                    raise AssertionError('untrusted compose was accepted')
    link = home / 'link.yml'
    link.symlink_to(compose)
    try:
        w.trusted_compose(link)
    except ValueError:
        pass
    else:
        raise AssertionError('symlink compose was accepted')
    print('ok - root-private canonical compose is required; user-owned, writable, public and symlink files fail')

    # Current and older protected anchors must reference the familiar inodes.
    for root in (w.COMPOSE.parent / 'mounts/users', home.parent / '.omarchy-windows/users'):
        anchors = (root / str(account.pw_uid) / 'storage', root / str(account.pw_uid) / 'shared')
        current = copy.deepcopy(container)
        config = copy.deepcopy(document)
        config['services']['windows']['volumes'] = [f'{anchors[0]}:/storage', f'{anchors[1]}:/shared']
        current['HostConfig']['Binds'] = [f'{path}:{target}:rw' for path, target in zip(anchors, ('/storage', '/shared'))]
        for mount, anchor in zip(current['Mounts'], anchors):
            mount['Source'] = str(anchor)
        with patch.object(w.os.path, 'ismount', return_value=True), patch.object(Path, 'samefile', return_value=True):
            w.validate(current, image, config, account)
        with patch.object(w.os.path, 'ismount', return_value=True), patch.object(Path, 'samefile', return_value=False):
            rejected(current, config)
    print('ok - both protected anchor layouts require the original user disk/shared inodes')

    network = {'Driver': 'bridge', 'Internal': False, 'Options': {},
               'Labels': {'com.docker.compose.project': 'windows', 'com.docker.compose.network': 'default'}}
    calls = []
    source_state = {'Running': False, 'ExitCode': 0}
    def fake_docker(*args):
        calls.append(args)
        if args[0] == 'info':
            return '["name=seccomp,profile=builtin", "name=cgroupns"]'
        return ''
    def fake_inspect(kind, identity):
        if kind == 'image': return image
        if kind == 'network': return network
        if identity == w.NAME: return container
        return {'State': source_state}
    with patch.object(w, 'docker', fake_docker), patch.object(w, 'inspect', fake_inspect), patch.object(w, 'trusted_compose', return_value=document):
        w.handover(account)
        assert not any(args[0] in ('stop', 'start') for args in calls)
        calls.clear()
        w.handover(account, stop=True)
        assert ('stop', '-t', '120', container['Id']) in calls
        assert not any(args[0] == 'start' for args in calls)
        for state in ({'Running': False, 'ExitCode': 137}, {'Running': False, 'ExitCode': 139}, {'Running': True, 'ExitCode': 0}):
            calls.clear()
            source_state = state
            try:
                w.handover(account, stop=True)
            except ValueError:
                pass
            else:
                raise AssertionError('unclean Windows stop was accepted')
            assert ('start', container['Id']) in calls
        calls.clear()
        container['Config']['Image'] = 'redis:7'
        try:
            w.handover(account, stop=True)
        except ValueError:
            pass
        else:
            raise AssertionError('changed source was stopped')
        assert not any(args[0] in ('stop', 'start') for args in calls)
    print('ok - handover rechecks before stop, verifies clean exit and restarts the source after forced shutdown')
PY
