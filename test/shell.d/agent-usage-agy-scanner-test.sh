#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

AGY_DIR="$TEST_HOME/.gemini/antigravity-cli"
mkdir -p "$AGY_DIR/brain/test-conv/.system_generated/logs" "$TEST_HOME/bin"

# Mock secret-tool to simulate a signed-in keyring entry without a token, so
# nothing is asked of Google.
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
timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cat >"$AGY_DIR/history.jsonl" <<EOF
{"timestamp":"$timestamp","conversation_id":"test-conv","prompt":"Hello world"}
EOF

cat >"$AGY_DIR/brain/test-conv/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":0,"type":"USER_INPUT","content":"Hello world","created_at":"$timestamp"}
{"step_index":1,"type":"PLANNER_RESPONSE","created_at":"$timestamp","model":"gemini-3.8-flash-high","usage":{"prompt_token_count":120,"candidates_token_count":45}}
EOF

collect() {
  HOME="$TEST_HOME" AGY_DIR="$AGY_DIR" XDG_CACHE_HOME="$TEST_HOME/.cache" PATH="$TEST_HOME/bin:$PATH" \
    "$ROOT/bin/omarchy-agent-usage-agy" --force
}

result=$(collect)

[[ $(jq -r '.id' <<<"$result") == "agy" ]] ||
  fail "Antigravity collector identifies itself as the default agent does" "$result"
pass "Antigravity collector identifies itself as the default agent does"

[[ $(jq -r '.name' <<<"$result") == "Antigravity" ]] ||
  fail "Antigravity collector names itself" "$result"
pass "Antigravity collector names itself"

[[ $(jq -r '.tierLabel' <<<"$result") == "" ]] ||
  fail "Antigravity collector invents no plan before Google names one" "$result"
pass "Antigravity collector invents no plan before Google names one"

[[ $(jq -r '.todayPrompts' <<<"$result") == "1" ]] ||
  fail "Antigravity collector counts today prompts" "$result"
pass "Antigravity collector counts today prompts"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "165" ]] ||
  fail "Antigravity collector counts only the tokens transcripts report" "$result"
pass "Antigravity collector counts only the tokens transcripts report"

[[ $(jq -c '.modelUsage["gemini-3.8-flash-high"] | {inputTokens, outputTokens}' <<<"$result") == '{"inputTokens":120,"outputTokens":45}' ]] ||
  fail "Antigravity collector parses input and output tokens" "$result"
pass "Antigravity collector parses input and output tokens"

[[ $(jq -c '{limits, usageStatusText}' <<<"$result") == '{"limits":[],"usageStatusText":"Waiting for auth"}' ]] ||
  fail "Antigravity collector makes up no limits from prompt counts" "$result"
pass "Antigravity collector makes up no limits from prompt counts"

# Nobody signed in and no history: a record the panel skips.
cat >"$TEST_HOME/bin/secret-tool" <<'EOF'
#!/bin/bash
exit 1
EOF
rm -rf "$AGY_DIR"
result=$(collect)

[[ $(jq -c '{ready, tierLabel, limits, totalPrompts, totalSessions, activeDays, modelUsage}' <<<"$result") == '{"ready":false,"tierLabel":"","limits":[],"totalPrompts":0,"totalSessions":0,"activeDays":0,"modelUsage":{}}' ]] ||
  fail "Antigravity collector prints an empty record without Antigravity" "$result"
pass "Antigravity collector prints an empty record without Antigravity"
