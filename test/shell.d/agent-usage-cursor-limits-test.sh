#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# Without credentials the collector must still print a full record the update
# runner can write. Isolate HOME so a developer machine's Cursor login cannot
# leak into the fixture.
no_key=$(HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  PATH="$TEST_HOME/bin" "$ROOT/bin/omarchy-agent-usage-cursor")

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.hasPromptStats | tostring)' <<<"$no_key") == "cursor:false:false" ]] ||
  fail "Cursor collector prints a valid record without credentials" "$no_key"
pass "Cursor collector prints a valid record without credentials"

[[ $(jq -r '.usageStatusText' <<<"$no_key") == "Waiting for auth" ]] ||
  fail "Cursor collector reports waiting for auth without credentials" "$no_key"
pass "Cursor collector reports waiting for auth without credentials"

# The printed record is the panel contract: never an access token, never a
# dashboard URL, never a mailbox. Drive the collector as a module over
# synthetic payloads so the network is not involved.
limits=$(COLLECTOR="$ROOT/bin/omarchy-agent-usage-cursor" python3 - <<'PY'
import importlib.machinery
import importlib.util
import json
import os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

period = {
  "billingCycleEnd": "1790849168000",
  "planUsage": {"totalPercentUsed": 25.0, "limit": 2000, "autoPercentUsed": 30.0},
  "spendLimitUsage": {"limitType": "user"},
}
sand = {
  "usagePercent": 0,
  "hasNonZeroIncludedLimit": True,
  "grokPlanLabel": "Grok Bot Plan",
  "nextResetTimestampUtc": "2026-09-14T07:00:00.000Z",
}
plan = {"planInfo": {"planName": "Pro", "billingCycleEnd": "1790849168000"}}
limits, tier = collector.limits_from_payloads(period, sand, plan)
print(json.dumps({"limits": limits, "tier": tier}))
PY
)

[[ $(jq -r '.tier' <<<"$limits") == "Pro" ]] ||
  fail "Cursor collector uses the plan name as the tier, not Grok Bot" "$limits"
pass "Cursor collector uses the plan name as the tier, not Grok Bot"

[[ $(jq -c '[.limits[].title]' <<<"$limits") == '["Monthly"]' ]] ||
  fail "Cursor collector omits unused Grok Bot weekly so it is not drawn as Agent weekly" "$limits"
pass "Cursor collector omits unused Grok Bot weekly so it is not drawn as Agent weekly"

[[ $(jq -r '.limits[0].percent' <<<"$limits") == "0.25" ]] ||
  fail "Cursor collector reads monthly included usage as a fraction" "$limits"
pass "Cursor collector reads monthly included usage as a fraction"

used_grok=$(COLLECTOR="$ROOT/bin/omarchy-agent-usage-cursor" python3 - <<'PY'
import importlib.machinery
import importlib.util
import json
import os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

period = {"planUsage": {"totalPercentUsed": 10.0, "limit": 2000}}
sand = {"usagePercent": 40, "grokPlanLabel": "Grok Bot Plan", "hasNonZeroIncludedLimit": True}
plan = {"planInfo": {"planName": "Pro"}}
limits, _ = collector.limits_from_payloads(period, sand, plan)
print(json.dumps([{"title": e["title"], "percent": e["percent"]} for e in limits]))
PY
)

[[ $(jq -c . <<<"$used_grok") == '[{"title":"Grok Bot","percent":0.4},{"title":"Monthly","percent":0.1}]' ]] ||
  fail "Cursor collector titles an in-use Grok Bot quota as Grok Bot, not Weekly" "$used_grok"
pass "Cursor collector titles an in-use Grok Bot quota as Grok Bot, not Weekly"

secret='cursor-test-token-value-xx'
record=$(COLLECTOR="$ROOT/bin/omarchy-agent-usage-cursor" SECRET="$secret" HOME="$TEST_HOME" \
  XDG_CONFIG_HOME="$TEST_HOME/.config" XDG_CACHE_HOME="$TEST_HOME/.cache" python3 - <<'PY'
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

secret = os.environ["SECRET"]
config = Path(os.environ["XDG_CONFIG_HOME"]) / "cursor"
config.mkdir(parents=True)
config.joinpath("auth.json").write_text(json.dumps({"accessToken": secret}))

def fake_request(path, token, body=None):
  assert token == secret
  if path == collector.PERIOD_PATH:
    return {"ok": True, "payload": {"planUsage": {"totalPercentUsed": 10.0, "limit": 2000}}}
  if path == collector.SAND_PATH:
    return {"ok": True, "payload": {"usagePercent": 0}}
  if path == collector.PLAN_PATH:
    return {"ok": True, "payload": {"planInfo": {"planName": "Pro"}}}
  if path == collector.AGG_PATH:
    return {"ok": True, "payload": {"aggregations": []}}
  if path == collector.EVENTS_PATH:
    return {"ok": True, "payload": {"usageEventsDisplay": []}}
  return {"ok": False, "helpText": "unexpected " + path}

collector.dashboard_request = fake_request
collector.ENV["PATH"] = "/usr/bin:/bin"
print(json.dumps(collector.base_record(
  ready=True,
  tierLabel="Pro",
  limits=collector.collect_limits(collector.get_access_token(), True)["limits"],
)))
PY
)

echo "$record" | grep -Fq "$secret" &&
  fail "Cursor collector record must not contain the access token" "$record"
pass "Cursor collector record must not contain the access token"

echo "$record" | grep -Eiq 'dashboard/spending|accessToken|authorization|@' &&
  fail "Cursor collector record must not contain account URLs, token keys, or mailboxes" "$record"
pass "Cursor collector record must not contain account URLs, token keys, or mailboxes"
