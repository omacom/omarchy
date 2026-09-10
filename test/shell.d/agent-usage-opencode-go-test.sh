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

# --- rate-limited meters and the Zen-balance fallback ------------------
#
# A meter the console flipped to 'rate-limited' is the binding constraint:
# requests for that window block (or bill the Zen balance when 'Use balance'
# is on). The collector must report it with its percentage and reset time,
# and the record must say which of the two behaviours applies.

rl_go_page = (
    '<html><body><script>'
    'rollingUsage:$R[1]={status:"ok",resetInSec:8073,usagePercent:1.0,usage:12000000,limit:1200000000},'
    'weeklyUsage:$R[2]={status:"ok",resetInSec:101069,usagePercent:60,usage:1800000000,limit:3000000000},'
    'monthlyUsage:$R[3]={status:"rate-limited",resetInSec:133420,usagePercent:100.1,usage:6007226480,limit:6000000000},'
    'balance:996544169,reload:null,'
    'liteSubscriptionID:"sub_test",'
    'lite:$R[33]={useBalance:!0}'
    '</script></body></html>'
)

rl_meters, _ = module.parse_meters(rl_go_page)
rl_limits = module.build_limits(rl_meters)
assert len(rl_limits) == 3, "build_limits keeps a rate-limited meter"
rl_monthly = [entry for entry in rl_limits if entry["label"] == "Monthly"][0]
assert rl_monthly["percent"] == 1.0, "percent clamps at full"
assert rl_monthly["status"] == "rate-limited", "rate-limited meter carries its status"
assert "status" not in rl_limits[0], "healthy meters carry no status field"

assert module.parse_go_config(rl_go_page) == {"useBalance": True, "balance": 996544169}, \
    "go config reads useBalance and the Zen balance before lite:"
assert module.parse_go_config('<script>lite:$R[7]={useBalance:!1}</script>') == {"useBalance": False, "balance": None}, \
    "useBalance off parses as false with no balance"
assert module.parse_go_config('<script>no config here</script>') == {"useBalance": False, "balance": None}, \
    "missing lite block parses as defaults"

note_hero, note_help = module.rate_limited_note(rl_limits, {"useBalance": True, "balance": 996544169})
assert note_hero == "Monthly limit reached", "hero names the exhausted window"
assert "$9.97" in note_help and "Zen balance" in note_help, "help bills the Zen balance with the amount left"
_, note_help = module.rate_limited_note(rl_limits, {"useBalance": False, "balance": None})
assert "Zen balance" not in note_help and "blocked" in note_help, "without Use balance, requests block"
_, note_help = module.rate_limited_note(rl_limits, {"useBalance": True, "balance": None})
assert "empty" in note_help, "Use balance with no credits still blocks"
assert module.rate_limited_note(limits, {}) == ("", ""), "healthy meters carry no rate-limit note"

rl_record = module.build_record(rl_meters, "Go", [], {"useBalance": True, "balance": 996544169})
assert rl_record["ready"] is True, "a rate-limited meter is still a ready record"
assert rl_record["usageStatusText"] == "Monthly limit reached", "record hero announces the limit"
assert "Zen balance" in rl_record["authHelpText"], "record help explains the fallback"
rl_blocked = module.build_record(rl_meters, "Go", [])
assert rl_blocked["authHelpText"] == "Requests blocked until the window resets", "default is a hard block"

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

# --- usage-list paging ---------------------------------------------------
#
# The usage page SSR renders only the newest 50 records; older days are
# fetched page-by-page through the usage-list server function. A refresh that
# stops at the first page would make every day that scrolled past it vanish
# from the record, so the walk must reach back through the trailing week.

assert module.seroval_args(["wrk_cccccccccccccccccccccccccc", 0]) == {
    "t": {"t": 9, "i": 0, "l": 2,
          "a": [{"t": 1, "s": "wrk_cccccccccccccccccccccccccc"}, {"t": 0, "s": 0}],
          "o": 0},
    "f": 31,
    "m": [],
}, "seroval encodes the SPA's (workspace, page) arguments"

six_days_ago = today - dt.timedelta(days=6)
week_cutoff = today - dt.timedelta(days=8)


def page_html(rows):
    return "<script>" + ",".join(rows) + "</script>"


def fill(day, n):
    return [rec("usg_01ZZZ%03d" % i, day, "deepseek-v4-flash", 1, 1, 0, 0, "null", "null")
            for i in range(n)]


fetched_pages = []


def fake_chunk(cookie, workspace, page, instance):
    fetched_pages.append(page)
    if page == 0:
        return page_html(fill(today, 50))
    if page == 1:
        return page_html(fill(yesterday, 50))
    if page == 2:
        return page_html(fill(six_days_ago, 50))
    # Out of window: the walk must stop here without keeping these.
    return page_html(fill(week_cutoff, 50))


module.fetch_usage_chunk = fake_chunk
walk = module.fetch_usage_records("cookie", "wrk_cccccccccccccccccccccccccc")
assert fetched_pages == [0, 1, 2, 3], "usage walk pages newest-first until past the window"
walk_days = {record["day"] for record in walk}
assert today.isoformat() in walk_days, "today survives a later refresh"
assert yesterday.isoformat() in walk_days, "yesterday survives a later refresh"
assert week_cutoff.isoformat() not in walk_days, "records outside the trailing week are dropped"
assert len(walk) == 150, "walk keeps exactly the in-window records"

# The console's usage list pages back through retained history, and new
# records land while a refresh walks it, so an interior page can come back
# short without being the last one. Ending the walk on a short page dropped
# whole days (yesterday scrolled off the newest page and vanished); only an
# empty page — the list's oldest — or a page whose oldest record predates the
# week ends it.

fetched_pages.clear()

def fake_short_mid(cookie, workspace, page, instance):
    fetched_pages.append(page)
    if page == 0:
        return page_html(fill(today, 50))
    if page == 1:
        return page_html(fill(today, 10))  # short page, but not the last
    if page == 2:
        return page_html(fill(yesterday, 50))
    return page_html(fill(week_cutoff, 50))


module.fetch_usage_chunk = fake_short_mid
walk = module.fetch_usage_records("cookie", "wrk_x")
assert fetched_pages == [0, 1, 2, 3], "an interior short page does not end the walk"
assert yesterday.isoformat() in {record["day"] for record in walk}, "yesterday survives a short page mid-history"
assert len(walk) == 110, "interior short pages keep their records"

# A mid-walk failure keeps the pages already parsed; a failed first page
# yields the old empty-records shape.
fetched_pages.clear()

def fake_flaky(cookie, workspace, page, instance):
    fetched_pages.append(page)
    if page == 1:
        raise urllib.error.URLError("no route")
    return page_html(fill(today, 50))


module.fetch_usage_chunk = fake_flaky
walk = module.fetch_usage_records("cookie", "wrk_cccccccccccccccccccccccccc")
assert fetched_pages == [0, 1], "a failed page stops the walk"
assert len(walk) == 50, "pages already parsed survive a mid-walk failure"

module.fetch_usage_chunk = lambda cookie, workspace, page, instance: "<script></script>"
assert module.fetch_usage_records("cookie", "wrk_x") == [], "an empty list page ends the walk"

fetched_pages.clear()

def fake_always(cookie, workspace, page, instance):
    fetched_pages.append(page)
    return page_html(fill(today, 50))


module.fetch_usage_chunk = fake_always
walk = module.fetch_usage_records("cookie", "wrk_x")
assert len(fetched_pages) == module.MAX_USAGE_PAGES, "a walk that never leaves the window is capped"
assert len(walk) == module.MAX_USAGE_PAGES * 50, "the cap truncates instead of hanging"

# --- healthy main(): meters plus a window walk that includes yesterday -----
module.fetch_page = lambda cookie, path: go_page
module.fetch_usage_chunk = fake_chunk
captured = io.StringIO()
with contextlib.redirect_stdout(captured):
    exit_code = module.main()
assert exit_code == 0, "main returns 0 on a healthy run"
healthy = json.loads(captured.getvalue())
by_day = {entry["date"]: entry["messageCount"] for entry in healthy["recentDays"]}
assert by_day.get(today.isoformat(), 0) > 0, "healthy record keeps today's tokens"
assert by_day.get(yesterday.isoformat(), 0) > 0, "healthy record keeps yesterday's tokens"
assert by_day.get(week_cutoff.isoformat(), 0) == 0, "healthy record drops out-of-window days"
assert healthy["ready"] is True, "healthy record stays ready"
assert healthy["usageStatusText"] == "", "healthy record carries no status card"
assert healthy["limits"] != [], "healthy record carries fresh meters"

print(json.dumps({
    "plan": plan,
    "limits": limits,
    "records": records,
    "stats": stats,
    "record": full_record,
    "limitsOnly": limits_only,
    "rlRecord": rl_record,
    "rlMonthly": rl_monthly,
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

[[ $(jq -r '.rlMonthly.status + ":" + (.rlMonthly.percent | tostring)' <<<"$result") == "rate-limited:1.0" ]] ||
  fail "OpenCode Go collector reports a rate-limited meter at full percentage" "$result"
pass "OpenCode Go collector reports a rate-limited meter at full percentage"

[[ $(jq -c '.rlRecord | {ready, usageStatusText, authHelpText}' <<<"$result") == '{"ready":true,"usageStatusText":"Monthly limit reached","authHelpText":"Billing the Zen balance ($9.97 left) until the window resets"}' ]] ||
  fail "OpenCode Go collector announces a rate-limited window and the Zen-balance fallback" "$result"
pass "OpenCode Go collector announces a rate-limited window and the Zen-balance fallback"
