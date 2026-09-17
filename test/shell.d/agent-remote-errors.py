"""SSH diagnostics through real pipes and a controlled executable, without auth."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(sys.argv.pop(1)).resolve()
sys.path.insert(0, str(ROOT / 'default/agent-remote'))
from transport import Sftp, TransportError


class SshErrorTests(unittest.TestCase):
  def setUp(self):
    self.temp = tempfile.TemporaryDirectory()
    self.root = Path(self.temp.name)
    self.ssh = self.root / 'ssh'
    self.ssh.write_text('#!' + sys.executable + '\n' + '''
import sys, time
sys.stderr.write('sign_and_send_pubkey: signing failed for ED25519 "private fixture key": agent refused operation\\n')
sys.stderr.flush()
time.sleep(30)
''')
    self.ssh.chmod(0o755)
    self.environment = patch.dict(os.environ, PATH=str(self.root) + ':' + os.environ['PATH'])
    self.environment.start()

  def tearDown(self):
    self.environment.stop()
    self.temp.cleanup()

  def test_pre_handshake_timeout_retains_refusal_as_secondary_context(self):
    with self.assertRaises(TransportError) as caught:
      with Sftp('fixture-alias', timeout=5):
        self.fail('The stalled fixture must not establish an SFTP session')
    self.assertTrue(str(caught.exception).startswith('SSH transfer timed out'))
    self.assertIn('agent signing refusal was reported during this attempt (failure cause unconfirmed)', str(caught.exception))
    self.assertNotIn('private fixture key', str(caught.exception))

  def test_pre_handshake_exit_retains_refusal_as_secondary_context(self):
    self.ssh.write_text(self.ssh.read_text().replace('time.sleep(30)', 'sys.exit(255)'))
    with self.assertRaises(TransportError) as caught:
      Sftp('fixture-alias', timeout=5)
    self.assertIn('agent signing refusal was reported during this attempt (failure cause unconfirmed)', str(caught.exception))

  def test_silent_stall_remains_a_timeout(self):
    self.ssh.write_text('#!' + sys.executable + '\nimport time\ntime.sleep(30)\n')
    with self.assertRaises(TransportError) as caught:
      Sftp('fixture-alias', timeout=5)
    self.assertIn('SSH transfer timed out', str(caught.exception))

  def test_subsystem_failure_after_key_refusal_keeps_primary_connection_error(self):
    self.ssh.write_text(self.ssh.read_text().replace('time.sleep(30)', '''
sys.stderr.write('subsystem request failed on channel 0\\n')
sys.exit(255)
'''))
    with self.assertRaises(TransportError) as caught:
      Sftp('fixture-alias', timeout=5)
    self.assertTrue(str(caught.exception).startswith('SSH/SFTP unavailable'))
    self.assertIn('failure cause unconfirmed', str(caught.exception))
    self.assertNotIn('private fixture key', str(caught.exception))

  def test_unknown_ssh_failure_does_not_publish_private_diagnostics(self):
    self.ssh.write_text('#!' + sys.executable + '\n' + '''
import sys
sys.stderr.write('private fixture key: unrelated connection failure\\n')
sys.exit(255)
''')
    with self.assertRaises(TransportError) as caught:
      Sftp('fixture-alias', timeout=5)
    self.assertIn('SSH/SFTP unavailable', str(caught.exception))
    self.assertNotIn('private fixture key', str(caught.exception))

  def successful_handshake_after_refusal(self):
    self.ssh.write_text(self.ssh.read_text().replace('time.sleep(30)', '''
import os, struct
os.read(0, 9)
os.write(1, struct.pack('>IBI', 5, 2, 3))
time.sleep(30)
'''))

  def test_successful_handshake_is_not_rejected_for_an_earlier_key_refusal(self):
    self.successful_handshake_after_refusal()
    with Sftp('fixture-alias', timeout=5):
      pass

  def test_transfer_timeout_after_success_does_not_reuse_an_earlier_key_refusal(self):
    self.successful_handshake_after_refusal()
    with Sftp('fixture-alias', timeout=5) as remote:
      with self.assertRaises(TransportError) as caught:
        remote.realpath('.')
    self.assertIn('SSH transfer timed out', str(caught.exception))
    self.assertNotIn('signing refusal', str(caught.exception))

  def identity_refusal(self):
    self.ssh.write_text('#!' + sys.executable + '\n' + '''
import os, struct, sys, time
if '-s' in sys.argv:
  os.read(0, 9)
  os.write(1, struct.pack('>IBI', 5, 2, 3))
  time.sleep(30)
else:
  sys.stderr.write('sign_and_send_pubkey: signing failed for ED25519 "private fixture key": agent refused operation\\n')
  sys.exit(255)
''')

  def test_identity_255_retains_refusal_as_secondary_context(self):
    self.identity_refusal()
    with Sftp('fixture-alias', timeout=5) as remote:
      with self.assertRaises(TransportError) as caught:
        remote.identity()
    self.assertIn('agent signing refusal was reported during this attempt (failure cause unconfirmed)', str(caught.exception))
    self.assertNotIn('private fixture key', str(caught.exception))

  def test_identity_remote_command_failure_after_key_refusal_has_no_auth_cause(self):
    for returncode in (1, 127, 255):
      with self.subTest(returncode=returncode):
        self.identity_refusal()
        self.ssh.write_text(self.ssh.read_text().replace('  sys.exit(255)', '''
  # A command started after another key authenticated successfully. Its
  # exit 255 is indistinguishable from an SSH failure at this boundary.
  sys.stdout.write('Linux\\n501\\nfixture-user\\n')
  sys.exit(''' + str(returncode) + ')'))
        with Sftp('fixture-alias', timeout=5) as remote:
          with self.assertRaises(TransportError) as caught:
            remote.identity()
        self.assertEqual(str(caught.exception),
                         'SSH identity check failed' + ('; an agent signing refusal was reported during this attempt (failure cause unconfirmed)' if returncode == 255 else ''))

  def test_identity_remote_command_timeout_after_key_refusal_has_no_auth_cause(self):
    self.identity_refusal()
    self.ssh.write_text(self.ssh.read_text().replace('  sys.exit(255)', '''
  sys.stdout.write('Linux\\n501\\nfixture-user\\n')
  sys.stdout.flush()
  time.sleep(30)
'''))
    with Sftp('fixture-alias', timeout=5) as remote:
      with self.assertRaises(TransportError) as caught:
        remote.identity()
    self.assertEqual(str(caught.exception),
                     'SSH identity check timed out')

  def test_cli_add_identity_failure_does_not_claim_a_retained_snapshot(self):
    self.identity_refusal()
    env = dict(os.environ, HOME=str(self.root / 'home'), XDG_CONFIG_HOME=str(self.root / 'config'),
               XDG_STATE_HOME=str(self.root / 'state'), XDG_CACHE_HOME=str(self.root / 'cache'),
               OMARCHY_PATH=str(ROOT), PYTHONDONTWRITEBYTECODE='1')
    added = subprocess.run([str(ROOT / 'bin/omarchy-agent-machine'), 'add', 'fixture-alias'],
                           env=env, capture_output=True, text=True, timeout=10)
    self.assertEqual(added.returncode, 1)
    self.assertEqual(added.stdout, '')
    self.assertTrue(added.stderr.startswith('SSH identity check failed'))
    self.assertIn('failure cause unconfirmed', added.stderr)
    self.assertNotIn('retained', added.stderr)
    self.assertNotIn('private fixture key', added.stderr)
    self.assertFalse((self.root / 'config/omarchy/agents/machines.json').exists())
    self.assertFalse((self.root / 'state/omarchy/agents/remote/state.json').exists())

  def assert_cli_failure(self, established):
    config = self.root / 'config/omarchy/agents'
    state = self.root / 'state/omarchy/agents/remote'
    cache = self.root / 'cache/omarchy/agents/remote'
    config.mkdir(parents=True)
    state.mkdir(parents=True)
    machine_id = 'a' * 32
    profile = {'id': machine_id, 'identity': 'fixture-identity', 'label': 'Fixture', 'target': 'fixture-alias'}
    providers = {'claude': {'id': 'claude', 'todayTotalTokens': 17}}
    prior = dict(profile, status='current', lastSuccess=1234, providers=providers, issues=[]) if established else profile
    (config / 'machines.json').write_text(json.dumps({'schemaVersion': 1, 'machines': [profile]}))
    (state / 'state.json').write_text(json.dumps({'schemaVersion': 1, 'machines': [prior]}))
    result = cache / machine_id / 'result.json'
    if established:
      result.parent.mkdir(parents=True)
      result.write_text('{"fixture":"last good cache"}\n')
    before = result.read_bytes() if established else None
    env = dict(os.environ, HOME=str(self.root / 'home'), XDG_CONFIG_HOME=str(self.root / 'config'),
               XDG_STATE_HOME=str(self.root / 'state'), XDG_CACHE_HOME=str(self.root / 'cache'),
               OMARCHY_PATH=str(ROOT), PYTHONDONTWRITEBYTECODE='1')
    refreshed = subprocess.run([str(ROOT / 'bin/omarchy-agent-machine'), 'refresh', '--force'],
                               env=env, capture_output=True, text=True, timeout=10)
    self.assertEqual(refreshed.returncode, 0, 'A completed sweep preserves the partial-success exit contract')
    row = json.loads((state / 'state.json').read_text())['machines'][0]
    self.assertEqual(row['status'], 'stale' if established else 'unavailable')
    self.assertEqual(row.get('lastSuccess'), 1234 if established else None)
    self.assertEqual(row.get('providers'), providers if established else None)
    self.assertEqual(result.read_bytes() if result.exists() else None, before)
    self.assertIn('agent signing refusal was reported during this attempt (failure cause unconfirmed)', row['error'])
    self.assertNotIn('private fixture key', json.dumps(row))

  def test_cli_sweep_retains_last_good_usage_and_publishes_attempt_failure(self):
    self.identity_refusal()
    self.assert_cli_failure(established=True)

  def test_cli_first_sftp_failure_is_unavailable_without_a_zero_usage_snapshot(self):
    self.ssh.write_text(self.ssh.read_text().replace('time.sleep(30)', 'sys.exit(255)'))
    self.assert_cli_failure(established=False)


if __name__ == '__main__':
  unittest.main()
