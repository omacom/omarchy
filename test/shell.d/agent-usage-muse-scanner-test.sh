#!/bin/bash

# The Muse collector's local metering: native `muse` CLI sessions and the
# CLI's session index, plus its own filter over opencode and pi sessions (the
# meta provider, never Muse Spark through OpenCode Zen). How the shared pi and
# opencode readers work, and the unused-machine record, are held centrally by
# the shared and partition tests, and the scan cache by the contract check.
# Muse's limits have a test of their own.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox
require_command rg

python3 - <<'PY'
import sqlite3
from datetime import date, timedelta

from agent_usage_fixtures import *

NOW_US = int(time.time()) * 1_000_000
NOW_MS = NOW_US // 1000
OLD_US = NOW_US - 8 * 86400 * 1_000_000
OLD_DATE = datetime.fromtimestamp(OLD_US / 1_000_000).astimezone().date().isoformat()


def muse_dir():
  return Path(os.environ["MUSE_DATA_DIR"])


def new_muse_home():
  sandbox()
  os.environ["MUSE_DATA_DIR"] = str(home() / "muse-data")


def completion(model=None, recorded_at=NOW_US, input=0, output=0, reasoning=0, cache_read=0, cache_write=0, **usage):
  event = {"kind": "model_completed", "usage": {"input_tokens": input, "output_tokens": output, "reasoning_tokens": reasoning,
                                                 "cache_read_tokens": cache_read, "cache_write_tokens": cache_write, **usage}}
  if model is not None:
    event["model"] = model
  line = {"payload": {"kind": "run", "event": event}}
  if recorded_at is not None:
    line["recorded_at"] = recorded_at
  return line


def model_record(kind, model):
  return {"recorded_at": NOW_US, "payload": {"kind": kind, "record": {"model_id": model}}}


def session(relative, *lines, root=None):
  path = (root or muse_dir() / "sessions") / relative / "session.jsonl"
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join((line if isinstance(line, str) else json.dumps(line)) + "\n" for line in lines))
  return path


def oc_tokens(input, output=0, reasoning=0, read=0, write=0):
  return {"input": input, "output": output, "reasoning": reasoning, "cache": {"read": read, "write": write}}


def muse(*args):
  return collect("muse", *(args or ("--force",)))


def pick(record, *keys):
  return {key: record[key] for key in keys}


# ---------------------------------------------------------- edge times

# A zoneless time at the edge of the calendar, in a zone off UTC, dates
# nothing: that row goes undated, and the record still prints.
new_muse_home()
saved_tz = os.environ.get("TZ")
os.environ["TZ"] = "Asia/Tokyo"
time.tzset()
session("sess-edge", completion("muse-spark-1.3-contributor", "0001-01-01T00:00:00", input=10), completion("muse-spark-1.3-contributor", "9999-12-31T23:59:59", input=20))
try:
  record = muse()
finally:
  if saved_tz is None:
    os.environ.pop("TZ")
  else:
    os.environ["TZ"] = saved_tz
  time.tzset()
expect("Muse reads zoneless times at year 1 and 9999 off UTC as undated", [record["ready"], record["modelUsage"]["muse-spark-1.3-contributor"]["inputTokens"]], [True, 30], record)

# ---------------------------------------------------------- native and opencode

# One main session with a completion and a subagent under it, one session from
# 8 days ago, and opencode rows: Meta's own (counted), Muse Spark through Zen
# (the opencode record's), another provider, and a prompt.
new_muse_home()
session("sess-A",
        {"recorded_at": NOW_US, "payload": {"kind": "metadata", "record": {"model_id": "muse-spark-1.3-contributor", "provider_id": "meta"}}},
        completion("muse-spark-1.3-contributor", input=1000, output=100, reasoning=20, cache_read=600))
session("sess-A/subagent/sub-1", completion("muse-spark-1.3-contributor", input=500, output=50, cache_read=100))
session("sess-B", completion("muse-spark-1.2-contributor", OLD_US, input=2000, output=200))
opencode_db(message=[
  ("op-1", "op-1", oc_v1("meta", oc_tokens(300, 60, 10, 90, 7), model="muse-spark-1.2-contributor", created=NOW_MS)),
  ("op-2", "op-2", oc_v1("opencode", oc_tokens(100, 20, read=30), model="muse-spark-1.3-contributor-free", created=NOW_MS)),
  ("op-3", "op-3", oc_v1("openai", oc_tokens(999, 999), model="gpt-5.4", created=NOW_MS)),
  ("op-4", "op-4", oc_v1("opencode", oc_tokens(0), model="muse-spark-1.3-contributor-free", created=NOW_MS, role="user")),
])
record = muse()
# Native input includes cached tokens, so uncached input is split out: sess-A
# (1000-600) + 100 out + 600 cached = 1100; the subagent (500-100) + 50 + 100
# = 550. opencode input is already cache-exclusive: 300 + 70 + 90 + 7 = 467.
expect("Muse sums native sessions and Meta's opencode rows, with metering only", pick(record, "ready", "hasPromptStats", "limits", "todayTotalTokens", "todayPrompts") | {"balance": "balance" in record},
       {"ready": True, "hasPromptStats": True, "limits": [], "todayTotalTokens": 2117, "todayPrompts": 3, "balance": False}, record)
expect("Muse rolls subagents into their parent session",
       pick(record, "todaySessions", "totalSessions", "totalPrompts"), {"todaySessions": 2, "totalSessions": 3, "totalPrompts": 4}, record)
expect("Muse splits cached tokens out of native input without counting reasoning twice, and keeps opencode input as it is", {
  "today13": record["todayTokensByModel"]["muse-spark-1.3-contributor"],
  "m13": record["modelUsage"]["muse-spark-1.3-contributor"],
  "m12input": record["modelUsage"]["muse-spark-1.2-contributor"]["inputTokens"],
}, {
  "today13": 1650,
  "m13": {"cacheCreationInputTokens": 0, "cacheReadInputTokens": 700, "inputTokens": 800, "outputTokens": 150},
  "m12input": 2300,
}, record)
check("Muse keeps active dates from before the recent week", OLD_DATE in record["activeDates"], record["activeDates"])

# A symlink to a real session would count it twice if followed, a dangling one
# must not break the scan, and a session reached through a symlinked directory
# must not escape the tree.
outside = session("evil", completion("evil-model", input=100, output=10), root=home() / "outside")
(muse_dir() / "sessions" / "sess-link").mkdir()
(muse_dir() / "sessions" / "sess-link" / "session.jsonl").symlink_to(muse_dir() / "sessions" / "sess-A" / "session.jsonl")
(muse_dir() / "sessions" / "sess-dangling").mkdir()
(muse_dir() / "sessions" / "sess-dangling" / "session.jsonl").symlink_to(muse_dir() / "sessions" / "nope" / "session.jsonl")
(muse_dir() / "sessions" / "sess-evildir").symlink_to(outside.parent)
record = muse()
expect("Muse skips symlinked session files and sessions outside the tree",
       [record["todayTotalTokens"], "evil-model" in record["modelUsage"]], [2117, False], record)

# A model id too long for the record fails its row closed, named on the
# completion or on the metadata before it.
big_model = "x" * 500
session("sess-huge", completion(big_model, input=100, output=10))
session("sess-huge-metadata", model_record("metadata", big_model), completion(input=100, output=10))
record = muse()
expect("Muse skips completions under an oversized model name", [record["todayTotalTokens"], len(record["modelUsage"])], [2117, 2], record)

# Many distinct models stay exact: every bucket is kept and the totals
# reconcile with the all-time total (today's 2817 and sess-B's 2200).
session("sess-many", *(completion("cap-model-%02d" % i, input=10) for i in range(70)))
record = muse()
expect("Muse keeps exact totals and every bucket with many models",
       [record["todayTotalTokens"], len(record["modelUsage"]), sum(sum(bucket.values()) for bucket in record["modelUsage"].values())],
       [2817, 72, 5017], record)

# Negative counts can't take usage away.
session("sess-negative", completion("negative-model", input=-100, output=10, reasoning=-5, cache_read=-20, cache_write=-30))
record = muse()
expect("Muse clamps negative token fields", record["modelUsage"]["negative-model"],
       {"cacheCreationInputTokens": 0, "cacheReadInputTokens": 0, "inputTokens": 0, "outputTokens": 10}, record)

# ---------------------------------------------------------------- sources

# Without MUSE_DATA_DIR the native sessions are under XDG_DATA_HOME.
sandbox()
session("xdg-session", completion("muse-spark-1.3", input=10, output=2, reasoning=1, cache_read=4), root=data_home() / "muse" / "sessions")
record = muse()
expect("Muse follows XDG_DATA_HOME", record["todayTotalTokens"], 12, record)

# A completion without a model takes the run_model's, a retained frame's
# record_json child reads like a plain event, an ISO stamp lands on today, and
# a missing recorded_at falls back on the file's time.
new_muse_home()
child = completion("model-via-child", input=20, output=2)
session("sess-events",
        model_record("run_model", "model-via-run-model"),
        completion(input=100, output=10),
        completion("model-explicit", datetime.now().astimezone().isoformat(timespec="seconds"), input=50, output=5),
        {"children": [{"record_json": json.dumps(child)}]},
        completion("model-via-mtime", None, input=7))
record = muse()
expect("Muse counts every event shape in one session", pick(record, "todayTotalTokens", "todayPrompts", "todaySessions") | {
  "runModel": record["modelUsage"]["model-via-run-model"]["inputTokens"] + record["modelUsage"]["model-via-run-model"]["outputTokens"],
  "child": record["modelUsage"]["model-via-child"]["inputTokens"] + record["modelUsage"]["model-via-child"]["outputTokens"],
  "today": sorted(record["todayTokensByModel"]),
}, {
  "todayTotalTokens": 194, "todayPrompts": 4, "todaySessions": 1, "runModel": 110, "child": 22,
  "today": ["model-explicit", "model-via-child", "model-via-mtime", "model-via-run-model"],
}, record)

# Current logs carry a completion as record_type "event" with no payload
# kind, and count cached tokens inside input_tokens; a cache figure larger
# than its input never claims more than the input.
new_muse_home()


def current(input, output, cache_read=None, cache_write=None, offset=0):
  usage = {"input_tokens": input, "output_tokens": output}
  if cache_read is not None:
    usage.update(cache_read_tokens=cache_read, cache_write_tokens=cache_write)
  return {"schema_version": 1, "recorded_at": NOW_US + offset, "record_type": "event", "payload_type": "runtime.session",
          "payload": {"event": {"kind": "model_completed", "model": "muse-wonder-1.0", "usage": usage}}}


session("2026/10/12/demo",
        current(38219, 290, 0, 0),
        current(42901, 357, 38132, 0, 1000),
        current(10, 1, 50, 7, 2000),
        {"payload": {"event": {"kind": "model_completed", "model": "muse", "usage": {"estimated_tokens": 5}}}},
        {"payload": {"event": {"kind": "tool_completed", "usage": {"input_tokens": 999}}}})
record = muse()
expect("Muse reads current event logs and clamps cache tokens to the input", pick(record, "totalPrompts", "totalSessions", "todayPrompts", "todayTotalTokens") | {"m": record["modelUsage"]["muse-wonder-1.0"]},
       {"totalPrompts": 3, "totalSessions": 1, "todayPrompts": 3, "todayTotalTokens": 81778,
        "m": {"cacheCreationInputTokens": 0, "cacheReadInputTokens": 38142, "inputTokens": 42988, "outputTokens": 648}}, record)

# The CLI's session index holds the real prompt and session counts: a session
# nobody prompted isn't one, and an undated row counts on no day.
index = sqlite3.connect(muse_dir() / "session-index.db")
index.execute("CREATE TABLE sessions (session_id TEXT PRIMARY KEY, prompt_count INTEGER NOT NULL DEFAULT 0, created_at_us INTEGER)")
index.executemany("INSERT INTO sessions VALUES (?, ?, ?)", [("demo", 2, NOW_US), ("earlier", 5, OLD_US), ("opened", 0, NOW_US), ("undated", 1, "soon")])
index.commit()
index.close()
record = muse()
expect("Muse takes prompt and session counts from the session index",
       pick(record, "totalPrompts", "totalSessions", "todayPrompts", "todaySessions", "todayTotalTokens") | {"old": OLD_DATE in record["activeDates"]},
       {"totalPrompts": 8, "totalSessions": 3, "todayPrompts": 2, "todaySessions": 1, "todayTotalTokens": 81778, "old": True}, record)

# A native session the index has no row for yet counts its completions as
# prompts, as it would with no index.
fresh = session("2026/10/12/fresh", current(10, 1))
record = muse()
fresh.unlink()
expect("Muse counts a native session the index hasn't seen yet",
       pick(record, "totalPrompts", "totalSessions", "todayPrompts", "todaySessions", "todayTotalTokens"),
       {"totalPrompts": 9, "totalSessions": 4, "todayPrompts": 3, "todaySessions": 2, "todayTotalTokens": 81789}, record)

# A session carried on from an earlier day counts today what its prompt count
# grew by since the last scan before today, not its whole count.
prompts_files = list(cache_root().glob("muse-prompts-*.json"))
check("Muse keeps the session prompt counts it saw", prompts_files, sorted(path.name for path in cache_root().iterdir()))
kept = json.loads(prompts_files[0].read_text())
kept.update(day=(date.today() - timedelta(days=1)).isoformat(), last={"earlier": 3})
prompts_files[0].write_text(json.dumps(kept))
record = muse()
expect("Muse counts today the prompts a session from an earlier day grew by",
       pick(record, "totalPrompts", "todayPrompts", "todaySessions"), {"totalPrompts": 8, "todayPrompts": 4, "todaySessions": 2}, record)
index = sqlite3.connect(muse_dir() / "session-index.db")
index.execute("UPDATE sessions SET prompt_count = 7 WHERE session_id = 'earlier'")
index.commit()
index.close()
record = muse()
expect("Muse keeps counting today from the count before today",
       pick(record, "totalPrompts", "todayPrompts", "todaySessions"), {"totalPrompts": 10, "todayPrompts": 6, "todaySessions": 2}, record)

# After a gap of days, what a count grew by since the last scan wasn't all
# typed today, so the counts start over from now, as on a first scan.
kept = json.loads(prompts_files[0].read_text())
kept.update(day=(date.today() - timedelta(days=3)).isoformat(), last={"earlier": 3})
prompts_files[0].write_text(json.dumps(kept))
record = muse()
expect("Muse puts nothing a session grew by over a gap of days on today",
       pick(record, "totalPrompts", "todayPrompts", "todaySessions"), {"totalPrompts": 10, "todayPrompts": 2, "todaySessions": 1}, record)

# An index that's there but unreadable falls back on completions, and that
# scan isn't cached.
(muse_dir() / "session-index.db").write_text("not a database")
for path in scan_cache_files("muse"):
  path.unlink()
record = collect("muse")
expect("Muse counts completions past an unreadable session index", pick(record, "totalPrompts", "totalSessions"), {"totalPrompts": 3, "totalSessions": 1}, record)
check("Muse doesn't cache a scan past an unreadable session index", not scan_cache_files("muse"), scan_cache_files("muse"))

# A corrupt opencode database can't take the native sessions with it, and
# that incomplete scan is served but never cached.
new_muse_home()
session("sess-native", completion("native-model", input=30, output=3))
(data_home() / "opencode").mkdir(parents=True)
(data_home() / "opencode" / "opencode.db").write_text("not a database")
record = muse()
again = collect("muse")
expect("Muse serves native stats past a corrupt opencode database, uncached",
       [record["todayTotalTokens"], record["ready"], again["todayTotalTokens"], scan_cache_files("muse")], [33, True, 33, []], record)

# An unreadable native session leaves the scan incomplete: the sessions that
# could be read are served, and that partial scan is never cached.
if os.geteuid() != 0:
  new_muse_home()
  session("sess-readable", completion("native-model", input=30, output=3))
  unreadable = session("sess-unreadable", completion("native-model", input=500, output=50))
  unreadable.chmod(0)
  record = muse()
  again = collect("muse")
  unreadable.chmod(0o644)
  expect("Muse serves readable native sessions past an unreadable one, uncached",
         [record["todayTotalTokens"], again["todayTotalTokens"], scan_cache_files("muse")], [33, 33, []], record)
  record = collect("muse")
  expect("Muse counts the session once it can be read", record["todayTotalTokens"], 583, record)

# A microsecond epoch written as a string lands on its real day; a boolean
# stamp falls back on the file's time rather than 1970; an opencode time that
# isn't an object reads as no time (today), tokens that aren't an object skip
# the row, and a cache that isn't one keeps the row's input. Today: 5 + 44 + 11.
# The database has the bare shape of older opencode builds, with no id column.
new_muse_home()
session("sess-odd", completion("string-ts-model", str(OLD_US), input=60, output=6), completion("bool-ts-model", True, input=5))
(data_home() / "opencode").mkdir(parents=True)
bare = sqlite3.connect(data_home() / "opencode" / "opencode.db")
bare.execute("CREATE TABLE message (session_id TEXT, data TEXT)")
bare.executemany("INSERT INTO message VALUES (?, ?)", [
  ("odd-1", json.dumps({"role": "assistant", "providerID": "meta", "modelID": "odd-time-model", "tokens": oc_tokens(40, 4), "time": 12345})),
  ("odd-2", json.dumps({"role": "assistant", "providerID": "meta", "modelID": "odd-tokens-model", "tokens": [1, 2], "time": {"created": NOW_MS}})),
  ("odd-3", json.dumps({"role": "assistant", "providerID": "meta", "modelID": "odd-cache-model", "tokens": {"input": 11, "output": 0, "reasoning": 0, "cache": "nope"}, "time": {"created": NOW_MS}})),
])
bare.commit()
bare.close()
record = muse()
usage = record["modelUsage"]
expect("Muse survives odd timestamp and token shapes without misfiling them", {
  "today": record["todayTotalTokens"],
  "prompts": record["totalPrompts"],
  "stringEpoch": OLD_DATE in record["activeDates"],
  "epoch": bool({"1969-12-31", "1970-01-01"} & set(record["activeDates"])),
  "oddTime": [usage["odd-time-model"]["inputTokens"], usage["odd-time-model"]["outputTokens"]],
  "oddTokens": "odd-tokens-model" in usage,
  "oddCache": [usage["odd-cache-model"]["inputTokens"], usage["odd-cache-model"]["outputTokens"]],
}, {"today": 60, "prompts": 4, "stringEpoch": True, "epoch": False, "oddTime": [40, 4], "oddTokens": False, "oddCache": [11, 0]}, record)

# pi sessions count on Meta's own provider: not Muse Spark through Zen, and
# not a prompt.
new_muse_home()
prompt = pi_reply("meta", 5000, id="user", model="muse-spark")
prompt["message"]["role"] = "user"
write_pi_session(home() / ".pi" / "agent" / "sessions" / "p" / "a.jsonl", [
  prompt,
  pi_reply("meta", 10, id="meta", model="muse-spark"),
  pi_reply("opencode", 5000, id="zen", model="muse-spark"),
])
record = muse()
expect("Muse counts Meta's pi replies alone", [record["todayTotalTokens"], record["totalPrompts"]], [10, 1], record)

# ---------------------------------------------------------- child agents

# Muse credits each billed run to its owner in the session's log, as `muse
# exec` writes it: the main agent, and the reminder children that watch a
# prompt. A child with a log of its own is counted from its completions; one
# without (a skill reminder) is known only from its attribution, which counts
# once however many copies of it the log holds, and answers no prompt.
new_muse_home()


def attribution(owner_id, owner_type, input, cached, output, usage_id):
  record = {"goal_attribution": {"mode": "none"}, "owner": {"owner_id": owner_id, "owner_type": owner_type, "requester_kind": "reminder",
            "run_id": "run-1", "session_id": "run-1"}, "quantity": {"cached_tokens": cached, "input_tokens": input, "main_llm_steps": 0,
            "output_tokens": output, "reasoning_tokens": 5, "reported": True, "unit": "tokens"}, "schema_version": 1,
            "usage_family": "provider", "usage_id": usage_id}
  return {"schema_version": 1, "id": "rec-" + usage_id, "recorded_at": NOW_US, "record_type": "event", "payload_type": "runtime.session",
          "payload": {"event": {"kind": "goal_usage_attribution", "record": record}, "kind": "run", "run_id": "run-1"}}


skill_reminder = attribution("child-skill", "reminder_child", 4000, 400, 40, "usage-skill")
session("sess-C",
        {"recorded_at": NOW_US, "payload": {"kind": "metadata", "record": {"model_id": "muse-spark-1.3-contributor", "provider_id": "meta"}}},
        completion("muse-spark-1.3-contributor", input=1000, output=10, cache_read=100),
        attribution("main-root", "main_root", 1000, 100, 10, "usage-main"),
        attribution("child-logged", "reminder_child", 2000, 200, 20, "usage-logged"),
        skill_reminder,
        {"id": "frame-1", "children": [{"record_json": json.dumps(skill_reminder)}]})
session("sess-C/subagent/child-logged",
        completion("muse-spark-1.3-contributor", input=2000, output=20, cache_read=200),
        attribution("child-logged", "reminder_child", 2000, 200, 20, "usage-logged-call"))
record = muse()
# Main 1010 + the logged child 2020 + the skill reminder 4040.
expect("Muse counts a child agent's calls known only from the session's attribution, once and with no prompt",
       pick(record, "todayTotalTokens", "todayPrompts", "todaySessions") | {"cached": record["modelUsage"]["muse-spark-1.3-contributor"]["cacheReadInputTokens"]},
       {"todayTotalTokens": 7070, "todayPrompts": 2, "todaySessions": 1, "cached": 700}, record)

# ---------------------------------------------------------------- contract

new_muse_home()


def add_session():
  add_session.count = getattr(add_session, "count", 0) + 1
  session(f"grown-{add_session.count}", completion("muse-spark", input=10))


check_scan_cache(Adapter("muse", grow=add_session, pi_root=lambda: home() / ".pi" / "agent" / "sessions"))
PY
