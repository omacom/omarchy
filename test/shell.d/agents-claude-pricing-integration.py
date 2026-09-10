"""Drive Claude transcripts and fallbacks through updater storage and public pricing."""

import datetime
import json
import os
from pathlib import Path
import sqlite3
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
const rows = pricing.buildDailyRows('claude', payload.record.dailyUsage, payload.record.recentDays, now, overrides, true)
process.stdout.write(JSON.stringify({
  rows,
  tooltip: pricing.dailyTooltip(rows[rows.length - 1]),
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
  pi = {"type": "message", "id": "pi", "timestamp": "2026-09-30T10:00:00Z",
    "message": {"role": "assistant", "provider": "anthropic", "model": "claude-opus-5",
                "inference_geo": "global",
                "usage": {"input": 10, "output": 4, "cacheRead": 3, "cacheWrite": 2}}}
  excluded = {"type": "message", "id": "foreign", "timestamp": "2026-09-30T10:00:00Z",
    "message": {"role": "assistant", "provider": "anthropic-proxy", "model": "claude-opus-5",
                "usage": {"input": 9999, "output": 9999}}}
  path.write_text("\n".join(json.dumps(row) for row in (pi, pi, excluded)) + "\n")
  omp = home / ".omp/agent/sessions/project/omp.jsonl"
  omp.parent.mkdir(parents=True)
  omp.write_text(json.dumps({"type": "message", "id": "omp", "timestamp": "2026-09-24T10:00:00Z",
    "message": {"role": "assistant", "provider": "anthropic", "model": "claude-sonnet-5",
                "usage": {"input": 20, "output": 5, "cacheRead": 4, "cacheWrite": 1, "totalTokens": 30}}}) + "\n")
  db = home / ".local/share/opencode/opencode.db"
  db.parent.mkdir(parents=True)
  connection = sqlite3.connect(db)
  connection.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
  created = 1790762400000
  def row(identifier, provider, model, **values):
    data = {"role": "assistant", "providerID": provider, "modelID": model,
      "tokens": {"input": values.get("input", 0), "output": values.get("output", 0),
                 "reasoning": values.get("reasoning", 0),
                 "cache": {"read": values.get("read", 0), "write": values.get("write", 0)}},
      "time": {"created": created}}
    if values.get("inference_geo"):
      data["inference_geo"] = values["inference_geo"]
    return (identifier, "same-opencode-session", created, created, json.dumps(data))
  connection.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
    row("known", "anthropic", "claude-haiku-4-5-20251001", input=30, output=5, reasoning=2, read=4, write=1,
        inference_geo="global"),
    row("model-change", "anthropic", "anthropic/custom", input=5),
    row("excluded", "anthropic-proxy", "claude-opus-5", input=9999),
  ])
  connection.commit()
  connection.close()


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
assert record["todayTotalTokens"] == 1786 and record["modelUsage"]["claude-sonnet-4-5"]["inputTokens"] == 1000
assert abs(next(row for row in formatted["rows"] if row["date"] == "2026-09-24")["cost"]["total"] - 55.6250933) < 1e-12
today = next(row for row in formatted["rows"] if row["date"] == "2026-09-30")
assert today["tokens"] == 1786 and abs(today["cost"]["total"] - 0.00769565) < 1e-12
assert today["cost"]["status"] == "partial"
manual_payload = json.dumps({"record": record, "now": "2026-09-30T12:00:00+02:00",
  "overrideText": json.dumps({"models": {"anthropic/custom": {
    "input": 1, "output": 2, "cacheRead": 0, "cacheWrite": 0}}})})
manual = json.loads(subprocess.run(["node", "-e", FORMATTER, str(ROOT / "shell/plugins/agents/ApiCost.js")],
                                    input=manual_payload, text=True, capture_output=True, check=True).stdout)
manual_today = next(row for row in manual["rows"] if row["date"] == "2026-09-30")
assert abs(manual_today["cost"]["total"] - 0.00770065) < 1e-12
assert any(rate["modelId"] == "anthropic/custom" and rate["origin"] == "user-override"
           for rate in manual_today["cost"]["rates"])
assert len(formatted["presentation"]["models"]) == 4 and len(formatted["presentation"]["summaries"]) == 3
assert [summary["tokens"] for summary in formatted["presentation"]["summaries"]] == [1786, 3_101_816, 3_101_816]
assert not any(model["id"] == "anthropic/custom" for model in formatted["presentation"]["models"])
assert any(bucket["issues"] == ["inconsistent-total"]
           and all(value is None for value in bucket["tokens"].values())
           for bucket in days["2026-09-30"]["buckets"])
assert {bucket["source"] for day in days.values() for bucket in day["buckets"]} == {"claude-native", "pi", "omp", "opencode"}
assert next(bucket for bucket in days["2026-09-30"]["buckets"] if bucket["source"] == "pi")["tariff"]["inference_geo"] == "global"
opencode = next(bucket for bucket in days["2026-09-30"]["buckets"] if bucket["rawModel"] == "claude-haiku-4-5-20251001")
assert opencode["tokens"] == {"inputTokens": 30, "outputTokens": 7,
  "cacheReadInputTokens": 4, "cacheCreationInputTokens": 1}
assert opencode["tariff"]["inference_geo"] == "global"
assert any(bucket["rawModel"] == "anthropic/custom" for bucket in days["2026-09-30"]["buckets"])
print("ok - native Claude, Pi, OMP, and OpenCode share typed daily/model/window pricing scope")


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
  cached["collectorRevision"] = 2
  cached["scanDate"] = "1999-01-01"
  cache.write_text(json.dumps(cached))
  path = home / ".claude/projects/example/session.jsonl"
  with path.open("a") as stream:
    stream.write(json.dumps(assistant("new", "2026-09-30T10:03:00Z", "claude-opus-5", 7, 0, 0, 0)) + "\n")


rescanned = collect([assistant("first", "2026-09-30T10:00:00Z", "claude-opus-5", 5, 0, 0, 0)],
                    force=False, between=invalidate_old_cache)
assert rescanned["todayTotalTokens"] == 12 and rescanned["dailyUsage"]["schemaVersion"] == 1
print("ok - previous-contract and prior-day Claude caches are invalidated and rebuilt")

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

def extra_edges(home):
  pi = home / ".pi/agent/sessions/project/edge.jsonl"
  pi.parent.mkdir(parents=True)
  pi.write_text(json.dumps({"type": "message", "id": "missing", "timestamp": "2026-09-30T10:00:00Z",
    "message": {"role": "assistant", "provider": "anthropic", "model": "claude-opus-5",
                "usage": {"input": 7}}}) + "\n")
  omp = home / ".omp/agent/sessions/project/edge.jsonl"
  omp.parent.mkdir(parents=True)
  omp.write_text(json.dumps({"type": "message", "id": "contradiction", "timestamp": "2026-09-30T10:00:00Z",
    "message": {"role": "assistant", "provider": "anthropic", "model": "claude-opus-5",
                "usage": {"input": 5, "output": 0, "cacheRead": 0, "cacheWrite": 0, "totalTokens": 100}}}) + "\n")


edges = collect(extras=extra_edges)
edge_buckets = edges["dailyUsage"]["days"][-1]["buckets"]
assert edges["todayTotalTokens"] == 12 and edge_buckets[0]["tokens"]["outputTokens"] is None
assert edge_buckets[1]["issues"] == ["inconsistent-total"]
assert all(value is None for value in edge_buckets[1]["tokens"].values())
print("ok - missing and contradictory Claude extra-source categories remain unknown without changing tokens")

boundary = collect([
  assistant("before", "2026-03-28T22:59:59Z", "claude-opus-5", 5, 0, 0, 0),
  assistant("after", "2026-03-28T23:00:00Z", "claude-sonnet-5", 7, 0, 0, 0),
], now="2026-03-30T12:00:00+02:00")
boundary_days = {day["date"]: day for day in boundary["dailyUsage"]["days"]}
assert boundary_days["2026-03-28"]["buckets"][0]["rawModel"] == "claude-opus-5"
assert boundary_days["2026-03-29"]["buckets"][0]["rawModel"] == "claude-sonnet-5"
print("ok - a same-session Claude model change stays on each side of local midnight before DST")


def split(five, hour):
  return {"ephemeral_5m_input_tokens": five, "ephemeral_1h_input_tokens": hour}


def format_special(record, overrides=""):
  return json.loads(subprocess.run(
    ["node", "-e", FORMATTER, str(ROOT / "shell/plugins/agents/ApiCost.js")],
    input=json.dumps({"record": record, "now": "2026-09-30T12:00:00+02:00", "overrideText": overrides}),
    text=True, capture_output=True, check=True).stdout)


special_cases = [
  ("5m", split(10, 0), {}, "complete", .0000675),
  ("1h", split(0, 10), {}, "complete", .000105),
  ("mixed", split(4, 6), {}, "complete", .00009),
  ("absent", None, {}, "complete", .0000675),
  ("mismatch", split(4, 5), {}, "partial", .000005),
  ("invalid", split(True, 9), {}, "partial", .000005),
  ("missing", {"ephemeral_5m_input_tokens": 10}, {}, "partial", .000005),
  ("unknown ttl", None, {"cache_duration": "24h"}, "partial", .000005),
  ("conflicting ttl", split(4, 6), {"cache_duration": "5m"}, "partial", .000005),
  ("global", split(0, 10), {"inference_geo": "global"}, "complete", .000105),
  ("fake geo alias", None, {"inference_geo": "standard"}, "unknown", 0),
  ("invalid geo", None, {"inference_geo": False}, "unknown", 0),
  ("fast", split(0, 10), {"fast_mode": True}, "unknown", 0),
]
for name, creation, attributes, status, cost in special_cases:
  event = assistant(name, "2026-09-30T10:00:00Z", "claude-opus-5", 1, 0, 0, 10, creation)
  event["message"].update(attributes)
  special = collect([event])
  bucket = special["dailyUsage"]["days"][-1]["buckets"][0]
  result = format_special(special)
  views = [result["rows"][-1], *result["presentation"]["models"], *result["presentation"]["summaries"]]
  assert len(views) == 5 and all(item["tokens"] == 11 and item["cost"]["status"] == status
    and abs(item["cost"]["total"] - cost) < 1e-14 for item in views), name
  if creation is not None:
    assert "cache_creation" in bucket["tariff"], name + " numeric split was lost"
  assumptions = " ".join(result["rows"][-1]["cost"]["assumptions"])
  if name == "absent":
    assert "Absent cache-duration metadata assumes 5-minute cache writes" in assumptions
  elif name in ("1h", "mixed"):
    assert "Absent cache-duration metadata" not in assumptions
  elif name == "unknown ttl":
    assert "observed 5-minute" not in assumptions and "assumes 5-minute" not in assumptions
  print("ok - Claude cache/geo " + name + " preserves one full-precision daily/model/window decision")

many_writes = collect([
  assistant("many-" + str(amount), "2026-09-30T10:00:00Z", "claude-opus-5", 0, 0, 0, amount, split(0, amount))
  for amount in range(1, 21)
])
many_result = format_special(many_writes)
many_today = many_result["rows"][-1]
assert many_today["tokens"] == 210 and abs(many_today["cost"]["total"] - .0021) < 1e-14
assert len(many_today["cost"]["assumptions"]) == 2
assert "210 tokens at 1h" not in many_result["tooltip"] and len(many_result["tooltip"]) < 1000
print("ok - many cache-write buckets keep exact totals and bounded class-level assumptions")

for ttl in (split(0, 10), split(4, 6)):
  event = assistant("manual", "2026-09-30T10:00:00Z", "claude-opus-5", 1, 0, 0, 10, ttl)
  for price in (0, 0.123456789):
    changed = format_special(collect([event]), json.dumps({"models": {"claude-opus-5": {
      "input": 5, "output": 25, "cacheRead": .5, "cacheWrite": price}}}))
    views = [changed["rows"][-1], *changed["presentation"]["models"], *changed["presentation"]["summaries"]]
    assert all(v["cost"]["status"] == "complete" and abs(v["cost"]["total"] - (5 + 10 * price) / 1e6) < 1e-16 for v in views)
    assert "User-configured cache-write rate" in " ".join(changed["rows"][-1]["cost"]["assumptions"])
print("ok - explicit manual zero/fractional cache-write rates override valid 1h and mixed duration prices")

zero = collect([assistant("zero", "2026-09-30T10:00:00Z", "claude-opus-5", 0, 0, 0, 0, split(0, 0))])
zero_cost = format_special(zero)["rows"][-1]["cost"]
assert zero_cost["total"] == 0 and not any("cache" in note.lower() for note in zero_cost["assumptions"])
print("ok - zero cache writes retain numeric zero without inventing usage")


def source_tariffs(home):
  for client, creation in (("pi", split(10, 0)), ("omp", split(0, 10))):
    path = home / ("." + client) / "agent/sessions/project/cache.jsonl"
    path.parent.mkdir(parents=True)
    path.write_text(json.dumps({"type": "message", "id": client, "timestamp": "2026-09-30T10:00:00Z",
      "message": {"role": "assistant", "provider": "anthropic", "model": "claude-opus-5",
                  "usage": {"input": 1, "output": 0, "cacheRead": 0, "cacheWrite": 10,
                            "cache_creation": creation}}}) + "\n")
  db = home / ".local/share/opencode/opencode.db"
  db.parent.mkdir(parents=True)
  connection = sqlite3.connect(db)
  connection.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
  def message(identifier, created, incoming):
    return (identifier, "cache-session", created, created, json.dumps({"role": "assistant",
      "providerID": "anthropic", "modelID": "claude-opus-5", "cache_duration": "24h",
      "tokens": {"input": incoming, "output": 0, "reasoning": 0,
                 "cache": {"read": 0, "write": 10 if created else 0}}, "time": {"created": created}}))
  connection.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
    message("dated", 1790762400000, 1), message("undated", 0, 7)])
  connection.commit()
  connection.close()


source_special = collect(extras=source_tariffs)
source_result = format_special(source_special)
source_today = source_result["rows"][-1]
assert source_today["tokens"] == 33 and source_today["cost"]["status"] == "partial"
assert abs(source_today["cost"]["total"] - .0001775) < 1e-14
assert source_special["dailyUsage"]["unallocatedTokens"] == 7
assert {bucket["source"] for bucket in source_special["dailyUsage"]["days"][-1]["buckets"]} == {"pi", "omp", "opencode"}
manual_sources = format_special(source_special, json.dumps({"models": {"claude-opus-5": {
  "input": 5, "output": 25, "cacheRead": .5, "cacheWrite": 0}}}))
assert abs(manual_sources["rows"][-1]["cost"]["total"] - .000015) < 1e-14
print("ok - Pi, OMP, and OpenCode cache durations preserve typed source pricing and undated coverage")
