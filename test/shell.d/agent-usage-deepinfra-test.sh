#!/bin/bash

# The DeepInfra collector's own sources: the API key in
# ~/.config/omarchy/agents/deepinfra.json or DEEPINFRA_API_KEY, and
# DeepInfra's own billing API (GET /payment/checklist for the balance, GET
# /payment/usage for per-model token rows). The unused-machine record is
# held centrally by the partition test.
#
# DeepInfra has no percent-based limit windows -- only a balance and
# per-model usage -- so this collector's record never carries a non-empty
# `limits` list, which `check_limits_contract` assumes every collector has.
# It, and `check_scan_cache` (there is no local scan: both answers come
# straight off the billing API, cached the way Fireworks's collector caches
# its own balance and usage), don't fit here, the same shape gap that
# apparently leaves Fireworks, OpenRouter, Synthetic and DeepSeek without a
# dedicated test file in this tree today. This test exercises the same
# ground those helpers cover -- reuse, --force, staleness, an unreachable
# service, a refused credential -- by hand instead.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

# Despite the name, these are plain dollar amounts, not cents -- a real
# account's $5 prepaid credit reads back as stripe_balance -5.0, not -500.
# recent is usage since the last invoice, not yet deducted from that
# ledger: a real account with $0.26 of such usage had a true remaining
# balance of $4.74, not $5.00.
BALANCE_DOLLARS = {"stripe_balance": -5.0, "recent": 0.26}
USAGE_ITEMS = []


def checklist(request):
  token = request.get_header("Authorization").split(" ", 1)[1]
  if token != "good-key":
    raise FakeHttp.refusal(request.full_url, 401, b'{"detail":"bad key"}')
  return {**BALANCE_DOLLARS, "limit": None, "suspend_reason": None}


def usage(request):
  token = request.get_header("Authorization").split(" ", 1)[1]
  if token != "good-key":
    raise FakeHttp.refusal(request.full_url, 401, b'{"detail":"bad key"}')
  return {"initial_month": "2026.01", "months": [{
    "period": "2026.11", "interval": {"fr": ms_in(-86400), "to": ms_in(0)},
    "total_cost": 125, "invoice_id": "NOT_FINAL", "items": list(USAGE_ITEMS),
  }]}


ROUTES = {"/payment/checklist": checklist, "/payment/usage": usage}


def item(model, units, pricing_type="input_tokens", cost=0):
  return {
    "model": {"provider": "deepinfra", "model_name": model, "task": "text-generation"},
    "units": units, "rate": 0.0, "cost": cost, "pricing_type": pricing_type,
    "interval": {"fr": ms_in(-3600), "to": ms_in(0)},
  }


def write_key(config_dir=None):
  path = (Path(config_dir) if config_dir else config_home()) / "omarchy" / "agents" / "deepinfra.json"
  write_json(path, {"apiKey": "good-key"})


def deepinfra(*args):
  with FakeHttp(ROUTES):
    return collect("deepinfra", *(args or ("--force",)))


# ---------------------------------------------------------------- the home

sandbox()
record = deepinfra()
expect("a machine with no DeepInfra key is unready, with no balance", [record["ready"], "balance" in record], [False, False], record)

os.environ["DEEPINFRA_API_KEY"] = "good-key"
record = deepinfra()
expect("DEEPINFRA_API_KEY alone is enough to read the account",
       [record["ready"], record["tierLabel"], record["scope"], record["hasPromptStats"]], [True, "Pay-as-you-go", "account", False], record)
del os.environ["DEEPINFRA_API_KEY"]

sandbox()
write_key()
record = deepinfra()
expect("a key in deepinfra.json is read the same way", record["ready"], True, record)

# ------------------------------------------------------------- the balance

sandbox()
write_key()
record = deepinfra()
expect("a negative stripe_balance is the ledger credit; recent usage not yet invoiced against it is subtracted, not added",
       record["balance"], {"remaining": 4.74, "funded": 5.0, "spent": 0.26, "currency": "USD", "estimated": False}, record)

BALANCE_DOLLARS["stripe_balance"] = 3.0
record = deepinfra()
BALANCE_DOLLARS["stripe_balance"] = -5.0
expect("a positive stripe_balance reads as nothing ready to spend, never negative",
       record["balance"]["remaining"], 0.0, record)

# --------------------------------------------------------------- the usage

sandbox()
write_key()
USAGE_ITEMS.append(item("meta-llama/Llama-3.3-70B-Instruct", 1000, cost=50))
USAGE_ITEMS.append(item("stability-ai/sdxl", 42, pricing_type="second", cost=75))
record = deepinfra()
USAGE_ITEMS.clear()
expect("only token-metered rows count as tokens; a GPU-rental second row doesn't",
       [record["hasLocalStats"], record["modelUsage"], record["activeDays"]],
       [True, {"Llama-3.3-70B-Instruct": {"inputTokens": 1000, "outputTokens": 0, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}}, 1],
       record)

# ---------------------------------------------------------- the recent spend

# recentSpend is a dollar total, so unlike the token stats it counts every
# pricing_type, GPU rental included -- real money spent either way.
sandbox()
write_key()
USAGE_ITEMS.append(item("meta-llama/Llama-3.3-70B-Instruct", 1000, cost=50))
USAGE_ITEMS.append(item("stability-ai/sdxl", 42, pricing_type="second", cost=75))
record = deepinfra()
USAGE_ITEMS.clear()
expect("recentSpend sums cost across every pricing_type, in dollars, over a fixed 48-hour window",
       record["recentSpend"], {"amount": 1.25, "hours": 48, "currency": "USD", "estimated": False}, record)

# ---------------------------------------------------------------- caching

sandbox()
write_key()
fresh = deepinfra("--force")
reused, asked = None, None
with FakeHttp({"/payment/checklist": lambda r: (_ for _ in ()).throw(AssertionError("should not be asked")),
               "/payment/usage": lambda r: (_ for _ in ()).throw(AssertionError("should not be asked"))}):
  reused = collect("deepinfra")
expect("a normal run inside the probe interval reuses the fresh answer, asking nothing",
       [reused["balance"], reused["recentSpend"], reused["limitsFetchedAt"], reused["limitsStale"]],
       [fresh["balance"], fresh["recentSpend"], fresh["limitsFetchedAt"], False], reused)

forced = deepinfra("--force")
check("--force asks the service again even inside the probe interval", forced["limitsFetchedAt"] >= fresh["limitsFetchedAt"])

# ----------------------------------------------------------------- failure

sandbox()
write_key()
good = deepinfra("--force")
with FakeHttp(ROUTES, mode=500):
  kept = collect("deepinfra", "--force")
expect("a failed check (500) keeps the last balance and recent spend, stale, with no retry",
       [kept["balance"], kept["recentSpend"], kept["limitsStale"], kept.get("retryAdvised", False)],
       [good["balance"], good["recentSpend"], True, False], kept)
expect("a failed check reports no status text of its own", kept["usageStatusText"], "", kept)

with FakeHttp(ROUTES, mode="down"):
  unreachable = collect("deepinfra", "--force")
expect("an unreachable service advises a retry and keeps the balance stale",
       [unreachable["retryAdvised"], unreachable["limitsStale"]], [True, True], unreachable)

with FakeHttp(ROUTES, mode=401):
  refused = collect("deepinfra", "--force")
expect("a refused key says 'Sign-in expired' and advises no retry",
       [refused["usageStatusText"], refused.get("retryAdvised", False)], ["Sign-in expired", False], refused)

# A bad key with nothing ever cached has no balance to fall back on at all.
sandbox()
os.environ["DEEPINFRA_API_KEY"] = "good-key"
with FakeHttp(ROUTES, mode=401):
  refused_cold = collect("deepinfra", "--force")
del os.environ["DEEPINFRA_API_KEY"]
expect("a refused key with nothing cached shows no balance and isn't ready",
       [refused_cold["usageStatusText"], "balance" in refused_cold, refused_cold["ready"]], ["Sign-in expired", False, True], refused_cold)

# A 403 for a key missing the billing:read scope (confirmed live against a
# real account) isn't the key being wrong at all -- DeepInfra's own message
# is the one thing to do about it, so it replaces the generic help text
# rather than sitting beside it.
sandbox()
write_key()
deepinfra("--force")
with FakeHttp({"/payment/checklist": lambda r: FakeHttp.refusal(r.full_url, 403, b'{"detail":{"error":"this API key does not have the \'billing:read\' scope"}}'),
               "/payment/usage": lambda r: FakeHttp.refusal(r.full_url, 403, b'{"detail":{"error":"this API key does not have the \'billing:read\' scope"}}')}):
  scoped = collect("deepinfra", "--force")
expect("a key missing the billing:read scope surfaces DeepInfra's own message, not the generic one",
       [scoped["usageStatusText"], "billing:read" in scoped["authHelpText"], "DEEPINFRA_API_KEY" in scoped["authHelpText"]],
       ["Sign-in expired", True, False], scoped)
PY
