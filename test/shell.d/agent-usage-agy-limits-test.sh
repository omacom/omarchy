#!/bin/bash

# The Antigravity collector's limits with agy's own sign-in: how it reads
# Google's plan and quota answers, a lapsed or replaced sign-in, where the
# bearer may go, and its adapter for the contract checks. Sign-ins kept by
# other harnesses are in agy-harness; local stats in agy-scanner. The
# unused-machine record is held centrally by the partition test, and the
# limits cache's mechanics by the shared test.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

import re

TIER = "v1internal:loadCodeAssist"
QUOTA = "v1internal:retrieveUserQuotaSummary"
ANSWER = {
  TIER: {"paidTier": {"id": "g1-pro-tier", "name": "Google AI Pro"}},
  QUOTA: {"groups": [{"displayName": "Gemini Models", "buckets": [{"window": "5h", "remainingFraction": 0.75, "resetTime": iso_in(3 * 3600)}]}]},
}
ME = jwt({"email": "me@example.com"})
OTHER = jwt({"email": "other@example.com"})
REAL_PATH = os.environ["PATH"]


# A machine where agy keeps its sign-in in the keyring: secret-tool answers
# with keyring.json, which sign_in() writes.
def machine():
  sandbox()
  stub = home() / "bin" / "secret-tool"
  stub.parent.mkdir(parents=True, exist_ok=True)
  stub.write_text('#!/bin/bash\ncat "$HOME/keyring.json" 2>/dev/null\n')
  stub.chmod(0o755)
  os.environ["PATH"] = f"{stub.parent}:{REAL_PATH}"
  os.environ["AGY_DIR"] = str(home() / "agy")


def sign_in(token="token-main", expiry=None, id_token=ME, refresh="refresh-main"):
  write_json(home() / "keyring.json", {"auth_method": "consumer", "id_token": id_token,
                                       "token": {"access_token": token, "refresh_token": refresh, "expiry": expiry or iso_in(3600)}})


def agy(mode="up", routes=ANSWER, args=("--force",)):
  with FakeHttp(routes, mode=mode) as http:
    record = collect("agy", *args)
  return record, http


def tier(payload):
  return load_collector("agy").extract_tier(payload)


def limits(payload):
  return load_collector("agy").extract_limits(payload)


# ------------------------------------------------------------- the answer

sandbox()
expect("Antigravity collector extracts the plan from paidTier, else currentTier", [
  tier({"currentTier": {"id": "free-tier", "name": "Antigravity"}, "paidTier": {"id": "g1-ultra-tier", "name": "Google AI Ultra"}}),
  tier({"currentTier": {"id": "free-tier", "name": "Antigravity"}, "paidTier": {"id": "g1-pro-tier", "name": "Google AI Pro"}}),
  tier({"currentTier": {"id": "free-tier", "name": "Antigravity"}}),
], ["Ultra", "Pro", "Free"])

# Gemini's windows first, the session before the week, then the Claude and
# GPT allowance only where some of it is used.
read = limits({"groups": [
  {"displayName": "Gemini Models", "buckets": [
    {"bucketId": "gemini-weekly", "displayName": "Weekly Limit Remaining", "window": "weekly", "resetTime": "2026-09-17T18:19:42Z", "remainingFraction": 0.95},
    {"bucketId": "gemini-5h", "displayName": "Five Hour Limit Remaining", "window": "5h", "resetTime": "2026-09-15T19:31:46Z", "remainingFraction": 0.90},
  ]},
  {"displayName": "Claude and GPT models", "buckets": [
    {"bucketId": "3p-weekly", "displayName": "Weekly Limit Remaining", "window": "weekly", "resetTime": "2026-09-18T12:56:14Z", "remainingFraction": 0.98},
    {"bucketId": "3p-5h", "displayName": "Five Hour Limit Remaining", "window": "5h", "resetTime": "2026-09-15T22:16:22Z", "remainingFraction": 1.0},
  ]},
]})
expect("Antigravity collector orders the windows, reads used from remaining, and omits an unused 3P window",
       [(entry["label"], entry.get("title"), round(entry["percent"], 2)) for entry in read],
       [("Session (5-hour)", "Session", 0.1), ("Weekly (7-day)", "Weekly", 0.05), ("Claude/GPT Weekly", "Claude/GPT Weekly", 0.02)], read)

read = limits({"groups": [
  {"displayName": "Claude and GPT models", "buckets": [{"window": "5h", "remainingFraction": 1.0}]},
  {"displayName": "Gemini Models", "buckets": [{"window": "weekly", "remainingFraction": 0.5}]},
]})
expect("Antigravity collector finds the Gemini group wherever it is listed", [(entry["label"], entry["percent"]) for entry in read], [("Weekly (7-day)", 0.5)], read)

# Google's quota endpoint can answer with the Claude and GPT pool alone: those
# are the scoped allowances they are, shown under their own names, and the
# plan's Session and Weekly meters are absent rather than wearing 3P numbers.
read = limits({"groups": [
  {"displayName": "Claude and GPT models", "buckets": [
    {"bucketId": "3p-weekly", "displayName": "Weekly Limit Remaining", "window": "weekly", "resetTime": "2026-09-18T12:56:14Z", "remainingFraction": 0.98},
    {"bucketId": "3p-5h", "displayName": "Five Hour Limit Remaining", "window": "5h", "resetTime": "2026-09-15T22:16:22Z", "remainingFraction": 1.0},
  ]},
]})
expect("Antigravity collector reads an answer with no Gemini group as allowances only, never as the plan's meters",
       [(entry["label"], round(entry["percent"], 2)) for entry in read], [("Claude/GPT Weekly", 0.02)], read)

read = limits({"buckets": [
  {"window": "5h", "remaining_fraction": 0.4, "reset_time": "2026-09-15T19:31:46Z"},
  {"window": "weekly", "remainingFraction": "plenty"},
  {"bucketId": "gemini-weekly", "remainingFraction": float("inf")},
]})
expect("Antigravity collector reads snake_case buckets listed without groups and skips unreadable fractions",
       [(entry["label"], round(entry["percent"], 2), entry["resetsAt"]) for entry in read], [("Session (5-hour)", 0.6, "2026-09-15T19:31:46+00:00")], read)

read = limits({"buckets": [{"window": "5h", "resetTime": "2026-09-15T19:31:46Z"}, {"window": "weekly"}]})
expect("Antigravity collector reads a bucket whose zero fraction proto3 JSON left out as fully spent, and skips one with no reset either",
       [(entry["label"], entry["percent"]) for entry in read], [("Session (5-hour)", 1.0)], read)

# agy's QuotaSummaryBucket holds its remainder as a oneof of a fraction and an
# amount (an int64, a string in JSON), so a bucket on the amount arm has no
# fraction yet isn't spent unless the amount is zero; a disabled bucket is
# skipped, as omp's reader skips it.
read = limits({"groups": [
  {"displayName": "Gemini Models", "buckets": [
    {"window": "5h", "remainingAmount": "800", "resetTime": "2026-09-15T19:31:46Z"},
    {"window": "weekly", "remainingAmount": "0", "resetTime": "2026-09-17T18:19:42Z"},
  ]},
  {"displayName": "Claude and GPT models", "buckets": [
    {"window": "5h", "disabled": True, "resetTime": "2026-09-15T22:16:22Z"},
  ]},
]})
expect("Antigravity collector reads a bucket's amount arm, spent only at zero, and skips a disabled bucket",
       [(entry["label"], entry["percent"]) for entry in read], [("Weekly (7-day)", 1.0)], read)

# An answer of another shape is no answer, not a plan without quotas; another
# group's buckets of the wrong shape skip that group alone.
gemini = {"displayName": "Gemini Models", "buckets": [{"window": "5h", "remainingFraction": 0.5}]}
shapes = [None, [1], {"error": {"code": 500}}, {"groups": 5}, {"groups": "abc"}, {"buckets": 5},
          {"groups": [{"displayName": "Gemini Models", "buckets": 5}]}]
expect("Antigravity collector reads an answer of another shape as none", [limits(shape) for shape in shapes], [None] * len(shapes))
read = limits({"groups": [gemini, {"displayName": "Claude and GPT models", "buckets": 5}]})
expect("Antigravity collector skips another group's buckets of the wrong shape", [(entry["label"], entry["percent"]) for entry in read], [("Session (5-hour)", 0.5)], read)

# ---------------------------------------------------------------- contract

machine()


def add_prompt():
  with (home() / "agy" / "history.jsonl").open("a") as history:
    history.write(json.dumps({"timestamp": iso_in(0), "conversation_id": f"c{time.time_ns()}"}) + "\n")


(home() / "agy").mkdir()
adapter = Adapter("agy", plant=sign_in, answer=ANSWER, requests_per_probe=2, grow=add_prompt,
                  pi_root=lambda: home() / ".pi" / "agent" / "sessions")
fresh = check_limits_contract(adapter)
expect("Antigravity collector reports its plan and live limits", [fresh["tierLabel"], fresh["limits"][0]["percent"]], ["Pro", 0.25], fresh)
check_scan_cache(adapter)

record, http = agy()
expect("Antigravity collector asks with agy's token", {r["headers"].get("authorization") for r in http.requests}, {"Bearer token-main"})

# agy's RetrieveUserQuotaSummaryRequest carries the project, which omp sends
# from loadCodeAssist's cloudaicompanionProject, named as a string or {id}.
asked = []
for project in ("proj-1", {"id": "proj-2", "name": "Default"}, None):
  routes = dict(ANSWER, **{TIER: dict(ANSWER[TIER], cloudaicompanionProject=project)})
  _, http = agy(routes=routes)
  asked += [json.loads(r["data"] or b"{}") for r in http.requests if QUOTA in r["url"]]
expect("Antigravity collector asks for the quota of the project loadCodeAssist names", asked, [{"project": "proj-1"}, {"project": "proj-2"}, {}])
caches = [path.name for path in limits_cache_files("agy")]
check("Antigravity collector caches limits per account, named by a digest rather than the email",
      len(caches) == 1 and re.fullmatch(r"agy-limits-[0-9a-f]{16}\.json", caches[0]) and "me@example.com" not in caches[0], caches)

# A damaged entry in the kept answer is dropped, not shown.
edit_limits_cache("agy", resets_past=True)
for path in limits_cache_files("agy"):
  data = json.loads(path.read_text())
  path.write_text(json.dumps(dict(data, limits=data["limits"] + ["damaged"])))
record, _ = agy("down")
expect("Antigravity collector drops a damaged kept window and shows an elapsed one at zero",
       record["limits"], [{"label": "Session (5-hour)", "title": "Session", "percent": 0.0, "resetsAt": ""}], record)
agy()

# A quota answer of another shape is a failed check: the kept limits stand,
# stale, and stay kept for the next failure.
record, _ = agy(routes={TIER: ANSWER[TIER], QUOTA: {"groups": 5}})
after, _ = agy("down")
expect("Antigravity collector keeps the last limits over a quota answer of another shape",
       [[entry["percent"] for entry in record["limits"]], record["limitsStale"], record["retryAdvised"], "couldn't be read" in record["authHelpText"],
        [entry["percent"] for entry in after["limits"]], after["limitsStale"]],
       [[0.25], True, False, True, [0.25], True], [record, after])

# ------------------------------------------------------------ the sign-in

# A lapsed access token is renewed the next time agy runs, so the kept limits
# stay up without a new sign-in; without a refresh token behind it, a new
# sign-in is needed. Neither is sent to Google.
sign_in(expiry=iso_in(-3600))
record, http = agy()
check("Antigravity collector pauses limits while agy's access token has lapsed, asking nothing",
      http.count == 0 and record["usageStatusText"] == "Limits paused" and record["limitsStale"] is True and len(record["limits"]) == 1
      and "signing in again is not needed" in record["authHelpText"], record)

sign_in(expiry=iso_in(-3600), refresh="")
record, http = agy()
expect("Antigravity collector reports a lapsed sign-in without a refresh token as expired", [http.count, record["usageStatusText"]], [0, "Sign-in expired"], record)

# Another account signed in here never wears the last one's limits.
sign_in("token-other", iso_in(-3600), OTHER)
record, _ = agy("down")
expect("Antigravity collector shows no other account's kept limits",
       [record["limits"], record["tierLabel"], record["limitsFetchedAt"]], [[], "", 0], record)

# A plan with no quota windows to report is healthy, with no meters.
sign_in("token-other", iso_in(3600), OTHER)
record, _ = agy(routes={TIER: ANSWER[TIER], QUOTA: {"groups": []}})
expect("Antigravity collector treats a plan without quota windows as healthy",
       [record["limits"], record["tierLabel"], record["usageStatusText"], record["authHelpText"], record["limitsStale"]], [[], "Pro", "", "", False], record)

# The bearer token goes only to an https destination.
os.environ["CLOUD_CODE_URL"] = "http://evil.example"
_, http = agy()
expect("Antigravity collector ignores a plain-http destination", {r["url"].split("/")[2] for r in http.requests}, {"daily-cloudcode-pa.googleapis.com"})
os.environ["CLOUD_CODE_URL"] = "https://mirror.example"
_, http = agy()
expect("Antigravity collector honors an https destination", {r["url"].split("/")[2] for r in http.requests}, {"mirror.example"})
del os.environ["CLOUD_CODE_URL"]

for path in limits_cache_files("agy"):
  path.unlink()
record, _ = agy("down")
expect("Antigravity collector invents no limits when it has never reached Google",
       [record["limits"], record["usageStatusText"], record["retryAdvised"]], [[], "Antigravity limits unavailable", True], record)
PY
