"""Synthetic collector -> atomic updater -> public presentation tests; no Kimi process."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from datetime import datetime, timedelta

ROOT = Path(__file__).resolve().parents[2]


class KimiUsage(unittest.TestCase):
  def setUp(self):
    self.temp = tempfile.TemporaryDirectory(prefix="omarchy-kimi-test-")
    self.addCleanup(self.temp.cleanup)
    self.home = Path(self.temp.name)
    self.share = self.home / "share"
    self.wire = self.share / "sessions" / ("a" * 32) / "session-fixture" / "wire.jsonl"
    self.now = datetime.fromisoformat("2026-09-10T12:00:00+02:00")
    self.env = {**os.environ, "HOME": str(self.home), "KIMI_SHARE_DIR": str(self.share),
                "XDG_STATE_HOME": str(self.home / "state"), "OMARCHY_PATH": str(self.home / "runtime"),
                "TZ": "Europe/Berlin"}
    launcher = self.home / "runtime/bin/omarchy-agent-usage-kimi"
    launcher.parent.mkdir(parents=True)
    launcher.write_text("#!/usr/bin/python3\nimport datetime, runpy\n"
      "class Clock(datetime.datetime):\n"
      "  @classmethod\n  def now(cls, tz=None):\n"
      "    return cls.fromisoformat(\"2026-09-10T12:00:00+02:00\").astimezone(tz)\n"
      "datetime.datetime = Clock\n"
      + "runpy.run_path(" + repr(str(ROOT / "bin/omarchy-agent-usage-kimi")) + ", run_name=\"__main__\")\n")
    launcher.chmod(0o700)

  def event(self, usage=None, **payload):
    return {"timestamp": self.now.timestamp(), "message": {"type": "StatusUpdate", "payload": {
      "token_usage": {"input_other": 10, "output": 4, "input_cache_read": 6,
                      "input_cache_creation": 2} if usage is None else usage, **payload}}}

  def write(self, events, version="1.10"):
    self.wire.parent.mkdir(parents=True, exist_ok=True)
    self.wire.write_text("\n".join(json.dumps(x) for x in [
      {"type": "metadata", "protocol_version": version}, *events]) + "\n")

  def collect(self):
    result = subprocess.run(["bash", str(ROOT / "bin/omarchy-agent-usage-update"), "kimi"],
                            env=self.env, capture_output=True, text=True)
    self.assertEqual(result.returncode, 0, result.stderr)
    target = self.home / "state/omarchy/agents/usage/kimi.json"
    self.assertTrue(target.is_file(), "updater must discover and write Kimi collector")
    return json.loads(target.read_text())

  def test_native_replacement(self):
    self.write([self.event()])
    first = self.collect()
    self.assertEqual(first["todayTotalTokens"], 22)
    self.assertEqual(self.collect()["todayTotalTokens"], 22)
    self.write([self.event(), self.event()])
    self.assertEqual(self.collect()["todayTotalTokens"], 44)
    self.write([self.event()])
    self.assertEqual(self.collect()["todayTotalTokens"], 22)

  def present(self, record):
    script = r"""
const fs = require('fs'), vm = require('vm');
const api = require(process.argv[1]);
const record = JSON.parse(fs.readFileSync(0, 'utf8'));
const now = Number(process.argv[2]);
const qml = fs.readFileSync(process.argv[3], 'utf8');
const start = qml.indexOf('  function providerHasData(');
const end = qml.indexOf('\n  }', start) + 4;
const context = { numberValue: value => Number(value) || 0 };
vm.createContext(context); vm.runInContext(qml.slice(start, end), context);
console.log(JSON.stringify({
  rows: api.buildDailyRows('kimi', record.dailyUsage, record.recentDays, now, '', true),
  model: api.buildModelWindowPresentation('kimi', record.dailyUsage, now, '', true),
  visible: context.providerHasData(record)
}));
"""
    result = subprocess.run(['node', '-e', script, str(ROOT / 'shell/plugins/agents/ApiCost.js'),
                             str(self.now.timestamp() * 1000), str(ROOT / 'shell/plugins/agents/Main.qml')],
                            input=json.dumps(record), text=True, capture_output=True, env=self.env)
    self.assertEqual(result.returncode, 0, result.stderr)
    return json.loads(result.stdout)

  def test_public_presentation(self):
    self.write([self.event()])
    p = self.present(self.collect())
    self.assertTrue(p['visible'])
    self.assertEqual(len(p['rows']), 7)
    self.assertEqual(p['rows'][-1]['value'], '22/—')
    self.assertTrue(p['model']['available'])
    self.assertEqual(p['model']['models'][0]['id'], '(unknown model)')
    self.assertEqual([row['tokens'] for row in p['model']['summaries']], [22, 22, 22])
    self.assertTrue(all(row['cost']['status'] == 'unknown' for row in p['model']['summaries']))

  def test_empty_source_not_created_or_visible(self):
    record = self.collect()
    self.assertFalse(self.share.exists())
    self.assertFalse(self.present(record)['visible'])
    self.assertFalse(record['ready'])

  def test_null_gauge_and_private_content(self):
    self.write([self.event(), self.event(token_usage=None, context_tokens=99999),
      {'timestamp': self.now.timestamp(), 'message': {'type': 'TurnBegin',
       'payload': {'user_input': 'PRIVATE_SENTINEL'}}}])
    record = self.collect()
    self.assertEqual(record['todayTotalTokens'], 22)
    self.assertNotIn('PRIVATE_SENTINEL', json.dumps(record))
    bucket = record['dailyUsage']['days'][-1]['buckets'][0]
    self.assertIsNone(bucket['rawModel'])
    self.assertEqual(list(bucket['tokens'].values()), [10, 4, 6, 2])

  def test_fully_known_zero_status_is_ignored(self):
    self.write([self.event({'input_other': 0, 'output': 0,
      'input_cache_read': 0, 'input_cache_creation': 0})])
    record = self.collect()
    self.assertFalse(record['ready'])
    self.assertEqual(sum(len(day['buckets']) for day in record['dailyUsage']['days']), 0)

  def test_invalid_counts_and_model_claim(self):
    for invalid in [-1, True, '4', 1.5, None]:
      with self.subTest(invalid=invalid):
        self.write([self.event({'input_other': 10, 'output': invalid,
          'input_cache_read': 6, 'input_cache_creation': 2}, model='invented-model')])
        record = self.collect()
        bucket = record['dailyUsage']['days'][-1]['buckets'][0]
        self.assertIsNone(bucket['tokens']['outputTokens'])
        self.assertIsNone(bucket['totalTokens'])
        self.assertIsNone(bucket['rawModel'])
        self.assertFalse(record['dailyUsage']['complete'])
        self.assertEqual(record['todayTotalTokens'], 18)

  def test_version_and_subagent_gap(self):
    self.write([self.event()], version='99')
    record = self.collect()
    self.assertEqual(record['todayTotalTokens'], 0)
    self.assertIn('unsupported-wire-version', record['dailyUsage']['issues'])
    self.write([self.event(), {'timestamp': self.now.timestamp(), 'message': {
      'type': 'SubagentEvent', 'payload': {'event': self.event()['message']}}}])
    record = self.collect()
    self.assertEqual(record['todayTotalTokens'], 22)
    self.assertIn('unsupported-wire-event', record['dailyUsage']['issues'])

  def test_local_calendar_and_window(self):
    events = []
    for age in (0, 6, 7, 29, 30):
      event = self.event()
      event['timestamp'] = (self.now - timedelta(days=age)).timestamp()
      events.append(event)
    self.write(events)
    result = self.present(self.collect())
    self.assertEqual([row['tokens'] for row in result['model']['summaries']], [22, 44, 88])

  def test_missing_timestamp_not_today(self):
    event = self.event()
    event['timestamp'] = 'not-a-time'
    self.write([event])
    record = self.collect()
    self.assertEqual(record['todayTotalTokens'], 0)
    self.assertEqual(record['dailyUsage']['unallocatedTokens'], 22)
    self.assertIn('invalid-timestamp', record['dailyUsage']['issues'])

  def test_schema_defaults_and_invalid_json(self):
    self.write([self.event({'input_other': 10, 'output': 4})])
    self.assertEqual(self.collect()['todayTotalTokens'], 14)
    with self.wire.open('a') as stream:
      stream.write('{broken\n')
    record = self.collect()
    self.assertEqual(record['todayTotalTokens'], 14)
    self.assertIn('invalid-wire-record', record['dailyUsage']['issues'])

  def test_local_midnight_and_default_root(self):
    event = self.event()
    event['timestamp'] = datetime.fromisoformat('2026-09-09T22:30:00+00:00').timestamp()
    self.write([event])
    default = self.home / '.kimi'
    self.share.rename(default)
    self.env.pop('KIMI_SHARE_DIR')
    self.assertEqual(self.collect()['todayTotalTokens'], 22)

  def test_exact_manual_only_and_unknown_identity(self):
    self.write([self.event()])
    record = self.collect()
    script = r"""
const api=require(process.argv[1]);
const override=api.parseOverrides(JSON.stringify({models:{model:{input:1,output:2,cacheRead:3,cacheWrite:4}},aliases:{alias:'model'}}));
if (!api.resolveRate('kimi','model',override)) throw Error('exact override missing');
if (api.resolveRate('kimi','alias',override)) throw Error('unproven alias priced');
if (api.resolveRate('kimi',null,override)) throw Error('unknown identity priced');
"""
    result = subprocess.run(['node', '-e', script, str(ROOT / 'shell/plugins/agents/ApiCost.js')],
                            capture_output=True, text=True, env=self.env)
    self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
  unittest.main()
