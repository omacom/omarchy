#!/bin/bash

# The OpenCode collector's limits: the Go plan's windows from the Zen gateway
# in both shapes it answers, a key without a Go plan, every credential store
# a key can come from, and its adapter for the contract checks. The
# unused-machine record is held centrally by the partition test, the limits
# cache's mechanics by the shared test, and the scan cache by the scanner
# test.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

ZEN = "opencode.ai/zen/go/v1/usage"
CONSOLE = "opencode.ai/inference/go/v1/usage"
USAGE = {"usage": {
  "rolling": {"percent": 16, "resetsAt": "2999-01-01T00:00:00.000Z"},
  "weekly": {"percent": 6, "resetsAt": "2999-01-05T00:00:00.000Z"},
  "monthly": {"percent": 29, "resetsAt": "2999-01-11T15:38:40.000Z"},
}}


def keyed(key="zen_test"):
  os.environ["OPENCODE_API_KEY"] = key


def opencode(answer=None, mode="up", *args):
  with FakeHttp({ZEN: answer}, mode=mode) as http:
    record = collect("opencode", *(args or ("--force",)))
  return record, http


def windows(record):
  return [(entry["label"], entry["percent"]) for entry in record["limits"]]


def candidates():
  return [candidate.token for candidate in load_collector("opencode").credential_candidates()]


# ---------------------------------------------------------------- contract

sandbox()
fresh = check_limits_contract(Adapter("opencode", plant=keyed, answer={ZEN: USAGE}))
expect("OpenCode collector maps every Zen usage window, under the Go plan",
       [windows(fresh), fresh["tierLabel"]], [[("Rolling (5h)", 0.16), ("Weekly (7-day)", 0.06), ("Monthly", 0.29)], "Go"], fresh)

# An answer (limits, or no plan) never rolls back one another run stamped
# while this one waited on the network.
for later_answer in (USAGE, 403):
  def later_run(request, later_answer=later_answer):
    edit_limits_cache("opencode", fetched_ago=-60)
    return later_answer
  opencode(later_run)
  expect(f"OpenCode collector never overwrites a newer cached answer with its own ({'limits' if later_answer == USAGE else 'no plan'})",
         [json.loads(path.read_text())["fetchedAtMs"] > ms_in(30) for path in limits_cache_files("opencode")], [True])
  edit_limits_cache("opencode", fetched_ago=0)
opencode(USAGE)

# A failed check keeps the plan along with the windows.
record, _ = opencode(mode=500)
expect("OpenCode collector keeps the Go plan with the kept windows", [record["tierLabel"], record["limitsStale"]], ["Go", True], record)

# Another sign-in never shows this one's numbers.
keyed("zen_other")
record, _ = opencode(mode="down")
expect("OpenCode collector caches limits per credential", [record["limits"], record["usageStatusText"]], [[], "OpenCode limits unavailable"], record)

# ------------------------------------------------------------- the answer

sandbox()
keyed()

# Another deployment spells the windows <window>Usage, and a rate-limited
# window is spent whatever it reads.
record, _ = opencode({
  "rollingUsage": {"usagePercent": 40, "resetInSec": 3600, "status": "rate-limited"},
  "weeklyUsage": {"usagePercent": "12.5", "resetInSec": 0},
})
expect("OpenCode collector reads the alternate payload shape",
       [windows(record), record["limits"][0]["resetsAt"] != "", record["limits"][1]["resetsAt"]],
       [[("Rolling (5h)", 1.0), ("Weekly (7-day)", 0.125)], True, ""], record)

# resetsAt is an ISO time or nothing, so an epoch, a list or garbage falls back
# to resetInSec, and a reset further out than a date goes reads as none.
for odd in (1792700000, ["x"], "garbage"):
  record, _ = opencode({"usage": {
    "rolling": {"percent": 10, "resetsAt": odd, "resetInSec": 3600},
    "weekly": {"percent": 20, "resetsAt": odd},
    "monthly": {"percent": 30, "resetInSec": 1e14},
  }})
  expect(f"OpenCode collector shows only an ISO reset time (resetsAt {odd!r})",
         [windows(record), record["limits"][0]["resetsAt"][:4].isdigit() and "T" in record["limits"][0]["resetsAt"],
          record["limits"][1]["resetsAt"], record["limits"][2]["resetsAt"]],
         [[("Rolling (5h)", 0.1), ("Weekly (7-day)", 0.2), ("Monthly", 0.3)], True, "", ""], record)

# With nothing kept, each way a check fails says what happened.
for path in limits_cache_files("opencode"):
  path.unlink()
cases = {
  "a payload without windows": ({"usage": {}}, "up", "OpenCode limits unavailable", "no quota windows", False),
  "a refused key": (None, 401, "Sign-in expired", "rejected the saved key", False),
  "a non-auth status": (None, 500, "OpenCode limits unavailable", "returned status 500", False),
  "no server answering": (None, "down", "OpenCode limits unavailable", "Couldn't reach", True),
  "a timeout": (None, "timeout", "OpenCode limits unavailable", "Couldn't reach", True),
  # A server that answered with garbage was reached; retrying soon won't help.
  "an unparseable answer": (None, "garbage", "OpenCode limits unavailable", "returned no data", False),
  "an answer that breaks the reader": (RuntimeError("broken"), "up", "OpenCode limits unavailable", "returned no data", False),
}
for name, (answer, mode, status, help_text, retry) in cases.items():
  record, _ = opencode(answer, mode)
  check(f"OpenCode collector explains {name} with nothing kept, and calls nothing stale",
        record["limits"] == [] and record["limitsStale"] is False and record["usageStatusText"] == status
        and help_text in record["authHelpText"] and bool(record.get("retryAdvised")) is retry, record)

# A Zen pay-as-you-go key has no Go plan behind it. That is no trouble, and
# the answer is remembered so the next runs don't ask again.
record, http = opencode(None, 403)
check("OpenCode collector stays silent for a key without a Go plan",
      record["limits"] == [] and record["usageStatusText"] == "" and record["authHelpText"] == "" and record["tierLabel"] == ""
      and record["limitsStale"] is False and http.count == 1, record)
check("an OpenCode key with no sessions here has no local stats",
      record["ready"] is True and record["totalSessions"] == 0 and record["hasLocalStats"] is False, record)
record, http = opencode(None, 403, "--limits-only")
check("OpenCode collector doesn't ask again about a key without a Go plan",
      record["usageStatusText"] == "" and record["limits"] == [] and http.count == 0, record)
record, _ = opencode({"usage": {"weekly": {"percent": 10, "resetsAt": "2999-01-01T00:00:00.000Z"}}})
expect("OpenCode collector --force asks again after a Go plan appears", [windows(record), record["tierLabel"]], [[("Weekly (7-day)", 0.1)], "Go"], record)
record, _ = opencode(None, 403)
expect("OpenCode collector drops a cancelled plan's windows",
       [record["limits"], record["usageStatusText"], record["tierLabel"]], [[], "", ""], record)

# Two ways in, each answering for itself: OPENCODE_API_KEY is asked first.
sandbox()
os.environ.update(OPENCODE_API_KEY="key_first", OPENCODE_GO_API_KEY="key_second")


def by_key(**answers):
  return lambda request: answers[request.get_header("Authorization").removeprefix("Bearer ")]


# Every way in refused keeps the open windows of whichever refusal has them,
# not just the first one asked, which has none.
opencode(by_key(key_first=401, key_second=USAGE))
record, _ = opencode(by_key(key_first=401, key_second=401))
expect("OpenCode collector keeps the windows of a later refused key when the first has none",
       [windows(record), record["limitsStale"], record["usageStatusText"]],
       [[("Rolling (5h)", 0.16), ("Weekly (7-day)", 0.06), ("Monthly", 0.29)], True, "Sign-in expired"], record)

# A key that says it has no Go plan makes an outage on the other one, with
# nothing kept for it, no news.
for path in limits_cache_files("opencode"):
  path.unlink()
record, _ = opencode(by_key(key_first=403, key_second=500))
expect("OpenCode collector lets a no-plan key quiet another key's outage",
       [record["limits"], record["usageStatusText"], record["authHelpText"]], [[], "", ""], record)
del os.environ["OPENCODE_API_KEY"], os.environ["OPENCODE_GO_API_KEY"]

# ------------------------------------------------------------ credentials

# The key can come from opencode's own credential stores or, when a machine
# codes through pi, from pi's.
sandbox()
auth = data_home() / "opencode" / "auth.json"
write_json(auth, {"opencode": {"type": "api_key", "key": "from_opencode"}})
expect("OpenCode collector reads opencode's own credential", candidates(), ["from_opencode"])

# A custom provider merely named like opencode holds a key for somewhere else.
write_json(auth, {"opencode-local": {"type": "api_key", "key": "gateway_secret"}})
check("OpenCode collector never sends a look-alike provider's key", "gateway_secret" not in candidates())

# An auth.json entry may be the key itself, and the Go key has an
# environment variable of its own beside OPENCODE_API_KEY.
write_json(auth, {"opencode-go": " plain_key "})
expect("OpenCode collector reads a plain-string auth.json key", candidates(), ["plain_key"])
os.environ["OPENCODE_GO_API_KEY"] = "go_env"
expect("OpenCode collector reads OPENCODE_GO_API_KEY first", candidates(), ["go_env", "plain_key"])

sandbox()
pi_auth(None, "opencode-go", "from_pi")
expect("OpenCode collector reads pi's credential as a last resort", candidates(), ["from_pi"])
pi_auth(home() / ".omp" / "agent", "opencode", "from_omp")
expect("OpenCode collector reads omp's credential after pi's", candidates(), ["from_pi", "from_omp"])
os.environ["PI_CODING_AGENT_DIR"] = str(home() / "pi-moved")
pi_auth(home() / "pi-moved", "opencode", "from_moved")
expect("OpenCode collector reads pi's credential where PI_CODING_AGENT_DIR moves it", candidates(), ["from_moved", "from_omp"])
pi_auth(home() / "pi-moved", "opencode", "!pass show opencode")
pi_auth(home() / ".omp" / "agent", "opencode", "$OPENCODE_KEY")
expect("OpenCode collector never sends a pi !command or $VAR entry as a key", candidates(), [])

# OpenCode V2 keeps its credentials in the database: a Go key first, and the
# Console session last, asked on Console's endpoint with its workspace.
sandbox()
db = data_home() / "opencode" / "opencode.db"
db.parent.mkdir(parents=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE credential (id text, integration_id text, active integer, time_updated integer, value text)")
conn.executemany("INSERT INTO credential VALUES (?, ?, ?, ?, ?)", [
  ("c1", "opencode-go", 1, 2, json.dumps({"type": "key", "key": "store_key"})),
  ("c2", "opencode-go", 0, 3, json.dumps({"type": "key", "key": "inactive_key"})),
  ("c3", "opencode", 1, 1, json.dumps({"type": "oauth", "access": "console_token", "expires": ms_in(60), "metadata": {"orgID": "org_1"}})),
])
conn.commit()
conn.close()
found = load_collector("opencode").credential_candidates()
expect("OpenCode collector reads V2 credentials, the Console session last",
       [(c.token, c.url.endswith("/inference/go/v1/usage"), c.headers) for c in found],
       [("store_key", False, {}), ("console_token", True, {"x-opencode-org-id": "org_1"})])

# One value nested too deeply to parse (a RecursionError, not a ValueError)
# costs only its own entry: the database's other key and pi's still count.
DEEP = "[" * 100000 + "]" * 100000
(data_home() / "opencode" / "auth.json").write_text(DEEP)
pi_auth(None, "opencode", "from_pi")
conn = sqlite3.connect(db)
conn.execute("INSERT INTO credential VALUES ('c4', 'opencode-go', 1, 9, ?)", (DEEP,))
conn.commit()
conn.close()
with FakeHttp({ZEN: USAGE, CONSOLE: USAGE}):
  record = collect("opencode", "--force")
expect("OpenCode collector skips a credential nested too deeply to parse",
       [[c.token for c in load_collector("opencode").credential_candidates()], windows(record)],
       [["store_key", "from_pi", "console_token"], [("Rolling (5h)", 0.16), ("Weekly (7-day)", 0.06), ("Monthly", 0.29)]], record)
(data_home() / "opencode" / "auth.json").unlink()
(home() / ".pi" / "agent" / "auth.json").unlink()
conn = sqlite3.connect(db)
conn.execute("DELETE FROM credential WHERE id = 'c4'")
conn.commit()
conn.close()


def refuse_key(request):
  if "store_key" in request.get_header("Authorization"):
    return 401
  return {"usage": {"weekly": {"percent": 30, "resetsAt": "2999-01-01T00:00:00.000Z"}}}


with FakeHttp({ZEN: refuse_key, CONSOLE: refuse_key}) as http:
  record = collect("opencode", "--force")
asked = http.requests[-1]
expect("OpenCode collector hands a refused key over to the Console session",
       [windows(record), asked["url"], asked["headers"].get("authorization"), asked["headers"].get("x-opencode-org-id")],
       [[("Weekly (7-day)", 0.3)], "https://opencode.ai/inference/go/v1/usage", "Bearer console_token", "org_1"], record)

# Every way in refused, with the Console session expired, says so.
conn = sqlite3.connect(db)
conn.execute("UPDATE credential SET value = ? WHERE id = 'c3'", (json.dumps({"type": "oauth", "access": "console_token", "expires": 1000}),))
conn.commit()
conn.close()
for path in limits_cache_files("opencode"):
  path.unlink()
with FakeHttp(mode=401):
  record = collect("opencode", "--force")
check("OpenCode collector names an expired Console session",
      record["usageStatusText"] == "Sign-in expired" and "Console session has expired" in record["authHelpText"] and record["limits"] == [], record)
PY
