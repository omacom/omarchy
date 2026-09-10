"""Exercise the real collector/update boundary with synthetic native usage."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(sys.argv[1])


def usage(input=1000, read=200, write=100, output=50, reasoning=20):
  return {"input_tokens": input, "cached_input_tokens": read,
          "cache_write_input_tokens": write, "output_tokens": output,
          "reasoning_output_tokens": reasoning, "total_tokens": input + output}


def context(model="gpt-6-astra", **extra):
  return {"type": "turn_context", "payload": {"model": model, **extra}}


def event(at="2026-09-09T10:00:00Z", last=None, total=None):
  return {"timestamp": at, "type": "event_msg", "payload": {"type": "token_count",
          "info": {"last_token_usage": last, "total_token_usage": total}}}


def collect(sessions, now="2026-09-09T12:00:00+02:00", extras=None, between=None, force=True):
  with tempfile.TemporaryDirectory(prefix="omarchy-codex-daily-") as temp:
    home = Path(temp)
    fake = home / "omarchy" / "bin"
    fake.mkdir(parents=True)
    # Clock and RPC are the only substitutions. Run the production CLI through
    # the actual updater and inspect the file consumed by Agent.qml.
    launcher = fake / "omarchy-agent-usage-codex"
    launcher.write_text(f'''#!/usr/bin/python3
import datetime, runpy, sys
from unittest.mock import patch
RealDateTime = datetime.datetime
class Clock(RealDateTime):
  @classmethod
  def now(cls, tz=None):
    value = RealDateTime.fromisoformat({now!r})
    return value.astimezone(tz) if tz else value.astimezone().replace(tzinfo=None)
sys.argv = [{str(ROOT / "bin/omarchy-agent-usage-codex")!r}] + {(["--force"] if force else [])!r}
with patch("datetime.datetime", Clock):
  runpy.run_path(sys.argv[0], run_name="__main__")
''')
    launcher.chmod(0o755)
    rpc = fake / "codex"
    rpc.write_text('''#!/usr/bin/python3
import sys, json
for line in sys.stdin:
  request = json.loads(line)
  print(json.dumps({"id": request["id"], "result": {}}), flush=True)
''')
    rpc.chmod(0o755)
    for name, records in sessions.items():
      path = home / ".codex" / name
      path.parent.mkdir(parents=True, exist_ok=True)
      path.write_text("\n".join(json.dumps(r) for r in records) + "\n")
    if extras:
      extras(home)
    env = {"HOME": str(home), "CODEX_HOME": str(home / ".codex"),
           "XDG_DATA_HOME": str(home / ".local/share"), "XDG_CACHE_HOME": str(home / ".cache"),
           "XDG_STATE_HOME": str(home / ".local/state"), "OMARCHY_PATH": str(fake.parent),
           "PATH": str(fake) + ":" + os.environ["PATH"], "TZ": "Europe/Berlin"}
    subprocess.run([str(ROOT / "bin/omarchy-agent-usage-update"), "codex"], env=env, check=True)
    if between:
      between(home)
      subprocess.run([str(ROOT / "bin/omarchy-agent-usage-update"), "codex"], env=env, check=True)
    return json.loads((home / ".local/state/omarchy/agents/usage/codex.json").read_text())


def check(condition, description):
  if not condition:
    raise AssertionError(description)
  print("ok - " + description)


record = collect({"sessions/native.jsonl": [context(), event(last=usage(), total=usage())]})
check(record["schemaVersion"] == 1 and record["todayTotalTokens"] == 1050,
      "Codex daily extension preserves the existing record and token total")
daily = record.get("dailyUsage", {})
check(daily.get("schemaVersion") == 1, "updater transports the versioned native daily contract")
bucket = next(day for day in daily["days"] if day["date"] == "2026-09-09")["buckets"][0]
check(bucket["rawModel"] == "gpt-6-astra" and bucket["source"] == "codex-native",
      "daily usage retains raw model and source identity")
check(bucket["tokens"] == {"inputTokens": 700, "outputTokens": 50,
                            "cacheReadInputTokens": 200, "cacheCreationInputTokens": 100},
      "daily categories are disjoint without counting cache or reasoning twice")

# Sanitized native token_count pair: cumulative accounting stays identical while
# last usage is cleared (its total_tokens is a context-sized value, not a bill).
# No transcript data, model inference, or invented token categories are involved.
meter = usage(input=14852885, read=14558464, write=0, output=82646, reasoning=49987)
request = usage(input=222487, read=215936, write=0, output=3865, reasoning=3627)
cleared = dict(usage(input=0, read=0, write=0, output=0, reasoning=0), total_tokens=20092)
measured = event(at="2026-09-09T20:39:06.325Z", last=request, total=meter)
cleared_event = event(at="2026-09-09T20:42:45.204Z", last=cleared, total=meter)
clear_meta = {"type": "session_meta", "payload": {"id": "sanitized-clear"}}
before_clear = collect({"sessions/last-cleared.jsonl": [clear_meta, context(), measured]})
after_clear = collect({"sessions/last-cleared.jsonl": [clear_meta, context(), measured, cleared_event, cleared_event]})
check(after_clear == before_clear,
      "real unchanged cumulative meter with cleared last usage preserves deduplicated totals and verified categories")

# The session's cumulative meter may be repeated (including a copied archive),
# while last_token_usage may be a growing streamed request snapshot.
meta = {"type": "session_meta", "payload": {"id": "synthetic-session"}}
first = event(last=usage(), total=usage())
progress = event(at="2026-09-09T10:00:01Z", last=usage(output=80), total=usage(output=80))
rows = [meta, context(), first, first, progress, progress]
record = collect({"sessions/live.jsonl": rows, "archived_sessions/copy.jsonl": rows})
check(record["todayTotalTokens"] == 1080,
      "repeated cumulative and streamed snapshots and an archived copy count once")
buckets = next(d for d in record["dailyUsage"]["days"] if d["date"] == "2026-09-09")["buckets"]
check(sum(b["tokens"]["outputTokens"] for b in buckets) == 80,
      "the same deduplicated output reaches both legacy and daily consumers")

missing = usage()
del missing["cache_write_input_tokens"]
record = collect({"sessions/missing.jsonl": [context(), event(last=missing, total=missing)]})
bucket = record["dailyUsage"]["days"][-1]["buckets"][0]
check(bucket["tokens"]["cacheCreationInputTokens"] is None
      and bucket["tokens"]["inputTokens"] is None
      and bucket["tokens"]["outputTokens"] == 50,
      "unverified cache amounts remain unknown without discarding known output")
check(not record["dailyUsage"]["complete"] and bucket["totalTokens"] == 1050,
      "partial category coverage retains the independently recorded token total")
record = collect({"sessions/bad-time.jsonl": [context(), event(at="not-a-date", last=usage(), total=usage())]})
check(record["todayTotalTokens"] == 0 and record["dailyUsage"]["unallocatedTokens"] == 1050,
      "invalid timestamps never invent today's usage or lose the undated token total")
check("invalid-timestamp" in record["dailyUsage"]["issues"],
      "undated native usage makes calendar coverage explicitly incomplete")
record = collect({"sessions/days.jsonl": [
  context(), event(at="2026-09-08T21:59:59Z", last=usage(), total=usage()),
  context("gpt-5.6-sol", service_tier="priority"),
  event(at="2026-09-08T22:00:00Z", last=usage(input=100, read=0, write=0, output=10),
        total=usage(input=1100, read=200, write=100, output=60))]})
check(record["dailyUsage"]["days"][-2]["buckets"][0]["rawModel"] == "gpt-6-astra"
      and record["dailyUsage"]["days"][-1]["buckets"][0]["rawModel"] == "gpt-5.6-sol",
      "events on either side of local midnight retain their own day and raw model")
check(record["dailyUsage"]["days"][-1]["buckets"][0]["tariff"]["service_tier"] == "priority",
      "observed tariff attributes survive collection without assuming their price")


def pi_source(home):
  path = home / ".pi/agent/sessions/project/pi.jsonl"
  path.parent.mkdir(parents=True)
  path.write_text(json.dumps({"type": "message", "id": "pi-fixture", "timestamp": "2026-09-09T10:00:00Z",
    "message": {"role": "assistant", "provider": "openai-codex", "model": "gpt-6-astra",
                "usage": {"input": 100, "output": 5, "cacheRead": 0, "cacheWrite": 0}}}) + "\n")


record = collect({"sessions/native.jsonl": [context(), event(last=usage(), total=usage())]}, extras=pi_source)
check(record["todayTotalTokens"] == 1155,
      "adding the native contract preserves existing pi token accounting")
check(not record["dailyUsage"]["complete"]
      and any(b["source"] == "legacy" and "source-not-covered" in b["issues"]
              for b in record["dailyUsage"]["days"][-1]["buckets"]),
      "sources reserved for later tickets are explicitly unpriced instead of complete zero")

# Stale file mtimes cannot decide the event's calendar day.
def old_mtime(home):
  os.utime(home / ".codex/sessions/native.jsonl", (1, 1))
record = collect({"sessions/native.jsonl": [context(), event(last=usage(), total=usage())]}, extras=old_mtime)
check(record["todayTotalTokens"] == 1050 and len(record["dailyUsage"]["days"]) == 30,
      "native dated usage survives an old file mtime in an extensible calendar window")

record = collect({"sessions/dst.jsonl": [context(),
  event(at="2026-03-28T23:30:00Z", last=usage(), total=usage()),
  event(at="2026-03-29T22:30:00Z", last=usage(), total=usage(input=2000, read=400, write=200, output=100))]},
  now="2026-03-30T12:00:00+02:00")
check(record["dailyUsage"]["days"][-2]["date"] == "2026-03-29"
      and record["dailyUsage"]["days"][-2]["buckets"][0]["totalTokens"] == 1050
      and record["dailyUsage"]["days"][-1]["buckets"][0]["totalTokens"] == 1050,
      "a 23-hour DST day and the following local day stay distinct")

record = collect({"sessions/gap.jsonl": [context(), event(last=usage(), total=usage(input=3000, read=600, write=300, output=150))]})
check(record["todayTotalTokens"] == 1050 and record["dailyUsage"]["unallocatedTokens"] == 2100
      and "unattributed-cumulative-usage" in record["dailyUsage"]["issues"],
      "an initial cumulative history is not silently attributed to the latest day or model")
record = collect({"sessions/cumulative-only.jsonl": [context(), event(total=usage())]})
check(record["todayTotalTokens"] == 0 and record["dailyUsage"]["unallocatedTokens"] == 1050
      and not record["dailyUsage"]["complete"],
      "a first cumulative-only meter remains undated rather than a fabricated request")
record = collect({"sessions/reset.jsonl": [context(), first,
  event(at="2026-09-09T10:00:01Z", last=usage(input=500), total=usage(input=500)),
  event(at="2026-09-09T10:00:02Z", last=usage(), total=usage())]})
check(record["todayTotalTokens"] == 1050 and "cumulative-reset" in record["dailyUsage"]["issues"],
      "a regressing meter and its replay never duplicate the previous high-water mark")

record = collect({"sessions/last-only.jsonl": [context(), event(last=usage()),
  context("gpt-5.6-sol"), event(last=usage())]})
check(record["todayTotalTokens"] == 2100 and not record["dailyUsage"]["complete"],
      "last-only events do not collapse different models and disclose unverified event identity")
for bad in (True, "200", -1, 0.5):
  invalid = usage(read=bad)
  record = collect({"sessions/invalid.jsonl": [context(), event(last=invalid, total=invalid)]})
  bucket = record["dailyUsage"]["days"][-1]["buckets"][0]
  check(bucket["tokens"]["cacheReadInputTokens"] is None and not record["dailyUsage"]["complete"],
        "non-integer, negative, string and boolean quantities are never validated as measured tokens: " + repr(bad))

request = usage(input=100, read=0, write=0, output=10)
request["service_tier"] = "fast"
record = collect({"sessions/request-tier.jsonl": [context(), first,
  event(at="2026-09-09T10:00:01Z", last=request, total=usage(input=1100, read=200, write=100, output=60))]})
check(record["dailyUsage"]["days"][-1]["buckets"][-1]["tariff"].get("service_tier") == "fast",
      "request-level tariff evidence survives cumulative differencing")

record = collect({"sessions/no-model.jsonl": [event(last=usage(), total=usage())]})
bucket = record["dailyUsage"]["days"][-1]["buckets"][0]
check(bucket["rawModel"] is None and "missing-model" in bucket["issues"]
      and not record["dailyUsage"]["complete"] and record["todayTotalTokens"] == 1050,
      "missing native model identity stays unknown while legacy tokens survive")

meter1 = usage()
meter2 = usage(input=1100, read=200, write=100, output=60)
for meter in (meter1, meter2):
  del meter["cached_input_tokens"]
  del meter["cache_write_input_tokens"]
record = collect({"sessions/request-cache.jsonl": [context(), event(last=usage(), total=meter1),
  event(at="2026-09-09T10:00:01Z", last=usage(input=100, read=20, write=10, output=10), total=meter2)]})
buckets = record["dailyUsage"]["days"][-1]["buckets"]
check(record["dailyUsage"]["complete"] and buckets[-1]["tokens"] == {
  "inputTokens": 70, "outputTokens": 10, "cacheReadInputTokens": 20, "cacheCreationInputTokens": 10}
  and record["todayTotalTokens"] == 1160,
  "request cache fields cover a whole measured increment when the cumulative cache meter is absent")

second = event(at="2026-09-09T10:00:01Z", last=usage(input=100, read=20, write=10, output=10),
               total=usage(input=1100, read=220, write=110, output=60))
for sessions in (
  {"archived_sessions/a-later.jsonl": [meta, context("gpt-5.6-sol"), second],
   "sessions/z-earlier.jsonl": [meta, context(), first, context("gpt-5.6-sol"), second]},
  {"sessions/reordered.jsonl": [meta, context("gpt-5.6-sol"), second, context(), first]},
):
  record = collect(sessions)
  buckets = record["dailyUsage"]["days"][-1]["buckets"]
  check(record["todayTotalTokens"] == 1160 and record["dailyUsage"]["unallocatedTokens"] == 0
        and record["dailyUsage"]["complete"] and len(buckets) == 2
        and buckets[0]["rawModel"] == "gpt-6-astra" and buckets[1]["rawModel"] == "gpt-5.6-sol",
        "chronological session accounting is independent of overlapping file and record order")

for corrected in (usage(read=300), usage(read=100), usage(input=990, output=60)):
  record = collect({"sessions/correction.jsonl": [context(), first,
    event(at="2026-09-09T10:00:01Z", last=corrected, total=corrected)]})
  buckets = record["dailyUsage"]["days"][-1]["buckets"]
  check(record["todayTotalTokens"] == 1050 and sum(b["totalTokens"] for b in buckets) == 1050
        and len(buckets) == 1 and "cumulative-correction" in record["dailyUsage"]["issues"]
        and all(value is None for value in buckets[0]["tokens"].values()),
        "a constant-total correction never creates consumption or keeps an unproven historical split")
reasoning_update = dict(missing, reasoning_output_tokens=40)
record = collect({"sessions/reasoning-only.jsonl": [context(), event(last=missing, total=missing),
  event(at="2026-09-09T10:00:01Z", last=reasoning_update, total=reasoning_update)]})
check(record["todayTotalTokens"] == 1050 and record["todayPrompts"] == 1
      and len(record["dailyUsage"]["days"][-1]["buckets"]) == 1,
      "reasoning-only updates with missing cache fields add neither tokens nor empty usage buckets")

# Storage failures are exercised with real temporary filesystem objects.
def broken_native_root(home):
  path = home / ".codex/sessions"
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("not a directory")
record = collect({}, extras=broken_native_root)
check(not record["dailyUsage"]["complete"] and "native-read-error" in record["dailyUsage"]["issues"],
      "a failed native directory scan cannot claim complete zero usage")

def corrupt_native(home):
  path = home / ".codex/sessions/broken.jsonl"
  path.write_bytes(b'{broken json\n' + json.dumps(event(last=usage(), total=usage())).encode() + b'\n')
record = collect({"sessions/broken.jsonl": [context()]}, extras=corrupt_native)
check("invalid-native-record" in record["dailyUsage"]["issues"] and record["todayTotalTokens"] == 1050,
      "native JSON parse failures disclose incomplete coverage while later valid usage survives")

def broken_pi_root(home):
  path = home / ".pi/agent/sessions"
  path.mkdir(parents=True)
  path.chmod(0)
record = collect({}, extras=broken_pi_root)
check(not record["dailyUsage"]["complete"] and "source-scan-incomplete" in record["dailyUsage"]["issues"],
      "an unreadable existing pi source cannot be cached as complete zero usage")


def change_source_and_cache(mutate):
  def between(home):
    path = home / ".codex/sessions/cache.jsonl"
    with path.open("a") as stream:
      stream.write(json.dumps(second) + "\n")
    cache = next((home / ".cache/omarchy/agent-usage").glob("codex-scan-*.json"))
    data = json.loads(cache.read_text())
    mutate(data)
    cache.write_text(json.dumps(data))
  return between


record = collect({"sessions/cache.jsonl": [context(), first]}, force=False,
                 between=change_source_and_cache(lambda data: None))
check(record["todayTotalTokens"] == 1050,
      "a fresh valid scan cache is reused through the updater without force")

for label, mutate in (
  ("boolean envelope version", lambda d: d.update(schemaVersion=True)),
  ("old collector envelope", lambda d: d.pop("collectorRevision", None)),
  ("unsupported envelope version", lambda d: d.update(schemaVersion=2)),
  ("boolean collector revision", lambda d: d.update(collectorRevision=True)),
  ("boolean daily version", lambda d: d["stats"]["dailyUsage"].update(schemaVersion=True)),
  ("future daily version", lambda d: d["stats"]["dailyUsage"].update(schemaVersion=2)),
  ("wrong token unit", lambda d: d["stats"]["dailyUsage"].update(unit="messages")),
  ("invalid bucket shape", lambda d: d["stats"]["dailyUsage"]["days"][-1].update(buckets="bad")),
  ("invalid category type", lambda d: d["stats"]["dailyUsage"]["days"][-1]["buckets"][0]["tokens"].update(outputTokens=True)),
  ("inconsistent complete flag", lambda d: d["stats"]["dailyUsage"]["days"][-1]["buckets"][0]["tokens"].update(inputTokens=None)),
  ("inconsistent total", lambda d: d["stats"]["dailyUsage"]["days"][-1]["buckets"][0].update(totalTokens=1)),
  ("missing calendar day", lambda d: d["stats"]["dailyUsage"]["days"].pop(0)),
  ("future scan date", lambda d: d.update(scanDate="2099-01-01")),
  ("negative unallocated", lambda d: d["stats"]["dailyUsage"].update(unallocatedTokens=-1)),
  ("invalid legacy shape", lambda d: d["stats"].update(todayTotalTokens="1050")),
  ("foreign record metadata", lambda d: d["stats"].update(schemaVersion=99)),
):
  record = collect({"sessions/cache.jsonl": [context(), first]}, force=False,
                   between=change_source_and_cache(mutate))
  check(record["todayTotalTokens"] == 1160 and record["dailyUsage"]["complete"],
        "corrupt or unsupported cache is rescanned rather than published: " + label)

record = collect({"sessions/cache-appears.jsonl": [context(), event(last=usage(), total=meter1),
  event(at="2026-09-09T10:00:01Z", last=usage(input=100, read=20, write=10, output=10),
        total=usage(input=1100, read=220, write=110, output=60))]})
check(record["dailyUsage"]["complete"] and record["dailyUsage"]["days"][-1]["buckets"][-1]["tokens"]["cacheReadInputTokens"] == 20,
      "a request covers cache deltas whose previous cumulative fields were absent")

for broken in (
  b'{broken json\n', b'\xff\xfe\n',
  b'{"type":"event_msg","payload":[]}\n',
  b'{"type":"event_msg","payload":{"type":"token_count","info":[]}}\n',
  b'{"type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":[]}}}\n',
):
  def corrupt(home):
    (home / ".codex/sessions/corrupt.jsonl").write_bytes(broken)
  def repair(home):
    (home / ".codex/sessions/corrupt.jsonl").unlink()
    with (home / ".codex/sessions/native.jsonl").open("a") as stream:
      stream.write(json.dumps(second) + "\n")
  record = collect({"sessions/native.jsonl": [context(), first]}, extras=corrupt, between=repair, force=False)
  check(record["todayTotalTokens"] == 1160 and record["dailyUsage"]["complete"],
        "a parse/read failure is retried after repair instead of reusing incomplete cached data: " + repr(broken))

# A failed directory scan must also recover immediately, not wait for cache TTL.
def deny_native(home):
  (home / ".codex/sessions").chmod(0)
def allow_native(home):
  (home / ".codex/sessions").chmod(0o700)
record = collect({"sessions/native.jsonl": [context(), first]}, extras=deny_native, between=allow_native, force=False)
check(record["todayTotalTokens"] == 1050 and record["dailyUsage"]["complete"],
      "an unreadable native subtree is rescanned immediately after permissions recover")

def bad_pi(home):
  path = home / ".pi/agent/sessions/p.jsonl"
  path.parent.mkdir(parents=True)
  path.write_text('{"provider":"openai-codex",broken}\n')
def fix_pi(home):
  (home / ".pi/agent/sessions/p.jsonl").unlink()
  with (home / ".codex/sessions/native.jsonl").open("a") as stream:
    stream.write(json.dumps(second) + "\n")
record = collect({"sessions/native.jsonl": [context(), first]}, extras=bad_pi, between=fix_pi, force=False)
check(record["todayTotalTokens"] == 1160 and record["dailyUsage"]["complete"],
      "a malformed matched pi record cannot suppress recovery through a cached scan")

partial_input = usage()
del partial_input["input_tokens"]
del partial_input["total_tokens"]
record = collect({"sessions/partial-input.jsonl": [context(), event(last=partial_input)]})
bucket = record["dailyUsage"]["days"][-1]["buckets"][0]
check(record["todayTotalTokens"] == 350 and bucket["totalTokens"] is None
      and bucket["tokens"]["inputTokens"] is None and bucket["tokens"]["outputTokens"] == 50
      and not record["dailyUsage"]["complete"],
      "independently known categories survive in both numeric legacy and partial daily usage")

oversized = usage(read=2000)
del oversized["cache_write_input_tokens"]
record = collect({"sessions/oversized-cache.jsonl": [context(), event(last=oversized, total=oversized)]})
bucket = record["dailyUsage"]["days"][-1]["buckets"][0]
check(bucket["tokens"]["cacheReadInputTokens"] is None and record["todayTotalTokens"] == 1050
      and record["modelUsage"]["gpt-6-astra"]["inputTokens"] == 1000,
      "a partial cache split cannot exceed measured input or create negative legacy categories")
