#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

COLLECTOR="$ROOT/bin/omarchy-agent-usage-antigravity"

# probe_antigravity reaches Google's Cloud Code endpoints, so the readers that
# interpret the answers are exercised with recorded payloads standing in.

test_tier() {
  COLLECTOR="$COLLECTOR" PAYLOAD="$1" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

payload = json.loads(os.environ["PAYLOAD"])
print(collector.extract_tier(payload))
PY
}

ultra_tier=$(test_tier '{
  "currentTier": { "id": "free-tier", "name": "Antigravity" },
  "paidTier": { "id": "g1-ultra-tier", "name": "Google AI Ultra" }
}')
[[ $ultra_tier == "Ultra" ]] ||
  fail "Antigravity collector extracts Ultra tier from paidTier" "$ultra_tier"
pass "Antigravity collector extracts Ultra tier from paidTier"

pro_tier=$(test_tier '{
  "currentTier": { "id": "free-tier", "name": "Antigravity" },
  "paidTier": { "id": "g1-pro-tier", "name": "Google AI Pro" }
}')
[[ $pro_tier == "Pro" ]] ||
  fail "Antigravity collector extracts Pro tier from paidTier" "$pro_tier"
pass "Antigravity collector extracts Pro tier from paidTier"

free_tier=$(test_tier '{
  "currentTier": { "id": "free-tier", "name": "Antigravity" }
}')
[[ $free_tier == "Free" ]] ||
  fail "Antigravity collector extracts Free tier when no paidTier" "$free_tier"
pass "Antigravity collector extracts Free tier when no paidTier"

# Test quota extraction
test_limits() {
  COLLECTOR="$COLLECTOR" PAYLOAD="$1" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

payload = json.loads(os.environ["PAYLOAD"])
print(json.dumps(collector.extract_limits(payload)))
PY
}

quota_payload='{
  "groups": [
    {
      "displayName": "Gemini Models",
      "buckets": [
        {
          "bucketId": "gemini-weekly",
          "displayName": "Weekly Limit Remaining",
          "window": "weekly",
          "resetTime": "2026-09-17T18:19:42Z",
          "remainingFraction": 0.95
        },
        {
          "bucketId": "gemini-5h",
          "displayName": "Five Hour Limit Remaining",
          "window": "5h",
          "resetTime": "2026-09-15T19:31:46Z",
          "remainingFraction": 0.90
        }
      ]
    },
    {
      "displayName": "Claude and GPT models",
      "buckets": [
        {
          "bucketId": "3p-weekly",
          "displayName": "Weekly Limit Remaining",
          "window": "weekly",
          "resetTime": "2026-09-18T12:56:14Z",
          "remainingFraction": 0.98
        },
        {
          "bucketId": "3p-5h",
          "displayName": "Five Hour Limit Remaining",
          "window": "5h",
          "resetTime": "2026-09-15T22:16:22Z",
          "remainingFraction": 1.0
        }
      ]
    }
  ]
}'

limits=$(test_limits "$quota_payload")

[[ $(jq -r '.[0].label' <<<"$limits") == "Session (5-hour)" ]] ||
  fail "Antigravity collector places Session window first" "$limits"
pass "Antigravity collector places Session window first"

[[ $(jq -r '.[0].percent' <<<"$limits") == "0.1" ]] ||
  fail "Antigravity collector calculates used percentage from remainingFraction" "$limits"
pass "Antigravity collector calculates used percentage from remainingFraction"

[[ $(jq -r '.[1].label' <<<"$limits") == "Weekly (7-day)" ]] ||
  fail "Antigravity collector places Weekly window second" "$limits"
pass "Antigravity collector places Weekly window second"

[[ $(jq -r '.[1].percent' <<<"$limits") == "0.05" ]] ||
  fail "Antigravity collector calculates weekly used percentage" "$limits"
pass "Antigravity collector calculates weekly used percentage"

[[ $(jq -r '.[2].title' <<<"$limits") == "Claude/GPT Weekly" ]] ||
  fail "Antigravity collector includes used scoped 3P limits" "$limits"
pass "Antigravity collector includes used scoped 3P limits"

[[ $(jq -r '.[2].percent' <<<"$limits") == "0.02" ]] ||
  fail "Antigravity collector calculates 3P used percentage" "$limits"
pass "Antigravity collector calculates 3P used percentage"

[[ $(jq -r 'length' <<<"$limits") == "3" ]] ||
  fail "Antigravity collector omits unused 3P session limit" "$limits"
pass "Antigravity collector omits unused 3P session limit"
