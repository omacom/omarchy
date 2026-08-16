#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# Without a session cookie the collector must still print a full, hidden-by-default
# record: the update runner writes whatever valid JSON appears on stdout.
no_cookie=$(HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" XDG_STATE_HOME="$TEST_HOME/.local/state" \
  XDG_DATA_HOME="$TEST_HOME/.local/share" "$ROOT/bin/omarchy-agent-usage-opencode-go")

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.hasPromptStats | tostring)' <<<"$no_cookie") == "opencode-go:false:false" ]] ||
  fail "OpenCode Go collector prints a valid record without a cookie" "$no_cookie"
pass "OpenCode Go collector prints a valid record without a cookie"

[[ $(jq -r '.authHelpText' <<<"$no_cookie") != "" ]] ||
  fail "OpenCode Go collector explains the missing cookie" "$no_cookie"
pass "OpenCode Go collector explains the missing cookie"

# The update runner passes --force and --limits-only to every collector; both
# must still print a valid record.
force_out=$(HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" XDG_STATE_HOME="$TEST_HOME/.local/state" \
  XDG_DATA_HOME="$TEST_HOME/.local/share" "$ROOT/bin/omarchy-agent-usage-opencode-go" --force)
[[ $(jq -r '.id' <<<"$force_out") == "opencode-go" ]] ||
  fail "OpenCode Go collector accepts --force" "$force_out"
pass "OpenCode Go collector accepts --force"

limits_out=$(HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" XDG_STATE_HOME="$TEST_HOME/.local/state" \
  XDG_DATA_HOME="$TEST_HOME/.local/share" "$ROOT/bin/omarchy-agent-usage-opencode-go" --limits-only)
[[ $(jq -r '.id' <<<"$limits_out") == "opencode-go" ]] ||
  fail "OpenCode Go collector accepts --limits-only" "$limits_out"
pass "OpenCode Go collector accepts --limits-only"

result=$(python3 - "$ROOT/bin/omarchy-agent-usage-opencode-go" <<'PY'
import importlib.machinery
import importlib.util
import json
import sys
import datetime as dt

loader = importlib.machinery.SourceFileLoader("collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
module = importlib.util.module_from_spec(spec)
loader.exec_module(module)

today = dt.date.today()
yesterday = today - dt.timedelta(days=1)

go_page = (
    '<html><body><script>'
    'rollingUsage:$R[1]={status:"ok",resetInSec:8073,usagePercent:1.0},'
    'weeklyUsage:$R[2]={status:"ok",resetInSec:101069,usagePercent:60},'
    'monthlyUsage:$R[3]={status:"ok",resetInSec:2347422,usagePercent:30},'
    'liteSubscriptionID:"sub_test"'
    '</script></body></html>'
)

def rec(rid, date, model, inp, out, reasoning, cread, w5m, w1h):
    return (
        '{id:"%s",workspaceID:"wrk_XXXXXXXXXXXXXXXXXXXXXXXXXX",'
        'timeCreated:$R[10]=new Date("%sT12:00:00.000Z"),'
        'timeUpdated:$R[11]=new Date("%sT12:00:01.000Z"),timeDeleted:null,'
        'model:"%s",provider:"inf-go.oa-compat",'
        'inputTokens:%d,outputTokens:%d,reasoningTokens:%s,cacheReadTokens:%d,'
        'cacheWrite5mTokens:%s,cacheWrite1hTokens:%s,cost:12345,'
        'keyID:"k",sessionID:"",enrichment:$R[12]={plan:"lite"}}' % (
            rid, date, date, model, inp, out, reasoning, cread, w5m, w1h)
    )

usage_page = (
    '<script>'
    + rec("usg_01AAA", today, "deepseek-v4-flash", 100, 200, 50, 300, "null", "null")
    + ',' + rec("usg_01BBB", today, "deepseek-v4-flash", 10, 20, 5, 30, "400", "50")
    + ',' + rec("usg_01CCC", yesterday, "qwen3-coder", 1000, 0, 0, 0, "null", "null")
    # reasoningTokens comes back null for models that report no reasoning
    # tokens; the record must still parse.
    + ',' + rec("usg_01DDD", today, "deepseek-v4-flash", 1000, 500, "null", 0, "null", "null")
    + '</script>'
)

meters, plan = module.parse_meters(go_page)
limits = module.build_limits(meters)
records = module.parse_usage_records(usage_page)
stats = module.build_stats(records)
full_record = module.build_record(meters, plan, records)
limits_only = module.build_record(meters, plan, [])

print(json.dumps({
    "plan": plan,
    "limits": limits,
    "records": records,
    "stats": stats,
    "record": full_record,
    "limitsOnly": limits_only,
}))
PY
)

[[ $(jq -r '.plan' <<<"$result") == "Go" ]] ||
  fail "OpenCode Go collector reads the Go plan marker" "$result"
pass "OpenCode Go collector reads the Go plan marker"

[[ $(jq -r '.limits[0].label' <<<"$result") == "Rolling (5-hour)" ]] ||
  fail "OpenCode Go collector labels the rolling window" "$result"
pass "OpenCode Go collector labels the rolling window"

[[ $(jq -c '[.limits[].percent]' <<<"$result") == '[0.01,0.6,0.3]' ]] ||
  fail "OpenCode Go collector reports percent-scale meters as fractions" "$result"
pass "OpenCode Go collector reports percent-scale meters as fractions"

[[ $(jq -r '.limits[0].resetsAt' <<<"$result") > "$(date -u -d 'now + 2 hours' +%Y-%m-%dT%H:%M)" ]] ||
  fail "OpenCode Go collector stamps a future resetsAt" "$result"
pass "OpenCode Go collector stamps a future resetsAt"

[[ $(jq -r '.records | length' <<<"$result") == "4" ]] ||
  fail "OpenCode Go collector parses every usage record" "$result"
pass "OpenCode Go collector parses every usage record"

[[ $(jq -r '.records[3].reasoning' <<<"$result") == "0" ]] ||
  fail "OpenCode Go collector treats a null reasoning token count as zero" "$result"
pass "OpenCode Go collector treats a null reasoning token count as zero"

[[ $(jq -r '.stats.todayPrompts' <<<"$result") == "3" ]] ||
  fail "OpenCode Go collector counts today's requests" "$result"
pass "OpenCode Go collector counts today's requests"

[[ $(jq -r '.stats.todayTotalTokens' <<<"$result") == "2665" ]] ||
  fail "OpenCode Go collector totals today's tokens" "$result"
pass "OpenCode Go collector totals today's tokens"

[[ $(jq -c '.stats.modelUsage["deepseek-v4-flash"]' <<<"$result") == '{"inputTokens":1110,"outputTokens":775,"cacheReadInputTokens":330,"cacheCreationInputTokens":450}' ]] ||
  fail "OpenCode Go collector rolls reasoning into output and sums cache writes" "$result"
pass "OpenCode Go collector rolls reasoning into output and sums cache writes"

[[ $(jq -r '.stats.recentDays[-1].messageCount' <<<"$result") == "2665" ]] ||
  fail "OpenCode Go collector builds the seven-day token series" "$result"
pass "OpenCode Go collector builds the seven-day token series"

[[ $(jq -r '.stats.activeDays' <<<"$result") == "2" ]] ||
  fail "OpenCode Go collector counts active days from the record window" "$result"
pass "OpenCode Go collector counts active days from the record window"

[[ $(jq -c '.record | {schemaVersion, id, ready, hasLocalStats, hasPromptStats, tierLabel, usageStatusText}' <<<"$result") == '{"schemaVersion":1,"id":"opencode-go","ready":true,"hasLocalStats":true,"hasPromptStats":false,"tierLabel":"Go","usageStatusText":""}' ]] ||
  fail "OpenCode Go collector prints the display-ready record contract" "$result"
pass "OpenCode Go collector prints the display-ready record contract"

[[ $(jq -r '.limitsOnly | has("todayTotalTokens")' <<<"$result") == "false" && $(jq -r '.limitsOnly.limits | length' <<<"$result") == "3" ]] ||
  fail "OpenCode Go collector keeps limits when usage records are missing" "$result"
pass "OpenCode Go collector keeps limits when usage records are missing"
