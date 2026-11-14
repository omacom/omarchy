#!/bin/bash

# The Grok Bot collector's own sources: the Cursor sign-in it shares with the
# Cursor collector, and the dashboard's GetSandUsageStatus answer, protobuf
# JSON that drops zeros and falses. The unused-machine record is held
# centrally by the partition test, the Cursor sign-in order by the shared
# test, and the limits cache by the contract checks.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *
import collectors

RESETS = iso_in(3 * 86400 - 600)
service = {"answer": None}


# The dashboard's answer: a week 42.5% used on a Pro plan unless a test
# swaps it.
def sand_status(request):
  if service["answer"] is not None:
    return service["answer"]
  return {"usagePercent": 42.5, "nextResetTimestampUtc": RESETS, "hasNonZeroIncludedLimit": True, "grokPlanLabel": "Pro"}


ROUTES = {"api2.cursor.sh/aiserver.v1.DashboardService/GetSandUsageStatus": sand_status}


# The Cursor CLI's sign-in, a JWT naming the account, an hour from lapsing
# unless told otherwise.
def cli_signed_in(user="u-main", expires_in=3600):
  write_json(config_home() / "cursor" / "auth.json", {"accessToken": jwt({"sub": user, "exp": time.time() + expires_in})})


def grokbot(*args, mode="up"):
  with FakeHttp(ROUTES, mode=mode) as http:
    record = collect("grokbot", *(args or ("--force",)))
  grokbot.requests = http.requests
  return record


def limit(record):
  return {"ready": record["ready"], "stale": record["limitsStale"], "percent": record["limits"][0]["percent"] if record["limits"] else None}


# ---------------------------------------------------------------- contract

sandbox()
fresh = check_limits_contract(Adapter("grokbot", plant=cli_signed_in, answer=ROUTES))
expect("Grok Bot's weekly allowance and plan come from the Cursor sign-in's dashboard answer",
       [fresh["tierLabel"], fresh["limits"][0]["label"], fresh["limits"][0]["percent"], fresh["hasPromptStats"], fresh["hasLocalStats"]],
       ["Pro", "Weekly", 0.425, False, False], fresh)
expect("the weekly window resets when the dashboard says", fresh["limits"][0]["resetsAt"], datetime.fromisoformat(RESETS).isoformat(), fresh)

# ------------------------------------------------------------ failed checks

# A reply cut short or reset mid-reply keeps the last limit, and only one cut
# short (an answer) skips the sooner retry. An error status says which.
grokbot()
server = grokbot(mode=500)
expect("a failed check says the dashboard's status", "500" in server["authHelpText"], True, server)
for broken in ("cut", "reset"):
  record = grokbot(mode=broken)
  expect(f"a connection that breaks mid-reply ({broken}) keeps the last limit, stale", limit(record), {"ready": True, "stale": True, "percent": 0.425}, record)
expect("a reply cut short is an answer, not a reason to retry", bool(grokbot(mode="cut").get("retryAdvised")), False)

# A cache that can't be written never costs the live answer.
cache_root().chmod(0o555)
try:
  record = grokbot()
finally:
  cache_root().chmod(0o755)
expect("an unwritable cache still gives the live limit", limit(record), {"ready": True, "stale": False, "percent": 0.425}, record)

# A lapsed sign-in isn't sent: the CLI or editor renews it the next time it
# runs, so the last limit is kept with the limits paused.
cli_signed_in(expires_in=-60)
record = grokbot()
expect("a lapsed sign-in pauses the limit without asking",
       [limit(record), record["usageStatusText"], len(grokbot.requests)], [{"ready": True, "stale": True, "percent": 0.425}, "Limits paused", 0], record)

# Another account's limit never stands in for this one's.
cli_signed_in("u-other")
record = grokbot(mode=500)
expect("another account's cached limit is never shown", [record["ready"], record["limits"], record["tierLabel"]], [False, [], ""], record)

# --------------------------------------------------------------- the answer

# Protobuf JSON leaves out zero and false: an untouched week reads 0%, and an
# account with no included limit has no Grok Bot, so the panel skips it.
service["answer"] = {"nextResetTimestampUtc": RESETS, "hasNonZeroIncludedLimit": True}
record = grokbot()
expect("an untouched week reads as 0%", [record["limits"][0]["label"], record["limits"][0]["percent"]], ["Weekly", 0.0], record)
service["answer"] = {"usagePercent": 10}
record = grokbot()
expect("a Cursor account without Grok Bot gives an unused record", [record["ready"], record["limits"]], [False, []], record)
service["answer"] = {"usagePercent": "NaN", "hasNonZeroIncludedLimit": True}
expect("an unreadable percentage reads as 0%", grokbot()["limits"][0]["percent"], 0.0)

# A limit with no known end is kept as it is through a failed check.
cli_signed_in("u-no-reset")
service["answer"] = {"usagePercent": 5, "hasNonZeroIncludedLimit": True}
record = grokbot()
expect("a limit with no known reset still shows while live", [limit(record), record["limits"][0]["resetsAt"]], [{"ready": True, "stale": False, "percent": 0.05}, ""], record)
record = grokbot(mode=500)
expect("a limit with no known reset is kept as it is through a failed check",
       [limit(record), record["limits"][0]["resetsAt"]], [{"ready": True, "stale": True, "percent": 0.05}, ""], record)
service["answer"] = None

# --------------------------------------------------------------- the sign-in

# The account asked is the one the Cursor collector reads, whose order the
# shared test holds: here the CLI's sign-in over the editor's.
sandbox()
cli_signed_in("p-cli")
cursor_state_db(None, jwt({"sub": "p-editor", "exp": time.time() + 3600}))
grokbot()
expect("Grok Bot asks as the sign-in the Cursor collector reads",
       [request["headers"]["authorization"] for request in grokbot.requests], ["Bearer " + collectors.cursor_token()])
expect("which is the CLI's over the editor's", collectors.account_key(collectors.cursor_token()), "p-cli")
PY
