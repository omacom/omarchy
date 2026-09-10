"""Drive native Codex fixtures through updater storage and the public QML formatter."""

import json
import math
import os
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile


ROOT = Path(sys.argv[1])
PRICING_MODULE = ROOT / "shell/plugins/agents/ApiCost.js"

FORMATTER_PROGRAM = r"""
const fs = require('fs')
const pricing = require(process.argv[1])
const payload = JSON.parse(fs.readFileSync(0, 'utf8'))
const overrides = pricing.parseOverrides(payload.overrideText || '')
const rows = pricing.buildDailyRows(
  'codex', payload.record.dailyUsage, payload.record.recentDays,
  Date.parse(payload.now), overrides, true
)
const presentation = pricing.buildModelWindowPresentation(
  'codex', payload.record.dailyUsage, Date.parse(payload.now), overrides, true
)
process.stdout.write(JSON.stringify({
  rows,
  presentation,
  tooltips: rows.map(row => pricing.dailyTooltip(row)),
  overrideErrors: overrides.errors
}))
"""


def usage(input_tokens=1000, read=200, write=100, output=50, reasoning=20):
  return {
    "input_tokens": input_tokens,
    "cached_input_tokens": read,
    "cache_write_input_tokens": write,
    "output_tokens": output,
    "reasoning_output_tokens": reasoning,
    "total_tokens": input_tokens + output,
  }


def context(model="gpt-6-astra", **extra):
  return {"type": "turn_context", "payload": {"model": model, **extra}}


def event(at="2026-09-09T10:00:00Z", last=None, total=None):
  return {
    "timestamp": at,
    "type": "event_msg",
    "payload": {"type": "token_count", "info": {
      "last_token_usage": last,
      "total_token_usage": total,
    }},
  }


def collect(sessions, now="2026-09-09T12:00:00+02:00", raw_files=None, extras=None):
  with tempfile.TemporaryDirectory(prefix="omarchy-agents-pricing-native-") as temp:
    home = Path(temp)
    fake_bin = home / "omarchy/bin"
    fake_bin.mkdir(parents=True)

    launcher = fake_bin / "omarchy-agent-usage-codex"
    launcher.write_text(f'''#!/usr/bin/python3
import datetime, runpy, sys
from unittest.mock import patch
RealDateTime = datetime.datetime
class Clock(RealDateTime):
  @classmethod
  def now(cls, tz=None):
    value = RealDateTime.fromisoformat({now!r})
    return value.astimezone(tz) if tz else value.astimezone().replace(tzinfo=None)
sys.argv = [{str(ROOT / "bin/omarchy-agent-usage-codex")!r}, "--force"]
with patch("datetime.datetime", Clock):
  runpy.run_path(sys.argv[0], run_name="__main__")
''')
    launcher.chmod(0o755)

    rpc = fake_bin / "codex"
    rpc.write_text('''#!/usr/bin/python3
import json, sys
for line in sys.stdin:
  request = json.loads(line)
  print(json.dumps({"id": request["id"], "result": {}}), flush=True)
''')
    rpc.chmod(0o755)

    for name, records in sessions.items():
      path = home / ".codex" / name
      path.parent.mkdir(parents=True, exist_ok=True)
      path.write_text("\n".join(json.dumps(record) for record in records) + "\n")
    for name, content in (raw_files or {}).items():
      path = home / ".codex" / name
      path.parent.mkdir(parents=True, exist_ok=True)
      path.write_bytes(content)
    if extras:
      extras(home)

    path_value = str(fake_bin) + ":" + os.environ["PATH"]
    env = {
      "HOME": str(home),
      "CODEX_HOME": str(home / ".codex"),
      "XDG_DATA_HOME": str(home / ".local/share"),
      "XDG_CACHE_HOME": str(home / ".cache"),
      "XDG_STATE_HOME": str(home / ".local/state"),
      "OMARCHY_PATH": str(fake_bin.parent),
      "PATH": path_value,
      "PYTHONDONTWRITEBYTECODE": "1",
      "TZ": "Europe/Berlin",
    }
    subprocess.run(
      [str(ROOT / "bin/omarchy-agent-usage-update"), "codex"],
      env=env,
      check=True,
      stdout=subprocess.DEVNULL,
    )
    output = home / ".local/state/omarchy/agents/usage/codex.json"
    return json.loads(output.read_text())


def format_record(record, now="2026-09-09T12:00:00+02:00", override_text=""):
  payload = json.dumps({"record": record, "now": now, "overrideText": override_text})
  completed = subprocess.run(
    ["node", "-e", FORMATTER_PROGRAM, str(PRICING_MODULE)],
    input=payload,
    text=True,
    capture_output=True,
    check=True,
    env={"PATH": os.environ["PATH"], "TZ": "Europe/Berlin"},
  )
  return json.loads(completed.stdout)


def check(condition, description, detail=""):
  if not condition:
    if detail:
      print(detail, file=sys.stderr)
    print("not ok - " + description, file=sys.stderr)
    raise SystemExit(1)
  print("ok - " + description)


def close(actual, expected):
  return math.isclose(actual, expected, rel_tol=0, abs_tol=1e-12)


def row(result, date):
  return next(item for item in result["rows"] if item["date"] == date)


meta = {"type": "session_meta", "payload": {"id": "pricing-stream-session"}}
first = event(
  at="2026-09-08T21:59:58Z",
  last=usage(),
  total=usage(),
)
progress = event(
  at="2026-09-08T21:59:59Z",
  last=usage(output=80),
  total=usage(output=80),
)
second_request = usage(input_tokens=100, read=20, write=10, output=10)
second_total = usage(input_tokens=1100, read=220, write=110, output=90)
second = event(
  at="2026-09-08T22:00:00Z",
  last=second_request,
  total=second_total,
)
stream = [meta, context(), first, first, progress, progress, context("gpt-5.6-sol"), second, second]
complete_record = collect({
  "sessions/live.jsonl": stream,
  "archived_sessions/copy.jsonl": stream,
})
complete_result = format_record(complete_record)
sep8 = row(complete_result, "2026-09-08")
sep9 = row(complete_result, "2026-09-09")
check(sep8["tokens"] == 1080 and sep8["messageCount"] == 1080,
      "streaming replays and an archive copy reach one unchanged Sep 8 bar amount")
check(sep9["tokens"] == 110 and sep9["messageCount"] == 110,
      "the native model switch reaches the next local-day label and bar exactly once")
check(sep8["cost"]["status"] == "complete" and close(sep8["cost"]["total"], 0.01245),
      "Astra native cache and reasoning categories produce the independent Sep 8 amount")
check(sep9["cost"]["status"] == "complete" and close(sep9["cost"]["total"], 0.000538),
      "the switched Sol model uses its own independently calculated rate")
check(len(sep8["cost"]["rates"]) == 1 and sep8["cost"]["rates"][0]["modelId"] == "gpt-6-astra",
      "native raw models select the effective exact bundled tariff")
check("bundled fallback" in complete_result["tooltips"][5]
      and "price as of 2026-09-09" in complete_result["tooltips"][5]
      and "Standard short-context tariff estimate" in complete_result["tooltips"][5],
      "the native Astra tooltip carries provenance, price date, and standard estimate")

zero_record = collect({"sessions/zero-categories.jsonl": [
  context(), event(last=usage(input_tokens=100, read=0, write=0, output=0),
                   total=usage(input_tokens=100, read=0, write=0, output=0)),
]})
zero_day = row(format_record(zero_record), "2026-09-09")
check(zero_day["tokens"] == 100 and zero_day["cost"]["status"] == "complete"
      and close(zero_day["cost"]["total"], 0.001),
      "measured zero cache and output fields remain complete beside priced input")

partial = usage()
partial.pop("input_tokens")
partial.pop("total_tokens")
partial_record = collect({
  "sessions/full.jsonl": [context(), event(last=usage(), total=usage())],
  "sessions/partial.jsonl": [context(), event(last=partial)],
})
partial_result = format_record(partial_record)
partial_day = row(partial_result, "2026-09-09")
check(partial_record["recentDays"][-1]["messageCount"] == 1400,
      "the native updater publishes the independently measured legacy day total")
check(any(bucket["totalTokens"] is None for bucket in partial_record["dailyUsage"]["days"][-1]["buckets"]),
      "the fixture reaches the consumer with a genuinely null bucket total")
check(partial_day["tokens"] == 1400 and partial_day["messageCount"] == 1400,
      "a null bucket total cannot erase independently measured label or bar tokens",
      "formatter row: " + json.dumps(partial_day, sort_keys=True))
check(partial_day["cost"]["status"] == "partial" and close(partial_day["cost"]["total"], 0.0149),
      "known native categories retain only their independently priced subtotal")

separate_day_record = collect({
  "sessions/complete-prior-day.jsonl": [
    context(), event(at="2026-09-08T10:00:00Z", last=usage(), total=usage()),
  ],
  "sessions/partial-current-day.jsonl": [context(), event(last=partial)],
})
separate_day_result = format_record(separate_day_record)
separate_complete_day = row(separate_day_result, "2026-09-08")
separate_partial_day = row(separate_day_result, "2026-09-09")
check(not separate_day_record["dailyUsage"]["complete"]
      and separate_day_record["dailyUsage"]["issues"] == [],
      "the real contract distinguishes localized bucket uncertainty from scan-wide issues")
check(separate_complete_day["tokens"] == 1050
      and separate_complete_day["cost"]["status"] == "complete"
      and close(separate_complete_day["cost"]["total"], 0.01095),
      "a complete native day stays fully priced beside a different partial day")
check(separate_partial_day["tokens"] == 350
      and separate_partial_day["cost"]["status"] == "partial",
      "the separately partial native day retains its measured tokens and subtotal marker")

unallocated_record = collect({
  "sessions/complete-prior-day.jsonl": [
    context(), event(at="2026-09-08T10:00:00Z", last=usage(), total=usage()),
  ],
  "sessions/unallocated.jsonl": [context(), event(at="not-a-date", last=usage(), total=usage())],
})
unallocated_result = format_record(unallocated_record)
unallocated_complete_day = row(unallocated_result, "2026-09-08")
check(unallocated_record["dailyUsage"]["unallocatedTokens"] == 1050
      and "invalid-timestamp" in unallocated_record["dailyUsage"]["issues"],
      "the real contract exposes genuinely unlocalizable measured consumption scan-wide")
check(unallocated_complete_day["tokens"] == 1050
      and unallocated_complete_day["cost"]["status"] == "partial"
      and close(unallocated_complete_day["cost"]["total"], 0.01095),
      "unlocalizable loss still marks an otherwise priced day as incomplete")
check("invalid-timestamp" in unallocated_result["tooltips"][5]
      and "tokens cannot be assigned to a day" in unallocated_result["tooltips"][5],
      "the public tooltip preserves the reason and measured size of unlocalizable loss")

unpriced_record = collect({
  "sessions/missing-model.jsonl": [event(last=usage(), total=usage())],
  "sessions/unknown-model.jsonl": [context("future-codex-model"), event(last=usage(), total=usage())],
})
unpriced_result = format_record(unpriced_record)
unpriced_day = row(unpriced_result, "2026-09-09")
check(unpriced_day["tokens"] == 2100 and unpriced_day["value"] == "2.1K/—",
      "missing and unknown native models preserve tokens without inventing zero cost")
check(unpriced_day["cost"]["status"] == "unknown" and unpriced_day["cost"]["total"] == 0,
      "a day with no priced share remains unknown rather than a known zero subtotal")
check("missing-model" in unpriced_result["tooltips"][6]
      and "No exact tariff for future-codex-model" in unpriced_result["tooltips"][6],
      "rawModel null and an unknown exact model remain visible as missing coverage")

corrected = usage(read=300)
correction_record = collect({"sessions/correction.jsonl": [
  context(), event(last=usage(), total=usage()),
  event(at="2026-09-09T10:00:01Z", last=corrected, total=corrected),
]})
correction_result = format_record(correction_record)
correction_day = row(correction_result, "2026-09-09")
check(correction_day["tokens"] == 1050 and correction_day["value"] == "1.1K/—",
      "a cumulative correction keeps measured consumption but withdraws its price")
check("cumulative-correction" in correction_result["tooltips"][6],
      "the real correction issue reaches the public tooltip")

scan_record = collect(
  {"sessions/valid.jsonl": [context(), event(last=usage(), total=usage())]},
  raw_files={"sessions/broken.jsonl": b"{broken native record\n"},
)
scan_result = format_record(scan_record)
scan_day = row(scan_result, "2026-09-09")
check(scan_day["tokens"] == 1050 and scan_day["cost"]["status"] == "partial"
      and close(scan_day["cost"]["total"], 0.01095),
      "a native scan error preserves measured tokens and marks the known subtotal partial")
check("invalid-native-record" in scan_result["tooltips"][6],
      "the scanner coverage failure survives updater storage and formatting")

alias_record = collect({"sessions/alias.jsonl": [
  context("gpt-5.6"), event(last=usage(), total=usage()),
]})
alias_default = row(format_record(alias_record), "2026-09-09")
manual_text = json.dumps({"models": {"gpt-5.6": {
  "input": 1, "output": 2, "cacheRead": 0, "cacheWrite": 0,
}}})
alias_manual_result = format_record(alias_record, override_text=manual_text)
alias_manual = row(alias_manual_result, "2026-09-09")
check(close(alias_default["cost"]["total"], 0.00438)
      and alias_default["cost"]["rates"][0]["modelId"] == "gpt-5.6-sol",
      "the documented alias uses its exact bundled target before an override exists")
check(close(alias_manual["cost"]["total"], 0.0008)
      and alias_manual["cost"]["rates"][0]["modelId"] == "gpt-5.6"
      and alias_manual["cost"]["rates"][0]["origin"] == "user-override",
      "a manual tariff on the documented alias ID takes priority immediately")
check(alias_manual["tokens"] == alias_default["tokens"] == 1050,
      "repricing the native record never changes its displayed consumption")
invalid_text = '{"models":{"gpt-5.6":{"input":"1","output":2}}}'
alias_invalid_result = format_record(alias_record, override_text=invalid_text)
alias_invalid = row(alias_invalid_result, "2026-09-09")
check(close(alias_invalid["cost"]["total"], 0.00438)
      and alias_invalid["cost"]["rates"][0]["origin"] == "bundled-fallback",
      "an invalid changed override cannot displace the valid alias fallback")
check(alias_invalid_result["overrideErrors"] == ["Invalid manual tariff for gpt-5.6"],
      "the invalid dynamic override remains explicitly visible")

moved = format_record(complete_record, now="2026-09-10T12:00:00+02:00")
check(moved["rows"][-1]["date"] == "2026-09-10" and moved["rows"][-1]["value"] == "0/—",
      "the real stored dataset moves to the next calendar window without new usage")

dst_record = collect({"sessions/dst.jsonl": [
  context(),
  event(at="2026-03-28T23:30:00Z", last=usage(), total=usage()),
  event(at="2026-03-29T22:30:00Z", last=usage(),
        total=usage(input_tokens=2000, read=400, write=200, output=100)),
]}, now="2026-03-30T12:00:00+02:00")
dst_result = format_record(dst_record, now="2026-03-30T12:00:00+02:00")
check([item["date"] for item in dst_result["rows"]][-3:]
      == ["2026-03-28", "2026-03-29", "2026-03-30"],
      "the public formatter keeps contiguous local dates across the 23-hour DST day")
check(row(dst_result, "2026-03-29")["tokens"] == 1050
      and row(dst_result, "2026-03-30")["tokens"] == 1050,
      "native events on both sides of the DST boundary keep their measured day amounts")


def additional_codex_sources(home):
  pi = home / ".pi/agent/sessions/project/pi.jsonl"
  pi.parent.mkdir(parents=True)
  pi_row = {"type": "message", "id": "pi-priced", "timestamp": "2026-09-30T10:00:00Z",
            "message": {"role": "assistant", "provider": "openai-codex",
                        "api": "openai-codex-responses", "model": "gpt-5.6",
                        "usage": {"input": 100, "output": 20, "cacheRead": 30,
                                  "cacheWrite": 10, "totalTokens": 160}}}
  excluded_pi = {"type": "message", "id": "pi-foreign", "timestamp": "2026-09-30T10:00:00Z",
                 "message": {"role": "assistant", "provider": "anthropic", "model": "gpt-5.6",
                             "usage": {"input": 9000, "output": 9000, "cacheRead": 0,
                                       "cacheWrite": 0, "totalTokens": 18000}}}
  pi.write_text("\n".join(json.dumps(item) for item in (pi_row, pi_row, excluded_pi)) + "\n")

  omp = home / ".omp/agent/sessions/project/omp.jsonl"
  omp.parent.mkdir(parents=True)
  omp.write_text(json.dumps({
    "type": "message", "id": "omp-priced", "timestamp": "2026-09-24T10:00:00Z",
    "message": {"role": "assistant", "provider": "openai-codex", "model": "gpt-5.4",
                "usage": {"input": 200, "output": 20, "cacheRead": 40,
                          "cacheWrite": 0, "totalTokens": 260}},
  }) + "\n")

  db = home / ".local/share/opencode/opencode.db"
  db.parent.mkdir(parents=True)
  connection = sqlite3.connect(db)
  connection.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, "
                     "time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")

  def opencode_message(identifier, provider, model, created, role="assistant", **tokens):
    data = {"role": role, "providerID": provider, "modelID": model,
            "tokens": {"input": tokens.get("input", 0), "output": tokens.get("output", 0),
                       "reasoning": tokens.get("reasoning", 0),
                       "cache": {"read": tokens.get("read", 0), "write": tokens.get("write", 0)}},
            "time": {"created": created}}
    return (identifier, "opencode-session", created, created, json.dumps(data))

  sep1 = 1788256800000
  sep30 = 1790762400000
  connection.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
    opencode_message("openai-priced", "openai", "gpt-5.2", sep1,
                     input=300, output=40, reasoning=10, read=50, write=0),
    opencode_message("openai-unknown", "openai", "future-codex-model", sep30, input=5),
    opencode_message("openai-local-excluded", "openai-local", "gpt-5.2", sep30, input=7000),
    opencode_message("anthropic-excluded", "anthropic", "gpt-5.2", sep30, input=8000),
    opencode_message("user-excluded", "openai", "gpt-5.2", sep30, role="user", input=9000),
  ])
  connection.commit()
  connection.close()


source_record = collect({"sessions/native.jsonl": [
  context(), event(at="2026-09-30T10:00:00Z", last=usage(), total=usage()),
]}, now="2026-09-30T12:00:00+02:00", extras=additional_codex_sources)
source_result = format_record(source_record, now="2026-09-30T12:00:00+02:00")
source_buckets = [bucket for day in source_record["dailyUsage"]["days"] for bucket in day["buckets"]]
check({bucket["source"] for bucket in source_buckets} == {"codex-native", "pi", "omp", "opencode"},
      "native, Pi, OMP, and exact OpenCode OpenAI usage share one Codex daily contract")
check(sum(bucket["totalTokens"] for bucket in source_buckets) == 1875
      and sum(day["messageCount"] for day in source_record["recentDays"]) == 1475,
      "source filters and per-source replay rules preserve the collector's exact token scope")
check(next(bucket for bucket in source_buckets if bucket["source"] == "pi")["tokens"]
      == {"inputTokens": 100, "outputTokens": 20, "cacheReadInputTokens": 30,
          "cacheCreationInputTokens": 10},
      "Pi cache categories remain disjoint through updater storage")
check(next(bucket for bucket in source_buckets if bucket["source"] == "opencode" and bucket["rawModel"] == "gpt-5.2")["tokens"]
      == {"inputTokens": 300, "outputTokens": 50, "cacheReadInputTokens": 50,
          "cacheCreationInputTokens": 0},
      "OpenCode reasoning and cache categories remain disjoint through updater storage")
check(row(source_result, "2026-09-30")["tokens"] == 1215
      and row(source_result, "2026-09-24")["tokens"] == 260
      and next(day for day in source_record["dailyUsage"]["days"] if day["date"] == "2026-09-01")
        ["buckets"][0]["totalTokens"] == 400
      and len(source_result["rows"]) == 7,
      "the public daily formatter keeps matching source token windows")
presentation = source_result["presentation"]
omp_tooltip = next(tooltip for item, tooltip in zip(source_result["rows"], source_result["tooltips"])
                   if item["date"] == "2026-09-24")
check(close(row(source_result, "2026-09-24")["cost"]["total"], 0.00081)
      and close(next(model for model in presentation["models"] if model["id"] == "gpt-5.2")
                ["cost"]["total"], 0.00123375)
      and "bundled fallback" in omp_tooltip and "price as of 2026-09-09" in omp_tooltip,
      "Pi/OMP and OpenCode known models use their bundled fallback tariffs")
check([model["id"] for model in presentation["models"]]
      == ["gpt-6-astra", "gpt-5.2", "gpt-5.4", "gpt-5.6"]
      and presentation["missingPriceModels"] == ["future-codex-model"],
      "the shared 30-day table includes the four heaviest models across Codex sources")
check([summary["tokens"] for summary in presentation["summaries"]] == [1215, 1475, 1875]
      and all(summary["cost"]["status"] == "partial" for summary in presentation["summaries"]),
      "Today, 7-day, and 30-day totals include hidden unknown-price source models")

manual_source_result = format_record(source_record, now="2026-09-30T12:00:00+02:00",
  override_text=json.dumps({"models": {"pi-rate": {
    "input": 1, "output": 2, "cacheRead": 0.1, "cacheWrite": 1,
  }}, "aliases": {"gpt-5.6": "pi-rate"}}))
manual_today = row(manual_source_result, "2026-09-30")
check(close(manual_today["cost"]["total"], 0.011103)
      and any(rate["origin"] == "user-override" and rate.get("alias") == "gpt-5.6"
              for rate in manual_today["cost"]["rates"]),
      "a manual alias remains authoritative for Pi usage at the public formatter")

moved_sources = format_record(source_record, now="2026-10-01T12:00:00+02:00")["presentation"]
check([summary["tokens"] for summary in moved_sources["summaries"]] == [0, 1215, 1475],
      "a clock jump shifts source-backed Today, 7-day, and 30-day windows without new usage")


def incomplete_codex_sources(home):
  pi = home / ".pi/agent/sessions/project/pi.jsonl"
  pi.parent.mkdir(parents=True)
  pi.write_text(json.dumps({
    "type": "message", "id": "pi-undated",
    "message": {"role": "assistant", "provider": "openai-codex", "model": "gpt-5.6-sol",
                "usage": {"input": 5, "output": 0, "cacheRead": 0,
                          "cacheWrite": 0, "totalTokens": 5}},
  }) + "\n")
  omp = home / ".omp/agent/sessions/project/omp.jsonl"
  omp.parent.mkdir(parents=True)
  omp.write_text(json.dumps({
    "type": "message", "id": "omp-partial", "timestamp": "2026-09-30T10:00:00Z",
    "message": {"role": "assistant", "provider": "openai-codex", "model": "gpt-5.6-sol",
                "usage": {"input": 10, "output": 2, "cacheRead": 1, "totalTokens": 13}},
  }) + "\n")

  db = home / ".local/share/opencode/opencode.db"
  db.parent.mkdir(parents=True)
  connection = sqlite3.connect(db)
  connection.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, "
                     "time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
  created = 1790762400000
  data = {"role": "assistant", "providerID": "openai", "modelID": "gpt-5.2",
          "tokens": {"input": 7, "output": 3, "cache": {"read": 2, "write": 1}},
          "time": {"created": created}}
  connection.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)",
                     ("opencode-partial", "partial-session", created, created, json.dumps(data)))
  connection.commit()
  connection.close()


incomplete_record = collect({}, now="2026-09-30T12:00:00+02:00", extras=incomplete_codex_sources)
incomplete_buckets = incomplete_record["dailyUsage"]["days"][-1]["buckets"]
check(incomplete_record["dailyUsage"]["unallocatedTokens"] == 5
      and "invalid-timestamp" in incomplete_record["dailyUsage"]["issues"]
      and all(bucket["source"] != "pi" for bucket in incomplete_buckets),
      "an undated Pi amount stays unallocated instead of becoming today's usage")
omp_partial = next(bucket for bucket in incomplete_buckets if bucket["source"] == "omp")
opencode_partial = next(bucket for bucket in incomplete_buckets if bucket["source"] == "opencode")
check(omp_partial["totalTokens"] == 13
      and omp_partial["tokens"]["cacheCreationInputTokens"] is None
      and opencode_partial["totalTokens"] is None
      and opencode_partial["tokens"]["outputTokens"] is None,
      "absent Pi/OMP and OpenCode categories remain unknown in the public record")
incomplete_result = format_record(incomplete_record, now="2026-09-30T12:00:00+02:00")
incomplete_today = row(incomplete_result, "2026-09-30")
incomplete_tooltip = next(tooltip for item, tooltip in zip(incomplete_result["rows"], incomplete_result["tooltips"])
                          if item["date"] == "2026-09-30")
check(incomplete_today["tokens"] == 26 and incomplete_today["cost"]["status"] == "partial"
      and "token count is unverified" in incomplete_tooltip,
      "known source tokens survive while missing category and time coverage stays explicit")


def special_tariff_source(home):
  pi = home / ".pi/agent/sessions/project/pi.jsonl"
  pi.parent.mkdir(parents=True)
  pi.write_text(json.dumps({
    "type": "message", "id": "pi-priority", "timestamp": "2026-09-30T10:00:00Z",
    "message": {"role": "assistant", "provider": "openai-codex", "model": "gpt-5.6-sol",
                "service_tier": "priority",
                "usage": {"input": 10, "output": 2, "cacheRead": 1,
                          "cacheWrite": 0, "totalTokens": 13}},
  }) + "\n")
  db = home / ".local/share/opencode/opencode.db"
  db.parent.mkdir(parents=True)
  connection = sqlite3.connect(db)
  connection.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, "
                     "time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
  created = 1790762400000
  data = {"role": "assistant", "providerID": "openai", "modelID": "gpt-5.2",
          "speed": "fast",
          "tokens": {"input": 7, "output": 3, "reasoning": 0,
                     "cache": {"read": 2, "write": 1}},
          "time": {"created": created}}
  connection.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)",
                     ("opencode-fast", "special-session", created, created, json.dumps(data)))
  connection.commit()
  connection.close()


tariff_record = collect({}, now="2026-09-30T12:00:00+02:00", extras=special_tariff_source)
tariff_buckets = tariff_record["dailyUsage"]["days"][-1]["buckets"]
tariff_bucket = next(bucket for bucket in tariff_buckets if bucket["source"] == "pi")
opencode_tariff_bucket = next(bucket for bucket in tariff_buckets if bucket["source"] == "opencode")
tariff_today = row(format_record(tariff_record, now="2026-09-30T12:00:00+02:00"), "2026-09-30")
check(tariff_bucket["tariff"] == {"service_tier": "priority"}
      and opencode_tariff_bucket["tariff"] == {"speed": "fast"}
      and tariff_today["tokens"] == 26 and tariff_today["cost"]["status"] == "unknown",
      "observed unsupported Pi and OpenCode tariff metadata preserves tokens without standard prices")


def pi_total_edge_sources(home):
  path = home / ".pi/agent/sessions/project/pi.jsonl"
  path.parent.mkdir(parents=True)
  rows = [
    {"type": "message", "id": "total-only", "timestamp": "2026-09-30T10:00:00Z",
     "message": {"role": "assistant", "provider": "openai-codex", "model": "gpt-5.6-sol",
                 "usage": {"totalTokens": 100}}},
    {"type": "message", "id": "contradictory", "timestamp": "2026-09-30T10:00:01Z",
     "message": {"role": "assistant", "provider": "openai-codex", "model": "gpt-5.2",
                 "usage": {"input": 40, "output": 10, "cacheRead": 0, "cacheWrite": 0,
                           "totalTokens": 100}}},
  ]
  path.write_text("\n".join(json.dumps(item) for item in rows) + "\n")


edge_record = collect({}, now="2026-09-30T12:00:00+02:00", extras=pi_total_edge_sources)
edge_buckets = edge_record["dailyUsage"]["days"][-1]["buckets"]
total_only = next(bucket for bucket in edge_buckets if bucket["rawModel"] == "gpt-5.6-sol")
contradictory = next(bucket for bucket in edge_buckets if bucket["rawModel"] == "gpt-5.2")
edge_today = row(format_record(edge_record, now="2026-09-30T12:00:00+02:00"), "2026-09-30")
check(edge_record["todayTotalTokens"] == 150 and total_only["totalTokens"] == 100
      and all(value is None for value in total_only["tokens"].values()),
      "Pi total-only fallback keeps legacy tokens without inventing zero categories")
check(contradictory["totalTokens"] == 50
      and all(value is None for value in contradictory["tokens"].values())
      and "inconsistent-total" in contradictory["issues"]
      and edge_today["tokens"] == 150 and edge_today["cost"]["status"] == "unknown",
      "contradictory Pi totals keep day scope aligned and withdraw category pricing")


def namespaced_opencode_source(home):
  db = home / ".local/share/opencode/opencode.db"
  db.parent.mkdir(parents=True)
  connection = sqlite3.connect(db)
  connection.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, "
                     "time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
  created = 1790762400000
  data = {"role": "assistant", "providerID": "openai", "modelID": "openai/gpt-5.2",
          "tokens": {"input": 100, "output": 10, "reasoning": 0,
                     "cache": {"read": 20, "write": 0}}, "time": {"created": created}}
  connection.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)",
                     ("namespaced", "model-change-session", created, created, json.dumps(data)))
  connection.commit()
  connection.close()


namespaced_record = collect({}, now="2026-09-30T12:00:00+02:00", extras=namespaced_opencode_source)
namespaced_bucket = namespaced_record["dailyUsage"]["days"][-1]["buckets"][0]
namespaced_default = row(format_record(namespaced_record, now="2026-09-30T12:00:00+02:00"), "2026-09-30")
namespaced_manual = row(format_record(namespaced_record, now="2026-09-30T12:00:00+02:00",
  override_text=json.dumps({"aliases": {"openai/gpt-5.2": "gpt-5.2"}})), "2026-09-30")
check(namespaced_bucket["rawModel"] == "openai/gpt-5.2"
      and namespaced_record["modelUsage"]["gpt-5.2"]["inputTokens"] == 100
      and namespaced_default["cost"]["status"] == "unknown",
      "OpenCode preserves literal model identity without silently pricing its namespace")
check(namespaced_manual["cost"]["status"] == "complete"
      and namespaced_manual["cost"]["rates"][0]["alias"] == "openai/gpt-5.2",
      "a manual alias can explicitly price the literal OpenCode model identity")


def pi_dst_midnight_source(home):
  path = home / ".pi/agent/sessions/project/pi.jsonl"
  path.parent.mkdir(parents=True)
  rows = [
    {"type": "message", "id": "before-midnight", "timestamp": "2026-03-28T22:59:59Z",
     "message": {"role": "assistant", "provider": "openai-codex", "model": "gpt-5.6-sol",
                 "usage": {"input": 10, "output": 0, "cacheRead": 0, "cacheWrite": 0}}},
    {"type": "message", "id": "after-midnight", "timestamp": "2026-03-28T23:00:00Z",
     "message": {"role": "assistant", "provider": "openai-codex", "model": "gpt-5.4",
                 "usage": {"input": 20, "output": 0, "cacheRead": 0, "cacheWrite": 0}}},
  ]
  path.write_text("\n".join(json.dumps(item) for item in rows) + "\n")


pi_dst_record = collect({}, now="2026-03-30T12:00:00+02:00", extras=pi_dst_midnight_source)
check(next(day for day in pi_dst_record["dailyUsage"]["days"] if day["date"] == "2026-03-28")
        ["buckets"][0]["rawModel"] == "gpt-5.6-sol"
      and next(day for day in pi_dst_record["dailyUsage"]["days"] if day["date"] == "2026-03-29")
        ["buckets"][0]["rawModel"] == "gpt-5.4",
      "Pi model changes in one session stay on either side of local midnight before DST")
