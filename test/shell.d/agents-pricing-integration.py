"""Drive native Codex fixtures through updater storage and the public QML formatter."""

import json
import math
import os
from pathlib import Path
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
process.stdout.write(JSON.stringify({
  rows,
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


def collect(sessions, now="2026-09-09T12:00:00+02:00", raw_files=None):
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
