#!/bin/bash

# The shared collector module, shell/plugins/agents/collectors.py, holds the
# parts of the collector contract every collector shares. This test holds the
# module's pieces to the contract directly, so a collector built on them
# inherits it, and a collector's own test covers only its own sources,
# credentials, and answer.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command rg

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

WORK="$WORK" python3 - <<'PY'
import contextlib
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


# "today" is held to the day this run began, so one that straddles local
# midnight still dates its rows, stats and scans by one day.
sys.path.insert(0, os.path.join(os.environ["ROOT"], "test", "shell.d"))
from agent_usage_fixtures import fixture_now, freeze_today  # noqa: E402

freeze_today()
today = collectors.today()
stamp = fixture_now().isoformat(timespec="milliseconds").replace("+00:00", "Z")

# ------------------------------------------------------------- untrusted values

check("local_day reads a row with no time as today's", collectors.local_day(None) == today)
check(
  "local_day skips zero, negative, huge, NaN, boolean, and garbage times",
  [collectors.local_day(value) for value in (0, -5, 1e300, float("nan"), True, "not a date", "", [1])] == [None] * 8,
)
check(
  "local_day keeps the last half second of a day on that day, in seconds and milliseconds",
  (lambda midnight: [collectors.local_day(midnight - 0.4), collectors.local_day((midnight - 0.4) * 1000)]
   == [(datetime.fromtimestamp(midnight) - timedelta(days=1)).strftime("%Y-%m-%d")] * 2)(
    datetime.combine(datetime.now().date(), datetime.min.time()).timestamp()),
)
check(
  "local_day skips a damaged stamp dated before 2000 or after 2100",
  [collectors.local_day(value) for value in (1, 86400, "1999-12-31T12:00:00", "2102-06-01T00:00:00Z")] == [None] * 4,
)
check(
  "local_day skips digit strings that aren't a time: other scripts' digits and thousands of digits",
  [collectors.local_day(value) for value in ("\u0661\u0667\u0660\u0660\u0660\u0660\u0660\u0660\u0660\u0660", "9" * 5000)] == [None] * 2,
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

# ------------------------------------------------------------------- files

# Collectors overlap in practice: the update command backgrounds one per agent
# while the panel refreshes on its own. Writers aiming at one cache file must
# all land, not trip over a shared temp path.
import threading  # noqa: E402

race = work / "race" / "cache.json"
race.parent.mkdir()
failures = []
barrier = threading.Barrier(8)


def hammer(writer):
  barrier.wait()
  for round_ in range(25):
    try:
      collectors.write_json(race, {"writer": writer, "round": round_})
    except Exception as error:
      failures.append(repr(error))


writers = [threading.Thread(target=hammer, args=(writer,)) for writer in range(8)]
for thread in writers:
  thread.start()
for thread in writers:
  thread.join()
check(
  "concurrent writers to one file all land, leaving one intact file and no temp files",
  not failures and isinstance(json.loads(race.read_text()).get("writer"), int) and [path.name for path in race.parent.iterdir()] == ["cache.json"],
  json.dumps({"failures": failures[:3], "files": sorted(path.name for path in race.parent.iterdir())}),
)
check("written files stay readable to others", race.stat().st_mode & 0o777 == 0o644, oct(race.stat().st_mode))

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

# A scan is rebuilt under its lock, so a run that starts while another scans
# waits for it, then takes its result rather than reading every source again.
import subprocess  # noqa: E402

HOLDER = '''
import json, os, sys, time, fcntl
fd = os.open(sys.argv[1], os.O_WRONLY | os.O_CREAT, 0o600)
fcntl.flock(fd, fcntl.LOCK_EX)
print("locked", flush=True)
time.sleep(1.0)
envelope = json.loads(sys.argv[3])
envelope["scannedAtMs"] = int(time.time() * 1000)
with open(sys.argv[2], "w") as handle:
  json.dump(envelope, handle)
'''
locked_cache, locked_lock = collectors.scan_cache_paths("demo", ["locked"])
envelope = {"schemaVersion": collectors.SCAN_CACHE_VERSION, "scanDate": today, "stats": {**collectors.empty_stats(), "totalPrompts": 42}}
holder = subprocess.Popen([sys.executable, "-c", HOLDER, str(locked_lock), str(locked_cache), json.dumps(envelope)], stdout=subprocess.PIPE, text=True)
holder.stdout.readline()
scans_before = len(calls)
started = time.time()
waited_for = collectors.cached_scan("demo", ["locked"], 20, scan)
waited = time.time() - started
holder.wait()
check(
  "a run that starts during a scan waits on its lock, then takes that scan rather than scanning again",
  waited >= 0.8 and waited_for["totalPrompts"] == 42 and len(calls) == scans_before,
  f"waited {waited:.2f}s, got {waited_for['totalPrompts']}, scanned {len(calls) - scans_before} more times",
)

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
interval = collectors.LimitsCache("demo", "interval")
interval.save([{"label": "Weekly", "percent": 0.1, "resetsAt": future}])
aged = json.loads(interval.path.read_text())
aged["fetchedAtMs"] = collectors.now_ms() - 14_000
interval.path.write_text(json.dumps(aged))
young = collectors.LimitsCache("demo", "interval").fresh(False)
aged["fetchedAtMs"] = collectors.now_ms() - 16_000
interval.path.write_text(json.dumps(aged))
check(
  "an answer stands in for a probe for 15 seconds",
  collectors.PROBE_MIN_INTERVAL_SECONDS == 15 and young and not collectors.LimitsCache("demo", "interval").fresh(False),
)
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
ahead = json.loads(credits.path.read_text())
ahead["fetchedAtMs"] = collectors.now_ms() + 3_600_000
credits.path.write_text(json.dumps(ahead))
older.save([], only_if_newer=True, balance={"remaining": 3})
check(
  "a stamp an hour ahead, from before the clock went back, is replaced by an answer saved only if newer",
  json.loads(credits.path.read_text())["balance"] == {"remaining": 3},
)
named = collectors.LimitsCache.at(collectors.cache_root() / "demo-limits.json")
named.save([{"label": "Weekly", "percent": 0.1, "resetsAt": future}])
check(
  "a cache opened at a name of its own keeps and reads like any other",
  named.path.name == "demo-limits.json" and named.lock_path.name == "demo-limits.lock"
  and collectors.LimitsCache.at(named.path).fresh(False) and collectors.LimitsCache.at(named.path).limits == named.limits,
)

import io  # noqa: E402

printed = io.StringIO()
with contextlib.redirect_stdout(printed):
  collectors.emit({"balance": {"remaining": float("inf"), "spent": [float("nan"), 1.5]}, "ready": True})
check(
  "emit prints a number that overflowed as 0, so the record stays JSON the panel can parse",
  json.loads(printed.getvalue()) == {"balance": {"remaining": 0, "spent": [0, 1.5]}, "ready": True},
  printed.getvalue(),
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
check("a body nested deeper than the parser goes is an invalid answer", outcome(lambda request, timeout=None: io.BytesIO(b"[" * 200_000)) == (0, False, True))

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
# Over a real socket: a server that stops short of its Content-Length and
# hangs up hands a sized read only what arrived, which is cut short, not an
# invalid answer.
import socket  # noqa: E402


def short_server():
  listener = socket.socket()
  listener.bind(("127.0.0.1", 0))
  listener.listen(1)

  def serve():
    conn, _ = listener.accept()
    with conn:
      conn.recv(65536)
      conn.sendall(b'HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: 100\r\n\r\n{"a": 1, "b"')
    listener.close()

  threading.Thread(target=serve, daemon=True).start()
  return f"http://127.0.0.1:{listener.getsockname()[1]}/"


os.environ["no_proxy"] = "*"
try:
  collectors.open_json(urllib.request.Request(short_server()), timeout=5)
  short = None
except collectors.HttpError as error:
  short = error
check("a body short of its Content-Length over a socket is cut short", short is not None and (short.transport, short.invalid, short.cut_short) == (False, True, True), repr(short and vars(short)))


def drip_server(status=b"200 OK"):
  listener = socket.socket()
  listener.bind(("127.0.0.1", 0))
  listener.listen(1)

  def serve():
    conn, _ = listener.accept()
    with conn:
      conn.recv(65536)
      conn.sendall(b'HTTP/1.1 ' + status + b'\r\nContent-Type: application/json\r\nContent-Length: 1000\r\n\r\n')
      with contextlib.suppress(OSError):
        for _ in range(100):
          conn.sendall(b" ")
          time.sleep(0.1)
    listener.close()

  threading.Thread(target=serve, daemon=True).start()
  return f"http://127.0.0.1:{listener.getsockname()[1]}/"


began = time.monotonic()
try:
  collectors.open_json(urllib.request.Request(drip_server()), timeout=0.3)
  dripped = None
except collectors.HttpError as error:
  dripped = error
check(
  "a reply dripping a byte at a time runs out of time as one cut short instead of holding the collector",
  dripped is not None and dripped.cut_short and not dripped.transport and time.monotonic() - began < 5,
  repr(dripped and vars(dripped)),
)
began = time.monotonic()
try:
  collectors.open_json(urllib.request.Request(drip_server(b"500 Internal Server Error")), timeout=0.3)
  dripped = None
except collectors.HttpError as error:
  dripped = error
check(
  "an error reply dripping its body still answers with its status by the deadline",
  dripped is not None and dripped.status == 500 and time.monotonic() - began < 5,
  repr(dripped and vars(dripped)),
)
bad_key = urllib.request.Request("https://example.invalid", headers={"Authorization": "Bearer sk-secret\nX: y"})
urllib.request.urlopen = real_urlopen
try:
  collectors.open_json(bad_key)
  header = None
except collectors.HttpError as error:
  header = error
check(
  "a key http.client won't send is an invalid answer that doesn't quote the key",
  header is not None and header.invalid and header.__cause__ is None and header.__suppress_context__ and "sk-secret" not in str(header),
  repr(header),
)
check(
  "a credential goes over HTTPS, or plain HTTP to loopback, and never to a URL with credentials in it",
  [collectors.trusted_endpoint(url) for url in ("https://example.com/x", "http://127.0.0.1:9/x", "http://localhost/x", "http://[::1]:9/x",
                                                "http://example.com/x", "ftp://example.com", "https://u:p@example.com", "http://[bad", "")]
  == [True, True, True, True, False, False, False, False, False],
)
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

# pi's SettingsManager.getSessionDir() reads `sessionDir` from the agent
# tree's settings.json, expanding a leading ~, and new sessions go there.
(home / ".pi" / "agent").mkdir(parents=True, exist_ok=True)
(home / ".pi" / "agent" / "settings.json").write_text(json.dumps({"sessionDir": "~/pi-sessions"}))
(home / ".omp" / "profiles" / "work" / "agent").mkdir(parents=True, exist_ok=True)
(home / ".omp" / "profiles" / "work" / "agent" / "settings.json").write_text(json.dumps({"sessionDir": "relative/sessions"}))
roots = collectors.pi_session_roots()
check(
  "a settings.json sessionDir is read as a root, a relative one skipped",
  (home / "pi-sessions").resolve() in roots and not any(root.name == "sessions" and root.parent.name == "relative" for root in roots),
  "\n".join(map(str, roots)),
)
(home / ".pi" / "agent" / "settings.json").unlink()
(home / ".omp" / "profiles" / "work" / "agent" / "settings.json").unlink()

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
  by_tokens == [1, 1, 10, 16, 40, 100, 1000],
  json.dumps([row._asdict() for row in rows]),
)
reasoning = next(row for row in rows if row.input_tokens == 2)
check("thinking is already in output and never added again", (reasoning.output_tokens, reasoning.cache_read, reasoning.cache_write) == (3, 5, 6))
# As pi 1.4.0 and omp 18.12.6 wrote them for a reply the server billed as 54
# and 84 completion tokens, 7 and 37 of them reasoning: totalTokens leaves the
# thinking out because output already holds it.
thinking = work / "thinking" / "sessions"
write_session(thinking / "pi.jsonl", [reply("demo", 0, "pi1", usage={"input": 1401, "output": 54, "cacheRead": 74, "cacheWrite": 0, "reasoning": 7, "totalTokens": 1529})])
write_session(thinking / "omp.jsonl", [reply("demo", 0, "omp1", usage={"input": 4401, "output": 84, "cacheRead": 104, "cacheWrite": 0, "totalTokens": 4589, "reasoningTokens": 37})])
thinking_rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda provider, model, entry: True, roots=[thinking])
check(
  "pi's and omp's output already holds their thinking",
  sorted((row.output_tokens, row.input_tokens + row.output_tokens + row.cache_read) for row in thinking_rows) == [(54, 1529), (84, 4589)],
  json.dumps([row._asdict() for row in thinking_rows]),
)
# pi 1.4.0 counts a compaction's and a branch summary's usage, a usage entry
# (cache warming), and a tool's nested model work in the session's totals.
# Only the usage entry names its provider; the rest ran on the session's
# model, the last switch or reply before them, as pi wrote this compaction.
summaries = work / "summaries" / "sessions"
pi_switch = {"type": "model_change", "id": "mc1", "timestamp": stamp, "provider": "demo", "modelId": "demo-model"}
compaction = {"type": "compaction", "id": "c1", "parentId": "x", "timestamp": stamp, "summary": "Mock reply 210.", "firstKeptEntryId": "x", "tokensBefore": 44000,
              "usage": {"input": 44102, "output": 521, "cacheRead": 561, "cacheWrite": 0, "reasoning": 427, "totalTokens": 45184}, "fromHook": False}
write_session(summaries / "pi.jsonl", [
  pi_switch,
  compaction,
  {"type": "usage", "id": "u1", "timestamp": stamp, "kind": "cache_warm", "provider": "demo", "model": "warm-model", "usage": {"input": 0, "output": 0, "cacheRead": 500, "cacheWrite": 0, "totalTokens": 500}},
  {"type": "usage", "id": "u2", "timestamp": stamp, "kind": "cache_warm", "provider": "other", "model": "warm-model", "usage": {"input": 9000}},
  {"type": "message", "id": "t1", "timestamp": stamp, "message": {"role": "toolResult", "toolCallId": "call_1", "toolName": "agent", "content": [], "usage": {"input": 30, "output": 3}, "isError": False}},
  {"type": "message", "id": "o1", "timestamp": stamp, "message": {"role": "assistant", "provider": "other", "model": "o", "usage": {"input": 9000}}},
  {**compaction, "id": "c2", "usage": {"input": 9000}},
])
# omp names the model as provider/model; a branch summary after it bills it,
# one before any switch or reply bills nobody this reader can name.
write_session(summaries / "omp.jsonl", [
  {"type": "branch_summary", "id": "b0", "timestamp": stamp, "fromId": "x", "summary": "s", "usage": {"input": 9000}},
  {"type": "model_change", "id": "mc2", "timestamp": stamp, "model": "demo/omp-model"},
  {"type": "branch_summary", "id": "b1", "timestamp": stamp, "fromId": "x", "summary": "s", "usage": {"input": 70, "output": 7}},
])
summary_rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"(demo|other)"', lambda provider, model, entry: provider == "demo", roots=[summaries])
check(
  "summaries, usage entries, and nested tool usage count under the model the session was on, answering no prompt",
  sorted((row.model, row.input_tokens + row.output_tokens + row.cache_read, row.prompts) for row in summary_rows)
  == [("demo-model", 33, 0), ("demo-model", 45184, 0), ("omp-model", 77, 0), ("warm-model", 500, 0)],
  json.dumps([row._asdict() for row in summary_rows]),
)
# A prompt is a typed user message, booked on the first reply answering it,
# as pi 1.4.0 wrote one that called a tool: the step after the tool result
# answers no new prompt. omp marks the user messages it writes itself (a
# handoff) as the agent's, and a prompt another provider answered is not
# this one's.
turns = work / "turns" / "sessions"
write_session(turns / "pi.jsonl", [
  {"type": "model_change", "id": "mc", "timestamp": stamp, "provider": "demo", "modelId": "m"},
  {"type": "message", "id": "sys", "timestamp": stamp, "message": {"role": "system", "content": "", "timestamp": 1}},
  {"type": "message", "id": "u1", "timestamp": stamp, "message": {"role": "user", "content": [{"type": "text", "text": "Use the tool"}], "timestamp": 1}},
  reply("demo", 0, "step1", usage={"input": 21401, "output": 47, "cacheRead": 274, "cacheWrite": 0, "totalTokens": 21722}),
  {"type": "message", "id": "tr", "timestamp": stamp, "message": {"role": "toolResult", "toolCallId": "call_1", "toolName": "bash", "content": [{"type": "text", "text": "ok"}], "isError": False}},
  reply("demo", 0, "step2", usage={"input": 21501, "output": 47, "cacheRead": 275, "cacheWrite": 0, "totalTokens": 21823}),
  {"type": "message", "id": "u2", "timestamp": stamp, "message": {"role": "user", "content": "Ask the other one", "timestamp": 2}},
  reply("other", 0, "o1", usage={"input": 9000}),
  {"type": "message", "id": "u3", "timestamp": stamp, "message": {"role": "user", "content": [{"type": "text", "text": "handoff"}], "attribution": "agent"}},
  reply("demo", 0, "step3", usage={"input": 5}),
])
turn_rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"(demo|other)"', lambda provider, model, entry: provider == "demo", roots=[turns])
check(
  "a typed prompt books on its first reply, not on a tool step, a handoff, or another provider's reply",
  sorted((row.input_tokens, row.prompts) for row in turn_rows) == [(5, 0), (21401, 1), (21501, 0)],
  json.dumps([row._asdict() for row in turn_rows]),
)
check("a session without user messages keeps a prompt per reply", all(row.prompts == 1 for row in thinking_rows))
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

# A header naming a FIFO is no parent to read: opening one would hang.
import signal  # noqa: E402

piped = work / "piped" / "sessions"
fifo = work / "piped" / "parent.fifo"
fifo.parent.mkdir(parents=True)
os.mkfifo(fifo)
piped_line = {"type": "message", "id": "q1", "timestamp": inner_stamp, "message": {"role": "assistant", "provider": "demo", "model": "demo", "usage": {"input": 5}}}
write_session(piped / "one.jsonl", [piped_line], header={"type": "session", "parentSession": str(fifo)})
write_session(piped / "two.jsonl", [piped_line])


# Not an OSError, which the reader would swallow as an unreadable header.
class Hung(BaseException):
  pass


def hung(*_):
  raise Hung()


signal.signal(signal.SIGALRM, hung)
signal.alarm(5)
try:
  piped_rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda provider, model, entry: True, roots=[piped])
except Hung:
  piped_rows = None
signal.alarm(0)
check("a parentSession naming a FIFO is never opened", piped_rows is not None and [row.input_tokens for row in piped_rows] == [5])

harness = work / "harness" / "sessions"
write_session(harness / "h.jsonl", [reply("demo", 300, "h1"), reply("demo", 100, "m1")])
own_rows, own_complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda provider, model, entry: True, roots=[harness])
check("a collector can read a pi-format tree of its own instead", own_complete and sorted(row.input_tokens for row in own_rows) == [100, 300])
(work / "alias").symlink_to(harness)
both_rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda provider, model, entry: provider == "demo", roots=[*collectors.pi_session_roots(), harness, work / "alias", work / "missing"])
check(
  "roots read beside pi's count a message copied between them once, an alias once, and a missing one as nothing",
  sorted(row.input_tokens + row.output_tokens + row.cache_read + row.cache_write for row in both_rows) == [1, 1, 10, 16, 40, 100, 300, 1000],
  json.dumps([row._asdict() for row in both_rows]),
)
check("canonical roots drop an alias and a root inside another", collectors.canonical_roots([harness, work / "alias", harness / "inner", work / "harness"]) == [(work / "harness").resolve()])

# A scan that couldn't read every session says so, and cached_scan above keeps
# such a scan out of the cache.
pattern = r'"provider"\s*:\s*"(demo|other)"'
real_path = os.environ["PATH"]
os.environ["PATH"] = str(work / "no-bin")
try:
  # The warning it prints is the collector's to show, not this test's.
  with contextlib.redirect_stderr(io.StringIO()):
    rows, complete = collectors.scan_pi_sessions(pattern, lambda provider, model, entry: provider == "demo")
finally:
  os.environ["PATH"] = real_path
check("without rg the sessions can't be read, and the scan says it is incomplete", rows == [] and not complete)
if os.geteuid() != 0:
  # rg still prints the matches it could read, and only its exit status tells.
  locked = sessions / "p" / "locked.jsonl"
  write_session(locked, [reply("demo", 5000, "locked")])
  locked.chmod(0)
  try:
    rows, complete = collectors.scan_pi_sessions(pattern, lambda provider, model, entry: provider == "demo")
  finally:
    locked.chmod(0o600)
    locked.unlink()
  check(
    "a session rg couldn't read makes the scan incomplete, the readable ones still counted",
    not complete and sorted(row.input_tokens + row.output_tokens + row.cache_read + row.cache_write for row in rows) == by_tokens,
    json.dumps([row._asdict() for row in rows]),
  )

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

# opencode keeps its database open while it runs, so its newest rows sit in
# the write-ahead log; a read-only open still sees them.
wal_db = work / "wal" / "opencode.db"
wal_db.parent.mkdir()
WAL_WRITER = '''
import os, sqlite3, sys
conn = sqlite3.connect(sys.argv[1])
conn.execute("PRAGMA journal_mode=WAL")
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text, time_created integer, time_updated integer, data text)")
conn.execute("INSERT INTO message VALUES ('msg_wal', 'ses_wal', 0, 0, ?)", (sys.argv[2],))
conn.commit()
# Killed with the connection open, so the rows stay in the log.
os.kill(os.getpid(), 9)
'''
subprocess.run([sys.executable, "-c", WAL_WRITER, str(wal_db), v1("demo", {"input": 61})])
os.environ["OPENCODE_DB"] = str(wal_db)
wal_before = (wal_db.parent / "opencode.db-wal").is_file()
rows, complete = collectors.scan_opencode(["demo"], accept_demo)
check("a database left open with its rows in the write-ahead log still reads", wal_before and complete and [row.input_tokens for row in rows] == [61],
      json.dumps({"wal": wal_before, "rows": [row._asdict() for row in rows]}))

# A fresh V2 install has no `message` table at all, and some builds keep the
# provider and model at the top level of a session_message row, with the role
# in its type column. Either way the store reads on its own.
v2_only = work / "v2-only.db"
conn = sqlite3.connect(v2_only)
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL,"
             " seq integer NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")


def flat(provider, tokens):
  return json.dumps({"providerID": provider, "modelID": "flat-model", "tokens": {"input": tokens}, "time": {"created": now_ms}})


conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, 1, ?, ?, ?)", [
  ("flat_reply", "ses_a", "assistant", now_ms, now_ms, flat("demo", 5)),
  ("flat_prompt", "ses_a", "user", now_ms, now_ms, flat("demo", 900)),
  ("flat_other", "ses_a", "assistant", now_ms, now_ms, flat("other", 900)),
  ("nested_reply", "ses_b", "assistant", now_ms, now_ms, v2("demo", {"input": 7})),
  ("broken", "ses_b", "assistant", now_ms, now_ms, "not json"),
])
conn.commit()
conn.close()
os.environ["OPENCODE_DB"] = str(v2_only)
rows, complete = collectors.scan_opencode(["demo"], accept_demo)
os.environ.pop("OPENCODE_DB")
check(
  "a database with only the V2 store reads on its own, flat rows and nested alike",
  complete and sorted((row.session, row.model, row.input_tokens) for row in rows) == [("opencode:ses_a", "flat-model", 5), ("opencode:ses_b", "v2-model", 7)],
  json.dumps([row._asdict() for row in rows]),
)

# A prompt is a typed user message, so of the steps answering one, as
# opencode 1.19.3 writes them (the same parentID), the first books it. A
# compaction's summary answers the marker opencode adds, and a subagent's
# session holds the model's prompts, not typed ones. V2 keeps a prompt as a
# `user` row without a model, booked on the first reply after it.
turns_db = work / "turns.db"
conn = sqlite3.connect(turns_db)
conn.execute("CREATE TABLE session (id text PRIMARY KEY, parent_id text, time_created integer NOT NULL)")
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL,"
             " seq integer NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.executemany("INSERT INTO session VALUES (?, ?, ?)", [("ses_tool", None, fork_ms), ("ses_task", "ses_tool", fork_ms)])


def step(parent, input_tokens, created, **extra):
  return json.dumps({"parentID": parent, "role": "assistant", "mode": "build", "agent": "build", "cost": 0, "modelID": "oc-tooltest", "providerID": "demo",
                     "tokens": {"total": input_tokens, "input": input_tokens, "output": 0, "reasoning": 0, "cache": {"write": 0, "read": 0}},
                     "time": {"created": created, "completed": created + 1}, **extra})


conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  ("msg_u1", "ses_tool", now_ms, now_ms, json.dumps({"role": "user", "time": {"created": now_ms}, "agent": "build", "model": {"providerID": "demo", "modelID": "oc-tooltest"}})),
  ("msg_a2", "ses_tool", now_ms + 2, now_ms + 2, step("msg_u1", 21501, now_ms + 2, finish="stop")),
  ("msg_a1", "ses_tool", now_ms + 1, now_ms + 1, step("msg_u1", 21401, now_ms + 1, finish="tool-calls")),
  ("msg_u2", "ses_tool", now_ms + 3, now_ms + 3, json.dumps({"role": "user", "time": {"created": now_ms + 3}, "model": {"providerID": "demo", "modelID": "oc-tooltest"}})),
  ("msg_c1", "ses_tool", now_ms + 4, now_ms + 4, step("msg_u2", 23153, now_ms + 4, mode="compaction", agent="compaction", summary=True)),
  ("msg_t1", "ses_task", now_ms + 5, now_ms + 5, step("msg_tu", 300, now_ms + 5)),
])
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?, ?, ?)", [
  ("v2_u1", "ses_v2", "user", 1, now_ms, now_ms, json.dumps({"text": "hi", "time": {"created": now_ms}})),
  ("v2_a1", "ses_v2", "assistant", 2, now_ms, now_ms, v2("demo", {"input": 11})),
  ("v2_a2", "ses_v2", "assistant", 3, now_ms, now_ms, v2("demo", {"input": 12})),
  ("v2_c1", "ses_v2", "compaction", 4, now_ms, now_ms, v2("demo", {"input": 13})),
  ("v2_lone", "ses_v2_lone", "assistant", 1, now_ms, now_ms, v2("demo", {"input": 14})),
])
conn.commit()
conn.close()
os.environ["OPENCODE_DB"] = str(turns_db)
rows, complete = collectors.scan_opencode(["demo"], accept_demo)
os.environ.pop("OPENCODE_DB")
check(
  "an opencode prompt books on its first step, never on a later one, a compaction, or a subagent's",
  complete and sorted((row.input_tokens, row.prompts) for row in rows) == [(11, 1), (12, 0), (13, 0), (14, 1), (300, 0), (21401, 1), (21501, 0), (23153, 0)],
  json.dumps([row._asdict() for row in rows]),
)

# One prompt answered by steps from two providers, as a tool loop that
# switches models writes it, books once: on the first step, under the
# collector that takes it, in both stores.
switch_db = work / "switch.db"
conn = sqlite3.connect(switch_db)
conn.execute("CREATE TABLE session (id text PRIMARY KEY, parent_id text, time_created integer NOT NULL)")
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL,"
             " seq integer NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.execute("INSERT INTO session VALUES ('ses_switch', NULL, ?)", (fork_ms,))
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  ("msg_su", "ses_switch", now_ms, now_ms, json.dumps({"role": "user", "time": {"created": now_ms}, "agent": "build", "model": {"providerID": "anthropic", "modelID": "claude-sonnet-4-5"}})),
  ("msg_sb", "ses_switch", now_ms + 2, now_ms + 2, json.dumps(json.loads(step("msg_su", 600, now_ms + 2, finish="stop")) | {"providerID": "openrouter", "modelID": "z-ai/glm-4.6"})),
  ("msg_sa", "ses_switch", now_ms + 1, now_ms + 1, json.dumps(json.loads(step("msg_su", 500, now_ms + 1, finish="tool-calls")) | {"providerID": "anthropic", "modelID": "claude-sonnet-4-5"})),
])
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?, ?, ?)", [
  ("v2_su", "ses_switch_v2", "user", 1, now_ms, now_ms, json.dumps({"text": "hi", "time": {"created": now_ms}})),
  ("v2_sa", "ses_switch_v2", "assistant", 2, now_ms, now_ms, v2("anthropic", {"input": 700})),
  ("v2_sb", "ses_switch_v2", "assistant", 3, now_ms, now_ms, v2("openrouter", {"input": 800})),
])
conn.commit()
conn.close()
os.environ["OPENCODE_DB"] = str(switch_db)
by_provider = {
  provider: sorted((row.input_tokens, row.prompts) for row in collectors.scan_opencode([provider], lambda p, m, e, provider=provider: p == provider)[0])
  for provider in ("anthropic", "openrouter")
}
os.environ.pop("OPENCODE_DB")
check(
  "a prompt answered by two providers' steps books once, on the first step's collector",
  by_provider == {"anthropic": [(500, 1), (700, 1)], "openrouter": [(600, 0), (800, 0)]},
  json.dumps(by_provider),
)

# A typed prompt no step answered, its request refused as opencode 1.19.3
# records one (an assistant row with an APIError and no tokens), books
# itself without tokens on the model its user row names, so a session
# holding only that still counts. In V2 it books on the failed reply after
# it, and a message migrated into both stores books once. A compaction's
# marker, a subagent's prompt, a fork's copy and an untrusted time book none,
# and so does a prompt opencode 1.19.3 refused before sending it (an unknown
# model or provider): it writes the user row alone, with no step at all.
failed_db = work / "failed.db"
conn = sqlite3.connect(failed_db)
conn.execute("CREATE TABLE session (id text PRIMARY KEY, parent_id text, time_created integer NOT NULL)")
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL,"
             " seq integer NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.executemany("INSERT INTO session VALUES (?, ?, ?)", [("ses_fail", None, fork_ms), ("ses_only", None, fork_ms), ("ses_kid", "ses_fail", fork_ms), ("ses_copy", None, now_ms + 50), ("ses_unsent", None, fork_ms)])


def asked(created, provider="demo", **extra):
  return json.dumps({"role": "user", "time": {"created": created}, "agent": "build", "model": {"providerID": provider, "modelID": "oc-failoc"}, "summary": {"diffs": []}, **extra})


def refused(parent, created, **extra):
  return json.dumps(json.loads(step(parent, 0, created)) | {"error": {"name": "APIError", "data": {"message": "refused", "statusCode": 400}}, **extra})


conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  # Refused, then `-c` and answered.
  ("msg_fu1", "ses_fail", now_ms, now_ms, asked(now_ms)),
  ("msg_fa1", "ses_fail", now_ms + 1, now_ms + 1, refused("msg_fu1", now_ms + 1)),
  ("msg_fu2", "ses_fail", now_ms + 2, now_ms + 2, asked(now_ms + 2)),
  ("msg_fa2", "ses_fail", now_ms + 3, now_ms + 3, step("msg_fu2", 900, now_ms + 3, finish="stop")),
  # A compaction that failed answers its marker all the same.
  ("msg_fu3", "ses_fail", now_ms + 4, now_ms + 4, asked(now_ms + 4)),
  ("msg_fc3", "ses_fail", now_ms + 5, now_ms + 5, refused("msg_fu3", now_ms + 5, mode="compaction", agent="compaction", summary=True)),
  # A session holding only a refused prompt, and one never sent.
  ("msg_ou1", "ses_only", now_ms, now_ms, asked(now_ms)),
  ("msg_oa1", "ses_only", now_ms + 1, now_ms + 1, refused("msg_ou1", now_ms + 1)),
  ("msg_ou2", "ses_only", now_ms + 2, now_ms + 2, asked(now_ms + 2)),
  # A session holding only a prompt never sent, as `opencode run -m` on an
  # unknown model leaves it (no `summary` yet).
  ("msg_nu1", "ses_unsent", now_ms, now_ms, json.dumps({k: v for k, v in json.loads(asked(now_ms)).items() if k != "summary"})),
  # Another provider's, a subagent's, a fork's copy, and an untrusted time.
  ("msg_xu1", "ses_only", now_ms + 3, now_ms + 3, asked(now_ms + 3, provider="other")),
  ("msg_ku1", "ses_kid", now_ms, now_ms, asked(now_ms)),
  ("msg_cu1", "ses_copy", now_ms, now_ms, asked(now_ms)),
  ("msg_zu1", "ses_only", now_ms, now_ms, asked(0)),
  # Migrated into V2 below under the same ids.
  ("v2_mu", "ses_moved", now_ms, now_ms, asked(now_ms)),
  ("v2_ma", "ses_moved", now_ms + 1, now_ms + 1, refused("v2_mu", now_ms + 1)),
])
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?, ?, ?)", [
  ("v2_mu", "ses_moved", "user", 1, now_ms, now_ms, json.dumps({"text": "hi", "time": {"created": now_ms}})),
  ("v2_ma", "ses_moved", "assistant", 2, now_ms, now_ms, v2("demo", {"input": 0})),
  ("v2_fu", "ses_v2_fail", "user", 1, now_ms, now_ms, json.dumps({"text": "hi", "time": {"created": now_ms}})),
  ("v2_fa", "ses_v2_fail", "assistant", 2, now_ms, now_ms, v2("demo", {"input": 0})),
])
conn.commit()
conn.close()
os.environ["OPENCODE_DB"] = str(failed_db)
rows, complete = collectors.scan_opencode(["demo"], accept_demo)
os.environ.pop("OPENCODE_DB")
booked = sorted((row.session, row.input_tokens, row.prompts) for row in rows if row.prompts or row.input_tokens)
check(
  "an opencode prompt no step answered books once, on its user row's model, its session with it, and one never sent nowhere",
  complete and booked == [("opencode:ses_fail", 0, 1), ("opencode:ses_fail", 900, 1), ("opencode:ses_moved", 0, 1), ("opencode:ses_only", 0, 1), ("opencode:ses_v2_fail", 0, 1)],
  json.dumps([row._asdict() for row in rows]),
)

# pi and omp write a refused request as a reply with its provider and no
# usage (pi 1.4.0's stopReason "error"), so the prompt books there, without
# tokens; one no reply came for at all books on the model switch before it.
failed_root = work / "failed-pi"
failed_root.mkdir()
failed_stamp = datetime.fromtimestamp(now_ms / 1000, timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
zero_usage = {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "totalTokens": 0}


def pi_reply(n, provider, usage):
  return {"type": "message", "id": f"a{n}", "timestamp": failed_stamp, "message": {"role": "assistant", "provider": provider, "model": "e2e-failpi", "usage": usage,
                                                                           "stopReason": "error" if usage is zero_usage else "stop"}}


def pi_user(n):
  return {"type": "message", "id": f"u{n}", "timestamp": failed_stamp, "message": {"role": "user", "content": [{"type": "text", "text": "go"}]}}


(failed_root / "failed.jsonl").write_text("".join(json.dumps(line) + "\n" for line in [
  {"type": "model_change", "id": "m1", "timestamp": failed_stamp, "provider": "demo", "modelId": "e2e-failpi"},
  pi_user(1), pi_reply(1, "other", zero_usage),
  pi_user(2), pi_reply(2, "demo", zero_usage),
  pi_user(3), pi_reply(3, "other", {"input": 40, "output": 1}),
  {"type": "model_change", "id": "m2", "timestamp": failed_stamp, "provider": "demo", "modelId": "e2e-failpi"},
  pi_user(4),
]))
by_provider = {
  provider: sorted((row.input_tokens, row.prompts) for row in collectors.scan_pi_sessions(r'"provider"\s*:\s*"' + provider + '"', lambda p, m, e, provider=provider: p == provider, [failed_root])[0])
  for provider in ("demo", "other")
}
check(
  "a pi prompt no reply answered books on the refused reply, else on the model switch, once",
  by_provider == {"demo": [(0, 1), (0, 1)], "other": [(0, 1), (40, 1)]},
  json.dumps(by_provider),
)

# A damaged step the reader rejects (a boolean token count, an untrusted
# time) is never an opencode prompt's first step, so the valid step after it
# with the same parentID still books the prompt.
damaged_db = work / "damaged.db"
conn = sqlite3.connect(damaged_db)
conn.execute("CREATE TABLE session (id text PRIMARY KEY, parent_id text, time_created integer NOT NULL)")
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
# ses_when has no session row, so no fork time bounds its steps.
conn.execute("INSERT INTO session VALUES ('ses_bool', NULL, ?)", (fork_ms,))
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  ("msg_bu", "ses_bool", now_ms, now_ms, asked(now_ms)),
  ("msg_b1", "ses_bool", now_ms + 1, now_ms + 1, json.dumps(json.loads(step("msg_bu", 0, now_ms + 1, finish="tool-calls")) | {"tokens": {"input": True, "output": 0}})),
  ("msg_b2", "ses_bool", now_ms + 2, now_ms + 2, step("msg_bu", 610, now_ms + 2, finish="stop")),
  ("msg_wu", "ses_when", now_ms, now_ms, asked(now_ms)),
  ("msg_w1", "ses_when", now_ms + 1, now_ms + 1, json.dumps(json.loads(step("msg_wu", 50, now_ms + 1, finish="tool-calls")) | {"time": {"created": True}})),
  ("msg_w2", "ses_when", now_ms + 2, now_ms + 2, step("msg_wu", 620, now_ms + 2, finish="stop")),
])
conn.commit()
conn.close()
os.environ["OPENCODE_DB"] = str(damaged_db)
rows, complete = collectors.scan_opencode(["demo"], accept_demo)
os.environ.pop("OPENCODE_DB")
check(
  "a step the reader rejects never takes an opencode prompt from the valid step after it",
  complete and sorted((row.input_tokens, row.prompts) for row in rows) == [(610, 1), (620, 1)],
  json.dumps([row._asdict() for row in rows]),
)

# A prompt left unanswered in a pi session (its request failed) and answered
# in a fork that copied it, as pi 1.4.0 and omp 18.12.6 copy a message with
# its id and timestamp, is one prompt, counted once.
retried_root = work / "retried-pi"
retried_root.mkdir()
retried = [{"type": "model_change", "id": "m1", "timestamp": failed_stamp, "provider": "demo", "modelId": "e2e-failpi"}, pi_user(1), pi_reply(1, "demo", zero_usage)]
write_session(retried_root / "parent.jsonl", retried, header={"type": "session", "version": 3, "id": "s-parent", "timestamp": failed_stamp})
write_session(retried_root / "fork.jsonl", retried + [pi_reply(2, "demo", {"input": 40, "output": 1})],
              header={"type": "session", "version": 3, "id": "s-fork", "timestamp": failed_stamp, "parentSession": str(retried_root / "parent.jsonl")})
rows, complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda *_: True, [retried_root])
check(
  "a pi prompt unanswered in its session and answered in a fork counts once",
  complete and sum(row.prompts for row in rows) == 1 and sum(row.input_tokens for row in rows) == 40,
  json.dumps([row._asdict() for row in rows]),
)

# A V2 prompt whose request failed books on its own user row's day, not the
# failed reply's, and one typed at an untrusted time counts nowhere.
late_db = work / "late.db"
yesterday_ms = now_ms - 86_400_000
conn = sqlite3.connect(late_db)
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL,"
             " seq integer NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?, ?, ?)", [
  ("v2_lu", "ses_v2_late", "user", 1, yesterday_ms, yesterday_ms, json.dumps({"text": "hi", "time": {"created": yesterday_ms}})),
  ("v2_la", "ses_v2_late", "assistant", 2, now_ms, now_ms, v2("demo", {"input": 0})),
  ("v2_zu", "ses_v2_untimed", "user", 1, now_ms, now_ms, json.dumps({"text": "hi", "time": {"created": 0}})),
  ("v2_za", "ses_v2_untimed", "assistant", 2, now_ms, now_ms, v2("demo", {"input": 0})),
])
conn.commit()
conn.close()
os.environ["OPENCODE_DB"] = str(late_db)
rows, complete = collectors.scan_opencode(["demo"], accept_demo)
os.environ.pop("OPENCODE_DB")
check(
  "a V2 prompt whose request failed books on the day it was typed, an untrusted one nowhere",
  complete and sorted((row.session, row.day, row.prompts) for row in rows if row.prompts) == [("opencode:ses_v2_late", collectors.local_day(yesterday_ms), 1)],
  json.dumps([row._asdict() for row in rows]),
)

# ------------------------------------------------------------- endpoints

# A base URL's host says who bills what it serves: a provider's own host or
# a subdomain of it, the user's own hardware, or nothing that can be placed.
for url, owner in (
  ("https://api.z.ai/api/anthropic", "zai"),
  ("https://open.bigmodel.cn/api/anthropic", "zai"),
  ("https://ollama.com", "ollama"),
  ("https://api.minimax.io/anthropic", "minimax"),
  ("https://api.minimaxi.com/anthropic", "minimax"),
  ("https://api.deepseek.com/anthropic", "deepseek"),
  ("https://api.kimi.com/coding/", "kimi"),
  ("https://api.moonshot.ai/anthropic", "kimi"),
  ("https://openrouter.ai/api", "openrouter"),
  ("https://eu.openrouter.ai/api", "openrouter"),
  ("http://localhost:11434", "local"),
  ("http://127.0.0.1:4000", "local"),
  ("http://192.168.1.20:8080/v1", "local"),
  ("http://gpu-box:11434", "local"),
  ("http://studio.lan:1234/v1", "local"),
  ("https://llm-proxy.example.com/anthropic", ""),
  ("https://notapi.z.ai.example.com", ""),
  ("", ""),
  ("http://[::1", ""),
):
  check(f"the endpoint {url!r} is billed by {owner or 'nobody here'}", collectors.endpoint_owner(url) == owner, collectors.endpoint_owner(url))

# Claude Code's replies, by the model that answered and where Claude Code is
# sent: the one rule every collector reading its transcripts applies.
CLAUDE_CODE_OWNERS = {
  "": {"claude-sonnet-4-5": "claude", None: "claude", "glm-4.6": "zai", "GLM-4.5-Air": "zai", "glm-4.6:cloud": "ollama",
       "gpt-oss:120b-cloud": "ollama", "MiniMax-M2": "minimax", "deepseek-chat": "deepseek", "kimi-k2-0905": "kimi",
       "moonshot-v1-8k": "kimi", "qwen3-coder": None, "<synthetic>": None},
  "https://api.anthropic.com": {"claude-sonnet-4-5": "claude", "glm-4.6": "zai"},
  "https://api.z.ai/api/anthropic": {"claude-sonnet-4-5": "zai", None: "zai", "glm-4.6": "zai", "glm-4.6:cloud": "zai"},
  "https://ollama.com": {"claude-sonnet-4-5": "ollama", "kimi-k2.7-code:cloud": "ollama", "glm-4.6": "ollama"},
  "https://openrouter.ai/api": {"claude-sonnet-4-5": "openrouter", "anthropic/claude-sonnet-4.5": "openrouter", None: "openrouter"},
  "https://api.minimax.io/anthropic": {"MiniMax-M2": "minimax", "claude-sonnet-4-5": "minimax"},
  "https://api.deepseek.com/anthropic": {"deepseek-chat": "deepseek"},
  "https://api.kimi.com/coding/": {"kimi-for-coding": "kimi", "claude-sonnet-4-5": "kimi"},
  "http://localhost:11434": {"qwen3-coder": "local", "glm-4.6": "local", "deepseek-r1:8b": "local", "glm-4.6:cloud": "ollama",
                             "claude-sonnet-4-5": "claude", None: "claude"},
  "https://llm-proxy.example.com/anthropic": {"claude-sonnet-4-5": "claude", None: "claude", "glm-4.6": None, "qwen3-coder": None,
                                              "gpt-oss:120b-cloud": "ollama"},
}
for url, models in CLAUDE_CODE_OWNERS.items():
  got = {model: collectors.claude_code_owner(model, url) for model in models}
  check(f"Claude Code replies sent to {url or 'Anthropic'} go to the collector that bills them", got == models, json.dumps({str(k): v for k, v in got.items()}))

# The shared transcript reader hands each owner its replies once, typed
# prompts apart from them, and the sessions in use; Stats books a row with no
# tokens as its prompts alone.
claude_home = home / "claude-code"
transcripts = claude_home / "projects" / "demo"
transcripts.mkdir(parents=True)


def claude_reply(message_id, model, input_tokens, session="s1"):
  return {"type": "assistant", "timestamp": stamp, "sessionId": session, "requestId": "r-" + message_id,
          "message": {"id": message_id, "role": "assistant", "model": model, "usage": {"input_tokens": input_tokens, "output_tokens": 1}}}


def claude_prompt(uuid, session="s1"):
  return {"type": "user", "uuid": uuid, "timestamp": stamp, "sessionId": session, "message": {"role": "user", "content": "hi"}}


lines = [claude_prompt("p1"), claude_reply("m1", "claude-sonnet-4-5", 100), claude_prompt("p2"), claude_reply("m2", "glm-4.6", 200),
         claude_reply("m3", "glm-4.6", 300)]
(transcripts / "s1.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))
# A fork copies the GLM reply into a session of its own: counted once.
(transcripts / "s2.jsonl").write_text(json.dumps({**claude_reply("m3", "glm-4.6", 300), "sessionId": "s2"}) + "\n")
by_owner = {}
for owner in ("claude", "zai", "ollama"):
  owned = collectors.Stats()
  for row in collectors.scan_claude_code(owner, claude_home / "projects", None, ""):
    owned.add_row(row, row.model)
  by_owner[owner] = owned.snapshot()
check(
  "the Claude Code reader splits replies and prompts between their owners, a copied reply once",
  [(by_owner[o]["todayTotalTokens"], by_owner[o]["todayPrompts"], by_owner[o]["todaySessions"]) for o in ("claude", "zai", "ollama")]
  == [(101, 1, 1), (502, 1, 2), (0, 0, 0)],
  json.dumps(by_owner),
)
check(
  "a scan of Claude Code is matched to the kind of endpoint it was made under, never the URL itself",
  collectors.claude_code_endpoint("https://user:secret@llm-proxy.example.com") == "other"
  and collectors.claude_code_endpoint("https://api.anthropic.com") == ""
  and collectors.claude_code_endpoint("http://127.0.0.1:4000") == "local",
)

# MiniMax Code's routes: its own are MiniMax's, a custom provider its
# config.yaml baseURL's (read without a YAML library: block mappings, quoted
# and commented scalars), and one it no longer declares nobody's.
mcode_home = home / "mcode"
mcode_home.mkdir()
(mcode_home / "config.yaml").write_text("""# written by mcode
defaultModel: custom_provider:router/glm
custom_provider:
  router:
    models:
      - glm
    options:
      apiKey: "sk: placeholder"
      baseURL: 'https://openrouter.ai/api/v1' # preset
  box:
    options:
      baseURL: http://127.0.0.1:8080/v1
  bare: {}
""")
routes = collectors.mcode_routes(mcode_home)
check("MiniMax Code's custom providers are read from config.yaml by their baseURL's owner",
      routes == {"router": "openrouter", "box": "local", "bare": ""}, json.dumps(routes))
check("a MiniMax Code reply goes to its route's owner",
      [collectors.mcode_route_owner(provider, routes) for provider in (None, "minimax_oauth", "custom_provider:router", "custom_provider:box", "custom_provider:bare", "custom_provider:gone", "zai")]
      == ["minimax", "minimax", "openrouter", "local", None, None, None])

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
for name in ("CURSOR_API_KEY", "CURSOR_AUTH_PATH", "CURSOR_AUTH_TOKEN"):
  os.environ.pop(name, None)
check("no Cursor sign-in anywhere is no token", collectors.cursor_token() == "")
state_db = collectors.cursor_state_db()
state_db.parent.mkdir(parents=True)
conn = sqlite3.connect(state_db)
conn.execute("CREATE TABLE ItemTable (key TEXT, value BLOB)")
conn.execute("INSERT INTO ItemTable VALUES ('cursorAuth/accessToken', ?)", (jwt({"sub": "ide", "exp": later}).encode(),))
conn.commit()
conn.close()
state_db_bytes = state_db.read_bytes()
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
check("an exported API key is never sent as a bearer, and with no token traded for it there is none",
      collectors.cursor_token() == "")
moved_auth.write_text(json.dumps({"accessToken": "traded-token", "apiKey": "exported"}))
check("an exported API key stands for the token the CLI traded it for", collectors.cursor_token() == "traded-token")
moved_auth.write_text(json.dumps({"accessToken": "traded-token", "apiKey": "another-key"}))
check("a token traded for another key never stands for this one", collectors.cursor_token() == "")
os.environ["CURSOR_AUTH_TOKEN"] = " direct "
check("CURSOR_AUTH_TOKEN is a bearer as it stands, ahead of everything", collectors.cursor_token() == "direct")
os.environ.pop("CURSOR_AUTH_TOKEN")
check(
  "the editor's database is read without touching it",
  state_db.read_bytes() == state_db_bytes and sorted(path.name for path in state_db.parent.iterdir()) == ["state.vscdb"],
  json.dumps(sorted(path.name for path in state_db.parent.iterdir())),
)
for name in ("CURSOR_API_KEY", "CURSOR_AUTH_PATH"):
  os.environ.pop(name)

deep_header = work / "deep-header.jsonl"
deep_header.write_text("[" * 200_000 + "\n")
check("a session header nested deeper than the parser goes names no parent instead of stopping the scan",
      collectors.pi_parent_session(str(deep_header)) is None)

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
for raw, held in ((20, 50), (180, 100), ("x", 95), (None, 95), (85.7, 85)):
  registry.write_text(json.dumps({"accounts": [{"id": "main", "primary": True}, {"id": "work"}], "threshold": raw}))
  check(f"a registry threshold of {raw!r} reads as {held}, as account state holds it", collectors.registered_accounts("demo")[0]["switch"]["threshold"] == held)
registry.write_text(json.dumps({"accounts": [{"id": "main", "primary": True}, {"id": "work", "label": "Work"}], "active": "gone", "switch": "auto", "threshold": 80}))
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
check(
  "an account whose check failed with nothing kept has no limits to call stale",
  collectors.account_entry(accounts[1], dict(limits, limits=[]), "")["stale"] is False,
)
PY
