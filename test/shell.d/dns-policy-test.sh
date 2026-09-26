#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

# Run the real policy code with temporary files and a stubbed D-Bus boundary.
python3 -B <<'PYTHON'
import importlib.util
import os
from pathlib import Path
import socket
import tempfile
import unittest
from unittest.mock import patch, Mock

root = Path(os.environ['ROOT'])
spec = importlib.util.spec_from_file_location('dns', root / 'default/dns/dns.py')
dns = importlib.util.module_from_spec(spec)
spec.loader.exec_module(dns)


class PolicyTest(unittest.TestCase):
  def setUp(self):
    self.temp = tempfile.TemporaryDirectory()
    self.addCleanup(self.temp.cleanup)
    for name in ('POLICY', 'LEGACY_NM', 'RESOLVED_CONF', 'BACKUP_DIR', 'LOCK'):
      mock = patch.object(dns, name, Path(self.temp.name) / name)
      mock.start()
      self.addCleanup(mock.stop)
    self.resolver = Mock()
    mock = patch.object(dns, 'Resolver', return_value=self.resolver)
    mock.start()
    self.addCleanup(mock.stop)
    mock = patch.object(dns, 'reload_resolved')
    self.reload = mock.start()
    self.addCleanup(mock.stop)

  def test_custom_input(self):
    self.assertEqual(dns.servers_from_input(' 192.0.2.53,2001:db8::53 192.0.2.53 '), ['192.0.2.53', '2001:db8::53'])
    for value in ('', 'abc', '1.2.3.4\n[Resolve]', '127.0.0.53', '::', '224.0.0.1', 'fe80::53%eth0', '$(id)'):
      with self.subTest(value=value), self.assertRaises(ValueError):
        dns.set_provider('Custom', value)
      self.assertFalse(dns.POLICY.exists())

  def test_all_providers_and_dhcp(self):
    for provider in ('Cloudflare', 'Google', 'Custom'):
      dns.set_provider(provider, '192.0.2.53 2001:db8::53')
      self.assertEqual(dns.read_policy()['provider'], provider)
      self.resolver.apply.assert_called_with(dns.read_policy())
      self.resolver.refresh.assert_not_called()
      self.assertEqual(dns.POLICY.stat().st_mode & 0o777, 0o644)
    for _ in range(2):
      dns.set_provider('DHCP')
      self.assertFalse(dns.POLICY.exists())
      self.resolver.refresh.assert_called_with(config=False)
    self.reload.assert_not_called()

  def test_unowned_config_is_preserved(self):
    original = b'[Resolve]\nDNS=192.0.2.80\nDNSSEC=yes\n'
    dns.RESOLVED_CONF.write_bytes(original)
    dns.set_provider('Google')
    self.assertEqual(dns.RESOLVED_CONF.read_bytes(), original)
    dns.LEGACY_NM.write_text('# Managed by omarchy-dns.\n[main]\ndns=dnsmasq\n')
    with self.assertRaises(ValueError):
      dns.set_provider('DHCP')
    self.assertTrue(dns.LEGACY_NM.exists())

  def legacy(self):
    dns.LEGACY_NM.write_text('# Managed by omarchy-dns. Remove this file or run omarchy dns DHCP to use DHCP DNS again.\n[global-dns]\n\n[global-dns-domain-*]\nservers=1.1.1.1,1.0.0.1\n')
    servers = ' '.join(f'{ip}#cloudflare-dns.com' for ip in dns.PRESETS['Cloudflare'])
    dns.RESOLVED_CONF.write_text(f'[Resolve]\nDNS={servers}\nFallbackDNS={dns.LEGACY_FALLBACK}\nDNSOverTLS=opportunistic\n')

  def test_legacy_cleanup_backs_up_and_retains_encryption(self):
    self.legacy()
    original = dns.RESOLVED_CONF.read_bytes()
    dns.set_provider('Google')
    self.assertFalse(dns.LEGACY_NM.exists())
    self.assertEqual(dns.RESOLVED_CONF.read_text(), '[Resolve]\nDNSOverTLS=opportunistic\n')
    self.assertEqual((dns.BACKUP_DIR / dns.RESOLVED_CONF.name).read_bytes(), original)
    self.resolver.refresh.assert_called_with(config=True)
    self.reload.assert_called_once()

  def test_rollback_restores_files_modes_and_previous_dns(self):
    self.legacy()
    dns.set_provider('Custom', '192.0.2.53')
    self.legacy()
    dns.RESOLVED_CONF.chmod(0o600)
    paths = (dns.POLICY, dns.RESOLVED_CONF, dns.LEGACY_NM)
    before = {p: p.read_bytes() for p in paths}
    self.resolver.apply.side_effect = [RuntimeError('D-Bus failure'), None]
    with self.assertRaisesRegex(RuntimeError, 'D-Bus failure'):
      dns.set_provider('Google')
    self.assertEqual({p: p.read_bytes() for p in paths}, before)
    self.assertEqual(dns.RESOLVED_CONF.stat().st_mode & 0o777, 0o600)
    self.resolver.apply.assert_called_with({'provider': 'Custom', 'servers': ['192.0.2.53']})


class RoutingTest(unittest.TestCase):
  def setUp(self):
    self.resolver = object.__new__(dns.Resolver)
    self.config = {'Configuration': [{'interface': 'eth0', 'nameservers': ['192.0.2.1'], 'priority': 100}]}
    self.resolver.check = Mock(return_value=self.config)
    self.global_props = {'DNS': [(2, socket.AF_INET, [192, 0, 2, 1])]}
    self.device = {'State': 100, 'Managed': True, 'ActiveConnection': '/active', 'IpInterface': 'eth0'}
    self.active = {'Type': '802-3-ethernet', 'Vpn': False, 'StateFlags': 0, 'Default': True, 'Default6': False}
    self.link = {'DNSEx': [], 'Domains': [('corp.test', True)], 'DefaultRoute': False, 'DNSOverTLS': 'yes'}
    def properties(name, path, interface):
      return {dns.RESOLVED + '.Manager': self.global_props,
              dns.NM: {'Devices': ['/device']}, dns.NM + '.Device': self.device,
              dns.NM + '.Connection.Active': self.active, dns.RESOLVED + '.Link': self.link}[interface]
    self.resolver.properties = properties
    self.resolver.call = Mock(return_value=('/link',))
    mock = patch.object(socket, 'if_nametoindex', return_value=2)
    mock.start()
    self.addCleanup(mock.stop)

  def apply(self):
    self.resolver.apply({'provider': 'Google', 'servers': dns.PRESETS['Google']})
    # Check mutations, allowing read-only calls to change without test churn.
    return [c.args[3] for c in self.resolver.call.call_args_list if not c.args[3].startswith('Get')]

  def test_preserves_domains_route_and_enforced_tls(self):
    self.assertEqual(self.apply(), ['SetLinkDNSEx'])

  def test_ignores_vpn_wireguard_and_external_connections(self):
    for kind in ('vpn', 'wireguard', 'tun'):
      self.active['Type'] = kind
      self.assertEqual(self.apply(), [])
    self.active['Type'] = '802-3-ethernet'
    self.active['StateFlags'] = 0x80
    self.assertEqual(self.apply(), [])
    self.active['StateFlags'] = 0
    self.device['Managed'] = False
    self.assertEqual(self.apply(), [])

  def test_global_conflict_fails_before_changing_links(self):
    self.global_props['DNS'].append((0, socket.AF_INET, [192, 0, 2, 8]))
    with self.assertRaisesRegex(ValueError, 'globally'):
      self.apply()
    self.resolver.call.assert_not_called()

  def test_nm_global_conflict_fails_before_changing_links(self):
    self.config['Configuration'].append({'nameservers': ['192.0.2.80']})
    with self.assertRaisesRegex(ValueError, 'custom global'):
      self.apply()
    self.resolver.call.assert_not_called()

  def test_no_native_dns_default_uplink(self):
    self.config['Configuration'] = []
    self.assertEqual(self.apply(), ['SetLinkDefaultRoute', 'SetLinkDNSEx'])

  def test_negative_priority_cannot_be_overridden(self):
    self.config['Configuration'] = [{'interface': 'vpn0', 'priority': -50, 'nameservers': ['192.0.2.80']}]
    self.link['Domains'] = []
    self.assertEqual(self.apply(), [])

  def test_disconnected_and_pre_up(self):
    self.device['State'] = 30
    self.assertEqual(self.apply(), [])
    self.device['State'] = 90
    self.assertEqual(self.apply(), ['SetLinkDNSEx'])


unittest.main()
PYTHON
pass "DNS policy preserves network settings and recovers from failed changes"
