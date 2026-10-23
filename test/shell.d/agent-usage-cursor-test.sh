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
unset CURSOR_API_KEY CURSOR_AUTH_PATH CURSOR_API_ENDPOINT

# Cursor's dashboard RPCs, answered per method; FAIL_WITH makes every call
# fail with that HTTP status.
collect() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-cursor" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, sys, time, urllib.error

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

now = int(time.time() * 1000)
start, end = now - 20 * 86400000, now + 10 * 86400000

def urlopen(request, timeout=None):
  assert request.get_header("Authorization") == "Bearer test-token"
  fail = os.environ.get("FAIL_WITH")
  if fail:
    raise urllib.error.HTTPError(request.full_url, int(fail), "fail", {}, None)
  method = request.full_url.rsplit("/", 1)[1]
  if method == "GetCurrentPeriodUsage":
    body = {"billingCycleStart": str(start), "billingCycleEnd": str(end),
            "planUsage": {"totalPercentUsed": 30, "autoPercentUsed": 20, "apiPercentUsed": 50,
                          "totalSpend": 1234, "includedSpend": 1000, "bonusSpend": 234, "limit": 2000},
            "spendLimitUsage": {"individualLimit": 5000, "individualUsed": 1250}}
  elif method == "GetPlanInfo":
    body = {"planInfo": {"planName": "Pro"}}
  else:
    body = {"aggregations": [{"modelIntent": "auto", "inputTokens": "100", "outputTokens": "50"}]}
  return io.BytesIO(json.dumps(body).encode())

collector.urllib.request.urlopen = urlopen
sys.argv = ["omarchy-agent-usage-cursor", "--force"]
collector.main()
PY
}

record=$(collect)
[[ $(jq -c '{id, ready, limits}' <<<"$record") == '{"id":"cursor","ready":false,"limits":[]}' ]] ||
  fail "a machine nobody signed in to Cursor on gives an empty record" "$record"
pass "a machine nobody signed in to Cursor on gives an empty record"

mkdir -p "$XDG_CONFIG_HOME/cursor"
printf '{"accessToken":"test-token"}\n' >"$XDG_CONFIG_HOME/cursor/auth.json"
record=$(collect)
[[ $(jq -c '{ready, tierLabel, labels: [.limits[].label], percents: [.limits[].percent]}' <<<"$record") == '{"ready":true,"tierLabel":"Pro","labels":["Included total","Auto models","Named models","On-demand $12.50 / $50.00"],"percents":[0.3,0.2,0.5,0.25]}' ]] ||
  fail "the CLI sign-in reads Cursor's own meters" "$record"
[[ $(jq -c '[.limits[].windowSeconds]' <<<"$record") == "[$((30 * 86400)),$((30 * 86400)),$((30 * 86400)),$((30 * 86400))]" ]] ||
  fail "every row, on-demand included, carries the billing cycle's length for the pace" "$record"
[[ $(jq -c '.limits[0].details' <<<"$record") == '[{"label":"Spend","value":"$12.34 (included $10.00 + bonus $2.34)"},{"label":"Included allowance","value":"$20.00"}]' ]] ||
  fail "the plan's dollar figures are detail lines" "$record"
[[ $(jq -r '.todayTotalTokens' <<<"$record") == 150 ]] || fail "today's tokens come from the aggregated events" "$record"
pass "the CLI sign-in reads Cursor's own meters"

record=$(FAIL_WITH=401 collect)
[[ $(jq -c '{stale: .limitsStale, status: .usageStatusText, percent: .limits[0].percent}' <<<"$record") == '{"stale":true,"status":"Waiting for auth","percent":0.3}' ]] ||
  fail "a lapsed sign-in keeps the last limits, marked stale" "$record"
pass "a lapsed sign-in keeps the last limits, marked stale"

rm "$XDG_CONFIG_HOME/cursor/auth.json"
mkdir -p "$XDG_CONFIG_HOME/Cursor/User/globalStorage"
python3 -c 'import sqlite3, sys; c = sqlite3.connect(sys.argv[1]); c.execute("CREATE TABLE ItemTable (key TEXT, value BLOB)"); c.execute("INSERT INTO ItemTable VALUES (?, ?)", ("cursorAuth/accessToken", "test-token")); c.commit()' \
  "$XDG_CONFIG_HOME/Cursor/User/globalStorage/state.vscdb"
record=$(collect)
[[ $(jq -r '.ready' <<<"$record") == true ]] || fail "the editor's sign-in stands in for the CLI's" "$record"
pass "the editor's sign-in stands in for the CLI's"
