#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

unset PI_CODING_AGENT_DIR PI_CODING_AGENT_SESSION_DIR PI_CONFIG_DIR

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.pi/agent/sessions/project" "$TEST_HOME/.omp/agent/sessions/project"

timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cat >"$TEST_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"pi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"anthropic","api":"anthropic-messages","model":"claude-pi","usage":{"input":10,"output":4,"cacheRead":3,"cacheWrite":2,"totalTokens":19}}}
{"type":"message","id":"codex-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","model":"gpt-test","usage":{"input":999,"output":999}}}
{"type":"message","id":"kimi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"kimi-coding","api":"anthropic-messages","model":"k3","usage":{"input":999,"output":999}}}
EOF
cat >"$TEST_HOME/.omp/agent/sessions/project/omp.jsonl" <<EOF
{ "type": "message", "id": "omp-1", "timestamp": "$timestamp", "message": { "role": "assistant", "provider": "anthropic", "model": "claude-omp", "usage": { "input": 20, "output": 5, "cacheRead": 4, "cacheWrite": 1, "totalTokens": 30 } } }
EOF

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_DATA_HOME="$TEST_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-pi" --force)

[[ $(jq -r '.id' <<<"$result") == "pi" ]] ||
  fail "Pi collector identifies itself" "$result"
pass "Pi collector identifies itself"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "4045" ]] ||
  fail "Pi collector counts usage from every configured backend" "$result"
pass "Pi collector counts usage from every configured backend"

[[ $(jq -c '.todayTokensByModel' <<<"$result") == '{"claude-omp":30,"claude-pi":19,"gpt-test":1998,"k3":1998}' ]] ||
  fail "Pi collector keeps today tokens per model" "$result"
pass "Pi collector keeps today tokens per model"

[[ $(jq -c '.modelUsage' <<<"$result") == '{"claude-omp":{"cacheCreationInputTokens":1,"cacheReadInputTokens":4,"inputTokens":20,"outputTokens":5},"claude-pi":{"cacheCreationInputTokens":2,"cacheReadInputTokens":3,"inputTokens":10,"outputTokens":4},"gpt-test":{"cacheCreationInputTokens":0,"cacheReadInputTokens":0,"inputTokens":999,"outputTokens":999},"k3":{"cacheCreationInputTokens":0,"cacheReadInputTokens":0,"inputTokens":999,"outputTokens":999}}' ]] ||
  fail "Pi collector aggregates tokens by model for all providers" "$result"
pass "Pi collector aggregates tokens by model for all providers"

python3 - "$ROOT/bin/omarchy-agent-usage-pi" <<'PY'
import copy
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import Mock, patch

collector = Path(sys.argv.pop())
source = collector.read_text()


class PiScannerTests(unittest.TestCase):
  def setUp(self):
    self.directory = tempfile.TemporaryDirectory()
    self.addCleanup(self.directory.cleanup)
    self.home = Path(self.directory.name)
    self.env = dict(os.environ, HOME=str(self.home), XDG_CACHE_HOME=str(self.home / '.cache'),
                    XDG_DATA_HOME=str(self.home / '.data'), TZ='UTC')
    for key in ('PI_CODING_AGENT_DIR', 'PI_CODING_AGENT_SESSION_DIR', 'PI_CONFIG_DIR'):
      self.env.pop(key, None)
    self.path = self.home / '.pi/agent/sessions/project/parent.jsonl'
    self.cache = self.home / '.cache/omarchy/agent-usage/pi-sessions.json'
    self.timestamp = dt.datetime.now(dt.timezone.utc).isoformat()

  def message(self, id='abcd1234', tokens=19, timestamp=None):
    return {'type': 'message', 'id': id, 'parentId': None, 'timestamp': timestamp or self.timestamp,
            'message': {'role': 'assistant', 'api': 'openai-completions', 'provider': 'openrouter',
                        'model': 'test', 'timestamp': int(time.time() * 1000), 'stopReason': 'stop',
                        'content': [{'type': 'text', 'text': id}],
                        'usage': {'input': tokens, 'output': 0, 'cacheRead': 0, 'cacheWrite': 0,
                                  'totalTokens': tokens, 'cost': {'input': .01, 'output': 0,
                                  'cacheRead': 0, 'cacheWrite': 0, 'total': .01}}}}

  def put(self, path, entries):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(''.join((e if isinstance(e, str) else json.dumps(e)) + '\n' for e in entries))

  def run_collector(self, *args):
    result = subprocess.run([sys.executable, str(collector), *args], env=self.env, capture_output=True, text=True)
    self.assertEqual(result.returncode, 0, result.stderr)
    record = json.loads(result.stdout)
    self.assertEqual(record['id'], 'pi')
    self.assertEqual(record['schemaVersion'], 1)
    return record

  def header(self, id, parent=None):
    header = {'type': 'session', 'version': 3, 'id': id, 'timestamp': self.timestamp, 'cwd': '/project'}
    if parent is not None:
      header['parentSession'] = str(parent)
    return header

  def test_empty_force_replaces_nonempty_cache(self):
    self.put(self.path, [self.message()])
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 19)
    self.path.unlink()
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 0)
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 0)
    self.assertEqual(json.loads(self.cache.read_text())['stats']['totalPrompts'], 0)

  def test_failed_cache_write_invalidates_previous_usage(self):
    self.put(self.path, [self.message()])
    self.run_collector('--force')
    self.path.unlink()
    namespace = {'__name__': 'test_collector'}
    exec(compile(source, str(collector), 'exec'), namespace)
    with patch.dict(os.environ, self.env), patch.dict(namespace, write_json=Mock(side_effect=OSError('disk full'))):
      self.assertEqual(namespace['cached_scan'](0)['todayTotalTokens'], 0)
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 0)

  def test_failed_cache_invalidation_is_best_effort(self):
    self.put(self.path, [self.message()])
    self.run_collector('--force')
    self.path.unlink()
    namespace = {'__name__': 'test_collector'}
    exec(compile(source, str(collector), 'exec'), namespace)
    with patch.dict(os.environ, self.env), patch.dict(namespace, write_json=Mock(side_effect=OSError('read only'))), \
         patch.object(Path, 'unlink', side_effect=PermissionError('read only')):
      self.assertEqual(namespace['cached_scan'](0)['todayTotalTokens'], 0)

  def test_cache_reuse_force_and_expiry(self):
    self.put(self.path, [self.message()])
    self.run_collector('--force')
    self.put(self.path, [self.message(tokens=33)])
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 19)
    self.assertEqual(self.run_collector('--force', '--limits-only')['todayTotalTokens'], 33)
    self.put(self.path, [self.message(tokens=45)])
    os.utime(self.cache, (time.time() - 1000,) * 2)
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 45)

  def test_cache_envelope_and_shapes(self):
    self.put(self.path, [self.message()])
    self.run_collector('--force')
    envelope = json.loads(self.cache.read_text())
    self.assertEqual(envelope.get('schemaVersion'), 1)
    self.assertEqual(envelope.get('scanDate'), self.timestamp[:10])
    self.assertEqual(self.cache.stat().st_mode & 0o777, 0o644)
    for bad in ([], {'stats': {}}, dict(envelope, stats=[]), dict(envelope, stats={}),
                dict(envelope, stats=dict(envelope['stats'], recentDays='wrong')),
                dict(envelope, stats=dict(envelope['stats'], modelUsage={'test': []}))):
      with self.subTest(cache=bad):
        self.cache.write_text(json.dumps(bad))
        self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 19)
    self.cache.write_text('{')
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 19)

  def test_other_date_and_future_mtime_are_cache_misses(self):
    self.put(self.path, [self.message()])
    self.run_collector('--force')
    cached = json.loads(self.cache.read_text())
    cached['scanDate'] = '2000-01-01'
    self.cache.write_text(json.dumps(cached))
    self.put(self.path, [self.message(tokens=33)])
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 33)
    os.utime(self.cache, (time.time() + 3600,) * 2)
    self.put(self.path, [self.message(tokens=45)])
    self.assertEqual(self.run_collector()['todayTotalTokens'], 45)

  def test_cache_unavailable_still_emits_record(self):
    self.put(self.path, [self.message()])
    blocked = self.home / 'blocked'
    blocked.write_text('not a directory')
    self.env['XDG_CACHE_HOME'] = str(blocked)
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 19)

  def test_bad_rows_do_not_abort_or_hide_valid_rows(self):
    self.put(self.path, [self.message(), '["usage", "assistant"]', '{"usage":',
                        {'type': 'message', 'message': ['assistant', 'usage']},
                        {'type': 'message', 'message': {'role': 'assistant', 'usage': []}},
                        self.message('second', 7)])
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 26)

  def test_fork_lineage_and_short_id_collisions(self):
    inherited = self.message()
    child = self.path.parent / 'a-child.jsonl'
    sibling = self.path.parent / 'b-sibling.jsonl'
    unrelated = self.path.parent / 'unrelated.jsonl'
    self.put(self.path, [self.header('parent-session'), inherited, inherited])
    self.put(child, [self.header('child-session', self.path), inherited, self.message('child-new', 7)])
    collision = self.message(tokens=5)
    collision['message']['content'] = [{'type': 'text', 'text': 'independent response with colliding short id'}]
    self.put(sibling, [self.header('sibling-session', 'parent-session'), inherited, collision])
    self.put(unrelated, [self.header('unrelated-session'), inherited])
    record = self.run_collector('--force')
    self.assertEqual(record['todayTotalTokens'], 50)
    self.assertEqual(record['totalPrompts'], 4)
    self.assertEqual(record['totalSessions'], 4)
    self.put(child, [self.header('child-session', self.path), inherited])
    sibling.unlink()
    unrelated.unlink()
    self.assertEqual(self.run_collector('--force')['totalSessions'], 1)
    self.path.unlink()
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 19)

  def test_cost_reset_forks_keep_stable_response_identity(self):
    original = self.message()
    original['message']['usage'].update(credits=2, premiumRequests=1)
    inherited = copy.deepcopy(original)
    inherited['message']['usage']['cost'] = dict.fromkeys(original['message']['usage']['cost'], 0)
    del inherited['message']['usage']['credits']
    del inherited['message']['usage']['premiumRequests']
    child = self.path.parent / 'child.jsonl'
    self.put(self.path, [self.header('parent-session'), original])
    self.put(child, [self.header('child-session', self.path), inherited])
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 19)
    for key, value in (('provider', 'another-provider'), ('model', 'another-model'),
                       ('timestamp', original['message']['timestamp'] + 1),
                       ('content', [{'type': 'text', 'text': 'different response'}]),
                       ('usage', dict(original['message']['usage'], input=7, totalTokens=7))):
      with self.subTest(field=key):
        collision = copy.deepcopy(original)
        collision['message'][key] = value
        self.put(child, [self.header('child-session', self.path), inherited, collision])
        expected = 26 if key == 'usage' else 38
        self.assertEqual(self.run_collector('--force')['todayTotalTokens'], expected)
    collision = copy.deepcopy(original)
    collision['timestamp'] = (dt.datetime.fromisoformat(self.timestamp) - dt.timedelta(seconds=1)).isoformat()
    self.put(child, [self.header('child-session', self.path), inherited, collision])
    self.assertEqual(self.run_collector('--force')['totalPrompts'], 2)

  def test_missing_uuid_parent_keeps_sibling_forks_linked(self):
    parent_id = '01995131-8e80-7000-8000-000000000001'
    inherited = self.message()
    sibling = self.path.parent / 'sibling.jsonl'
    self.put(self.path, [self.header('child-session', parent_id), inherited])
    self.put(sibling, [self.header('sibling-session', parent_id), inherited, self.message('new', 7)])
    record = self.run_collector('--force')
    self.assertEqual(record['todayTotalTokens'], 26)
    self.assertEqual(record['totalPrompts'], 2)

  def test_ambiguous_and_non_uuid_parent_ids_remain_independent(self):
    inherited = self.message()
    sibling = self.path.parent / 'sibling.jsonl'
    parent_id = '01995131-8e80-7000-8000-000000000001'
    for parent in ('abcd1234', '{' + parent_id + '}', parent_id):
      with self.subTest(parent=parent):
        if parent == parent_id:
          for name in ('original-a', 'original-b'):
            self.put(self.path.parent / (name + '.jsonl'), [self.header(parent)])
        self.put(self.path, [self.header('child-session', parent), inherited])
        self.put(sibling, [self.header('sibling-session', parent), inherited])
        self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 38)

  def test_malformed_parent_paths_do_not_hide_usage(self):
    self.put(self.path.parent / 'later.jsonl', [self.message('later', 7)])
    loop = self.path.parent / 'loop'
    loop.symlink_to(loop)
    for parent in ('bad\x00.jsonl', '/bad\x00/parent', str(loop)):
      with self.subTest(parent=parent):
        self.put(self.path, [self.header('session', parent), self.message()])
        self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 26)

  def test_physical_aliases_count_once(self):
    self.put(self.path, [self.message()])
    alias = self.home / '.omp/agent/sessions'
    alias.parent.mkdir(parents=True)
    alias.symlink_to(self.home / '.pi/agent/sessions', target_is_directory=True)
    os.link(self.path, self.path.parent / 'hardlink.jsonl')
    self.env['PI_CODING_AGENT_DIR'] = str(self.home / '.pi/agent')
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 19)

  def test_configured_roots_profiles_and_cache_identity(self):
    configured = self.home / 'configured agent'
    self.env['PI_CODING_AGENT_DIR'] = str(configured)
    self.put(configured / 'sessions/project/custom.jsonl', [self.message('custom', 11)])
    self.put(self.home / '.omp/profiles/work/agent/sessions/project/profile.jsonl', [self.message('profile', 7)])
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 18)
    self.env['PI_CODING_AGENT_DIR'] = str(self.home / 'other agent')
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 7)
    self.put(self.home / '.omp/profiles/new/agent/sessions/project/new.jsonl', [self.message('new', 3)])
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 10)

  def test_explicit_session_directory_and_cache_identity(self):
    self.put(self.path, [self.message()])
    self.put(self.home / 'custom sessions/project/a.jsonl', [self.message('custom', 11)])
    self.env['PI_CODING_AGENT_SESSION_DIR'] = '~/custom sessions'
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 30)
    other = self.home / 'other sessions'
    self.put(other / 'project/b.jsonl', [self.message('other', 7)])
    self.env['PI_CODING_AGENT_SESSION_DIR'] = str(other)
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 26)
    self.env['PI_CODING_AGENT_SESSION_DIR'] = str(self.home / '.pi/agent/sessions')
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 19)

  def test_omp_xdg_and_custom_config_roots(self):
    self.env['PI_CONFIG_DIR'] = '.custom-omp'
    self.put(self.home / '.custom-omp/agent/sessions/project/a.jsonl', [self.message('custom', 11)])
    self.put(self.home / '.data/omp/sessions/project/b.jsonl', [self.message('xdg', 7)])
    self.put(self.home / '.data/omp/profiles/work/sessions/project/c.jsonl', [self.message('profile', 3)])
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 21)

  def test_invalid_counters_are_not_replaced_by_total_tokens(self):
    rows = [self.message()]
    for index, value in enumerate((-1, float('nan'), float('inf'), True, 'bad', {}, 1.5)):
      bad = self.message(str(index))
      bad['message']['usage']['input'] = value
      rows.append(bad)
    self.put(self.path, rows)
    self.assertEqual(self.run_collector('--force')['todayTotalTokens'], 19)

  def test_token_categories_are_exclusive_and_per_response(self):
    row = self.message()
    row['message']['usage'] = {'input': 10, 'output': 4, 'cacheRead': 3, 'cacheWrite': 2,
                               'reasoning': 2, 'cacheWrite1h': 1, 'totalTokens': 19, 'cost': {'total': 99}}
    fallback = self.message('fallback')
    fallback['message']['usage'] = {'totalTokens': 5}
    self.put(self.path, [row, fallback, self.message('next', 2)])
    record = self.run_collector('--force')
    self.assertEqual(record['todayTotalTokens'], 26)
    self.assertEqual(sum(record['modelUsage']['test'].values()), 26)
    self.assertNotIn('cost', record)

  def test_invalid_dates_do_not_become_today(self):
    rows = [self.message()]
    for index, timestamp in enumerate((None, '', 'invalid', True, [], -1, float('nan'))):
      bad = self.message(str(index))
      bad['timestamp'] = timestamp
      bad['message']['timestamp'] = timestamp
      rows.append(bad)
    old = self.message('old', 7)
    old['timestamp'] = 'invalid'
    old['message']['timestamp'] = 1577836800000
    future = self.message('future', 9, '2999-01-01T00:00:00Z')
    self.put(self.path, [*rows, old, future])
    record = self.run_collector('--force')
    self.assertEqual(record['todayTotalTokens'], 19)
    self.assertEqual(record['activeDates'], ['2020-01-01', self.timestamp[:10]])
    self.assertEqual(record['modelUsage']['test']['inputTokens'], 26)

  def test_local_calendar_and_timestamp_units(self):
    namespace = {'__name__': 'test_collector'}
    exec(compile(source, str(collector), 'exec'), namespace)
    with patch.dict(os.environ, TZ='America/Los_Angeles'):
      time.tzset()
      try:
        instant = dt.datetime(2026, 9, 5, 1, tzinfo=dt.timezone.utc).timestamp()
        for timestamp in ('2026-09-05T01:00:00Z', '2026-09-05T03:00:00+02:00', instant, instant * 1000):
          self.assertEqual(namespace['local_date_from_timestamp'](timestamp), '2026-09-04')
      finally:
        time.tzset()
    time.tzset()
    today = dt.datetime.now(dt.timezone.utc).date()
    rows = [self.message(str(offset), 1, (today - dt.timedelta(days=offset)).isoformat() + 'T12:00:00Z')
            for offset in range(9)]
    self.put(self.path, rows)
    record = self.run_collector('--force')
    self.assertEqual(len(record['recentDays']), 7)
    self.assertEqual(sum(day['messageCount'] for day in record['recentDays']), 7)
    self.assertEqual(record['modelUsage']['test']['inputTokens'], 9)

  def test_local_only_record_is_not_a_subscription(self):
    self.put(self.path, [self.message()])
    record = self.run_collector('--force')
    self.assertEqual(record.get('tierLabel'), 'Local usage')
    self.assertEqual(record.get('usageStatusText', ''), '')
    self.assertEqual(record.get('limits', []), [])

  def test_codex_cache_from_before_pi_split_is_ignored(self):
    namespace = {'__name__': 'test_codex'}
    codex_source = collector.with_name('omarchy-agent-usage-codex').read_text()
    with patch.dict(os.environ, dict(self.env, CODEX_HOME=str(self.home / '.codex'))):
      exec(compile(codex_source, 'omarchy-agent-usage-codex', 'exec'), namespace)
      stats = namespace['local_stats']()
      stats['todayTotalTokens'] = 99
      stats['totalPrompts'] = 1
      db = self.home / '.data/opencode/opencode.db'
      identity = str(self.home) + '\n' + str(self.home / '.codex') + '\n' + str(db)
      old_cache = self.cache.parent / ('codex-scan-' + hashlib.sha1(identity.encode()).hexdigest()[:16] + '.json')
      old_cache.parent.mkdir(parents=True, exist_ok=True)
      old_cache.write_text(json.dumps({'schemaVersion': 1, 'scanDate': namespace['today'], 'stats': stats}))
      self.assertEqual(namespace['cached_local_stats'](900)['todayTotalTokens'], 0)

  def test_unreadable_file_does_not_hide_later_files_or_get_cached(self):
    self.put(self.path, [self.message()])
    unreadable = self.path.parent / 'a-unreadable.jsonl'
    self.put(unreadable, [self.message('unreadable', 7)])
    namespace = {'__name__': 'test_collector'}
    exec(compile(source, str(collector), 'exec'), namespace)
    original_open = Path.open
    def open_file(path, *args, **kwargs):
      if path == unreadable:
        raise PermissionError('fixture permission denied')
      return original_open(path, *args, **kwargs)
    with patch.dict(os.environ, self.env), patch.object(Path, 'open', open_file):
      stats = namespace['cached_scan'](0)
    self.assertEqual(stats['todayTotalTokens'], 19)
    self.assertFalse(self.cache.exists())
    self.assertEqual(self.run_collector('--limits-only')['todayTotalTokens'], 26)

  def test_midnight_changes_today_even_with_fresh_cache(self):
    namespace = {'__name__': 'test_collector'}
    exec(compile(source, str(collector), 'exec'), namespace)
    real_datetime = dt.datetime
    class Clock(real_datetime):
      current = real_datetime(2026, 9, 5, 23, 59, 59, tzinfo=dt.timezone.utc)
      @classmethod
      def now(cls, tz=None):
        return cls.current.astimezone(tz) if tz else cls.current.replace(tzinfo=None)
    self.put(self.path, [self.message(timestamp='2026-09-05T12:00:00Z')])
    with patch.dict(os.environ, self.env), patch.object(dt, 'datetime', Clock):
      self.assertEqual(namespace['cached_scan'](0)['todayTotalTokens'], 19)
      Clock.current = real_datetime(2026, 9, 6, 0, 0, 1, tzinfo=dt.timezone.utc)
      self.assertEqual(namespace['cached_scan'](900)['todayTotalTokens'], 0)


unittest.main(verbosity=2)
PY
