#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

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

# --limits-only keeps the token sections of the record already on disk.
record_path = collector.record_path()
record_path.parent.mkdir(parents=True, exist_ok=True)
record_path.write_text(json.dumps(record))
carried = collector.scan("https://api.example", Path(os.environ["XDG_CONFIG_HOME"]) / "cursor" / "auth.json", True)

print(json.dumps({
  "record": record,
  "aggregationCalls": sum(1 for method, _ in calls if method == "GetAggregatedUsageEvents"),
  "windowIsLocalMidnight": (first_start.hour, first_start.minute, first_start.second) == (0, 0, 0),
  "carriedRecentDays": carried["recentDays"] == record["recentDays"],
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
