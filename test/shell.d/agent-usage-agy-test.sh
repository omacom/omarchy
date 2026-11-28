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

expect("plan lookup identifies the Antigravity IDE and quota requests identify a CLI release",
       ([json.loads(r["data"]) for r in http.requests if r["url"].endswith(TIER)],
        all(r["headers"].get("user-agent", "").startswith("antigravity/cli/") for r in http.requests)),
       ([{"metadata": {"ideType": "ANTIGRAVITY"}}], True), http.requests)

# Gemini 4 Argon is its own scoped allowance, not the plan's Gemini group, even
# when listed ahead of Gemini Models.
machine()
reset_week = iso_in(5 * 24 * 3600)
record, _ = agy({
  TIER: {"paidTier": {"id": "g1-pro-tier", "name": "Google AI Pro"}},
  SUMMARY: {"groups": [
    {"displayName": "Gemini 4 Argon", "buckets": [{"window": "weekly", "remainingFraction": 0.8, "resetTime": reset_week}]},
    {"displayName": "Gemini Models", "buckets": [
      {"window": "5h", "remainingFraction": 0.75, "resetTime": reset_early},
      {"window": "weekly", "remainingFraction": 0.6, "resetTime": reset_week},
    ]},
    {"displayName": "Claude and GPT models", "buckets": [{"bucketId": "3p-weekly", "window": "weekly", "remainingFraction": 1.0}]},
  ]},
})
expect("Gemini 4 Argon stays separate from the primary Gemini Session and Weekly meters",
       [(w["title"], round(w["percent"], 2), w["resetsAt"]) for w in record["limits"]],
       [("Session", 0.25, reset_early), ("Weekly", 0.4, reset_week), ("Gemini 4 Argon Weekly", 0.2, reset_week)], record)

# Summary containing only Argon and Claude/GPT (no primary Gemini group) still
# falls back to retrieveUserQuota for Gemini Session without promoting Argon.
machine()
record, _ = agy({
  TIER: {"paidTier": {"id": "g1-pro-tier", "name": "Google AI Pro"}},
  SUMMARY: {"groups": [
    {"displayName": "Gemini 4 Argon", "buckets": [{"window": "weekly", "remainingFraction": 0.8, "resetTime": reset_week}]},
    {"displayName": "Claude and GPT models", "buckets": [{"bucketId": "3p-5h", "window": "5h", "remainingFraction": 1.0}]},
  ]},
  QUOTA: {"buckets": [{"modelId": "gemini-4-hydrogen-sonar", "remainingFraction": 0.9, "resetTime": reset_early}]},
})
expect("summary with only Argon and 3P still uses retrieveUserQuota for Gemini Session",
       [(w["title"], round(w["percent"], 2), w["resetsAt"]) for w in record["limits"]],
       [("Session", 0.1, reset_early), ("Gemini 4 Argon Weekly", 0.2, reset_week)], record)

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

# Answers saved before the request fix must not reappear after a failed refresh.
for age in (0, 3600):
  machine()
  collector = load_collector("agy")
  legacy = collector.LimitsCache("agy", "me@example.com")
  legacy.save([{"title": "Weekly", "percent": 0.99, "resetsAt": iso_in(3600)}], tierLabel="Free")
  write_json(legacy.path, dict(legacy.data, fetchedAtMs=ms_in(-age)))
  with FakeHttp(mode="down"):
    record = collect("agy")
  expect("pre-fix cached quotas never stand in for a corrected request", record["limits"], [], record)

# omp can renew its token while answering usage; the subsequent tier lookup
# must use that new token and the same IDE metadata as the direct path.
machine()
(home() / "keyring.json").unlink()
database = home() / ".omp/agent/agent.db"
database.parent.mkdir(parents=True)
with sqlite3.connect(database) as conn:
  conn.execute("CREATE TABLE auth_credentials (provider TEXT, credential_type TEXT, data TEXT, disabled_cause TEXT)")
  conn.execute("INSERT INTO auth_credentials VALUES ('google-antigravity', 'oauth', ?, NULL)",
               (json.dumps({"access": "old", "refresh": "r", "expires": ms_in(-60), "email": "me@example.com"}),))
write_json(home() / "renewed.json", {"access": "renewed", "refresh": "r", "expires": ms_in(3600), "email": "me@example.com"})
write_json(home() / "omp-report.json", {"reports": [{"provider": "google-antigravity", "metadata": {"email": "me@example.com"},
  "limits": [{"label": "Gemini", "amount": {"usedFraction": 0.6}, "window": {"id": "5h"}}]}]})
stub = home() / "bin/omp"
stub.write_text('''#!/bin/bash
[[ "$*" == "usage --json --provider google-antigravity" ]] || exit 2
python3 - <<'RENEW'
import os, sqlite3
from pathlib import Path
with sqlite3.connect(Path.home() / ".omp/agent/agent.db") as conn:
  conn.execute("UPDATE auth_credentials SET data = ?", ((Path.home() / "renewed.json").read_text(),))
RENEW
cat "$HOME/omp-report.json"
''')
stub.chmod(0o755)
record, http = agy({TIER: {"paidTier": {"name": "Google AI Pro"}}})
expect("omp-renewed token looks up its paid tier with Antigravity metadata",
       (record["tierLabel"], record["limitsStale"], [w["percent"] for w in record["limits"]],
        [(r["headers"].get("authorization"), json.loads(r["data"])) for r in http.requests]),
       ("Pro", False, [0.6], [("Bearer renewed", {"metadata": {"ideType": "ANTIGRAVITY"}})]), record)
PY
