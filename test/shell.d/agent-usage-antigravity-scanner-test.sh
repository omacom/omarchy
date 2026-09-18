#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# --- 1. Empty / missing data directory ---------------------------------------

empty_out=$(HOME="$TEST_HOME" ANTIGRAVITY_DATA_DIR="$TEST_HOME/missing" \
  "$ROOT/bin/omarchy-agent-usage-antigravity")

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.totalPrompts | tostring)' <<<"$empty_out") == "antigravity:false:0" ]] ||
  fail "Antigravity collector prints a valid empty record without session data" "$empty_out"
pass "Antigravity collector prints a valid empty record without session data"

# --- 2. history.jsonl parsing & daily aggregation ----------------------------

data_dir="$TEST_HOME/.gemini/antigravity-cli"
mkdir -p "$data_dir"

today_epoch_ms=$(python3 -c 'import time; print(int(time.time() * 1000))')
yesterday_epoch_ms=$(python3 -c 'import time; print(int((time.time() - 86400) * 1000))')

cat >"$data_dir/history.jsonl" <<EOF
{"display":"First prompt","timestamp":$yesterday_epoch_ms,"workspace":"/home/user","conversationId":"conv-1"}
{"display":"Second prompt","timestamp":$today_epoch_ms,"workspace":"/home/user","conversationId":"conv-1"}
{"display":"Third prompt","timestamp":$today_epoch_ms,"workspace":"/home/user","conversationId":"conv-2"}
EOF

result=$(HOME="$TEST_HOME" ANTIGRAVITY_DATA_DIR="$data_dir" \
  "$ROOT/bin/omarchy-agent-usage-antigravity" --force)

[[ $(jq -r '.id' <<<"$result") == "antigravity" ]] ||
  fail "Antigravity collector returns correct agent id" "$result"
[[ $(jq -r '.ready' <<<"$result") == "true" ]] ||
  fail "Antigravity collector reports ready when history exists" "$result"
[[ $(jq -r '.totalPrompts' <<<"$result") == "3" ]] ||
  fail "Antigravity collector counts total prompts correctly" "$result"
[[ $(jq -r '.todayPrompts' <<<"$result") == "2" ]] ||
  fail "Antigravity collector counts today's prompts correctly" "$result"
[[ $(jq -r '.todaySessions' <<<"$result") == "2" ]] ||
  fail "Antigravity collector counts unique today sessions correctly" "$result"
[[ $(jq -r '.activeDays' <<<"$result") == "2" ]] ||
  fail "Antigravity collector counts active days correctly" "$result"
[[ $(jq -r '.recentDays | length' <<<"$result") == "7" ]] ||
  fail "Antigravity collector outputs 7-day history window" "$result"

pass "Antigravity collector aggregates prompt counts and sessions from history.jsonl"

# --- 3. Fallback to conversation transcripts in brain/ ----------------------

rm -f "$data_dir/history.jsonl"
conv_brain="$data_dir/brain/conv-fallback/.system_generated/logs"
mkdir -p "$conv_brain"

now_iso=$(python3 -c 'import datetime as dt; print(dt.datetime.now().isoformat() + "Z")')

cat >"$conv_brain/transcript.jsonl" <<EOF
{"step_index":0,"source":"USER_EXPLICIT","type":"USER_INPUT","status":"DONE","created_at":"$now_iso","content":"Hello"}
{"step_index":1,"source":"MODEL","type":"PLANNER_RESPONSE","status":"DONE","created_at":"$now_iso","content":"Hi there"}
{"step_index":2,"source":"USER_EXPLICIT","type":"USER_INPUT","status":"DONE","created_at":"$now_iso","content":"Second turn"}
EOF

fallback_out=$(HOME="$TEST_HOME" ANTIGRAVITY_DATA_DIR="$data_dir" \
  "$ROOT/bin/omarchy-agent-usage-antigravity" --force)

[[ $(jq -r '.totalPrompts' <<<"$fallback_out") == "2" ]] ||
  fail "Antigravity collector falls back to transcript.jsonl when history.jsonl is missing" "$fallback_out"
[[ $(jq -r '.todayPrompts' <<<"$fallback_out") == "2" ]] ||
  fail "Antigravity collector counts today turns from transcript fallback" "$fallback_out"
pass "Antigravity collector falls back to conversation transcripts when history.jsonl is missing"

# --- 4. Caching behavior -----------------------------------------------------

cache_root="$TEST_HOME/.cache/omarchy/agent-usage"
mkdir -p "$cache_root"

# Run cached scan
HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" ANTIGRAVITY_DATA_DIR="$data_dir" \
  "$ROOT/bin/omarchy-agent-usage-antigravity" >/dev/null

cache_files=("$cache_root"/antigravity-*.json)
[[ -f ${cache_files[0]} ]] || fail "Antigravity collector writes cache file"

# Mutate cache file to prove cache hit
jq '.totalPrompts = 999' "${cache_files[0]}" >"${cache_files[0]}.tmp" && mv "${cache_files[0]}.tmp" "${cache_files[0]}"

cached_out=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" ANTIGRAVITY_DATA_DIR="$data_dir" \
  "$ROOT/bin/omarchy-agent-usage-antigravity")
[[ $(jq -r '.totalPrompts' <<<"$cached_out") == "999" ]] ||
  fail "Antigravity collector reads valid cache on subsequent calls" "$cached_out"
pass "Antigravity collector writes and reads cache file"

# --- 5. Conversation SQLite protobuf token decoding -------------------------

token_data_dir="$TEST_HOME/token_test"
mkdir -p "$token_data_dir/conversations"

python3 -c '
import sqlite3, time

def encode_varint(val):
    out = bytearray()
    while val > 0x7f:
        out.append((val & 0x7f) | 0x80)
        val >>= 7
    out.append(val & 0x7f)
    return bytes(out)

def field_varint(num, val):
    tag = (num << 3) | 0
    return encode_varint(tag) + encode_varint(val)

def field_bytes(num, data):
    tag = (num << 3) | 2
    return encode_varint(tag) + encode_varint(len(data)) + data

# ModelUsageStats: 2: input (100), 3: output (25), 5: cache_read (50)
usage_pb = field_varint(2, 100) + field_varint(3, 25) + field_varint(5, 50)
# ChatModelMetadata: 4: usage, 19: response_model ("gemini-3.8-flash")
chat_pb = field_bytes(4, usage_pb) + field_bytes(19, b"gemini-3.8-flash")
# CortexStepGeneratorMetadata: 1: chat_model
gen_pb = field_bytes(1, chat_pb)

now_sec = int(time.time())
ts_pb = field_varint(1, now_sec)
step_meta_pb = field_bytes(1, ts_pb)

conn = sqlite3.connect("'"$token_data_dir/conversations/session1.db"'")
c = conn.cursor()
c.execute("CREATE TABLE gen_metadata (idx integer, data blob, size integer, PRIMARY KEY (idx))")
c.execute("CREATE TABLE steps (idx integer, metadata blob, PRIMARY KEY (idx))")
c.execute("INSERT INTO gen_metadata VALUES (0, ?, ?)", (gen_pb, len(gen_pb)))
c.execute("INSERT INTO steps VALUES (0, ?)", (step_meta_pb,))
conn.commit()
conn.close()
'

token_out=$(HOME="$TEST_HOME" ANTIGRAVITY_DATA_DIR="$token_data_dir" \
  "$ROOT/bin/omarchy-agent-usage-antigravity" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$token_out") == "125" ]] ||
  fail "Antigravity collector decodes today total tokens" "$token_out"
[[ $(jq -r '.modelUsage["gemini-3.8-flash"].inputTokens' <<<"$token_out") == "100" ]] ||
  fail "Antigravity collector decodes input tokens by model" "$token_out"
[[ $(jq -r '.modelUsage["gemini-3.8-flash"].outputTokens' <<<"$token_out") == "25" ]] ||
  fail "Antigravity collector decodes output tokens by model" "$token_out"
[[ $(jq -r '.modelUsage["gemini-3.8-flash"].cacheReadInputTokens' <<<"$token_out") == "50" ]] ||
  fail "Antigravity collector decodes cache read tokens by model" "$token_out"
pass "Antigravity collector decodes tokens and models from conversation protobufs"
