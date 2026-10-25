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
from unittest.mock import patch

from agent_usage_fixtures import *

USAGE = "api.anthropic.com/api/oauth/usage"
ROUTES = {USAGE: {"five_hour": {"utilization": 40.0, "resets_at": iso_in(3600)}, "seven_day": {"utilization": 10.0, "resets_at": iso_in(86400)}}}


# The sign-in the Claude Code CLI leaves: an access token living about eight
# hours, and the refresh token behind it about thirty days.
def signed_in(token="token", expires=None, refresh_expires=0, where=None):
  write_json((where or home() / ".claude") / ".credentials.json", {"claudeAiOauth": {
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


# Only the interpreter and file tools, so no claude or mise on this machine
# can answer for the stand-in CLI.
CLI_BIN = Path(os.environ["SANDBOX"]) / "claude-cli"
os.environ["PATH"] = f"{CLI_BIN}:{Path(os.environ['SANDBOX']) / 'tools'}"


# A stand-in Claude Code CLI that logs every run to ~/claude-calls, names its
# version, and on `auth status` renews the access token of the home
# CLAUDE_CONFIG_DIR names (else ~/.claude) when RENEWS.
FAKE_CLAUDE = r'''
import json, os, sys, time
from pathlib import Path
with open(Path.home() / "claude-calls", "a") as log:
  log.write(json.dumps({"args": sys.argv[1:], "env": dict(os.environ)}) + "\n")
if sys.argv[1:] == ["--version"]:
  print(VERSION + " (Claude Code)")
elif sys.argv[1:] == ["auth", "status"] and RENEWS:
  path = Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude") / ".credentials.json"
  credentials = json.loads(path.read_text())
  credentials["claudeAiOauth"].update(accessToken="renewed", expiresAt=int(time.time() * 1000) + 8 * 3600 * 1000)
  path.write_text(json.dumps(credentials))
'''


def fake_claude(renews=False, version="2.1.310"):
  CLI_BIN.mkdir(exist_ok=True)
  (CLI_BIN / "claude").write_text(f"#!/usr/bin/python3\nVERSION, RENEWS = {version!r}, {renews!r}\n{FAKE_CLAUDE}")
  (CLI_BIN / "claude").chmod(0o755)


# The CLI runs logged since the last call, and the log emptied.
def cli_calls():
  log = home() / "claude-calls"
  calls = [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []
  log.unlink(missing_ok=True)
  return calls


def cli_args():
  return [call["args"] for call in cli_calls()]


REFRESH = [["--version"], ["auth", "status"]]


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
fake_claude()

# Both tokens lapsed is a genuine sign-out. It used to return an empty limits
# list and no status at all, which hides the panel's whole limits section
# without saying why. Nothing is asked of Anthropic, nor of the CLI, which
# has nothing left to refresh with.
signed_in(expires=1000, refresh_expires=1000)
kept_limits(3600, WINDOWS)
record, http = claude()
check("Claude collector reports an expired sign-in instead of hiding the section, asking nothing",
      record["usageStatusText"] == "Sign-in expired" and "claude auth login" in record["authHelpText"]
      and http.count == 0 and cli_args() == [], record)
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
# token fine: routine, and nothing a person fixes by signing in again. The
# CLI is run to refresh it, and one that renews nothing leaves it paused.
signed_in(expires=1000, refresh_expires=ms_in(30 * 86400))
kept_limits(3600, WINDOWS)
record, http = claude()
check("Claude collector calls a lapsed access token the CLI didn't renew paused, not signed out",
      record["usageStatusText"] == "Limits paused" and "claude auth login" not in record["authHelpText"]
      and labels(record) == ["Session (5-hour)", "Weekly (7-day)"] and http.count == 0 and cli_args() == REFRESH, record)

# The CLI is asked again for the same sign-in once the half hour is up, not on
# every panel refresh, unless refresh is pressed.
claude("--limits-only")
expect("Claude collector runs the CLI once per half hour", cli_args(), [])
claude("--force")
expect("Claude collector runs the CLI again when refresh is pressed", cli_args(), REFRESH)
write_json(next(cache_root().glob("claude-refresh-*.json")), {"attemptedAtMs": ms_in(-1801)})
claude("--limits-only")
expect("Claude collector runs the CLI again half an hour on", cli_args(), REFRESH)

# Before 2.1.301 `claude auth status` could exit mid-refresh and sign the
# home out, so an older CLI is only asked its version.
fake_claude(renews=True, version="2.1.300")
with contextlib.redirect_stderr(io.StringIO()):
  record, _ = claude()
expect("Claude collector never refreshes with a CLI older than 2.1.301",
       [record["usageStatusText"], cli_args()], ["Limits paused", [["--version"]]], record)

# A CLI that renews the token unpauses the limits, probed with the new token.
# It runs without the variables that would hand it a Claude Code session's
# sign-in or another credential, and with no CLAUDE_CONFIG_DIR for
# ~/.claude, whose profile is ~/.claude.json rather than one inside it.
fake_claude(renews=True)
SESSION_VARS = {"CLAUDECODE": "1", "CLAUDE_CODE_ENTRYPOINT": "claude-desktop", "ANTHROPIC_BASE_URL": DEAD_PROXY}
with patch.dict(os.environ, SESSION_VARS):
  record, http = claude()
expect("Claude collector probes with the token the CLI renewed",
       [record["usageStatusText"], record["limitsStale"], [request["headers"]["authorization"] for request in http.requests]],
       ["", False, ["Bearer renewed"]], record)
expect("Claude collector runs the CLI clear of a session's variables and the default home's config dir",
       [[name for name in call["env"] if name in {*SESSION_VARS, "CLAUDE_CONFIG_DIR"}] for call in cli_calls()], [[], []])

# Another account's home is refreshed in place, the CLI pointed at it.
side = home() / "side"
signed_in(token="side-token", expires=1000, refresh_expires=ms_in(30 * 86400), where=side)
write_json(side / ".claude.json", {"oauthAccount": {"accountUuid": "acct-side"}})
accounts = registry("claude", [{"id": "main", "primary": True}, {"id": "side", "home": str(side)}], active="main")
record, _ = claude()
expect("Claude collector refreshes another account's lapsed token in its own home",
       [[entry["usageStatusText"] for entry in record["accounts"]], [call["env"].get("CLAUDE_CONFIG_DIR") for call in cli_calls()]],
       [["", ""], [str(side.resolve())] * 2], record)
accounts.unlink()

# A signed-out machine says so, and still shows what it last knew.
(home() / ".claude" / ".credentials.json").unlink()
record, _ = claude()
check("Claude collector serves open cached windows without a token",
      record["usageStatusText"] == "Waiting for auth" and labels(record) == ["Session (5-hour)", "Weekly (7-day)"], record)
PY
