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


def plant_t3(hash_name="hash-1", *, token=None, summaries=(), transcripts=None):
  acp = home() / "t3" / "userdata" / "providers" / "antigravity" / hash_name / "antigravity-acp"
  acp.mkdir(parents=True, exist_ok=True)
  os.environ["T3CODE_HOME"] = str(home() / "t3")
  if token is not None:
    write_json(acp / "antigravity-oauth-token", token)
  if summaries:
    db = acp / "conversation_summaries.db"
    conn = sqlite3.connect(db)
    conn.execute("CREATE TABLE conversation_summaries (conversation_id text PRIMARY KEY, last_modified_time datetime NOT NULL, parent_conversation_id text NOT NULL DEFAULT '')")
    conn.executemany("INSERT INTO conversation_summaries VALUES (?, ?, ?)", summaries)
    conn.commit()
    conn.close()
  for cid, steps in (transcripts or {}).items():
    transcript = acp / "brain" / cid / ".system_generated" / "logs" / "transcript.jsonl"
    transcript.parent.mkdir(parents=True, exist_ok=True)
    transcript.write_text("".join(json.dumps(step) + "\n" for step in steps))
  return acp


# T3 Code's antigravity-acp sign-in is picked up ahead of a lapsed agy keyring
# token, and a lapsed T3 token names 'T3 Code' in authHelpText.
machine()
os.environ.pop("T3CODE_HOME", None)
write_json(home() / "keyring.json", {
  "auth_method": "consumer",
  "id_token_email": "me@example.com",
  "token": {"access_token": "token-lapsed", "refresh_token": "refresh-main", "expiry": iso_in(-3600)},
})
plant_t3(token={
  "auth_method": "consumer",
  "id_token_email": "me@example.com",
  "token": {"access_token": "token-t3", "refresh_token": "refresh-t3", "expiry": iso_in(3600)},
})
record, http = agy({
  TIER: {"paidTier": {"id": "g1-pro-tier", "name": "Google AI Pro"}},
  SUMMARY: {"groups": [{"displayName": "Gemini Models", "buckets": [{"window": "5h", "remainingFraction": 0.6, "resetTime": reset_early}]}]},
})
expect("T3 Code token is picked up ahead of a lapsed agy keyring token",
       (record["tierLabel"], record["accountName"], [w["percent"] for w in record["limits"]],
        [r["headers"].get("authorization") for r in http.requests[:1]]),
       ("Pro", "me@example.com", [0.4], ["Bearer token-t3"]), record)

plant_t3(token={
  "auth_method": "consumer",
  "id_token_email": "me@example.com",
  "token": {"access_token": "token-t3-lapsed", "refresh_token": "refresh-t3", "expiry": iso_in(-60)},
})
record, _ = agy({})
expect("lapsed T3 Code token names 'T3 Code' in authHelpText",
       (record["usageStatusText"], "T3 Code" in record["authHelpText"]),
       ("Limits paused", True), record)

# Without history.jsonl in antigravity-acp, USER_INPUT steps count as prompts
# while subagent transcripts are excluded from prompt and session counts; an
# AGY_DIR with history.jsonl still counts from history.jsonl alone.
freeze_today()
machine()
os.environ.pop("T3CODE_HOME", None)
(home() / "keyring.json").unlink()
now_iso = today_stamp(10)
write_json(home() / "agy" / "history.jsonl", {"timestamp": now_iso, "conversationId": "agy-main"})
agy_transcript = home() / "agy" / "brain" / "agy-main" / ".system_generated" / "logs" / "transcript.jsonl"
agy_transcript.parent.mkdir(parents=True, exist_ok=True)
agy_transcript.write_text(
  json.dumps({"type": "USER_INPUT", "source": "USER_EXPLICIT", "created_at": now_iso}) + "\n" +
  json.dumps({"type": "USER_INPUT", "source": "USER_EXPLICIT", "created_at": now_iso}) + "\n"
)
plant_t3(
  summaries=[("conv-main", now_iso, ""), ("conv-sub", now_iso, "conv-main")],
  transcripts={
    "conv-main": [
      {"type": "USER_INPUT", "source": "USER_EXPLICIT", "created_at": now_iso},
      {"type": "PLANNER_RESPONSE", "created_at": now_iso, "model": "gemini-4-hydrogen-high", "input_tokens": 300, "output_tokens": 50},
      {"type": "USER_INPUT", "source": "USER_EXPLICIT", "created_at": now_iso},
      {"type": "PLANNER_RESPONSE", "created_at": now_iso, "input_tokens": 200, "output_tokens": 10},
    ],
    "conv-sub": [
      {"type": "USER_INPUT", "source": "USER_EXPLICIT", "created_at": now_iso},
      {"type": "PLANNER_RESPONSE", "created_at": now_iso, "model": "gemini-4-hydrogen-high", "input_tokens": 40, "output_tokens": 10},
    ],
  },
)
record, _ = agy({})
expect("T3 Code USER_INPUT steps count as prompts without history.jsonl, excluding subagents",
       (record["ready"], record["hasLocalStats"], record["todayPrompts"], record["totalPrompts"],
        record["todaySessions"], record["totalSessions"], record["todayTotalTokens"]),
       (True, True, 3, 3, 2, 2, 610), record)
PY
