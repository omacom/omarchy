#!/bin/bash

# The Moonshot collector's prepaid balance: Moonshot's balance answer, with
# no funded figure, and the balance kept past a failed check. A balance has
# no windows, so check_limits_contract (which holds limits) doesn't apply;
# the same contract is held for the balance here. The unused-machine record
# is held centrally by the partition test, the limits cache's mechanics by
# the shared test, and the scan cache by the stats tests.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

BALANCE = "/v1/users/me/balance"
answer = {"remaining": 19.81}


def balance(request):
  remaining = answer.get("remaining", 19.81)
  return {"code": 0, "status": True, "data": {
    "available_balance": remaining, "voucher_balance": 0, "cash_balance": remaining,
  }}


def moonshot(mode="up", args=("--force",)):
  with FakeHttp({BALANCE: balance}, mode=mode) as http:
    record = collect("moonshot", *args)
  return record, http


def balance_caches():
  return sorted(cache_root().glob("moonshot-limits-*.json"))


sandbox()
# The spend replies are dated today: hold "today" to the day the run began,
# so a run across local midnight still lands their costs in the last bar.
freeze_today()

# No key, no request: a machine with no Moonshot key prints the empty
# record the panel skips.
record, http = moonshot()
expect("Moonshot collector asks Moonshot nothing without a key",
       [http.count, record["ready"], "balance" in record, record["tierLabel"], record["usageStatusText"]],
       [0, False, False, "", ""], record)

os.environ["MOONSHOT_API_KEY"] = "key-123"
record, http = moonshot()
check("Moonshot collector reads Moonshot's live balance, asking with the key",
      record["ready"] is True and record["tierLabel"] == "Prepaid" and record["balance"]["remaining"] == 19.81
      and record["balance"]["currency"] == "USD" and record["balance"]["estimated"] is False
      and record["limits"] == [] and record["limitsStale"] is False and record["limitsFetchedAt"] > 0
      and record["usageStatusText"] == ""
      and [(r["url"], r["headers"].get("authorization")) for r in http.requests]
      == [("https://api.moonshot.ai/v1/users/me/balance", "Bearer key-123")],
      record)
fetched_at = record["limitsFetchedAt"]

# A panel that opens and shuts repeatedly must not ask every time, a
# --limits-only run included.
for args in ((), ("--limits-only",)):
  record, http = moonshot(500, args)
  check(f"Moonshot collector reuses a balance it just read on a {'--limits-only' if args else 'normal'} run",
        http.count == 0 and record["balance"]["remaining"] == 19.81 and record["limitsStale"] is False
        and record["limitsFetchedAt"] == fetched_at, record)

answer["remaining"] = 20.5
record, http = moonshot()
expect("Moonshot collector --force asks past the reuse window", [http.count, record["balance"]["remaining"]], [1, 20.5], record)

# Moonshot says what is left, never what was bought: the balance has no
# funded figure and no spend of its own.
expect("Moonshot collector shows the remaining balance with no funded figure",
       record["balance"], {"remaining": 20.5, "funded": 0.0, "spent": 0.0, "currency": "USD", "estimated": False}, record)
fetched_at = record["limitsFetchedAt"]

# A failed check keeps the last good balance, marked stale with when it was
# read; only an unreachable service asks for a quick retry.
cases = {
  "can't be reached": ("down", True, "Couldn't reach", ""),
  "times out": ("timeout", True, "Couldn't reach", ""),
  "answers with a server error": (500, False, "HTTP 500", ""),
  "sends a garbled answer": ("garbage", False, "invalid balance response", ""),
  # A refused key asks for a new sign-in.
  "refuses the key": (401, False, "", "Sign-in expired"),
}
for name, (mode, retry, help_text, status) in cases.items():
  record, _ = moonshot(mode)
  if status == "Sign-in expired":
    # A refused key is its own trouble: it says so, and the last good balance
    # stays on show, stale, as DeepSeek's does.
    check(f"Moonshot collector says the sign-in expired when Moonshot {name}",
          record["usageStatusText"] == status and record["balance"]["remaining"] == 20.5
          and record["limitsStale"] is True, record)
    continue
  check(f"Moonshot collector keeps the last balance, stale, when Moonshot {name}",
        record["balance"]["remaining"] == 20.5 and record["limitsStale"] is True
        and record["limitsFetchedAt"] == fetched_at and record["usageStatusText"] == status
        and bool(record.get("retryAdvised")) is retry and help_text in record["authHelpText"], record)

# With nothing kept, a failed check says the balance is unavailable.
for path in balance_caches():
  path.unlink()
record, _ = moonshot(500)
check("Moonshot collector says the balance is unavailable with nothing kept",
      record["usageStatusText"] == "Balance unavailable" and "balance" not in record
      and record["limitsStale"] is False and record["limitsFetchedAt"] == 0
      and record["ready"] is True and record["tierLabel"] == "Prepaid", record)

# Another key never shows this one's balance.
moonshot()
os.environ["MOONSHOT_API_KEY"] = "key-other"
record, _ = moonshot("down")
check("Moonshot collector keeps a balance per key",
      "balance" not in record and record["usageStatusText"] == "Balance unavailable"
      and record.get("retryAdvised") is True, record)

# An answer without a readable available_balance is a failed check, not a
# balance of zero: it never replaces the last good one.
del os.environ["MOONSHOT_API_KEY"]
os.environ["MOONSHOT_API_KEY"] = "key-123"
moonshot()
for shape in ({}, {"data": {}}, {"data": {"available_balance": None}},
              {"data": {"available_balance": True}}, {"data": {"available_balance": "abc"}},
              {"data": {"available_balance": -1}}, {"data": {"available_balance": "1e400"}}):
  with FakeHttp({BALANCE: shape}):
    record = collect("moonshot", "--force")
  check(f"Moonshot collector keeps the last balance, stale, when Moonshot answers {shape}",
        record["balance"]["remaining"] == 20.5 and record["limitsStale"] is True
        and "balance response" in record["authHelpText"], record)

# MOONSHOT_API_BASE_URL moves the endpoint, never the key onto plain HTTP to
# another machine, nor into a URL that isn't one.
for url in ("http://evil.example", "not a url"):
  os.environ["MOONSHOT_API_BASE_URL"] = url
  record, http = moonshot()
  expect(f"Moonshot collector sends its key to no untrusted endpoint ({url})",
         [http.count, record["usageStatusText"], "HTTPS" in record["authHelpText"]],
         [0, "Balance unavailable", True], record)
del os.environ["MOONSHOT_API_BASE_URL"]

# A zero balance is the wallet saying it no longer covers API calls: the
# status says so, live and from the kept answer, since with no funded figure
# the gauge can't raise the alarm itself.
sandbox()
os.environ["MOONSHOT_API_KEY"] = "key-123"
answer["remaining"] = 0
record, _ = moonshot()
expect("Moonshot says out of credits when the balance is zero",
       [record["balance"]["remaining"], record["usageStatusText"], record["authHelpText"]],
       [0.0, "Out of credits", load_collector("moonshot").OUT_OF_CREDITS_HELP], record)
answer["remaining"] = 19.81
record, _ = moonshot("down")
check("Moonshot keeps the out-of-credits status while the wallet can't be asked",
      record["usageStatusText"] == "Out of credits" and record["balance"]["remaining"] == 0.0
      and record["limitsStale"] is True, record)

# The key the agents keep: pi's, where PI_CODING_AGENT_DIR moves it, omp's,
# and opencode's, each naming the wallet its provider does.
sandbox()


def credential():
  return load_collector("moonshot").api_key()


pi_auth(home() / ".omp" / "agent", "moonshot", "key-omp")
expect("Moonshot collector reads the Moonshot key omp saved", credential(), ("key-omp", "https://api.moonshot.ai"))
pi_auth(None, "moonshotai", "key-pi")
expect("Moonshot collector prefers the key pi saved", credential(), ("key-pi", "https://api.moonshot.ai"))
os.environ["PI_CODING_AGENT_DIR"] = str(home() / "pi-moved")
pi_auth(home() / "pi-moved", "moonshotai-cn", "key-cn")
expect("Moonshot collector reads pi's key where PI_CODING_AGENT_DIR moves it, on the China wallet",
       credential(), ("key-cn", "https://api.moonshot.cn"))
pi_auth(home() / "pi-moved", "moonshotai", "!pass show moonshot")
pi_auth(home() / "pi-moved", "moonshotai-cn", "$MOONSHOT_KEY")
(home() / ".omp" / "agent" / "auth.json").unlink()
expect("Moonshot collector never takes a pi !command or $VAR entry as a key", credential(), ("", ""))
opencode_auth(None, "moonshotai", "key-opencode")
expect("Moonshot collector reads the key opencode saved", credential(), ("key-opencode", "https://api.moonshot.ai"))
pi_auth(home() / "pi-moved", "moonshotai", "key-pi")
expect("Moonshot collector prefers pi's key to opencode's", credential(), ("key-pi", "https://api.moonshot.ai"))

# Pay-as-you-go: the costs pi and opencode wrote beside each Moonshot reply
# add up to the last 30 days' spend, a day at a time, as an estimate. Another
# provider's cost never counts, and replies with no cost add no spend at all.
sandbox()
os.environ["MOONSHOT_API_KEY"] = "key-123"
record, _ = moonshot()
expect("Moonshot replies without a cost add no spend", "spend" in record, False, record)
write_pi_session(home() / ".pi" / "agent" / "sessions" / "project" / "pi.jsonl", [
  pi_reply("moonshotai", id="pi-1", usage={"input": 10, "cost": {"total": 0.25}}),
  pi_reply("anthropic", id="pi-2", usage={"input": 10, "cost": {"total": 9}}),
])
opencode_db(tables=("message",), message=[
  ("m-1", "ses_1", json.dumps({**json.loads(oc_v1("moonshotai", {"input": 10})), "cost": 0.5})),
])
record, _ = moonshot()
expect("Moonshot adds up the last 30 days' local Moonshot reply costs, by day, as an estimate", record.get("spend"),
       {"amount": 0.75, "cap": 0.0, "currency": "USD", "days": [0.0] * 29 + [0.75], "estimated": True}, record)

# Kimi Code can send its requests to Moonshot's API: those requests and
# their prompts count here, while the requests Kimi Code sent to its own plan
# stay Kimi's. A route change to a self-hosted server leaves both behind.
sandbox()
os.environ["MOONSHOT_API_KEY"] = "key-123"
config = home() / ".kimi-code" / "config.toml"
config.parent.mkdir(parents=True, exist_ok=True)
config.write_text("""[providers.moon]
type = "kimi"
base_url = "https://api.moonshot.ai/v1"

[models."moon/kimi-k2"]
provider = "moon"
model = "kimi-k2"
""")
wire = home() / ".kimi-code" / "sessions" / "wd_p_1" / "session_1" / "agents" / "main" / "wire.jsonl"
wire.parent.mkdir(parents=True, exist_ok=True)
now = int(fixture_now().timestamp() * 1000)
with wire.open("w") as handle:
  handle.write(json.dumps({"type": "metadata", "protocol_version": "1.5", "created_at": now}) + "\n")
  handle.write(json.dumps({"type": "profile.bind", "agentId": "main", "modelAlias": "moon/kimi-k2", "time": now}) + "\n")
  handle.write(json.dumps({"type": "llm.request", "agentId": "main", "modelAlias": "moon/kimi-k2", "time": now}) + "\n")
  handle.write(json.dumps({"type": "turn.prompt", "agentId": "main", "input": [{"type": "text", "text": "hi"}], "origin": {"kind": "user"}, "promptId": "p1", "turnId": 0, "time": now}) + "\n")
  handle.write(json.dumps({"type": "usage.record", "agentId": "main", "model": "moon/kimi-k2", "usage": {"inputOther": 100, "output": 20, "inputCacheRead": 5, "inputCacheCreation": 2}, "usageScope": "turn", "time": now}) + "\n")
record, _ = moonshot()
expect("Moonshot counts Kimi Code requests sent to Moonshot's API, with their prompts",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"]],
       [{"moon/kimi-k2": 127}, 1, 1], record)

# A route change to a server you run leaves nothing here, and the cached scan
# follows it at once.
config.write_text("""[providers.moon]
type = "kimi"
base_url = "http://localhost:8000/v1"

[models."moon/kimi-k2"]
provider = "moon"
model = "kimi-k2"
""")
record, _ = moonshot()
expect("Moonshot counts no Kimi Code requests once the route is self-hosted",
       [record["todayTotalTokens"], record["todayPrompts"]], [0, 0], record)

# The China wallet answers in yuan and is asked on its own host, so a key
# saved there never reads as a US balance.
sandbox()
pi_auth(None, "moonshotai-cn", "key-cn")
record, http = moonshot()
expect("Moonshot collector asks the China wallet on its own host, in yuan",
       [http.requests[0]["url"], record["balance"]["currency"]],
       ["https://api.moonshot.cn/v1/users/me/balance", "CNY"], record)

# A balance never rolls back one another run stamped while this one waited on
# the network.
def later_run(request):
  for path in balance_caches():
    data = json.loads(path.read_text())
    data["fetchedAtMs"] = ms_in(60)
    path.write_text(json.dumps(data))
  return balance(request)


for path in balance_caches():
  path.unlink()
moonshot()
with FakeHttp({BALANCE: later_run}):
  collect("moonshot", "--force")
expect("Moonshot collector never overwrites a newer cached balance with its own",
       [json.loads(path.read_text())["fetchedAtMs"] > ms_in(30) for path in balance_caches()], [True])

PY
