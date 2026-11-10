#!/bin/bash

# The Fireworks collector's own sources: the key from FIREWORKS_API_KEY,
# firectl's auth.ini, or a pi or opencode login; the billing API's usage
# buckets, paged; and this month's spend and the rate-limit tier, from the
# account's quota and the account itself. The unused-machine record is held
# centrally by the partition test.
#
# Fireworks keeps a spend and no limit windows, and reuses its usage rows
# through a limits cache rather than a scan cache, so neither contract check
# fits it as they stand: check_spend_contract below holds the spend to the
# same probe contract, and the usage reuse windows have a check of their own.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

# Bucket dates resolve in local time, so pin the zone or the fixtures below
# would shift by a day depending on where the test runs.
export TZ=UTC

python3 - <<'PY'
from agent_usage_fixtures import *
from datetime import date, datetime, timezone

API = "https://api.fireworks.ai"
TODAY = time.strftime("%Y-%m-%d")
ROWS = [{"startTime": TODAY + "T00:00:00Z", "promptTokens": "100", "completionTokens": "20", "group": {"model_name": "accounts/fireworks/models/kimi-k2p5"}}]
SPEND = {"name": "accounts/example/quotas/monthly-spend-usd", "usage": 7.5, "value": "50"}
# Today's rated cost, the only day this month with any.
COSTS = {"rows": [{"dimensions": {"startTime": TODAY + "T00:00:00Z"}, "subtotal": {"units": "1", "nanos": 250000000}}]}
DAYS = [0.0] * 29 + [1.25]
# The bare account route goes last: routes match by substring, in order.
ROUTES = {
  "/quotas/monthly-spend-usd": SPEND,
  "/usageCosts:query": COSTS,
  "/billingUsage": {"serverlessCosts": ROWS},
  "/v1/accounts/example": {"name": "accounts/example", "ratelimitTier": 2},
}


def signed_in(key="fw_test"):
  auth = home() / ".fireworks" / "auth.ini"
  auth.parent.mkdir(parents=True, exist_ok=True)
  auth.write_text(f"[default]\napi_key = {key}\naccount_id = example\n")


def fireworks(*args, routes=None, mode="up", force=True, **env):
  saved = dict(os.environ)
  os.environ.update(env)
  try:
    with FakeHttp(ROUTES if routes is None else routes, mode=mode) as http:
      record = collect("fireworks", *(args or (("--force",) if force else ())))
  finally:
    os.environ.clear()
    os.environ.update(saved)
  fireworks.asked = ["usage" if "/billingUsage" in request["url"] else "spend" for request in http.requests]
  return record


# check_limits_contract held to the spend instead of limit windows: a fresh
# probe, the 15-second reuse for a normal and a --limits-only run, --force, a
# failed check, an answer cut short or garbled and an unreachable service
# keeping the last spend stale, and a refused key. A candidate for the
# shared fixtures.
def check_spend_contract(plant, per_probe):
  for path in limits_cache_files("fireworks"):
    path.unlink()
  plant()
  fresh = fireworks()
  check("fireworks: a fresh spend is live, stamped, healthy, and asked for once per probe",
        "spend" in fresh and fresh["limitsStale"] is False and fresh["limitsFetchedAt"] > 0 and fresh["usageStatusText"] == ""
        and fresh["authHelpText"] == "" and not fresh.get("retryAdvised") and len(fireworks.asked) == per_probe, json.dumps(fresh))
  for args in ((), ("--limits-only",)):
    reused = fireworks(*args, mode=500, force=False)
    check(f"fireworks: a {'--limits-only' if args else 'normal'} run inside the probe interval reuses the answer, live",
          fireworks.asked == [] and reused.get("spend") == fresh["spend"] and reused["limitsFetchedAt"] == fresh["limitsFetchedAt"]
          and reused["limitsStale"] is False and reused["usageStatusText"] == "", json.dumps(reused))
  forced = fireworks()
  check("fireworks: --force asks again inside the probe interval", len(fireworks.asked) == per_probe and forced["limitsStale"] is False, json.dumps(forced))
  kept = fireworks(mode=500)
  check("fireworks: a failed check keeps the last spend, stale, with when it was measured",
        kept.get("spend") == forced["spend"] and kept["limitsStale"] is True and kept["limitsFetchedAt"] == forced["limitsFetchedAt"]
        and kept["usageStatusText"] == "" and not kept.get("retryAdvised"), json.dumps(kept))
  for mode in ("cut", "garbage"):
    answered = fireworks(mode=mode)
    check(f"fireworks: an answer {'cut short' if mode == 'cut' else 'that is not JSON'} keeps the last spend, stale, and advises no retry",
          answered.get("spend") == forced["spend"] and answered["limitsStale"] is True and answered["limitsFetchedAt"] == forced["limitsFetchedAt"]
          and answered["usageStatusText"] == "" and not answered.get("retryAdvised"), json.dumps(answered))
  for mode in ("down", "timeout"):
    unreachable = fireworks(mode=mode)
    check(f"fireworks: an unreachable service ({mode}) advises a retry and keeps the last spend, stale",
          unreachable.get("retryAdvised") is True and unreachable.get("spend") == forced["spend"] and unreachable["limitsStale"] is True
          and unreachable["usageStatusText"] == "", json.dumps(unreachable))
  refused = fireworks(mode=401)
  check("fireworks: a refused key says 'Sign-in expired', advises no retry, and shows nothing as live",
        refused["usageStatusText"] == "Sign-in expired" and not refused.get("retryAdvised") and refused["limitsStale"] is True, json.dumps(refused))
  return fresh


# ---------------------------------------------------------------- contract

sandbox()
fresh = check_spend_contract(signed_in, 4)
expect("the record is account-wide, on its rate-limit tier, with tokens and no prompt counts or limits",
       {key: fresh.get(key) for key in ("ready", "hasPromptStats", "scope", "tierLabel", "limits", "todayTotalTokens", "hasLocalStats")},
       {"ready": True, "hasPromptStats": False, "scope": "account", "tierLabel": "Tier 2", "limits": [], "todayTotalTokens": 120, "hasLocalStats": True}, fresh)
expect("this month's spend is read against the tier's monthly cap, with each day's cost", fresh["spend"],
       {"amount": 7.5, "cap": 50.0, "currency": "USD", "days": DAYS}, fresh)

# The usage rows are this record's stats, reused like a local scan: briefly
# on a normal run and for 15 minutes on the near-limit refresh, which probes
# the spend like a normal run.
fireworks()
for path in cache_root().glob("fireworks-*.json"):
  data = json.loads(path.read_text())
  write_json(path, dict(data, fetchedAtMs=data["fetchedAtMs"] - 60_000))
fireworks("--limits-only")
limits_only = fireworks.asked
fireworks(force=False)
expect("a minute-old answer serves --limits-only its usage but not its spend, and a normal run neither",
       [limits_only, fireworks.asked], [["spend", "spend", "spend"], ["usage"]])

# --------------------------------------------------------------- the spend

# An uncapped account's quota carries Fireworks' placeholder, which is no cap.
sandbox()
signed_in()
record = fireworks(routes=dict(ROUTES, **{"/quotas/monthly-spend-usd": dict(SPEND, value="9999999")}))
expect("an uncapped account's spend is the last 30 days' total, with no cap", record["spend"], {"amount": 1.25, "cap": 0.0, "currency": "USD", "days": DAYS}, record)

# A quota that can't be read keeps the last good spend, stale; with nothing
# kept there is no spend, and the tokens still show.
record = fireworks(routes=dict(ROUTES, **{"/quotas/monthly-spend-usd": {"value": "50"}}))
expect("an unreadable quota keeps the last spend, stale",
       [record["spend"], record["limitsStale"], record["usageStatusText"], "unreadable" in record["authHelpText"]],
       [{"amount": 1.25, "cap": 0.0, "currency": "USD", "days": DAYS}, True, "", True], record)
# A day's cost that can't be read is no answer, not a day that cost nothing.
for subtotal in ({"units": "bad"}, {"units": "NaN"}, {"units": True}, {"units": False}, {"units": ""}, {"nanos": []}, {"units": 10 ** 400}, None):
  record = fireworks(routes=dict(ROUTES, **{"/quotas/monthly-spend-usd": dict(SPEND, value="9999999"),
                                            "/usageCosts:query": {"rows": [{"dimensions": {"startTime": TODAY + "T00:00:00Z"}, "subtotal": subtotal}]}}))
  expect(f"an unreadable day's cost ({subtotal}) keeps the last spend, stale",
         [record["spend"], record["limitsStale"], "unreadable" in record["authHelpText"]],
         [{"amount": 1.25, "cap": 0.0, "currency": "USD", "days": DAYS}, True, True], record)
for path in limits_cache_files("fireworks"):
  path.unlink()
# A key refused the quota still reads its daily costs, so it gets the 30
# days' bars with no cap; one refused those too has no spend.
record = fireworks(routes=dict(ROUTES, **{"/quotas/monthly-spend-usd": 403}))
expect("a key that can't read the quota shows the last 30 days with no cap",
       [record.get("spend"), record["limitsStale"], record["authHelpText"]],
       [{"amount": 1.25, "cap": 0.0, "currency": "USD", "days": DAYS}, False, ""], record)
# A cap the account had is still its cap: a refused quota keeps it, stale.
fireworks()
record = fireworks(routes=dict(ROUTES, **{"/quotas/monthly-spend-usd": 403}))
expect("a refused quota keeps a known cap, stale",
       [record.get("spend"), record["limitsStale"], record["authHelpText"]],
       [{"amount": 7.5, "cap": 50.0, "currency": "USD", "days": DAYS}, True, "The Fireworks API key cannot read billing data"], record)
# A kept answer is read back from disk: one whose cap is no positive number
# is no cap, and never fails the record.
module = load_collector("fireworks")
for spend in ({"cap": "50"}, {"cap": True}, {"cap": -5}, {"cap": 10 ** 400}, {"cap": float("inf")}, {"cap": float("nan")}, "capped", [50]):
  expect(f"a kept spend of {str(spend)[:24]} holds no cap", module.known_cap({"spend": spend}), False)
expect("a kept spend capped at 50 holds a cap", module.known_cap({"spend": {"cap": 50.0}}), True)
for path in limits_cache_files("fireworks"):
  path.unlink()
record = fireworks(routes=dict(ROUTES, **{"/quotas/monthly-spend-usd": 403, "/usageCosts:query": 403}))
expect("a key that can't read billing at all shows its tokens and no spend",
       [record["ready"], "spend" in record, record["modelUsage"]["kimi-k2.5"]["outputTokens"], record["usageStatusText"], record["authHelpText"]],
       [True, False, 20, "", "The Fireworks API key cannot read billing data"], record)

# FIREWORKS_API_BASE_URL moves the endpoint, never the key onto plain HTTP to
# another machine, nor into a URL that isn't one.
for url in ("http://evil.example", "not a url"):
  record = fireworks(FIREWORKS_API_BASE_URL=url)
  expect(f"Fireworks sends its key to no untrusted endpoint ({url})",
         [fireworks.asked, record["limitsStale"], "HTTPS" in record["authHelpText"]], [[], True, True], record)

# Usage and spend both unreachable with nothing kept: the stats source is
# unavailable.
sandbox()
signed_in()
record = fireworks(mode="down")
expect("an unreachable API with nothing kept says Fireworks is unavailable",
       [record["ready"], record["usageStatusText"], record["limitsStale"], record.get("retryAdvised"), record.get("spend")],
       [True, "Fireworks unavailable", True, True, None], record)

# Another key, or the same key now pointed at another account, never shows
# these numbers.
fireworks()
record = fireworks(mode="down", FIREWORKS_API_KEY="fw_other")
expect("each key's answers are kept apart", [record.get("spend"), record["todayTotalTokens"], record["usageStatusText"]], [None, 0, "Fireworks unavailable"], record)
record = fireworks(mode="down", FIREWORKS_ACCOUNT_ID="elsewhere")
expect("each account's answers are kept apart", [record.get("spend"), record["todayTotalTokens"]], [None, 0], record)

# ------------------------------------------------------------ the account

# Without an account id anywhere, the key's one account is found and asked
# about; a key reaching several can't be guessed at.
sandbox()
(home() / ".fireworks").mkdir()
(home() / ".fireworks" / "auth.ini").write_text("[default]\napi_key = fw_discover\n")


def accounts(*names):
  return {"/v1/accounts?": {"accounts": [{"name": f"accounts/{name}", "ratelimitTier": 3} for name in names]}}


def asked_accounts(http):
  return sorted({request["url"].split("/v1/accounts/")[1].split("/")[0].split(":")[0] for request in http.requests if "/v1/accounts/" in request["url"]})


with FakeHttp(dict(accounts("acct-one"), **ROUTES)) as http:
  record = collect("fireworks", "--force")
expect("Fireworks finds the key's one account and asks about it, its tier included",
       [asked_accounts(http), record["todayTotalTokens"], record["spend"]["amount"], record["tierLabel"], record["usageStatusText"]],
       [["acct-one"], 120, 7.5, "Tier 3", ""], record)
with FakeHttp(dict(accounts("acct-one", "acct-two"), **ROUTES)) as http:
  record = collect("fireworks", "--force")
expect("Fireworks asks for an accountId when the key reaches several accounts",
       [asked_accounts(http), record["limitsStale"], "FIREWORKS_ACCOUNT_ID" in record["authHelpText"]], [[], True, True], record)

# An account list that isn't a list is a failed check: the kept answers stand.
with FakeHttp(dict(accounts("acct-one"), **ROUTES)):
  collect("fireworks", "--force")
with FakeHttp(dict({"/v1/accounts?": {"accounts": None}}, **ROUTES)):
  record = collect("fireworks", "--force")
expect("Fireworks keeps its last answers past an account list that isn't one",
       [record["ready"], record["todayTotalTokens"], record["spend"]["amount"], record["limitsStale"]], [True, 120, 7.5, True], record)

# The key now reaching another account starts over: the first account's
# usage and spend never stand in for it when its own checks fail.
with FakeHttp(dict(accounts("acct-two"), **{"/quotas/monthly-spend-usd": 500, "/billingUsage": 500})):
  record = collect("fireworks", "--force")
expect("Fireworks never keeps another account's answers when the key moves",
       [record["todayTotalTokens"], "spend" in record, record["usageStatusText"]], [0, False, "Fireworks unavailable"], record)

# ------------------------------------------------------------ the answer

module = load_collector("fireworks")

# Each day's cost lands on its day of the last 30, today last; days without
# a row cost nothing, and a row outside the 30 days, or with no day, is left
# out.
client = module.FireworksClient("fw_test", API)
with FakeHttp({"/usageCosts:query": {"rows": [
  {"dimensions": {"startTime": "2026-06-04T00:00:00Z"}, "subtotal": {"units": "9"}},
  {"dimensions": {"startTime": "2026-06-05T00:00:00Z"}, "subtotal": {"units": "1"}},
  {"dimensions": {"startTime": "2026-07-01T00:00:00Z"}, "subtotal": {"units": "2"}},
  {"dimensions": {"startTime": "2026-07-03T00:00:00Z"}, "subtotal": {"nanos": 500000000}},
  {"dimensions": {"startTime": "2026-07-02T00:00:00Z"}, "subtotal": {}},
  {"dimensions": {"startTime": "2026-07-09T00:00:00Z"}, "subtotal": {"units": "9"}},
  {"dimensions": {}, "subtotal": {"units": "9"}},
]}}):
  days = client.daily_costs("example", datetime(2026, 7, 4, 12, tzinfo=timezone.utc))
expect("daily costs fill the last 30 days, day by day", days, [1.0] + [0.0] * 25 + [2.0, 0.0, 0.5, 0.0])

# Today's uncached, cached and output tokens count once, cache apart in the
# model totals, over the 30-day window.
summary = module.summarize_usage({"serverlessCosts": [
  {"startTime": "2026-07-31T00:00:00Z", "promptTokens": "100", "cachedPromptTokens": "40", "uncachedPromptTokens": "60", "completionTokens": "20",
   "group": {"model_name": "accounts/fireworks/models/kimi-k2p5"}},
  {"startTime": "2026-07-30T00:00:00Z", "promptTokens": "300", "cachedPromptTokens": "0", "completionTokens": "50",
   "group": {"model_name": "accounts/fireworks/models/deepseek-v3p2"}},
  {"startTime": "2026-07-20T00:00:00Z", "promptTokens": "500", "cachedPromptTokens": "0", "completionTokens": "100",
   "group": {"model_name": "accounts/fireworks/models/kimi-k2p5"}},
]}, date(2026, 7, 31))
expect("today's token categories count once, cache apart, over the 30-day window",
       [summary["todayTotalTokens"], summary["recentDays"][-1]["messageCount"], summary["activeDays"], summary["modelUsage"]["kimi-k2.5"]],
       [120, 120, 3, {"inputTokens": 560, "outputTokens": 120, "cacheReadInputTokens": 40, "cacheCreationInputTokens": 0}], summary)
expect("untrusted token fields are skipped", module.summarize_usage({"serverlessCosts": [
  {"startTime": TODAY + "T00:00:00Z", "promptTokens": True, "completionTokens": "NaN", "group": {"model_name": "a"}},
  {"startTime": TODAY + "T00:00:00Z", "promptTokens": 1e300, "completionTokens": "inf", "group": {"model_name": "b"}},
  {"startTime": TODAY + "T00:00:00Z", "promptTokens": -5, "completionTokens": 7, "group": {"model_name": "c"}},
]})["modelUsage"], {"c": {"inputTokens": 0, "outputTokens": 7, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}})
expect("a bucket time at the calendar's edge has no day, and its tokens still count",
       [module.row_date({"startTime": "9999-12-31T23:00:00-05:00"}), module.row_date({"startTime": "0001-01-01T00:00:00+05:00"}),
        module.summarize_usage({"serverlessCosts": [{"startTime": "9999-12-31T23:00:00-05:00", "completionTokens": "7"}]})["modelUsage"]["unknown"]["outputTokens"]],
       ["", "", 7])

# billingUsage pages long ranges, so every continuation token is followed,
# from a window that opens at local midnight.
client = module.FireworksClient("fw_test", API)
with FakeHttp({"pageToken=p2": {"serverlessCosts": [{"startTime": "2026-07-31T00:00:00Z"}]},
               "/billingUsage": {"serverlessCosts": [{"startTime": "2026-07-30T00:00:00Z"}], "nextPageToken": "p2"}}) as http:
  merged = client.usage("example", date(2026, 7, 1), date(2026, 8, 1))
first = urllib.parse.parse_qs(urllib.parse.urlsplit(http.requests[0]["url"]).query)
expect("billingUsage continuation tokens are followed", [len(merged["serverlessCosts"]), len(http.requests), first["startTime"]], [2, 2, ["2026-07-01T00:00:00Z"]])

# A reply that isn't an object, or usage rows that aren't a list, fail the
# check rather than passing for an idle account; a missing list is an idle
# month, since the API leaves empty lists out.
def fails(call):
  try:
    call()
  except module.FireworksError:
    return True
  return False


with FakeHttp({"/v1/accounts": []}):
  odd_object = fails(lambda: client.request("/v1/accounts"))
with FakeHttp({"/billingUsage": {"serverlessCosts": "rows"}}):
  odd_rows = fails(lambda: client.usage("example", date(2026, 7, 1), date(2026, 8, 1)))
with FakeHttp({"/billingUsage": {}}):
  idle = client.usage("example", date(2026, 7, 1), date(2026, 8, 1))
expect("a reply of the wrong shape fails, and a missing usage list reads as idle", [odd_object, odd_rows, idle], [True, True, {"serverlessCosts": []}])

# East of Greenwich, a local-midnight bucket starts on the previous UTC date;
# the row still lands on the local day it names, and the query window asks
# for local midnights expressed in UTC.
saved_tz = os.environ.get("TZ")
os.environ["TZ"] = "Etc/GMT-2"
time.tzset()
try:
  east = [module.row_date({"startTime": "2026-07-30T22:00:00Z"}), module.local_midnight_utc(date(2026, 7, 31))]
finally:
  if saved_tz is None:
    os.environ.pop("TZ", None)
  else:
    os.environ["TZ"] = saved_tz
  time.tzset()
expect("buckets are dated by local day, and windows open at local midnight in UTC", east, ["2026-07-31", "2026-07-30T22:00:00Z"])

# ---------------------------------------------------------- the credentials

# firectl's auth.ini, then a pi login, then opencode's; pi's key resolves a
# $VAR reference and leaves a !command lookup to pi.
sandbox()
auth = home() / ".fireworks" / "auth.ini"
signed_in()
expect("firectl's auth.ini gives the key and account", list(module.read_auth_file(auth)), ["fw_test", "example"])
unreadable = home() / "latin1.ini"
unreadable.write_bytes(b"[default]\napi_key = fw_caf\xe9\n")
expect("an auth.ini that isn't UTF-8 reads as no key", list(module.read_auth_file(unreadable)), ["", ""])
missing = home() / "missing.ini"
opencode_auth(None, "fireworks-ai", "fw_opencode")
expect("opencode's key is the last resort", [module.credentials(missing)[0], module.credentials(auth)[0]], ["fw_opencode", "fw_test"])
pi_auth(None, "fireworks", "fw_pi")
expect("a pi login comes below firectl and above opencode", [module.credentials(missing)[0], module.credentials(auth)[0]], ["fw_pi", "fw_test"])
os.environ["FW_TEST_ENV_KEY"] = "fw_from_env"
expect("pi's $VAR keys resolve, and a missing one stays unresolved",
       [module.resolve_pi_key("$FW_TEST_ENV_KEY"), module.resolve_pi_key("$FW_DEFINITELY_MISSING")], ["fw_from_env", ""])
pi_auth(None, "fireworks", "!secret-tool lookup fw")
expect("pi's !command keys are skipped for the next rung", module.credentials(missing)[0], "fw_opencode")
PY
