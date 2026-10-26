#!/bin/bash

# The DeepSeek collector's prepaid balance: DeepSeek's balance answer, the
# estimated ledger a funded amount adds, and the balance kept past a failed
# check. A balance has no windows, so check_limits_contract (which holds
# limits) doesn't apply; the same contract is held for the balance here. The
# unused-machine record is held centrally by the partition test, the limits
# cache's mechanics by the shared test, and the scan cache by the scanner
# test.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

BALANCE = "api.deepseek.com/user/balance"
answer = {"total": "42.50", "currency": "CNY"}


def balance(request):
  return {"is_available": True, "balance_infos": [
    {"currency": answer["currency"], "total_balance": answer["total"], "granted_balance": "2.50", "topped_up_balance": "40.00"},
  ]}


def deepseek(mode="up", args=("--force",)):
  with FakeHttp({BALANCE: balance}, mode=mode) as http:
    record = collect("deepseek", *args)
  return record, http


sandbox()

# No key, no request: local usage alone never reaches DeepSeek.
record, http = deepseek()
expect("DeepSeek collector asks nothing without a key", [http.count, "balance" in record], [0, False], record)

os.environ["DEEPSEEK_API_KEY"] = "key-123"
record, http = deepseek()
check("DeepSeek collector reads the live balance, asking with the key",
      record["ready"] is True and record["tierLabel"] == "Prepaid" and record["balance"]["remaining"] == 42.5
      and record["balance"]["currency"] == "CNY" and record["balance"]["estimated"] is False
      and record["limitsStale"] is False and record["limitsFetchedAt"] > 0 and record["usageStatusText"] == ""
      and [(r["url"], r["headers"].get("authorization")) for r in http.requests] == [("https://api.deepseek.com/user/balance", "Bearer key-123")],
      record)
fetched_at = record["limitsFetchedAt"]

# A panel that opens and shuts repeatedly must not ask every time, a
# --limits-only run included.
for args in ((), ("--limits-only",)):
  record, http = deepseek(500, args)
  check(f"DeepSeek collector reuses a balance it just read on a {'--limits-only' if args else 'normal'} run",
        http.count == 0 and record["balance"]["remaining"] == 42.5 and record["limitsStale"] is False and record["limitsFetchedAt"] == fetched_at,
        record)

answer["total"] = "40.00"
record, http = deepseek()
expect("DeepSeek collector --force asks past the reuse window", [http.count, record["balance"]["remaining"]], [1, 40.0], record)

# The estimated ledger comes from fundedAmount, applied to a kept balance too.
write_json(config_home() / "omarchy" / "agents" / "deepseek.json", {"fundedAmount": 50})
answer.update(total="8.15", currency="USD")
record, _ = deepseek()
expect("DeepSeek collector derives the estimated ledger from fundedAmount",
       record["balance"], {"remaining": 8.15, "funded": 50.0, "spent": 41.85, "currency": "USD", "estimated": True}, record)
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
  record, _ = deepseek(mode)
  check(f"DeepSeek collector keeps the last balance, stale, when DeepSeek {name}",
        record["balance"]["remaining"] == 8.15 and record["balance"]["estimated"] is True and record["limitsStale"] is True
        and record["limitsFetchedAt"] == fetched_at and record["usageStatusText"] == status
        and bool(record.get("retryAdvised")) is retry and help_text in record["authHelpText"], record)

# With nothing kept, a failed check says the balance is unavailable.
for path in limits_cache_files("deepseek"):
  path.unlink()
record, _ = deepseek(500)
check("DeepSeek collector says the balance is unavailable with nothing kept",
      record["usageStatusText"] == "Balance unavailable" and "balance" not in record and record["limitsStale"] is False
      and record["limitsFetchedAt"] == 0 and record["ready"] is True and record["tierLabel"] == "Prepaid", record)

# Another key never shows this one's balance.
deepseek()
os.environ["DEEPSEEK_API_KEY"] = "key-other"
record, _ = deepseek("down")
check("DeepSeek collector keeps a balance per key",
      "balance" not in record and record["usageStatusText"] == "Balance unavailable" and record.get("retryAdvised") is True, record)

# An answer without a readable total_balance is a failed check, not a balance
# of zero: it keeps the last balance, stale, and never replaces it.
deepseek()
# A total too large for the record's number is as unreadable as no total.
for incomplete in ([{}], [{"currency": "USD", "total_balance": None}], [{"total_balance": "NaN"}], [{"total_balance": True}], [{"total_balance": "1e400"}]):
  with FakeHttp({BALANCE: {"is_available": True, "balance_infos": incomplete}}):
    record = collect("deepseek", "--force")
  check(f"DeepSeek collector keeps the last balance, stale, when DeepSeek answers {incomplete}",
        record["balance"]["remaining"] == 8.15 and record["limitsStale"] is True and record["usageStatusText"] == ""
        and "total_balance" in record["authHelpText"], record)
  record, _ = deepseek(500)
  expect(f"DeepSeek collector never caches {incomplete} over the last balance", [record["balance"]["remaining"], record["limitsStale"]], [8.15, True], record)

# DEEPSEEK_API_BASE_URL moves the endpoint, never the key onto plain HTTP to
# another machine, nor into a URL that isn't one.
for url in ("http://evil.example", "not a url"):
  os.environ["DEEPSEEK_API_BASE_URL"] = url
  record, http = deepseek()
  expect(f"DeepSeek collector sends its key to no untrusted endpoint ({url})",
         [http.count, record["usageStatusText"], "HTTPS" in record["authHelpText"]], [0, "Balance unavailable", True], record)
del os.environ["DEEPSEEK_API_BASE_URL"]

# A balance never rolls back one another run stamped while this one waited on
# the network.
def later_run(request):
  edit_limits_cache("deepseek", fetched_ago=-60)
  return balance(request)


for path in limits_cache_files("deepseek"):
  path.unlink()
deepseek()
with FakeHttp({BALANCE: later_run}):
  collect("deepseek", "--force")
expect("DeepSeek collector never overwrites a newer cached balance with its own",
       [json.loads(path.read_text())["fetchedAtMs"] > ms_in(30) for path in limits_cache_files("deepseek")], [True])

# Untrusted amounts read as nothing rather than as a number.
expect("DeepSeek collector reads untrusted amounts as zero",
       [float(load_collector("deepseek").money(value)) for value in ("NaN", "Infinity", "1e400", True, "abc", None, "3.5")], [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.5])

# The key pi keeps, where PI_CODING_AGENT_DIR moves it, or omp's. Only a
# literal key: a `!command` or `$VAR` entry is pi's to resolve, never sent.
sandbox()


def saved_key():
  return load_collector("deepseek").api_key()


pi_auth(home() / ".omp" / "agent", "deepseek", "key-omp")
expect("DeepSeek collector reads the key omp saved", saved_key(), "key-omp")
pi_auth(None, "deepseek", "key-pi")
expect("DeepSeek collector prefers the key pi saved", saved_key(), "key-pi")
os.environ["PI_CODING_AGENT_DIR"] = str(home() / "pi-moved")
pi_auth(home() / "pi-moved", "deepseek", "key-moved")
expect("DeepSeek collector reads pi's key where PI_CODING_AGENT_DIR moves it", saved_key(), "key-moved")
pi_auth(home() / "pi-moved", "deepseek", "!pass show deepseek")
pi_auth(home() / ".omp" / "agent", "deepseek", "$DEEPSEEK_KEY")
expect("DeepSeek collector never takes a pi !command or $VAR entry as a key", saved_key(), "")
opencode_auth(None, "deepseek", "key-opencode")
expect("DeepSeek collector reads the key opencode saved", saved_key(), "key-opencode")
pi_auth(home() / ".omp" / "agent", "deepseek", "key-omp")
expect("DeepSeek collector prefers omp's key to opencode's", saved_key(), "key-omp")

# The balance is kept per API host: another host, the same key or not, is
# another account, and never shows this one's balance.
sandbox()
os.environ["DEEPSEEK_API_KEY"] = "key-123"
deepseek()
with FakeHttp(mode="down") as http:
  other = collect("deepseek", "--force", "--api-base-url", "https://deepseek.example")
record, _ = deepseek("down")
expect("DeepSeek collector keeps one key's balance per API host",
       [http.requests[0]["url"], "balance" in other, other["usageStatusText"], record["balance"]["remaining"], record["limitsStale"]],
       ["https://deepseek.example/user/balance", False, "Balance unavailable", float(answer["total"]), True], other)

# balance_infos holds one entry per currency, CNY or USD (DeepSeek's
# get-user-balance reference): the funded one is the balance, so an empty CNY
# entry never reads as an empty account beside USD credit.
sandbox()
os.environ["DEEPSEEK_API_KEY"] = "key-123"
with FakeHttp({BALANCE: {"is_available": True, "balance_infos": [
  {"currency": "CNY", "total_balance": "0.00", "granted_balance": "0.00", "topped_up_balance": "0.00"},
  {"currency": "USD", "total_balance": "12.50", "granted_balance": "0.00", "topped_up_balance": "12.50"},
]}}):
  record = collect("deepseek", "--force")
expect("DeepSeek collector reads the currency that holds the credit",
       [record["balance"]["remaining"], record["balance"]["currency"], record["usageStatusText"]], [12.5, "USD", ""], record)

# is_available false is DeepSeek saying the balance no longer covers a call:
# with no funded figure the gauge raises no alarm, so the status does, and a
# reused answer keeps saying so.
with FakeHttp({BALANCE: {"is_available": False, "balance_infos": [
  {"currency": "CNY", "total_balance": "0.00", "granted_balance": "0.00", "topped_up_balance": "0.00"},
]}}):
  record = collect("deepseek", "--force")
expect("DeepSeek collector reads an unavailable balance as Out of credits",
       [record["balance"]["remaining"], record["usageStatusText"], "Top up" in record["authHelpText"], record.get("retryAdvised")],
       [0.0, "Out of credits", True, None], record)
record, http = deepseek(500, ())
expect("DeepSeek collector keeps saying Out of credits from the balance it reuses", [http.count, record["usageStatusText"]], [0, "Out of credits"], record)
PY
