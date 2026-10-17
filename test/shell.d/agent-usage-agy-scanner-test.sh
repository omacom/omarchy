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

# Transcripts in both shapes agy writes: Gemini's counts nested under usage,
# with the cached part inside the prompt count, and the four flat counts on
# the step. A "Model Selection" step names the model the following steps run
# on, and a step that names its own model id wins.
mkdir -p "$AGY_DIR/brain/flat-conv/.system_generated/logs"
cat >"$AGY_DIR/brain/test-conv/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":0,"type":"USER_INPUT","content":"Hello world","created_at":"$timestamp"}
{"step_index":1,"type":"PLANNER_RESPONSE","created_at":"$timestamp","model":"gemini-3.8-flash-high","usage":{"prompt_token_count":120,"cached_content_token_count":20,"candidates_token_count":45,"thoughts_token_count":5}}
{"step_index":2,"type":"PLANNER_RESPONSE","created_at":"$timestamp","model":"gemini-3.8-flash-high","usage":{"prompt_token_count":"lots","candidates_token_count":true}}
EOF
cat >"$AGY_DIR/brain/flat-conv/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":0,"type":"SYSTEM","content":"The user changed \`Model Selection\` from Gemini 3.8 Flash to Claude Sonnet 4.6 (Thinking). No need to mention it.","created_at":"$timestamp"}
{"step_index":1,"type":"PLANNER_RESPONSE","created_at":"$timestamp","input_tokens":10,"output_tokens":4,"cache_read_tokens":100,"cache_write_tokens":6}
{"step_index":2,"type":"PLANNER_RESPONSE","created_at":"$timestamp","model_name":"Gemini 3.8 Pro","input_tokens":"NaN","output_tokens":-3,"cache_read_tokens":1e400}
{"step_index":3,"type":"PLANNER_RESPONSE","created_at":"2020-02-02T12:00:00Z","model_id":"gemini-3.8-pro","input_tokens":7,"output_tokens":1}
EOF

result=$(collect)

[[ $(jq -c '.modelUsage["gemini-3.8-flash-high"]' <<<"$result") == '{"inputTokens":100,"outputTokens":50,"cacheReadInputTokens":20,"cacheCreationInputTokens":0}' ]] ||
  fail "Antigravity collector splits the cached part out of Gemini's prompt count" "$result"
pass "Antigravity collector splits the cached part out of Gemini's prompt count"

[[ $(jq -c '.modelUsage["claude-sonnet-4.6-thinking"]' <<<"$result") == '{"inputTokens":10,"outputTokens":4,"cacheReadInputTokens":100,"cacheCreationInputTokens":6}' ]] ||
  fail "Antigravity collector files flat step counts under the selected model" "$result"
pass "Antigravity collector files flat step counts under the selected model"

[[ $(jq -c '[.modelUsage["gemini-3.8-pro"].inputTokens, (.modelUsage | has("unknown")), .todayTotalTokens]' <<<"$result") == '[7,false,290]' ]] ||
  fail "Antigravity collector takes a step's own model and skips counts it can't read" "$result"
pass "Antigravity collector takes a step's own model and skips counts it can't read"

[[ $(jq -c '.activeDates | index("2020-02-02") != null' <<<"$result") == "true" ]] ||
  fail "Antigravity collector counts a transcript's days as active" "$result"
pass "Antigravity collector counts a transcript's days as active"

# A subagent's conversation belongs to the one that spawned it, and
# history may key a prompt by sessionId.
rm -rf "$AGY_DIR/brain"
cat >"$AGY_DIR/history.jsonl" <<EOF
{"timestamp":"$timestamp","conversation_id":"parent","prompt":"one"}
{"timestamp":"$timestamp","sessionId":"child","prompt":"two"}
{"timestamp":"$timestamp","sessionId":"other","prompt":"three"}
EOF
python3 - "$AGY_DIR/conversation_summaries.db" "$timestamp" <<'PY'
import sqlite3, sys
db = sqlite3.connect(sys.argv[1])
db.execute("CREATE TABLE conversation_summaries (conversation_id TEXT, last_modified_time TEXT, parent_conversation_id TEXT)")
db.executemany("INSERT INTO conversation_summaries VALUES (?, ?, ?)", [
  ("parent", sys.argv[2], ""), ("child", sys.argv[2], "parent"), ("grandchild", sys.argv[2], "child"), ("other", sys.argv[2], None)])
db.commit()
PY
result=$(collect)
[[ $(jq -c '{totalPrompts, totalSessions, todaySessions}' <<<"$result") == '{"totalPrompts":3,"totalSessions":2,"todaySessions":2}' ]] ||
  fail "Antigravity collector counts a subagent's conversation as part of its parent" "$result"
pass "Antigravity collector counts a subagent's conversation as part of its parent"

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
