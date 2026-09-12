#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3
require_command sqlite3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

data="$TEST_HOME/.gemini/antigravity-cli"
mkdir -p "$data" "$TEST_HOME/bin" "$TEST_HOME/.cache"

# No agy and no local history: still a valid hidden-by-default record.
no_agy=$(
  HOME="$TEST_HOME" PATH="/usr/bin:/bin" XDG_CACHE_HOME="$TEST_HOME/.cache" \
    ANTIGRAVITY_DATA_DIR="$data" "$ROOT/bin/omarchy-agent-usage-antigravity"
)

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.hasPromptStats | tostring)' <<<"$no_agy") == "antigravity:false:true" ]] ||
  fail "Antigravity collector prints a valid record without agy" "$no_agy"
pass "Antigravity collector prints a valid record without agy"

now_ms=$(($(date +%s) * 1000))
cat >"$data/history.jsonl" <<EOF
{"display":"hello","timestamp":$now_ms,"workspace":"/tmp"}
{"display":"again","timestamp":$now_ms,"workspace":"/tmp"}
EOF

sqlite3 "$data/conversation_summaries.db" <<'SQL'
CREATE TABLE conversation_summaries (
  conversation_id text PRIMARY KEY,
  title text NOT NULL DEFAULT "",
  preview text NOT NULL DEFAULT "",
  step_count integer NOT NULL DEFAULT 0,
  last_modified_time datetime NOT NULL,
  workspace_uris text NOT NULL,
  status text NOT NULL DEFAULT "",
  source text NOT NULL DEFAULT "",
  project_id text NOT NULL DEFAULT "",
  agent_name text NOT NULL DEFAULT "",
  parent_conversation_id text NOT NULL DEFAULT "",
  nesting_depth integer NOT NULL DEFAULT 0,
  battle_id text NOT NULL DEFAULT "",
  winning_conversation_id text NOT NULL DEFAULT "",
  not_fully_idle numeric NOT NULL DEFAULT false,
  killed numeric NOT NULL DEFAULT false,
  last_user_input_time datetime NOT NULL,
  last_user_input_step_index integer NOT NULL DEFAULT -1,
  app_data_dir text NOT NULL DEFAULT "",
  raw_summary blob
);
INSERT INTO conversation_summaries(conversation_id, last_modified_time, last_user_input_time, workspace_uris)
VALUES ('conv-1', 0, 0, '');
SQL
# last_modified_time is ms in the collector; 0 still counts as a session.

cat >"$TEST_HOME/bin/agy" <<'EOF'
#!/bin/bash
python3 - <<'PY'
import json
print(json.dumps({
  "command": {
    "name": "usage",
    "data": {
      "groups": [
        {
          "name": "Gemini Models",
          "buckets": [
            {"window": "weekly", "remaining_fraction": 0.9, "reset_time": "2026-09-10T20:00:00Z"},
            {"window": "5h", "remaining_fraction": 1, "reset_time": "2026-09-06T04:00:00Z"}
          ]
        },
        {
          "name": "Claude and GPT models",
          "buckets": [
            {"window": "weekly", "remaining_fraction": 1, "reset_time": "2026-09-12T23:00:00Z"}
          ]
        }
      ]
    }
  }
}))
PY
EOF
chmod +x "$TEST_HOME/bin/agy"

result=$(
  HOME="$TEST_HOME" PATH="$TEST_HOME/bin:/usr/bin:/bin" XDG_CACHE_HOME="$TEST_HOME/.cache" \
    ANTIGRAVITY_DATA_DIR="$data" "$ROOT/bin/omarchy-agent-usage-antigravity" --force
)

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.todayPrompts | tostring) + ":" + (.totalSessions | tostring)' <<<"$result") == "antigravity:true:2:1" ]] ||
  fail "Antigravity collector counts local prompts and sessions" "$result"
pass "Antigravity collector counts local prompts and sessions"

[[ $(jq -c '[.limits[].title, (.limits[].percent * 1000 | round / 1000)]' <<<"$result") == '["Gemini Weekly","Gemini Session","Claude / GPT Weekly",0.1,0,0]' ]] ||
  fail "Antigravity collector inverts remaining_fraction to percent used" "$result"
pass "Antigravity collector inverts remaining_fraction to percent used"

cached=$(
  HOME="$TEST_HOME" PATH="/usr/bin:/bin" XDG_CACHE_HOME="$TEST_HOME/.cache" \
    ANTIGRAVITY_DATA_DIR="$data" "$ROOT/bin/omarchy-agent-usage-antigravity" --limits-only
)

[[ $(jq -r '.limits | length' <<<"$cached") == "3" ]] ||
  fail "Antigravity collector reuses a fresh limits cache on --limits-only" "$cached"
pass "Antigravity collector reuses a fresh limits cache on --limits-only"
