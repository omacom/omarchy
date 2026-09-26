"""Apply Omarchy DNS choices to resolved's live links, leaving NM profiles alone."""

import contextlib
import fcntl
import ipaddress
import json
import os
from pathlib import Path
import re
import socket
import subprocess
import sys
import tempfile

POLICY = Path('/etc/omarchy/dns.json')
LEGACY_NM = Path('/etc/NetworkManager/conf.d/20-omarchy-dns.conf')
RESOLVED_CONF = Path('/etc/systemd/resolved.conf')
BACKUP_DIR = Path('/var/lib/omarchy/dns-backup')
LOCK = Path('/run/omarchy-dns.lock')
PRESETS = {
  'Cloudflare': ['1.1.1.1', '1.0.0.1', '2606:4700:4700::1111', '2606:4700:4700::1001'],
  'Google': ['8.8.8.8', '8.8.4.4', '2001:4860:4860::8888', '2001:4860:4860::8844'],
}
SERVER_NAMES = {'Cloudflare': 'cloudflare-dns.com', 'Google': 'dns.google'}
LEGACY_FALLBACK = ('9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net '
                   '2620:fe::fe#dns.quad9.net 2620:fe::9#dns.quad9.net')
NM = 'org.freedesktop.NetworkManager'
NM_PATH = '/org/freedesktop/NetworkManager'
RESOLVED = 'org.freedesktop.resolve1'
RESOLVED_PATH = '/org/freedesktop/resolve1'
# Never alter VPN, WireGuard, tun/tap, or externally managed links. Logical
# uplinks (e.g. a VLAN on Ethernet) need the same treatment as physical NICs.
UPLINK_TYPES = {'802-3-ethernet', '802-11-wireless', 'bridge', 'bond', 'vlan',
                'team', 'bluetooth', 'gsm', 'cdma', 'adsl', 'macvlan', 'ipvlan', 'veth'}


def servers_from_input(value):
  servers = []
  for token in re.split(r'[\s,]+', value.strip()):
    if not token:
      continue
    if '%' in token:
      raise ValueError('Use IPv6 addresses without an interface suffix; DNS is applied per link.')
    address = ipaddress.ip_address(token)
    if address.is_unspecified or address.is_multicast or str(address) in {'127.0.0.53', '127.0.0.54', '255.255.255.255'}:
      raise ValueError(f'{token} cannot be used as an upstream DNS server.')
    if str(address) not in servers:
      servers.append(str(address))
  if not servers:
    raise ValueError('No DNS servers provided.')
  return servers


def read_policy():
  if not POLICY.exists():
    return None
  policy = json.loads(POLICY.read_text())
  provider = policy.get('provider')
  if provider not in {*PRESETS, 'Custom'} or not isinstance(policy.get('servers'), list):
    raise ValueError(f'Invalid DNS policy in {POLICY}')
  servers = servers_from_input(' '.join(policy['servers']))
  if provider in PRESETS and servers != PRESETS[provider]:
    raise ValueError(f'Invalid {provider} servers in {POLICY}')
  return {'provider': provider, 'servers': servers}


def legacy_provider():
  # Read-only compatibility until the next explicit provider selection.
  servers = []
  for path, prefix in ((LEGACY_NM, 'servers='), (RESOLVED_CONF, 'DNS=')):
    if path.exists():
      for line in path.read_text().splitlines():
        if line.strip().startswith(prefix):
          servers = re.split(r'[\s,]+', line.strip()[len(prefix):])
          break
    if any(servers):
      break
  addresses = {s.split('#')[0] for s in servers if s}
  for provider, preset in PRESETS.items():
    if addresses and addresses <= set(preset):
      return provider
  return 'Custom' if addresses else 'DHCP'


def atomic_write(path, data, mode=0o644):
  path.parent.mkdir(parents=True, exist_ok=True)
  fd, temporary = tempfile.mkstemp(prefix=f'.{path.name}.', dir=path.parent)
  try:
    with os.fdopen(fd, 'wb') as stream:
      stream.write(data)
      stream.flush()
      os.fsync(stream.fileno())
      os.fchmod(stream.fileno(), mode)
    os.replace(temporary, path)
  finally:
    Path(temporary).unlink(missing_ok=True)


@contextlib.contextmanager
def locked():
  fd = os.open(LOCK, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
  with os.fdopen(fd, 'w') as stream:
    fcntl.flock(stream, fcntl.LOCK_EX)
    yield


def stock_resolved_config(text):
  if text == '[Resolve]\nDNSOverTLS=no\n':
    return True
  for provider, servers in PRESETS.items():
    dns = ' '.join(f'{server}#{SERVER_NAMES[provider]}' for server in servers)
    if text == f'[Resolve]\nDNS={dns}\nFallbackDNS={LEGACY_FALLBACK}\nDNSOverTLS=opportunistic\n':
      return True
  match = re.fullmatch(r'\[Resolve\]\nDNS=([^\n]+)\nFallbackDNS=' + re.escape(LEGACY_FALLBACK) + r'\n', text)
  if match:
    try:
      servers_from_input(match[1])
      return True
    except ValueError:
      pass
  return False


def legacy_changes():
  changes = {}
  if LEGACY_NM.exists():
    match = re.fullmatch(
      r'# Managed by omarchy-dns\. Remove this file or run omarchy dns DHCP to use DHCP DNS again\.\n'
      r'\[global-dns\]\n\n\[global-dns-domain-\*\]\nservers=([^\n]+)\n', LEGACY_NM.read_text())
    if not match:
      raise ValueError(f'{LEGACY_NM} contains unrecognized configuration; preserve or move it manually first.')
    servers_from_input(match[1])
    changes[LEGACY_NM] = None
  if RESOLVED_CONF.exists() and stock_resolved_config(RESOLVED_CONF.read_text()):
    original = RESOLVED_CONF.read_text()
    # Keep the existing encryption policy when removing the old global servers.
    updated = ''.join(line for line in original.splitlines(keepends=True)
                      if not line.startswith(('DNS=', 'FallbackDNS=')))
    if updated != original:
      changes[RESOLVED_CONF] = updated.encode()
  return changes


class Resolver:
  def __init__(self):
    from gi.repository import Gio, GLib
    self.Gio, self.GLib = Gio, GLib
    self.bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)

  def call(self, name, path, interface, method, signature=None, args=()):
    parameters = self.GLib.Variant(signature, args) if signature else None
    return self.bus.call_sync(name, path, interface, method, parameters, None,
                             self.Gio.DBusCallFlags.NO_AUTO_START, 10000, None).unpack()

  def properties(self, name, path, interface):
    return self.call(name, path, 'org.freedesktop.DBus.Properties', 'GetAll', '(s)', (interface,))[0]

  def check(self):
    config = self.properties(NM, NM_PATH + '/DnsManager', NM + '.DnsManager')
    if config['Mode'] != 'systemd-resolved':
      raise ValueError('Omarchy DNS requires NetworkManager to use systemd-resolved.')
    self.properties(RESOLVED, RESOLVED_PATH, RESOLVED + '.Manager')
    return config

  def refresh(self, config=False):
    # Reload only DNS (and, for legacy cleanup, the global configuration).
    # Unlike Device.Reapply, this does not restart DHCP transactions.
    self.call(NM, NM_PATH, NM, 'Reload', '(u)', (4 | int(config),))

  def apply(self, policy):
    config = self.check()
    native = config.get('Configuration', [])
    if any(entry.get('nameservers') and not entry.get('interface') for entry in native):
      raise ValueError('NetworkManager has a custom global DNS configuration. Preserve or remove it before selecting an Omarchy provider.')
    global_dns = self.properties(RESOLVED, RESOLVED_PATH, RESOLVED + '.Manager')
    if any(entry[0] == 0 for entry in global_dns.get('DNS', [])):
      raise ValueError('DNS is also configured globally in resolved. Preserve or remove that custom global DNS configuration before selecting an Omarchy provider.')
    settings = self.properties(NM, NM_PATH, NM)
    server_name = SERVER_NAMES.get(policy['provider'], '')
    servers = []
    for server in policy['servers']:
      address = ipaddress.ip_address(server)
      servers.append((socket.AF_INET if address.version == 4 else socket.AF_INET6,
                      list(address.packed), 0, server_name))
    for device_path in settings['Devices']:
      device = self.properties(NM, device_path, NM + '.Device')
      # pre-up runs before ACTIVATED (100), after the IP configuration is ready.
      if not 80 <= device['State'] <= 100 or device['ActiveConnection'] == '/' or not device['Managed']:
        continue
      active = self.properties(NM, device['ActiveConnection'], NM + '.Connection.Active')
      if active['Type'] not in UPLINK_TYPES or active.get('Vpn') or active.get('StateFlags', 0) & 0x80:
        continue
      interface = device['IpInterface']
      ifindex = socket.if_nametoindex(interface)
      link_path = self.call(RESOLVED, RESOLVED_PATH, RESOLVED + '.Manager', 'GetLink', '(i)', (ifindex,))[0]
      link = self.properties(RESOLVED, link_path, RESOLVED + '.Link')
      # Retain NetworkManager's routing and encryption policy. Never add ~.
      # and compete with a privacy VPN, or weaken enforced DNS-over-TLS.
      has_native_dns = any(entry.get('interface') == interface and entry.get('nameservers') for entry in native)
      # A default uplink with no native DNS still needs to work. Do not revive
      # a link whose DNS routing NetworkManager suppressed (e.g. VPN priority).
      supply_default = (not has_native_dns and (active['Default'] or active['Default6'])
                        and not any(entry.get('priority', 0) < 0 for entry in native))
      if not link['DefaultRoute'] and not link['Domains'] and not supply_default:
        continue
      if supply_default and not link['DefaultRoute']:
        self.call(RESOLVED, RESOLVED_PATH, RESOLVED + '.Manager', 'SetLinkDefaultRoute', '(ib)', (ifindex, True))
      if link.get('DNSEx') != servers:
        self.call(RESOLVED, RESOLVED_PATH, RESOLVED + '.Manager', 'SetLinkDNSEx', '(ia(iayqs))', (ifindex, servers))


def reload_resolved():
  # Current Omarchy's resolved supports reload; do not restart it and discard
  # other services' live VPN configuration if a reload fails.
  subprocess.run(['/usr/bin/systemctl', 'reload', 'systemd-resolved.service'], check=True)


def set_provider(provider, custom=None):
  if provider == 'DHCP':
    policy = None
  else:
    servers = PRESETS[provider] if provider in PRESETS else servers_from_input(custom or '')
    policy = {'provider': provider, 'servers': servers}
  with locked():
    resolver = Resolver()
    resolver.check()
    changes = legacy_changes()
    paths = [POLICY, *changes]
    before = {path: path.read_bytes() if path.exists() else None for path in paths}
    modes = {path: path.stat().st_mode & 0o777 for path in paths if path.exists()}
    try:
      for path, updated in changes.items():
        BACKUP_DIR.mkdir(parents=True, exist_ok=True)
        backup = BACKUP_DIR / path.name
        if not backup.exists():
          with backup.open('xb') as stream:
            os.fchmod(stream.fileno(), 0o600)
            stream.write(before[path])
            stream.flush()
            os.fsync(stream.fileno())
        if updated is None:
          path.unlink()
        else:
          atomic_write(path, updated, modes[path])
      if policy:
        atomic_write(POLICY, (json.dumps(policy) + '\n').encode())
      else:
        POLICY.unlink(missing_ok=True)
      if RESOLVED_CONF in changes:
        reload_resolved()
      if changes or not policy:
        resolver.refresh(config=LEGACY_NM in changes)
      if policy:
        resolver.apply(policy)
    except Exception:
      for path, content in before.items():
        if content is None:
          path.unlink(missing_ok=True)
        else:
          atomic_write(path, content, modes[path])
      try:
        if RESOLVED_CONF in changes:
          reload_resolved()
        resolver.refresh(config=LEGACY_NM in changes)
        previous = read_policy()
        if previous:
          resolver.apply(previous)
      except Exception as recovery_error:
        print(f'DNS recovery also failed: {recovery_error}', file=sys.stderr)
      raise


def main():
  action = sys.argv[1]
  if action == 'status':
    policy = read_policy()
    print(policy['provider'] if policy else legacy_provider())
    return
  if os.geteuid() != 0:
    raise ValueError('Changing DNS requires root privileges.')
  if action == 'apply':
    with locked():
      policy = read_policy()
      if policy:
        resolver = Resolver()
        if sys.argv[2:] == ['--refresh']:
          resolver.refresh()
        resolver.apply(policy)
  elif action == 'set':
    provider = sys.argv[2]
    custom = None
    if provider == 'Custom':
      print("Enter your DNS servers (space-separated IPv4 or IPv6 addresses):")
      custom = input()
    set_provider(provider, custom)
  else:
    raise ValueError(f'Unknown DNS operation: {action}')


if __name__ == '__main__':
  try:
    main()
  except Exception as error:
    print(f'Error: {error}', file=sys.stderr)
    sys.exit(1)
