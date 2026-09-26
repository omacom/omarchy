#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

read_limits() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-grok" PAYLOAD="$1" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

collector.urllib.request.urlopen = lambda request, timeout=None: io.BytesIO(os.environ["PAYLOAD"].encode())
print(json.dumps(collector.probe_limits("token", "user-1")))
PY
}

limits=$(read_limits '{
  "config": {
    "creditUsagePercent": 65.0,
    "currentPeriod": {
      "type": "USAGE_PERIOD_TYPE_WEEKLY",
      "start": "2026-09-21T00:23:46.069736+00:00",
      "end": "2026-09-28T00:23:46.069736+00:00"
    },
    "productUsage": [
      {"product": "GrokBuild", "usagePercent": 57.0},
      {"product": "GrokImagine", "usagePercent": 6.0},
      {"product": "GrokChat"}
    ]
  }
}')

expected='[{"label":"Weekly (7-day)","percent":0.65,"resetsAt":"2026-09-28T00:23:46.069736+00:00"},{"label":"Grok Build","percent":0.57,"resetsAt":"2026-09-28T00:23:46.069736+00:00"}]'
[[ $(jq -c '[.ok, .limits]' <<<"$limits") == "[true,$expected]" ]] ||
  fail "Grok collector reads the weekly pool and Grok Build's share" "$limits"
pass "Grok collector reads the weekly pool and Grok Build's share"

monthly=$(read_limits '{
  "config": {
    "creditUsagePercent": 20,
    "currentPeriod": {
      "type": "USAGE_PERIOD_TYPE_MONTHLY",
      "start": "2030-02-01T00:00:00Z",
      "end": "2030-03-01T00:00:00Z"
    }
  }
}')

[[ $(jq -c '[.limits[].label,.limits[].percent]' <<<"$monthly") == '["Monthly",0.2]' ]] ||
  fail "Grok collector titles a monthly billing period as Monthly" "$monthly"
pass "Grok collector titles a monthly billing period as Monthly"

legacy=$(read_limits '{
  "config": {
    "monthlyLimit": {"val": 2000},
    "used": {"val": 500},
    "creditUsagePercent": 25,
    "billingPeriodStart": "2030-02-01T00:00:00Z",
    "billingPeriodEnd": "2030-03-01T00:00:00Z"
  }
}')

[[ $(jq -c '[.limits[0].label,.limits[0].percent]' <<<"$legacy") == '["Monthly",0.25]' ]] ||
  fail "Grok collector infers Monthly from a month-long billing window" "$legacy"
pass "Grok collector infers Monthly from a month-long billing window"

CACHE_HOME=$(mktemp -d)
trap 'rm -rf "$CACHE_HOME"' EXIT

collect_limits() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-grok" TOKEN="$1" EXPIRES_AT="$2" CACHED="$3" \
    XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

cache = collector.cache_root() / "grok-limits.json"
cached = os.environ["CACHED"]
if cached:
  cache.write_text(cached, encoding="utf-8")
elif cache.exists():
  cache.unlink()

def unreachable(request, timeout=None):
  raise OSError("no route to host")

collector.urllib.request.urlopen = unreachable
login = {
  "access_token": os.environ["TOKEN"],
  "expires_at_ms": int(os.environ["EXPIRES_AT"]),
  "refresh_token": "",
  "user_id": "user-1",
  "client_id": "",
  "principal_type": "",
  "principal_id": "",
  "tier_label": "SuperGrok+",
}
print(json.dumps(collector.collect_limits(login, False)))
PY
}

open_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=3)).isoformat())')
past_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=3)).isoformat())')
cache=$(jq -nc --arg open "$open_at" --arg past "$past_at" '{
  fetchedAtMs: 1,
  limits: [
    { label: "Weekly (7-day)", percent: 0.11, resetsAt: $open },
    { label: "Grok Build", percent: 0.31, resetsAt: $past }
  ]
}')

expired=$(collect_limits "token" 1000 "$cache")
[[ $(jq -r '.usageStatusText' <<<"$expired") == "Sign-in expired" ]] ||
  fail "Grok collector reports an expired sign-in" "$expired"
[[ $(jq -r '.authHelpText' <<<"$expired") == *"grok login"* ]] ||
  fail "Grok collector says how to refresh an expired sign-in" "$expired"
[[ $(jq -c '[.limits[].label]' <<<"$expired") == '["Weekly (7-day)"]' ]] ||
  fail "Grok collector keeps only cached windows that have not reset" "$expired"
pass "Grok collector reports an expired sign-in instead of hiding the section"

signed_out=$(collect_limits "" 0 "$cache")
[[ $(jq -r '.usageStatusText' <<<"$signed_out") == "Waiting for auth" ]] ||
  fail "Grok collector still reports a missing token" "$signed_out"
[[ $(jq -c '[.limits[].label]' <<<"$signed_out") == '["Weekly (7-day)"]' ]] ||
  fail "Grok collector serves open cached windows without a token" "$signed_out"
pass "Grok collector serves open cached windows without a token"

unreachable=$(collect_limits "token" 0 "$cache")
[[ $(jq -c '[.limits[].label]' <<<"$unreachable") == '["Weekly (7-day)"]' ]] ||
  fail "Grok collector falls back to cache when the probe cannot connect" "$unreachable"
[[ $(jq -r '.retryAdvised' <<<"$unreachable") == "true" ]] ||
  fail "Grok collector advises a retry after a transport failure" "$unreachable"
pass "Grok collector falls back to cache when the probe cannot connect"

probe_with_cache() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-grok" FORCE="$1" CACHED="$2" PAYLOAD="$3" \
    XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, time

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

cache = collector.cache_root() / "grok-limits.json"
cached = json.loads(os.environ["CACHED"])
cached["fetchedAtMs"] = round(time.time() * 1000)
cache.write_text(json.dumps(cached), encoding="utf-8")

probes = []

def urlopen(request, timeout=None):
  probes.append(str(request.full_url))
  return io.BytesIO(os.environ["PAYLOAD"].encode())

collector.urllib.request.urlopen = urlopen
login = {
  "access_token": "token",
  "expires_at_ms": 0,
  "refresh_token": "",
  "user_id": "user-1",
  "client_id": "",
  "principal_type": "",
  "principal_id": "",
  "tier_label": "SuperGrok+",
}
result = collector.collect_limits(login, os.environ["FORCE"] == "true")
result["_probes"] = probes
print(json.dumps(result))
PY
}

fresh=$(jq -nc --arg open "$open_at" '{
  limits: [{ label: "Weekly (7-day)", percent: 0.1, resetsAt: $open }]
}')
payload='{"config":{"creditUsagePercent":40,"currentPeriod":{"type":"USAGE_PERIOD_TYPE_WEEKLY","end":"2030-01-08T00:00:00Z"}}}'

reused=$(probe_with_cache false "$fresh" "$payload")
[[ $(jq -c '._probes' <<<"$reused") == "[]" ]] ||
  fail "Grok collector reuses a seconds-old limits probe" "$reused"
[[ $(jq -r '.limits[0].percent' <<<"$reused") == "0.1" ]] ||
  fail "Grok collector serves the cached weekly percent during the reuse window" "$reused"
pass "Grok collector reuses a seconds-old limits probe"

forced=$(probe_with_cache true "$fresh" "$payload")
[[ $(jq -c '._probes' <<<"$forced") == '["https://cli-chat-proxy.grok.com/v1/billing?format=credits"]' ]] ||
  fail "Grok collector --force re-probes the billing endpoint" "$forced"
[[ $(jq -r '.limits[0].percent' <<<"$forced") == "0.4" ]] ||
  fail "Grok collector --force stores the fresh weekly percent" "$forced"
pass "Grok collector --force re-probes the billing endpoint"
