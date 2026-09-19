#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3
require_command sqlite3
PYTHON=$(command -p -v python3)

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

export HOME="$TEST_HOME"
export XDG_CACHE_HOME="$TEST_HOME/.cache"
export XDG_CONFIG_HOME="$TEST_HOME/.config"
export XDG_DATA_HOME="$TEST_HOME/.local/share"
export MUSE_DATA_DIR="$TEST_HOME/muse-data"
unset META_API_KEY META_API_BASE_URL MUSE_AUTH_PATH

now_s=$(date +%s)
now_us=$((now_s * 1000000))
now_ms=$((now_s * 1000))
old_s=$((now_s - 8 * 86400))
old_us=$((old_s * 1000000))
old_ms=$((old_s * 1000))
old_date=$(date -d "@$old_s" +%F)

# Native muse sessions: one main session with a model_completed event, one
# subagent event under the same session, and one session from 8 days ago.
mkdir -p "$MUSE_DATA_DIR/sessions/sess-A/subagent/sub-1" "$MUSE_DATA_DIR/sessions/sess-B"
cat >"$MUSE_DATA_DIR/sessions/sess-A/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "metadata", "record": {"model_id": "muse-spark-1.3-contributor", "provider_id": "meta"}}}
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "muse-spark-1.3-contributor", "usage": {"input_tokens": 1000, "output_tokens": 100, "reasoning_tokens": 20, "cache_read_tokens": 600, "cache_write_tokens": 0}}}}
EOF
cat >"$MUSE_DATA_DIR/sessions/sess-A/subagent/sub-1/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "muse-spark-1.3-contributor", "usage": {"input_tokens": 500, "output_tokens": 50, "reasoning_tokens": 0, "cache_read_tokens": 100, "cache_write_tokens": 0}}}}
EOF
cat >"$MUSE_DATA_DIR/sessions/sess-B/session.jsonl" <<EOF
{"recorded_at": $old_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "muse-spark-1.2-contributor", "usage": {"input_tokens": 2000, "output_tokens": 200, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
EOF

# opencode database: one meta row, one opencode-proxied muse-spark row, and
# one unrelated provider row that must be ignored.
mkdir -p "$XDG_DATA_HOME/opencode"
db_path="$XDG_DATA_HOME/opencode/opencode.db"
sqlite3 "$db_path" <<EOF
CREATE TABLE message (session_id TEXT, data TEXT);
INSERT INTO message VALUES ('op-1', '{"role":"assistant","providerID":"meta","modelID":"muse-spark-1.2-contributor","tokens":{"input":300,"output":60,"reasoning":10,"cache":{"read":90,"write":7}},"time":{"created":$now_ms}}');
INSERT INTO message VALUES ('op-2', '{"role":"assistant","providerID":"opencode","modelID":"muse-spark-1.3-contributor-free","tokens":{"input":100,"output":20,"reasoning":0,"cache":{"read":30,"write":0}},"time":{"created":$now_ms}}');
INSERT INTO message VALUES ('op-3', '{"role":"assistant","providerID":"openai","modelID":"gpt-5.4","tokens":{"input":999,"output":999,"reasoning":0,"cache":{"read":0,"write":0}},"time":{"created":$now_ms}}');
INSERT INTO message VALUES ('op-4', '{"role":"user","model":{"providerID":"opencode","modelID":"muse-spark-1.3-contributor-free"},"time":{"created":$now_ms}}');
EOF

result=$("$ROOT/bin/omarchy-agent-usage-muse" --force)

# Test 1: Collector identifies itself with prompt stats and no limits
[[ $(jq -r '.id' <<<"$result") == "muse" ]] ||
  fail "Muse collector identifies as 'muse'" "$result"
[[ $(jq -r '.ready' <<<"$result") == "true" ]] ||
  fail "Muse collector reports ready with recorded usage" "$result"
[[ $(jq -r '.hasPromptStats' <<<"$result") == "true" ]] ||
  fail "Muse collector reports prompt stats" "$result"
[[ $(jq -r '.limits | length' <<<"$result") == "0" ]] ||
  fail "Muse collector reports no limits without an API key" "$result"
[[ $(jq 'has("balance")' <<<"$result") == "false" ]] ||
  fail "Muse collector reports metering only, no balance" "$result"
pass "Muse collector identifies as 'muse' with metering-only record"

# Test 2: Token totals sum native sessions and opencode rows
# Native input_tokens include cached tokens, so uncached input is split out:
# sess-A main (1000-600) + 100 out + 600 cached = 1100; subagent
# (500-100) + 50 + 100 = 550. opencode input is already cache-exclusive:
# meta 300 + 70 + 90 + 7 = 467; free 100 + 20 + 30 = 150.
# Today: 1100 + 550 + 467 + 150 = 2267.
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "2267" ]] ||
  fail "Muse collector sums today's tokens across sources" "$result"
[[ $(jq -r '.todayPrompts' <<<"$result") == "4" ]] ||
  fail "Muse collector counts today's prompts" "$result"
pass "Muse collector sums today's tokens across sources"

# Test 3: Subagent sessions roll up into the parent session
# sess-A main + subagent = 1 session; plus 2 opencode sessions = 3 today,
# 4 all-time with sess-B.
[[ $(jq -r '.todaySessions' <<<"$result") == "3" ]] ||
  fail "Muse collector rolls subagents into the parent session" "$result"
[[ $(jq -r '.totalSessions' <<<"$result") == "4" ]] ||
  fail "Muse collector counts all-time sessions" "$result"
[[ $(jq -r '.totalPrompts' <<<"$result") == "5" ]] ||
  fail "Muse collector counts all-time prompts" "$result"
pass "Muse collector rolls subagents into the parent session"

# Test 4: Per-model breakdowns use flat numeric totals and split buckets
[[ $(jq -r '.todayTokensByModel.["muse-spark-1.3-contributor"]' <<<"$result") == "1650" ]] ||
  fail "Muse collector tracks todayTokensByModel as flat numeric totals" "$result"
usage_13=$(jq '.modelUsage.["muse-spark-1.3-contributor"]' <<<"$result")
[[ $(jq -r '.inputTokens' <<<"$usage_13") == "800" ]] ||
  fail "Muse collector splits cached tokens out of native input" "$result"
[[ $(jq -r '.outputTokens' <<<"$usage_13") == "150" ]] ||
  fail "Muse collector does not double-count native reasoning tokens" "$result"
[[ $(jq -r '.cacheReadInputTokens' <<<"$usage_13") == "700" ]] ||
  fail "Muse collector tracks native cache reads" "$result"
usage_meta=$(jq '.modelUsage.["muse-spark-1.2-contributor"]' <<<"$result")
[[ $(jq -r '.inputTokens' <<<"$usage_meta") == "2300" ]] ||
  fail "Muse collector keeps opencode input cache-exclusive" "$result"
pass "Muse collector tracks per-model breakdowns"

# Test 5: Active dates include history outside the 7-day window
[[ $(jq -r --arg d "$old_date" '.activeDates | index($d) != null' <<<"$result") == "true" ]] ||
  fail "Muse collector unions active dates beyond recent days" "$result"
[[ $(jq -r '.recentDays | length' <<<"$result") == "7" ]] ||
  fail "Muse collector reports a 7-day window" "$result"
pass "Muse collector unions active dates beyond recent days"

# Test 6: Without sources, returns an empty unreadied record
mkdir -p "$TEST_HOME/empty-home"
result_empty=$(HOME="$TEST_HOME/empty-home" MUSE_DATA_DIR="$TEST_HOME/empty-muse" XDG_DATA_HOME="$TEST_HOME/empty-share" XDG_CACHE_HOME="$TEST_HOME/empty-cache" "$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_empty") == "0" ]] ||
  fail "Muse collector returns empty stats without sources" "$result_empty"
[[ $(jq -r '.ready' <<<"$result_empty") == "false" ]] ||
  fail "Muse collector reports not ready without sources" "$result_empty"
# Local metering needs no credentials, so there is never an auth state to
# report — even on a machine with no usage at all.
[[ $(jq -r '.usageStatusText' <<<"$result_empty") == "" ]] ||
  fail "Muse collector reports no status without sources" "$result_empty"
[[ $(jq -r '.authHelpText' <<<"$result_empty") == "" ]] ||
  fail "Muse collector reports no auth help without sources" "$result_empty"
pass "Muse collector returns empty stats without sources"

# Test 7: Schema matches panel expectations
[[ $(jq 'has("schemaVersion") and has("ready") and has("limits") and has("recentDays") and has("modelUsage") and has("activeDates")' <<<"$result") == "true" ]] ||
  fail "Muse collector emits correct schema" "$result"
pass "Muse collector emits correct schema"

# Test 8: Symlinked session files are skipped, never followed
# A symlink to a real session would double-count it if followed; a dangling
# one must not error the scan; and a session reached via a symlinked
# directory must not escape the tree. Totals stay at the Test 2 baseline.
mkdir -p "$MUSE_DATA_DIR/sessions/sess-link" "$MUSE_DATA_DIR/sessions/sess-dangling" "$TEST_HOME/outside/evil"
cat >"$TEST_HOME/outside/evil/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "evil-model", "usage": {"input_tokens": 100, "output_tokens": 10, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
EOF
ln -s "$MUSE_DATA_DIR/sessions/sess-A/session.jsonl" "$MUSE_DATA_DIR/sessions/sess-link/session.jsonl"
ln -s "$MUSE_DATA_DIR/sessions/nope/session.jsonl" "$MUSE_DATA_DIR/sessions/sess-dangling/session.jsonl"
ln -s "$TEST_HOME/outside/evil" "$MUSE_DATA_DIR/sessions/sess-evildir"
result_link=$("$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_link") == "2267" ]] ||
  fail "Muse collector skips symlinked session files" "$result_link"
[[ $(jq -r '.modelUsage | has("evil-model")' <<<"$result_link") == "false" ]] ||
  fail "Muse collector rejects sessions outside the tree" "$result_link"
pass "Muse collector skips symlinked session files"

# Test 9: Oversized model names fail the row closed
# A 500-character model id with real tokens must not bloat the record:
# totals stay put and the model never appears.
mkdir -p "$MUSE_DATA_DIR/sessions/sess-huge" "$MUSE_DATA_DIR/sessions/sess-huge-metadata"
big_model=$(printf 'x%.0s' {1..500})
cat >"$MUSE_DATA_DIR/sessions/sess-huge/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "$big_model", "usage": {"input_tokens": 100, "output_tokens": 10, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
EOF
cat >"$MUSE_DATA_DIR/sessions/sess-huge-metadata/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "metadata", "record": {"model_id": "$big_model"}}}
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "usage": {"input_tokens": 100, "output_tokens": 10, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
EOF
result_huge=$("$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_huge") == "2267" ]] ||
  fail "Muse collector skips oversized model names" "$result_huge"
[[ $(jq -r '.modelUsage | length' <<<"$result_huge") == "3" ]] ||
  fail "Muse collector keeps oversized models out of the breakdown" "$result_huge"
pass "Muse collector skips oversized model names"

# Test 10: Many distinct models stay exact in totals
# 70 distinct models plus the 3 baseline ones: every bucket is kept and the
# totals reconcile exactly.
NOW_US="$now_us" "$PYTHON" - <<'PY'
import json
import os
from pathlib import Path
root = Path(os.environ["MUSE_DATA_DIR"]) / "sessions" / "sess-many"
root.mkdir(parents=True, exist_ok=True)
now_us = int(os.environ["NOW_US"])
with (root / "session.jsonl").open("w", encoding="utf-8") as handle:
    for i in range(70):
        handle.write(json.dumps({
            "recorded_at": now_us,
            "payload": {"kind": "run", "event": {
                "kind": "model_completed",
                "model": "cap-model-%02d" % i,
                "usage": {"input_tokens": 10, "output_tokens": 0,
                          "reasoning_tokens": 0, "cache_read_tokens": 0,
                          "cache_write_tokens": 0},
            }},
        }) + "\n")
PY
result_cap=$("$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_cap") == "2967" ]] ||
  fail "Muse collector keeps exact totals with many models" "$result_cap"
[[ $(jq -r '.modelUsage | length' <<<"$result_cap") == "73" ]] ||
  fail "Muse collector keeps every model in the breakdown" "$result_cap"
# Scan order varies, so reconcile instead of naming names: every bucket must
# sum to the all-time total (today 2967 + sess-B 2200).
[[ $(jq -r '[.modelUsage[] | .inputTokens + .outputTokens + .cacheReadInputTokens + .cacheCreationInputTokens] | add' <<<"$result_cap") == "5167" ]] ||
  fail "Muse collector accounts every token with many models" "$result_cap"
pass "Muse collector keeps exact totals with many models"

# Test 11: Negative token fields cannot reduce recorded usage
mkdir -p "$MUSE_DATA_DIR/sessions/sess-negative"
cat >"$MUSE_DATA_DIR/sessions/sess-negative/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "negative-model", "usage": {"input_tokens": -100, "output_tokens": 10, "reasoning_tokens": -5, "cache_read_tokens": -20, "cache_write_tokens": -30}}}}
EOF
result_negative=$("$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.modelUsage.["negative-model"] | [.inputTokens, .outputTokens, .cacheReadInputTokens, .cacheCreationInputTokens] == [0, 10, 0, 0]' <<<"$result_negative") == "true" ]] ||
  fail "Muse collector clamps negative token fields" "$result_negative"
pass "Muse collector clamps negative token fields"

# Test 12: Normal runs reuse the short local scan cache; --force bypasses it
negative_total=$(jq -r '.todayTotalTokens' <<<"$result_negative")
cat >>"$MUSE_DATA_DIR/sessions/sess-negative/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "negative-model", "usage": {"input_tokens": 5, "output_tokens": 0, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
EOF
result_scan_cached=$("$ROOT/bin/omarchy-agent-usage-muse")
result_scan_forced=$("$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_scan_cached") == "$negative_total" ]] ||
  fail "Muse collector reuses a fresh local scan" "$result_scan_cached"
[[ $(jq -r '.todayTotalTokens' <<<"$result_scan_forced") == "$((negative_total + 5))" ]] ||
  fail "Muse collector force-refreshes local stats" "$result_scan_forced"
pass "Muse collector caches local scans and honors --force"

# Test 13: The default native data path follows XDG_DATA_HOME
xdg_home="$TEST_HOME/xdg"
mkdir -p "$xdg_home/data/muse/sessions/xdg-session"
cat >"$xdg_home/data/muse/sessions/xdg-session/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "muse-spark-1.3", "usage": {"input_tokens": 10, "output_tokens": 2, "reasoning_tokens": 1, "cache_read_tokens": 4, "cache_write_tokens": 0}}}}
EOF
result_xdg=$(HOME="$xdg_home" XDG_DATA_HOME="$xdg_home/data" XDG_CONFIG_HOME="$xdg_home/config" XDG_CACHE_HOME="$xdg_home/cache" MUSE_DATA_DIR="" "$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_xdg") == "12" ]] ||
  fail "Muse collector follows XDG_DATA_HOME" "$result_xdg"
pass "Muse collector follows XDG_DATA_HOME"

# Test 14: run_model tracking, retained_frame children, and timestamp fallbacks
# A completion without an explicit model inherits the run_model id; a
# retained_frame wrapper's record_json child parses like a plain event; ISO
# timestamps land on today; and a missing recorded_at falls back to the file
# mtime (today for a new file). 110 + 55 + 22 + 7 = 194 in one session.
ev_home="$TEST_HOME/events"
mkdir -p "$ev_home/muse-data/sessions/sess-events"
now_iso=$(date +%FT%T%:z)
cat >"$ev_home/muse-data/sessions/sess-events/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "run_model", "record": {"model_id": "model-via-run-model"}}}
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "usage": {"input_tokens": 100, "output_tokens": 10, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
{"recorded_at": "$now_iso", "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "model-explicit", "usage": {"input_tokens": 50, "output_tokens": 5, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
{"children": [{"record_json": "{\"recorded_at\": $now_us, \"payload\": {\"kind\": \"run\", \"event\": {\"kind\": \"model_completed\", \"model\": \"model-via-child\", \"usage\": {\"input_tokens\": 20, \"output_tokens\": 2, \"reasoning_tokens\": 0, \"cache_read_tokens\": 0, \"cache_write_tokens\": 0}}}}"}]}
{"payload": {"kind": "run", "event": {"kind": "model_completed", "model": "model-via-mtime", "usage": {"input_tokens": 7, "output_tokens": 0, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
EOF
result_ev=$(HOME="$ev_home" XDG_DATA_HOME="$ev_home/data" XDG_CACHE_HOME="$ev_home/cache" MUSE_DATA_DIR="$ev_home/muse-data" "$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_ev") == "194" ]] ||
  fail "Muse collector counts every event shape" "$result_ev"
[[ $(jq -r '.todayPrompts' <<<"$result_ev") == "4" ]] ||
  fail "Muse collector counts prompts across event shapes" "$result_ev"
[[ $(jq -r '.todaySessions' <<<"$result_ev") == "1" ]] ||
  fail "Muse collector keeps one session's events together" "$result_ev"
[[ $(jq -r '.modelUsage.["model-via-run-model"] | [.inputTokens, .outputTokens] == [100, 10]' <<<"$result_ev") == "true" ]] ||
  fail "Muse collector tracks the run_model id" "$result_ev"
[[ $(jq -r '.modelUsage.["model-via-child"] | [.inputTokens, .outputTokens] == [20, 2]' <<<"$result_ev") == "true" ]] ||
  fail "Muse collector parses retained_frame children" "$result_ev"
[[ $(jq -r '.todayTokensByModel | keys | sort == ["model-explicit", "model-via-child", "model-via-mtime", "model-via-run-model"]' <<<"$result_ev") == "true" ]] ||
  fail "Muse collector files ISO and mtime events under today" "$result_ev"
pass "Muse collector handles run_model, children, and timestamp fallbacks"

# Test 15: A corrupt opencode database cannot break the native scan
# The native sessions still report, and the incomplete scan is served but
# never cached.
corrupt_home="$TEST_HOME/corrupt"
mkdir -p "$corrupt_home/muse-data/sessions/sess-native" "$corrupt_home/data/opencode"
cat >"$corrupt_home/muse-data/sessions/sess-native/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "native-model", "usage": {"input_tokens": 30, "output_tokens": 3, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
EOF
printf 'not a database' >"$corrupt_home/data/opencode/opencode.db"
corrupt_env=(env HOME="$corrupt_home" XDG_DATA_HOME="$corrupt_home/data" XDG_CACHE_HOME="$corrupt_home/cache" MUSE_DATA_DIR="$corrupt_home/muse-data")
result_corrupt=$("${corrupt_env[@]}" "$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_corrupt") == "33" ]] ||
  fail "Muse collector serves native stats past a corrupt database" "$result_corrupt"
[[ $(jq -r '.ready' <<<"$result_corrupt") == "true" ]] ||
  fail "Muse collector reports ready past a corrupt database" "$result_corrupt"
shopt -s nullglob
corrupt_cached=("$corrupt_home"/cache/omarchy/agent-usage/muse-scan-*.json)
shopt -u nullglob
(( ${#corrupt_cached[@]} == 0 )) ||
  fail "Muse collector refuses to cache an incomplete scan" "$result_corrupt"
result_corrupt_again=$("${corrupt_env[@]}" "$ROOT/bin/omarchy-agent-usage-muse")
[[ $(jq -r '.todayTotalTokens' <<<"$result_corrupt_again") == "33" ]] ||
  fail "Muse collector repeats the scan past a corrupt database" "$result_corrupt_again"
pass "Muse collector survives a corrupt opencode database"

# Test 16: --limits-only reuses a scan for far longer than a normal run
lo_home="$TEST_HOME/limits-only"
mkdir -p "$lo_home/muse-data/sessions/sess-lo"
cat >"$lo_home/muse-data/sessions/sess-lo/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "lo-model", "usage": {"input_tokens": 40, "output_tokens": 0, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
EOF
lo_env=(env HOME="$lo_home" XDG_DATA_HOME="$lo_home/data" XDG_CACHE_HOME="$lo_home/cache" MUSE_DATA_DIR="$lo_home/muse-data")
result_lo_base=$("${lo_env[@]}" "$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_lo_base") == "40" ]] ||
  fail "Muse collector scans the limits-only fixture" "$result_lo_base"
cat >>"$lo_home/muse-data/sessions/sess-lo/session.jsonl" <<EOF
{"recorded_at": $now_us, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "lo-model", "usage": {"input_tokens": 8, "output_tokens": 0, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
EOF
result_lo_cached=$("${lo_env[@]}" "$ROOT/bin/omarchy-agent-usage-muse" --limits-only)
[[ $(jq -r '.todayTotalTokens' <<<"$result_lo_cached") == "40" ]] ||
  fail "Muse collector reuses a scan for --limits-only" "$result_lo_cached"
result_lo_forced=$("${lo_env[@]}" "$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_lo_forced") == "48" ]] ||
  fail "Muse collector force-refreshes past --limits-only" "$result_lo_forced"
pass "Muse collector honors --limits-only cache reuse"

# Test 17: Odd timestamp and token shapes cannot misfile or drop usage
# A microsecond epoch emitted as a string still lands on its real day (8 days
# ago, outside the 7-day window); a boolean timestamp falls back to today
# instead of 1970; a non-dict opencode time object keeps its row's tokens
# under today; a non-dict tokens object skips just that row; and a non-dict
# cache object keeps the row's input. Today: 5 + 44 + 11 = 60.
odd_home="$TEST_HOME/odd-shapes"
mkdir -p "$odd_home/muse-data/sessions/sess-odd" "$odd_home/data/opencode"
cat >"$odd_home/muse-data/sessions/sess-odd/session.jsonl" <<EOF
{"recorded_at": "$old_us", "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "string-ts-model", "usage": {"input_tokens": 60, "output_tokens": 6, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
{"recorded_at": true, "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "bool-ts-model", "usage": {"input_tokens": 5, "output_tokens": 0, "reasoning_tokens": 0, "cache_read_tokens": 0, "cache_write_tokens": 0}}}}
EOF
sqlite3 "$odd_home/data/opencode/opencode.db" <<EOF
CREATE TABLE message (session_id TEXT, data TEXT);
INSERT INTO message VALUES ('odd-1', '{"role":"assistant","providerID":"meta","modelID":"odd-time-model","tokens":{"input":40,"output":4,"reasoning":0,"cache":{"read":0,"write":0}},"time":12345}');
INSERT INTO message VALUES ('odd-2', '{"role":"assistant","providerID":"meta","modelID":"odd-tokens-model","tokens":[1,2],"time":{"created":$now_ms}}');
INSERT INTO message VALUES ('odd-3', '{"role":"assistant","providerID":"meta","modelID":"odd-cache-model","tokens":{"input":11,"output":0,"reasoning":0,"cache":"nope"},"time":{"created":$now_ms}}');
EOF
result_odd=$(HOME="$odd_home" XDG_DATA_HOME="$odd_home/data" XDG_CACHE_HOME="$odd_home/cache" MUSE_DATA_DIR="$odd_home/muse-data" "$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result_odd") == "60" ]] ||
  fail "Muse collector totals odd shapes without misfiling" "$result_odd"
[[ $(jq -r '.totalPrompts' <<<"$result_odd") == "4" ]] ||
  fail "Muse collector counts prompts across odd shapes" "$result_odd"
[[ $(jq -r --arg d "$old_date" '.activeDates | index($d) != null' <<<"$result_odd") == "true" ]] ||
  fail "Muse collector files string epochs on their real day" "$result_odd"
[[ $(jq -r '.activeDates | index("1969-12-31") != null or index("1970-01-01") != null' <<<"$result_odd") == "false" ]] ||
  fail "Muse collector keeps booleans out of 1970" "$result_odd"
[[ $(jq -r '.modelUsage.["odd-time-model"] | [.inputTokens, .outputTokens] == [40, 4]' <<<"$result_odd") == "true" ]] ||
  fail "Muse collector keeps tokens past a malformed time object" "$result_odd"
[[ $(jq -r '.modelUsage | has("odd-tokens-model")' <<<"$result_odd") == "false" ]] ||
  fail "Muse collector skips only the malformed tokens row" "$result_odd"
[[ $(jq -r '.modelUsage.["odd-cache-model"] | [.inputTokens, .outputTokens] == [11, 0]' <<<"$result_odd") == "true" ]] ||
  fail "Muse collector keeps input past a malformed cache object" "$result_odd"
pass "Muse collector survives odd timestamp and token shapes"
