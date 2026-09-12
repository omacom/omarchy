"""Exercise real read-only OpenSSH SFTP and the production collector boundary."""
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
import fcntl
import json
import errno
import os
import shutil
import select
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import threading
import unittest
from unittest.mock import patch

ROOT = Path(sys.argv.pop(1))
sys.path.insert(0, str(ROOT / 'default/agent-remote'))
import main as machines
import collection
from transport import Sftp, target_value

# OpenSSH installs the subsystem in different lib/libexec directories. An
# explicit path also lets isolated runners declare this test-only dependency.
if 'OMARCHY_TEST_SFTP_SERVER' in os.environ:
  candidates = [os.environ['OMARCHY_TEST_SFTP_SERVER']]
else:
  candidates = [shutil.which('sftp-server'), '/usr/lib/ssh/sftp-server',
                '/usr/lib/openssh/sftp-server', '/usr/libexec/openssh/sftp-server',
                '/usr/libexec/sftp-server']
SFTP_SERVER = next((str(Path(p).resolve()) for p in candidates if p and os.path.isfile(p) and os.access(p, os.X_OK)), None)


def native(total, session='native-a'):
  tokens = {'input_tokens': total, 'cached_input_tokens': 0, 'cache_write_input_tokens': 0, 'output_tokens': 0, 'total_tokens': total}
  return [{'type': 'session_meta', 'payload': {'id': session}},
          {'type': 'turn_context', 'payload': {'model': 'gpt-6-astra'}},
          {'timestamp': datetime.now(timezone.utc).isoformat(), 'type': 'event_msg',
           'payload': {'type': 'token_count', 'info': {'total_token_usage': tokens, 'last_token_usage': tokens}}}]


def native_claude(incoming, outgoing=20):
  return [{'type': 'assistant', 'timestamp': datetime.now(timezone.utc).isoformat(),
           'sessionId': 'claude-native', 'requestId': 'native-request',
           'message': {'id': 'native-message', 'role': 'assistant', 'model': 'claude-sonnet-5',
                       'usage': {'input_tokens': incoming, 'output_tokens': outgoing,
                                 'cache_read_input_tokens': 0, 'cache_creation_input_tokens': 0}}}]


@unittest.skipUnless(SFTP_SERVER, 'read-only OpenSSH sftp-server unavailable; set OMARCHY_TEST_SFTP_SERVER')
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
    system.write_text('#!' + sys.executable + """
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
    ssh.write_text('#!' + sys.executable + r"""
import os, sys
args = sys.argv[1:]
if os.environ.get('REMOTE_OFFLINE'): sys.exit(255)
with open(os.environ['REMOTE_CALLS'], 'a') as log: log.write(repr(args) + '\n')
if '-s' in args:
  os.execv(os.environ['REMOTE_SFTP_SERVER'], ['sftp-server', '-R', '-d', os.environ['REMOTE_HOME']])
env = dict(os.environ, HOME=os.environ['REMOTE_HOME'], PATH=os.environ['REMOTE_BIN'] + ':' + os.environ['PATH'])
os.execve('/bin/sh', ['sh', '-c', args[-1]], env)
""")
    ssh.chmod(0o755)
    self.env = dict(os.environ, PATH=str(self.fake_bin) + ':' + os.environ['PATH'],
                    HOME=str(self.root / 'local'), OMARCHY_PATH=str(ROOT),
                    XDG_CONFIG_HOME=str(self.config), XDG_STATE_HOME=str(self.state),
                    XDG_CACHE_HOME=str(self.cache), PYTHONDONTWRITEBYTECODE='1',
                    REMOTE_SFTP_SERVER=SFTP_SERVER, REMOTE_HOME=str(self.source), REMOTE_PLATFORM='Linux', REMOTE_UID='501',
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

  def assert_transport_failure_retains_snapshot(self, established):
    source = self.write('.codex/sessions/test.jsonl', native(100))
    self.assertFalse((self.source / '.local/share/opencode').exists())
    for failure in ('deadline', 'disconnect', 'read-eof', 'read-timeout'):
      stages = ('identity', 'read', 'optional-probe') if failure in ('deadline', 'disconnect') else ('read',)
      for stage in stages:
        with self.subTest(failure=failure, stage=stage, established=established):
          source.write_text(''.join(json.dumps(row) + '\n' for row in native(100)))
          machine = machines.add(self.config, self.state, 'transport-box', 'Transport', self.connection)
          try:
            if established:
              machines.refresh(self.config, self.state, self.cache, ROOT, True, self.connection)
            before = collection.read_json(self.state / 'state.json')['machines'][0]
            result_path = self.cache / machine['id'] / 'result.json'
            old_result = result_path.read_bytes() if result_path.exists() else None
            source.write_text(''.join(json.dumps(row) + '\n' for row in native(1750)))
            reached = []
            pipe_fd = []
            class InterruptedSftp(Sftp):
              # All protocol operations are production SFTP. Only the session
              # deadline or actual child process changes at the chosen boundary.
              def interrupt(self, boundary):
                if stage != boundary or reached:
                  return
                reached.append(boundary)
                pipe_fd.append(self.process.stdout.fileno())
                if failure == 'deadline':
                  self.deadline = 0
                elif failure == 'disconnect':
                  self.process.kill()
                  self.process.wait(timeout=5)

              def identity(self):
                result = super().identity()
                self.interrupt('identity')
                return result

              def read(self, *args, **kwargs):
                result = super().read(*args, **kwargs)
                self.interrupt('read')
                return result

              def attrs(self, path):
                if path.endswith('/.local/share/opencode/opencode.db'):
                  self.interrupt('optional-probe')
                return super().attrs(path)

            read = os.read
            wait = select.select
            def read_pipe(fd, count):
              if failure == 'read-eof' and pipe_fd == [fd]:
                return b''
              return read(fd, count)
            def wait_pipe(readers, writers, errors, timeout):
              if failure == 'read-timeout' and readers and pipe_fd == [readers[0].fileno()]:
                return [], [], []
              return wait(readers, writers, errors, timeout)
            # EOF/inactivity while awaiting a reply are injected at the OS
            # boundary, after real identity and file reads have completed.
            with patch.object(os, 'read', side_effect=read_pipe), patch.object(select, 'select', side_effect=wait_pipe):
              machines.refresh(self.config, self.state, self.cache, ROOT, True, InterruptedSftp)
            self.assertEqual(reached, [stage], 'transport fault was not exercised')
            failed = collection.read_json(self.state / 'state.json')['machines'][0]
            self.assertEqual(failed['status'], 'stale' if established else 'unavailable')
            self.assertEqual(failed.get('lastSuccess'), before.get('lastSuccess'))
            self.assertEqual(failed.get('providers'), before.get('providers'))
            self.assertEqual(failed.get('issues', []), before.get('issues', []))
            self.assertNotIn('OpenCode', json.dumps(failed.get('issues', [])))
            self.assertIn('error', failed)
            self.assertEqual(result_path.read_bytes() if result_path.exists() else None, old_result)
            if not established:
              self.assertNotIn('lastSuccess', failed)
              self.assertNotIn('providers', failed)
            machines.refresh(self.config, self.state, self.cache, ROOT, True, self.connection)
            recovered = collection.read_json(self.state / 'state.json')['machines'][0]
            self.assertEqual(recovered['status'], 'current')
            self.assertEqual(recovered['issues'], [])
            self.assertEqual(recovered['providers']['codex']['todayTotalTokens'], 1750)
            self.assertNotIn('error', recovered)
            if established:
              self.assertGreater(recovered['lastSuccess'], before['lastSuccess'])
          finally:
            machines.mutate(self.config, self.state, machine['id'], remove=True)

  @unittest.skipIf(os.getuid() == 0, 'EACCES needs an unprivileged test account')
  def test_source_last_success_tracks_verified_pass_including_unchanged_sources(self):
    codex = self.write('.codex/sessions/test.jsonl', native(100))
    claude = self.write('.claude/projects/project/test.jsonl', native_claude(100))
    machine = machines.add(self.config, self.state, 'verified-box', 'Verified', self.connection)
    now = time.time() + 10
    def refresh_at(stamp):
      with patch.object(time, 'time', return_value=stamp):
        machines.refresh(self.config, self.state, self.cache, ROOT, True, self.connection)
      return collection.read_json(self.state / 'state.json')['machines'][0]
    first = refresh_at(now)
    quiet = refresh_at(now + 10)
    self.assertEqual(quiet['providers']['codex']['remoteSources']['.codex/sessions']['lastSuccess'], now + 10)
    self.assertEqual(quiet['providers']['claude']['remoteSources']['.claude/projects']['lastSuccess'], now + 10)
    self.assertEqual(quiet['providers']['codex']['remoteCollector'], first['providers']['codex']['remoteCollector'])
    claude.parent.chmod(0)
    try:
      codex.write_text(''.join(json.dumps(row) + '\n' for row in native(1750)))
      partial = refresh_at(now + 20)
      self.assertEqual(partial['providers']['claude']['remoteSources']['.claude/projects'],
                       {'status': 'stale', 'lastSuccess': now + 10})
      self.assertEqual(partial['providers']['codex']['remoteSources']['.codex/sessions']['lastSuccess'], now + 20)
      self.assertEqual(partial['providers']['codex']['todayTotalTokens'], 1750)
      self.assertEqual(partial['providers']['claude']['todayTotalTokens'], 120)
    finally:
      claude.parent.chmod(0o700)
    recovered = refresh_at(now + 30)
    self.assertEqual(recovered['providers']['claude']['remoteSources']['.claude/projects'],
                     {'status': 'current', 'lastSuccess': now + 30})
    self.assertEqual(recovered['status'], 'current')

  def test_first_import_transport_failure_remains_unavailable_until_recovery(self):
    self.assert_transport_failure_retains_snapshot(established=False)

  def test_cached_import_transport_failure_retains_last_success_until_recovery(self):
    self.assert_transport_failure_retains_snapshot(established=True)

  @unittest.skipIf(os.getuid() == 0, 'EACCES needs an unprivileged test account')
  def test_unreadable_source_retains_its_history_while_native_sources_advance(self):
    codex = self.write('.codex/sessions/test.jsonl', native(100))
    claude = self.write('.claude/projects/project/test.jsonl', native_claude(100))
    self.cli('add', 'partial-box')
    self.cli('refresh', '--force')
    state = self.state / 'omarchy/agents/remote/state.json'
    previous = collection.read_json(state)['machines'][0]
    claude.parent.chmod(0)
    try:
      with self.assertRaises(PermissionError):
        claude.read_bytes()
      codex.write_text(''.join(json.dumps(row) + '\n' for row in native(175)))
      self.cli('refresh', '--force')
      partial = collection.read_json(state)['machines'][0]
      self.assertEqual(partial['status'], 'incomplete')
      self.assertEqual(partial['providers']['codex']['todayTotalTokens'], 175)
      self.assertEqual(partial['providers']['claude']['todayTotalTokens'], 120)
      self.assertFalse(partial['providers']['claude']['dailyUsage']['complete'])
      self.assertTrue(partial['providers']['codex']['dailyUsage']['complete'])
      self.assertIn('.claude/projects', ' '.join(partial['issues']))
      self.assertLessEqual(partial['providers']['claude']['remoteSources']['.claude/projects']['lastSuccess'],
                           previous['lastSuccess'])
    finally:
      claude.parent.chmod(0o700)
    claude.write_text(''.join(json.dumps(row) + '\n' for row in native_claude(200)))
    self.cli('refresh', '--force')
    recovered = collection.read_json(state)['machines'][0]
    self.assertEqual(recovered['status'], 'current')
    self.assertEqual(recovered['issues'], [])
    self.assertEqual(recovered['providers']['codex']['todayTotalTokens'], 175)
    self.assertEqual(recovered['providers']['claude']['todayTotalTokens'], 220)
    self.assertTrue(recovered['providers']['claude']['dailyUsage']['complete'])

  def test_symlink_entries_do_not_hide_readable_siblings_or_follow_linked_parents(self):
    self.write('.codex/sessions/z-safe.jsonl', native(100))
    outside = self.write('outside/secret.jsonl', native(99999, 'must-not-read'))
    link = self.source / '.codex/sessions/a-link.jsonl'
    link.symlink_to(outside)
    self.cli('add', 'links-box')
    self.cli('refresh', '--force')
    state = self.state / 'omarchy/agents/remote/state.json'
    row = collection.read_json(state)['machines'][0]
    self.assertEqual(row['status'], 'incomplete')
    self.assertEqual(row['providers']['codex']['todayTotalTokens'], 100)
    self.assertFalse(row['providers']['codex']['dailyUsage']['complete'])
    self.assertIn('symlink', ' '.join(row['issues']).lower())
    link.unlink()
    # Even a parent above the configured root must not redirect the walk.
    for relative in ('.claude', '.pi/agent', '.omp/agent/sessions', '.kimi/sessions'):
      with self.subTest(relative=relative):
        link = self.source / relative
        link.parent.mkdir(parents=True, exist_ok=True)
        link.symlink_to(outside.parent, target_is_directory=True)
        try:
          self.cli('refresh', '--force')
          row = collection.read_json(state)['machines'][0]
          self.assertEqual(row['status'], 'incomplete')
          self.assertEqual(row['providers']['codex']['todayTotalTokens'], 100)
          self.assertIn('symlink', ' '.join(row['issues']).lower())
        finally:
          link.unlink()
    self.cli('refresh', '--force')
    row = collection.read_json(state)['machines'][0]
    self.assertEqual(row['status'], 'current')
    self.assertEqual(row['providers']['codex']['todayTotalTokens'], 100)
    self.assertNotIn('99999', ''.join(p.read_text() for p in self.cache.rglob('*.jsonl')))

  @unittest.skipIf(os.getuid() == 0, 'EACCES needs an unprivileged test account')
  def test_unreadable_optional_roots_are_incomplete_instead_of_zero(self):
    self.write('.codex/sessions/test.jsonl', native(123))
    self.cli('add', 'unreadable-box')
    for relative, provider in (('.claude/projects', 'claude'), ('.pi/agent/sessions', 'codex'),
                               ('.omp/agent/sessions', 'codex'), ('.kimi/sessions', 'kimi')):
      with self.subTest(relative=relative):
        directory = self.source / relative
        directory.mkdir(parents=True, exist_ok=True)
        directory.chmod(0)
        try:
          with self.assertRaises(PermissionError):
            list(directory.iterdir())
          self.cli('refresh', '--force')
          row = collection.read_json(self.state / 'omarchy/agents/remote/state.json')['machines'][0]
          self.assertEqual(row['status'], 'incomplete')
          self.assertEqual(row['providers']['codex']['todayTotalTokens'], 123)
          self.assertFalse(row['providers'][provider]['dailyUsage']['complete'])
          if provider != 'codex':
            self.assertIsNone(row['providers'][provider]['todayTotalTokens'])
        finally:
          directory.chmod(0o700)
    self.cli('refresh', '--force')
    row = collection.read_json(self.state / 'omarchy/agents/remote/state.json')['machines'][0]
    self.assertEqual(row['status'], 'current')
    self.assertEqual(row['issues'], [])

  @unittest.skipIf(os.getuid() == 0, 'EACCES needs an unprivileged test account')
  def test_file_read_and_parse_failures_keep_cached_source_and_fresh_siblings(self):
    bad = self.write('.claude/projects/project/test.jsonl', native_claude(100))
    self.write('.codex/sessions/test.jsonl', native(100))
    self.cli('add', 'files-box')
    self.cli('refresh', '--force')
    state = self.state / 'omarchy/agents/remote/state.json'
    for index, failure in enumerate(('eacces', 'json', 'nan')):
      with self.subTest(failure=failure):
        codex = self.write('.codex/sessions/test.jsonl', native(2000 + index))
        os.utime(codex, None)
        if failure == 'eacces':
          bad.chmod(0)
        elif failure == 'json':
          bad.write_text('{PRIVATE broken json\n')
        else:
          bad.write_text(''.join(json.dumps(row) + '\n' for row in native_claude(float('nan'))))
        try:
          self.cli('refresh', '--force')
          row = collection.read_json(state)['machines'][0]
          self.assertEqual(row['status'], 'incomplete')
          self.assertEqual(row['providers']['codex']['todayTotalTokens'], 2000 + index)
          self.assertEqual(row['providers']['claude']['todayTotalTokens'], 120)
          self.assertFalse(row['providers']['claude']['dailyUsage']['complete'])
        finally:
          bad.chmod(0o600)
    bad.write_text(''.join(json.dumps(row) + '\n' for row in native_claude(300)))
    self.cli('refresh', '--force')
    row = collection.read_json(state)['machines'][0]
    self.assertEqual(row['status'], 'current')
    self.assertEqual(row['providers']['claude']['todayTotalTokens'], 320)
    self.assertNotIn('PRIVATE', ''.join(p.read_text() for p in self.cache.rglob('*.jsonl')))

  def test_collector_process_failures_preserve_previous_provider_and_retry_without_source_change(self):
    self.write('.codex/sessions/test.jsonl', native(100))
    claude = self.write('.claude/projects/project/test.jsonl', native_claude(100))
    app = self.root / 'collector-app'
    (app / 'bin').mkdir(parents=True)
    (app / 'default').symlink_to((ROOT / 'default').resolve(), target_is_directory=True)
    for name in ('omarchy-agent-machine', 'omarchy-agent-usage-codex', 'omarchy-agent-usage-kimi'):
      (app / 'bin' / name).symlink_to((ROOT / 'bin' / name).resolve())
    wrapper = app / 'bin/omarchy-agent-usage-claude'
    wrapper.write_text('#!' + sys.executable + '\n' +
      "import os, sys\nmode = os.environ.get('COLLECTOR_FAILURE')\n" +
      "if mode == 'exit': sys.exit(7)\n" +
      "if mode == 'json': print('PRIVATE invalid JSON'); sys.exit(0)\n" +
      "if mode == 'shape': print('[]'); sys.exit(0)\n" +
      "if mode == 'deep': print('{\"id\":\"claude\",\"dailyUsage\":{\"schemaVersion\":1,\"complete\":false,\"days\":[{\"buckets\":[null]}]}}'); sys.exit(0)\n" +
      "if mode == 'nan': print('{\"id\":\"claude\",\"todayTotalTokens\":NaN,\"dailyUsage\":{\"schemaVersion\":1,\"days\":[]}}'); sys.exit(0)\n" +
      "os.execv(" + repr(str((ROOT / 'bin/omarchy-agent-usage-claude').resolve())) +
      ", ['omarchy-agent-usage-claude'] + sys.argv[1:])\n")
    wrapper.chmod(0o755)
    state = self.state / 'omarchy/agents/remote/state.json'
    with patch.dict(os.environ, OMARCHY_PATH=str(app)):
      self.cli('add', 'collector-box')
      # No prior Claude import: explicitly unavailable, never a measured zero.
      with patch.dict(os.environ, COLLECTOR_FAILURE='exit'):
        self.cli('refresh', '--force')
      first = collection.read_json(state)['machines'][0]
      self.assertEqual(first['status'], 'incomplete')
      self.assertEqual(first['providers']['codex']['todayTotalTokens'], 100)
      self.assertIsNone(first['providers']['claude']['todayTotalTokens'])
      self.assertFalse(first['providers']['claude']['dailyUsage']['complete'])
      self.cli('refresh', '--force')
      good = collection.read_json(state)['machines'][0]
      self.assertEqual(good['providers']['claude']['todayTotalTokens'], 120)
      for index, failure in enumerate(('exit', 'json', 'shape', 'deep', 'nan')):
        with self.subTest(failure=failure):
          codex = self.write('.codex/sessions/test.jsonl', native(2000 + index))
          os.utime(codex, None)
          claude.write_text(''.join(json.dumps(row) + '\n' for row in native_claude(200)))
          with patch.dict(os.environ, COLLECTOR_FAILURE=failure):
            self.cli('refresh', '--force')
          row = collection.read_json(state)['machines'][0]
          self.assertEqual(row['status'], 'incomplete')
          self.assertEqual(row['providers']['codex']['todayTotalTokens'], 2000 + index)
          self.assertEqual(row['providers']['claude']['todayTotalTokens'], 120)
          self.assertFalse(row['providers']['claude']['dailyUsage']['complete'])
          self.assertEqual(row['providers']['claude']['remoteCollector']['lastSuccess'],
                           good['providers']['claude']['remoteCollector']['lastSuccess'])
          self.assertNotIn('PRIVATE', json.dumps(row))
      # Recovery must retry even with an unchanged sanitized-source cache.
      self.cli('refresh', '--force')
      recovered = collection.read_json(state)['machines'][0]
      self.assertEqual(recovered['status'], 'current')
      self.assertEqual(recovered['providers']['claude']['todayTotalTokens'], 220)
      self.assertTrue(recovered['providers']['claude']['dailyUsage']['complete'])
      self.cli('refresh', '--force')
      self.assertEqual(collection.read_json(state)['machines'][0]['providers']['claude']['todayTotalTokens'], 220)

  def test_remove_while_refresh_waits_for_catalog_lock_does_not_fail_or_resurrect(self):
    self.write('.codex/sessions/test.jsonl', native(100))
    machine = machines.add(self.config, self.state, 'race-box', 'Race', self.connection)
    waiting = threading.Event()
    resume = threading.Event()
    flock = fcntl.flock
    test_thread = threading.get_ident()
    def pause_at_lock(stream, operation):
      # Pause at the OS lock boundary, before refresh can acquire the catalog.
      # Removal uses the real lock and public catalog mutation in the meantime.
      if (threading.get_ident() != test_thread and operation == fcntl.LOCK_EX
          and Path(stream.name) == self.config / '.machines.lock' and not waiting.is_set()):
        waiting.set()
        if not resume.wait(5):
          raise TimeoutError('test did not release catalog boundary')
      return flock(stream, operation)
    with patch.object(fcntl, 'flock', side_effect=pause_at_lock), ThreadPoolExecutor(max_workers=1) as pool:
      future = pool.submit(machines.refresh, self.config, self.state, self.cache, ROOT, True, self.connection)
      try:
        self.assertTrue(waiting.wait(5), 'refresh did not reach the catalog lock')
        machines.mutate(self.config, self.state, machine['id'], remove=True)
      finally:
        resume.set()
      future.result(timeout=5)
    self.assertEqual(collection.read_json(self.state / 'state.json')['machines'], [])

  def test_list_is_read_only_and_not_due_refresh_keeps_panel_snapshot_unchanged(self):
    self.assertEqual(json.loads(self.cli('list', '--json').stdout), [])
    for directory in (self.config, self.state, self.cache):
      self.assertFalse((directory / 'omarchy').exists(), 'empty list created runtime state')
    self.write('.codex/sessions/test.jsonl', native(100))
    self.cli('add', 'quiet-box')
    self.cli('refresh', '--force')
    state = self.state / 'omarchy/agents/remote/state.json'
    original = state.read_bytes()
    before = state.stat()
    calls = (self.root / 'ssh-calls').read_bytes()
    self.cli('list', '--json')
    self.cli('list')
    self.cli('refresh')
    self.assertEqual(state.read_bytes(), original)
    self.assertEqual((state.stat().st_ino, state.stat().st_mtime_ns), (before.st_ino, before.st_mtime_ns))
    self.assertEqual((self.root / 'ssh-calls').read_bytes(), calls)

  def test_sftp_read_rejects_links_even_if_a_path_changes_after_inventory(self):
    source = self.write('.codex/sessions/test.jsonl', native(100))
    with self.connection() as remote:
      # The actual SFTP listing saw a regular file before its replacement.
      self.assertTrue(any(path == str(source) for path, _ in
                          remote.walk(str(source.parent), self.fail, base=str(self.source))))
      source.unlink()
      target = self.write('outside/test.jsonl', native(99999))
      source.symlink_to(target)
      with self.assertRaisesRegex(OSError, 'symlink'):
        remote.read(str(source))
      source.unlink()
      source.parent.rmdir()
      source.parent.symlink_to(target.parent, target_is_directory=True)
      with self.assertRaisesRegex(OSError, 'symlink'):
        remote.read(str(source))
      self.assertEqual(remote.transferred, 0)

  def test_invalid_native_record_shapes_do_not_replace_last_successful_files(self):
    codex = self.write('.codex/sessions/test.jsonl', native(100))
    claude = self.write('.claude/projects/project/test.jsonl', native_claude(100))
    self.cli('add', 'shape-box')
    self.cli('refresh', '--force')
    state = self.state / 'omarchy/agents/remote/state.json'
    for payload in ([], {'type': 'token_count', 'info': []},
                    {'type': 'token_count', 'info': {'last_token_usage': []}}):
      with self.subTest(payload=payload):
        codex.write_text(json.dumps({'type': 'event_msg', 'payload': payload}) + '\n')
        claude.write_text(''.join(json.dumps(row) + '\n' for row in native_claude(200)))
        self.cli('refresh', '--force')
        row = collection.read_json(state)['machines'][0]
        self.assertEqual(row['status'], 'incomplete')
        self.assertEqual(row['providers']['codex']['todayTotalTokens'], 100)
        self.assertEqual(row['providers']['claude']['todayTotalTokens'], 220)
    codex.write_text(''.join(json.dumps(row) + '\n' for row in native(175)))
    for message in ([], {'role': 'assistant', 'usage': []}):
      with self.subTest(message=message):
        claude.write_text(json.dumps({'type': 'assistant', 'message': message}) + '\n')
        self.cli('refresh', '--force')
        row = collection.read_json(state)['machines'][0]
        self.assertEqual(row['status'], 'incomplete')
        self.assertEqual(row['providers']['codex']['todayTotalTokens'], 175)
        self.assertEqual(row['providers']['claude']['todayTotalTokens'], 220)
    claude.write_text(''.join(json.dumps(row) + '\n' for row in native_claude(300)))
    self.cli('refresh', '--force')
    row = collection.read_json(state)['machines'][0]
    self.assertEqual(row['status'], 'current')
    self.assertEqual(row['providers']['codex']['todayTotalTokens'], 175)
    self.assertEqual(row['providers']['claude']['todayTotalTokens'], 320)

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
    for provider in providers:
      self.assertEqual({key: value for key, value in warm[provider].items() if key != 'remoteSources'},
                       {key: value for key, value in providers[provider].items() if key != 'remoteSources'})
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

  def test_optional_opencode_eacces_keeps_fresh_native_contributions(self):
    if os.geteuid() == 0:
      self.skipTest('Real EACCES requires an unprivileged SFTP server')
    codex = self.write('.codex/sessions/test.jsonl', native(100))
    claude = self.write('.claude/projects/project/test.jsonl', native_claude(100))
    database = self.source / '.local/share/opencode/opencode.db'
    database.parent.mkdir(parents=True)
    database.write_text('Optional source must not gate native usage')
    self.cli('add', 'workbox')
    database.parent.chmod(0)
    try:
      # Verify the fixture actually denies traversal; no mocked SFTP error.
      with self.assertRaises(PermissionError) as denied:
        database.stat()
      self.assertEqual(denied.exception.errno, errno.EACCES)
      self.cli('refresh', '--force')
      row = collection.read_json(self.state / 'omarchy/agents/remote/state.json')['machines'][0]
      self.assertEqual(row['status'], 'incomplete')
      self.assertGreater(row['lastSuccess'], 0)
      self.assertEqual(row['providers']['codex']['todayTotalTokens'], 100)
      self.assertEqual(row['providers']['claude']['todayTotalTokens'], 120)
      self.assertTrue(any('OpenCode' in issue and 'check' in issue for issue in row['issues']))
      with codex.open('a') as stream:
        stream.write(json.dumps(native(175)[-1]) + '\n')
      self.write('.claude/projects/project/test.jsonl', native_claude(200))
      os.utime(claude, None)
      self.cli('refresh', '--force')
      fresh = collection.read_json(self.state / 'omarchy/agents/remote/state.json')['machines'][0]
      self.assertEqual(fresh['status'], 'incomplete')
      self.assertGreater(fresh['lastSuccess'], row['lastSuccess'])
      self.assertEqual(fresh['providers']['codex']['todayTotalTokens'], 175)
      self.assertEqual(fresh['providers']['claude']['todayTotalTokens'], 220)
    finally:
      database.parent.chmod(0o700)
    database.unlink()
    self.cli('refresh', '--force')
    recovered = collection.read_json(self.state / 'omarchy/agents/remote/state.json')['machines'][0]
    self.assertEqual(recovered['status'], 'current')
    self.assertEqual(recovered['issues'], [])
    for provider, expected in (('codex', 175), ('claude', 220)):
      self.assertEqual(recovered['providers'][provider]['todayTotalTokens'], expected)
      self.assertEqual(recovered['providers'][provider]['dailyUsage'], fresh['providers'][provider]['dailyUsage'])

  def test_native_claude_all_and_single_without_opencode_or_sqlite_command(self):
    # The same CLI, native collectors and presentation used by the panel run
    # with only Python, Node and the existing SSH fixture available in PATH.
    for command in ('python3', 'node'):
      (self.fake_bin / command).symlink_to(shutil.which(command))
    remote_file = self.write('.claude/projects/project/test.jsonl', native_claude(100))
    local_root = self.root / 'local-sources'
    local_file = local_root / '.claude/projects/project/test.jsonl'
    local_file.parent.mkdir(parents=True)
    local_entries = native_claude(40)
    local_entries[0]['sessionId'] = 'local-native'
    local_file.write_text(''.join(json.dumps(entry) + '\n' for entry in local_entries))
    original = remote_file.read_bytes()
    with patch.dict(os.environ, PATH=str(self.fake_bin)):
      self.assertIsNone(shutil.which('opencode'))
      self.assertIsNone(shutil.which('sqlite3'))
      self.assertFalse((self.source / '.local/share/opencode').exists())
      added = json.loads(self.cli('add', 'claude-box', '--label', 'Native Claude').stdout)
      self.assertEqual(len(json.loads(self.cli('list', '--json').stdout)), 1)
      self.cli('refresh', '--force')
      snapshot = collection.read_json(self.state / 'omarchy/agents/remote/state.json')
      row = snapshot['machines'][0]
      self.assertEqual(row['status'], 'current')
      self.assertEqual(row['issues'], [])
      self.assertEqual(row['providers']['claude']['todayTotalTokens'], 120)
      self.assertTrue(row['providers']['claude']['dailyUsage']['complete'])
      local_env = dict(os.environ, OMARCHY_AGENT_SOURCE_ROOT=str(local_root),
                       CLAUDE_CONFIG_DIR=str(local_root / '.claude'),
                       XDG_DATA_HOME=str(local_root / '.local/share'),
                       XDG_CACHE_HOME=str(self.root / 'local-cache'))
      local = subprocess.run([str(ROOT / 'bin/omarchy-agent-usage-claude'), '--force', '--stats-only'],
                             env=local_env, capture_output=True, text=True, check=True)
      script = """
const remote = require(process.argv[1]);
const prices = require(process.argv[2]);
const machines = JSON.parse(process.argv[3]);
const local = {...JSON.parse(process.argv[4]), providerId:'claude', providerName:'Claude', costScopeCompatible:true};
const scopes = remote.scopes([local], machines, Date.now());
const all = scopes.all.find(p => p.providerId === 'claude');
const single = scopes[machines[0].id].find(p => p.providerId === 'claude');
function cost(view) {
  return prices.buildModelWindowPresentation('claude', view.dailyUsage, Date.now(), prices.parseOverrides(''), true).summaries[0].cost.total;
}
console.log(JSON.stringify([all.todayTotalTokens, single.todayTotalTokens,
  scopes.local[0].todayTotalTokens, cost(all), cost(single)]));
"""
      shown = subprocess.run(['node', '-e', script, str(ROOT / 'shell/plugins/agents/RemoteUsage.js'),
                              str(ROOT / 'shell/plugins/agents/ApiCost.js'), json.dumps(snapshot['machines']), local.stdout],
                             capture_output=True, text=True, check=True)
      values = json.loads(shown.stdout)
      self.assertEqual(values[:3], [180, 120, 60])
      # Existing Sonnet 5 rate: input $2/M, output $10/M. No cache tokens.
      self.assertAlmostEqual(values[3], 0.00068)
      self.assertAlmostEqual(values[4], 0.00040)
      self.cli('remove', added['id'])
      self.assertEqual(json.loads(self.cli('list', '--json').stdout), [])
    self.assertEqual(remote_file.read_bytes(), original)
    self.assertEqual([str(p.relative_to(self.source)) for p in self.source.rglob('*') if p.is_file()],
                     ['.claude/projects/project/test.jsonl'])

  @unittest.skipUnless(Path('/etc/machine-id').is_file(), 'local Linux machine-id unavailable')
  def test_cli_rejects_local_account_before_saving(self):
    with patch.dict(os.environ, REMOTE_UID=str(os.getuid()),
                    REMOTE_MACHINE=Path('/etc/machine-id').read_text().strip()):
      self.assertIn('This computer', self.cli('add', 'local-alias', success=False).stderr)
    self.assertEqual(json.loads(self.cli('list', '--json').stdout), [])

  def test_cli_rejects_invalid_identity_before_saving(self):
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
  unittest.main(verbosity=2)
