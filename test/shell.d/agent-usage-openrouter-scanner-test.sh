#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3
require_command sqlite3

COLLECTOR="$ROOT/bin/omarchy-agent-usage-openrouter"

[[ -x $COLLECTOR ]] || fail "collector missing/executable" "$COLLECTOR"

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

export HOME="$TEST_HOME"
export XDG_CONFIG_HOME="$TEST_HOME/.config"
export XDG_DATA_HOME="$TEST_HOME/.local/share"
export XDG_CACHE_HOME="$TEST_HOME/.cache"
export XDG_STATE_HOME="$TEST_HOME/.local/state"
export OPENROUTER_API_KEY=""
export OPENROUTER_MANAGEMENT_KEY=""
# Bucket dates resolve in local time, so pin the zone or the fixtures below
# would shift by a day depending on where the test runs.
export TZ="UTC"

# 1. Without credentials: valid record, ready=false
no_key=$("$COLLECTOR")
[[ $(jq -r '.id + ":" + (.ready | tostring)' <<<"$no_key") == "openrouter:false" ]] ||
  fail "prints a valid record without credentials" "$no_key"
pass "prints a valid record without credentials"

# 2. Fixture opencode DB: 2 assistant rows (openrouter) + 1 other provider (ignored)
mkdir -p "$XDG_DATA_HOME/opencode"
sqlite3 "$XDG_DATA_HOME/opencode/opencode.db" <<'SQL'
CREATE TABLE message (id TEXT PRIMARY KEY, session_id TEXT NOT NULL, time_created INTEGER NOT NULL, time_updated INTEGER NOT NULL, data TEXT NOT NULL);
INSERT INTO message VALUES
 ('m1','ses_aaa',1787000000000,1787000000000,'{"role":"assistant","providerID":"openrouter","modelID":"openai/gpt-4o-mini","tokens":{"input":100,"output":20,"reasoning":5,"cache":{"read":10,"write":0}},"time":{"created":1787000000000}}'),
 ('m2','ses_aaa',1787000001000,1787000001000,'{"role":"user","providerID":"openrouter","modelID":"openai/gpt-4o-mini","time":{"created":1787000001000}}'),
 ('m3','ses_bbb',1787000002000,1787000002000,'{"role":"assistant","providerID":"openai","modelID":"gpt-5","tokens":{"input":999,"output":999},"time":{"created":1787000002000}}');
SQL

result=$(python3 - "$COLLECTOR" <<'PY'
import importlib.machinery, importlib.util, json, sys
from datetime import datetime, timezone
from pathlib import Path
loader = importlib.machinery.SourceFileLoader("or_collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)

today = datetime.now().astimezone()
scan = mod.LocalScan(today)
complete = mod.scan_opencode(scan)
stats = scan.snapshot()

# /activity fold: prompt+reasoning -> input, completion -> output
activity = mod.summarize_activity([
  {"date": today.strftime("%Y-%m-%d"), "model": "openai/gpt-4o-mini",
   "prompt_tokens": 50, "completion_tokens": 25, "reasoning_tokens": 10},
  {"date": "2020-01-01", "model": "x/y-model",
   "prompt_tokens": 7, "completion_tokens": 3, "reasoning_tokens": 0},
  "garbage-row",
], today)

out = {
  "complete": complete,
  "totalPrompts": stats["totalPrompts"],
  "totalTokens": stats["todayTotalTokens"] + sum(d["messageCount"] for d in stats["recentDays"] if d["date"] != today.strftime("%Y-%m-%d")),
  "model": sorted(stats["modelUsage"].keys()),
  "hasPromptStats_tier1": True,
  "activityToday": activity["todayTotalTokens"],
  "activityModels": sorted(activity["modelUsage"].keys()),
  "activityOldDay": activity["activeDates"],
  "keyMeterEmpty": mod.key_limit_meter({}) == [],
  "keyMeter": mod.key_limit_meter({"limit": 10, "limit_remaining": 4, "limit_reset": "weekly"}),
  "scopeNote": "scope set only in tier2 path",
}
print(json.dumps(out))
PY
)

check() {
  local actual="$1" expected="$2" label="$3"
  [[ $actual == "$expected" ]] || fail "$label (got: $actual, want: $expected)" "$result"
  pass "$label"
}

check "$(jq -r .complete <<<"$result")" "true" "opencode scan completes"
check "$(jq -r .totalPrompts <<<"$result")" "1" "counts only openrouter assistant rows"
check "$(jq -r '.model | join(",")' <<<"$result")" "gpt-4o-mini" "strips provider prefix from model"
check "$(jq -r .activityToday <<<"$result")" "85" "activity folds prompt+completion+reasoning"
check "$(jq -r '.activityModels | join(",")' <<<"$result")" "gpt-4o-mini,y-model" "activity keeps per-model buckets"
check "$(jq -r '.activityOldDay | length' <<<"$result")" "2" "activity tracks active dates"
check "$(jq -r .keyMeterEmpty <<<"$result")" "true" "no meter without key limit"
check "$(jq -r '.keyMeter[0].percent' <<<"$result")" "0.6" "key meter drains toward empty"
check "$(jq -r '.keyMeter[0].resetsAt' <<<"$result")" "weekly" "key meter maps limit_reset"

# 3. Tier-2 path sets scope=account + hasPromptStats=false (stub api_get)
scope_check=$(python3 - "$COLLECTOR" <<'PY'
import importlib.machinery, importlib.util, json, sys
from datetime import datetime
loader = importlib.machinery.SourceFileLoader("or_collector2", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)

captured = {}
def fake_api_get(path, key):
    captured[path] = key
    if path == "/activity":
        return {"data": [{"date": "2026-09-08", "model": "a/b", "prompt_tokens": 10,
                           "completion_tokens": 5, "reasoning_tokens": 0}]}
    if path == "/key":
        return {"data": {"limit": None, "limit_remaining": None}}
    if path == "/credits":
        return {"data": {"total_credits": 10, "total_usage": 1}}
    raise AssertionError(path)
mod.api_get = fake_api_get

class Args: force = True; limits_only = False
import os
os.environ["OPENROUTER_API_KEY"] = "sk-test"
os.environ["OPENROUTER_MANAGEMENT_KEY"] = "sk-mgmt"
rec = mod.scan(Args())
print(json.dumps({"scope": rec.get("scope"), "hasPromptStats": rec.get("hasPromptStats"),
                  "balance": rec.get("balance", {}).get("remaining"),
                  "called": sorted(captured.keys())}))
PY
)
check "$(jq -r .scope <<<"$scope_check")" "account" "tier-2 record is scope=account"
check "$(jq -r .hasPromptStats <<<"$scope_check")" "false" "tier-2 hides prompt counts"
check "$(jq -r .balance <<<"$scope_check")" "9.0" "tier-2 keeps balance from /credits"
check "$(jq -r '.called | join(",")' <<<"$scope_check")" "/activity,/credits,/key" "tier-2 probes activity + key + credits"

pass "ALL OPENROUTER SCANNER TESTS PASSED"
