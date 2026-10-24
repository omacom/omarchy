#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command jq

# login_limits decides between a subscription's limits and an API key's none,
# over a planted home: the CLI's profile (.claude.json) beside the config
# directory, its credentials and settings inside it. No network: an API key
# never reaches the usage endpoint, a missing login stops before it, and the
# subscription cases use a lapsed access token, which stops before it too.
SANDBOX=$(mktemp -d) || fail "a temporary directory can be created"
trap 'rm -rf "${SANDBOX:?}"' EXIT

now_ms=$(date +%s%3N)
# A subscription the CLI can still refresh: the access token lapsed (routine),
# the refresh token has not.
paused_subscription=$(printf '{"claudeAiOauth":{"accessToken":"token","expiresAt":%s,"refreshTokenExpiresAt":%s,"subscriptionType":"max","rateLimitTier":"default_claude_max_5x"}}' \
  $((now_ms - 1000)) $((now_ms + 86400000)))
# One whose refresh expiry the credentials don't record.
unknown_refresh_subscription=$(printf '{"claudeAiOauth":{"accessToken":"token","expiresAt":%s,"subscriptionType":"max","rateLimitTier":"default_claude_max_5x"}}' \
  $((now_ms - 1000)))
# One a person would have to sign in to again.
lapsed_subscription=$(printf '{"claudeAiOauth":{"accessToken":"token","expiresAt":%s,"refreshTokenExpiresAt":%s,"subscriptionType":"max","rateLimitTier":"default_claude_max_5x"}}' \
  $((now_ms - 86400000)) $((now_ms - 1000)))

# Plants a home from T_PROFILE, T_SETTINGS, T_SETTINGS_LOCAL and T_CREDENTIALS
# (empty means absent; the credentials default to none) and prints what
# login_limits says of it. Extra arguments are environment settings.
login() {
  local home
  home=$(mktemp -d "$SANDBOX/home.XXXXXX")
  mkdir "$home/.claude"
  printf '%s' "${T_CREDENTIALS:-{\}}" >"$home/.claude/.credentials.json"
  [[ -n ${T_PROFILE:-} ]] && printf '%s' "$T_PROFILE" >"$home/.claude.json"
  [[ -n ${T_SETTINGS:-} ]] && printf '%s' "$T_SETTINGS" >"$home/.claude/settings.json"
  [[ -n ${T_SETTINGS_LOCAL:-} ]] && printf '%s' "$T_SETTINGS_LOCAL" >"$home/.claude/settings.local.json"

  env -u CLAUDE_CONFIG_DIR -u ANTHROPIC_API_KEY -u ANTHROPIC_AUTH_TOKEN "$@" \
    HOME="$home" XDG_CACHE_HOME="$home/.cache" XDG_STATE_HOME="$home/.state" \
    COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" CLAUDE_DIR="$home/.claude" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os, pathlib

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

home = pathlib.Path(os.environ["CLAUDE_DIR"])
plan, limits = collector.login_limits(home, False)
account = collector.account_limits({"id": "work", "home": str(home), "active": True}, False)
print(json.dumps({"plan": plan, "limits": limits["limits"], "status": limits["usageStatusText"],
  "stale": not limits["live"], "accountPlan": account["plan"], "accountStatus": account["usageStatusText"]}))
PY
}

api_key() { # NAME [VAR=VALUE...]: the planted home must read as an API-key login
  local name=$1 result
  shift
  result=$(login "$@") || fail "an API key login ($name) is read" "$result"
  jq -e '.plan == "API key" and .limits == [] and .status == "" and .stale == false' <<<"$result" >/dev/null ||
    fail "an API key login ($name) shows as API key, without limits, a sign-in prompt or a stale mark" "$result"
  jq -e '.accountPlan == "API key" and .accountStatus == ""' <<<"$result" >/dev/null ||
    fail "an API key login ($name) reads the same as a registered account" "$result"
}

T_PROFILE='{"primaryApiKey":"sk-ant-test"}' api_key "the CLI's own key"
T_SETTINGS='{"apiKeyHelper":"pass show anthropic"}' api_key "a key helper in the settings"
T_SETTINGS='{"env":{"ANTHROPIC_API_KEY":"sk-ant-test"}}' api_key "a key in the settings' env block"
T_SETTINGS='{"env":{"ANTHROPIC_AUTH_TOKEN":"token"}}' api_key "an auth token in the settings' env block"
api_key "a key in the environment" ANTHROPIC_API_KEY=sk-ant-test
api_key "an auth token in the environment" ANTHROPIC_AUTH_TOKEN=token
pass "an API key login shows as API key, without limits or a sign-in prompt, wherever the key is configured"

result=$(T_PROFILE='{"primaryApiKey":"sk-ant-secret-value"}' login)
[[ $result != *"sk-ant-secret-value"* ]] || fail "the API key itself never reaches the record" "$result"
pass "the API key itself never reaches the record"

result=$(login)
jq -e '.status == "Waiting for auth"' <<<"$result" >/dev/null ||
  fail "with neither a subscription nor an API key it still waits for a sign-in" "$result"
result=$(T_PROFILE='{"primaryApiKey":""}' login)
jq -e '.status == "Waiting for auth"' <<<"$result" >/dev/null ||
  fail "an empty API key doesn't count as signed in" "$result"
result=$(T_SETTINGS='[1,2]' T_PROFILE='"text"' login)
jq -e '.status == "Waiting for auth"' <<<"$result" >/dev/null ||
  fail "settings that aren't an object don't count as signed in" "$result"
# The settings' env block wins over the environment, as in the CLI: one that
# empties the variable leaves no key.
result=$(T_SETTINGS='{"env":{"ANTHROPIC_API_KEY":""}}' login ANTHROPIC_API_KEY=sk-ant-test)
jq -e '.status == "Waiting for auth"' <<<"$result" >/dev/null ||
  fail "an exported key the settings empty doesn't count as signed in" "$result"
# settings.local.json in the config directory is a project's file: `claude auth
# status` stays signed out with a key only there, so the panel must too.
result=$(T_SETTINGS_LOCAL='{"apiKeyHelper":"pass show anthropic","env":{"ANTHROPIC_API_KEY":"sk-ant-test"}}' login)
jq -e '.status == "Waiting for auth"' <<<"$result" >/dev/null ||
  fail "a key only in settings.local.json doesn't count as signed in" "$result"
pass "with neither a subscription nor an API key it still waits for a sign-in"

# A subscription the CLI can still refresh leads, even beside a key.
result=$(T_CREDENTIALS="$paused_subscription" T_PROFILE='{"primaryApiKey":"sk-ant-test"}' login)
jq -e '.plan == "Max 5x" and .status == "Limits paused"' <<<"$result" >/dev/null ||
  fail "a subscription login leads while it can be refreshed" "$result"
pass "a subscription login leads while it can be refreshed"

# One a person would have to sign in to again is shadowed by a working key.
result=$(T_CREDENTIALS="$lapsed_subscription" login)
jq -e '.status == "Sign-in expired"' <<<"$result" >/dev/null ||
  fail "a lapsed subscription on its own asks for a sign-in" "$result"
result=$(T_CREDENTIALS="$lapsed_subscription" T_PROFILE='{"primaryApiKey":"sk-ant-test"}' login)
jq -e '.plan == "API key" and .status == ""' <<<"$result" >/dev/null ||
  fail "a lapsed subscription beside a key reads as the key" "$result"
# So is one whose access token lapsed and whose credentials don't say when the
# refresh token does, which on its own reads as an expired sign-in too.
result=$(T_CREDENTIALS="$unknown_refresh_subscription" login)
jq -e '.status == "Sign-in expired"' <<<"$result" >/dev/null ||
  fail "a subscription whose refresh expiry is unknown asks for a sign-in on its own" "$result"
result=$(T_CREDENTIALS="$unknown_refresh_subscription" T_PROFILE='{"primaryApiKey":"sk-ant-test"}' login)
jq -e '.plan == "API key" and .status == "" and .limits == [] and .accountPlan == "API key"' <<<"$result" >/dev/null ||
  fail "a subscription whose refresh expiry is unknown, beside a key, reads as the key" "$result"
pass "a subscription that would ask for a sign-in reads as the key beside one"

# The whole record: an API-key login with no session yet is still ready, so
# the panel lists it rather than offering to add it.
home=$(mktemp -d "$SANDBOX/home.XXXXXX")
mkdir "$home/.claude"
printf '{}' >"$home/.claude/.credentials.json"
printf '{"primaryApiKey":"sk-ant-test"}' >"$home/.claude.json"
record=$(env -u CLAUDE_CONFIG_DIR -u ANTHROPIC_API_KEY -u ANTHROPIC_AUTH_TOKEN \
  HOME="$home" XDG_CACHE_HOME="$home/.cache" XDG_STATE_HOME="$home/.state" XDG_DATA_HOME="$home/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --force) || fail "the collector runs over an API-key home" "$record"
jq -e '.ready == true and .tierLabel == "API key" and .usageStatusText == "" and .limits == [] and .limitsStale == false' <<<"$record" >/dev/null ||
  fail "an API-key login with no session yet is ready, as API key" "$record"
[[ $record != *"sk-ant-test"* ]] || fail "the record never carries the key" "$record"
pass "an API-key login with no session yet is ready, as API key"
