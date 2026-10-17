#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command python3

unset DEEPSEEK_API_KEY DEEPSEEK_API_BASE_URL DSH_HOME PI_CODING_AGENT_DIR OPENCODE_DB

# The balance comes from DeepSeek's API, so the reader that interprets its
# answer is exercised on its own: the collector loads as a module, and a fake
# urlopen stands in for the response.
TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

COLLECTOR="$ROOT/bin/omarchy-agent-usage-deepseek" TEST_HOME="$TEST_HOME" python3 - <<'PY'
import importlib.machinery
import importlib.util
import io
import json
import os
import sys
import time
import urllib.error
from pathlib import Path

home = os.environ["TEST_HOME"]
# Never the real sign-ins: every store lives under the test home.
os.environ["HOME"] = os.path.join(home, "home")
os.environ["XDG_CACHE_HOME"] = os.path.join(home, "cache")
os.environ["XDG_DATA_HOME"] = os.path.join(home, "data")
os.environ["XDG_CONFIG_HOME"] = os.path.join(home, "config")
os.makedirs(os.environ["HOME"], exist_ok=True)

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

BASE = "https://api.deepseek.com"
cache_dir = Path(os.environ["XDG_CACHE_HOME"]) / "omarchy" / "agent-usage"


def check(description, condition, detail=""):
  if condition:
    print("ok - " + description)
    return
  print("not ok - " + description, file=sys.stderr)
  if detail:
    print(detail, file=sys.stderr)
  sys.exit(1)


asked = []


def answer(total="42.50", currency="CNY", error=None, body=None):
  def open_(request, timeout=None):
    asked.append((request.full_url, request.get_header("Authorization")))
    if error is not None:
      raise error
    if body is not None:
      return io.BytesIO(body)
    return io.BytesIO(json.dumps({
      "is_available": True,
      "balance_infos": [{"currency": currency, "total_balance": total, "granted_balance": "2.50", "topped_up_balance": "40.00"}],
    }).encode())
  return open_


def clear_cache():
  for cache in cache_dir.glob("deepseek-limits-*.json"):
    cache.unlink()


def record(force=True):
  return collector.collect(BASE, 0, force)


# Unused: no key and no local usage is a record the panel skips.
collector.urllib.request.urlopen = answer(error=RuntimeError("no key, no request"))
result = record()
check(
  "DeepSeek collector prints an empty record on an unused machine",
  result["ready"] is False and result["tierLabel"] == "" and "balance" not in result and result["limits"] == []
  and result["usageStatusText"] == "" and result["authHelpText"] == "" and "retryAdvised" not in result and asked == [],
  json.dumps(result),
)

os.environ["DEEPSEEK_API_KEY"] = "key-123"
collector.urllib.request.urlopen = answer()
result = record()
check(
  "DeepSeek collector reads the live balance",
  result["ready"] is True and result["tierLabel"] == "Prepaid" and result["balance"]["remaining"] == 42.5
  and result["balance"]["currency"] == "CNY" and result["balance"]["estimated"] is False
  and result["limitsStale"] is False and result["limitsFetchedAt"] > 0 and result["usageStatusText"] == ""
  and asked[-1] == ("https://api.deepseek.com/user/balance", "Bearer key-123"),
  json.dumps({"result": result, "asked": asked}),
)
fetched_at = result["limitsFetchedAt"]

# A panel that opens and shuts repeatedly must not ask every time.
asked.clear()
collector.urllib.request.urlopen = answer(error=RuntimeError("probe should have been skipped"))
result = record(force=False)
check(
  "DeepSeek collector reuses a balance it just read",
  asked == [] and result["balance"]["remaining"] == 42.5 and result["limitsStale"] is False and result["limitsFetchedAt"] == fetched_at,
  json.dumps(result),
)

collector.urllib.request.urlopen = answer(total="40.00")
result = record(force=True)
check(
  "DeepSeek collector --force asks past the reuse window",
  len(asked) == 1 and result["balance"]["remaining"] == 40.0,
  json.dumps(result),
)

# The estimated ledger comes from fundedAmount, applied to a kept balance too.
config = Path(os.environ["XDG_CONFIG_HOME"]) / "omarchy" / "agents"
config.mkdir(parents=True, exist_ok=True)
(config / "deepseek.json").write_text(json.dumps({"fundedAmount": 50}))
collector.urllib.request.urlopen = answer(total="8.15", currency="USD")
result = record()
check(
  "DeepSeek collector derives the estimated ledger from fundedAmount",
  result["balance"] == {"remaining": 8.15, "funded": 50.0, "spent": 41.85, "currency": "USD", "estimated": True},
  json.dumps(result),
)
fetched_at = result["limitsFetchedAt"]

# A failed check keeps the last good balance, marked stale with when it was
# read; only an unreachable service asks for a quick retry.
collector.urllib.request.urlopen = answer(error=urllib.error.URLError("no route"))
result = record()
check(
  "DeepSeek collector keeps the last balance, stale, when DeepSeek can't be reached",
  result["balance"]["remaining"] == 8.15 and result["balance"]["estimated"] is True and result["limitsStale"] is True
  and result["limitsFetchedAt"] == fetched_at and result["usageStatusText"] == "" and result.get("retryAdvised") is True
  and "Couldn't reach" in result["authHelpText"],
  json.dumps(result),
)

collector.urllib.request.urlopen = answer(error=TimeoutError("timed out"))
result = record()
check(
  "DeepSeek collector advises a retry on a timeout",
  result.get("retryAdvised") is True and result["limitsStale"] is True and "Couldn't reach" in result["authHelpText"],
  json.dumps(result),
)

collector.urllib.request.urlopen = answer(error=urllib.error.HTTPError(BASE, 500, "Server Error", {}, None))
result = record()
check(
  "DeepSeek collector doesn't advise a retry on a server error",
  "retryAdvised" not in result and result["limitsStale"] is True and "HTTP 500" in result["authHelpText"],
  json.dumps(result),
)

collector.urllib.request.urlopen = answer(body=b"<html>oops</html>")
result = record()
check(
  "DeepSeek collector reads a garbled answer as invalid, not unreachable",
  "retryAdvised" not in result and "invalid balance response" in result["authHelpText"] and result["limitsStale"] is True,
  json.dumps(result),
)

# A cache written before the clock went back is still the last good answer.
future = time.time() + 86400
cache = collector.balance_cache_path("key-123", BASE)
os.utime(cache, (future, future))
collector.urllib.request.urlopen = answer(error=urllib.error.URLError("no route"))
result = record()
check(
  "DeepSeek collector keeps a balance cache whose file time is in the future",
  result["balance"]["remaining"] == 8.15 and result["limitsStale"] is True,
  json.dumps(result),
)

# A refused key keeps its last balance, stale, and asks for a new sign-in.
collector.urllib.request.urlopen = answer(error=urllib.error.HTTPError(BASE, 401, "Unauthorized", {}, None))
result = record()
check(
  "DeepSeek collector asks for a new key when DeepSeek refuses it",
  result["usageStatusText"] == "Sign-in expired" and result["balance"]["remaining"] == 8.15 and result["limitsStale"] is True
  and "retryAdvised" not in result,
  json.dumps(result),
)

# With nothing kept, a failed check says the balance is unavailable.
clear_cache()
collector.urllib.request.urlopen = answer(error=urllib.error.HTTPError(BASE, 500, "Server Error", {}, None))
result = record()
check(
  "DeepSeek collector says the balance is unavailable with nothing kept",
  result["usageStatusText"] == "Balance unavailable" and "balance" not in result and result["limitsStale"] is False
  and result["limitsFetchedAt"] == 0 and result["ready"] is True and result["tierLabel"] == "Prepaid",
  json.dumps(result),
)

# Another key never shows this one's balance.
collector.urllib.request.urlopen = answer(total="1.00")
record()
os.environ["DEEPSEEK_API_KEY"] = "key-other"
collector.urllib.request.urlopen = answer(error=urllib.error.URLError("no route"))
result = record()
check(
  "DeepSeek collector keeps a balance per key",
  "balance" not in result and result["usageStatusText"] == "Balance unavailable" and result.get("retryAdvised") is True,
  json.dumps(result),
)

# Untrusted amounts read as nothing rather than as a number.
check(
  "DeepSeek collector reads untrusted amounts as zero",
  [float(collector.money(value)) for value in ("NaN", "Infinity", True, "abc", None, "3.5")] == [0.0, 0.0, 0.0, 0.0, 0.0, 3.5],
)
PY
