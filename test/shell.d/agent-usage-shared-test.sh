#!/bin/bash

# The shared collector module, shell/plugins/agents/collectors.py, holds the
# parts of the collector contract every collector shares. Each collector's
# own tests cover its record end to end; this one holds the module's pieces
# to the contract directly, so a collector built on them inherits it.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command rg

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

WORK="$WORK" python3 - <<'PY'
import json
import os
import sqlite3
import sys
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.environ["OMARCHY_PATH"], "shell", "plugins", "agents"))
import collectors  # noqa: E402

work = Path(os.environ["WORK"])
home = work / "home"
home.mkdir()
os.environ["HOME"] = str(home)
os.environ["XDG_CACHE_HOME"] = str(work / "cache")
os.environ["XDG_DATA_HOME"] = str(home / ".local" / "share")
for name in ("PI_CODING_AGENT_DIR", "PI_CODING_AGENT_SESSION_DIR", "OPENCODE_DB"):
  os.environ.pop(name, None)


def check(description, condition, detail=""):
  if condition:
    print("ok - " + description)
    return
  print("not ok - " + description, file=sys.stderr)
  if detail:
    print(detail, file=sys.stderr)
  sys.exit(1)


today = datetime.now().strftime("%Y-%m-%d")
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")

# ------------------------------------------------------------- untrusted values

check("local_day reads a row with no time as today's", collectors.local_day(None) == today)
check(
  "local_day skips zero, negative, huge, NaN, boolean, and garbage times",
  [collectors.local_day(value) for value in (0, -5, 1e300, float("nan"), True, "not a date", "", [1])] == [None] * 8,
)
check(
  "local_day skips a damaged stamp dated before 2000 or after 2100",
  [collectors.local_day(value) for value in (1, 86400, "1999-12-31T12:00:00", "2102-06-01T00:00:00Z")] == [None] * 4,
)
check("local_day reads epoch milliseconds, seconds, and digit strings alike", len({
  collectors.local_day(1_700_000_000_000),
  collectors.local_day(1_700_000_000),
  collectors.local_day("1700000000000"),
}) == 1)
check(
  "token counts skip booleans, strings, NaN, negatives, and absurd values",
  [collectors.token_count(value) for value in (True, "12", float("nan"), -1, 1e300, 12)] == [0, 0, 0, 0, 0, 12],
)
check(
  "usage_tokens takes the first spelling present",
  collectors.usage_tokens({"input_tokens": 9, "input": 3}, "input", "inputTokens", "input_tokens") == 3,
)

# ------------------------------------------------------------------ time

real_time = time.time
time.time = lambda: 1_000.0009
try:
  check("stamps are floored, never rounded", collectors.now_ms() == 1_000_000)
finally:
  time.time = real_time

now = time.time()
check("the age guard takes a stamp younger than the limit", collectors.age_below(now - 5, 15))
check("the age guard refuses a stamp as old as the limit", not collectors.age_below(now - 15, 15))
check("the age guard refuses a stamp from the future", not collectors.age_below(now + 60, 15))
check("a zero limit reuses nothing", not collectors.age_below(now, 0))
check("an untrusted stamp reads as never", [collectors.stamp(value) for value in (True, "5", float("inf"), -3, 7.9)] == [0, 0, 0, 0, 7])
check(
  "the scan reuse windows are 20, 900, and 0 seconds",
  (collectors.scan_max_age(False, False), collectors.scan_max_age(False, True), collectors.scan_max_age(True, True)) == (20, 900, 0),
)

# ------------------------------------------------------------------ record

record = collectors.base_record("demo", "Demo")
check(
  "the unused-machine record is unready, with no status, limits, or balance",
  {key: record[key] for key in ("schemaVersion", "id", "name", "ready", "hasLocalStats", "hasPromptStats", "tierLabel", "usageStatusText", "authHelpText", "limits", "limitsStale", "limitsFetchedAt")}
  == {"schemaVersion": 1, "id": "demo", "name": "Demo", "ready": False, "hasLocalStats": False, "hasPromptStats": True, "tierLabel": "", "usageStatusText": "", "authHelpText": "", "limits": [], "limitsStale": False, "limitsFetchedAt": 0}
  and "balance" not in record,
  json.dumps(record),
)
check(
  "the unused-machine record carries the full, zeroed stats block",
  [day["messageCount"] for day in record["recentDays"]] == [0] * 7
  and record["recentDays"][-1]["date"] == today
  and all(record[key] in (0, {}, []) for key in ("todayPrompts", "todaySessions", "todayTotalTokens", "todayTokensByModel", "totalPrompts", "totalSessions", "activeDays", "activeDates", "modelUsage")),
  json.dumps(record),
)

stats = collectors.Stats()
stats.add(today, "s1", "m", 1, 2, 3, 4)
stats.add(today, "s1", "m", 10, 0, 0, 0)
stats.add("2000-01-01", "s2", "n", 5, 0, 0, 0)
snapshot = stats.snapshot()
check(
  "the stats accumulator turns replies into the record's stats",
  (snapshot["todayPrompts"], snapshot["todaySessions"], snapshot["todayTotalTokens"], snapshot["totalPrompts"], snapshot["totalSessions"], snapshot["activeDates"], snapshot["recentDays"][-1]["messageCount"], snapshot["todayTokensByModel"], snapshot["modelUsage"]["m"])
  == (2, 1, 20, 3, 2, ["2000-01-01", today], 20, {"m": 20}, {"inputTokens": 11, "outputTokens": 2, "cacheReadInputTokens": 3, "cacheCreationInputTokens": 4}),
  json.dumps(snapshot),
)

stats = collectors.Stats()
# A store that books a prompt apart from the tokens it spent.
stats.add_prompts(today, "s1")
stats.add(today, "s1", "m", 10, 5, 0, 0, prompts=0)
# Running totals covering three prompts, and a line with no tokens at all.
stats.add(today, "s2", "n", 4, 0, 0, 0, prompts=3)
stats.add(today, "s3", "z", 0, 0, 0, 0, prompts=0)
# A typed prompt booked on its own line, with no tokens and no model.
stats.add(today, "s4", "", 0, 0, 0, 0)
snapshot = stats.snapshot()
check(
  "prompts count apart from tokens, and tokens alone are no prompt",
  (snapshot["todayPrompts"], snapshot["totalPrompts"], snapshot["todaySessions"], snapshot["todayTotalTokens"], sorted(snapshot["modelUsage"]), snapshot["todayTokensByModel"])
  == (5, 5, 3, 19, ["m", "n"], {"m": 15, "n": 4}),
  json.dumps(snapshot),
)
stats = collectors.Stats()
stats.add(None, None, "m", 7, 0, 0, 0, prompts=0)
stats.add_prompts(None, "s1", 2)
stats.add_prompts("2000-01-01", None)
stats.add_prompts(today, "s2", 0)
snapshot = stats.snapshot()
check(
  "undated tokens with no session count toward the totals alone",
  (snapshot["modelUsage"]["m"]["inputTokens"], snapshot["todayTotalTokens"], snapshot["totalPrompts"], snapshot["todayPrompts"], snapshot["totalSessions"], snapshot["todaySessions"], snapshot["activeDates"])
  == (7, 0, 3, 0, 2, 1, ["2000-01-01", today]),
  json.dumps(snapshot),
)
from datetime import date  # noqa: E402
stats = collectors.Stats(today=date(2020, 3, 1))
stats.add("2020-03-01", None, "m", 5, 0, 0, 0, prompts=0)
stats.add("2020-02-24", None, "m", 1, 0, 0, 0, prompts=0)
snapshot = stats.snapshot()
check(
  "an injected today dates today's fields and the recent week",
  (snapshot["todayTotalTokens"], [day["date"] for day in snapshot["recentDays"]][0], snapshot["recentDays"][0]["messageCount"], snapshot["recentDays"][-1]["date"])
  == (5, "2020-02-24", 1, "2020-03-01")
  and collectors.Stats(today="2020-03-01").today == "2020-03-01",
  json.dumps(snapshot),
)

# ------------------------------------------------------------- scan cache

calls = []


def scan():
  calls.append(1)
  return {**collectors.empty_stats(), "totalPrompts": len(calls)}, True


first = collectors.cached_scan("demo", ["a"], 20, scan)
again = collectors.cached_scan("demo", ["a"], 20, scan)
forced = collectors.cached_scan("demo", ["a"], 0, scan)
check("a scan is reused within its window and rebuilt at zero", (first["totalPrompts"], again["totalPrompts"], forced["totalPrompts"]) == (1, 1, 2))
cache_file, _ = collectors.scan_cache_paths("demo", ["a"])
cached = json.loads(cache_file.read_text())
check("the scan cache records its day", cached["scanDate"] == today and cached["schemaVersion"] == 2)
cached["scanDate"] = "2000-01-01"
cache_file.write_text(json.dumps(cached))
check("a scan from another day is a miss", collectors.cached_scan("demo", ["a"], 900, scan)["totalPrompts"] == 3)
check("a scan with other options is a miss", collectors.cached_scan("demo", ["a"], 900, scan, match={"modelPrefix": "kimi"})["totalPrompts"] == 4)
check("a scan with the same options is reused", collectors.cached_scan("demo", ["a"], 900, scan, match={"modelPrefix": "kimi"})["totalPrompts"] == 4)
collectors.cached_scan("demo", ["b"], 0, lambda: ({**collectors.empty_stats(), "totalPrompts": 99}, False))
check("an incomplete scan is never cached", collectors.cached_scan("demo", ["b"], 900, scan)["totalPrompts"] == 5)
partial = collectors.cached_scan("demo", ["c"], 900, lambda: ({**collectors.empty_stats(), "totalPrompts": 7}, False), with_complete=True)
whole = collectors.cached_scan("demo", ["b"], 900, scan, with_complete=True)
check("a caller can ask whether the scan was complete, a cached one being so", partial[0]["totalPrompts"] == 7 and partial[1] is False and whole == (whole[0], True) and whole[0]["totalPrompts"] == 5)

# ------------------------------------------------------------------ limits

cache = collectors.LimitsCache("demo", "who@example.com")
check("each credential gets its own limits cache", cache.path.name.startswith("demo-limits-") and cache.path != collectors.LimitsCache("demo", "other").path)
past = (datetime.now(timezone.utc) - timedelta(hours=1)).isoformat()
future = (datetime.now(timezone.utc) + timedelta(hours=1)).isoformat()
fetched = cache.save([
  {"label": "Session", "percent": 0.8, "resetsAt": past},
  {"label": "Weekly", "percent": 0.3, "resetsAt": future},
  {"label": "Monthly", "percent": 0.5, "resetsAt": ""},
])
kept = collectors.LimitsCache("demo", "who@example.com")
check(
  "a kept window whose reset passed reads 0 with no reset; others stay as they were",
  [(entry["percent"], entry["resetsAt"]) for entry in kept.limits] == [(0.0, ""), (0.3, future), (0.5, "")],
  json.dumps(kept.limits),
)
check("a fresh answer stands in for a probe, but not past --force", kept.fresh(False) and not kept.fresh(True))
check("the stale fallback carries when the limits were measured", kept.kept() == (kept.limits, fetched))
os.utime(kept.path, (0, 0))
check("the limits cache is read whatever its file time", collectors.LimitsCache("demo", "who@example.com").fetched_at == fetched)
data = json.loads(kept.path.read_text())
data["fetchedAtMs"] = collectors.now_ms() + 60_000
kept.path.write_text(json.dumps(data))
future_stamped = collectors.LimitsCache("demo", "who@example.com")
check("a future-stamped answer is kept but never trusted as fresh", future_stamped.limits and not future_stamped.fresh(False))
check("no answer at all has nothing to fall back on", collectors.LimitsCache("demo", "nobody").kept() == ([], 0))
check("an identity holding a lone surrogate still gets its own limits cache", collectors.LimitsCache("demo", "who\udc80").path != cache.path)

credits = collectors.LimitsCache("demo", "who@example.com", kind="credits")
check(
  "another kind of answer is kept beside the limits under the same key",
  credits.path.name == cache.path.name.replace("demo-limits-", "demo-credits-", 1),
)
credits.save([], balance={"remaining": 3})
credits = collectors.LimitsCache("demo", "who@example.com", kind="credits")
check(
  "an answer without limits stands in for a probe only when the caller allows it",
  not credits.fresh(False) and credits.fresh(False, allow_empty=True) and not credits.fresh(True, allow_empty=True)
  and not credits.fresh(False, seconds=0, allow_empty=True) and credits.data["balance"] == {"remaining": 3},
)
check("no answer at all never stands in, even allowing an empty one", not collectors.LimitsCache("demo", "nobody").fresh(False, allow_empty=True))
newer = json.loads(credits.path.read_text())
newer["fetchedAtMs"] = collectors.now_ms() + 60_000
newer["balance"] = {"remaining": 9}
credits.path.write_text(json.dumps(newer))
older = collectors.LimitsCache("demo", "who@example.com", kind="credits")
kept_stamp = older.save([], only_if_newer=True, balance={"remaining": 1})
check(
  "an answer saved only if newer never rolls back one another run stamped later, but serves this run",
  json.loads(credits.path.read_text())["balance"] == {"remaining": 9} and older.data["balance"] == {"remaining": 1} and older.fetched_at == kept_stamp,
)
older.save([], balance={"remaining": 2})
check("a plain save replaces whatever was kept", json.loads(credits.path.read_text())["balance"] == {"remaining": 2})
named = collectors.LimitsCache.at(collectors.cache_root() / "demo-limits.json")
named.save([{"label": "Weekly", "percent": 0.1, "resetsAt": future}])
check(
  "a cache opened at a name of its own keeps and reads like any other",
  named.path.name == "demo-limits.json" and named.lock_path.name == "demo-limits.lock"
  and collectors.LimitsCache.at(named.path).fresh(False) and collectors.LimitsCache.at(named.path).limits == named.limits,
)

# ------------------------------------------------------------------- http

import io
import urllib.error
import urllib.request

real_urlopen = urllib.request.urlopen


def failing(error):
  def open_(request, timeout=None):
    raise error
  return open_


def outcome(opener):
  urllib.request.urlopen = opener
  try:
    return collectors.open_json(urllib.request.Request("https://example.invalid"))
  except collectors.HttpError as error:
    return (error.status, error.transport, error.invalid)
  finally:
    urllib.request.urlopen = real_urlopen


check("open_json returns the JSON answer", outcome(lambda request, timeout=None: io.BytesIO(b'{"a":1}')) == {"a": 1})
check("an HTTP status is a refusal, not a transport failure", outcome(failing(urllib.error.HTTPError("u", 401, "no", {}, None))) == (401, False, False))
check("no route, no DNS, and a timeout are transport failures", {outcome(failing(error)) for error in (urllib.error.URLError("no route"), TimeoutError("slow"), ConnectionResetError())} == {(0, True, False)})
check("a body that isn't JSON is an invalid answer", outcome(lambda request, timeout=None: io.BytesIO(b"<html>")) == (0, False, True))

import http.client  # noqa: E402


def error_of(opener):
  urllib.request.urlopen = opener
  try:
    collectors.open_json(urllib.request.Request("https://example.invalid"))
  except collectors.HttpError as error:
    return error
  finally:
    urllib.request.urlopen = real_urlopen


class CutShort(io.BytesIO):
  def read(self, *args):
    raise http.client.IncompleteRead(b'{"a"', 10)


cut = error_of(lambda request, timeout=None: CutShort())
check("a reply cut short is an answer, never a transport failure", (cut.status, cut.transport, cut.invalid, cut.cut_short) == (0, False, True, True))
garbled = error_of(failing(http.client.BadStatusLine("HTTP/9 ???")))
check("a garbled reply is an answer too", (garbled.transport, garbled.cut_short) == (False, True))
dropped = error_of(failing(http.client.RemoteDisconnected("closed")))
check("a server hanging up without a reply is a dropped connection, so transport", (dropped.transport, dropped.cut_short) == (True, False))
reset = error_of(failing(ConnectionResetError()))
check("a reset connection is transport, not a reply cut short", (reset.transport, reset.cut_short) == (True, False))
refused = error_of(failing(urllib.error.HTTPError("u", 429, "slow down", {"retry-after": "30"}, None)))
check("a refusal carries its own headers", refused.status == 429 and refused.headers.get("retry-after") == "30" and not refused.cut_short)
handlers = [handler for handler in urllib.request._opener.handlers if isinstance(handler, urllib.request.HTTPRedirectHandler)]
check("requests refuse redirects", handlers and handlers[0].redirect_request(None, None, 302, "Found", {}, "https://elsewhere") is None)

# --------------------------------------------------------- pi/omp sessions


def write_session(path, lines, header=None):
  path.parent.mkdir(parents=True, exist_ok=True)
  with path.open("w") as handle:
    if header is not None:
      handle.write(json.dumps(header) + "\n")
    for line in lines:
      handle.write(json.dumps(line) + "\n")


def reply(provider, tokens, message_id=None, timestamp=stamp, model="m", usage=None):
  line = {"type": "message", "timestamp": timestamp, "message": {"role": "assistant", "provider": provider, "model": model, "usage": usage or {"input": tokens}}}
  if message_id:
    line["id"] = message_id
  return line


sessions = home / ".pi" / "agent" / "sessions"
moved = work / "moved"
alone = work / "alone"
(home / ".omp" / "profiles" / "work").mkdir(parents=True)
(home / ".pi" / "profiles").mkdir(parents=True)
# A profile linked into the default root sits inside it, so it is dropped.
(sessions / "nested").mkdir(parents=True)
(home / ".pi" / "profiles" / "nest").symlink_to(sessions / "nested")
os.environ["PI_CODING_AGENT_DIR"] = str(moved)
os.environ["PI_CODING_AGENT_SESSION_DIR"] = str(alone)
roots = collectors.pi_session_roots()
check(
  "session roots are the defaults, each profile, and both overrides, nested ones dropped",
  roots == [
    sessions.resolve(),
    (home / ".omp" / "agent" / "sessions").resolve(),
    (home / ".omp" / "profiles" / "work" / "agent" / "sessions").resolve(),
    (moved / "sessions").resolve(),
    alone.resolve(),
  ],
  "\n".join(map(str, roots)),
)
os.environ["PI_CODING_AGENT_DIR"] = str(home / ".pi" / "agent")
check("an override that aliases a default root is read once", collectors.pi_session_roots().count(sessions.resolve()) == 1)
os.environ.pop("PI_CODING_AGENT_DIR")

parent = sessions / "p" / "parent.jsonl"
write_session(parent, [
  reply("demo", 100, "m1"),
  reply("demo", 1),
  reply("demo", 1),
  reply("other", 5000, "o1"),
  reply("demo", 7, "z", timestamp=0),
  reply("demo", 0, "t", usage={"input": 0, "totalTokens": 40}),
  reply("demo", 0, "r", usage={"input": 2, "output": 3, "reasoning": 4, "cacheRead": 5, "cache_write": 6}),
])
# The fork is read first by name, and repeats the parent's message.
write_session(sessions / "a" / "fork.jsonl", [reply("demo", 100, "m1"), reply("demo", 10, "m2")], header={"type": "session", "parentSession": str(parent)})
write_session(sessions / "a" / "copy-only.jsonl", [reply("demo", 100, "m1")], header={"type": "session", "parentSession": str(parent)})
write_session(alone / "x.jsonl", [reply("demo", 1000, "m3")])
# A $HOME that is a git checkout ignoring everything still gets read.
(home / ".git").mkdir()
(home / ".gitignore").write_text("*\n")

rows, complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"(demo|other)"', lambda provider, model, entry: provider == "demo")
by_tokens = sorted(row.input_tokens + row.output_tokens + row.cache_read + row.cache_write for row in rows)
check("a scan that read everything says so", complete)
check(
  "pi replies count once by (id, timestamp), id-less lines always, with totals, thinking, and garbage handled",
  by_tokens == [1, 1, 10, 20, 40, 100, 1000],
  json.dumps([row._asdict() for row in rows]),
)
reasoning = next(row for row in rows if row.input_tokens == 2)
check("thinking tokens count as output", (reasoning.output_tokens, reasoning.cache_read, reasoning.cache_write) == (7, 5, 6))
check("a forked message counts toward the session it was forked from", next(row for row in rows if row.input_tokens == 100).session == os.path.realpath(parent))
check("a fork that only copied its parent is no session of its own", os.path.realpath(sessions / "a" / "copy-only.jsonl") not in {row.session for row in rows})
check("the provider filter is the caller's", all(row.provider == "demo" for row in rows))

# A writer that keeps the time on the message rather than the entry: a fork's
# copy still shares the message's (id, timestamp) and counts once.
inner = work / "inner" / "sessions"
inner_stamp = int(time.time() * 1000)
inner_line = {"type": "message", "id": "k1", "message": {"role": "assistant", "provider": "demo", "model": "demo", "timestamp": inner_stamp, "usage": {"input": 77}}}
write_session(inner / "parent.jsonl", [inner_line])
write_session(inner / "fork.jsonl", [inner_line], header={"type": "session", "parentSession": str(inner / "parent.jsonl")})
inner_rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda provider, model, entry: True, roots=[inner])
check("a copy timed only on its message counts once", [row.input_tokens for row in inner_rows] == [77], json.dumps([row._asdict() for row in inner_rows]))

harness = work / "harness" / "sessions"
write_session(harness / "h.jsonl", [reply("demo", 300, "h1"), reply("demo", 100, "m1")])
own_rows, own_complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda provider, model, entry: True, roots=[harness])
check("a collector can read a pi-format tree of its own instead", own_complete and sorted(row.input_tokens for row in own_rows) == [100, 300])
(work / "alias").symlink_to(harness)
both_rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda provider, model, entry: True, roots=[*collectors.pi_session_roots(), harness, work / "alias", work / "missing"])
check(
  "roots read beside pi's count a message copied between them once, an alias once, and a missing one as nothing",
  sorted(row.input_tokens + row.output_tokens + row.cache_read + row.cache_write for row in both_rows) == [1, 1, 10, 20, 40, 100, 300, 1000],
  json.dumps([row._asdict() for row in both_rows]),
)
check("canonical roots drop an alias and a root inside another", collectors.canonical_roots([harness, work / "alias", harness / "inner", work / "harness"]) == [(work / "harness").resolve()])

# --------------------------------------------------------------- opencode

db = home / ".local" / "share" / "opencode" / "opencode.db"
db.parent.mkdir(parents=True)
now_ms = int(time.time() * 1000) - 1000
fork_ms = now_ms - 60_000


def v1(provider, tokens, created=now_ms):
  return json.dumps({"role": "assistant", "providerID": provider, "modelID": "v1-model", "tokens": tokens, "time": {"created": created}})


def v2(provider, tokens):
  return json.dumps({"model": {"providerID": provider, "id": "v2-model"}, "tokens": tokens, "time": {"created": now_ms}})


conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text, time_created integer, time_updated integer, data text)")
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text, type text, time_created integer, data text)")
conn.execute("CREATE TABLE session_v2 (id text PRIMARY KEY, fork_session_id text, time_created integer)")
conn.execute("INSERT INTO session_v2 VALUES ('ses_fork', 'ses_v2', ?)", (fork_ms,))
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  ("msg_v1", "ses_v1", now_ms, now_ms, v1("demo", {"input": 10, "output": 5, "reasoning": 2, "cache": {"read": 3, "write": 1}})),
  ("msg_both", "ses_v1", now_ms, now_ms, v1("demo", {"input": 40})),
  ("msg_zero", "ses_v1", now_ms, now_ms, v1("demo", {"input": 8000}, created=0)),
  ("msg_lookalike", "ses_v1", now_ms, now_ms, v1("demo-proxy", {"input": 9000})),
  ("msg_other", "ses_v1", now_ms, now_ms, v1("other", {"input": 9000})),
])
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?)", [
  ("msg_compact", "ses_v2", "compaction", now_ms, v2("demo", {"input": 30})),
  ("msg_both", "ses_v1", "assistant", now_ms, v2("demo", {"input": 40})),
  ("msg_copy", "ses_fork", "assistant", fork_ms - 5_000, v2("demo", {"input": 7000})),
  ("msg_forked", "ses_fork", "assistant", now_ms, v2("demo", {"input": 50})),
  ("msg_bad", "ses_v2", "assistant", now_ms, '{"model":{"providerID":"demo"'),
])
conn.commit()
conn.close()

accept_demo = lambda provider, model, entry: provider == "demo"  # noqa: E731
rows, complete = collectors.scan_opencode(["demo"], accept_demo)
check(
  "opencode rows come from both stores once each, compactions in, fork copies and untrusted times out",
  complete and sorted(row.input_tokens + row.output_tokens for row in rows) == [17, 30, 40, 50],
  json.dumps([row._asdict() for row in rows]),
)
check("the V2 store is read first", next(row for row in rows if row.input_tokens == 40).model == "v2-model")
check("opencode rows count toward their session", {row.session for row in rows} == {"opencode:ses_v1", "opencode:ses_v2", "opencode:ses_fork"})
check("a closing quote keeps a look-alike provider out of the prefilter", collectors.scan_opencode(['demo"'], lambda *_: True)[0] == collectors.scan_opencode(["demo"], accept_demo)[0])

db.rename(db.parent / "elsewhere.db")
os.environ["OPENCODE_DB"] = "elsewhere.db"
check("OPENCODE_DB names the database, a relative name beside the default", len(collectors.scan_opencode(["demo"], accept_demo)[0]) == 4)
os.environ.pop("OPENCODE_DB")
(db.parent / "elsewhere.db").rename(db.parent / "opencode-v2.db")
check("opencode-v2.db is read when opencode.db is absent", len(collectors.scan_opencode(["demo"], accept_demo)[0]) == 4)

before = (db.parent / "opencode-v2.db").read_bytes()
collectors.scan_opencode(["demo"], accept_demo)
check("the database is opened read-only", (db.parent / "opencode-v2.db").read_bytes() == before)

(db.parent / "opencode-v2.db").write_bytes(b"not a database at all, just bytes" * 200)
rows, complete = collectors.scan_opencode(["demo"], accept_demo)
check("a database error marks the scan incomplete", not complete and rows == [])

# --------------------------------------------------------------- sign-ins

import base64  # noqa: E402


def jwt(claims):
  body = base64.urlsafe_b64encode(json.dumps(claims).encode()).decode().rstrip("=")
  return f"header.{body}.signature"


later = time.time() + 3600
check("jwt_claims reads a JWT's claims", collectors.jwt_claims(jwt({"sub": "u1", "exp": later})) == {"sub": "u1", "exp": later})
check(
  "jwt_claims reads anything else as no claims",
  [collectors.jwt_claims(value) for value in ("opaque-key", "a.b", "a.!!!.c", f"h.{base64.urlsafe_b64encode(b'[1]').decode()}.s", None, 5)] == [{}] * 6,
)
check("a token keys by its subject, an opaque key by itself", (collectors.account_key(jwt({"sub": "u1"})), collectors.account_key("opaque")) == ("u1", "opaque"))
check(
  "a token lapses once its expiry passes; one with no expiry, or an opaque key, never does",
  collectors.token_lapsed(jwt({"exp": time.time() - 5})) and not collectors.token_lapsed(jwt({"exp": later})) and not collectors.token_lapsed(jwt({})) and not collectors.token_lapsed("opaque"),
)
check("finite reads only finite numbers", [collectors.finite(value) for value in (True, "2.5", float("inf"), None, "x", 3)] == [0.0, 2.5, 0.0, 0.0, 0.0, 3.0])

config = work / "config"
os.environ["XDG_CONFIG_HOME"] = str(config)
for name in ("CURSOR_API_KEY", "CURSOR_AUTH_PATH"):
  os.environ.pop(name, None)
check("no Cursor sign-in anywhere is no token", collectors.cursor_token() == "")
state_db = collectors.cursor_state_db()
state_db.parent.mkdir(parents=True)
conn = sqlite3.connect(state_db)
conn.execute("CREATE TABLE ItemTable (key TEXT, value BLOB)")
conn.execute("INSERT INTO ItemTable VALUES ('cursorAuth/accessToken', ?)", (jwt({"sub": "ide", "exp": later}).encode(),))
conn.commit()
conn.close()
check("the editor's sign-in stands when the CLI has none", collectors.account_key(collectors.cursor_token()) == "ide")
cli = config / "cursor" / "auth.json"
cli.parent.mkdir(parents=True)
cli.write_text(json.dumps({"accessToken": jwt({"sub": "cli", "exp": time.time() - 5})}))
check("a lapsed CLI sign-in gives way to the editor's", collectors.account_key(collectors.cursor_token()) == "ide")
cli.write_text(json.dumps({"accessToken": jwt({"sub": "cli", "exp": later})}))
check("the CLI's sign-in comes before the editor's", collectors.account_key(collectors.cursor_token()) == "cli")
moved_auth = work / "moved-auth.json"
moved_auth.write_text(json.dumps({"accessToken": "moved-key"}))
os.environ["CURSOR_AUTH_PATH"] = str(moved_auth)
check("CURSOR_AUTH_PATH moves the CLI's sign-in", collectors.cursor_auth_path() == moved_auth and collectors.cursor_token() == "moved-key")
check("an explicit auth path wins over CURSOR_AUTH_PATH", collectors.account_key(collectors.cursor_token(cli)) == "cli")
os.environ["CURSOR_API_KEY"] = " exported "
check("an exported key comes first", collectors.cursor_token() == "exported")
for name in ("CURSOR_API_KEY", "CURSOR_AUTH_PATH"):
  os.environ.pop(name)

# --------------------------------------------------------------- accounts

os.environ["XDG_STATE_HOME"] = str(work / "state")
registry = work / "state" / "omarchy" / "agents" / "accounts" / "demo.json"
registry.parent.mkdir(parents=True)
registry.write_text(json.dumps({"accounts": [{"id": "main", "primary": True}], "active": "main"}))
check("a registry with one account adds nothing to the record", collectors.registered_accounts("demo") == [])
check("no registry at all adds nothing either", collectors.registered_accounts("nothing") == [])
registry.write_text(json.dumps({"accounts": [{"id": "main", "primary": True}, {"id": "work", "label": "Work"}, {"label": "no id"}, "junk"], "active": "gone", "switch": "auto", "threshold": 80}))
accounts = collectors.registered_accounts("demo")
check(
  "registered accounts carry which is active (the first when the registry names none it has) and the switch settings",
  [(a["id"], a["active"], a["switch"]) for a in accounts] == [("main", True, {"mode": "auto", "threshold": 80}), ("work", False, {"mode": "auto", "threshold": 80})],
  json.dumps(accounts),
)
limits = {"limits": [{"label": "Weekly", "percent": 0.5, "resetsAt": ""}], "live": False, "fetchedAtMs": 5, "usageStatusText": "", "authHelpText": "help"}
entry = collectors.account_entry(accounts[1], limits, "", resetCredits=None)
check(
  "an account entry names the account, its limits, and the collector's own fields last",
  list(entry) == ["id", "label", "email", "plan", "active", "primary", "limits", "stale", "fetchedAt", "usageStatusText", "authHelpText", "retryAdvised", "resetCredits"]
  and (entry["label"], entry["plan"], entry["stale"], entry["fetchedAt"], entry["retryAdvised"], entry["primary"]) == ("Work", "", True, 5, False, False)
  and collectors.account_entry(dict(accounts[0], plan="Old"), dict(limits, live=True, retryAdvised=True), "Max")["plan"] == "Max"
  and collectors.account_entry(dict(accounts[0], plan="Old"), limits, "")["plan"] == "Old",
  json.dumps(entry),
)
PY
