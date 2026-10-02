#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 - <<'PY'
import fcntl
import importlib.machinery
import importlib.util
import json
import os
import sqlite3
import subprocess
import tempfile
import time
import unittest
from datetime import datetime, timezone
from pathlib import Path
from unittest.mock import patch

root = Path(os.environ['ROOT'])
script = root / 'bin/omarchy-agent-usage-antigravity'
loader = importlib.machinery.SourceFileLoader('collector', str(script))
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

class Scanner(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.home = Path(self.tmp.name)
    self.app = self.home / 'app'
    self.app.mkdir()
    self.bin = self.home / 'bin'
    self.bin.mkdir()
    self.log = self.home / 'calls'
    self.cli = self.bin / 'agy'
    self.cli.write_text('''#!/usr/bin/python3
import json, os, sys, time
from pathlib import Path
with open(os.environ['AGY_TEST_LOG'], 'a') as f:
  f.write(json.dumps(sys.argv[1:]) + '\\n')
if sys.argv[1:] == ['--version']:
  print(os.environ.get('AGY_TEST_VERSION', '1.2.14'))
  sys.exit(0)
assert sys.argv[1:] == ['-p', '/usage', '--output-format', 'json']
if os.environ.get('AGY_TEST_STARTED'):
  Path(os.environ['AGY_TEST_STARTED']).touch()
  time.sleep(2)
error = os.environ.get('AGY_TEST_ERROR')
if error:
  print(error, file=sys.stderr)
  sys.exit(1)
print(Path(os.environ['AGY_TEST_FIXTURE']).read_text())
''')
    self.cli.chmod(0o755)
    self.env = {'HOME': str(self.home), 'PATH': str(self.bin) + ':/usr/bin', 'TZ': 'Etc/GMT-14',
                'AGY_DIR': str(self.app), 'XDG_CACHE_HOME': str(self.home / 'cache'),
                'AGY_TEST_LOG': str(self.log), 'AGY_TEST_FIXTURE': str(root / 'test/shell.d/fixtures/antigravity/usage.json')}

  def run_collector(self, *args, **extra):
    result = subprocess.run([str(script), *args], env={**self.env, **extra}, text=True, capture_output=True, check=True)
    self.assertEqual(result.stderr, '')
    return json.loads(result.stdout)

  def transcript(self, name, entries):
    path = self.app / 'brain' / name / '.system_generated/logs/transcript.jsonl'
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text('\n'.join(json.dumps(e) for e in entries) + '\n{partial')

  def test_local_dates_real_shapes_and_no_invented_tokens(self):
    now = datetime(2026, 9, 28, 1, tzinfo=timezone.utc)
    prompt = {'step_index': 0, 'source': 'USER', 'type': 'USER_INPUT', 'status': 'DONE',
              'created_at': '2026-09-27T23:00:00Z', 'content': 'Hello'}
    self.transcript('session', [prompt, prompt,
      {'step_index': 1, 'source': 'MODEL', 'type': 'PLANNER_RESPONSE', 'created_at': '2026-09-27T23:01:00Z', 'content': 'Answer', 'thinking': 'Thinking'},
      {'step_index': 2, 'source': 'USER', 'type': 'USER_INPUT', 'content': 'Missing date'},
      {'step_index': 3, 'type': 'USER_INPUT', 'created_at': '2099-01-01T00:00:00Z'},
      {'step_index': 4, 'created_at': [], 'type': 'USER_INPUT'}])
    history = [
      {'display': 'Hello', 'timestamp': 1759014000000, 'workspace': '/project'},
      {'display': 'Hello', 'timestamp': '2026-09-27T23:00:00Z', 'workspace': '/project'},
      {'display': '/usage', 'timestamp': '2026-09-27T23:00:00Z'},
      {'display': 'old', 'timestamp': '2026-09-27T01:00:00Z'},
      {'timestamp': []}, {'timestamp': 10**30}, []]
    # The first record exercises epoch milliseconds for the same instant.
    history[0]['timestamp'] = int(datetime(2026, 9, 27, 23, tzinfo=timezone.utc).timestamp() * 1000)
    (self.app / 'history.jsonl').write_text('\n'.join(json.dumps(e) for e in history))
    with sqlite3.connect(self.app / 'conversation_summaries.db') as db:
      db.execute('CREATE TABLE conversation_summaries (conversation_id TEXT, last_modified_time TEXT)')
      db.executemany('INSERT INTO conversation_summaries VALUES (?, ?)', [('session', '2026-09-27 23:02:00+00:00'), ('summary-only', '2026-09-27 23:03:00+00:00')])
    with patch.dict(os.environ, {'TZ': 'Etc/GMT-14'}):
      time.tzset()
      stats = collector.collect_local_stats(self.app, now)
    time.tzset()
    self.assertEqual(stats['todayPrompts'], 2)
    self.assertEqual(stats['totalPrompts'], 3)
    self.assertEqual(stats['todaySessions'], 2)
    self.assertEqual(stats['totalSessions'], 2)
    self.assertEqual(stats['activeDates'], ['2026-09-27', '2026-09-28'])
    self.assertEqual(stats['recentDays'][-1], {'date': '2026-09-28', 'messageCount': 0})
    self.assertEqual(stats['todayTotalTokens'], 0)
    self.assertEqual(stats['modelUsage'], {})
    self.assertEqual(stats['todayTokensByModel'], {})

  def test_negative_timezone(self):
    self.transcript('session', [{'step_index': 0, 'type': 'USER_INPUT', 'created_at': '2026-09-28T01:00:00Z'}])
    with patch.dict(os.environ, {'TZ': 'America/New_York'}):
      time.tzset()
      stats = collector.collect_local_stats(self.app, datetime(2026, 9, 28, 2, tzinfo=timezone.utc))
    time.tzset()
    self.assertEqual(stats['activeDates'], ['2026-09-27'])
    self.assertEqual(stats['recentDays'][-1]['date'], '2026-09-27')
    self.assertEqual(stats['todayPrompts'], 1)

  def test_executable_record_caches_custom_root_and_tier(self):
    stamp = datetime.now(timezone.utc).isoformat()
    (self.app / 'history.jsonl').write_text(json.dumps({'display': 'hello', 'timestamp': stamp}) + '\n')
    record = self.run_collector('--force')
    self.assertEqual(record['id'], 'antigravity')
    self.assertTrue(record['ready'])
    self.assertTrue(record['hasLocalStats'])
    self.assertEqual(record['tierLabel'], '')
    self.assertEqual(record['usageStatusText'], '')
    self.assertEqual([e['percent'] for e in record['limits']], [0, .27, 0, .03])
    self.assertEqual(record['todayPrompts'], 1)
    self.assertEqual(record['todayTotalTokens'], 0)
    self.assertEqual(record['modelUsage'], {})
    calls = self.log.read_text()
    (self.app / 'history.jsonl').write_text((json.dumps({'display': 'hello', 'timestamp': stamp}) + '\n') * 3)
    self.assertEqual(self.run_collector('--limits-only')['todayPrompts'], 1)
    self.assertEqual(len(self.log.read_text().splitlines()), len(calls.splitlines()) + 2)
    self.assertEqual(self.run_collector('--force')['todayPrompts'], 3)
    stats_path = next((self.home / 'cache/omarchy/agent-usage').glob('*.stats.json'))
    cached = json.loads(stats_path.read_text())
    cached['stats'] = {}
    stats_path.write_text(json.dumps(cached))
    self.assertEqual(self.run_collector('--limits-only')['todayPrompts'], 3)
    other = self.home / 'other'
    other.mkdir()
    self.assertEqual(self.run_collector(AGY_DIR=str(other))['totalPrompts'], 0)
    self.assertEqual(self.run_collector(AGY_TIER='Ultra')['tierLabel'], 'Ultra')
    config = self.home / 'config/omarchy/agents'
    config.mkdir(parents=True)
    (config / 'antigravity.json').write_text('{"tier":"Enterprise"}')
    self.assertEqual(self.run_collector(XDG_CONFIG_HOME=str(self.home / 'config'))['tierLabel'], 'Enterprise')

  def test_real_command_errors_and_safety_gate(self):
    for error, status, retry in [('401 expired token', 'Antigravity sign-in required', False),
                                 ('403 permission denied', 'Antigravity sign-in required', False),
                                 ('429 rate limit', 'Antigravity limits rate limited', False),
                                 ('network unreachable', 'Antigravity limits unavailable', True),
                                 ('500 server failure', 'Antigravity limits unavailable', False)]:
      record = self.run_collector('--force', AGY_TEST_ERROR=error)
      self.assertEqual(record['limits'], [])
      self.assertEqual(record['tierLabel'], '')
      self.assertEqual(record['usageStatusText'], status)
      self.assertEqual(record['retryAdvised'], retry)
      self.assertTrue(record['authHelpText'])
    self.log.write_text('')
    record = self.run_collector('--force', AGY_TEST_VERSION='1.1.10')
    self.assertEqual(record['usageStatusText'], 'Antigravity update required')
    self.assertEqual(self.log.read_text().splitlines(), ['["--version"]'])
    self.run_collector('--force')
    stale = self.run_collector('--force', AGY_TEST_ERROR='network unavailable')
    self.assertFalse(stale['limitsStale'])
    self.assertEqual(stale['limits'], [])
    self.assertTrue(stale['retryAdvised'])

  def test_partial_and_disjoint_history_preserve_distinct_prompts(self):
    history = [{'display': 'shared', 'timestamp': '2026-09-27T12:00:00Z'},
               {'display': 'history only', 'timestamp': '2026-09-27T12:01:00Z'}]
    (self.app / 'history.jsonl').write_text('\n'.join(json.dumps(e) for e in history))
    for shared, expected in [('shared', 4), ('different prompt', 5)]:
      self.transcript('session', [
        {'step_index': 0, 'type': 'USER_INPUT', 'created_at': '2026-09-27T12:00:00.400Z', 'content': '<USER_REQUEST>\n' + shared + '\n</USER_REQUEST>'},
        {'step_index': 1, 'type': 'USER_INPUT', 'created_at': '2026-09-27T12:02:00Z', 'content': 'transcript only'},
        {'step_index': 2, 'type': 'USER_INPUT', 'created_at': '2026-09-27T12:03:00Z', 'content': 'shared'}])
      with patch.dict(os.environ, {'TZ': 'UTC'}):
        time.tzset()
        stats = collector.collect_local_stats(self.app, datetime(2026, 9, 27, 14, tzinfo=timezone.utc))
      time.tzset()
      self.assertEqual(stats['todayPrompts'], expected)
      self.assertEqual(stats['totalPrompts'], expected)

  def test_account_switch_and_new_sign_in_are_visible_immediately(self):
    first = self.run_collector()
    other = json.loads(Path(self.env['AGY_TEST_FIXTURE']).read_text())
    other['command']['data']['groups'][1]['buckets'][1]['remaining_fraction'] = .2
    other_file = self.home / 'other-account.json'
    other_file.write_text(json.dumps(other))
    second = self.run_collector(AGY_TEST_FIXTURE=str(other_file))
    self.assertEqual(first['limits'][0]['percent'], 0)
    self.assertEqual(second['limits'][0]['percent'], .8)
    self.assertEqual(self.run_collector(AGY_TEST_ERROR='401 signed out')['limits'], [])
    self.assertEqual(self.run_collector()['usageStatusText'], '')
    self.assertFalse(list((self.home / 'cache').rglob('*.limits.json')))

  def test_prompt_matching_ignores_substrings_and_metadata(self):
    (self.app / 'history.jsonl').write_text(json.dumps({'display': 'hello', 'timestamp': '2026-09-27T12:00:00Z'}))
    for content, expected in [
      ('<USER_REQUEST>hello</USER_REQUEST><ADDITIONAL_METADATA>context</ADDITIONAL_METADATA>', 1),
      ('<USER_REQUEST>hello world</USER_REQUEST><ADDITIONAL_METADATA>context</ADDITIONAL_METADATA>', 2),
      ('<USER_REQUEST>different</USER_REQUEST><ADDITIONAL_METADATA>hello</ADDITIONAL_METADATA>', 2)]:
      self.transcript('session', [{'step_index': 0, 'type': 'USER_INPUT', 'created_at': '2026-09-27T12:00:00.400Z', 'content': content}])
      stats = collector.collect_local_stats(self.app, datetime(2026, 9, 27, 14, tzinfo=timezone.utc))
      self.assertEqual(stats['totalPrompts'], expected)

  def test_slow_quota_query_does_not_hold_the_history_lock(self):
    started = self.home / 'quota-started'
    process = subprocess.Popen([str(script)], env={**self.env, 'AGY_TEST_STARTED': str(started)},
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
      deadline = time.monotonic() + 5
      while not started.exists() and process.poll() is None and time.monotonic() < deadline:
        time.sleep(.02)
      self.assertTrue(started.exists(), 'quota query started')
      lock_path = next((self.home / 'cache').rglob('*.lock'))
      with lock_path.open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        fcntl.flock(lock, fcntl.LOCK_UN)
    finally:
      stdout, stderr = process.communicate(timeout=5)
    self.assertEqual(process.returncode, 0, stderr)
    self.assertEqual(json.loads(stdout)['usageStatusText'], '')

  def test_literal_wrapper_tags_in_prompt_count_once(self):
    for text in ['Explain </USER_REQUEST> please', '<USER_REQUEST>nested</USER_REQUEST>',
                 'Document </USER_REQUEST><ADDITIONAL_METADATA> literally']:
      (self.app / 'history.jsonl').write_text(json.dumps({'display': text, 'timestamp': '2026-09-27T12:00:00Z'}))
      wrapped = '<USER_REQUEST>\n' + text + '\n</USER_REQUEST>\n<ADDITIONAL_METADATA>context</ADDITIONAL_METADATA>'
      self.transcript('session', [{'step_index': 0, 'type': 'USER_INPUT', 'created_at': '2026-09-27T12:00:00.400Z', 'content': wrapped}])
      stats = collector.collect_local_stats(self.app, datetime(2026, 9, 27, 14, tzinfo=timezone.utc))
      self.assertEqual(stats['totalPrompts'], 1)

  def test_stock_wrapper_does_not_install(self):
    self.cli.write_text('#!/bin/bash\nmise use -g antigravity-cli\nexit 99\n')
    mise = self.bin / 'mise'
    mise.write_text('#!/bin/bash\n[[ $* == "which agy" ]] || exit 99\nexit 1\n')
    mise.chmod(0o755)
    record = self.run_collector('--force')
    self.assertEqual(record['usageStatusText'], 'Antigravity CLI unavailable')
    self.assertFalse(record['ready'])
    self.assertFalse(self.log.exists())

unittest.main(verbosity=2)
PY
pass "Antigravity real CLI integration, local history, timezones and cache isolation"
