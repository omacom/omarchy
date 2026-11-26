#!/bin/bash

# Antigravity collector fallback to retrieveUserQuota when
# retrieveUserQuotaSummary omits the Gemini group (as Google AI Ultra does).

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

TIER = "v1internal:loadCodeAssist"
SUMMARY = "v1internal:retrieveUserQuotaSummary"
QUOTA = "v1internal:retrieveUserQuota"
ME = jwt({"email": "me@example.com"})
REAL_PATH = os.environ["PATH"]


def machine():
  sandbox()
  stub = home() / "bin" / "secret-tool"
  stub.parent.mkdir(parents=True, exist_ok=True)
  stub.write_text('#!/bin/bash\ncat "$HOME/keyring.json" 2>/dev/null\n')
  stub.chmod(0o755)
  os.environ["PATH"] = f"{stub.parent}:{REAL_PATH}"
  os.environ["AGY_DIR"] = str(home() / "agy")
  write_json(home() / "keyring.json", {
    "auth_method": "consumer",
    "id_token": ME,
    "token": {"access_token": "token-main", "refresh_token": "refresh-main", "expiry": iso_in(3600)},
  })


def agy(routes):
  with FakeHttp(routes) as http:
    return collect("agy", "--force"), http


# Ultra summary has only Claude/GPT; fallback reads Gemini's 5-hour bucket from
# retrieveUserQuota and ignores Claude/GPT and tab_* entries.
machine()
reset_early = iso_in(2 * 3600)
reset_late = iso_in(4 * 3600)
record, http = agy({
  TIER: {"paidTier": {"id": "g1-ultra-tier", "name": "Google AI Ultra"}, "cloudaicompanionProject": "aicode-consumers"},
  SUMMARY: {"groups": [{"displayName": "Claude and GPT models", "buckets": [
    {"bucketId": "3p-5h", "window": "5h", "remainingFraction": 1.0},
    {"bucketId": "3p-weekly", "window": "weekly", "remainingFraction": 0.9},
  ]}]},
  QUOTA: {"buckets": [
    {"modelId": "claude-opus-5-5-high", "remainingFraction": 0.2, "resetTime": reset_early},
    {"modelId": "tab_flash_lite_preview", "remainingFraction": 0.1, "resetTime": reset_early},
    {"modelId": "gemini-2.5-flash", "remainingFraction": 0.93, "resetTime": reset_late},
    {"modelId": "gemini-4-hydrogen-sonar", "remainingFraction": 0.85, "resetTime": reset_early},
    {"modelId": "models/gemini-2.5-pro", "remainingFraction": 0.85, "resetTime": reset_late},
  ]},
})
expect("Ultra falls back to retrieveUserQuota for Gemini and puts Session ahead of scoped 3P limits",
       [(w["title"], round(w["percent"], 2), w["resetsAt"]) for w in record["limits"]],
       [("Session", 0.15, reset_early), ("Claude/GPT Weekly", 0.1, "")], record)
expect("fallback sends the project from loadCodeAssist",
       [json.loads(r["data"]) for r in http.requests if r["url"].endswith(QUOTA)],
       [{"project": "aicode-consumers"}], http.requests)

# A transient 500 on retrieveUserQuota preserves the cached Gemini limit as
# stale rather than overwriting it with empty limits.
record, _ = agy({
  TIER: {"paidTier": {"id": "g1-ultra-tier", "name": "Google AI Ultra"}},
  SUMMARY: {"groups": [{"displayName": "Claude and GPT models", "buckets": [{"window": "5h", "remainingFraction": 1.0}]}]},
  QUOTA: 500,
})
expect("transient 500 on retrieveUserQuota keeps cached limits stale",
       (record["limitsStale"], [round(w["percent"], 2) for w in record["limits"]]),
       (True, [0.15, 0.1]), record)

# An untouched Gemini bucket (0% used) drops Google's rolling now+5h reset.
machine()
record, _ = agy({
  TIER: {"paidTier": {"id": "g1-ultra-tier", "name": "Google AI Ultra"}},
  SUMMARY: {"groups": [{"displayName": "Claude and GPT models", "buckets": [{"window": "5h", "remainingFraction": 1.0}]}]},
  QUOTA: {"buckets": [{"modelId": "gemini-3-flash", "remainingFraction": 1.0, "resetTime": iso_in(5 * 3600)}]},
})
expect("untouched Gemini fallback bucket omits synthetic reset time",
       [(w["title"], w["percent"], w["resetsAt"]) for w in record["limits"]],
       [("Session", 0.0, "")], record)

# When retrieveUserQuotaSummary already carries a Gemini group, retrieveUserQuota
# is never called.
machine()
record, http = agy({
  TIER: {"paidTier": {"id": "g1-pro-tier", "name": "Google AI Pro"}},
  SUMMARY: {"groups": [{"displayName": "Gemini Models", "buckets": [{"window": "5h", "remainingFraction": 0.75, "resetTime": reset_early}]}]},
})
expect("summary with Gemini group does not call retrieveUserQuota",
       ([w["percent"] for w in record["limits"]], [r["url"] for r in http.requests if r["url"].endswith(QUOTA)]),
       ([0.25], []), record)

# A 404 on retrieveUserQuota degrades cleanly to the summary's limits instead of
# failing the whole check.
machine()
record, _ = agy({
  TIER: {"paidTier": {"id": "g1-ultra-tier", "name": "Google AI Ultra"}},
  SUMMARY: {"groups": [{"displayName": "Claude and GPT models", "buckets": [{"window": "5h", "remainingFraction": 1.0}]}]},
  QUOTA: 404,
})
expect("404 on retrieveUserQuota degrades cleanly to summary limits",
       [record["tierLabel"], record["limits"], record["usageStatusText"]],
       ["Ultra", [], ""], record)
PY

python3 - <<'PY'
from agent_usage_fixtures import *

# Antigravity's own local stats: the desktop app keeps no history log, and a
# completed turn writes exact counts to its conversation database. A turn the
# database holds but the transcript does not has no model of its own, so it
# takes the model in effect at its step.
PLANNER_STEP_TYPE = 15
COMPLETED_STEP_STATUS = 3


def varint(value):
  out = bytearray()
  while True:
    byte = value & 0x7f
    value >>= 7
    out.append(byte | (0x80 if value else 0))
    if not value:
      return bytes(out)


def proto_field(number, wire, payload):
  key = varint((number << 3) | wire)
  if wire == 2:
    return key + varint(len(payload)) + payload
  return key + varint(payload)


def usage_counts(input_tokens, output_tokens, cache_read=0, cache_write=0):
  return b"".join([
    proto_field(2, 0, input_tokens),
    proto_field(3, 0, output_tokens),
    proto_field(5, 0, cache_read),
    proto_field(4, 0, cache_write),
  ])


def step_metadata(seconds, input_tokens, output_tokens, cache_read=0, cache_write=0):
  timestamp = proto_field(1, 0, seconds) + proto_field(2, 0, 0)
  return proto_field(1, 2, timestamp) + proto_field(9, 2, usage_counts(input_tokens, output_tokens, cache_read, cache_write))


def transcript(name, steps):
  path = home() / ".gemini" / "antigravity" / "brain" / name / ".system_generated" / "logs" / "transcript.jsonl"
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(step) + "\n" for step in steps))
  return path


def conversation(name, steps=(), model=""):
  db = home() / ".gemini" / "antigravity" / "conversations" / f"{name}.db"
  db.parent.mkdir(parents=True, exist_ok=True)
  conn = sqlite3.connect(db)
  conn.execute("CREATE TABLE steps (idx INTEGER PRIMARY KEY, step_type INTEGER, status INTEGER, metadata BLOB)")
  conn.execute("CREATE TABLE gen_metadata (idx INTEGER PRIMARY KEY, data BLOB)")
  conn.executemany("INSERT INTO steps VALUES (?, ?, ?, ?)",
                   [(index, PLANNER_STEP_TYPE, COMPLETED_STEP_STATUS, metadata) for index, metadata in steps])
  if model:
    conn.execute("INSERT INTO gen_metadata VALUES (0, ?)", (model.encode(),))
  conn.commit()
  conn.close()
  return db


sandbox()
# Only the tools a scan may run (rg), so the real keyring's secret-tool or an
# agent CLI cannot leak a sign-in into the record.
os.environ["PATH"] = str(Path(os.environ["SANDBOX"]) / "tools")
freeze_today()
STAMP = today_stamp()
SECONDS = int(fixture_now().timestamp())

# A conversation that switches from Gemini to Claude at step 8. The database
# holds completed turns at 1, 5, and 9 that the transcript never wrote; its
# gen_metadata names neither model, as a real one names no model at all.
transcript("switch", [
  {"step_index": 3, "type": "PLANNER_RESPONSE", "created_at": STAMP, "model": "gemini-3.8-flash",
   "usage": {"prompt_token_count": 10, "candidates_token_count": 1}},
  {"step_index": 8, "type": "SYSTEM", "created_at": STAMP,
   "content": "The user changed `Model Selection` from Gemini 3.8 Flash to Claude Sonnet 4.6 (Thinking). No need to mention it."},
  {"step_index": 10, "type": "PLANNER_RESPONSE", "created_at": STAMP,
   "usage": {"prompt_token_count": 20, "candidates_token_count": 2}},
])
conversation("switch", [(1, step_metadata(SECONDS, 1, 1)), (5, step_metadata(SECONDS, 2, 2)), (9, step_metadata(SECONDS, 4, 4))],
             model="gemini-3.9-final")

record = collect("agy", "--force")
expect("Antigravity gives a database-only turn the model in effect at its step, and unknown before any model",
       record["modelUsage"], {
         "gemini-3.8-flash": {"inputTokens": 12, "outputTokens": 3, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
         "claude-sonnet-4.6-thinking": {"inputTokens": 24, "outputTokens": 6, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
         "unknown": {"inputTokens": 1, "outputTokens": 1, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
       }, record)

# The desktop app keeps no history log, so its typed prompts are USER_INPUT
# steps, and a completed turn's exact counts replace the transcript's own.
sandbox()
freeze_today()
STAMP = today_stamp()
SECONDS = int(fixture_now().timestamp())

transcript("desk", [
  {"step_index": 0, "type": "USER_INPUT", "content": "desktop prompt", "created_at": STAMP},
  {"step_index": 1, "type": "PLANNER_RESPONSE", "created_at": STAMP, "model": "gemini-3.9-desktop",
   "usage": {"prompt_token_count": 100, "candidates_token_count": 20}},
])
conversation("desk", [(1, step_metadata(SECONDS, 11, 7, 3, 1))], model="gemini-3.9-desktop")

record = collect("agy", "--force")
expect("Antigravity counts a desktop prompt from its USER_INPUT step with no history log",
       [record["totalPrompts"], record["todayPrompts"]], [1, 1], record)
expect("Antigravity takes a completed turn's exact database counts over the transcript's",
       record["modelUsage"].get("gemini-3.9-desktop"),
       {"inputTokens": 11, "outputTokens": 7, "cacheReadInputTokens": 3, "cacheCreationInputTokens": 1}, record)

# A turn the database adds beside the transcript's counted step counts once.
sandbox()
freeze_today()
STAMP = today_stamp()
SECONDS = int(fixture_now().timestamp())

transcript("dbonly", [
  {"step_index": 0, "type": "PLANNER_RESPONSE", "created_at": STAMP, "model": "gemini-3.9-only",
   "usage": {"prompt_token_count": 5, "candidates_token_count": 1}},
])
conversation("dbonly", [(0, step_metadata(SECONDS, 5, 1)), (1, step_metadata(SECONDS, 4, 2))], model="gemini-3.9-only")

record = collect("agy", "--force")
expect("Antigravity counts a database-only turn once, not again beside the transcript",
       record["modelUsage"].get("gemini-3.9-only"),
       {"inputTokens": 9, "outputTokens": 3, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}, record)

# Metadata that trails off, or carries a wire type the parser doesn't know,
# is no exact usage; the transcript's own counts stand and nothing crashes.
sandbox()
freeze_today()
STAMP = today_stamp()
SECONDS = int(fixture_now().timestamp())

transcript("meta", [
  {"step_index": 1, "type": "PLANNER_RESPONSE", "created_at": STAMP, "model": "gemini-3.9-meta",
   "usage": {"prompt_token_count": 5, "candidates_token_count": 1}},
  {"step_index": 2, "type": "PLANNER_RESPONSE", "created_at": STAMP, "model": "gemini-3.9-meta",
   "usage": {"prompt_token_count": 6, "candidates_token_count": 2}},
])
conversation("meta", [
  (1, b"\x4a\x05\x02"),  # field 9, five bytes promised, one there
  (2, b"\x4b\x00"),  # field 9, wire type 3
], model="gemini-3.9-meta")

record = collect("agy", "--force")
expect("Antigravity ignores truncated and unsupported turn metadata without crashing",
       record["modelUsage"].get("gemini-3.9-meta"),
       {"inputTokens": 11, "outputTokens": 3, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}, record)

# A count too large to be real is not usage, so it cannot inflate the totals.
sandbox()
freeze_today()
STAMP = today_stamp()
SECONDS = int(fixture_now().timestamp())

transcript("damaged", [
  {"step_index": 0, "type": "PLANNER_RESPONSE", "created_at": STAMP, "model": "gemini-3.9-damaged",
   "usage": {"prompt_token_count": 7, "candidates_token_count": 2}},
])
conversation("damaged", [(0, step_metadata(SECONDS, 2**63, 0))], model="gemini-3.9-damaged")

record = collect("agy", "--force")
expect("Antigravity drops a damaged exact count rather than inflating the totals",
       [record["modelUsage"].get("gemini-3.9-damaged"),
        max((bucket["inputTokens"] for bucket in record["modelUsage"].values()), default=0)],
       [{"inputTokens": 7, "outputTokens": 2, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}, 7], record)

# A conversation database that exists but can't be read is a problem, so its
# missing turns are never cached as a complete scan.
sandbox()
broken = home() / ".gemini" / "antigravity" / "conversations" / "broken.db"
broken.parent.mkdir(parents=True, exist_ok=True)
broken.write_text("not a database\n")

agy = load_collector("agy")
problems = []
expect("Antigravity reads no exact turns from a conversation database it cannot read",
       agy.read_conversation_db(broken, problems), ({}, ""))
expect("Antigravity reports a conversation database it cannot read", problems, [str(broken)])

record = collect("agy", "--force")
expect("Antigravity never caches a scan whose conversation database it cannot read",
       scan_cache_files("agy"), [], record)
PY
