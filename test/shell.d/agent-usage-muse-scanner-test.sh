#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

day_path=$(date +%Y/%m/%d)
mkdir -p "$TEST_HOME/.local/share/muse/sessions/$day_path/sess-1"

now_us=$(date +%s%6N)
session="$TEST_HOME/.local/share/muse/sessions/$day_path/sess-1/session.jsonl"
cat >"$session" <<EOF
{"recorded_at":$now_us,"payload":{"event":{"kind":"goal_usage_attribution","record":{"usage_id":"u-1","quantity":{"input_tokens":100,"output_tokens":20}}}}}
{"recorded_at":$now_us,"payload":{"event":{"kind":"model_completed","model":"muse-test","usage":{"input_tokens":100,"output_tokens":20,"reasoning_tokens":5,"cache_read_tokens":60,"cache_write_tokens":7,"cached_tokens":0}}}}
{"recorded_at":$now_us,"payload":{"event":{"kind":"model_completed","model":{"model_id":"muse-test","provider_id":"meta"},"usage":{"input_tokens":50,"output_tokens":10,"reasoning_tokens":0,"cache_read_tokens":0,"cache_write_tokens":0,"cached_tokens":0}}}}
{"recorded_at":$now_us,"payload":{"event":{"kind":"model_completed","model":"other-model","usage":{"input_tokens":30,"output_tokens":5}}}}
not json at all
EOF

result=$(XDG_DATA_HOME="$TEST_HOME/.local/share" "$ROOT/bin/omarchy-agent-usage-muse")

[[ $(jq -r '.id + "/" + (.limits|tostring)' <<<"$result") == 'muse/[]' ]] ||
  fail "Muse collector identifies itself with an empty limits list" "$result"
pass "Muse collector identifies itself with an empty limits list"

[[ $(jq -r '.totalPrompts' <<<"$result") == "3" ]] ||
  fail "Muse collector counts each model response once" "$result"
pass "Muse collector counts each model response once"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "220" ]] ||
  fail "Muse collector totals input plus output plus reasoning tokens" "$result"
pass "Muse collector totals input plus output plus reasoning tokens"

[[ $(jq -c '.modelUsage["muse-test"]' <<<"$result") == '{"inputTokens":150,"outputTokens":35,"cacheReadInputTokens":60,"cacheCreationInputTokens":7}' ]] ||
  fail "Muse collector merges string and object model names without double-counting" "$result"
pass "Muse collector merges string and object model names without double-counting"

[[ $(jq -r '.totalSessions' <<<"$result") == "1" ]] ||
  fail "Muse collector counts sessions" "$result"
pass "Muse collector counts sessions"
