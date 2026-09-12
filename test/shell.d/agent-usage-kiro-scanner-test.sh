#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.kiro/sessions/cli" "$TEST_HOME/.local/share" "$TEST_HOME/.cache"

now="$(date +%s)"
cat >"$TEST_HOME/.kiro/sessions/cli/test-session.json" <<EOF
{"session_id":"test-session","cwd":"/tmp/proj","created_at":"2026-09-12T10:00:00Z","updated_at":"2026-09-12T12:00:00Z","title":"test","session_state":{"version":"v1","conversation_metadata":{"user_turn_metadatas":[{"input_token_count":1000,"output_token_count":500,"end_timestamp":$now},{"input_token_count":2000,"output_token_count":1000,"end_timestamp":$now}]},"rts_model_state":{"conversation_id":"test-session","model_info":{"model_id":"claude-sonnet-4","context_window_tokens":200000},"context_usage_percentage":10}}}
EOF

result=$(HOME="$TEST_HOME" XDG_DATA_HOME="$TEST_HOME/.local/share" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-kiro")

[[ $(jq -r '.id' <<<"$result") == "kiro" ]] ||
  fail "Kiro collector identifies itself" "$result"
pass "Kiro collector identifies itself"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "4500" ]] ||
  fail "Kiro collector sums turn token counts" "$result"
pass "Kiro collector sums turn token counts"

[[ $(jq -r '.totalPrompts' <<<"$result") == "2" ]] ||
  fail "Kiro collector counts each turn once" "$result"
pass "Kiro collector counts each turn once"

[[ $(jq -c '.modelUsage["claude-sonnet-4"]' <<<"$result") == '{"cacheCreationInputTokens":0,"cacheReadInputTokens":0,"inputTokens":3000,"outputTokens":1500}' ]] ||
  fail "Kiro collector attributes tokens to the session model" "$result"
pass "Kiro collector attributes tokens to the session model"

# No kiro-cli credentials in the fake HOME, so no limits probe runs and the
# record degrades to local stats only without touching the network.
[[ $(jq -r '.limits|length' <<<"$result") == "0" ]] ||
  fail "Kiro collector reports no limits without credentials" "$result"
pass "Kiro collector reports no limits without credentials"

[[ $(jq -r '.usageStatusText' <<<"$result") == "Waiting for auth" ]] ||
  fail "Kiro collector says it is waiting for auth" "$result"
pass "Kiro collector says it is waiting for auth"
