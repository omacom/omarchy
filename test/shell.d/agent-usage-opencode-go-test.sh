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

# With a prepared limits cache, a missing cookie must keep the last meters on
# the panel — a status card instead of a vanished provider — until the cached
# windows reset.
cache_dir="$TEST_HOME/.cache/omarchy/agent-usage"
mkdir -p "$cache_dir"
cache_resets=$(date -u -d 'now + 3 hours' +%Y-%m-%dT%H:%M:%SZ)
printf '{"fetchedAtMs":%s000,"limits":[{"label":"Rolling (5-hour)","percent":0.22,"resetsAt":"%s"}]}\n' \
  "$(date +%s)" "$cache_resets" > "$cache_dir/opencode-go-limits.json"
cached_no_cookie=$(HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  XDG_STATE_HOME="$TEST_HOME/.local/state" XDG_DATA_HOME="$TEST_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-opencode-go")
[[ $(jq -r '(.ready | tostring) + ":" + .usageStatusText + ":" + (.limits[0].label | tostring) + ":" + (.limits | length | tostring)' <<<"$cached_no_cookie") == "true:Waiting for sign-in:Rolling (5-hour):1" ]] ||
  fail "OpenCode Go collector keeps cached limits and a status card without a cookie" "$cached_no_cookie"
pass "OpenCode Go collector keeps cached limits and a status card without a cookie"

result=$(python3 - "$ROOT/bin/omarchy-agent-usage-opencode-go" <<'PY'
import contextlib
import datetime as dt
import importlib.machinery
import importlib.util
import io
import json
import os
import sqlite3
import sys
import tempfile
import urllib.error

loader = importlib.machinery.SourceFileLoader("collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
module = importlib.util.module_from_spec(spec)
loader.exec_module(module)

today = dt.date.today()
yesterday = today - dt.timedelta(days=1)

# The fixture stamps each record at LOCAL noon: a UTC-noon stamp is tomorrow
# local east of UTC+12, which would file today's requests under tomorrow's
# date and empty today's stats there.
def local_noon_utc(day):
    return dt.datetime.combine(
        day, dt.time(12, 0), tzinfo=dt.datetime.now().astimezone().tzinfo
    ).astimezone(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.000Z")

go_page = (
    '<html><body><script>'
    'rollingUsage:$R[1]={status:"ok",resetInSec:8073,usagePercent:1.0,usage:12000000,limit:1200000000},'
    'weeklyUsage:$R[2]={status:"ok",resetInSec:101069,usagePercent:60,usage:1800000000,limit:3000000000},'
    'monthlyUsage:$R[3]={status:"ok",resetInSec:2347422,usagePercent:30,usage:1800000000,limit:6000000000},'
    'liteSubscriptionID:"sub_test"'
    '</script></body></html>'
)

def rec(rid, date, model, inp, out, reasoning, cread, w5m, w1h):
    stamp = local_noon_utc(date)
    return (
        '{id:"%s",workspaceID:"wrk_XXXXXXXXXXXXXXXXXXXXXXXXXX",'
        'timeCreated:$R[10]=new Date("%s"),'
        'timeUpdated:$R[11]=new Date("%s"),timeDeleted:null,'
        'model:"%s",provider:"inf-go.oa-compat",'
        'inputTokens:%d,outputTokens:%d,reasoningTokens:%s,cacheReadTokens:%d,'
        'cacheWrite5mTokens:%s,cacheWrite1hTokens:%s,cost:12345,'
        'keyID:"k",sessionID:"",enrichment:$R[12]={plan:"lite"}}' % (
            rid, stamp, stamp, model, inp, out, reasoning, cread, w5m, w1h)
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

# --- extract_all_cookies fixture -------------------------------------------
fixture_dir = tempfile.mkdtemp()
cookie_db = os.path.join(fixture_dir, "cookies.sqlite")
conn = sqlite3.connect(cookie_db)
conn.execute(
    "CREATE TABLE moz_cookies (host TEXT, name TEXT, value TEXT, expiry INTEGER, "
    "lastAccessed INTEGER, creationTime INTEGER)"
)
conn.execute(
    "INSERT INTO moz_cookies VALUES ('.opencode.ai', 'auth', 'auth-token-xyz', "
    "9999999999, 5000, 1000)"
)
conn.commit()
conn.close()
assert module.extract_all_cookies(cookie_db) == [("auth", "auth-token-xyz", 5000)], "auth cookie value round-trips"

empty_db = os.path.join(fixture_dir, "empty.sqlite")
conn = sqlite3.connect(empty_db)
conn.execute(
    "CREATE TABLE moz_cookies (host TEXT, name TEXT, value TEXT, expiry INTEGER, "
    "lastAccessed INTEGER, creationTime INTEGER)"
)
conn.commit()
conn.close()
assert module.extract_all_cookies(empty_db) == [], "empty cookies db yields an empty list"

multi_db = os.path.join(fixture_dir, "multi.sqlite")
conn = sqlite3.connect(multi_db)
conn.execute(
    "CREATE TABLE moz_cookies (host TEXT, name TEXT, value TEXT, expiry INTEGER, "
    "lastAccessed INTEGER, creationTime INTEGER)"
)
# Two auth cookies with different lastAccessed — the more recent one wins.
conn.execute(
    "INSERT INTO moz_cookies VALUES ('opencode.ai', 'auth', 'stale-token', "
    "9999999999, 1000, 1000)"
)
conn.execute(
    "INSERT INTO moz_cookies VALUES ('opencode.ai', 'auth', 'fresh-token', "
    "1818027938219, 9000, 2000)"
)
conn.execute(
    "INSERT INTO moz_cookies VALUES ('opencode.ai', 'oc_locale', 'en', "
    "1818028166359, 8000, 3000)"
)
conn.commit()
conn.close()
result = module.extract_all_cookies(multi_db)
assert result == [
    ("auth", "fresh-token", 9000),
    ("oc_locale", "en", 8000),
    ("auth", "stale-token", 1000),
], "multi-cookie db returns all cookies sorted by lastAccessed"

header = module.build_cookie_header(result)
assert header == "auth=fresh-token; oc_locale=en", "build_cookie_header de-duplicates by name keeping freshest"

# --- resolve_workspace precedence, never touching the network -------------

# --- resolve_workspace precedence, never touching the network -------------
os.environ["OPENCODE_WORKSPACE"] = "wrk_eeeeeeeeeeeeeeeeeeeeeeeeee"
assert module.resolve_workspace({"workspaceId": "wrk_cccccccccccccccccccccccccc"}, "") == (
    "wrk_cccccccccccccccccccccccccc", ""), "config workspaceId wins over env"
assert module.resolve_workspace({}, "") == (
    "wrk_eeeeeeeeeeeeeeeeeeeeeeeeee", ""), "env is used when the config has no workspaceId"
del os.environ["OPENCODE_WORKSPACE"]

def no_network(cookie):
    raise urllib.error.URLError("name resolution failed")
module.list_workspaces = no_network
assert module.resolve_workspace({}, "cookie") == ("", "transport"), "RPC failure maps to transport"

module.list_workspaces = lambda cookie: []
assert module.resolve_workspace({}, "cookie") == ("", "unknown"), "zero workspaces maps to unknown"

module.list_workspaces = lambda cookie: ["wrk_aaaaaaaaaaaaaaaaaaaaaaaaaa", "wrk_bbbbbbbbbbbbbbbbbbbbbbbbbb"]
assert module.resolve_workspace({}, "cookie") == ("", "unknown"), "several workspaces maps to unknown"

# --- main() failure branch: cached limits keep the tab alive --------------
cfg_root = os.path.join(fixture_dir, "config")
os.makedirs(os.path.join(cfg_root, "omarchy", "agents"), exist_ok=True)
cookie_file = os.path.join(fixture_dir, "cookie.txt")
with open(cookie_file, "w", encoding="utf-8") as handle:
    handle.write("auth-token-xyz\n")
with open(os.path.join(cfg_root, "omarchy", "agents", "opencode-go.json"), "w", encoding="utf-8") as handle:
    json.dump({"cookieFile": cookie_file, "workspaceId": "wrk_cccccccccccccccccccccccccc"}, handle)

cache_root_dir = os.path.join(fixture_dir, "cache")
os.makedirs(os.path.join(cache_root_dir, "omarchy", "agent-usage"), exist_ok=True)
future_resets = (dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=3)).isoformat().replace("+00:00", "Z")
cache_payload = {
    "fetchedAtMs": round(dt.datetime.now(dt.timezone.utc).timestamp() * 1000),
    "limits": [
        {"label": "Rolling (5-hour)", "percent": 0.15, "resetsAt": future_resets},
        {"label": "Weekly", "percent": 0.4, "resetsAt": future_resets},
        {"label": "Monthly", "percent": 0.7, "resetsAt": future_resets},
    ],
}
with open(os.path.join(cache_root_dir, "omarchy", "agent-usage", "opencode-go-limits.json"), "w", encoding="utf-8") as handle:
    json.dump(cache_payload, handle)

os.environ["XDG_CONFIG_HOME"] = cfg_root
os.environ["XDG_CACHE_HOME"] = cache_root_dir

def fetch_boom(cookie, path):
    raise urllib.error.URLError("no route to host")
module.fetch_page = fetch_boom

# The harness invoked python with the collector path as an argument; main()
# must see a clean argv like a real launch.
sys.argv = ["omarchy-agent-usage-opencode-go"]

captured = io.StringIO()
with contextlib.redirect_stdout(captured):
    exit_code = module.main()
assert exit_code == 0, "main returns 0 on a transport failure"
failure_record = json.loads(captured.getvalue())
assert failure_record["limits"] == cache_payload["limits"], "cached limits survive a refresh failure"
assert failure_record["retryAdvised"] is True, "transport failure advises an earlier retry"
assert failure_record["usageStatusText"] == "Couldn't reach opencode.ai", "status card explains the failure"

# --- format change detection: no meters and no auth redirect ----------------
def fetch_unknown_format(cookie, path):
    return "<html><body><h1>Go Plan Dashboard</h1><p>Loading...</p></body></html>"
module.fetch_page = fetch_unknown_format

captured = io.StringIO()
with contextlib.redirect_stdout(captured):
    exit_code = module.main()
assert exit_code == 0, "main returns 0 when the page format changes"
format_record = json.loads(captured.getvalue())
assert format_record["usageStatusText"] == "Page format changed", "unrecognised HTML is reported as a format change, not auth failure"
assert format_record["retryAdvised"] is True, "format change advises retry in case it was transient"

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

[[ $(jq -r '.limitsOnly | has("todayTotalTokens")' <<<"$result") == "true" && \
   $(jq -r '.limitsOnly.todayTotalTokens' <<<"$result") == "0" && \
   $(jq -r '.limitsOnly.limits | length' <<<"$result") == "3" ]] ||
  fail "OpenCode Go collector keeps limits and zero-shaped stats when usage records are missing" "$result"
pass "OpenCode Go collector keeps limits and zero-shaped stats when usage records are missing"

[[ $(jq -r '.record.scope' <<<"$result") == "account" ]] ||
  fail "OpenCode Go collector marks account-scoped records" "$result"
pass "OpenCode Go collector marks account-scoped records"
