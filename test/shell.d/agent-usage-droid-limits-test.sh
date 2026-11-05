#!/bin/bash

# The Droid collector's limits: the login in the Secret Service keyring, the
# API-key fallback, an expired or unreadable login, the plan and balance kept
# with stale windows, the Core pool, and its adapter for the contract checks.
# The unused-machine record is held centrally by the partition test, the
# limits cache's mechanics by the shared test, and the local scan by the
# scanner test.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

# Fixtures only: a fixed Secret Service key and two AES-256-GCM envelopes
# sealed with it. Neither contains a real Factory credential.
KEY = "MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY="
VALID = "CQkJCQkJCQkJCQkJCQkJCQ==:Px6XANF5xoUo2rf2lx0z4w==:KFDADRm30+D+YKlrwl3hhBQTsNvpUft5WEodHre9G/R+zZQ+Gvmmj37yYA0wtDHd4u9pbeCJjS/GAF0dDD2bd31xxJL7ee0M0vZkQEbtCptBJdU8AwpwdfQaFN0FeHcrdYdnzGFfaGpWGGwOUCkXYnpJmJ6bJlHCA55k+jj7Uv9BXPwm"
EXPIRED = "BwcHBwcHBwcHBwcHBwcHBw==:48UClBsOagFSaHSL0cYJ9Q==:O5hmyFD2gd0sE0K+0edyjJ9Bb8iCt9tAiz5ltvds4tZr048sQdpsd8XkK4xZHyuqGwNyldegSTPML2I4YMEQgXH6/HQTVMhkXHkMcMKOr/RAAKzlf25//mbxhh/iZYGwdtQDFaVgEI48onn9URWlh/KcxQVdZlXO4OKFqDPcwV2jX9LdALee2U7+ZGSciWRGLvA3AXcMCKwek1o="
BASE_PATH = os.environ["PATH"]

LIMITS = {
  "usesTokenRateLimitsBilling": True,
  "hasActiveSubscription": True,
  "limits": {
    "standard": {
      "fiveHour": {"usedPercent": 2, "windowEnd": "2999-01-01T00:00:00Z", "secondsRemaining": 1000},
      "weekly": {"usedPercent": 5, "windowEnd": "2999-01-02T00:00:00Z", "secondsRemaining": 2000},
      "monthly": {"usedPercent": 3, "windowEnd": "2999-01-03T00:00:00Z", "secondsRemaining": 3000},
    },
    "core": {
      "fiveHour": {"usedPercent": 0, "windowEnd": None, "secondsRemaining": None},
      "weekly": {"usedPercent": 0, "windowEnd": None, "secondsRemaining": None},
      "monthly": {"usedPercent": 0, "windowEnd": None, "secondsRemaining": None},
    },
  },
  "overagePreference": "droidCore",
  "canManageOverage": True,
  "extraUsageBalanceCents": 500,
  "extraUsageAllowed": True,
}
ME = {"organization": {"subscription": {"factoryTier": "team", "orbSubscription": {"plan": {"name": "Factory Pro Plan"}}}}}
ROUTES = {"/api/billing/limits": LIMITS, "/api/app/auth/me": ME}


def clear_key():
  os.environ.pop("FACTORY_API_KEY", None)


def write_login(envelope):
  (home() / ".factory").mkdir(parents=True, exist_ok=True)
  (home() / ".factory" / "auth.v2.keyring").write_text(envelope + "\n")


def fake_secret_tool():
  stub = home() / "bin" / "secret-tool"
  stub.parent.mkdir(parents=True, exist_ok=True)
  stub.write_text(f'#!/bin/bash\nprintf "%s\\n" "{KEY}"\n')
  stub.chmod(0o755)
  os.environ["PATH"] = str(home() / "bin") + ":" + BASE_PATH


def plant(envelope=VALID):
  sandbox()
  clear_key()
  write_login(envelope)
  fake_secret_tool()


def plant_api_key():
  sandbox()
  clear_key()
  os.environ["FACTORY_API_KEY"] = "test-key"


def plant_unreadable():
  plant()
  (home() / ".factory" / "auth.v2.keyring").write_text("not-an-envelope\n")


def plant_non_keyring():
  sandbox()
  clear_key()
  (home() / ".factory").mkdir(parents=True, exist_ok=True)
  (home() / ".factory" / "auth.v2.file").write_text("{}\n")


def droid(answer=None, mode="up", *args):
  with FakeHttp(answer or ROUTES, mode=mode) as http:
    record = collect("droid", *(args or ("--force",)))
  return record, http


def labels(record):
  return [(entry["label"], entry["percent"]) for entry in record["limits"]]


# ---------------------------------------------------------------- contract

fresh = check_limits_contract(Adapter("droid", plant=plant, answer=ROUTES, requests_per_probe=2, refused_status="Limits paused"))
expect("Droid reports Factory's plan, Standard windows, and extra balance", {
  "tier": fresh["tierLabel"], "limits": labels(fresh), "balance": fresh["balance"],
}, {
  "tier": "Factory Pro Plan",
  "limits": [("Rolling (5h)", 0.02), ("Weekly (7-day)", 0.05), ("Monthly", 0.03)],
  "balance": {"remaining": 5.0, "funded": 0.0, "spent": 0.0, "currency": "USD", "estimated": False},
}, fresh)

# A failed check keeps the plan and balance beside the stale windows.
plant()
first, _ = droid()
fetched_at = first["limitsFetchedAt"]
stale, _ = droid(mode=500)
expect("Droid keeps its plan and balance when limits go stale", {
  "tier": stale["tierLabel"], "balance": stale["balance"], "stale": stale["limitsStale"],
  "fetched": stale["limitsFetchedAt"] == fetched_at, "status": stale["usageStatusText"], "retry": stale.get("retryAdvised"),
}, {
  "tier": "Factory Pro Plan", "balance": first["balance"], "stale": True,
  "fetched": True, "status": "", "retry": None,
}, stale)

# An expired login is never sent; the cached plan and balance stay.
write_login(EXPIRED)
expired, http = droid()
expect("Droid pauses an expired login without sending it", {
  "ready": expired["ready"], "status": expired["usageStatusText"], "limits": expired["limits"],
  "stale": expired["limitsStale"], "tier": expired["tierLabel"], "balance": expired["balance"],
  "requests": http.count, "help": "Run `droid` once" in expired["authHelpText"],
}, {
  "ready": True, "status": "Limits paused", "limits": first["limits"],
  "stale": True, "tier": "Factory Pro Plan", "balance": first["balance"],
  "requests": 0, "help": True,
}, expired)

# An unreadable keyring is a visible problem, not an unused machine.
plant_unreadable()
broken, http = droid()
expect("Droid reports an unreadable saved login", {
  "ready": broken["ready"], "status": broken["usageStatusText"], "requests": http.count,
  "help": "could not be read" in broken["authHelpText"],
}, {
  "ready": True, "status": "Droid limits unavailable", "requests": 0, "help": True,
}, broken)

# The API key is a fallback, not the primary path.
plant_api_key()
keyed, http = droid()
expect("Droid uses FACTORY_API_KEY when no login is readable", {
  "ready": keyed["ready"], "tier": keyed["tierLabel"], "limits": labels(keyed), "requests": http.count,
}, {
  "ready": True, "tier": "Factory Pro Plan",
  "limits": [("Rolling (5h)", 0.02), ("Weekly (7-day)", 0.05), ("Monthly", 0.03)], "requests": 2,
}, keyed)

# A login in another auth store is called out rather than guessed at.
plant_non_keyring()
other_store, http = droid()
expect("Droid names the non-keyring login store it cannot read", {
  "ready": other_store["ready"], "status": other_store["usageStatusText"], "requests": http.count,
  "help": "keyring" in other_store["authHelpText"],
}, {
  "ready": True, "status": "Droid limits unavailable", "requests": 0, "help": True,
}, other_store)

# Core windows are attached to the Standard rows, not drawn as duplicates.
plant()
core = json.loads(json.dumps(LIMITS))
core["limits"]["core"] = {
  "fiveHour": {"usedPercent": 25, "windowEnd": "2999-01-04T00:00:00Z", "secondsRemaining": 4000},
  "weekly": {"usedPercent": 0, "windowEnd": None, "secondsRemaining": None},
  "monthly": {"usedPercent": 0, "windowEnd": None, "secondsRemaining": None},
}
with_core, _ = droid({"api/billing/limits": core, "api/app/auth/me": ME})
expect("Droid titles active Core windows against their Standard rows", {
  "labels": [(entry["label"], entry.get("title")) for entry in with_core["limits"]],
}, {
  "labels": [
    ("Rolling (5h)", None), ("Weekly (7-day)", None), ("Monthly", None),
    ("Core Rolling (5h)", "Core Session"), ("Core Weekly (7-day)", "Core Weekly"), ("Core Monthly", "Core Monthly"),
  ],
}, with_core)

# The refresh token is a canary: it must never reach a record or a cache.
records = [json.dumps(fresh), json.dumps(stale), json.dumps(expired), json.dumps(keyed), json.dumps(with_core)]
caches = [path.read_text() for path in limits_cache_files("droid")]
check("Droid never writes the refresh-token canary to a record or cache",
      all("refresh-canary-must-not-be-read" not in text for text in records + caches))
PY
