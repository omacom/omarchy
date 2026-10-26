#!/bin/bash

# The Grok collector's own sources: the sign-in and plan the Grok CLI keeps in
# its home, xAI's credits answer, and the session summaries and usage ledgers
# beside each session. The unused-machine record is held centrally by the
# partition test, and the limits and scan caches by the contract checks.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

PERIOD_END = iso_in(9 * 86400)
USED = {"token-main": 42.0, "token-side": 7.0, "token-fresh": 0}
answer = {"percent": None, "end": None}


# Shaped like xAI's answer: protobuf JSON under config, which drops a
# percentage of zero. A unified-billing account has no percentage there at
# all; its monthly quota comes on the billing answer without the credits
# format, its amounts money fields of {"val": n}.
def credits(request):
  token = request.get_header("Authorization").split(" ", 1)[1]
  config = {"currentPeriod": {"type": "USAGE_PERIOD_TYPE_WEEKLY", "end": answer["end"] or PERIOD_END}, "billingPeriodEnd": PERIOD_END}
  if USED.get(token):
    config["creditUsagePercent"] = USED[token]
  if answer["percent"] is not None:
    config["creditUsagePercent"] = answer["percent"]
  if token == "token-unified":
    config["isUnifiedBillingUser"] = True
  return {"config": config}


def monthly(request):
  return {"config": {"isUnifiedBillingUser": True, "billingPeriodStart": iso_in(-20 * 86400), "billingPeriodEnd": PERIOD_END,
                     "monthlyLimit": {"val": 1000}, "used": {"val": 900}}}


ROUTES = {"cli-chat-proxy.grok.com/v1/billing?format=credits": credits, "cli-chat-proxy.grok.com/v1/billing": monthly}


# A home signed in the way the Grok CLI leaves it.
def signed_in(grok_home, token="token-main", user="u-main", expires=None, tier="X Premium+", **extra):
  login = {"key": token, "user_id": user, "email": user + "@example.com", "expires_at": expires or iso_in(6 * 3600), **extra}
  write_json(Path(grok_home) / "auth.json", {"https://auth.x.ai::client": login})
  write_json(Path(grok_home) / "settings_cache.json", {"payload": json.dumps({"settings": {"subscription_tier_display": tier}})})


def summary(grok_home, name, active_at, prompts):
  write_json(Path(grok_home) / "sessions" / "%2Fhome%2Fme" / name / "summary.json", {"last_active_at": active_at, "num_messages": prompts})


def grok(*args):
  with FakeHttp(ROUTES):
    return collect("grok", *(args or ("--force",)))


def grok_home():
  return home() / ".grok"


# ---------------------------------------------------------------- the home

# The partition test holds the rest of the unused-machine record; whether a
# record's stats are this machine's is each collector's to say.
sandbox()
record = grok()
expect("a machine without Grok has no local Grok stats", [record["ready"], record["hasLocalStats"]], [False, False], record)

# A Grok home with no sign-in in it has been set up, so the sign-in is what's
# missing.
(home() / "bare-grok").mkdir()
os.environ["GROK_HOME"] = str(home() / "bare-grok")
record = grok()
expect("a signed-out Grok home waits for auth", [record["ready"], record["usageStatusText"]], [False, "Waiting for auth"], record)

# Sessions on disk put Grok in use here even with no sign-in, which is then
# what's missing.
os.environ["GROK_HOME"] = str(home() / "orphan")
summary(home() / "orphan", "one", "2026-01-02T10:00:00Z", 2)
record = grok()
expect("Grok sessions with no sign-in are in use, waiting for auth",
       [record["ready"], record["totalSessions"], record["usageStatusText"]], [True, 1, "Waiting for auth"], record)

# A home chosen with GROK_HOME is the one read, as the CLI itself does.
signed_in(home() / "custom-grok", tier="SuperGrok")
os.environ["GROK_HOME"] = str(home() / "custom-grok")
record = grok()
expect("a single Grok account in GROK_HOME is read from there",
       [record["ready"], record["tierLabel"], record["limits"][0]["percent"]], [True, "SuperGrok", 0.42], record)
del os.environ["GROK_HOME"]

# ---------------------------------------------------------------- contract

sandbox()


def add_session():
  add_session.count = getattr(add_session, "count", 0) + 1
  summary(grok_home(), f"grown-{add_session.count}", iso_in(0), 1)


adapter = Adapter("grok", plant=lambda: signed_in(grok_home()), answer=ROUTES, grow=add_session)
fresh = check_limits_contract(adapter)
expect("Grok's plan and weekly credits come from its own home and xAI's answer",
       [fresh["tierLabel"], fresh["limits"][0]["label"], fresh["limits"][0]["percent"], bool(fresh["limits"][0]["resetsAt"])],
       ["X Premium+", "Weekly", 0.42, True], fresh)
check_scan_cache(adapter)

# ------------------------------------------------------------ the sign-in

sandbox()
signed_in(grok_home())
grok()
signed_in(grok_home(), expires=iso_in(-3600))
record = grok()
expect("a lapsed sign-in keeps the last credits and says so",
       [record["usageStatusText"], record["limits"][0]["percent"], record["limitsStale"]], ["Sign-in expired", 0.42, True], record)

# A lapsed access token with a refresh token is routine: Grok renews it when it
# starts, so the limits are paused, the last numbers kept as stale, with no
# sign-in asked for.
signed_in(grok_home(), expires=iso_in(-3600), refresh_token="r")
record = grok()
expect("a lapsed access token with a refresh token pauses the limits, keeping the last numbers stale",
       [record["usageStatusText"], record["limits"][0]["percent"], record["limitsStale"], "Start Grok" in record["authHelpText"]],
       ["Limits paused", 0.42, True, True], record)

# A week that reset while Grok sat idle starts over at 0%, its next reset
# unknown until xAI says.
edit_limits_cache("grok", resets_past=True)
record = grok()
expect("a week that reset while Grok was idle starts over at zero",
       [record["limits"][0]["percent"], record["limits"][0]["resetsAt"], record["limitsStale"]], [0.0, "", True], record)

# Without cached numbers there's nothing to show, so it says how to get them.
for path in limits_cache_files("grok"):
  path.unlink()
record = grok()
expect("a lapsed token with nothing cached says to start Grok, with no limits to call stale", [record["usageStatusText"], record["limits"], record["limitsStale"]], ["Limits paused", [], False], record)

# A refresh token past Grok's 30-day sign-in can't renew anything: signed out.
signed_in(grok_home(), expires=iso_in(-31 * 86400), refresh_token="r")
record = grok()
expect("a sign-in lapsed past Grok's 30 days asks for a sign-in", record["usageStatusText"], "Sign-in expired", record)

# ------------------------------------------------------------- the answer

# A percentage that isn't a number is no answer, not a full allowance.
sandbox()
signed_in(grok_home())
answer["percent"] = float("nan")
record = grok()
answer["percent"] = None
expect("a Grok percentage that isn't a number reads as unavailable",
       [record["usageStatusText"], record["limits"]], ["Grok limits unavailable", []], record)

# A period with nothing used yet comes without a percentage.
for path in limits_cache_files("grok"):
  path.unlink()
signed_in(grok_home(), token="token-fresh")
record = grok()
expect("an untouched period reads as 0% rather than nothing known",
       [record["limits"][0]["label"], record["limits"][0]["percent"]], ["Weekly", 0.0], record)

# A period already over without a percentage says nothing about this one: no
# answer, the last numbers kept as stale.
answer["end"] = iso_in(-3600)
record = grok()
answer["end"] = None
expect("an ended period without a percentage is no answer, keeping the last numbers",
       [record["limits"][0]["percent"], record["limitsStale"]], [0.0, True], record)

# A unified-billing account leaves the percentage out of the credits answer,
# its usage counted against the monthly quota the plain billing answer gives.
sandbox()
signed_in(grok_home(), token="token-unified")
record = grok()
expect("a unified-billing account reads its monthly quota, not a confident 0%",
       [record["limits"][0]["label"], record["limits"][0]["percent"], record["limitsStale"], bool(record["limits"][0]["resetsAt"])],
       ["Monthly", 0.9, False, True], record)

# A unified-billing account can also carry a weekly percentage on the credits
# answer; Grok's /usage then shows the monthly included quota beside it.
sandbox()
signed_in(grok_home(), token="token-unified")
answer["percent"] = 30
record = grok()
answer["percent"] = None
expect("a unified-billing account with weekly credits shows the monthly quota beside them",
       [[limit["label"], limit["percent"]] for limit in record["limits"]], [["Weekly", 0.3], ["Monthly", 0.9]], record)

# ------------------------------------------------------------- accounts

sandbox()
signed_in(grok_home())
side = state_home() / "omarchy" / "agents" / "accounts" / "grok" / "side"
signed_in(side, token="token-side", user="u-side", tier="SuperGrok")
registry("grok", [
  {"id": "main", "label": "Main", "home": "", "primary": True},
  {"id": "side", "label": "Side", "home": str(side), "primary": False},
], active="side", switch="auto", threshold=90)
record = grok()
expect("every Grok account reports its own plan and credits", {
  "tierLabel": record["tierLabel"],
  "first": record["limits"][0]["percent"],
  "accounts": [{"id": a["id"], "active": a["active"], "plan": a["plan"], "percent": a["limits"][0]["percent"]} for a in record["accounts"]],
  "switch": record["accountSwitch"],
}, {
  "tierLabel": "SuperGrok",
  "first": 0.07,
  "accounts": [{"id": "main", "active": False, "plan": "X Premium+", "percent": 0.42}, {"id": "side", "active": True, "plan": "SuperGrok", "percent": 0.07}],
  "switch": {"mode": "auto", "threshold": 90},
}, record)

# ------------------------------------------------------------ odd shapes

# A ledger or settings cache of the wrong shape costs that field, never the
# record.
sandbox()
signed_in(grok_home())
write_json(grok_home() / "settings_cache.json", {"payload": json.dumps({"settings": "x"})})
summary(grok_home(), "odd", iso_in(0), 1)
write_json(grok_home() / "sessions" / "%2Fhome%2Fme" / "odd" / "usage.json", {"turns": [{"endedAt": iso_in(0), "modelUsage": ["grok-4.7-build"]}]})
record = grok()
expect("a list-shaped modelUsage and a non-object settings read as empty",
       [record["ready"], record["tierLabel"], record["todayPrompts"], record["modelUsage"]], [True, "", 1, {}], record)

# A session or turn time out of range (year 1, before 2000, past 2100) is an
# untrusted stamp: it skips that session or turn, never the record.
sandbox()
signed_in(grok_home())
summary(grok_home(), "good", iso_in(0), 2)
write_json(grok_home() / "sessions" / "%2Fhome%2Fme" / "good" / "usage.json", {"turns": [
  {"endedAt": iso_in(0), "modelUsage": {"grok-4.7-build": {"inputTokens": 10, "outputTokens": 1}}},
  {"endedAt": "0001-01-01T00:00:00+00:00", "modelUsage": {"grok-4.7-build": {"inputTokens": 500}}},
  {"endedAt": "9999-12-31T23:59:59+00:00", "modelUsage": {"grok-4.7-build": {"inputTokens": 500}}},
]})
for name, stamp in (("year1", "0001-01-01T00:00:00+00:00"), ("1970", "1970-01-01T00:00:00Z"), ("far", "2999-01-01T00:00:00Z")):
  summary(grok_home(), name, stamp, 7)
record = grok()
expect("Grok skips sessions and turns with out-of-range times",
       [record["totalSessions"], record["totalPrompts"], record["todayPrompts"], record["todayTotalTokens"], record["activeDates"]],
       [1, 1, 1, 11, [datetime.now().date().isoformat()]], record)

# ---------------------------------------------------------- local stats

# Sessions come from each session's summary; tokens and prompts from its
# usage.json, one entry per finished turn, with cached input kept apart. The
# summary's num_messages counts the model's replies too, so it isn't read.
sandbox()
signed_in(grok_home())
now = iso_in(0)
sessions = grok_home() / "sessions" / "%2Fhome%2Fme"
summary(grok_home(), "today-1", now, 3)
summary(grok_home(), "today-2", now, 2)
summary(grok_home(), "old", "2026-01-02T10:00:00Z", 5)
write_json(sessions / "today-1" / "usage.json", {"turns": [
  {"endedAt": now, "modelUsage": {"grok-4.7-build": {"inputTokens": 1000, "cachedReadTokens": 800, "outputTokens": 50, "cacheCreationTokens": 0, "totalTokens": 1050}}},
  {"endedAt": now, "modelUsage": {"grok-4.7-build": {"inputTokens": 200, "cachedReadTokens": 100, "outputTokens": 10, "cacheCreationTokens": 5, "totalTokens": 210}}},
]})
write_json(sessions / "old" / "usage.json", {"turns": [
  {"endedAt": "2026-01-02T10:00:00Z", "modelUsage": {"grok-4.6": {"inputTokens": 500, "cachedReadTokens": 0, "outputTokens": 20, "cacheCreationTokens": 0, "totalTokens": 520}}},
]})
record = grok()
expect("Grok counts sessions, prompts, and tokens from its session files",
       {key: record[key] for key in ("hasLocalStats", "todayPrompts", "todaySessions", "totalPrompts", "totalSessions", "activeDays", "todayTotalTokens", "todayTokensByModel")}
       | {"today": record["recentDays"][6]["messageCount"]},
       {"hasLocalStats": True, "todayPrompts": 2, "todaySessions": 2, "totalPrompts": 3, "totalSessions": 3, "activeDays": 2,
        "todayTotalTokens": 1265, "todayTokensByModel": {"grok-4.7-build": 1265}, "today": 1265}, record)
expect("Grok's tokens by model keep cached input apart", record["modelUsage"], {
  "grok-4.6": {"inputTokens": 500, "outputTokens": 20, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
  "grok-4.7-build": {"inputTokens": 300, "outputTokens": 60, "cacheReadInputTokens": 900, "cacheCreationInputTokens": 5},
}, record)

# A fork repeats its source's turns verbatim ahead of its own, as `grok -r
# <id> --fork-session` leaves its usage.json; each turn counts once. A
# subagent's turns are tokens spent, but no prompts typed.
sandbox()
signed_in(grok_home())
sessions = grok_home() / "sessions" / "%2Fhome%2Fme"


def turn(number, seconds_ago, tokens):
  ended = (datetime.now(timezone.utc) - timedelta(seconds=seconds_ago)).strftime("%Y-%m-%dT%H:%M:%S.620236893+00:00")
  usage = {"inputTokens": tokens, "outputTokens": 10, "cachedReadTokens": 0, "cacheCreationTokens": 0, "reasoningTokens": 5, "totalTokens": tokens + 10, "modelCalls": 1}
  return {"turnNumber": number, "endedAt": ended, **usage, "turnCount": 1, "primaryModelId": "grok-build", "modelUsage": {"grok-build": usage}}


first, second = turn(1, 4, 100), turn(2, 3, 200)
write_json(sessions / "source" / "summary.json", {"last_active_at": iso_in(-3), "num_messages": 7, "session_kind": "headless"})
write_json(sessions / "source" / "usage.json", {"turns": [first, second]})
write_json(sessions / "fork" / "summary.json", {"last_active_at": iso_in(-1), "num_messages": 11, "session_kind": "headless",
                                                 "parent_session_id": "source", "forked_at": iso_in(-2)})
write_json(sessions / "fork" / "usage.json", {"turns": [first, second, turn(3, 1, 400)]})
write_json(sessions / "child" / "summary.json", {"last_active_at": iso_in(-2), "num_messages": 5, "session_kind": "subagent"})
write_json(sessions / "child" / "usage.json", {"turns": [turn(1, 2, 800)]})
record = grok()
expect("a fork's copied turns count once, and a subagent's turns as tokens but no prompts",
       [record["totalSessions"], record["totalPrompts"], record["todayPrompts"], record["todayTotalTokens"]], [3, 3, 3, 1540], record)
PY
