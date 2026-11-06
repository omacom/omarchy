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
PY
