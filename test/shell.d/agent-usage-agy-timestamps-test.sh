#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

python3 - "$ROOT/bin/omarchy-agent-usage-agy" <<'PY'
import contextlib
import io
import json
import os
import runpy
import sqlite3
import subprocess
import sys
import tempfile
import time
import types
import unittest
from datetime import datetime, timezone
from pathlib import Path
from unittest.mock import Mock, patch

collector_path = Path(sys.argv.pop())
collector = types.SimpleNamespace(**runpy.run_path(str(collector_path)))
# Functions loaded by runpy share this namespace, rather than the wrapper.
namespace = collector.local_stats.__globals__
NOW = datetime(2026, 10, 2, 12, tzinfo=timezone.utc)
ZONES = ('UTC0', 'EST5', 'JST-9')  # Fixed offsets; no host zoneinfo or DST rules.
INVALID = (None, '', 'not a date', 0, -1, '0', -1.5, '2026-02-30T12:00:00Z', [], {}, True,
           '0001-01-01 00:00:00+00:00', '0001-01-01T00:00:00Z',
           '0001-01-01T00:00:00', '0001-01-01T01:00:00+01:00',
           10**30, -(10**30), 10**400, '9' * 400, float('inf'), float('nan'))


@contextlib.contextmanager
def local_zone(zone):
  old = os.environ.get('TZ')
  try:
    os.environ['TZ'] = zone
    time.tzset()
    yield
  finally:
    if old is None:
      os.environ.pop('TZ', None)
    else:
      os.environ['TZ'] = old
    time.tzset()


class FrozenDatetime(datetime):
  @classmethod
  def now(cls, tz=None):
    return NOW.astimezone(tz) if tz else NOW.astimezone().replace(tzinfo=None)


def write_fixture(root, invalid):
  history = [dict(timestamp='2026-10-02T02:00:00Z', conversation_id='valid')]
  history += [dict(timestamp=value, conversation_id='bad-history') for value in invalid]
  history += [{}, dict(timestamp='1969-07-20T12:00:00Z', conversation_id='old'),
              dict(timestamp='2026-10-02T12:00:00Z', conversation_id='valid')]
  (root / 'history.jsonl').write_text('\n'.join(map(json.dumps, history)))
  with contextlib.closing(sqlite3.connect(root / 'conversation_summaries.db')) as db, db:
    db.execute('CREATE TABLE conversation_summaries (conversation_id TEXT, last_modified_time TEXT)')
    db.executemany('INSERT INTO conversation_summaries VALUES (?, ?)', [
      ('valid', '2026-10-02T12:00:00Z'), ('undated', '0001-01-01 00:00:00+00:00'),
      ('undated', None), ('undated', 'not a date'),
      ('summary-only', '2026-10-02T12:00:00Z')])
  transcript = root / 'brain/valid/.system_generated/logs/transcript.jsonl'
  transcript.parent.mkdir(parents=True)
  steps = [dict(created_at='2026-10-02T12:00:00Z', model='dated',
                usage=dict(input_tokens=10, output_tokens=5))]
  steps += [dict(created_at=value, model='undated', usage=dict(input_tokens=2, output_tokens=1))
            for value in invalid]
  steps += [dict(model='undated', usage=dict(input_tokens=2, output_tokens=1)),
            dict(created_at='2026-10-02T02:00:00Z', model='dated',
                 usage=dict(input_tokens=7, output_tokens=3))]
  transcript.write_text('\n'.join(map(json.dumps, steps)))


class TimestampTests(unittest.TestCase):
  def test_zero_and_invalid_times_are_undated_in_every_zone(self):
    for zone in ZONES:
      with local_zone(zone):
        for value in INVALID:
          with self.subTest(zone=zone, value=value):
            self.assertEqual(collector.local_day(value), '')
        self.assertIsNone(collector.parse_time('0001-01-01 00:00:00+00:00'))

  def test_valid_times_keep_existing_formats_and_local_dates(self):
    for zone, early_day in zip(ZONES, ('2026-10-02', '2026-10-01', '2026-10-02')):
      with local_zone(zone), self.subTest(zone=zone):
        for value in ('2026-10-02T02:00:00Z', '2026-10-02 02:00:00',
                      '2026-10-02T04:00:00+02:00', 1790906400, 1790906400000,
                      '1790906400000'):
          self.assertEqual(collector.local_day(value), early_day)
        self.assertEqual(collector.local_day('1969-07-20T12:00:00Z'), '1969-07-20')
        self.assertEqual(collector.local_day(1), '1969-12-31' if zone == 'EST5' else '1970-01-01')
        self.assertEqual(collector.local_day('2026-10-02T20:00:00Z'),
                         '2026-10-03' if zone == 'JST-9' else '2026-10-02')

  def test_conversion_boundaries(self):
    cases = (
      ('0001-01-01T00:00:01Z', ('0001-01-01', '', '0001-01-01')),
      ('0001-01-01T12:00:00Z', ('0001-01-01', '0001-01-01', '0001-01-01')),
      ('9999-12-31T23:59:59Z', ('9999-12-31', '9999-12-31', '')),
      ('9999-12-31T12:00:00Z', ('9999-12-31', '9999-12-31', '9999-12-31')),
      ('0001-01-01T00:00:01+14:00', ('', '', '')),
      ('9999-12-31T23:59:59-12:00', ('', '', '')),
    )
    for value, expected in cases:
      for zone, day in zip(ZONES, expected):
        with local_zone(zone), self.subTest(zone=zone, value=value):
          self.assertEqual(collector.local_day(value), day)

  def test_mixed_activity_survives_without_inventing_dates(self):
    for zone in ZONES:
      # These offset timestamps overflow while normalizing to UTC in all zones.
      invalid = INVALID + ('0001-01-01T00:00:01+14:00', '9999-12-31T23:59:59-12:00')
      if zone == 'EST5':
        invalid += ('0001-01-01T00:00:01Z',)
      elif zone == 'JST-9':
        invalid += ('9999-12-31T23:59:59Z',)
      with local_zone(zone), tempfile.TemporaryDirectory() as scratch, self.subTest(zone=zone):
        root = Path(scratch)
        write_fixture(root, invalid)
        # Today is the shared module's to say, as well as the collector's.
        with patch.dict(namespace, datetime=FrozenDatetime), patch.object(sys.modules['collectors'], 'datetime', FrozenDatetime):
          stats = collector.local_stats(root)
        self.assertTrue(stats['hasLocalStats'])
        self.assertEqual(stats['totalPrompts'], 3)
        self.assertEqual(stats['todayPrompts'], 1 if zone == 'EST5' else 2)
        # Summary identities remain countable without a date; bad history isn't.
        self.assertEqual(stats['totalSessions'], 4)
        self.assertEqual(stats['todaySessions'], 2)
        dates = ['1969-07-20', '2026-10-02']
        if zone == 'EST5':
          dates.insert(1, '2026-10-01')
        self.assertEqual(stats['activeDates'], dates)
        self.assertEqual(stats['activeDays'], len(dates))
        self.assertEqual(stats['todayTotalTokens'], 15 if zone == 'EST5' else 25)
        self.assertEqual(stats['todayTokensByModel'], {'dated': stats['todayTotalTokens']})
        recent = {row['date']: row['messageCount'] for row in stats['recentDays']}
        self.assertEqual(recent['2026-10-02'], stats['todayTotalTokens'])
        self.assertEqual(sum(recent.values()), 25)
        self.assertEqual(stats['modelUsage']['dated']['inputTokens'], 17)
        self.assertEqual(stats['modelUsage']['dated']['outputTokens'], 8)
        # Undated usage retains lifetime totals, just like a missing timestamp.
        self.assertEqual(stats['modelUsage']['undated']['inputTokens'], 2 * (len(invalid) + 1))
        self.assertEqual(stats['modelUsage']['undated']['outputTokens'], len(invalid) + 1)

  def test_quota_reset_display_keeps_unknown_and_valid_windows(self):
    # A usable quota remains useful without a trustworthy reset countdown.
    cases = [({}, '')] + [({'resetTime': value}, '') for value in INVALID]
    cases += [
      ({'resetTime': '2026-10-02T11:00:00Z'}, '2026-10-02T11:00:00+00:00'),
      ({'resetTime': '2026-10-02T15:00:00+02:00'}, '2026-10-02T15:00:00+02:00'),
      ({'resetTime': '2026-10-02 13:00:00'}, '2026-10-02T13:00:00+00:00'),
      ({'resetTime': (NOW.timestamp() + 3600) * 1000}, '2026-10-02T13:00:00+00:00'),
    ]
    for zone in ZONES:
      for reset, expected in cases:
        with local_zone(zone), self.subTest(zone=zone, reset=reset):
          bucket = dict(reset, window='5h', remainingFraction=0.75)
          self.assertEqual(collector.reset_of(bucket), expected)
          limits = collector.extract_limits({'groups': [
            {'displayName': 'Gemini', 'buckets': [bucket]}]})
          self.assertEqual(len(limits), 1)
          self.assertEqual(limits[0]['resetsAt'], expected)
          self.assertEqual(limits[0]['percent'], 0.25)

  def test_unrelated_errors_propagate(self):
    with patch.dict(namespace, datetime=types.SimpleNamespace(
        fromisoformat=lambda value: (_ for _ in ()).throw(RuntimeError('unexpected parser failure')))):
      with self.assertRaisesRegex(RuntimeError, 'unexpected parser failure'):
        collector.local_day('2026-10-02T12:00:00Z')
    with patch.dict(namespace, parse_time=lambda value: types.SimpleNamespace(
        astimezone=lambda: (_ for _ in ()).throw(RuntimeError('unexpected conversion failure')))):
      with self.assertRaisesRegex(RuntimeError, 'unexpected conversion failure'):
        collector.local_day('2026-10-02T12:00:00Z')

  def test_isolated_cli_smoke_and_cached_record(self):
    for zone in ZONES:
      with tempfile.TemporaryDirectory() as scratch, self.subTest(zone=zone):
        root = Path(scratch)
        write_fixture(root, ('0001-01-01 00:00:00+00:00', None, 'not a date'))
        stub_dir = root / 'bin'
        stub_dir.mkdir()
        secret_tool = stub_dir / 'secret-tool'
        secret_tool.write_text('#!/bin/bash\nexit 1\n')
        secret_tool.chmod(0o755)
        env = dict(os.environ, HOME=scratch, AGY_DIR=scratch, XDG_CACHE_HOME=str(root / 'cache'),
                   PATH=str(stub_dir) + os.pathsep + os.defpath, TZ=zone)
        for flag in ('--force', '--limits-only'):
          result = subprocess.run([str(collector_path), flag], env=env, capture_output=True,
                                  text=True, check=True, timeout=10)
          record = json.loads(result.stdout)
          self.assertEqual(result.stderr, '')
          self.assertEqual(record['id'], 'agy')
          # Local history alone puts Antigravity in use here, waiting for a sign-in.
          self.assertTrue(record['ready'])
          self.assertEqual(record['usageStatusText'], 'Waiting for auth')
          self.assertEqual(record['limits'], [])
          self.assertEqual(record['totalPrompts'], 3)
          self.assertEqual(record['totalSessions'], 4)
          self.assertEqual(record['modelUsage']['dated']['inputTokens'], 17)


unittest.main(verbosity=2)
PY

pass "Antigravity timestamp boundaries, mixed records, and isolated CLI smoke"
