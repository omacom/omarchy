#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

unset MUSE_DATA_DIR MUSE_AUTH_PATH

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

day_dir="$TEST_HOME/.local/share/muse/sessions/$(date +%Y/%m/%d)"
old_dir="$TEST_HOME/.local/share/muse/sessions/$(date -d '8 days ago' +%Y/%m/%d)"
mkdir -p "$day_dir/top-session-1/subagent/child-1" "$old_dir/old-session"

now_us=$(($(date +%s) * 1000000))
old_us=$((($(date +%s) - 8 * 86400) * 1000000))
today=$(date +%Y-%m-%d)
old_date=$(date -d '8 days ago' +%Y-%m-%d)

# Native layout: top-level session logs with subagent logs nested deeper.
# Subagent calls spend the same subscription, so they count as prompts but
# must not read as sessions of their own.
cat >"$day_dir/top-session-1/session.jsonl" <<EOF
{"id":"evt-1","stream":{"kind":"session","id":"top-session-1"},"recorded_at":$now_us,"payload":{"event":{"kind":"model_completed","model":"muse-spark-test","usage":{"input_tokens":1000,"output_tokens":50,"reasoning_tokens":20,"cache_read_tokens":600,"cache_write_tokens":100,"cached_tokens":600}}}}
{"id":"evt-dup","stream":{"kind":"session","id":"top-session-1"},"recorded_at":$now_us,"payload":{"event":{"kind":"not_a_completion","usage":{"input_tokens":9999,"output_tokens":9999}}}}
EOF
cat >"$day_dir/top-session-1/subagent/child-1/session.jsonl" <<EOF
{"id":"evt-2","stream":{"kind":"session","id":"child-1"},"recorded_at":$now_us,"payload":{"event":{"kind":"model_completed","model":"muse-spark-test","usage":{"input_tokens":200,"output_tokens":30,"reasoning_tokens":5,"cache_read_tokens":0,"cache_write_tokens":0,"cached_tokens":0}}}}
EOF
cat >"$old_dir/old-session/session.jsonl" <<EOF
{"id":"evt-3","stream":{"kind":"session","id":"old-session"},"recorded_at":$old_us,"payload":{"event":{"kind":"model_completed","model":"muse-spark-test","usage":{"input_tokens":500,"output_tokens":10,"reasoning_tokens":0,"cache_read_tokens":0,"cache_write_tokens":0,"cached_tokens":0}}}}
EOF

result=$(HOME="$TEST_HOME" XDG_DATA_HOME="$TEST_HOME/.local/share" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_CONFIG_HOME="$TEST_HOME/.config" \
  "$ROOT/bin/omarchy-agent-usage-muse" --force)

[[ $(jq -r '.id' <<<"$result") == "muse" ]] ||
  fail "Muse collector identifies itself" "$result"
pass "Muse collector identifies itself"

# evt-1: 1000 - 600 - 100 input, 50 output, 600 + 100 cache. evt-2: 200 + 30.
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "1280" ]] ||
  fail "Muse collector totals today's tokens across top-level and subagent logs" "$result"
pass "Muse collector totals today's tokens across top-level and subagent logs"

[[ $(jq -r '.todayPrompts' <<<"$result") == "2" ]] ||
  fail "Muse collector counts today's model calls as prompts" "$result"
pass "Muse collector counts today's model calls as prompts"

[[ $(jq -r '.totalSessions' <<<"$result") == "2" ]] ||
  fail "Muse collector counts top-level sessions, not subagent logs" "$result"
pass "Muse collector counts top-level sessions, not subagent logs"

[[ $(jq -r '.todaySessions' <<<"$result") == "1" ]] ||
  fail "Muse collector counts today's top-level sessions" "$result"
pass "Muse collector counts today's top-level sessions"

[[ $(jq -c '.modelUsage["muse-spark-test"]' <<<"$result") == '{"inputTokens":1000,"outputTokens":90,"cacheReadInputTokens":600,"cacheCreationInputTokens":100}' ]] ||
  fail "Muse collector keeps the cache split without double-counting" "$result"
pass "Muse collector keeps the cache split without double-counting"

# Reasoning rides inside output_tokens (20 + 5 + 10 = 35 of the 90 above are
# reasoning) and cached tokens ride inside input_tokens, so neither is added
# on top.
[[ $(jq -r '.totalPrompts' <<<"$result") == "3" ]] ||
  fail "Muse collector counts every model call including older days" "$result"
pass "Muse collector counts every model call including older days"

[[ $(jq -r '.recentDays[-1].messageCount' <<<"$result") == "1280" ]] ||
  fail "Muse collector charts today as the last recent day" "$result"
pass "Muse collector charts today as the last recent day"

[[ $(jq -r '.activeDays' <<<"$result") == "2" ]] ||
  fail "Muse collector counts active days" "$result"
pass "Muse collector counts active days"

[[ $(jq -c '[.activeDates[]] | sort' <<<"$result") == "$(jq -cn --arg a "$old_date" --arg b "$today" '[$a,$b]|sort')" ]] ||
  fail "Muse collector reports active dates for cross-machine merging" "$result"
pass "Muse collector reports active dates for cross-machine merging"

# No login in the fake home: hide meters and report the missing auth.
[[ $(jq -c '.limits' <<<"$result") == "[]" ]] ||
  fail "Muse collector reports no limits without credentials" "$result"
pass "Muse collector reports no limits without credentials"

[[ $(jq -r '.usageStatusText' <<<"$result") == "Waiting for auth" ]] ||
  fail "Muse collector waits for auth without credentials" "$result"
pass "Muse collector waits for auth without credentials"

# A parent named sessions must not be mistaken for the native log root.
mkdir -p "$TEST_HOME/sessions"
mv "$TEST_HOME/.local/share/muse" "$TEST_HOME/sessions/muse"
custom_day="$TEST_HOME/sessions/muse/sessions/$(date +%Y/%m/%d)"
mkdir "$custom_day/top-session-2"
cat >"$custom_day/top-session-2/session.jsonl" <<EOF
{"id":"evt-4","recorded_at":$now_us,"payload":{"event":{"kind":"model_completed","model":"muse-spark-test","usage":{"input_tokens":10,"output_tokens":5}}}}
EOF
custom=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_CONFIG_HOME="$TEST_HOME/.config" \
  MUSE_DATA_DIR="$TEST_HOME/sessions/muse" "$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -c '[.totalSessions,.todaySessions,.todayTotalTokens]' <<<"$custom") == '[3,2,1295]' ]] ||
  fail "Muse collector preserves session counts under a custom sessions parent" "$custom"
pass "Muse collector preserves session counts under a custom sessions parent"

# Cache failures must still emit a usable record, even without credentials.
touch "$TEST_HOME/blocked-cache"
uncached=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/blocked-cache" XDG_CONFIG_HOME="$TEST_HOME/.config" \
  MUSE_DATA_DIR="$TEST_HOME/sessions/muse" "$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -c '[.todayTotalTokens,.totalSessions,.usageStatusText]' <<<"$uncached") == '[1295,3,"Waiting for auth"]' ]] ||
  fail "Muse collector emits local stats when the cache is unavailable" "$uncached"
pass "Muse collector emits local stats when the cache is unavailable"
