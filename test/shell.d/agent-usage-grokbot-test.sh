#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_CACHE_HOME="$test_tmp/cache"
unset CURSOR_API_KEY

reset_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(days=3)).strftime("%Y-%m-%dT%H:%M:%S.%fZ"))')

# A JWT whose subject names the account, as Cursor's sign-in tokens do, with
# an expiry an hour out unless one is given.
jwt() {
  local exp=${2:-$(( $(date +%s) + 3600 ))}
  printf 'h.%s.s' "$(printf '{"sub":"%s","exp":%s}' "$1" "$exp" | base64 -w0 | tr '+/' '-_' | tr -d '=')"
}

cli_signed_in() {
  mkdir -p "$XDG_CONFIG_HOME/cursor"
  jq -n --arg token "$(jwt "$@")" '{accessToken: $token}' >"$XDG_CONFIG_HOME/cursor/auth.json"
}

# ANSWER is the dashboard's JSON reply, an HTTP status code to fail with,
# cut/reset for a connection that breaks mid-reply, unreachable for one that
# never connects, or unasked to fail the test if anything is sent. With EXPECT
# set, any other token is refused, as Cursor would refuse it. Every run is
# --force unless ARGS says otherwise, so each one really asks.
collect() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-grokbot" python3 - <<'PY'
import http.client, importlib.machinery, importlib.util, io, os, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

def urlopen(request, timeout=None):
  assert request.full_url == collector.USAGE_URL
  answer = os.environ["ANSWER"]
  if answer == "unasked":
    raise AssertionError("the dashboard should not have been asked")
  expected = os.environ.get("EXPECT")
  if expected and request.get_header("Authorization") != f"Bearer {expected}":
    answer = "401"
  if answer == "cut":
    raise http.client.IncompleteRead(b"{")
  if answer == "reset":
    raise ConnectionResetError()
  if answer == "unreachable":
    raise collector.urllib.error.URLError("no route to host")
  if answer.isdigit():
    raise collector.urllib.error.HTTPError(request.full_url, int(answer), "", {}, None)
  return io.BytesIO(answer.encode())

collector.urllib.request.urlopen = urlopen
sys.argv = ["omarchy-agent-usage-grokbot", *os.environ.get("ARGS", "--limits-only --force").split()]
collector.main()
PY
}

record=$(ANSWER='{}' collect)
# The last seven local days ending today, none with messages: an unused
# record still carries the full week, zeroed.
empty_week=$(for offset in 6 5 4 3 2 1 0; do date -d "$(date +%F) 12:00 $offset days ago" +%F; done | jq -Rsc 'split("\n")[:-1] | map({date: ., messageCount: 0})')
[[ $(jq -c '{id, ready, limits, usageStatusText, authHelpText, hasLocalStats, hasPromptStats, todayPrompts, todayTotalTokens, recentDays, modelUsage, activeDates}' <<<"$record") == '{"id":"grokbot","ready":false,"limits":[],"usageStatusText":"","authHelpText":"","hasLocalStats":false,"hasPromptStats":false,"todayPrompts":0,"todayTotalTokens":0,"recentDays":'"$empty_week"',"modelUsage":{},"activeDates":[]}' ]] ||
  fail "a machine signed in to Cursor nowhere gives an unused record" "$record"
pass "a machine signed in to Cursor nowhere gives an unused record"

cli_signed_in u-main
answer=$(jq -nc --arg at "$reset_at" '{usagePercent: 42.5, nextResetTimestampUtc: $at, hasNonZeroIncludedLimit: true, grokPlanLabel: "Pro"}')
record=$(ANSWER="$answer" collect)
[[ $(jq -c '{ready, tierLabel, stale: .limitsStale, label: .limits[0].label, percent: .limits[0].percent, help: .authHelpText, status: .usageStatusText, retry: (.retryAdvised // false)}' <<<"$record") == '{"ready":true,"tierLabel":"Pro","stale":false,"label":"Weekly","percent":0.425,"help":"","status":"","retry":false}' ]] ||
  fail "Grok Bot's weekly allowance comes from the Cursor sign-in" "$record"
python3 -c 'import datetime as dt, sys; d = dt.datetime.fromisoformat(sys.argv[1]) - dt.datetime.now(dt.timezone.utc); sys.exit(0 if dt.timedelta(days=2) < d < dt.timedelta(days=3) else 1)' "$(jq -r '.limits[0].resetsAt' <<<"$record")" ||
  fail "the weekly window says when it resets" "$record"
pass "Grok Bot's weekly allowance comes from the Cursor sign-in"

# An answer this recent is reused rather than asked again, unless forced.
record=$(ARGS="" ANSWER=unasked collect)
[[ $(jq -c '{ready, tierLabel, stale: .limitsStale, percent: .limits[0].percent, help: .authHelpText}' <<<"$record") == '{"ready":true,"tierLabel":"Pro","stale":false,"percent":0.425,"help":""}' ]] ||
  fail "a recent answer is reused" "$record"
record=$(ARGS="--limits-only" ANSWER=unasked collect)
[[ $(jq -r '.limits[0].percent' <<<"$record") == "0.425" ]] ||
  fail "a near-limit refresh reuses a recent answer too" "$record"
answer_later=$(jq -nc --arg at "$reset_at" '{usagePercent: 50, nextResetTimestampUtc: $at, hasNonZeroIncludedLimit: true, grokPlanLabel: "Pro"}')
record=$(ARGS="--force" ANSWER="$answer_later" collect)
[[ $(jq -r '.limits[0].percent' <<<"$record") == "0.5" ]] ||
  fail "--force asks again" "$record"
record=$(ANSWER="$answer" collect)
pass "a recent answer is reused, and --force asks again"

# Failed checks keep the last good limit, stale, and say why when it's auth.
record=$(ANSWER=500 collect)
[[ $(jq -c '{ready, tierLabel, stale: .limitsStale, percent: .limits[0].percent, status: .usageStatusText, retry: (.retryAdvised // false), help: (.authHelpText | test("500"))}' <<<"$record") == '{"ready":true,"tierLabel":"Pro","stale":true,"percent":0.425,"status":"","retry":false,"help":true}' ]] ||
  fail "a failed check keeps the last limit, marked stale" "$record"
record=$(ANSWER=401 collect)
[[ $(jq -c '{stale: .limitsStale, percent: .limits[0].percent, status: .usageStatusText}' <<<"$record") == '{"stale":true,"percent":0.425,"status":"Sign-in expired"}' ]] ||
  fail "a refused sign-in keeps the last limit and says it expired" "$record"
for broken in cut reset; do
  record=$(ANSWER=$broken collect)
  [[ $(jq -c '{stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"stale":true,"percent":0.425}' ]] ||
    fail "a connection that breaks mid-reply ($broken) keeps the last limit" "$record"
done
pass "failed checks keep the last limit, marked stale"

# Only a dashboard that couldn't be reached at all asks for a sooner retry.
record=$(ANSWER=unreachable collect)
[[ $(jq -c '{retry: .retryAdvised, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"retry":true,"stale":true,"percent":0.425}' ]] ||
  fail "an unreachable dashboard advises a retry" "$record"
record=$(ANSWER=cut collect)
[[ $(jq -r '.retryAdvised // false' <<<"$record") == "false" ]] ||
  fail "a reply cut short is an answer, not a reason to retry" "$record"
pass "only an unreachable dashboard advises a retry"

# A kept week that has ended comes back at zero, never dropped.
cache_file=$(ls "$XDG_CACHE_HOME"/omarchy/agent-usage/grokbot-limits-*.json)
kept=$(<"$cache_file")
jq '.limits[0].resetsAt = "2020-01-01T00:00:00+00:00"' <<<"$kept" >"$cache_file"
record=$(ANSWER=500 collect)
[[ $(jq -c '{ready, stale: .limitsStale, limits: [.limits[] | {label, percent, resetsAt}]}' <<<"$record") == '{"ready":true,"stale":true,"limits":[{"label":"Weekly","percent":0.0,"resetsAt":""}]}' ]] ||
  fail "an elapsed kept week comes back at zero" "$record"
printf '%s' "$kept" >"$cache_file"
pass "an elapsed kept week comes back at zero"

# A cache that can't be written never costs the live answer.
chmod a-w "$XDG_CACHE_HOME/omarchy/agent-usage"
record=$(ANSWER="$answer" collect)
chmod u+w "$XDG_CACHE_HOME/omarchy/agent-usage"
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"ready":true,"stale":false,"percent":0.425}' ]] ||
  fail "an unwritable cache still gives the live limit" "$record"
pass "an unwritable cache still gives the live limit"

# A lapsed sign-in isn't sent: the CLI or editor renews it the next time it
# runs, so the last limit is kept with the limits paused.
cli_signed_in u-main "$(( $(date +%s) - 60 ))"
record=$(ANSWER=unasked collect)
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent, status: .usageStatusText}' <<<"$record") == '{"ready":true,"stale":true,"percent":0.425,"status":"Limits paused"}' ]] ||
  fail "a lapsed sign-in pauses the limit without asking" "$record"
pass "a lapsed sign-in pauses the limit without asking"

# Another account's limit never stands in for this one's.
cli_signed_in u-other
record=$(ANSWER=500 collect)
[[ $(jq -c '{ready, limits, tierLabel}' <<<"$record") == '{"ready":false,"limits":[],"tierLabel":""}' ]] ||
  fail "another account's cached limit is never shown" "$record"
pass "another account's cached limit is never shown"

# Protobuf JSON leaves out zero and false: an untouched week reads 0%, and an
# account with no included limit has no Grok Bot, so the panel skips it.
answer=$(jq -nc --arg at "$reset_at" '{nextResetTimestampUtc: $at, hasNonZeroIncludedLimit: true}')
record=$(ANSWER="$answer" collect)
[[ $(jq -c '.limits[0] | {label, percent}' <<<"$record") == '{"label":"Weekly","percent":0.0}' ]] ||
  fail "an untouched week reads as 0%" "$record"
record=$(ANSWER='{"usagePercent": 10}' collect)
[[ $(jq -c '{ready, limits}' <<<"$record") == '{"ready":false,"limits":[]}' ]] ||
  fail "a Cursor account without Grok Bot gives an unused record" "$record"
record=$(ANSWER='{"usagePercent": "NaN", "hasNonZeroIncludedLimit": true}' collect)
[[ $(jq -r '.limits[0].percent' <<<"$record") == "0.0" ]] ||
  fail "an unreadable percentage reads as 0%" "$record"
pass "an untouched week reads 0%, and no allowance means no Grok Bot"

# A limit with no known end is kept as it is through a failed check.
cli_signed_in u-no-reset
record=$(ANSWER='{"usagePercent": 5, "hasNonZeroIncludedLimit": true}' collect)
[[ $(jq -c '{ready, percent: .limits[0].percent, resetsAt: .limits[0].resetsAt}' <<<"$record") == '{"ready":true,"percent":0.05,"resetsAt":""}' ]] ||
  fail "a limit with no known reset still shows while live" "$record"
record=$(ANSWER=500 collect)
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent, resetsAt: .limits[0].resetsAt}' <<<"$record") == '{"ready":true,"stale":true,"percent":0.05,"resetsAt":""}' ]] ||
  fail "a limit with no known reset is kept through a failed check" "$record"
pass "a limit with no known reset is kept as it is through a failed check"

# The same account the Cursor collector reads: an exported key, then the CLI's
# sign-in, then the editor's, with all three present and each asked with its
# own token. A lapsed CLI sign-in gives way to a live editor one.
# Each token is made once: jwt stamps its expiry from the clock, so making it
# again a second later would give a token the dashboard refuses.
expiry=$(( $(date +%s) + 3600 ))
cli_token=$(jwt p-cli "$expiry")
editor_token=$(jwt p-editor "$expiry")
key_token=$(jwt p-key "$expiry")
cli_signed_in p-cli "$expiry"
state_db="$XDG_CONFIG_HOME/Cursor/User/globalStorage/state.vscdb"
mkdir -p "$(dirname "$state_db")"
python3 - "$state_db" "$editor_token" <<'PY'
import sqlite3, sys
conn = sqlite3.connect(sys.argv[1])
conn.execute("CREATE TABLE ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB)")
conn.execute("INSERT INTO ItemTable VALUES ('cursorAuth/accessToken', ?)", (sys.argv[2],))
conn.commit()
PY
answer=$(jq -nc --arg at "$reset_at" '{usagePercent: 7, nextResetTimestampUtc: $at, hasNonZeroIncludedLimit: true}')
live='{"ready":true,"stale":false,"percent":0.07}'
record=$(CURSOR_API_KEY="$key_token" EXPECT="$key_token" ANSWER="$answer" collect)
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == "$live" ]] ||
  fail "an exported CURSOR_API_KEY wins over both sign-ins" "$record"
record=$(EXPECT="$cli_token" ANSWER="$answer" collect)
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == "$live" ]] ||
  fail "the Cursor CLI's sign-in wins over the editor's" "$record"
cli_signed_in p-cli "$(( $(date +%s) - 60 ))"
record=$(EXPECT="$editor_token" ANSWER="$answer" collect)
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == "$live" ]] ||
  fail "a live editor sign-in stands in for a lapsed CLI one" "$record"
rm -f "$XDG_CONFIG_HOME/cursor/auth.json"
record=$(EXPECT="$editor_token" ANSWER="$answer" collect)
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == "$live" ]] ||
  fail "the Cursor editor's sign-in stands in for the CLI's" "$record"
moved_token=$(jwt p-moved "$expiry")
jq -n --arg token "$moved_token" '{accessToken: $token}' >"$test_tmp/moved-auth.json"
record=$(CURSOR_AUTH_PATH="$test_tmp/moved-auth.json" EXPECT="$moved_token" ANSWER="$answer" collect)
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == "$live" ]] ||
  fail "CURSOR_AUTH_PATH moves the CLI's sign-in, as it does for the Cursor collector" "$record"
pass "the sign-in is the one the Cursor collector reads, in the same order"

# Both collectors pick the same sign-in from the same files.
same=$(COLLECTORS="$ROOT/bin" python3 - <<'PY'
import importlib.machinery, importlib.util, os
from pathlib import Path

def load(name):
  loader = importlib.machinery.SourceFileLoader(name.replace("-", "_"), os.path.join(os.environ["COLLECTORS"], name))
  spec = importlib.util.spec_from_loader(loader.name, loader)
  module = importlib.util.module_from_spec(spec)
  loader.exec_module(module)
  return module

cursor = load("omarchy-agent-usage-cursor")
grokbot = load("omarchy-agent-usage-grokbot")
print(cursor.cursor_token(cursor.cursor_auth_path()) == grokbot.cursor_token() != "")
PY
)
[[ $same == "True" ]] || fail "Grok Bot and Cursor read the same sign-in" "$same"
pass "Grok Bot and Cursor read the same sign-in"
