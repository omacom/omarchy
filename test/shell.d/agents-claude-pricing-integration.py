"""Drive Claude transcripts and fallbacks through updater storage and public pricing."""

import datetime
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(sys.argv[1])

FORMATTER = r"""
const fs = require('fs')
const pricing = require(process.argv[1])
const payload = JSON.parse(fs.readFileSync(0, 'utf8'))
const overrides = pricing.parseOverrides(payload.overrideText || '')
const now = Date.parse(payload.now)
process.stdout.write(JSON.stringify({
  rows: pricing.buildDailyRows('claude', payload.record.dailyUsage, payload.record.recentDays, now, overrides, true),
  presentation: pricing.buildModelWindowPresentation('claude', payload.record.dailyUsage, now, overrides, true)
}))
"""


def collect(records=None, extras=None, force=True, now="2026-09-30T12:00:00+02:00", between=None):
  with tempfile.TemporaryDirectory(prefix="omarchy-claude-pricing-") as temp:
    home = Path(temp)
    fake = home / "omarchy/bin"
    fake.mkdir(parents=True)
    launcher = fake / "omarchy-agent-usage-claude"
    launcher.write_text(f'''#!/usr/bin/python3
import datetime, runpy, sys
from unittest.mock import patch
RealDateTime = datetime.datetime
class Clock(RealDateTime):
  @classmethod
  def now(cls, tz=None):
    value = RealDateTime.fromisoformat({now!r})
    return value.astimezone(tz) if tz else value.astimezone().replace(tzinfo=None)
sys.argv = [{str(ROOT / "bin/omarchy-agent-usage-claude")!r}] + {(["--force"] if force else [])!r}
with patch("datetime.datetime", Clock):
  runpy.run_path(sys.argv[0], run_name="__main__")
''')
    launcher.chmod(0o755)
    if records:
      path = home / ".claude/projects/example/session.jsonl"
      path.parent.mkdir(parents=True)
      path.write_text("\n".join(json.dumps(row) for row in records) + "\n")
    if extras:
      extras(home)
    env = {"HOME": str(home), "CLAUDE_CONFIG_DIR": str(home / ".claude"),
           "XDG_DATA_HOME": str(home / ".local/share"), "XDG_CACHE_HOME": str(home / ".cache"),
           "XDG_STATE_HOME": str(home / ".local/state"), "OMARCHY_PATH": str(fake.parent),
           "PATH": str(fake) + ":" + os.environ["PATH"], "TZ": "Europe/Berlin"}
    command = [str(ROOT / "bin/omarchy-agent-usage-update"), "claude"]
    subprocess.run(command, env=env, check=True)
    if between:
      between(home)
      subprocess.run(command, env=env, check=True)
    return json.loads((home / ".local/state/omarchy/agents/usage/claude.json").read_text())


def assistant(identifier, at, model, incoming, outgoing, read, write, creation=None):
  usage = {"input_tokens": incoming, "output_tokens": outgoing,
           "cache_read_input_tokens": read, "cache_creation_input_tokens": write}
  if creation is not None:
    usage["cache_creation"] = creation
  return {"timestamp": at, "type": "assistant", "sessionId": "same-session", "uuid": identifier,
          "message": {"id": identifier, "role": "assistant", "model": model, "usage": usage}}


def extras(home):
  path = home / ".pi/agent/sessions/project/pi.jsonl"
  path.parent.mkdir(parents=True)
  path.write_text(json.dumps({"type": "message", "id": "pi", "timestamp": "2026-09-30T10:00:00Z",
    "message": {"role": "assistant", "provider": "anthropic", "model": "claude-opus-5",
                "usage": {"input": 10, "output": 4, "cacheRead": 3, "cacheWrite": 2}}}) + "\n")


rows = [
  assistant("opus", "2026-09-24T10:00:00Z", "claude-opus-4-6", 1_000_000, 2_000_000, 0, 100_000,
            {"ephemeral_5m_input_tokens": 100_000, "ephemeral_1h_input_tokens": 0}),
  assistant("sonnet", "2026-09-30T10:00:00Z", "claude-sonnet-4-5", 1000, 200, 300, 100),
  assistant("sonnet", "2026-09-30T10:00:01Z", "claude-sonnet-4-5", 1000, 200, 300, 100),
  assistant("unknown", "2026-09-30T10:01:00Z", "claude-unknown", 10, 0, 0, 0),
  assistant("one-hour", "2026-09-30T10:02:00Z", "claude-opus-5", 0, 0, 0, 100,
            {"ephemeral_5m_input_tokens": 0, "ephemeral_1h_input_tokens": 100}),
]
rows[1]["message"]["usage"]["inference_geo"] = "global"
contradictory = assistant("contradictory", "2026-09-30T10:03:00Z", "claude-opus-5", 10, 0, 0, 0)
contradictory["message"]["usage"]["total_tokens"] = 999
rows.append(contradictory)
record = collect(rows, extras)
payload = json.dumps({"record": record, "now": "2026-09-30T12:00:00+02:00"})
formatted = json.loads(subprocess.run(["node", "-e", FORMATTER, str(ROOT / "shell/plugins/agents/ApiCost.js")],
                                      input=payload, text=True, capture_output=True, check=True).stdout)
days = {day["date"]: day for day in record["dailyUsage"]["days"]}
assert len(formatted["rows"]) == 7
assert days["2026-09-24"]["buckets"][0]["tokens"] == {
  "inputTokens": 1_000_000, "outputTokens": 2_000_000,
  "cacheReadInputTokens": 0, "cacheCreationInputTokens": 100_000}
assert days["2026-09-30"]["buckets"][0]["rawModel"] == "claude-sonnet-4-5"
assert days["2026-09-30"]["buckets"][0]["tariff"]["inference_geo"] == "global"
assert record["todayTotalTokens"] == 1739 and record["modelUsage"]["claude-sonnet-4-5"]["inputTokens"] == 1000
assert abs(next(row for row in formatted["rows"] if row["date"] == "2026-09-24")["cost"]["total"] - 55.625) < 1e-12
today = next(row for row in formatted["rows"] if row["date"] == "2026-09-30")
assert today["tokens"] == 1739 and abs(today["cost"]["total"] - 0.006465) < 1e-12
assert today["cost"]["status"] == "partial"
assert len(formatted["presentation"]["models"]) == 4 and len(formatted["presentation"]["summaries"]) == 3
assert formatted["presentation"]["summaries"][0]["tokens"] == 1739
assert any(bucket["issues"] == ["inconsistent-total"]
           and all(value is None for value in bucket["tokens"].values())
           for bucket in days["2026-09-30"]["buckets"])
assert any(bucket["source"] == "legacy" and bucket["issues"] == ["source-not-covered"]
           for bucket in days["2026-09-30"]["buckets"])
print("ok - native Claude and legacy extras share honest daily/model/window pricing scope")


def stats_fallback(home):
  path = home / ".claude/stats-cache.json"
  path.parent.mkdir(parents=True)
  path.write_text(json.dumps({"dailyModelTokens": [{"date": "2026-09-30", "tokensByModel": {"claude-opus-5": 123}}],
    "dailyActivity": [{"date": "2026-09-30", "messageCount": 999}], "modelUsage": {"claude-opus-5": {
      "inputTokens": 50, "outputTokens": 50, "cacheReadInputTokens": 20, "cacheCreationInputTokens": 3}},
    "totalMessages": 999, "totalSessions": 2}))


fallback = collect(extras=stats_fallback)
bucket = fallback["dailyUsage"]["days"][-1]["buckets"][0]
assert fallback["recentDays"][-1]["messageCount"] == 123 and fallback["todayTotalTokens"] == 123
assert bucket["totalTokens"] == 123 and all(value is None for value in bucket["tokens"].values())
assert bucket["issues"] == ["token-categories-unavailable"]
print("ok - stats-cache token totals remain visible without pricing message counts or all-time splits")


def history_only(home):
  path = home / ".claude/history.jsonl"
  path.parent.mkdir(parents=True)
  path.write_text(json.dumps({"timestamp": 1790762400000, "sessionId": "history", "display": "prompt"}) + "\n")


history = collect(extras=history_only)
assert history["todayPrompts"] == 1 and sum(day["messageCount"] for day in history["recentDays"]) == 0
assert history["dailyUsage"]["issues"] == ["history-has-no-token-counts"]
print("ok - history message counts remain prompts and make token cost coverage explicitly unavailable")


def invalidate_old_cache(home):
  cache = next((home / ".cache/omarchy/agent-usage").glob("claude-scan-*.json"))
  cached = json.loads(cache.read_text())
  cached["scanDate"] = "1999-01-01"
  cache.write_text(json.dumps(cached))
  path = home / ".claude/projects/example/session.jsonl"
  with path.open("a") as stream:
    stream.write(json.dumps(assistant("new", "2026-09-30T10:03:00Z", "claude-opus-5", 7, 0, 0, 0)) + "\n")


rescanned = collect([assistant("first", "2026-09-30T10:00:00Z", "claude-opus-5", 5, 0, 0, 0)],
                    force=False, between=invalidate_old_cache)
assert rescanned["todayTotalTokens"] == 12 and rescanned["dailyUsage"]["schemaVersion"] == 1
print("ok - prior-day parsed Claude caches are invalidated and rebuilt with daily usage")

undated = assistant("undated", "not-a-time", "claude-opus-5", 9, 0, 0, 0)
undated_record = collect([undated])
assert undated_record["todayTotalTokens"] == 0 and sum(day["messageCount"] for day in undated_record["recentDays"]) == 0
assert undated_record["totalPrompts"] == 1 and undated_record["totalSessions"] == 1
assert undated_record["dailyUsage"]["unallocatedTokens"] == 9
print("ok - invalid native Claude timestamps remain all-time-only and never inflate today")

def undated_pi(home):
  path = home / ".pi/agent/sessions/project/undated.jsonl"
  path.parent.mkdir(parents=True)
  path.write_text(json.dumps({"type": "message", "id": "undated-pi", "timestamp": "bad",
    "message": {"role": "assistant", "provider": "anthropic", "model": "claude-opus-5",
                "usage": {"input": 11, "output": 0, "cacheRead": 0, "cacheWrite": 0}}}) + "\n")


undated_extra = collect(extras=undated_pi)
assert undated_extra["todayTotalTokens"] == 0 and undated_extra["totalPrompts"] == 1
assert undated_extra["dailyUsage"]["unallocatedTokens"] == 11
print("ok - invalid Claude extra-source timestamps preserve all-time counts without inflating today")

boundary = collect([
  assistant("before", "2026-03-28T22:59:59Z", "claude-opus-5", 5, 0, 0, 0),
  assistant("after", "2026-03-28T23:00:00Z", "claude-sonnet-5", 7, 0, 0, 0),
], now="2026-03-30T12:00:00+02:00")
boundary_days = {day["date"]: day for day in boundary["dailyUsage"]["days"]}
assert boundary_days["2026-03-28"]["buckets"][0]["rawModel"] == "claude-opus-5"
assert boundary_days["2026-03-29"]["buckets"][0]["rawModel"] == "claude-sonnet-5"
print("ok - a same-session Claude model change stays on each side of local midnight before DST")
