#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 - <<'PY'
import importlib.machinery
import importlib.util
import json
import os
import unittest
from pathlib import Path
from unittest.mock import patch

root = Path(os.environ['ROOT'])
loader = importlib.machinery.SourceFileLoader('collector', str(root / 'bin/omarchy-agent-usage-antigravity'))
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
fixture = json.loads((root / 'test/shell.d/fixtures/antigravity/usage.json').read_text())

class Limits(unittest.TestCase):
  def test_real_cli_shape_and_reversed_groups(self):
    data = fixture['command']['data']
    limits = collector.extract_limits(data)
    self.assertEqual([v['title'] for v in limits], ['Session', 'Weekly', 'Claude/GPT Session', 'Claude/GPT Weekly'])
    self.assertEqual([v['percent'] for v in limits], [0, .27, 0, .03])
    reversed_data = {'groups': list(reversed(data['groups']))}
    self.assertEqual(limits, collector.extract_limits(reversed_data))
    self.assertEqual(limits[0]['resetsAt'], '2099-10-02T07:42:57+00:00')

  def test_missing_invalid_and_exhausted_buckets(self):
    for remaining in [None, 'bad', True, float('nan'), float('inf'), -1, 2]:
      data = {'groups': [{'name': 'Gemini Models', 'buckets': [{'window': '5h', 'remaining_fraction': remaining}]}]}
      self.assertEqual(collector.extract_limits(data), [], remaining)
    data['groups'][0]['buckets'][0]['remaining_fraction'] = 0
    self.assertEqual(collector.extract_limits(data)[0]['percent'], 1)
    del data['groups'][0]['buckets'][0]['remaining_fraction']
    self.assertEqual(collector.extract_limits(data), [])
    for data in [{}, {'groups': None}, {'groups': [None, {'buckets': 7}]}]:
      self.assertEqual(collector.extract_limits(data), [])

  def test_only_scoped_group_keeps_its_identity(self):
    data = {'groups': [fixture['command']['data']['groups'][0]]}
    self.assertEqual([limit['title'] for limit in collector.extract_limits(data)], ['Claude/GPT Session', 'Claude/GPT Weekly'])
    self.assertEqual(collector.extract_limits(data)[0]['percent'], 0)

  def test_version_gate_never_prompts_an_old_or_unknown_cli(self):
    for version in ['1.1.10', '1.0.99', 'unknown', '1.1.11-preview', '']:
      with patch.object(collector, 'run_cli', return_value=(0, version, '')) as run:
        result = collector.probe_limits('agy')
      self.assertEqual(run.call_count, 1)
      self.assertEqual(result['usageStatusText'], 'Antigravity update required')
    for version in ['1.1.11', '1.2.14', '2.0.0', 'agy 1.2.14']:
      self.assertTrue(collector.supported_version(version))

  def test_failures_and_malformed_success(self):
    cases = [('401 unauthenticated', 'Antigravity sign-in required', False),
             ('403 PermissionDenied', 'Antigravity sign-in required', False),
             ('429 RESOURCE_EXHAUSTED', 'Antigravity limits rate limited', False),
             ('dial tcp: no such host', 'Antigravity limits unavailable', True),
             ('refresh credentials: dial tcp: connection refused', 'Antigravity limits unavailable', True),
             ('500 internal server error', 'Antigravity limits unavailable', False)]
    for error, status, retry in cases:
      with patch.object(collector, 'run_cli', side_effect=[(0, '1.2.14', ''), (1, '', error)]):
        result = collector.probe_limits('agy')
      self.assertEqual(result['usageStatusText'], status)
      self.assertEqual(result['retryAdvised'], retry)
      self.assertNotIn(error, result['authHelpText'])
    for output in ['invalid', '[]', '{}', '{"status":"SUCCESS","response":"pretend usage"}',
                   '{"status":"SUCCESS","command":{"name":"usage","data":{}}}']:
      with patch.object(collector, 'run_cli', side_effect=[(0, '1.2.14', ''), (0, output, '')]):
        self.assertTrue(collector.probe_limits('agy')['usageStatusText'])
    with patch.object(collector, 'run_cli', side_effect=collector.subprocess.TimeoutExpired('agy', 20)):
      self.assertTrue(collector.probe_limits('agy')['retryAdvised'])

  def test_every_check_reads_the_current_sign_in(self):
    good = {'limits': collector.extract_limits(fixture['command']['data']), 'usageStatusText': '', 'authHelpText': ''}
    other = {'limits': [{'title': 'Session', 'percent': .8, 'resetsAt': '2099-01-01T00:00:00Z'}], 'usageStatusText': '', 'authHelpText': ''}
    failure = collector.probe_failure('network unavailable')
    auth = collector.probe_failure('401')
    with patch.object(collector, 'probe_limits', side_effect=[good, other, failure, auth, good]) as probe:
      first = collector.collect_limits('agy')
      second = collector.collect_limits('agy')
      self.assertEqual(first['limits'], good['limits'])
      self.assertEqual(second['limits'], other['limits'])
      self.assertGreater(second['limitsFetchedAt'], 0)
      offline = collector.collect_limits('agy')
      self.assertEqual(offline['limits'], [])
      self.assertTrue(offline['retryAdvised'])
      self.assertEqual(offline['limitsFetchedAt'], 0)
      signed_out = collector.collect_limits('agy')
      self.assertEqual(signed_out['limits'], [])
      signed_in = collector.collect_limits('agy')
      self.assertEqual(signed_in['usageStatusText'], '')
      self.assertEqual(signed_in['limits'], good['limits'])
      self.assertEqual(probe.call_count, 5)

unittest.main(verbosity=2)
PY
pass "Antigravity quota parsing, version safety, failures and account changes"
