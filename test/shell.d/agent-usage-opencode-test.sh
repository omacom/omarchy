#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# Without credentials the collector must still print a full, hidden-by-default
# record: the update runner writes whatever valid JSON appears on stdout.
no_key=$(HOME="$TEST_HOME" XDG_DATA_HOME="$TEST_HOME/data" XDG_CACHE_HOME="$TEST_HOME/cache" OPENCODE_GO_API_KEY="" \
  "$ROOT/bin/omarchy-agent-usage-opencode")

[[ $(jq -r '.id + ":" + (.ready | tostring)' <<<"$no_key") == "opencode:false" ]] ||
  fail "OpenCode Go collector prints a valid record without credentials" "$no_key"
[[ $(jq -r '.authHelpText' <<<"$no_key") == *"account add opencode"* ]] ||
  fail "Keyless record points at the add command" "$no_key"
pass "OpenCode Go collector prints a valid record without credentials"

result=$(TEST_HOME="$TEST_HOME" python3 - "$ROOT/bin/omarchy-agent-usage-opencode" <<'PY'
import importlib.machinery
import importlib.util
import json
import os
import sqlite3
import sys
import time
from pathlib import Path

collector_path = str(Path(sys.argv[1]))
test_home = Path(os.environ["TEST_HOME"])

os.environ["HOME"] = str(test_home / "home")
os.environ["XDG_DATA_HOME"] = str(test_home / "data")
os.environ["XDG_CACHE_HOME"] = str(test_home / "cache")

loader = importlib.machinery.SourceFileLoader("opencode_collector", collector_path)
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

summary = {}

# ------------------------------------------------------------- key sources

os.environ["OPENCODE_GO_API_KEY"] = "oc_sk_env"
summary["envKeyWins"] = collector.api_key() == "oc_sk_env"
del os.environ["OPENCODE_GO_API_KEY"]

auth_dir = Path(os.environ["XDG_DATA_HOME"]) / "opencode"
auth_dir.mkdir(parents=True)
(auth_dir / "auth.json").write_text(json.dumps({
  "litellm": {"type": "api", "key": "other"},
  "opencode-go": {"type": "api", "key": "oc_sk_file"},
}))
summary["authFileKey"] = collector.api_key() == "oc_sk_file"

(auth_dir / "auth.json").write_text(json.dumps({"litellm": {"type": "api", "key": "other"}}))
summary["otherProvidersIgnored"] = collector.api_key() == ""

# ---------------------------------------------------------- window parsing

usage = {
  "usage": {
    "rolling": {"status": "ok", "percent": 4, "resetsAt": "2026-10-22T16:00:00Z"},
    "weekly": {"status": "ok", "percent": 0, "resetsAt": "2026-10-26T00:00:00Z"},
    "monthly": {"status": "rate-limited", "percent": 100, "resetsAt": "2026-11-01T00:00:00Z"},
  }
}
limits = collector.to_limits(usage)
by_label = {row["label"]: row for row in limits}
summary["labels"] = list(by_label) == ["Session (5-hour)", "Weekly (7-day)", "Monthly limit"]
summary["percentScaled"] = by_label["Session (5-hour)"]["percent"] == 0.04
# At 0% the gateway's resetsAt is a placeholder and must not render as a countdown.
summary["placeholderResetDropped"] = "resetsAt" not in by_label["Weekly (7-day)"]
# An exhausted window reports "rate-limited" and is exactly the one to show.
summary["rateLimitedKept"] = (
  by_label["Monthly limit"]["percent"] == 1.0
  and by_label["Monthly limit"]["resetsAt"] == "2026-11-01T00:00:00Z"
)

unknown_status = {"usage": {"rolling": {"status": "paused", "percent": 4}}}
try:
  collector.to_limits(unknown_status)
  summary["unknownStatusSkipped"] = False
except collector.GoError:
  summary["unknownStatusSkipped"] = True

# ------------------------------------------------------------------ balance

class FakeUsage:
  def __init__(self, responses):
    self.responses = responses

  def __call__(self, url, key):
    outcome = self.responses[url]
    if isinstance(outcome, Exception):
      raise outcome
    return outcome

real_fetch = collector.fetch_usage
try:
  collector.fetch_usage = FakeUsage({
    collector.BILLING_STATUS_URL: {"billingMode": "prepaid", "availableMicroCents": "674118061"},
  })
  balance = collector.fetch_balance("k")
  summary["billingStatusBalance"] = (
    balance is not None and balance["remaining"] == 6.74118061 and balance["estimated"] is False
  )

  # A key without Billing permission falls back to the member budget ledger.
  collector.fetch_usage = FakeUsage({
    collector.BILLING_STATUS_URL: collector.GoError("forbidden"),
    collector.BUDGETS_URL: [{"limit_micro_cents": "1000000000", "spent_micro_cents": "250000000"}],
  })
  balance = collector.fetch_balance("k")
  summary["budgetFallback"] = (
    balance is not None and balance["remaining"] == 7.5 and balance["funded"] == 10.0
  )

  # Uncapped member budget: no residual to compute, no ledger.
  collector.fetch_usage = FakeUsage({
    collector.BILLING_STATUS_URL: collector.GoError("forbidden"),
    collector.BUDGETS_URL: [{"limit_micro_cents": None, "spent_micro_cents": "325881939"}],
  })
  summary["uncappedShowsNothing"] = collector.fetch_balance("k") is None
finally:
  collector.fetch_usage = real_fetch

# -------------------------------------------------------------- local stats

summary["noDbNoStats"] = collector.scan_local_stats(False) is None

db_dir = Path(os.environ["XDG_DATA_HOME"]) / "opencode"
db_path = db_dir / "opencode.db"
conn = sqlite3.connect(db_path)
conn.execute("CREATE TABLE session_message (session_id TEXT, data TEXT, type TEXT)")
now_ms = int(time.time() * 1000)


def message(provider, model, tokens):
  return json.dumps({
    "model": {"providerID": provider, "id": model},
    "tokens": tokens,
    "time": {"created": now_ms},
  })


conn.execute(
  "INSERT INTO session_message VALUES (?, ?, ?)",
  ("ses_1", message("opencode-go", "glm-5.3", {"input": 10, "output": 5, "reasoning": 2, "cache": {"read": 3, "write": 1}}), "assistant"),
)
# Other providers and non-assistant rows are not this subscription's traffic.
conn.execute(
  "INSERT INTO session_message VALUES (?, ?, ?)",
  ("ses_2", message("anthropic", "claude", {"input": 99, "output": 99}), "assistant"),
)
conn.execute(
  "INSERT INTO session_message VALUES (?, ?, ?)",
  ("ses_1", message("opencode-go", "glm-5.3", {}), "user"),
)
conn.commit()
conn.close()

stats = collector.scan_local_stats(False)
summary["goTrafficCounted"] = (
  stats is not None
  and stats["totalPrompts"] == 1
  and stats["totalSessions"] == 1
  and stats["todayTotalTokens"] == 21
  and stats["modelUsage"]["glm-5.3"]["inputTokens"] == 10
  and stats["modelUsage"]["glm-5.3"]["cacheReadInputTokens"] == 3
)

# --limits-only reuses today's cached stats, however old, but a cache written
# yesterday no longer describes "today" and the database is scanned again.
import hashlib

cache_file = Path(os.environ["XDG_CACHE_HOME"]) / "omarchy" / "agent-usage" / (
  "opencode-go-stats-" + hashlib.sha1(str(db_path).encode("utf-8")).hexdigest()[:16] + ".json"
)
collector.write_json(cache_file, {"stats": None})
summary["limitsOnlyUsesTodaysCache"] = collector.scan_local_stats(True) is None
yesterday = time.time() - 86400
os.utime(cache_file, (yesterday, yesterday))
summary["yesterdaysCacheRescans"] = collector.scan_local_stats(True) is not None

print(json.dumps(summary))
PY
)

failures=$(jq -r 'to_entries | map(select(.value != true) | .key) | .[]' <<<"$result")
if [[ -n $failures ]]; then
  fail "OpenCode Go collector behavior" "$failures"
else
  pass "OpenCode Go collector behavior"
fi
