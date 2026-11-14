#!/bin/bash

# The Antigravity collector's local stats from agy's own home: prompts from
# history.jsonl, conversations from it and the conversation summaries, and
# tokens from each transcript in both shapes agy writes. The unused-machine
# record is held centrally by the partition test, and the scan cache by the
# contract checks in agy-limits.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

home=$(new_home)
agy_dir="$home/.gemini/antigravity-cli"
mkdir -p "$agy_dir/brain/test-conv/.system_generated/logs"

# A keyring entry signed in without a token, so nothing is asked of Google.
stub_cli "$home" secret-tool >/dev/null <<'EOF'
if [[ "$*" == *"lookup service gemini username antigravity"* ]]; then
  echo '{"auth_method":"consumer","id_token":"header.eyJlbWFpbCI6InRlc3RAZ21haWwuY29tIn0.signature"}'
  exit 0
fi
exit 1
EOF

timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cat >"$agy_dir/history.jsonl" <<EOF
{"timestamp":"$timestamp","conversation_id":"test-conv","prompt":"Hello world"}
EOF
cat >"$agy_dir/brain/test-conv/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":0,"type":"USER_INPUT","content":"Hello world","created_at":"$timestamp"}
{"step_index":1,"type":"PLANNER_RESPONSE","created_at":"$timestamp","model":"gemini-3.8-flash-high","usage":{"prompt_token_count":120,"candidates_token_count":45}}
EOF

record=$(run_collector "$home" agy)
expect_jq "Antigravity collector counts today's prompts and only the tokens transcripts report, inventing no plan or limits" \
  '{name, tierLabel, todayPrompts, todayTotalTokens, limits, usageStatusText, model: (.modelUsage["gemini-3.8-flash-high"] | {inputTokens, outputTokens})}' \
  '{"name":"Antigravity","tierLabel":"","todayPrompts":1,"todayTotalTokens":165,"limits":[],"usageStatusText":"Waiting for auth","model":{"inputTokens":120,"outputTokens":45}}' "$record"

# Transcripts in both shapes agy writes: Gemini's counts nested under usage,
# with the cached part inside the prompt count, and the four flat counts on
# the step. A "Model Selection" step names the model the following steps run
# on, and a step that names its own model id wins over the one carried from
# the step before.
mkdir -p "$agy_dir/brain/flat-conv/.system_generated/logs"
cat >"$agy_dir/brain/test-conv/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":0,"type":"USER_INPUT","content":"Hello world","created_at":"$timestamp"}
{"step_index":1,"type":"PLANNER_RESPONSE","created_at":"$timestamp","model":"gemini-3.8-flash-high","usage":{"prompt_token_count":120,"cached_content_token_count":20,"candidates_token_count":45,"thoughts_token_count":5}}
{"step_index":2,"type":"PLANNER_RESPONSE","created_at":"$timestamp","model":"gemini-3.8-flash-high","usage":{"prompt_token_count":"lots","candidates_token_count":true}}
EOF
cat >"$agy_dir/brain/flat-conv/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":0,"type":"SYSTEM","content":"The user changed \`Model Selection\` from Gemini 3.8 Flash to Claude Sonnet 4.6 (Thinking). No need to mention it.","created_at":"$timestamp"}
{"step_index":1,"type":"PLANNER_RESPONSE","created_at":"$timestamp","input_tokens":10,"output_tokens":4,"cache_read_tokens":100,"cache_write_tokens":6}
{"step_index":2,"type":"PLANNER_RESPONSE","created_at":"$timestamp","model_name":"Gemini 3.8 Pro","input_tokens":"NaN","output_tokens":-3,"cache_read_tokens":1e400}
{"step_index":3,"type":"PLANNER_RESPONSE","created_at":"2020-02-02T12:00:00Z","model_id":"gemini-3.9-ultra","input_tokens":7,"output_tokens":1}
EOF

record=$(run_collector "$home" agy)
expect_jq "Antigravity collector splits the cached part out of Gemini's prompt count" '.modelUsage["gemini-3.8-flash-high"]' \
  '{"inputTokens":100,"outputTokens":50,"cacheReadInputTokens":20,"cacheCreationInputTokens":0}' "$record"
expect_jq "Antigravity collector files flat step counts under the selected model" '.modelUsage["claude-sonnet-4.6-thinking"]' \
  '{"inputTokens":10,"outputTokens":4,"cacheReadInputTokens":100,"cacheCreationInputTokens":6}' "$record"
expect_jq "Antigravity collector takes a step's own model and skips counts it can't read" \
  '[.modelUsage["gemini-3.9-ultra"].inputTokens, (.modelUsage | has("gemini-3.8-pro")), (.modelUsage | has("unknown")), .todayTotalTokens]' '[7,false,false,290]' "$record"
# The step's day is its local one, in the zone the test runs in.
old_day=$(date -d "2020-02-02T12:00:00Z" +%F)
expect_jq "Antigravity collector counts a transcript's days as active" ".activeDates | index(\"$old_day\") != null" 'true' "$record"

# A subagent's conversation belongs to the one that spawned it, and
# history may key a prompt by sessionId.
rm -rf "$agy_dir/brain"
cat >"$agy_dir/history.jsonl" <<EOF
{"timestamp":"$timestamp","conversation_id":"parent","prompt":"one"}
{"timestamp":"$timestamp","sessionId":"child","prompt":"two"}
{"timestamp":"$timestamp","sessionId":"other","prompt":"three"}
EOF
python3 - "$agy_dir/conversation_summaries.db" "$timestamp" <<'PY'
import sqlite3, sys
db = sqlite3.connect(sys.argv[1])
db.execute("CREATE TABLE conversation_summaries (conversation_id TEXT, last_modified_time TEXT, parent_conversation_id TEXT)")
db.executemany("INSERT INTO conversation_summaries VALUES (?, ?, ?)", [
  ("parent", sys.argv[2], ""), ("child", sys.argv[2], "parent"), ("grandchild", sys.argv[2], "child"), ("other", sys.argv[2], None)])
db.commit()
PY
record=$(run_collector "$home" agy)
expect_jq "Antigravity collector counts a subagent's conversation as part of its parent" '{totalPrompts, totalSessions, todaySessions}' \
  '{"totalPrompts":3,"totalSessions":2,"todaySessions":2}' "$record"
