"""Validate the managed Windows disk handover before retiring Docker."""

import copy
import importlib.util
import json
import os
from pathlib import Path
import pwd
import stat
import subprocess
import sys

import yaml

sys.dont_write_bytecode = True


COMPOSE = Path('/var/lib/omarchy/windows/docker-compose.yml')
NAME = 'omarchy-windows'
IMAGES = {'dockurr/windows', 'dockurr/windows:latest', 'docker.io/dockurr/windows', 'docker.io/dockurr/windows:latest'}
PORTS = {'8006/tcp': [{'HostIp': '127.0.0.1', 'HostPort': '8006'}],
         '3389/tcp': [{'HostIp': '127.0.0.1', 'HostPort': '3389'}],
         '3389/udp': [{'HostIp': '127.0.0.1', 'HostPort': '3389'}]}


class UniqueLoader(yaml.SafeLoader):
    pass


def unique_mapping(loader, node):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node)
        if not isinstance(key, str) or key in result:
            raise ValueError('duplicate or unsupported configuration key')
        result[key] = loader.construct_object(value_node)
    return result


UniqueLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, unique_mapping)


def docker(*arguments):
    result = subprocess.run(['/usr/bin/docker', '--host', 'unix:///var/run/docker.sock', *arguments],
                            check=True, text=True, capture_output=True)
    return result.stdout


def inspect(kind, identity):
    return json.loads(docker(kind, 'inspect', identity))[0]


def trusted_compose(path):
    if path.resolve(strict=True) != path:
        raise ValueError('managed compose must have a canonical, non-symlink path')
    for parent in path.parents:
        info = parent.stat()
        if info.st_uid != 0 or info.st_mode & 0o022:
            raise ValueError('managed compose has a writable or untrusted parent')
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
    with os.fdopen(fd) as source:
        info = os.fstat(source.fileno())
        if not stat.S_ISREG(info.st_mode) or info.st_uid != 0 or info.st_mode & 0o027:
            raise ValueError('managed compose must be root-owned and private')
        return yaml.load(source, Loader=UniqueLoader)


def compose_settings(document, account):
    if not isinstance(document, dict) or set(document) != {'services'} or set(document['services']) != {'windows'}:
        raise ValueError('only the managed Windows service can use automatic handover')
    service = document['services']['windows']
    expected = {'image', 'container_name', 'environment', 'devices', 'cap_add', 'ports', 'volumes', 'restart', 'stop_grace_period'}
    if not isinstance(service, dict) or set(service) != expected:
        raise ValueError('custom Windows compose settings need an explicit transfer')
    if service['image'] not in IMAGES or service['container_name'] != NAME:
        raise ValueError('compose does not describe the managed Windows image')
    if (service['devices'] != ['/dev/kvm', '/dev/net/tun'] or service['cap_add'] != ['NET_ADMIN'] or
            set(service['ports']) != {'127.0.0.1:8006:8006', '127.0.0.1:3389:3389/tcp', '127.0.0.1:3389:3389/udp'} or
            service['restart'] != 'no' or service['stop_grace_period'] != '2m'):
        raise ValueError('custom Windows devices, privileges, ports or restart policy need review')
    environment = service['environment']
    keys = {'VERSION', 'RAM_SIZE', 'CPU_CORES', 'DISK_SIZE', 'USERNAME', 'PASSWORD', 'TZ', 'ARGUMENTS'}
    if not isinstance(environment, dict) or set(environment) not in (keys, keys | {'PROTECT'}):
        raise ValueError('custom Windows environment needs an explicit transfer')
    if (any(not isinstance(value, str) for value in environment.values()) or environment['VERSION'] != '11' or
            environment['ARGUMENTS'] != '-rtc base=localtime,clock=host,driftfix=slew' or
            environment.get('PROTECT', 'Y') != 'Y'):
        raise ValueError('custom Windows environment needs an explicit transfer')
    # The managed writer escapes every dollar as $$. Reject unresolved Compose
    # substitutions: evaluating those as root would not recreate the old values.
    decoded = {}
    for key, value in environment.items():
        if '$' in value.replace('$$', ''):
            raise ValueError('Windows environment substitutions need explicit review')
        decoded[key] = value.replace('$$', '$')
    home = Path(account.pw_dir)
    pairs = [(home / '.windows', home / 'Windows'),
             (COMPOSE.parent / 'mounts/users' / str(account.pw_uid) / 'storage',
              COMPOSE.parent / 'mounts/users' / str(account.pw_uid) / 'shared'),
             (home.parent / '.omarchy-windows/users' / str(account.pw_uid) / 'storage',
              home.parent / '.omarchy-windows/users' / str(account.pw_uid) / 'shared')]
    for storage, shared in pairs:
        if service['volumes'] == [f'{storage}:/storage', f'{shared}:/shared']:
            return service, decoded, (storage, shared)
    raise ValueError('Windows compose uses custom disk or shared-folder paths')


def validate_mounts(container, paths, account):
    mounts = container.get('Mounts') or []
    if len(mounts) != 2:
        raise ValueError('Windows container has additional or missing mounts')
    for destination, source, familiar in zip(('/storage', '/shared'), paths,
                                           (Path(account.pw_dir) / '.windows', Path(account.pw_dir) / 'Windows')):
        matches = [mount for mount in mounts if mount.get('Destination') == destination]
        if len(matches) != 1:
            raise ValueError('Windows container has duplicate or missing storage')
        mount = matches[0]
        if (mount.get('Type') != 'bind' or mount.get('RW') is not True or
                mount.get('Propagation') not in ('', 'rprivate') or Path(mount.get('Source', '')) != source):
            raise ValueError('Windows container mounts do not match its managed configuration')
        if not familiar.is_dir() or familiar.stat().st_uid != account.pw_uid:
            raise ValueError('Windows disk/shared directory is missing or belongs to another user')
        if source == familiar or os.path.ismount(source):
            if not source.samefile(familiar):
                raise ValueError('Windows mount anchor points at different data')
        elif (container['State']['Running'] or not source.is_dir() or source.is_symlink() or
              source.stat().st_uid != 0 or any(source.iterdir())):
            # An empty root-owned anchor may remain after reboot; the launcher
            # recreates that known mount from the familiar user directory.
            raise ValueError('Windows storage anchor cannot be verified')


def validate(container, image, document, account):
    service, environment, paths = compose_settings(document, account)
    config = container['Config']
    if container.get('Name') != '/' + NAME or config.get('Image') not in IMAGES or image['Id'] != container['Image']:
        raise ValueError('container is not the managed Windows image')
    baseline = image['Config']
    # Docker materializes an omitted image User as an empty string in the
    # container. Both mean the image's default root user, not an override.
    if (config.get('User') or '') != (baseline.get('User') or ''):
        raise ValueError('custom Windows User needs explicit review')
    for key in ('Cmd', 'Entrypoint', 'WorkingDir', 'Healthcheck', 'StopSignal', 'Volumes'):
        if config.get(key) != baseline.get(key):
            raise ValueError(f'custom Windows {key} needs explicit review')
    expected_env = dict(value.split('=', 1) for value in baseline.get('Env') or [])
    expected_env.update(environment)
    if dict(value.split('=', 1) for value in config.get('Env') or []) != expected_env:
        raise ValueError('running Windows environment differs from its managed configuration')
    if ((config.get('Domainname') or '') != (baseline.get('Domainname') or '') or
            config.get('Hostname', container['Id'][:12]) != container['Id'][:12]):
        raise ValueError('custom Windows hostname settings need explicit review')
    image_labels = baseline.get('Labels') or {}
    for key, value in (config.get('Labels') or {}).items():
        if not key.startswith('com.docker.compose.') and image_labels.get(key) != value:
            raise ValueError('custom Windows labels need explicit review')
    if config.get('StopTimeout') != 120 or config.get('Tty') or config.get('OpenStdin'):
        raise ValueError('custom Windows process settings need explicit review')
    host = container['HostConfig']
    devices = sorted((device.get('PathOnHost'), device.get('PathInContainer'), device.get('CgroupPermissions'))
                     for device in host.get('Devices') or [])
    if devices != [('/dev/kvm', '/dev/kvm', 'rwm'), ('/dev/net/tun', '/dev/net/tun', 'rwm')]:
        raise ValueError('custom Windows devices need explicit review')
    capabilities = [value.removeprefix('CAP_') for value in host.get('CapAdd') or []]
    if (capabilities != ['NET_ADMIN'] or host.get('PortBindings') != PORTS or
            host.get('RestartPolicy') != {'Name': 'no', 'MaximumRetryCount': 0} or
            host.get('ShmSize') != 67108864 or host.get('IpcMode') != 'private'):
        raise ValueError('custom Windows runtime settings need explicit review')
    expected_binds = {f'{path}:{destination}:rw' for path, destination in zip(paths, ('/storage', '/shared'))}
    if set(host.get('Binds') or []) != expected_binds:
        raise ValueError('custom Windows bind options need explicit review')
    # Reuse the general fail-closed security policy after removing only the
    # exact managed exceptions checked above. Runtime resources are not emitted
    # by the Windows writer and must not disappear during recreation.
    spec = importlib.util.spec_from_file_location('migration', Path(__file__).with_name('migrate-databases.py'))
    migration = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(migration)
    ordinary = copy.deepcopy(container)
    for field in ('CapAdd', 'Devices', 'Binds'):
        ordinary['HostConfig'][field] = []
    migration.validate_security(ordinary)
    for key in (*migration.RESOURCE_FLAGS, 'NanoCpus', 'PidsLimit', 'CapDrop', 'SecurityOpt'):
        defaults = (None, 0, '', []) + ((-1,) if key == 'PidsLimit' else ())
        if host.get(key) not in defaults:
            raise ValueError('custom Windows resource or confinement settings need explicit review')
    networks = container.get('NetworkSettings', {}).get('Networks') or {}
    if host.get('NetworkMode') != 'windows_default' or set(networks) != {'windows_default'}:
        raise ValueError('custom Windows networks need explicit review')
    if any(networks['windows_default'].get(key) for key in ('IPAMConfig', 'Links', 'DriverOpts')):
        raise ValueError('custom Windows network addressing needs explicit review')
    aliases = networks['windows_default'].get('Aliases') or []
    if set(aliases) - {NAME, 'windows', container['Id'][:12]}:
        raise ValueError('custom Windows network aliases need explicit review')
    validate_mounts(container, paths, account)


def check(account):
    options = json.loads(docker('info', '--format', '{{json .SecurityOptions}}'))
    if not isinstance(options, list) or not options or set(options) - {'name=seccomp,profile=builtin', 'name=seccomp,profile=default', 'name=cgroupns'}:
        raise ValueError('custom Docker daemon confinement needs explicit review')
    container = inspect('container', NAME)
    validate(container, inspect('image', container['Image']), trusted_compose(COMPOSE), account)
    network = inspect('network', 'windows_default')
    labels = network.get('Labels') or {}
    if (network.get('Driver') != 'bridge' or network.get('Internal') or network.get('Options') or
            labels.get('com.docker.compose.project') != 'windows' or labels.get('com.docker.compose.network') != 'default'):
        raise ValueError('Windows network is not the managed Compose bridge')
    return container


def handover(account, stop=False):
    container = check(account)
    if stop:
        identity = container['Id']
        running = container['State']['Running']
        try:
            docker('stop', '-t', '120', identity)
            state = inspect('container', identity)['State']
            if state['Running'] or (running and state['ExitCode'] in (137, 139)):
                raise ValueError('Windows did not stop cleanly; Docker must be retained')
        except BaseException:
            if running:
                docker('start', identity)
            raise


if __name__ == '__main__':
    try:
        if os.geteuid() != 0 or len(sys.argv) != 3 or sys.argv[1] not in ('--check', '--stop'):
            raise ValueError('invoke the Windows preflight through the migration')
        account = pwd.getpwnam(sys.argv[2])
        if account.pw_uid == 0:
            raise ValueError('Windows handover requires the desktop user')
        handover(account, stop=sys.argv[1] == '--stop')
    except (ValueError, KeyError, TypeError, OSError, subprocess.CalledProcessError, yaml.YAMLError):
        # Configuration, engine errors and environment values may contain the
        # Windows password. Never print their contents or command arguments.
        print('omarchy-windows: managed Windows handover could not be verified or stopped cleanly; Docker was retained for explicit review', file=sys.stderr)
        sys.exit(1)
