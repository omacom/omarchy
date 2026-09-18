#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

AGY_DIR="$TEST_HOME/.gemini/antigravity-cli"
mkdir -p "$AGY_DIR/brain/test-conv/.system_generated/logs" "$TEST_HOME/bin"

# Mock secret-tool to simulate authenticated state
cat >"$TEST_HOME/bin/secret-tool" <<'EOF'
#!/bin/bash
if [[ "$*" == *"lookup service gemini username antigravity"* ]]; then
  echo '{"auth_method":"consumer","id_token":"header.eyJlbWFpbCI6InRlc3RAZ21haWwuY29tIn0.signature"}'
  exit 0
fi
exit 1
EOF
chmod +x "$TEST_HOME/bin/secret-tool"

# Write mock history and transcript
now_date=$(date +%Y-%m-%d)
timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cat >"$AGY_DIR/history.jsonl" <<EOF
{"timestamp":"$timestamp","conversation_id":"test-conv","prompt":"Hello world"}
EOF

cat >"$AGY_DIR/brain/test-conv/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":0,"type":"USER_INPUT","content":"Hello world","created_at":"$timestamp"}
{"step_index":1,"type":"PLANNER_RESPONSE","created_at":"$timestamp","model":"gemini-3.8-flash-high","usage":{"prompt_token_count":120,"candidates_token_count":45}}
EOF

result=$(HOME="$TEST_HOME" AGY_DIR="$AGY_DIR" XDG_CACHE_HOME="$TEST_HOME/.cache" PATH="$TEST_HOME/bin:$PATH" \
  "$ROOT/bin/omarchy-agent-usage-antigravity" --force)

[[ $(jq -r '.id' <<<"$result") == "antigravity" ]] ||
  fail "Antigravity collector identifies itself" "$result"
pass "Antigravity collector identifies itself"

[[ $(jq -r '.name' <<<"$result") == "Antigravity" ]] ||
  fail "Antigravity collector names itself" "$result"
pass "Antigravity collector names itself"

[[ $(jq -r '.tierLabel' <<<"$result") == "Pro" ]] ||
  fail "Antigravity collector reports Pro tier by default when authenticated" "$result"
pass "Antigravity collector reports Pro tier by default when authenticated"

[[ $(jq -r '.tierLabel' <<<"$result") != $(jq -r '.modelUsage | keys[0]' <<<"$result") ]] ||
  fail "Antigravity collector tierLabel does not match model name" "$result"
pass "Antigravity collector tierLabel does not match model name"

[[ $(jq -r '.todayPrompts' <<<"$result") == "1" ]] ||
  fail "Antigravity collector counts today prompts" "$result"
pass "Antigravity collector counts today prompts"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "167" ]] ||
  fail "Antigravity collector counts today tokens" "$result"
pass "Antigravity collector counts today tokens"

[[ $(jq -r '.modelUsage["gemini-3.8-flash-high"].inputTokens' <<<"$result") == "122" ]] ||
  fail "Antigravity collector parses input tokens" "$result"
pass "Antigravity collector parses input tokens"

[[ $(jq -r '.modelUsage["gemini-3.8-flash-high"].outputTokens' <<<"$result") == "45" ]] ||
  fail "Antigravity collector parses output tokens" "$result"
pass "Antigravity collector parses output tokens"

[[ $(jq -r '.limits | length' <<<"$result") == "2" ]] ||
  fail "Antigravity collector produces session and weekly limits" "$result"
pass "Antigravity collector produces session and weekly limits"

# Test AGY_TIER environment override
env_tier_result=$(HOME="$TEST_HOME" AGY_DIR="$AGY_DIR" AGY_TIER="Ultra" XDG_CACHE_HOME="$TEST_HOME/.cache" PATH="$TEST_HOME/bin:$PATH" \
  "$ROOT/bin/omarchy-agent-usage-antigravity" --force)

[[ $(jq -r '.tierLabel' <<<"$env_tier_result") == "Ultra" ]] ||
  fail "Antigravity collector honors AGY_TIER override" "$env_tier_result"
pass "Antigravity collector honors AGY_TIER override"

# Test config file override
mkdir -p "$TEST_HOME/.config/omarchy/agents"
cat >"$TEST_HOME/.config/omarchy/agents/antigravity.json" <<'EOF'
{
  "tier": "Enterprise"
}
EOF

cfg_tier_result=$(HOME="$TEST_HOME" AGY_DIR="$AGY_DIR" XDG_CACHE_HOME="$TEST_HOME/.cache" PATH="$TEST_HOME/bin:$PATH" \
  "$ROOT/bin/omarchy-agent-usage-antigravity" --force)

[[ $(jq -r '.tierLabel' <<<"$cfg_tier_result") == "Enterprise" ]] ||
  fail "Antigravity collector honors config file tier override" "$cfg_tier_result"
pass "Antigravity collector honors config file tier override"

# Test unauthenticated state
cat >"$TEST_HOME/bin/secret-tool" <<'EOF'
#!/bin/bash
exit 1
EOF

unauth_result=$(HOME="$TEST_HOME" AGY_DIR="$AGY_DIR" XDG_CACHE_HOME="$TEST_HOME/.cache" PATH="$TEST_HOME/bin:$PATH" \
  "$ROOT/bin/omarchy-agent-usage-antigravity" --force)

[[ $(jq -r '.tierLabel' <<<"$unauth_result") == "" ]] ||
  fail "Antigravity collector has empty tier when unauthenticated" "$unauth_result"
pass "Antigravity collector has empty tier when unauthenticated"

[[ $(jq -r '.usageStatusText' <<<"$unauth_result") == "Sign in to see limits" ]] ||
  fail "Antigravity collector indicates sign in status when unauthenticated" "$unauth_result"
pass "Antigravity collector indicates sign in status when unauthenticated"
