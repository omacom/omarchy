#!/bin/bash

# The plan label the Claude collector settles on from the two files Claude
# Code keeps side by side: the credentials for the token, and the CLI's
# profile for the account it belongs to.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

CREDENTIALS = {"claudeAiOauth": {"accessToken": "token", "expiresAt": 1, "subscriptionType": "max", "rateLimitTier": "default_claude_max_5x"}}
UPGRADED = {"oauthAccount": {"organizationRateLimitTier": "default_claude_max_20x", "userRateLimitTier": None}}
STALE = {"oauthAccount": {"organizationRateLimitTier": "default_claude_max_5x", "userRateLimitTier": None}}


def plan_of(directory):
  return load_collector("claude").oauth_login(Path(directory))[-1]


# The profile sits in $HOME by default, inside the config directory when
# CLAUDE_CONFIG_DIR moved the whole config elsewhere, or as a legacy
# .config.json inside it; `where` says which shape to plant, and `stray`
# leaves a copy in the place the CLI does not read.
def read_plan(credentials, profile=None, where="beside", stray=None):
  sandbox()
  directory = home() / ".claude"
  write_json(directory / ".credentials.json", credentials)
  live, other = {
    "beside": (home() / ".claude.json", directory / ".claude.json"),
    "inside": (directory / ".claude.json", home() / ".claude.json"),
    "legacy": (directory / ".config.json", home() / ".claude.json"),
  }[where]
  if where == "inside":
    os.environ["CLAUDE_CONFIG_DIR"] = str(directory)
  if profile is not None:
    write_json(live, profile)
  if stray is not None:
    write_json(other, stray)
  return plan_of(directory)


def credentials(tier, subscription):
  return {"claudeAiOauth": {"accessToken": "token", "expiresAt": 1, "rateLimitTier": tier, "subscriptionType": subscription}}


# The tier in the credentials is the one the token was minted with. An upgraded
# account keeps it there, so the profile the CLI refreshes decides the label.
expect("Claude collector labels the plan from the refreshed profile", read_plan(CREDENTIALS, UPGRADED), "Max 20x")

# CLAUDE_CONFIG_DIR takes the profile along with the rest of the config.
expect("Claude collector finds the profile inside a relocated config directory", read_plan(CREDENTIALS, UPGRADED, "inside"), "Max 20x")

# A copy of the profile in the place the CLI does not read is never refreshed,
# so it must not outrank the live one, whichever way the config is laid out.
expect("Claude collector reads only the profile the CLI keeps",
       {where: read_plan(CREDENTIALS, UPGRADED, where, STALE) for where in ("beside", "inside", "legacy")},
       {"beside": "Max 20x", "inside": "Max 20x", "legacy": "Max 20x"})

# A seat with a tier of its own is limited by that tier, not by its org's.
expect("Claude collector prefers the seat's own tier over the organization's",
       read_plan(CREDENTIALS, {"oauthAccount": {"organizationRateLimitTier": "default_claude_max_20x", "userRateLimitTier": "default_claude_max_5x"}}), "Max 5x")

# Without a profile, or with one that states no tier, or a tier the label
# cannot read, the credentials are all there is, and they still answer.
profiles = [None, {}, {"oauthAccount": {"organizationRateLimitTier": None}}, {"oauthAccount": {"organizationRateLimitTier": "default_claude_unknown"}}]
expect("Claude collector falls back to the credentials when the profile names no readable tier",
       [read_plan(CREDENTIALS, profile) for profile in profiles], ["Max 5x"] * len(profiles))

# A Team seat runs on a Max tier; the refreshed profile changes the multiplier
# but never turns the seat into Max.
expect("Claude collector keeps a Team seat's label when the profile names its tier",
       read_plan(credentials("default_claude_max_5x", "team"), UPGRADED), "Team 20x")

# A secondary account's home has its own profile; ~/.claude.json describes the
# primary account and must never lend it its tier.
sandbox()
write_json(home() / ".claude.json", UPGRADED)
write_json(home() / "accounts" / "work" / ".credentials.json", CREDENTIALS)
(home() / ".claude").mkdir()
expect("Claude collector never labels a secondary account from the primary's profile", plan_of(home() / "accounts" / "work"), "Max 5x")

# The credentials carry two plan facts: the subscription and the rate-limit
# tier it runs under. With no profile beside them, they settle the label. A
# Team premium seat runs on the Max 5x rate-limit tier, and the tier alone
# used to label it "Max 5x", the plan the seat is not on.
expect("Claude collector labels a Team seat by its subscription, not its rate-limit tier",
       read_plan(credentials("default_claude_max_5x", "team")), "Team 5x")

# Max keeps its multiplier, with or without a subscription type alongside the
# tier, and a plan whose tier names no multiplier is just the plan.
expect("Claude collector keeps Max multipliers and plain plan names", [
  read_plan(credentials("default_claude_max_20x", "max")), read_plan(credentials("default_claude_max_5x", "")),
  read_plan(credentials("default_claude_pro", "pro")), read_plan(credentials("", "team")),
], ["Max 20x", "Max 5x", "Pro", "Team"])
PY
