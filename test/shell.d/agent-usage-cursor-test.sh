#!/bin/bash

# The Cursor collector's own sources: the dashboard RPCs the Cursor CLI calls
# (the period meters, the plan, and a week of daily token aggregations), the
# per-account token scan carried past midnight and through failed checks, and
# the editor or CLI being installed at all. The unused-machine record is held
# centrally by the partition test, the Cursor sign-in order and the editor's
# untouched database by the shared test, and the limits and scan caches by
# the contract checks.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

# Day windows resolve in local time, so pin the zone or the fixtures below
# would shift by a day depending on where the test runs.
export TZ=UTC

python3 - <<'PY'
from agent_usage_fixtures import *
import collectors
from datetime import date

RPC = "api2.cursor.sh/aiserver.v1.DashboardService/"
TODAY = datetime.now().astimezone().date()
YESTERDAY = TODAY - timedelta(days=1)

# Spend well past the included limit, the way a plan with provider bonus usage
# reports it: 609.86 spent against a 400.00 allowance, while Cursor's own
# meters say 18.76% / 11.81% / 100%.
PERIOD = {
  "billingCycleEnd": "4092099926000",
  "planUsage": {"totalSpend": 60986, "includedSpend": 40000, "limit": 40000, "autoPercentUsed": 11.81, "apiPercentUsed": 100, "totalPercentUsed": 18.76},
  "spendLimitUsage": {"individualLimit": "1000", "individualUsed": "951", "limitType": "user"},
}
AGGREGATIONS = {
  TODAY.isoformat(): [{"modelIntent": "default", "inputTokens": "10", "outputTokens": "5", "cacheReadTokens": "100", "cacheWriteTokens": "1", "totalCents": None}],
  YESTERDAY.isoformat(): [
    {"modelIntent": "default", "inputTokens": "2", "outputTokens": "3", "cacheReadTokens": "4", "cacheWriteTokens": "0"},
    {"modelIntent": "kimi-k3-max", "inputTokens": "1", "outputTokens": "1", "cacheReadTokens": "0", "cacheWriteTokens": "0"},
  ],
}
grown = {"tokens": 0}


def window_start(data):
  return datetime.fromtimestamp(int(json.loads(data)["startDate"]) / 1000).astimezone()


# A day's aggregations, plus whatever the scan contract has grown today by.
def aggregations(request):
  day = window_start(request.data).date()
  rows = list(AGGREGATIONS.get(day.isoformat(), []))
  if day == TODAY and grown["tokens"]:
    rows.append({"modelIntent": "grown", "inputTokens": str(grown["tokens"])})
  return {"aggregations": rows}


ROUTES = {
  RPC + "GetCurrentPeriodUsage": PERIOD,
  RPC + "GetPlanInfo": {"planInfo": {"planName": "Ultra"}},
  RPC + "GetAggregatedUsageEvents": aggregations,
}


def cli_signed_in(user="u-main", expires_in=3600):
  write_json(config_home() / "cursor" / "auth.json", {"accessToken": jwt({"sub": user, "exp": time.time() + expires_in})})


def cursor(*args, routes=None, mode="up", **env):
  saved = dict(os.environ)
  os.environ.update(env)
  try:
    with FakeHttp(ROUTES if routes is None else routes, mode=mode) as http:
      record = collect("cursor", *(args or ("--force",)))
  finally:
    os.environ.clear()
    os.environ.update(saved)
  cursor.requests = http.requests
  return record


def meters(record):
  return [{"label": limit["label"], "percent": round(limit["percent"] * 10000)} for limit in record["limits"]]


# --------------------------------------------------------------- the answer

sandbox()
cli_signed_in()
record = cursor()
expect("the record is account-wide, with no prompt counts, and the plan from GetPlanInfo",
       {key: record.get(key) for key in ("ready", "hasPromptStats", "scope", "tierLabel", "usageStatusText")},
       {"ready": True, "hasPromptStats": False, "scope": "account", "tierLabel": "Ultra", "usageStatusText": ""}, record)
expect("the meters are Cursor's own, not spend over the allowance", meters(record), [
  {"label": "Included total", "percent": 1876}, {"label": "Auto models", "percent": 1181},
  {"label": "Named models", "percent": 10000}, {"label": "On-demand $9.51 / $10.00", "percent": 9510},
], record)
expect("the reset is the billing cycle's end", record["limits"][0]["resetsAt"], "2099-09-03T06:25:26+00:00", record)
starts = [window_start(request["data"]) for request in cursor.requests if request["url"].endswith("GetAggregatedUsageEvents")]
expect("tokens are asked for in seven daily windows, each from local midnight",
       [len(starts), {(start.hour, start.minute, start.second) for start in starts}], [7, {(0, 0, 0)}])
expect("the week's token series is built from the windows", [day["messageCount"] for day in record["recentDays"]], [0, 0, 0, 0, 0, 11, 116], record)
expect("Cursor's token names map onto the record's", record["modelUsage"], {
  "default": {"inputTokens": 12, "outputTokens": 8, "cacheReadInputTokens": 104, "cacheCreationInputTokens": 1},
  "kimi-k3-max": {"inputTokens": 1, "outputTokens": 1, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
}, record)
expect("today stands apart from the rest of the week",
       [record["todayTotalTokens"], record["todayTokensByModel"], record["activeDays"]], [116, {"default": 116}, 2], record)

# A failed check keeps the week of tokens on disk along with the limits.
down = cursor(mode="down")
expect("a failed check keeps the last week of tokens and the plan",
       [down["recentDays"] == record["recentDays"], down["tierLabel"], down["limitsStale"]], [True, "Ultra", True], down)

# Another account's scan never stands in: signed in as someone else with the
# dashboard down, there are no tokens to show.
other = cursor(mode="down", CURSOR_API_KEY="someone_else")
expect("another account's numbers are never carried",
       {"limits": other["limits"], "tierLabel": other["tierLabel"], "today": other["todayTotalTokens"],
        "counts": [day["messageCount"] for day in other["recentDays"]], "last": other["recentDays"][6]["date"], "modelUsage": other["modelUsage"]},
       {"limits": [], "tierLabel": "", "today": 0, "counts": [0] * 7, "last": TODAY.isoformat(), "modelUsage": {}}, other)

# A kept limit whose billing cycle has ended comes back at zero, and an
# on-demand meter among them is renamed for its new spend.
module = load_collector("cursor")
key = collectors.account_key(collectors.cursor_token())
limits_path = module.limits_cache(key).path
good = json.loads(limits_path.read_text())
past = iso_in(-3600)
write_json(limits_path, dict(good, limits=[dict(good["limits"][0], resetsAt=past)] + good["limits"][1:3] + [dict(good["limits"][3], resetsAt=past)]))
lapsed = cursor(mode="down")
write_json(limits_path, good)
expect("a kept limit whose cycle ended resets, the rest stand",
       [[limit["label"], round(limit["percent"] * 100), limit["resetsAt"]] for limit in lapsed["limits"][:2]],
       [["Included total", 0, ""], ["Auto models", 12, "2099-09-03T06:25:26+00:00"]], lapsed)
expect("an on-demand meter that reset is renamed with its new spend",
       {name: lapsed["limits"][3][name] for name in ("label", "title", "percent", "resetsAt")},
       {"label": "On-demand $0.00 / $10.00", "title": "On-demand $0.00 / $10.00 Monthly", "percent": 0.0, "resetsAt": ""}, lapsed)

# A scan from yesterday moves onto this week's dates, and its today figures
# are cleared, since none of it happened today. Each day's usage rides along,
# so the day that falls out of the week leaves the model totals and active
# days as well as the chart.
stats_path = module.stats_cache(key)
scan = json.loads(stats_path.read_text())
yesterday_scan = dict(scan, scanDate=YESTERDAY.isoformat())
yesterday_scan["stats"] = dict(scan["stats"], recentDays=[{"date": (TODAY - timedelta(days=offset)).isoformat(), "messageCount": offset} for offset in range(7, 0, -1)])
yesterday_scan["stats"]["days"] = [[(TODAY - timedelta(days=offset)).isoformat(), {"carried-model": {"inputTokens": offset}}] for offset in range(7, 0, -1)]
write_json(stats_path, yesterday_scan)
overnight = module.carried_stats(key, TODAY)
expect("a scan from yesterday moves onto today's week",
       [overnight["todayTotalTokens"], overnight["todayTokensByModel"], [day["messageCount"] for day in overnight["recentDays"]], overnight["recentDays"][6]["date"]],
       [0, {}, [6, 5, 4, 3, 2, 1, 0], TODAY.isoformat()], overnight)
expect("the day that left the week leaves the model totals",
       [overnight["modelUsage"]["carried-model"]["inputTokens"], overnight["activeDays"], len(overnight["activeDates"])], [21, 6, 6], overnight)
# A scan cached before days were kept still moves onto the new week.
write_json(stats_path, dict(yesterday_scan, stats={k: v for k, v in yesterday_scan["stats"].items() if k != "days"}))
overnight = module.carried_stats(key, TODAY)
expect("an older cached scan moves onto today's week too",
       [overnight["todayTotalTokens"], [day["messageCount"] for day in overnight["recentDays"]]], [0, [6, 5, 4, 3, 2, 1, 0]], overnight)

# Days that spring forward or fall back are 23 or 25 hours long.
saved_tz = os.environ.get("TZ")
os.environ["TZ"] = "America/New_York"
time.tzset()
try:
  spring = module.day_windows(date(2026, 3, 9), 2)
  fall = module.day_windows(date(2026, 11, 1), 1)
finally:
  if saved_tz is None:
    os.environ.pop("TZ", None)
  else:
    os.environ["TZ"] = saved_tz
  time.tzset()
expect("daily windows are sized across DST",
       [[(end - start) // 3_600_000 for _, start, end in spring + fall], spring[0][2] == spring[1][1]], [[23, 24, 25], True])

# ------------------------------------------------------------- the sign-in

# Cursor installed but signed in nowhere: the agent is in use, so it says it
# is waiting for a sign-in.
sandbox()
(config_home() / "cursor").mkdir(parents=True)
record = cursor()
expect("Cursor installed but signed in nowhere waits for a sign-in",
       [record["ready"], record["usageStatusText"], record["limits"], record["authHelpText"] != ""], [True, "Waiting for auth", [], True], record)

# A lapsed sign-in isn't sent: the CLI or editor renews it when it runs.
sandbox()
cli_signed_in()
cursor()
cli_signed_in(expires_in=-60)
record = cursor()
expect("a lapsed sign-in pauses the limits without asking",
       [record["usageStatusText"], record["limitsStale"], len(record["limits"]), cursor.requests], ["Limits paused", True, 4, []], record)

# ------------------------------------------------------------ the endpoint

# CURSOR_API_ENDPOINT moves the endpoint, but the sign-in only ever goes over
# HTTPS, or plain HTTP to loopback.
sandbox()
cli_signed_in()
for endpoint, sent in (("http://cursor.example.com", False), ("ftp://cursor.example.com", False), ("https://user:pw@cursor.example.com", False),
                       ("https://cursor.example.com", True), ("http://127.0.0.1:9", True)):
  with FakeHttp({"/aiserver.v1.DashboardService/": PERIOD}) as http:
    os.environ["CURSOR_API_ENDPOINT"] = endpoint
    try:
      record = collect("cursor", "--force")
    finally:
      del os.environ["CURSOR_API_ENDPOINT"]
  expect(f"the Cursor sign-in {'goes' if sent else 'never goes'} to {endpoint}", bool(http.requests), sent, record)
  if not sent:
    expect(f"{endpoint} reads as unavailable and says why", [record["usageStatusText"], "HTTPS" in record["authHelpText"]], ["Cursor limits unavailable", True], record)

# ---------------------------------------------------------------- contract

sandbox()


def grow():
  grown["tokens"] += 1


# A probe asks for the period and the plan, and a forced one scans the
# week's seven days too.
adapter = Adapter("cursor", plant=cli_signed_in, answer=ROUTES, requests_per_probe=9, grow=grow)
check_limits_contract(adapter)
check_scan_cache(adapter)
grown["tokens"] = 0

# Without a billing cycle end there is no reset time, as "" rather than null,
# and every meter is titled after the billing period.
sandbox()
cli_signed_in()
routes = dict(ROUTES)
routes[RPC + "GetCurrentPeriodUsage"] = {"planUsage": {"totalPercentUsed": 40, "autoPercentUsed": 20, "apiPercentUsed": 60},
                                         "spendLimitUsage": {"individualLimit": "2000", "individualUsed": "500"}}
record = cursor(routes=routes)
expect("the meters are titled after the billing period",
       [limit["title"] for limit in record["limits"]], ["Monthly", "Auto models Monthly", "Named models Monthly", "On-demand $5.00 / $20.00 Monthly"], record)
expect("an unknown reset is an empty string", sorted({limit["resetsAt"] for limit in record["limits"]}), [""], record)

# A plan whose included allowance is weekly, as GetPlanInfoResponse.PlanInfo
# says with included_usage_period and included_usage_resets_at, titles and
# dates its included meters by the week; the on-demand budget stays on the
# billing cycle.
weekly_routes = dict(routes, **{
  RPC + "GetCurrentPeriodUsage": dict(PERIOD, planUsage={"totalPercentUsed": 40, "autoPercentUsed": 20, "apiPercentUsed": 60}),
})
read = {}
for period, reset in (("INCLUDED_USAGE_PERIOD_WEEKLY", "4091840726000"), ("WEEKLY", "4091840726"), (2, 4091840726000)):
  weekly_routes[RPC + "GetPlanInfo"] = {"planInfo": {"planName": "Ultra", "includedUsagePeriod": period, "includedUsageResetsAt": reset}}
  record = cursor(routes=weekly_routes)
  read[str(period)] = [[limit["title"], limit["resetsAt"]] for limit in record["limits"]]
WEEK_END, CYCLE_END = "2099-08-31T06:25:26+00:00", "2099-09-03T06:25:26+00:00"
expect("a weekly included allowance reads Weekly and resets with the week", read, {
  period: [["Weekly", WEEK_END], ["Auto models Weekly", WEEK_END], ["Named models Weekly", WEEK_END], ["On-demand $9.51 / $10.00 Monthly", CYCLE_END]]
  for period in ("INCLUDED_USAGE_PERIOD_WEEKLY", "WEEKLY", "2")
}, read)

# A weekly plan whose GetPlanInfo fails can't say its week's reset, so the
# known weekly limits are kept, stale, rather than read as Monthly.
record = cursor(routes=dict(weekly_routes, **{RPC + "GetPlanInfo": 500}))
expect("a weekly plan that can't be checked keeps its weekly limits, stale",
       [[[limit["title"], limit["resetsAt"]] for limit in record["limits"]], record["limitsStale"], record["tierLabel"]],
       [read["2"], True, "Ultra"], record)

# GetPlanInfo failing leaves the plan the account last had.
cursor(routes=routes)
record = cursor(routes=dict(routes, **{RPC + "GetPlanInfo": 500}))
expect("the plan is kept when GetPlanInfo fails", [record["tierLabel"], record["limitsStale"]], ["Ultra", False], record)

# A failure that isn't Cursor's error keeps the limits and the tokens too.
with contextlib.redirect_stderr(io.StringIO()):
  record = cursor(routes=dict(routes, **{RPC + "GetCurrentPeriodUsage": RuntimeError("boom")}))
expect("an unexpected failure keeps the limits and the tokens",
       [len(record["limits"]), record["limitsStale"], record["usageStatusText"], record["todayTotalTokens"], record.get("retryAdvised", False)],
       [4, True, "", 116, False], record)

# A usage section of the wrong type is a reply this doesn't read: a failed
# check that keeps the known limits, stale, rather than no meters. A plan
# with nothing in it, its sections left out or null, is a real answer.
wrong = {name: cursor(routes=dict(routes, **{RPC + "GetCurrentPeriodUsage": dict(routes[RPC + "GetCurrentPeriodUsage"], **{name: []})}))
         for name in ("planUsage", "spendLimitUsage")}
expect("a wrongly typed usage section keeps the known limits, stale",
       {name: [len(record["limits"]), record["limitsStale"], record["authHelpText"] != ""] for name, record in wrong.items()},
       {"planUsage": [4, True, True], "spendLimitUsage": [4, True, True]}, wrong)
empty = [cursor(routes=dict(routes, **{RPC + "GetCurrentPeriodUsage": period})) for period in ({}, {"planUsage": None, "spendLimitUsage": None})]
expect("an empty plan is an answer with no meters",
       [[record["limits"], record["limitsStale"], record["usageStatusText"]] for record in empty], [[[], False, ""]] * 2, empty)

# Untrusted numbers never break the record.
expect("untrusted numbers read as nothing",
       [module.fraction("nan"), module.fraction("inf"), module.fraction(True), module.number("1e400"), module.iso("9" * 30)], [0.0, 0.0, 0.0, 0, ""])
PY
