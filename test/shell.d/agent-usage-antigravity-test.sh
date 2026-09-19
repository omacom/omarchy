#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# Without history or credentials, the collector must print a valid fallback record
fallback=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" PATH="/nonexistent" "$ROOT/bin/omarchy-agent-usage-antigravity")

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.todayPrompts | tostring)' <<<"$fallback") == "antigravity:false:0" ]] ||
  fail "Antigravity collector prints a valid record when offline and uninitialized" "$fallback"
pass "Antigravity collector prints a valid record when offline and uninitialized"

[[ $(jq -r '.schemaVersion' <<<"$fallback") == "1" ]] ||
  fail "Antigravity collector declares schemaVersion 1" "$fallback"
pass "Antigravity collector declares schemaVersion 1"

[[ $(jq -r '.todayTotalTokens' <<<"$fallback") == "0" ]] ||
  fail "Antigravity fallback has 0 todayTotalTokens" "$fallback"
pass "Antigravity fallback has 0 todayTotalTokens"

# Create mock history.jsonl
mkdir -p "$TEST_HOME/.gemini/antigravity-cli"
now_ms=$(date +%s000)
yesterday_ms=$(( ( $(date +%s) - 86400 ) * 1000 ))

cat >"$TEST_HOME/.gemini/antigravity-cli/history.jsonl" <<JSONL
{"display":"hello","timestamp":$now_ms,"conversationId":"c1"}
{"display":"world","timestamp":$now_ms,"conversationId":"c1"}
{"display":"previous","timestamp":$yesterday_ms,"conversationId":"c2"}
JSONL

with_history=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" PATH="/nonexistent" "$ROOT/bin/omarchy-agent-usage-antigravity")

[[ $(jq -r '.todayPrompts' <<<"$with_history") == "2" ]] ||
  fail "Antigravity collector totals today's prompts" "$with_history"
pass "Antigravity collector totals today's prompts"

[[ $(jq -r '.totalPrompts' <<<"$with_history") == "3" ]] ||
  fail "Antigravity collector totals all prompts" "$with_history"
pass "Antigravity collector totals all prompts"

[[ $(jq -r '.activeDays' <<<"$with_history") == "2" ]] ||
  fail "Antigravity collector counts unique active days" "$with_history"
pass "Antigravity collector counts unique active days"

(( $(jq -r '.todayTotalTokens' <<<"$with_history") > 0 )) ||
  fail "Antigravity collector estimates tokens when history is present" "$with_history"
pass "Antigravity collector estimates tokens when history is present"

# Mock settings.json and brain transcripts
cat >"$TEST_HOME/.gemini/antigravity-cli/settings.json" <<JSON
{"model":"Gemini 3.8 Flash (High)"}
JSON

mkdir -p "$TEST_HOME/.gemini/antigravity-cli/brain/c1/.system_generated/logs"
today_iso=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat >"$TEST_HOME/.gemini/antigravity-cli/brain/c1/.system_generated/logs/transcript.jsonl" <<JSONL
{"step_index":0,"source":"USER_EXPLICIT","type":"USER_INPUT","created_at":"$today_iso","content":"echo test prompt with multiple words"}
{"step_index":1,"source":"MODEL","type":"PLANNER_RESPONSE","created_at":"$today_iso","content":"Here is a full explanation of the result","thinking":"reasoning step"}
JSONL

with_transcript=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" PATH="/nonexistent" "$ROOT/bin/omarchy-agent-usage-antigravity")

[[ $(jq -r '.tierLabel' <<<"$with_transcript") == "Gemini 3.8 Flash (High)" ]] ||
  fail "Antigravity collector reads dynamic model tier from settings" "$with_transcript"
pass "Antigravity collector reads dynamic model tier from settings"

(( $(jq -r '.todayTotalTokens' <<<"$with_transcript") > 0 )) ||
  fail "Antigravity collector calculates tokens from transcripts" "$with_transcript"
pass "Antigravity collector calculates tokens from transcripts"

(( $(jq -r '.modelUsage["gemini-3.8-flash"].inputTokens' <<<"$with_transcript") > 0 )) ||
  fail "Antigravity collector records input tokens by model" "$with_transcript"
pass "Antigravity collector records input tokens by model"

(( $(jq -r '.modelUsage["gemini-3.8-flash"].outputTokens' <<<"$with_transcript") > 0 )) ||
  fail "Antigravity collector records output tokens by model" "$with_transcript"
pass "Antigravity collector records output tokens by model"

# Test quota parser via Python (both text output and JSON output)
result=$(python3 - "$ROOT/bin/omarchy-agent-usage-antigravity" <<'PY'
import importlib.machinery
import importlib.util
import json
import sys
from pathlib import Path

collector_path = str(Path(sys.argv[1]))
loader = importlib.machinery.SourceFileLoader("antigravity_collector", collector_path)
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

# 1. Text output parsing
sample_output = """
Quota:
Gemini Models          Weekly Limit Remaining     90%   2026-09-13T15:29:40Z
Gemini Models          Five Hour Limit Remaining  60%   2026-09-06T20:29:40Z
Claude and GPT models  Weekly Limit Remaining     100%  2026-09-13T17:16:46Z
Claude and GPT models  Five Hour Limit Remaining  80%   2026-09-06T22:16:46Z
"""

limits = collector.parse_quota_output(sample_output)
assert len(limits) == 4
assert limits[0]["label"] == "Gemini Models Weekly"
assert limits[0]["title"] == "Gemini Weekly"
assert limits[0]["percent"] == 0.10
assert limits[0]["resetsAt"] == "2026-09-13T15:29:40Z"
assert limits[1]["label"] == "Gemini Models Session"
assert limits[1]["title"] == "Gemini Session"
assert limits[1]["percent"] == 0.40
assert limits[1]["resetsAt"] == "2026-09-06T20:29:40Z"
assert limits[3]["percent"] == 0.20

# 2. JSON output parsing
json_sample = """{
  "command": {
    "name": "usage",
    "data": {
      "groups": [
        {
          "name": "Gemini Models",
          "buckets": [
            {
              "id": "gemini-weekly",
              "name": "Weekly Limit Remaining",
              "window": "weekly",
              "remaining_fraction": 0.12,
              "reset_time": "2026-09-23T05:27:57Z"
            },
            {
              "id": "gemini-5h",
              "name": "Five Hour Limit Remaining",
              "window": "5h",
              "remaining_fraction": 0.98,
              "reset_time": "2026-09-19T11:50:31Z"
            }
          ]
        }
      ]
    }
  }
}"""

json_limits = collector.parse_quota_output(json_sample)
assert len(json_limits) == 2
assert json_limits[0]["label"] == "Gemini Models Weekly"
assert json_limits[0]["title"] == "Gemini Weekly"
assert json_limits[0]["percent"] == 0.88
assert json_limits[0]["resetsAt"] == "2026-09-23T05:27:57Z"
assert json_limits[1]["percent"] == 0.02

print(json.dumps({"ok": True, "limits": limits, "json_limits": json_limits}))
PY
)

[[ $(jq -r '.ok' <<<"$result") == "true" ]] ||
  fail "Antigravity quota parsing correctly extracts limits and resetsAt" "$result"
pass "Antigravity quota parsing correctly extracts limits and resetsAt"
