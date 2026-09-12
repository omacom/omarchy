#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# The collector reads ~/.minimax/v2/sessions/<date>/<session_id>/messages.jsonl.
# A user without mcode installed has no session directory at all; the
# collector must still print a valid record with an empty auth prompt
# instead of crashing the whole usage update.
mkdir -p "$TEST_HOME/.minimax/v2/sessions"

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-mcode" --force 2>/dev/null) ||
  fail "mcode collector runs without any session directory"

[[ $(jq -r '.id' <<<"$result") == "mcode" ]] ||
  fail "mcode collector identifies as mcode" "$result"
pass "mcode collector identifies as mcode"

[[ $(jq -r '.name' <<<"$result") == "MiniMax Code" ]] ||
  fail "mcode collector labels as MiniMax Code" "$result"
pass "mcode collector labels as MiniMax Code"

[[ $(jq -r '.ready' <<<"$result") == "false" ]] ||
  fail "mcode collector reports ready=false with no usage" "$result"
pass "mcode collector reports ready=false with no usage"

[[ $(jq -r '.authHelpText' <<<"$result") == "Run \`mcode login\` to authenticate." ]] ||
  fail "mcode collector surfaces the auth prompt when no sessions exist" "$result"
pass "mcode collector surfaces the auth prompt when no sessions exist"

# A fresh install leaves an auth record on disk: the auth prompt should
# quiet down even though no usage has been recorded yet.
mkdir -p "$TEST_HOME/.minimax/auth/prod/en/mcode-public"
echo '{}' >"$TEST_HOME/.minimax/auth/prod/en/mcode-public/placeholder.json"

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-mcode" --force 2>/dev/null) ||
  fail "mcode collector runs with an auth record present"

[[ $(jq -r '.authHelpText' <<<"$result") == "" ]] ||
  fail "mcode collector silences the auth prompt when an auth record exists" "$result"
pass "mcode collector silences the auth prompt when an auth record exists"

# A session directory with two messages.jsonl files: the collector must
# count each assistant turn once and attribute tokens by model.
session_dir="$TEST_HOME/.minimax/v2/sessions/$(date +%Y/%m/%d)/session_a"
mkdir -p "$session_dir"
today_ms=$(($(date +%s) * 1000))
cat >"$session_dir/messages.jsonl" <<EOF
{"message_id":"m1","message":{"role":"user","content":[{"type":"text","text":"hello"}]}}
{"message_id":"m2","message":{"role":"assistant","model":"minimax-m3","timestamp":$today_ms,"usage":{"input":100,"output":40,"cacheRead":60,"cacheWrite":0,"totalTokens":200,"cost":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0,"total":0}}}}
EOF

session_dir_b="$TEST_HOME/.minimax/v2/sessions/$(date +%Y/%m/%d)/session_b"
mkdir -p "$session_dir_b"
cat >"$session_dir_b/messages.jsonl" <<EOF
{"message_id":"m3","message":{"role":"assistant","model":"minimax-m3","timestamp":$today_ms,"usage":{"input":50,"output":20,"cacheRead":30,"cacheWrite":0,"totalTokens":100,"cost":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0,"total":0}}}}
EOF

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-mcode" --force 2>/dev/null) ||
  fail "mcode collector scans a populated session directory"

# Each session's messages.jsonl counts as one session; the two turns are
# counted separately because they live in different session directories.
[[ $(jq -r '.todayPrompts' <<<"$result") == "2" ]] ||
  fail "mcode collector counts both assistant turns" "$result"
pass "mcode collector counts both assistant turns"

[[ $(jq -r '.todaySessions' <<<"$result") == "2" ]] ||
  fail "mcode collector attributes sessions by directory" "$result"
pass "mcode collector attributes sessions by directory"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "300" ]] ||
  fail "mcode collector sums input + output + cache" "$result"
pass "mcode collector sums input + output + cache"

[[ $(jq -r '.modelUsage["minimax-m3"].inputTokens' <<<"$result") == "150" ]] ||
  fail "mcode collector reports non-cached input separately from cache reads" "$result"
pass "mcode collector reports non-cached input separately from cache reads"

[[ $(jq -r '.modelUsage["minimax-m3"].cacheReadInputTokens' <<<"$result") == "90" ]] ||
  fail "mcode collector reports cache reads under their own bucket" "$result"
pass "mcode collector reports cache reads under their own bucket"

[[ $(jq -r '.ready' <<<"$result") == "true" ]] ||
  fail "mcode collector flips ready to true once usage exists" "$result"
pass "mcode collector flips ready to true once usage exists"

# A usage payload with no breakdown but a positive totalTokens should
# still count toward input so the model row has something to show.
session_dir_c="$TEST_HOME/.minimax/v2/sessions/$(date +%Y/%m/%d)/session_c"
mkdir -p "$session_dir_c"
cat >"$session_dir_c/messages.jsonl" <<EOF
{"message_id":"m4","message":{"role":"assistant","model":"minimax-m3","timestamp":$today_ms,"usage":{"totalTokens":50,"cacheRead":0,"cacheWrite":0,"cost":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0,"total":0}}}}
EOF

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-mcode" --force 2>/dev/null) ||
  fail "mcode collector scans a totals-only usage payload"

[[ $(jq -r '.modelUsage["minimax-m3"].inputTokens' <<<"$result") == "200" ]] ||
  fail "mcode collector attributes totals-only to input" "$result"
pass "mcode collector attributes totals-only to input"

# User messages must not be counted as prompts.
session_dir_d="$TEST_HOME/.minimax/v2/sessions/$(date +%Y/%m/%d)/session_d"
mkdir -p "$session_dir_d"
cat >"$session_dir_d/messages.jsonl" <<EOF
{"message_id":"m5","message":{"role":"user","content":[{"type":"text","text":"hi"}]}}
EOF

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-mcode" --force 2>/dev/null) ||
  fail "mcode collector scans a user-only session"

[[ $(jq -r '.todayPrompts' <<<"$result") == "3" ]] ||
  fail "mcode collector ignores user-only sessions for prompts" "$result"
pass "mcode collector ignores user-only sessions for prompts"

# MCODE_HOME overrides the default ~/.minimax root.
OVERRIDE_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$OVERRIDE_HOME"' EXIT

mkdir -p "$OVERRIDE_HOME/v2/sessions/$(date +%Y/%m/%d)/session_override"
cat >"$OVERRIDE_HOME/v2/sessions/$(date +%Y/%m/%d)/session_override/messages.jsonl" <<EOF
{"message_id":"m6","message":{"role":"assistant","model":"minimax-m3","timestamp":$today_ms,"usage":{"input":10,"output":5,"cacheRead":0,"cacheWrite":0,"totalTokens":15,"cost":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0,"total":0}}}}
EOF

result=$(HOME="$TEST_HOME" MCODE_HOME="$OVERRIDE_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-mcode" --force 2>/dev/null) ||
  fail "mcode collector honors MCODE_HOME override"

[[ $(jq -r '.todayPrompts' <<<"$result") == "1" ]] ||
  fail "mcode collector reads from MCODE_HOME" "$result"
pass "mcode collector reads from MCODE_HOME"
