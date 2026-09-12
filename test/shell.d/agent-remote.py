"""Exercise real read-only OpenSSH SFTP and the production collector boundary."""
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

ROOT = Path(sys.argv.pop(1))
sys.path.insert(0, str(ROOT / 'default/agent-remote'))
import main as machines
import collection
from transport import Sftp, target_value, ssh_command

SERVER = Path('/usr/lib/ssh/sftp-server')


def native(total, session='native-a'):
  tokens = {'input_tokens': total, 'cached_input_tokens': 0, 'cache_write_input_tokens': 0, 'output_tokens': 0, 'total_tokens': total}
  return [{'type': 'session_meta', 'payload': {'id': session}},
          {'type': 'turn_context', 'payload': {'model': 'gpt-6-astra'}},
          {'timestamp': datetime.now(timezone.utc).isoformat(), 'type': 'event_msg',
           'payload': {'type': 'token_count', 'info': {'total_token_usage': tokens, 'last_token_usage': tokens}}}]


class RemoteTests(unittest.TestCase):
  def setUp(self):
    self.temp = tempfile.TemporaryDirectory()
    self.root = Path(self.temp.name)
    self.source = self.root / 'remote'
    self.source.mkdir()
    self.cache = self.root / 'cache'
    self.config = self.root / 'config'
    self.state = self.root / 'state'
    for path in (self.cache, self.config, self.state):
      path.mkdir()
    # Only the SSH executable/system-command boundary is simulated. The real
    # client, remote identity shell command, SFTP server and collectors run.
    self.fake_bin = self.root / 'bin'
    self.fake_bin.mkdir()
    remote_bin = self.fake_bin / 'remote-tools'
    remote_bin.mkdir()
    system = remote_bin / 'remote-system'
    system.write_text("""#!/usr/bin/python3
import os, pathlib, sys
name = pathlib.Path(sys.argv[0]).name
if name == 'uname': print(os.environ['REMOTE_PLATFORM'])
elif name == 'id': print(os.environ['REMOTE_UID'] if sys.argv[1] == '-u' else 'fixture-user')
elif name == 'cat':
  if os.environ['REMOTE_PLATFORM'] != 'Linux': sys.exit(1)
  print(os.environ['REMOTE_MACHINE'])
elif name == 'ioreg': print('"IOPlatformUUID" = "' + os.environ['REMOTE_UUID'] + '"')
""")
    system.chmod(0o755)
    for name in ('uname', 'id', 'cat', 'ioreg'):
      (remote_bin / name).symlink_to(system.name)
    ssh = self.fake_bin / 'ssh'
    ssh.write_text(r"""#!/usr/bin/python3
import os, sys
args = sys.argv[1:]
if os.environ.get('REMOTE_OFFLINE'): sys.exit(255)
with open(os.environ['REMOTE_CALLS'], 'a') as log: log.write(repr(args) + '\n')
if '-s' in args:
  os.execv('/usr/lib/ssh/sftp-server', ['sftp-server', '-R', '-d', os.environ['REMOTE_HOME']])
env = dict(os.environ, HOME=os.environ['REMOTE_HOME'], PATH=os.environ['REMOTE_BIN'] + ':' + os.environ['PATH'])
os.execve('/bin/sh', ['sh', '-c', args[-1]], env)
""")
    ssh.chmod(0o755)
    self.env = dict(os.environ, PATH=str(self.fake_bin) + ':' + os.environ['PATH'],
                    HOME=str(self.root / 'local'), OMARCHY_PATH=str(ROOT),
                    XDG_CONFIG_HOME=str(self.config), XDG_STATE_HOME=str(self.state),
                    XDG_CACHE_HOME=str(self.cache), PYTHONDONTWRITEBYTECODE='1',
                    REMOTE_HOME=str(self.source), REMOTE_PLATFORM='Linux', REMOTE_UID='501',
                    REMOTE_MACHINE='0123456789abcdef0123456789abcdef',
                    REMOTE_UUID='01234567-89AB-CDEF-0123-456789ABCDEF',
                    REMOTE_CALLS=str(self.root / 'ssh-calls'), REMOTE_BIN=str(remote_bin))
    self.environment = patch.dict(os.environ, self.env)
    self.environment.start()

  def tearDown(self):
    self.environment.stop()
    self.temp.cleanup()

  def connection(self, target=None):
    return Sftp(target=target or 'fixture-alias')

  def write(self, relative, entries):
    path = self.source / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(''.join(json.dumps(entry) + '\n' for entry in entries))
    os.utime(path, (time.time() - 5, time.time() - 5))
    return path

  def collect(self, budget=64 * 1024 * 1024):
    with self.connection() as remote:
      result = collection.collect_sources(remote, remote.identity(), self.cache, ROOT, budget)
      return result, remote.transferred

  def test_native_append_cache_and_no_transcript_retention(self):
    path = self.write('.codex/sessions/test.jsonl', native(100) + [
      {'type': 'response_item', 'payload': {'role': 'user', 'content': 'PRIVATE PROMPT DO NOT CACHE'}}])
    (providers, issues), _ = self.collect()
    self.assertEqual(providers['codex']['todayTotalTokens'], 100)
    self.assertNotIn('invalid-native-record', providers['codex']['dailyUsage']['issues'])
    self.assertEqual(issues, [])
    run = subprocess.run
    def no_collector(command, **kwargs):
      self.assertEqual(command[0], 'ssh', 'warm cache reran collector')
      return run(command, **kwargs)
    with patch.object(collection.subprocess, 'run', side_effect=no_collector):
      (warm, _), transferred = self.collect()
    self.assertEqual(warm, providers)
    self.assertLess(transferred, 256, 'unchanged logs need no file-content reads')
    with path.open('a') as stream:
      stream.write(json.dumps(native(175)[-1]) + '\n')
    (updated, _), _ = self.collect()
    self.assertEqual(updated['codex']['todayTotalTokens'], 175)
    contents = ''.join(p.read_text() for p in self.cache.rglob('*.jsonl'))
    self.assertNotIn('PRIVATE PROMPT', contents)

  def test_replacement_and_partial_last_line(self):
    path = self.write('.codex/sessions/test.jsonl', native(100))
    self.collect()
    path.write_text(''.join(json.dumps(row) + '\n' for row in native(42, 'replacement')))
    (value, _), _ = self.collect()
    self.assertEqual(value['codex']['todayTotalTokens'], 42)
    line = json.dumps(native(60, 'replacement')[-1])
    with path.open('a') as stream:
      stream.write(line[:30])
    (value, _), _ = self.collect()
    self.assertEqual(value['codex']['todayTotalTokens'], 42)
    with path.open('a') as stream:
      stream.write(line[30:] + '\n')
    (value, _), _ = self.collect()
    self.assertEqual(value['codex']['todayTotalTokens'], 60)

  def test_claude_and_pi_keep_rates_but_drop_content(self):
    stamp = datetime.now(timezone.utc).isoformat()
    self.write('.claude/projects/project/test.jsonl', [{
      'type': 'assistant', 'timestamp': stamp, 'sessionId': 'claude-a', 'requestId': 'request-a',
      'message': {'id': 'message-a', 'role': 'assistant', 'model': 'claude-sonnet-5',
                  'content': 'SECRET ANSWER', 'usage': {'input_tokens': 100, 'output_tokens': 20,
                    'cache_creation_input_tokens': 30, 'cache_read_input_tokens': 0,
                    'service_tier': 'fast', 'inference_geo': 'us',
                    'cache_creation': {'ephemeral_5m_input_tokens': 0, 'ephemeral_1h_input_tokens': 30}}}}])
    self.write('.pi/agent/sessions/test.jsonl', [{'type': 'message', 'id': 'pi-a', 'timestamp': stamp,
      'message': {'role': 'assistant', 'provider': 'openai-codex', 'model': 'gpt-6-astra',
                  'content': 'SECRET PI', 'usage': {'input': 80, 'output': 10, 'cacheRead': 0, 'cacheWrite': 0}}}])
    (value, _), _ = self.collect()
    self.assertEqual(value['claude']['todayTotalTokens'], 150)
    self.assertEqual(value['codex']['todayTotalTokens'], 90)
    buckets = [b for day in value['claude']['dailyUsage']['days'] for b in day['buckets']]
    self.assertEqual(buckets[0]['tariff']['cache_creation']['ephemeral_1h_input_tokens'], 30)
    self.assertEqual(buckets[0]['tariff']['service_tier'], 'fast')
    self.assertEqual(buckets[0]['tariff']['inference_geo'], 'us')
    self.assertNotIn('SECRET', ''.join(p.read_text() for p in self.cache.rglob('*.jsonl')))

  def test_catalog_duplicate_offline_recovery_and_late_removal(self):
    self.write('.codex/sessions/test.jsonl', native(100))
    machine = machines.add(self.config, self.state, 'first-alias', 'Laptop', self.connection)
    with self.assertRaisesRegex(ValueError, 'already included'):
      machines.add(self.config, self.state, 'second-alias', 'Duplicate', self.connection)
    machines.refresh(self.config, self.state, self.cache, ROOT, factory=self.connection)
    previous = collection.read_json(self.state / 'state.json')['machines'][0]
    def offline(target):
      raise OSError('offline')
    machines.refresh(self.config, self.state, self.cache, ROOT, force=True, factory=offline)
    stale = collection.read_json(self.state / 'state.json')['machines'][0]
    self.assertEqual(stale['status'], 'stale')
    self.assertEqual(stale['lastSuccess'], previous['lastSuccess'])
    self.assertEqual(stale['providers'], previous['providers'])
    machines.refresh(self.config, self.state, self.cache, ROOT, force=True, factory=self.connection)
    self.assertNotIn('error', collection.read_json(self.state / 'state.json')['machines'][0])
    machines.mutate(self.config, self.state, machine['id'], remove=True)
    machines.publish(self.config, self.state, {machine['id']: previous})
    self.assertEqual(collection.read_json(self.state / 'state.json')['machines'], [])
    self.assertTrue((self.source / '.codex/sessions/test.jsonl').exists())

  def test_budget_resumes_and_failed_pass_does_not_reuse_old_result(self):
    self.write('.codex/sessions/a.jsonl', native(100))
    self.collect()
    changed = self.write('.codex/sessions/a.jsonl', native(200))
    os.utime(changed, None)
    self.write('.codex/sessions/b.jsonl', native(300, 'b'))
    with self.assertRaises(InterruptedError):
      self.collect(budget=700)
    (value, _), _ = self.collect()
    self.assertEqual(value['codex']['todayTotalTokens'], 500)

  def cli(self, *args, success=True):
    result = subprocess.run([str(ROOT / 'bin/omarchy-agent-machine'), *args],
                            capture_output=True, text=True)
    self.assertEqual(result.returncode == 0, success, result.stderr)
    return result

  def test_cli_verifies_connected_account_not_directory_owner(self):
    row = json.loads(self.cli('add', 'workbox', '--label', 'Laptop').stdout)
    self.assertEqual(row['uid'], 501)
    self.assertEqual(row['user'], 'fixture-user')
    self.assertEqual(row['home'], str(self.source))
    self.assertEqual(row['platform'], 'Linux')
    # SFTP may start in another directory; the connected account is unchanged.
    alternate = self.root / 'another-start'
    alternate.mkdir()
    with patch.dict(os.environ, REMOTE_HOME=str(alternate)):
      result = self.cli('add', 'second-alias', success=False)
    self.assertIn('already included', result.stderr)

  def test_cli_rejects_reused_target_even_if_account_changed(self):
    self.cli('add', 'workbox')
    with patch.dict(os.environ, REMOTE_UID='502'):
      result = self.cli('add', 'workbox', success=False)
    self.assertIn('already', result.stderr)
    self.assertEqual(len(json.loads(self.cli('list', '--json').stdout)), 1)

  def test_cli_linux_and_macos_lifecycle(self):
    path = self.write('.codex/sessions/test.jsonl', native(175) + [
      {'type': 'response_item', 'payload': {'role': 'user', 'content': 'PRIVATE CLI PROMPT'}}])
    original = path.read_bytes()
    for platform, label in (('Linux', 'Linux box'), ('Darwin', 'Mac laptop')):
      with self.subTest(platform=platform), patch.dict(os.environ, REMOTE_PLATFORM=platform):
        added = json.loads(self.cli('add', 'workbox', '--label', label).stdout)
        rows = json.loads(self.cli('list', '--json').stdout)
        self.assertEqual(rows[0]['user'], 'fixture-user')
        self.assertEqual(rows[0]['platform'], 'macOS' if platform == 'Darwin' else platform)
        self.assertIsNone(rows[0]['lastSuccess'])
        self.assertNotIn('providers', collection.read_json(self.state / 'omarchy/agents/remote/state.json')['machines'][0])
        self.cli('rename', added['id'], '--label', 'Renamed <computer>')
        self.assertIn('Renamed <computer>', self.cli('list').stdout)
        self.cli('refresh', '--force')
        snapshot = collection.read_json(self.state / 'omarchy/agents/remote/state.json')
        row = snapshot['machines'][0]
        self.assertEqual(row['status'], 'current')
        self.assertGreater(row['lastSuccess'], 0)
        self.assertEqual(row['providers']['codex']['todayTotalTokens'], 175)
        script = """
const remote = require(process.argv[1]);
const prices = require(process.argv[2]);
const machines = JSON.parse(process.argv[3]);
const scopes = remote.scopes([], machines, Date.now());
const all = scopes.all[0], single = scopes[machines[0].id][0];
const cost = prices.buildModelWindowPresentation('codex', all.dailyUsage, Date.now(), prices.parseOverrides(''), true);
console.log(JSON.stringify([all.todayTotalTokens, single.todayTotalTokens, cost.summaries[0].cost.total]));
"""
        shown = subprocess.run(['node', '-e', script, str(ROOT / 'shell/plugins/agents/RemoteUsage.js'),
                                str(ROOT / 'shell/plugins/agents/ApiCost.js'), json.dumps(snapshot['machines'])],
                               text=True, capture_output=True, check=True)
        self.assertEqual(json.loads(shown.stdout), [175, 175, 0.00175])
        self.cli('remove', added['id'])
        self.assertEqual(json.loads(self.cli('list', '--json').stdout), [])
        self.assertEqual(collection.read_json(self.state / 'omarchy/agents/remote/state.json')['machines'], [])
        self.assertEqual(path.read_bytes(), original)
        self.assertNotIn('PRIVATE CLI PROMPT', ''.join(p.read_text() for p in self.cache.rglob('*') if p.is_file()))
    self.assertEqual([str(p.relative_to(self.source)) for p in self.source.rglob('*') if p.is_file()],
                     ['.codex/sessions/test.jsonl'])

  def test_cli_rejects_local_account_and_invalid_identity_before_saving(self):
    with patch.dict(os.environ, REMOTE_UID=str(os.getuid()),
                    REMOTE_MACHINE=Path('/etc/machine-id').read_text().strip()):
      self.assertIn('This computer', self.cli('add', 'local-alias', success=False).stderr)
    for change in ({'REMOTE_UID': 'not-a-uid'}, {'REMOTE_MACHINE': 'invalid'},
                   {'REMOTE_PLATFORM': 'Darwin', 'REMOTE_UUID': '123'}, {'REMOTE_PLATFORM': 'Windows'}):
      with patch.dict(os.environ, change):
        self.cli('add', 'invalid', success=False)
    self.assertEqual(json.loads(self.cli('list', '--json').stdout), [])

  def test_cli_first_failed_import_and_distinct_accounts(self):
    with patch.dict(os.environ, REMOTE_OFFLINE='1'):
      self.cli('add', 'offline', success=False)
    self.assertEqual(json.loads(self.cli('list', '--json').stdout), [])
    first = json.loads(self.cli('add', 'first-account').stdout)
    with patch.dict(os.environ, REMOTE_UID='502'):
      second = json.loads(self.cli('add', 'second-account').stdout)
    self.assertNotEqual(first['identity'], second['identity'])
    with patch.dict(os.environ, REMOTE_OFFLINE='1'):
      self.cli('refresh', '--force')
    rows = collection.read_json(self.state / 'omarchy/agents/remote/state.json')['machines']
    self.assertEqual(len(rows), 2)
    for row in rows:
      self.assertEqual(row['status'], 'unavailable')
      self.assertNotIn('lastSuccess', row)
      self.assertNotIn('providers', row)

  def test_ambiguous_timestamp_retains_usage_without_wrong_day(self):
    rows = native(100)
    rows[-1]['timestamp'] = datetime.now().isoformat()
    self.write('.codex/sessions/test.jsonl', rows)
    (providers, _), _ = self.collect()
    self.assertEqual(providers['codex']['dailyUsage']['unallocatedTokens'], 100)
    self.assertEqual(providers['codex']['todayTotalTokens'], 0)

  def test_invalid_catalog_retains_previous_state(self):
    machines.add(self.config, self.state, 'first-alias', 'Laptop', self.connection)
    previous = (self.state / 'state.json').read_bytes()
    (self.config / 'machines.json').write_text('{broken')
    with self.assertRaises(ValueError):
      machines.refresh(self.config, self.state, self.cache, ROOT, factory=self.connection)
    self.assertEqual((self.state / 'state.json').read_bytes(), previous)

  def test_target_validation_and_no_first_snapshot_is_not_zero(self):
    for value in ('-oProxyCommand=bad', 'user:password@host', 'host\ncommand'):
      with self.assertRaises(ValueError):
        target_value(value)
    machine = machines.add(self.config, self.state, 'workbox', 'Laptop', self.connection)
    row = collection.read_json(self.state / 'state.json')['machines'][0]
    self.assertNotIn('providers', row)
    self.assertNotIn('lastSuccess', row)


if __name__ == '__main__':
  unittest.main()
