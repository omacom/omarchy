#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command python3

# oauth_login reads two files that only ever exist side by side, so the plan it
# settles on is exercised over a planted config directory: credentials for the
# token, the CLI's profile for the account it belongs to. The profile sits in
# $HOME by default and inside the config directory when CLAUDE_CONFIG_DIR moved
# the whole config elsewhere, so the caller says which shape to plant, and may
# leave a stale copy in the place the CLI does not read.
SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT

read_plan() {
  local credentials="$1" profile="$2" where="${3:-beside}" stray="${4:-}"
  local home dir live other relocated plan
  home=$(mktemp -d "$SANDBOX/home.XXXXXX")
  dir="$home/.claude"
  mkdir "$dir"
  printf '%s' "$credentials" >"$dir/.credentials.json"
  if [[ $where == "inside" ]]; then
    live="$dir/.claude.json" other="$home/.claude.json" relocated="$dir"
  elif [[ $where == "legacy" ]]; then
    live="$dir/.config.json" other="$home/.claude.json" relocated=""
  else
    live="$home/.claude.json" other="$dir/.claude.json" relocated=""
  fi
  [[ -n $profile ]] && printf '%s' "$profile" >"$live"
  [[ -n $stray ]] && printf '%s' "$stray" >"$other"

  plan=$(env -u CLAUDE_CONFIG_DIR ${relocated:+CLAUDE_CONFIG_DIR="$relocated"} HOME="$home" \
    COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" CLAUDE_DIR="$dir" python3 - <<'PY'
import importlib.machinery, importlib.util, os, pathlib

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

print(collector.oauth_login(pathlib.Path(os.environ["CLAUDE_DIR"]))[-1])
PY
  )

  printf '%s' "$plan"
}

credentials='{"claudeAiOauth":{"accessToken":"token","expiresAt":1,"subscriptionType":"max","rateLimitTier":"default_claude_max_5x"}}'
upgraded='{"oauthAccount":{"organizationRateLimitTier":"default_claude_max_20x","userRateLimitTier":null}}'

# The tier in the credentials is the one the token was minted with. An upgraded
# account keeps it there, so the profile the CLI refreshes decides the label.
plan=$(read_plan "$credentials" "$upgraded")
[[ $plan == "Max 20x" ]] ||
  fail "Claude collector labels the plan from the refreshed profile" "$plan"
pass "Claude collector labels the plan from the refreshed profile"

# CLAUDE_CONFIG_DIR takes the profile along with the rest of the config.
plan=$(read_plan "$credentials" "$upgraded" inside)
[[ $plan == "Max 20x" ]] ||
  fail "Claude collector finds the profile inside a relocated config directory" "$plan"
pass "Claude collector finds the profile inside a relocated config directory"

# A copy of the profile in the place the CLI does not read is never refreshed,
# so it must not outrank the live one, whichever way the config is laid out.
stale='{"oauthAccount":{"organizationRateLimitTier":"default_claude_max_5x","userRateLimitTier":null}}'
for where in beside inside legacy; do
  plan=$(read_plan "$credentials" "$upgraded" "$where" "$stale")
  [[ $plan == "Max 20x" ]] ||
    fail "Claude collector reads only the profile the CLI keeps" "$where -> $plan"
done
pass "Claude collector reads only the profile the CLI keeps"

# A seat with a tier of its own is limited by that tier, not by its org's.
plan=$(read_plan "$credentials" '{"oauthAccount":{"organizationRateLimitTier":"default_claude_max_20x","userRateLimitTier":"default_claude_max_5x"}}')
[[ $plan == "Max 5x" ]] ||
  fail "Claude collector prefers the seat's own tier over the organization's" "$plan"
pass "Claude collector prefers the seat's own tier over the organization's"

# Without a profile — or with one that states no tier, or a tier the label
# cannot read — the credentials are all there is, and they still answer.
for profile in '' '{}' '{"oauthAccount":{"organizationRateLimitTier":null}}' '{"oauthAccount":{"organizationRateLimitTier":"default_claude_unknown"}}'; do
  plan=$(read_plan "$credentials" "$profile")
  [[ $plan == "Max 5x" ]] ||
    fail "Claude collector falls back to the credentials when the profile names no readable tier" "$profile -> $plan"
done
pass "Claude collector falls back to the credentials when the profile names no readable tier"

# A Team seat runs on a Max tier; the refreshed profile changes the multiplier
# but never turns the seat into Max.
team='{"claudeAiOauth":{"accessToken":"token","expiresAt":1,"subscriptionType":"team","rateLimitTier":"default_claude_max_5x"}}'
plan=$(read_plan "$team" "$upgraded")
[[ $plan == "Team 20x" ]] ||
  fail "Claude collector keeps a Team seat's label when the profile names its tier" "$plan"
pass "Claude collector keeps a Team seat's label when the profile names its tier"

# A secondary account's home has its own profile; ~/.claude.json describes the
# primary account and must never lend it its tier.
second_home=$(mktemp -d "$SANDBOX/home.XXXXXX")
mkdir -p "$second_home/.claude" "$second_home/accounts/work"
printf '%s' "$upgraded" >"$second_home/.claude.json"
printf '%s' "$credentials" >"$second_home/accounts/work/.credentials.json"
plan=$(env -u CLAUDE_CONFIG_DIR HOME="$second_home" COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" \
  CLAUDE_DIR="$second_home/accounts/work" python3 - <<'PY'
import importlib.machinery, importlib.util, os, pathlib

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

print(collector.oauth_login(pathlib.Path(os.environ["CLAUDE_DIR"]))[-1])
PY
)
[[ $plan == "Max 5x" ]] ||
  fail "Claude collector never labels a secondary account from the primary's profile" "$plan"
pass "Claude collector never labels a secondary account from the primary's profile"
