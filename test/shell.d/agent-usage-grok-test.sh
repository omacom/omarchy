#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_STATE_HOME="$test_tmp/state"
export XDG_CACHE_HOME="$test_tmp/cache"

future=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=6)).isoformat())')
past=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=1)).isoformat())')
period_end=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(days=9)).isoformat())')

# A home signed in the way the Grok CLI leaves it.
signed_in() {
  mkdir -p "$1"
  jq -nc --arg token "$2" --arg user "$3" --arg expires "$4" \
    '{"https://auth.x.ai::client": {key: $token, user_id: $user, email: ($user + "@example.com"), expires_at: $expires}}' >"$1/auth.json"
  printf '{"payload":"{\\"settings\\":{\\"subscription_tier_display\\":\\"%s\\"}}"}\n' "$5" >"$1/settings_cache.json"
}

# xAI answers per token, so each home's probe is told apart by its sign-in.
collect() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-grok" python3 - "$@" <<'PY'
import importlib.machinery, importlib.util, io, json, os, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

used = {"token-main": 42.0, "token-side": 7.0, "token-fresh": 0}
end = os.environ["PERIOD_END"]

# Shaped like xAI's answer: protobuf JSON under config, which drops a
# percentage of zero.
def urlopen(request, timeout=None):
  assert request.full_url == collector.CREDITS_URL
  if os.environ.get("GROK_PROBES"):
    with open(os.environ["GROK_PROBES"], "a") as log:
      log.write("probe\n")
  failure = os.environ.get("GROK_FAIL")
  if failure == "unreachable":
    raise collector.urllib.error.URLError(OSError("Name or service not known"))
  if failure:
    raise collector.urllib.error.HTTPError(request.full_url, int(failure), "refused", {}, None)
  token = request.get_header("Authorization").split(" ", 1)[1]
  config = {"currentPeriod": {"type": "USAGE_PERIOD_TYPE_WEEKLY", "end": end}, "billingPeriodEnd": end}
  if used.get(token):
    config["creditUsagePercent"] = used[token]
  if os.environ.get("GROK_PERCENT"):
    config["creditUsagePercent"] = json.loads(os.environ["GROK_PERCENT"])
  return io.BytesIO(json.dumps({"config": config}).encode())

collector.urllib.request.urlopen = urlopen
sys.argv = ["omarchy-agent-usage-grok"] + (os.environ.get("COLLECT_ARGS") or "--force").split()
collector.main()
PY
}
export PERIOD_END="$period_end"

record=$(collect)
[[ $(jq -c '{ready, tierLabel, limits}' <<<"$record") == '{"ready":false,"tierLabel":"","limits":[]}' ]] ||
  fail "a machine nobody signed in to Grok on gives an empty record" "$record"
[[ $(jq -c '{hasLocalStats, totalPrompts, totalSessions, todayTotalTokens, days: (.recentDays | length), modelUsage, status: .usageStatusText}' <<<"$record") == '{"hasLocalStats":false,"totalPrompts":0,"totalSessions":0,"todayTotalTokens":0,"days":7,"modelUsage":{},"status":""}' ]] ||
  fail "an empty Grok record still carries the full stats block" "$record"
[[ $(jq -r '.authHelpText' <<<"$record") == "" ]] ||
  fail "a machine without Grok is not asked to sign in" "$record"
pass "a machine nobody signed in to Grok on gives an empty record"

# A Grok home with no sign-in in it has been set up, so the sign-in is
# what's missing.
mkdir -p "$test_tmp/bare-grok"
record=$(GROK_HOME="$test_tmp/bare-grok" collect)
[[ $(jq -c '{ready, status: .usageStatusText}' <<<"$record") == '{"ready":false,"status":"Waiting for auth"}' ]] ||
  fail "a signed-out Grok home waits for auth" "$record"
pass "a signed-out Grok home waits for auth"

# Sessions on disk put Grok in use here even with no sign-in, which is then
# what's missing.
mkdir -p "$test_tmp/orphan/sessions/%2Fhome%2Fme/one"
jq -n '{last_active_at: "2026-01-02T10:00:00Z", num_messages: 2}' >"$test_tmp/orphan/sessions/%2Fhome%2Fme/one/summary.json"
record=$(GROK_HOME="$test_tmp/orphan" collect)
[[ $(jq -c '{ready, totalSessions, status: .usageStatusText}' <<<"$record") == '{"ready":true,"totalSessions":1,"status":"Waiting for auth"}' ]] ||
  fail "Grok sessions with no sign-in are in use, waiting for auth" "$record"
pass "Grok sessions with no sign-in are in use, waiting for auth"

# A home chosen with GROK_HOME is the one read, as the CLI itself does.
signed_in "$test_tmp/custom-grok" token-main u-main "$future" "SuperGrok"
record=$(GROK_HOME="$test_tmp/custom-grok" collect)
[[ $(jq -c '{ready, tierLabel, percent: .limits[0].percent}' <<<"$record") == '{"ready":true,"tierLabel":"SuperGrok","percent":0.42}' ]] ||
  fail "a single Grok account in GROK_HOME is read from there" "$record"
pass "a single Grok account in GROK_HOME is read from there"
rm -f "$XDG_CACHE_HOME"/omarchy/agent-usage/grok-limits-*.json

signed_in "$HOME/.grok" token-main u-main "$future" "X Premium+"
record=$(collect)
[[ $(jq -c '{ready, tierLabel, stale: .limitsStale, label: .limits[0].label, percent: .limits[0].percent}' <<<"$record") == '{"ready":true,"tierLabel":"X Premium+","stale":false,"label":"Weekly","percent":0.42}' ]] ||
  fail "Grok's plan and credits come from its own home" "$record"
[[ -n $(jq -r '.limits[0].resetsAt' <<<"$record") ]] || fail "the credits window says when the period ends" "$record"
[[ $(jq -r '.authHelpText' <<<"$record") == "" ]] || fail "a successful Grok probe drops the login hint" "$record"
record=$(collect)
[[ $(jq -c '{percent: .limits[0].percent, help: .authHelpText}' <<<"$record") == '{"percent":0.42,"help":""}' ]] ||
  fail "reused Grok limits drop the login hint" "$record"
pass "Grok's plan and credits come from its own home"

signed_in "$HOME/.grok" token-main u-main "$past" "X Premium+"
record=$(collect)
[[ $(jq -c '{usageStatusText, first: .limits[0].percent, stale: .limitsStale}' <<<"$record") == '{"usageStatusText":"Sign-in expired","first":0.42,"stale":true}' ]] ||
  fail "a lapsed sign-in keeps the last credits and says so" "$record"
pass "a lapsed sign-in keeps the last credits and says so"

# A lapsed access token with a refresh token is routine: Grok renews it when it
# starts, and while it hasn't run nothing here has spent its allowance, so the
# last numbers stand as current, with no sign-in asked for.
jq '.[].refresh_token = "r"' "$HOME/.grok/auth.json" >"$test_tmp/auth.json"
mv "$test_tmp/auth.json" "$HOME/.grok/auth.json"
record=$(collect)
[[ $(jq -c '{usageStatusText, authHelpText, first: .limits[0].percent, stale: .limitsStale}' <<<"$record") == '{"usageStatusText":"","authHelpText":"","first":0.42,"stale":false}' ]] ||
  fail "a lapsed access token with a refresh token keeps showing the last numbers" "$record"
pass "a lapsed access token with a refresh token keeps showing the last numbers"

# A week that reset while Grok sat idle starts over at 0%, its next reset
# unknown until xAI says.
cache=$(ls "$XDG_CACHE_HOME"/omarchy/agent-usage/grok-limits-*.json | head -1)
reset_past=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=1)).isoformat())')
jq --arg at "$reset_past" '.limits[0].resetsAt = $at' "$cache" >"$test_tmp/cache.json"
mv "$test_tmp/cache.json" "$cache"
record=$(collect)
[[ $(jq -c '.limits[0] | {percent, resetsAt}' <<<"$record") == '{"percent":0.0,"resetsAt":""}' ]] ||
  fail "a week that reset while Grok was idle starts over at zero" "$record"
pass "a week that reset while Grok was idle starts over at zero"

# Without cached numbers there's nothing to show, so it says how to get them.
rm -f "$XDG_CACHE_HOME"/omarchy/agent-usage/grok-limits-*.json
record=$(collect)
[[ $(jq -c '{usageStatusText, limits}' <<<"$record") == '{"usageStatusText":"Limits paused","limits":[]}' ]] ||
  fail "a lapsed token with nothing cached says to start Grok" "$record"
pass "a lapsed token with nothing cached says to start Grok"

# A refresh token past Grok's 30-day sign-in can't renew anything: signed out.
long_ago=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=31)).isoformat())')
jq --arg at "$long_ago" '.[].expires_at = $at' "$HOME/.grok/auth.json" >"$test_tmp/auth.json"
mv "$test_tmp/auth.json" "$HOME/.grok/auth.json"
record=$(collect)
[[ $(jq -r '.usageStatusText' <<<"$record") == "Sign-in expired" ]] ||
  fail "a sign-in lapsed past Grok's 30 days asks for a sign-in" "$record"
pass "a sign-in lapsed past Grok's 30 days asks for a sign-in"

# A failed check keeps the last numbers, stale, and a window that has reset
# since comes back at zero rather than at what it read then.
signed_in "$HOME/.grok" token-main u-main "$future" "X Premium+"
rm -f "$XDG_CACHE_HOME"/omarchy/agent-usage/grok-limits-*.json
fresh=$(collect)
fetched_at=$(jq '.limitsFetchedAt' <<<"$fresh")
record=$(GROK_FAIL=500 collect)
[[ $(jq -c --argjson at "$fetched_at" '{stale: .limitsStale, at: (.limitsFetchedAt == $at), percent: .limits[0].percent, status: .usageStatusText}' <<<"$record") == '{"stale":true,"at":true,"percent":0.42,"status":""}' ]] ||
  fail "a failed Grok check keeps the last credits, stale" "$record"
pass "a failed Grok check keeps the last credits, stale"
cache=$(ls "$XDG_CACHE_HOME"/omarchy/agent-usage/grok-limits-*.json | head -1)
jq --arg at "$reset_past" '.limits[0].resetsAt = $at' "$cache" >"$test_tmp/cache.json"
mv "$test_tmp/cache.json" "$cache"
record=$(GROK_FAIL=500 collect)
[[ $(jq -c '{stale: .limitsStale, window: (.limits[0] | {percent, resetsAt})}' <<<"$record") == '{"stale":true,"window":{"percent":0.0,"resetsAt":""}}' ]] ||
  fail "a failed Grok check zeroes a kept window that has reset since" "$record"
pass "a failed Grok check zeroes a kept window that has reset since"

# Only an endpoint that couldn't be reached at all asks the panel to retry
# soon; one that answered with an error would only answer the same again.
record=$(GROK_FAIL=unreachable collect)
[[ $(jq -c '{retryAdvised, stale: .limitsStale, kept: (.limits | length), status: .usageStatusText}' <<<"$record") == '{"retryAdvised":true,"stale":true,"kept":1,"status":""}' ]] ||
  fail "an unreachable Grok endpoint advises a retry and keeps the last credits" "$record"
record=$(GROK_FAIL=500 collect)
[[ $(jq -r '.retryAdvised // false' <<<"$record") == false ]] ||
  fail "a Grok endpoint that answered with an error advises no retry" "$record"
pass "only an unreachable Grok endpoint advises a retry"

# A token turned away before it lapsed is a sign-in to redo.
record=$(GROK_FAIL=401 collect)
[[ $(jq -c '{status: .usageStatusText, stale: .limitsStale, retry: (.retryAdvised // false)}' <<<"$record") == '{"status":"Sign-in expired","stale":true,"retry":false}' ]] ||
  fail "a refused Grok sign-in says it expired" "$record"
pass "a refused Grok sign-in says it expired"

# A percentage that isn't a number is no answer, not a full allowance.
rm -f "$XDG_CACHE_HOME"/omarchy/agent-usage/grok-limits-*.json
record=$(GROK_PERCENT=NaN collect)
[[ $(jq -c '{status: .usageStatusText, limits}' <<<"$record") == '{"status":"Grok limits unavailable","limits":[]}' ]] ||
  fail "a Grok percentage that isn't a number reads as unavailable" "$record"
pass "a Grok percentage that isn't a number reads as unavailable"

# A period with nothing used yet comes without a percentage.
signed_in "$HOME/.grok" token-fresh u-main "$future" "X Premium+"
rm -f "$XDG_CACHE_HOME"/omarchy/agent-usage/grok-limits-*.json
record=$(collect)
[[ $(jq -c '.limits[0] | {label, percent}' <<<"$record") == '{"label":"Weekly","percent":0.0}' ]] ||
  fail "an untouched period reads as 0% rather than nothing known" "$record"
pass "an untouched period reads as 0% rather than nothing known"

signed_in "$HOME/.grok" token-main u-main "$future" "X Premium+"
side="$XDG_STATE_HOME/omarchy/agents/accounts/grok/side"
signed_in "$side" token-side u-side "$future" "SuperGrok"
jq -n --arg side "$side" '{active: "side", switch: "auto", threshold: 90, accounts: [
  {id: "main", label: "Main", home: "", primary: true},
  {id: "side", label: "Side", home: $side, primary: false}
]}' >"$XDG_STATE_HOME/omarchy/agents/accounts/grok.json"
record=$(collect)
[[ $(jq -c '{tierLabel, first: .limits[0].percent, accounts: [.accounts[] | {id, active, plan, percent: .limits[0].percent}], switch: .accountSwitch}' <<<"$record") == '{"tierLabel":"SuperGrok","first":0.07,"accounts":[{"id":"main","active":false,"plan":"X Premium+","percent":0.42},{"id":"side","active":true,"plan":"SuperGrok","percent":0.07}],"switch":{"mode":"auto","threshold":90}}' ]] ||
  fail "every Grok account reports its own plan and credits" "$record"
pass "every Grok account reports its own plan and credits"

# Sessions come from each session's summary; tokens and today's prompts from
# its usage.json, one entry per finished turn, with cached input kept apart.
sessions="$HOME/.grok/sessions/%2Fhome%2Fme"
now=$(python3 -c 'import datetime as dt; print(dt.datetime.now(dt.timezone.utc).isoformat())')
mkdir -p "$sessions/today-1" "$sessions/today-2" "$sessions/old"
jq -n --arg at "$now" '{last_active_at: $at, num_messages: 3}' >"$sessions/today-1/summary.json"
jq -n --arg at "$now" '{last_active_at: $at, num_messages: 2}' >"$sessions/today-2/summary.json"
jq -n '{last_active_at: "2026-01-02T10:00:00Z", num_messages: 5}' >"$sessions/old/summary.json"
jq -n --arg at "$now" '{turns: [
  {endedAt: $at, modelUsage: {"grok-4.7-build": {inputTokens: 1000, cachedReadTokens: 800, outputTokens: 50, cacheCreationTokens: 0, totalTokens: 1050}}},
  {endedAt: $at, modelUsage: {"grok-4.7-build": {inputTokens: 200, cachedReadTokens: 100, outputTokens: 10, cacheCreationTokens: 5, totalTokens: 210}}}
]}' >"$sessions/today-1/usage.json"
jq -n '{turns: [{endedAt: "2026-01-02T10:00:00Z", modelUsage: {"grok-4.6": {inputTokens: 500, cachedReadTokens: 0, outputTokens: 20, cacheCreationTokens: 0, totalTokens: 520}}}]}' >"$sessions/old/usage.json"
record=$(collect)
[[ $(jq -c '{hasLocalStats, todayPrompts, todaySessions, totalPrompts, totalSessions, activeDays, todayTotalTokens, todayTokensByModel, today: .recentDays[6].messageCount}' <<<"$record") == '{"hasLocalStats":true,"todayPrompts":2,"todaySessions":2,"totalPrompts":10,"totalSessions":3,"activeDays":2,"todayTotalTokens":1265,"todayTokensByModel":{"grok-4.7-build":1265},"today":1265}' ]] ||
  fail "Grok counts sessions, prompts, and tokens from its session files" "$record"
[[ $(jq -cS '.modelUsage' <<<"$record") == '{"grok-4.6":{"cacheCreationInputTokens":0,"cacheReadInputTokens":0,"inputTokens":500,"outputTokens":20},"grok-4.7-build":{"cacheCreationInputTokens":5,"cacheReadInputTokens":900,"inputTokens":300,"outputTokens":60}}' ]] ||
  fail "Grok's tokens by model keep cached input apart" "$record"
pass "Grok counts sessions, prompts, and tokens from its session files"

# A limits-only refresh reuses the last scan rather than reading every summary.
mkdir -p "$sessions/later"
jq -n --arg at "$now" '{last_active_at: $at, num_messages: 1}' >"$sessions/later/summary.json"
record=$(COLLECT_ARGS="--limits-only" collect)
[[ $(jq -r '.totalSessions' <<<"$record") == 3 ]] || fail "a limits-only refresh reuses the session scan" "$record"
pass "a limits-only refresh reuses the session scan"

# A scan from another day is never reused, so yesterday's sessions don't
# count as today's after midnight. Each home has its own scan; ~/.grok's was
# the last one made.
stats_cache=$(ls -t "$XDG_CACHE_HOME"/omarchy/agent-usage/grok-scan-*.json | head -1)
jq '.scanDate = "2000-01-01"' "$stats_cache" >"$test_tmp/stats.json"
mv "$test_tmp/stats.json" "$stats_cache"
record=$(COLLECT_ARGS="--limits-only" collect)
[[ $(jq -r '.totalSessions' <<<"$record") == 4 ]] || fail "a scan from another day is made again" "$record"
pass "a scan from another day is made again"

# A scan whose time is in the future came from a clock that has since gone
# back, so it can't say how old it is and is made again.
mkdir -p "$sessions/future"
jq -n --arg at "$now" '{last_active_at: $at, num_messages: 1}' >"$sessions/future/summary.json"
jq '.scannedAtMs = 99999999999999' "$stats_cache" >"$test_tmp/stats.json"
mv "$test_tmp/stats.json" "$stats_cache"
record=$(COLLECT_ARGS="--limits-only" collect)
[[ $(jq -r '.totalSessions' <<<"$record") == 5 ]] || fail "a future-dated Grok scan is made again" "$record"
pass "a future-dated Grok scan is made again"

# A normal run reuses a scan for a few seconds, so overlapping runs read once;
# --force reads again.
mkdir -p "$sessions/soon"
jq -n --arg at "$now" '{last_active_at: $at, num_messages: 1}' >"$sessions/soon/summary.json"
record=$(COLLECT_ARGS=" " collect)
[[ $(jq -r '.totalSessions' <<<"$record") == 5 ]] || fail "a normal Grok run reuses a scan this recent" "$record"
record=$(collect)
[[ $(jq -r '.totalSessions' <<<"$record") == 6 ]] || fail "--force scans Grok's sessions again" "$record"
pass "a normal Grok run reuses a recent scan, and --force scans again"

# A probe this recent is reused rather than asking xAI again, until a person
# presses refresh.
rm -f "$XDG_STATE_HOME/omarchy/agents/accounts/grok.json" "$test_tmp/probes"
collect >/dev/null
record=$(GROK_PROBES="$test_tmp/probes" COLLECT_ARGS="--limits-only" collect)
[[ ! -e $test_tmp/probes && $(jq -c '{stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"stale":false,"percent":0.42}' ]] ||
  fail "a Grok probe this recent is reused" "$record"
GROK_PROBES="$test_tmp/probes" collect >/dev/null
[[ $(wc -l <"$test_tmp/probes") == 1 ]] || fail "--force probes Grok past the reuse window" "$(cat "$test_tmp/probes")"
pass "a recent Grok probe is reused, and --force probes again"

