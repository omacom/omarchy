#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT
export XDG_CACHE_HOME="$TEST_HOME/.cache"

mkdir -p "$TEST_HOME/.config/cursor"
cat >"$TEST_HOME/.config/cursor/auth.json" <<'EOF'
{ "accessToken": "cursor_test", "refreshToken": "cursor_refresh" }
EOF

# Without a credential the collector must still print a full, hidden-by-default
# record: the update runner writes whatever valid JSON appears on stdout.
no_token=$(HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/missing" XDG_STATE_HOME="$TEST_HOME/.local/state" \
  CURSOR_API_KEY="" "$ROOT/bin/omarchy-agent-usage-cursor")

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.hasPromptStats | tostring)' <<<"$no_token") == "cursor:false:false" ]] ||
  fail "Cursor collector prints a valid record without credentials" "$no_token"
pass "Cursor collector prints a valid record without credentials"

result=$(python3 - "$ROOT/bin/omarchy-agent-usage-cursor" "$TEST_HOME/.config" "$TEST_HOME/.local/state" <<'PY'
import importlib.machinery
import importlib.util
import json
import os
import sys
import time
from datetime import datetime, timedelta
from pathlib import Path

collector_path = str(Path(sys.argv[1]))
os.environ["XDG_CONFIG_HOME"] = sys.argv[2]
os.environ["XDG_STATE_HOME"] = sys.argv[3]

# Day windows resolve in local time, so pin the zone or the fixtures below
# would shift by a day depending on where the test runs.
os.environ["TZ"] = "UTC"
time.tzset()
os.environ.pop("CURSOR_API_KEY", None)

loader = importlib.machinery.SourceFileLoader("cursor_collector", collector_path)
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

today = datetime.now().astimezone().date()
yesterday = today - timedelta(days=1)

# Spend well past the included limit, the way a plan with provider bonus usage
# reports it: 609.86 spent against a 400.00 allowance, while Cursor's own
# meters say 18.76% / 11.81% / 100%.
PERIOD = {
  "billingCycleEnd": "1792099926000",
  "planUsage": {
    "totalSpend": 60986,
    "includedSpend": 40000,
    "limit": 40000,
    "autoPercentUsed": 11.81,
    "apiPercentUsed": 100,
    "totalPercentUsed": 18.76,
  },
  "spendLimitUsage": {"individualLimit": "1000", "individualUsed": "951", "limitType": "user"},
}

AGGREGATIONS = {
  today.isoformat(): [
    {"modelIntent": "default", "inputTokens": "10", "outputTokens": "5",
     "cacheReadTokens": "100", "cacheWriteTokens": "1", "totalCents": None},
  ],
  yesterday.isoformat(): [
    {"modelIntent": "default", "inputTokens": "2", "outputTokens": "3",
     "cacheReadTokens": "4", "cacheWriteTokens": "0"},
    {"modelIntent": "kimi-k3-max", "inputTokens": "1", "outputTokens": "1",
     "cacheReadTokens": "0", "cacheWriteTokens": "0"},
  ],
}

calls = []


class StubClient(collector.CursorClient):
  def call(self, method, payload):
    calls.append((method, payload))
    if method == "GetCurrentPeriodUsage":
      return PERIOD
    if method == "GetPlanInfo":
      return {"planInfo": {"planName": "Ultra"}}
    if method == "GetAggregatedUsageEvents":
      start = datetime.fromtimestamp(int(payload["startDate"]) / 1000).astimezone().date()
      return {"aggregations": AGGREGATIONS.get(start.isoformat(), [])}
    raise AssertionError(f"unexpected method: {method}")


collector.CursorClient = StubClient
record = collector.scan("https://api.example", Path(os.environ["XDG_CONFIG_HOME"]) / "cursor" / "auth.json", False)

windows = collector.day_windows(today, collector.RECENT_DAYS)
first_start = datetime.fromtimestamp(windows[0][1] / 1000).astimezone()

# --limits-only keeps the token sections of this account's last scan.
carried = collector.scan("https://api.example", Path(os.environ["XDG_CONFIG_HOME"]) / "cursor" / "auth.json", True)

# ...but only for so long: an old scan is fetched again.
stats_file = collector.stats_cache(collector.account_key("cursor_test"))
fresh_scan = json.loads(stats_file.read_text())
stats_file.write_text(json.dumps(dict(fresh_scan, scannedAtMs=fresh_scan["scannedAtMs"] - sys.modules["collectors"].LIMITS_ONLY_REUSE_SECONDS * 1000)))
calls_before = len(calls)
collector.scan("https://api.example", Path(os.environ["XDG_CONFIG_HOME"]) / "cursor" / "auth.json", True)
refetched = sum(1 for method, _ in calls[calls_before:] if method == "GetAggregatedUsageEvents")
del calls[calls_before:]
stats_file.write_text(json.dumps(fresh_scan))

# Another account's scan never stands in: signed in as someone else with the
# dashboard down, there are no tokens to show.
class DownForOther(StubClient):
  def call(self, method, payload):
    raise collector.CursorError("Cursor API unreachable")


collector.CursorClient = DownForOther
os.environ["CURSOR_API_KEY"] = "someone_else"
other = collector.scan("https://api.example", Path(os.environ["XDG_CONFIG_HOME"]) / "cursor" / "auth.json", False)
os.environ.pop("CURSOR_API_KEY")
collector.CursorClient = StubClient

# A scan from yesterday moves onto this week's dates, and its today figures
# are cleared, since none of it happened today.
key = collector.account_key("cursor_test")
cache = collector.stats_cache(key)
scan = json.loads(cache.read_text())
yesterday_scan = dict(scan, scanDate=yesterday.isoformat())
yesterday_scan["stats"] = dict(scan["stats"], recentDays=[{"date": (today - timedelta(days=offset)).isoformat(), "messageCount": offset} for offset in range(7, 0, -1)])
# Each day's usage rides along, so the day that falls out of the week leaves
# the model totals and active days as well as the chart.
yesterday_scan["stats"]["days"] = [[(today - timedelta(days=offset)).isoformat(), {"carried-model": {"inputTokens": offset}}] for offset in range(7, 0, -1)]
cache.write_text(json.dumps(yesterday_scan))
overnight = collector.carried_stats(key, today)
# A scan cached before days were kept still moves onto the new week.
cache.write_text(json.dumps(dict(yesterday_scan, stats={k: v for k, v in yesterday_scan["stats"].items() if k != "days"})))
overnight_legacy = collector.carried_stats(key, today)
cache.write_text(json.dumps(scan))

# A kept limit whose billing cycle has ended comes back at zero.
limits_cache = collector.limits_cache(key).path
good = json.loads(limits_cache.read_text())
past = "2020-01-01T00:00:00+00:00"
limits_cache.write_text(json.dumps(dict(good, limits=[dict(good["limits"][0], resetsAt=past)] + good["limits"][1:3] + [dict(good["limits"][3], resetsAt=past)])))
collector.CursorClient = DownForOther
lapsed = collector.scan("https://api.example", Path(os.environ["XDG_CONFIG_HOME"]) / "cursor" / "auth.json", False, force=True)
limits_cache.write_text(json.dumps(good))
collector.CursorClient = StubClient


# A failed check keeps the last good limits and the week on disk, marked stale.
class DownClient(StubClient):
  def call(self, method, payload):
    raise collector.CursorError("Cursor API unreachable")


class RefusedClient(StubClient):
  def call(self, method, payload):
    raise collector.CursorError(collector.AUTH_HELP, auth=True)


collector.CursorClient = DownClient
down = collector.scan("https://api.example", Path(os.environ["XDG_CONFIG_HOME"]) / "cursor" / "auth.json", False, force=True)
collector.CursorClient = RefusedClient
refused = collector.scan("https://api.example", Path(os.environ["XDG_CONFIG_HOME"]) / "cursor" / "auth.json", False, force=True)

print(json.dumps({
  "other": other,
  "overnight": overnight,
  "overnightLegacy": overnight_legacy,
  "lapsed": [[limit["label"], round(limit["percent"] * 100), limit["resetsAt"]] for limit in lapsed["limits"][:2]],
  "lapsedOnDemand": {name: lapsed["limits"][3][name] for name in ("label", "title", "percent", "resetsAt")},
  "down": down,
  "refused": refused,
  "record": record,
  "aggregationCalls": sum(1 for method, _ in calls if method == "GetAggregatedUsageEvents"),
  "windowIsLocalMidnight": (first_start.hour, first_start.minute, first_start.second) == (0, 0, 0),
  "carriedRecentDays": carried["recentDays"] == record["recentDays"],
  "refetched": refetched,
  "carriedSkipsAggregation": sum(1 for method, _ in calls if method == "GetAggregatedUsageEvents") == collector.RECENT_DAYS,
}))
PY
)

[[ $(jq -c '.record | {schemaVersion, id, name, ready, hasPromptStats, scope, tierLabel, usageStatusText}' <<<"$result") == '{"schemaVersion":1,"id":"cursor","name":"Cursor","ready":true,"hasPromptStats":false,"scope":"account","tierLabel":"Ultra","usageStatusText":""}' ]] ||
  fail "Cursor collector prints the display-ready record contract" "$result"
pass "Cursor collector prints the display-ready record contract"

[[ $(jq -c '[.record.limits[] | {label, percent: (.percent * 10000 | round)}]' <<<"$result") == '[{"label":"Included total","percent":1876},{"label":"Auto models","percent":1181},{"label":"Named models","percent":10000},{"label":"On-demand $9.51 / $10.00","percent":9510}]' ]] ||
  fail "Cursor collector reports Cursor's own meters, not spend over the allowance" "$result"
pass "Cursor collector reports Cursor's own meters, not spend over the allowance"

[[ $(jq -r '.record.limits[0].resetsAt' <<<"$result") == "2026-10-15T21:32:06+00:00" ]] ||
  fail "Cursor collector dates the reset from the billing cycle end" "$result"
pass "Cursor collector dates the reset from the billing cycle end"

[[ $(jq -r '.aggregationCalls' <<<"$result") == "7" ]] ||
  fail "Cursor collector asks for seven daily windows" "$result"
pass "Cursor collector asks for seven daily windows"

[[ $(jq -r '.windowIsLocalMidnight' <<<"$result") == "true" ]] ||
  fail "Cursor collector requests windows that start at local midnight" "$result"
pass "Cursor collector requests windows that start at local midnight"

[[ $(jq -c '[.record.recentDays[] | .messageCount]' <<<"$result") == '[0,0,0,0,0,11,116]' ]] ||
  fail "Cursor collector builds the seven-day token series" "$result"
pass "Cursor collector builds the seven-day token series"

[[ $(jq -c '.record.modelUsage' <<<"$result") == '{"default":{"inputTokens":12,"outputTokens":8,"cacheReadInputTokens":104,"cacheCreationInputTokens":1},"kimi-k3-max":{"inputTokens":1,"outputTokens":1,"cacheReadInputTokens":0,"cacheCreationInputTokens":0}}' ]] ||
  fail "Cursor collector maps Cursor token names onto the record contract" "$result"
pass "Cursor collector maps Cursor token names onto the record contract"

[[ $(jq -c '{today: .record.todayTotalTokens, byModel: .record.todayTokensByModel, activeDays: .record.activeDays}' <<<"$result") == '{"today":116,"byModel":{"default":116},"activeDays":2}' ]] ||
  fail "Cursor collector separates today from the rest of the week" "$result"
pass "Cursor collector separates today from the rest of the week"

[[ $(jq -r '.carriedRecentDays' <<<"$result") == "true" && $(jq -r '.carriedSkipsAggregation' <<<"$result") == "true" ]] ||
  fail "Cursor collector keeps the token sections on --limits-only" "$result"
pass "Cursor collector keeps the token sections on --limits-only"

[[ $(jq -r '.refetched' <<<"$result") == "7" ]] ||
  fail "Cursor collector fetches tokens again once the carried scan is old" "$result"
pass "Cursor collector fetches tokens again once the carried scan is old"

[[ $(jq -c '.record | {limitsStale, fetched: (.limitsFetchedAt > 0)}' <<<"$result") == '{"limitsStale":false,"fetched":true}' ]] ||
  fail "Cursor collector stamps fresh limits" "$result"
pass "Cursor collector stamps fresh limits"

[[ $(jq -c '{same: (.down.limits == .record.limits), stamp: (.down.limitsFetchedAt >= .record.limitsFetchedAt), stale: .down.limitsStale, tier: .down.tierLabel, status: .down.usageStatusText, week: (.down.recentDays == .record.recentDays)}' <<<"$result") == '{"same":true,"stamp":true,"stale":true,"tier":"Ultra","status":"","week":true}' ]] ||
  fail "Cursor collector keeps the last good limits, stale, after a failed check" "$result"
pass "Cursor collector keeps the last good limits, stale, after a failed check"

[[ $(jq -c '{stale: .refused.limitsStale, status: .refused.usageStatusText, kept: (.refused.limits | length)}' <<<"$result") == '{"stale":true,"status":"Sign-in expired","kept":4}' ]] ||
  fail "Cursor collector says a refused sign-in has expired" "$result"
pass "Cursor collector says a refused sign-in has expired"

[[ $(jq -c '.other | {limits, tierLabel, todayTotalTokens, counts: [.recentDays[].messageCount], last: .recentDays[6].date, modelUsage}' <<<"$result") == "{\"limits\":[],\"tierLabel\":\"\",\"todayTotalTokens\":0,\"counts\":[0,0,0,0,0,0,0],\"last\":\"$(TZ=UTC date +%F)\",\"modelUsage\":{}}" ]] ||
  fail "Cursor collector never carries another account's numbers" "$result"
pass "Cursor collector never carries another account's numbers"

[[ $(jq -c '.overnight | {todayTotalTokens, todayTokensByModel, counts: [.recentDays[].messageCount], last: .recentDays[6].date}' <<<"$result") == "{\"todayTotalTokens\":0,\"todayTokensByModel\":{},\"counts\":[6,5,4,3,2,1,0],\"last\":\"$(TZ=UTC date +%F)\"}" ]] ||
  fail "Cursor collector moves a scan from yesterday onto today's week" "$result"
[[ $(jq -c '.overnight | {model: .modelUsage["carried-model"].inputTokens, activeDays, dates: (.activeDates | length)}' <<<"$result") == '{"model":21,"activeDays":6,"dates":6}' ]] ||
  fail "Cursor collector drops the day that left the week from the model totals" "$result"
[[ $(jq -c '.overnightLegacy | {todayTotalTokens, counts: [.recentDays[].messageCount]}' <<<"$result") == '{"todayTotalTokens":0,"counts":[6,5,4,3,2,1,0]}' ]] ||
  fail "Cursor collector moves an older cached scan onto today's week" "$result"
pass "Cursor collector moves a scan from yesterday onto today's week"

[[ $(jq -c '.lapsed' <<<"$result") == '[["Included total",0,""],["Auto models",12,"2026-10-15T21:32:06+00:00"]]' ]] ||
  fail "Cursor collector resets a kept limit whose cycle ended" "$result"
[[ $(jq -c '.lapsedOnDemand | {label, title, zero: (.percent == 0), resetsAt}' <<<"$result") == '{"label":"On-demand $0.00 / $10.00","title":"On-demand $0.00 / $10.00 Monthly","zero":true,"resetsAt":""}' ]] ||
  fail "Cursor collector renames an on-demand meter that reset with its new spend" "$result"
pass "Cursor collector resets a kept limit whose cycle ended"

# Days that spring forward or fall back are 23 or 25 hours long.
dst=$(TZ=America/New_York python3 - "$ROOT/bin/omarchy-agent-usage-cursor" <<'PY'
import importlib.machinery
import importlib.util
import sys
from datetime import date

loader = importlib.machinery.SourceFileLoader("cursor_collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

spring = collector.day_windows(date(2026, 3, 9), 2)
fall = collector.day_windows(date(2026, 11, 1), 1)
hours = [(end - start) / 3_600_000 for _, start, end in spring + fall]
print(" ".join(str(int(h)) for h in hours), spring[0][2] == spring[1][1])
PY
)
[[ $dst == "23 24 25 True" ]] || fail "Cursor collector sizes daily windows across DST" "$dst"
pass "Cursor collector sizes daily windows across DST"

# Someone who only uses the Cursor editor has no CLI auth file; the editor's
# own sign-in in state.vscdb stands in, read without touching the database.
ide=$(python3 - "$ROOT/bin/omarchy-agent-usage-cursor" "$TEST_HOME/ide" "$TEST_HOME/.config/cursor/auth.json" <<'PY'
import hashlib
import importlib.machinery
import importlib.util
import json
import os
import sqlite3
import sys
from pathlib import Path

os.environ.pop("CURSOR_API_KEY", None)
loader = importlib.machinery.SourceFileLoader("cursor_collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

root = Path(sys.argv[2])
db = root / "Cursor" / "User" / "globalStorage" / "state.vscdb"
db.parent.mkdir(parents=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB)")
conn.execute("INSERT INTO ItemTable VALUES ('cursorAuth/accessToken', 'ide_token')")
conn.commit()
conn.close()
before = hashlib.sha256(db.read_bytes()).hexdigest()

os.environ["XDG_CONFIG_HOME"] = str(root)
print(json.dumps({
  "ide": collector.cursor_token(root / "cursor" / "auth.json"),
  "cliWins": collector.cursor_token(Path(sys.argv[3])),
  "untouched": hashlib.sha256(db.read_bytes()).hexdigest() == before and sorted(p.name for p in db.parent.iterdir()) == ["state.vscdb"],
}))
PY
)
[[ $(jq -c . <<<"$ide") == '{"ide":"ide_token","cliWins":"cursor_test","untouched":true}' ]] ||
  fail "Cursor collector falls back to the editor's sign-in, read-only" "$ide"
pass "Cursor collector falls back to the editor's sign-in, read-only"

# Cursor installed but signed in nowhere: the agent is in use, so it says it
# is waiting for a sign-in. A machine without Cursor at all stays unused.
mkdir -p "$TEST_HOME/unsigned/cursor"
unsigned=$(HOME="$TEST_HOME/unsigned-home" XDG_CONFIG_HOME="$TEST_HOME/unsigned" XDG_CACHE_HOME="$TEST_HOME/unsigned-cache" \
  CURSOR_API_KEY="" "$ROOT/bin/omarchy-agent-usage-cursor")
[[ $(jq -c '{ready, usageStatusText, limits, help: (.authHelpText != "")}' <<<"$unsigned") == '{"ready":true,"usageStatusText":"Waiting for auth","limits":[],"help":true}' ]] ||
  fail "Cursor collector waits for a sign-in where Cursor is installed" "$unsigned"
# The last seven local days ending today, none with messages: an unused
# record still carries the full week, zeroed.
empty_week=$(for offset in 6 5 4 3 2 1 0; do date -d "$(date +%F) 12:00 $offset days ago" +%F; done | jq -Rsc 'split("\n")[:-1] | map({date: ., messageCount: 0})')
[[ $(jq -c '{ready, usageStatusText, authHelpText, limits, todayPrompts, recentDays, modelUsage}' <<<"$no_token") == '{"ready":false,"usageStatusText":"","authHelpText":"","limits":[],"todayPrompts":0,"recentDays":'"$empty_week"',"modelUsage":{}}' ]] ||
  fail "Cursor collector prints an unused record where Cursor isn't installed" "$no_token"
pass "Cursor collector waits for a sign-in only where Cursor is installed"

contract=$(python3 - "$ROOT/bin/omarchy-agent-usage-cursor" "$TEST_HOME/contract" <<'PY'
import base64
import importlib.machinery
import importlib.util
import json
import os
import sqlite3
import sys
import time
from pathlib import Path

root = Path(sys.argv[2])
os.environ["HOME"] = str(root / "home")
os.environ["XDG_CONFIG_HOME"] = str(root / "config")
os.environ["XDG_CACHE_HOME"] = str(root / "cache")
os.environ.pop("CURSOR_API_KEY", None)
os.environ["TZ"] = "UTC"
time.tzset()

loader = importlib.machinery.SourceFileLoader("cursor_collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
RealClient = collector.CursorClient


def jwt(sub, exp):
  claims = base64.urlsafe_b64encode(json.dumps({"sub": sub, "exp": exp}).encode()).decode().rstrip("=")
  return f"h.{claims}.s"


auth = root / "config" / "cursor" / "auth.json"
auth.parent.mkdir(parents=True)
auth.write_text(json.dumps({"accessToken": jwt("u-main", time.time() + 3600)}))

PERIOD = {"planUsage": {"totalPercentUsed": 40, "autoPercentUsed": 20, "apiPercentUsed": 60},
          "spendLimitUsage": {"individualLimit": "2000", "individualUsed": "500"}}
calls = []
answers = {"GetPlanInfo": {"planInfo": {"planName": "Pro"}}, "GetCurrentPeriodUsage": PERIOD}


class Stub(RealClient):
  def call(self, method, payload):
    calls.append(method)
    answer = answers.get(method, {"aggregations": [{"modelIntent": "default", "inputTokens": "3"}]})
    if isinstance(answer, Exception):
      raise answer
    return answer


def run(client=Stub, **kwargs):
  collector.CursorClient = client
  del calls[:]
  record = collector.scan("https://api.example", auth, kwargs.pop("limits_only", False), **kwargs)
  return record, list(calls)


out = {}
# Without a billing cycle end there is no reset time, as "" rather than null.
fresh, _ = run(force=True)
out["fresh"] = {key: fresh[key] for key in ("tierLabel", "usageStatusText", "authHelpText", "limitsStale")}
out["titles"] = [limit["title"] for limit in fresh["limits"]]
out["resets"] = sorted({limit["resetsAt"] for limit in fresh["limits"]})

# A second run straight after asks nothing: the limits answer and the token
# scan are both this recent.
reused, asked = run()
out["reused"] = {"asked": asked, "same": reused["limits"] == fresh["limits"], "stale": reused["limitsStale"],
                 "help": reused["authHelpText"], "tokens": reused["todayTotalTokens"]}
_, asked = run(limits_only=True)
out["limitsOnlyReused"] = asked
_, asked = run(force=True)
out["forced"] = sorted(set(asked))

# GetPlanInfo failing leaves the plan the account last had.
answers["GetPlanInfo"] = collector.CursorError("Cursor's dashboard returned status 500.")
planless, _ = run(force=True)
out["planKept"] = planless["tierLabel"]
answers["GetPlanInfo"] = {"planInfo": {"planName": "Pro"}}

# A failure that isn't Cursor's error keeps the limits and the tokens too.
answers["GetCurrentPeriodUsage"] = RuntimeError("boom")
broken, _ = run(force=True)
out["broken"] = {"kept": len(broken["limits"]), "stale": broken["limitsStale"], "status": broken["usageStatusText"],
                 "tokens": broken["todayTotalTokens"], "retry": broken.get("retryAdvised", False)}
answers["GetCurrentPeriodUsage"] = PERIOD


# retryAdvised only when nothing answered at all.
def urlopen_raising(error):
  def urlopen(request, timeout=None):
    raise error
  return urlopen


transport = {}
for name, error in (
  ("dns", collector.urllib.error.URLError("no route")),
  ("timeout", TimeoutError()),
  ("status", collector.urllib.error.HTTPError("https://api.example", 500, "", {}, None)),
):
  collector.urllib.request.urlopen = urlopen_raising(error)
  record, _ = run(RealClient, force=True)
  transport[name] = [record.get("retryAdvised", False), record["limitsStale"], len(record["limits"]), record["usageStatusText"]]
out["transport"] = transport

# A lapsed sign-in isn't sent: the CLI or editor renews it when it runs.
collector.urllib.request.urlopen = urlopen_raising(AssertionError("a lapsed token was sent"))
auth.write_text(json.dumps({"accessToken": jwt("u-main", time.time() - 60)}))
paused, _ = run(RealClient, force=True)
out["paused"] = [paused["usageStatusText"], paused["limitsStale"], len(paused["limits"])]

# ...but a live editor sign-in stands in for a lapsed CLI one.
db = root / "config" / "Cursor" / "User" / "globalStorage" / "state.vscdb"
db.parent.mkdir(parents=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB)")
conn.execute("INSERT INTO ItemTable VALUES ('cursorAuth/accessToken', ?)", (jwt("u-editor", time.time() + 3600),))
conn.commit()
conn.close()
out["fallthrough"] = collector.account_key(collector.cursor_token(auth)) == collector.account_key(jwt("u-editor", 0))

# Untrusted numbers never break the record.
out["robust"] = [collector.fraction("nan"), collector.fraction("inf"), collector.fraction(True), collector.number("1e400"), collector.iso("9" * 30)]
print(json.dumps(out))
PY
)

[[ $(jq -c '.fresh' <<<"$contract") == '{"tierLabel":"Pro","usageStatusText":"","authHelpText":"","limitsStale":false}' ]] ||
  fail "Cursor collector clears the help text when healthy" "$contract"
pass "Cursor collector clears the help text when healthy"

[[ $(jq -c '.titles' <<<"$contract") == '["Monthly","Auto models Monthly","Named models Monthly","On-demand $5.00 / $20.00 Monthly"]' ]] ||
  fail "Cursor collector titles its meters after the billing period" "$contract"
pass "Cursor collector titles its meters after the billing period"

[[ $(jq -c '.resets' <<<"$contract") == '[""]' ]] ||
  fail "Cursor collector gives an unknown reset as an empty string" "$contract"
pass "Cursor collector gives an unknown reset as an empty string"

[[ $(jq -c '.reused' <<<"$contract") == '{"asked":[],"same":true,"stale":false,"help":"","tokens":3}' && $(jq -c '.limitsOnlyReused' <<<"$contract") == '[]' ]] ||
  fail "Cursor collector reuses a recent limits answer and token scan" "$contract"
[[ $(jq -c '.forced' <<<"$contract") == '["GetAggregatedUsageEvents","GetCurrentPeriodUsage","GetPlanInfo"]' ]] ||
  fail "Cursor collector asks again on --force" "$contract"
pass "Cursor collector reuses a recent probe, and --force asks again"

[[ $(jq -r '.planKept' <<<"$contract") == "Pro" ]] ||
  fail "Cursor collector keeps the plan when GetPlanInfo fails" "$contract"
pass "Cursor collector keeps the plan when GetPlanInfo fails"

[[ $(jq -c '.broken' <<<"$contract") == '{"kept":4,"stale":true,"status":"","tokens":3,"retry":false}' ]] ||
  fail "Cursor collector keeps limits and tokens through an unexpected failure" "$contract"
pass "Cursor collector keeps limits and tokens through an unexpected failure"

[[ $(jq -c '.transport' <<<"$contract") == '{"dns":[true,true,4,""],"timeout":[true,true,4,""],"status":[false,true,4,""]}' ]] ||
  fail "Cursor collector advises a retry only when the dashboard can't be reached" "$contract"
pass "Cursor collector advises a retry only when the dashboard can't be reached"

[[ $(jq -c '.paused' <<<"$contract") == '["Limits paused",true,4]' && $(jq -r '.fallthrough' <<<"$contract") == "true" ]] ||
  fail "Cursor collector pauses on a lapsed sign-in, preferring a live one" "$contract"
pass "Cursor collector pauses on a lapsed sign-in, preferring a live one"

[[ $(jq -c '.robust' <<<"$contract") == '[0.0,0.0,0.0,0,""]' ]] ||
  fail "Cursor collector shrugs off untrusted numbers" "$contract"
pass "Cursor collector shrugs off untrusted numbers"
