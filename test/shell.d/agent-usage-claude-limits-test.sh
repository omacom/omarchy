#!/bin/bash

# The Claude collector's limits: how it reads Anthropic's usage answer, what
# the sign-in Claude Code keeps says before anything is asked, Anthropic's
# rate limiting, and its adapter for the contract checks. The unused-machine
# record is held centrally by the partition test, and the limits cache's
# mechanics (file times, future stamps, elapsed windows) by the shared test.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

USAGE = "api.anthropic.com/api/oauth/usage"
ROUTES = {USAGE: {"five_hour": {"utilization": 40.0, "resets_at": iso_in(3600)}, "seven_day": {"utilization": 10.0, "resets_at": iso_in(86400)}}}


# The sign-in the Claude Code CLI leaves: an access token living about eight
# hours, and the refresh token behind it about thirty days.
def signed_in(token="token", expires=None, refresh_expires=0):
  write_json(home() / ".claude" / ".credentials.json", {"claudeAiOauth": {
    "accessToken": token, "expiresAt": ms_in(3600) if expires is None else expires, "refreshTokenExpiresAt": refresh_expires,
    "subscriptionType": "max", "rateLimitTier": "default_claude_max_5x",
  }})


def claude(*args, routes=ROUTES, mode="up"):
  with FakeHttp(routes, mode=mode) as http:
    record = collect("claude", *(args or ("--force",)))
  return record, http


def labels(record):
  return [entry["label"] for entry in record["limits"]]


# The single-account cache, planted as an earlier probe left it.
def kept_limits(fetched_ago, limits):
  write_json(cache_root() / "claude-limits.json", {"fetchedAtMs": ms_in(-fetched_ago), "limits": limits})


# ------------------------------------------------------------ the answer

sandbox()
signed_in()


def read_limits(payload, headers=None):
  def answer(request):
    return payload if headers is None else FakeHttp.refusal(request.full_url, 429, b"", headers)
  with FakeHttp({USAGE: answer}):
    return load_collector("claude").probe_limits("token")


# The two flat buckets, then every scoped shape that matters: a model's weekly
# window, a second window for that same model, a model that names only an id,
# and, dropped, a repeat of a window already read, a blank name, and a percent
# that will not parse.
limits = read_limits({
  "five_hour": {"utilization": 78.0},
  "seven_day": {"utilization": 12.0},
  "seven_day_opus": None,
  "limits": [
    {"kind": "session", "percent": 78, "scope": None},
    {"kind": "weekly_all", "percent": 12, "scope": None},
    {"kind": "weekly_scoped", "percent": 17, "resets_at": "2026-08-15T03:00:00+00:00",
     "scope": {"model": {"id": "claude-fable-5", "display_name": "Fable"}, "surface": None}},
    {"kind": "weekly_scoped", "percent": 99, "scope": {"model": {"display_name": "Fable"}}},
    {"kind": "five_hour_scoped", "percent": 95, "scope": {"model": {"display_name": "Fable"}}},
    {"kind": "weekly_scoped", "percent": 42, "scope": {"model": {"id": "claude-opus-5", "display_name": None}}},
    {"kind": "weekly_scoped", "percent": 5, "scope": {"model": {"display_name": "  "}}},
    {"kind": "weekly_scoped", "percent": "unknown", "scope": {"model": {"display_name": "Opus"}}},
  ],
})
expect("Claude collector reads every model-scoped window once and drops unusable entries", limits["limits"], [
  {"label": "Session (5-hour)", "percent": 0.78, "resetsAt": ""},
  {"label": "Weekly (7-day)", "percent": 0.12, "resetsAt": ""},
  {"label": "Fable Weekly", "title": "Fable Weekly", "percent": 0.17, "resetsAt": "2026-08-15T03:00:00+00:00"},
  {"label": "Fable Session", "title": "Fable Session", "percent": 0.95, "resetsAt": ""},
  {"label": "claude-opus-5 Weekly", "title": "claude-opus-5 Weekly", "percent": 0.42, "resetsAt": ""},
], limits)

# Every value is a percentage, as Claude Code renders them
# (`${Math.floor(utilization)}% used`): just after a reset, a window at 0.6%
# is 0.6%, never read as the fraction 0.6.
low = read_limits({"five_hour": {"utilization": 0.6}, "seven_day": {"utilization": 0.8}, "limits": [
  {"kind": "session", "percent": 0.6, "scope": None},
  {"kind": "weekly_scoped", "percent": 0, "scope": {"model": {"id": "claude-fable-5", "display_name": "Fable"}}},
]})
expect("Claude collector reads values below 1 as percentages", [entry["percent"] for entry in low["limits"]], [0.006, 0.008, 0.0], low)

# An account with no model-scoped allowance, and an endpoint that never grew
# the array, both keep the session and weekly windows they always had.
for payload in ({"five_hour": {"utilization": 78.0}, "limits": [{"kind": "session", "percent": 78, "scope": None}]},
                {"five_hour": {"utilization": 78.0}, "seven_day": {"utilization": 12.0}}):
  read = read_limits(payload)
  check("Claude collector adds no limit when the payload scopes none", not any(" Weekly" in entry["label"] for entry in read["limits"]), read)

# The week is `seven_day`, the row Claude Code's /usage titles "Current week
# (all models)"; `seven_day_oauth_apps` is a side bucket it never shows as
# the weekly limit, even when it holds numbers of its own.
both = read_limits({
  "five_hour": {"utilization": 11.0, "resets_at": "2026-10-22T15:20:00+00:00"},
  "seven_day": {"utilization": 13.0, "resets_at": "2026-10-25T06:00:00+00:00"},
  "seven_day_oauth_apps": {"utilization": 64.0, "resets_at": "2026-10-23T01:00:00+00:00"},
})
expect("Claude's weekly meter is the account's seven_day window, not the OAuth apps bucket",
       [(entry["label"], entry["percent"], entry["resetsAt"]) for entry in both["limits"]],
       [("Session (5-hour)", 0.11, "2026-10-22T15:20:00+00:00"), ("Weekly (7-day)", 0.13, "2026-10-25T06:00:00+00:00")], both)

# A rate-limited check says when to try again, as Anthropic's refusal does.
refused = read_limits(None, headers={"retry-after": "42"})
check("a rate-limited check names Anthropic's retry-after", "(retry after 42s)" in refused["helpText"], refused)

# ---------------------------------------------------------------- contract

sandbox()


def add_session():
  add_session.count = getattr(add_session, "count", 0) + 1
  write_pi_session(home() / ".pi" / "agent" / "sessions" / "p" / f"grown-{add_session.count}.jsonl",
                   [pi_reply("anthropic", 10, id=f"grown-{add_session.count}", model="claude-opus")])


adapter = Adapter("claude", plant=signed_in, answer=ROUTES, grow=add_session,
                  pi_root=lambda: home() / ".pi" / "agent" / "sessions")
fresh = check_limits_contract(adapter)
expect("Claude's plan and windows come from its sign-in and Anthropic's answer",
       [fresh["tierLabel"], labels(fresh), [entry["percent"] for entry in fresh["limits"]]],
       ["Max 5x", ["Session (5-hour)", "Weekly (7-day)"], [0.4, 0.1]], fresh)
check_scan_cache(adapter)

# Anthropic rate-limits its usage endpoint readily, and a 429 only says "ask
# later": numbers measured minutes ago still describe the account, so only
# older ones count as stale. Either way the record says when they were measured.
for ago, age, live in ((60, "a minute", True), (1800, "half an hour", False)):
  kept_limits(ago, [{"label": "Session (5-hour)", "percent": 0.4, "resetsAt": iso_in(3 * 3600)}])
  fetched_at = json.loads((cache_root() / "claude-limits.json").read_text())["fetchedAtMs"]
  record, _ = claude(mode=429)
  expect(f"a rate-limited re-check of numbers {age} old counts as {'current' if live else 'stale'}, with no sooner retry",
         [record["limitsStale"], record["limits"][0]["percent"], record["limitsFetchedAt"] == fetched_at, record.get("retryAdvised", False)],
         [not live, 0.4, True, False], record)

# The single home keeps its numbers under who it is signed in as, so signing
# it in to another account never shows the last one's, stale or current.
sandbox()
signed_in()
write_json(home() / ".claude.json", {"oauthAccount": {"accountUuid": "acct-A"}})
record, _ = claude()
expect("Claude's single home reads account A's limits", [entry["percent"] for entry in record["limits"]], [0.4, 0.1], record)
signed_in(token="token-b")
write_json(home() / ".claude.json", {"oauthAccount": {"accountUuid": "acct-B"}})
for mode in ("down", 429):
  record, _ = claude(mode=mode)
  expect(f"account B signed in to the same home never shows account A's limits ({mode})",
         [record["limits"], record["usageStatusText"]], [[], "Claude limits unavailable"], record)

# ------------------------------------------------------------ the sign-in

# An open window and one that already reset, cached long enough ago that a
# live token would ask again rather than reuse them.
sandbox()
WINDOWS = [
  {"label": "Session (5-hour)", "percent": 0.31, "resetsAt": iso_in(-3 * 3600)},
  {"label": "Weekly (7-day)", "percent": 0.11, "resetsAt": iso_in(3 * 3600)},
]

# Both tokens lapsed is a genuine sign-out. It used to return an empty limits
# list and no status at all, which hides the panel's whole limits section
# without saying why. Nothing is asked of Anthropic.
signed_in(expires=1000, refresh_expires=1000)
kept_limits(3600, WINDOWS)
record, http = claude()
check("Claude collector reports an expired sign-in instead of hiding the section, asking nothing",
      record["usageStatusText"] == "Sign-in expired" and "claude auth login" in record["authHelpText"] and http.count == 0, record)
expect("Claude collector keeps cached windows and resets just the elapsed one",
       [(entry["label"], entry["percent"], entry["resetsAt"]) for entry in record["limits"]],
       [("Session (5-hour)", 0.0, ""), ("Weekly (7-day)", 0.11, WINDOWS[1]["resetsAt"])], record)

# A wholly reset cache still shows the empty allowance.
kept_limits(3600, WINDOWS[:1])
record, _ = claude()
check("Claude collector resets a wholly elapsed cache to zero, with its guidance",
      [entry["percent"] for entry in record["limits"]] == [0] and record["usageStatusText"] == "Sign-in expired"
      and "last known" in record["authHelpText"], record)

# A machine left overnight finds the access token lapsed and the refresh
# token fine: routine, and nothing a person fixes by signing in again.
signed_in(expires=1000, refresh_expires=ms_in(30 * 86400))
kept_limits(3600, WINDOWS)
record, http = claude()
check("Claude collector calls a lapsed access token paused, not signed out",
      record["usageStatusText"] == "Limits paused" and "claude auth login" not in record["authHelpText"]
      and labels(record) == ["Session (5-hour)", "Weekly (7-day)"] and http.count == 0, record)

# A signed-out machine says so, and still shows what it last knew.
(home() / ".claude" / ".credentials.json").unlink()
record, _ = claude()
check("Claude collector serves open cached windows without a token",
      record["usageStatusText"] == "Waiting for auth" and labels(record) == ["Session (5-hour)", "Weekly (7-day)"], record)

# ------------------------------------------------------------ usage credits

sandbox()
signed_in()


def money(minor, currency="EUR", exponent=2):
  return {"amount_minor": minor, "currency": currency, "exponent": exponent}


def enabled(used, limit):
  return {"enabled": True, "used": used, "limit": limit}


def credits_of(spend):
  read = read_limits({"five_hour": {"utilization": 0.0}, "spend": spend})
  return [entry for entry in read["limits"] if "spend" in entry]


# The money is minor units over 10 ** exponent: 45820 at exponent 2 is
# 458.20, and 458.20 of 500.00 is 91.64%. A refund below zero empties the
# meter and keeps the signed amount; spending past the cap fills it.
for name, spend, percent, amounts in (
  ("a share of the cap", enabled(money(45820), money(50000)),
   0.9164, (458.2, 500.0, "EUR")),
  ("past the cap", enabled(money(60000), money(50000)),
   1.0, (600.0, 500.0, "EUR")),
  ("a refund", enabled(money(-500), money(50000)),
   0.0, (-5.0, 500.0, "EUR")),
  ("a zero-decimal currency",
   enabled(money(25000, "JPY", 0), money(50000, "JPY", 0)),
   0.5, (25000.0, 50000.0, "JPY")),
):
  read = credits_of(spend)
  expect(f"Claude collector reads usage credits as a window: {name}",
         [(entry["label"], round(entry["percent"], 6),
           tuple(entry["spend"].values())) for entry in read],
         [("Usage credits", percent, amounts)], read)

# No allowance, or one it cannot read, is no window rather than a guess.
for name, spend in (
  ("no spend object", None),
  ("credits switched off",
   {"enabled": False, "used": money(0), "limit": money(50000)}),
  ("no cap", enabled(money(100), None)),
  ("a zero cap", enabled(money(100), money(0))),
  ("two currencies", enabled(money(100, "USD"), money(50000))),
  ("no exponent",
   enabled({"amount_minor": 100, "currency": "EUR"}, money(50000))),
  ("a negative exponent", enabled(money(100, exponent=-2), money(50000))),
  ("an amount as text", enabled(money("100"), money(50000))),
  ("an amount as a boolean", enabled(money(True), money(50000))),
  ("an amount that is not a number",
   enabled(money(float("nan")), money(50000))),
):
  read = credits_of(spend)
  expect(f"Claude collector adds no credit window for {name}", read, [], read)

# Credits refill on the first of the coming month, dated in the offset that
# day carries: Stockholm leaves summer time on 25 October 2026 and enters it
# on 29 March 2026.
collector = load_collector("claude")
zone = os.environ.get("TZ")
for now, tz, expected in (
  (datetime(2026, 10, 15, 12), "Europe/Stockholm",
   "2026-11-01T00:00:00+01:00"),
  (datetime(2026, 3, 15, 12), "Europe/Stockholm",
   "2026-04-01T00:00:00+02:00"),
  (datetime(2026, 12, 31, 23), "UTC", "2027-01-01T00:00:00+00:00"),
):
  os.environ["TZ"] = tz
  time.tzset()
  expect(f"Claude credits reset on the first after {now:%Y-%m-%d} ({tz})",
         collector.next_month_start(now), expected, now)
if zone is None:
  os.environ.pop("TZ")
else:
  os.environ["TZ"] = zone
time.tzset()

WEEKLY = {"label": "Weekly (7-day)", "percent": 0.11,
          "resetsAt": iso_in(3 * 3600)}
CREDITS = {"label": "Usage credits", "title": "Usage credits",
           "percent": 0.92, "resetsAt": iso_in(10 * 86400),
           "spend": {"used": 458.2, "limit": 500.0, "currency": "EUR"}}

# Inside the reuse interval the cache is the last probe's answer, credits
# and all, and Anthropic is not asked again.
sandbox()
signed_in()
kept_limits(5, [WEEKLY, CREDITS])
record, http = claude("--limits-only")
check("Claude collector reuses a fresh cache with its credit window",
      labels(record) == ["Weekly (7-day)", "Usage credits"]
      and not any(USAGE in r["url"] for r in http.requests), record)


def no_token():
  signed_in()
  (home() / ".claude" / ".credentials.json").unlink()


def expired():
  signed_in(expires=1000, refresh_expires=1000)


# Past a failed check, money measured within CURRENT_ENOUGH_SECONDS (900)
# still describes the account, as the windows beside it do. Older money could
# misreport weeks of spending, so it waits for a check that lands.
for name, plant, mode in (
  ("an expired sign-in", expired, "up"),
  ("no sign-in", no_token, "up"),
  ("an unreachable endpoint", signed_in, "down"),
  ("a refused check", signed_in, 429),
):
  for ago, kept in ((60, True), (890, True), (910, False), (1800, False)):
    sandbox()
    plant()
    kept_limits(ago, [WEEKLY, CREDITS])
    record, _ = claude(mode=mode)
    verb = "keeps" if kept else "drops"
    expect(f"Claude collector {verb} cached credits {ago}s old after {name}",
           labels(record),
           ["Weekly (7-day)"] + (["Usage credits"] if kept else []), record)
PY
