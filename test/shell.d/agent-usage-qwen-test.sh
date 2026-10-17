#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

COLLECTOR="$ROOT/bin/omarchy-agent-usage-qwen"
TMP_ROOT=$(mktemp -d)
trap 'rm -rf "$TMP_ROOT"' EXIT

unset QWEN_HOME QWEN_RUNTIME_DIR XDG_CACHE_HOME

today=$(date +%Y-%m-%d)
now_iso=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)
two_days_ago=$(date -d '2 days ago' +%Y-%m-%d)
two_days_ago_iso=$(date -u -d '2 days ago' +%Y-%m-%dT%H:%M:%S.000Z)

new_home() {
  local home="$TMP_ROOT/$1"
  mkdir -p "$home"
  printf '%s\n' "$home"
}

collect() {
  local home="$1"
  shift
  HOME="$home" XDG_CACHE_HOME="$home/.cache" "$COLLECTOR" "$@"
}

# prompt <uuid> <session> <time> [subtype]
prompt() {
  local subtype=""
  [[ -n ${4:-} ]] && subtype=",\"subtype\":\"$4\""
  printf '{"uuid":"%s","parentUuid":null,"sessionId":"%s","timestamp":"%s","type":"user"%s,"message":{"role":"user","parts":[{"text":"hi"}]}}\n' "$1" "$2" "$3" "$subtype"
}

# response <uuid> <session> <time> <model> <auth> <input> <output> <cached> <thoughts> [response id]
response() {
  printf '{"uuid":"%s","sessionId":"%s","timestamp":"%s","type":"system","subtype":"ui_telemetry","systemPayload":{"uiEvent":{"event.name":"qwen-code.api_response","event.timestamp":"%s","response_id":"%s","model":"%s","auth_type":"%s","input_token_count":%s,"output_token_count":%s,"cached_content_token_count":%s,"thoughts_token_count":%s,"total_token_count":0}}}\n' \
    "$1" "$2" "$3" "$3" "${10:-}" "$4" "$5" "$6" "$7" "$8" "$9"
}

# ---------------------------------------------------------------- unused

home=$(new_home empty)
record=$(collect "$home" --force)
[[ $(jq -c '{schemaVersion, id, name, ready, hasPromptStats, tierLabel, usageStatusText, authHelpText, limits, limitsStale, limitsFetchedAt, balance: has("balance"), todayPrompts, todaySessions, todayTotalTokens, todayTokensByModel, totalPrompts, totalSessions, activeDays, activeDates, modelUsage, days: (.recentDays | length)}' <<<"$record") == '{"schemaVersion":1,"id":"qwen","name":"Qwen Code","ready":false,"hasPromptStats":true,"tierLabel":"","usageStatusText":"","authHelpText":"","limits":[],"limitsStale":false,"limitsFetchedAt":0,"balance":false,"todayPrompts":0,"todaySessions":0,"todayTotalTokens":0,"todayTokensByModel":{},"totalPrompts":0,"totalSessions":0,"activeDays":0,"activeDates":[],"modelUsage":{},"days":7}' ]] ||
  fail "Qwen collector prints a full empty record the panel skips on an unused machine" "$record"
pass "Qwen collector prints a full empty record the panel skips on an unused machine"

# ---------------------------------------------------------------- transcripts

home=$(new_home transcripts)
chats="$home/.qwen/projects/-home-me-app/chats"
mkdir -p "$chats"
{
  prompt u1 s1 "$now_iso"
  response r1 s1 "$now_iso" qwen3-coder-plus qwen-oauth 1000 200 600 50 resp-1
  prompt u2 s1 "$now_iso" mid_turn_user_message
  # Goal and notification records are not typed prompts.
  prompt u3 s1 "$now_iso" goal_runtime
  # Gemini leaves thinking out of the output count.
  response r2 s1 "$now_iso" gemini-2.5-pro gemini-api-key 300 40 0 10 resp-2
  # A provider that reports only the cached part reported a fully cached prompt.
  response r3 s1 "$now_iso" qwen3-coder-plus openai 0 5 80 0 resp-3
  printf '{"uuid":"x","type":"system","subtype":"ui_telemetry","systemPayload":{"uiEvent":{"event.name":"qwen-code.tool_call","model":"m"}}}\n'
  printf '{"uuid":"y","type":"assistant","model":"qwen3-coder-plus","usageMetadata":{"promptTokenCount":999}}\n'
} >"$chats/s1.jsonl"
{
  prompt u4 s2 "$two_days_ago_iso"
  response r4 s2 "$two_days_ago_iso" qwen3-coder-plus openai 70 7 0 3 resp-4
} >"$chats/s2.jsonl"
# A branched session carries the records it was branched from.
{
  prompt u4 s2 "$two_days_ago_iso"
  response r4 s2 "$two_days_ago_iso" qwen3-coder-plus openai 70 7 0 3 resp-4
} >"$chats/s3.jsonl"
printf '{"uuid":"l","type":"user","sessionId":"s1","timestamp":"%s"}\n' "$now_iso" >"$chats/s1.ledger.jsonl"

record=$(collect "$home" --force)
[[ $(jq -c '{ready, todayPrompts, todaySessions, todayTotalTokens, totalPrompts, totalSessions, activeDays}' <<<"$record") == '{"ready":true,"todayPrompts":2,"todaySessions":1,"todayTotalTokens":1635,"totalPrompts":3,"totalSessions":2,"activeDays":2}' ]] ||
  fail "Qwen collector counts typed prompts and billed responses once each" "$record"
pass "Qwen collector counts typed prompts and billed responses once each"

[[ $(jq -c '.modelUsage' <<<"$record") == '{"qwen3-coder-plus":{"inputTokens":470,"outputTokens":212,"cacheReadInputTokens":680,"cacheCreationInputTokens":0},"gemini-2.5-pro":{"inputTokens":300,"outputTokens":50,"cacheReadInputTokens":0,"cacheCreationInputTokens":0}}' ]] ||
  fail "Qwen collector reads tokens the way Qwen Code's own statistics do" "$record"
pass "Qwen collector reads tokens the way Qwen Code's own statistics do"

[[ $(jq -r --arg day "$two_days_ago" '.recentDays[] | select(.date == $day) | .messageCount' <<<"$record") == "77" ]] ||
  fail "Qwen collector books a response on the day it arrived" "$record"
pass "Qwen collector books a response on the day it arrived"

# ---------------------------------------------------------------- untrusted fields

home=$(new_home untrusted)
chats="$home/.qwen/projects/p/chats"
mkdir -p "$chats"
{
  prompt bad1 s "yesterday-ish"
  prompt bad2 s "2999-01-01T00:00:00Z"
  response bad3 s "$now_iso" m openai '"100"' true NaN -5 a
  response bad4 s "$now_iso" m openai 1e30 0 0 0 b
  response ok1 s "$now_iso" m openai 10 2 0 0 c
  printf '{"uuid":"z","type":"user","timestamp":'
} >"$chats/s.jsonl"
record=$(collect "$home" --force)
[[ $(jq -c '{todayPrompts, todayTotalTokens}' <<<"$record") == '{"todayPrompts":0,"todayTotalTokens":12}' ]] ||
  fail "Qwen collector skips bad times, bad token fields, and a torn last line" "$record"
pass "Qwen collector skips bad times, bad token fields, and a torn last line"

# ---------------------------------------------------------------- locations

home=$(new_home relocated)
mkdir -p "$home/qhome" "$home/runtime/projects/p/chats" "$home/qhome/projects/p/chats" "$home/.qwen/projects/p/chats"
response a s "$now_iso" m openai 1 0 0 0 ra >"$home/runtime/projects/p/chats/s.jsonl"
response b s "$now_iso" m openai 10 0 0 0 rb >"$home/qhome/projects/p/chats/s.jsonl"
response c s "$now_iso" m openai 100 0 0 0 rc >"$home/.qwen/projects/p/chats/s.jsonl"
record=$(HOME="$home" XDG_CACHE_HOME="$home/.cache" QWEN_HOME="$home/qhome" QWEN_RUNTIME_DIR="$home/runtime" "$COLLECTOR" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$record") == "11" ]] ||
  fail "Qwen collector honors QWEN_HOME and QWEN_RUNTIME_DIR" "$record"
pass "Qwen collector honors QWEN_HOME and QWEN_RUNTIME_DIR"

mkdir -p "$home/.qwen" "$home/out/projects/p/chats"
printf '{"advanced":{"runtimeOutputDir":"~/out"}}\n' >"$home/.qwen/settings.json"
response d s "$now_iso" m openai 1000 0 0 0 rd >"$home/out/projects/p/chats/s.jsonl"
record=$(collect "$home" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$record") == "1100" ]] ||
  fail "Qwen collector reads the runtimeOutputDir from settings.json" "$record"
pass "Qwen collector reads the runtimeOutputDir from settings.json"

# ---------------------------------------------------------------- scan cache

home=$(new_home cache)
chats="$home/.qwen/projects/p/chats"
mkdir -p "$chats"
response a s "$now_iso" m openai 10 0 0 0 ra >"$chats/s.jsonl"
collect "$home" >/dev/null
response b s "$now_iso" m openai 5 0 0 0 rb >>"$chats/s.jsonl"
[[ $(collect "$home" | jq -r '.todayTotalTokens') == "10" ]] ||
  fail "Qwen collector reuses a scan from the last few seconds"
[[ $(collect "$home" --limits-only | jq -r '.todayTotalTokens') == "10" ]] ||
  fail "Qwen collector reuses a recent scan for --limits-only"
[[ $(collect "$home" --force | jq -r '.todayTotalTokens') == "15" ]] ||
  fail "Qwen collector rescans with --force"
pass "Qwen collector reuses a recent scan and rescans with --force"

cache_file=$(find "$home/.cache/omarchy/agent-usage" -name 'qwen-scan-*.json' -print -quit)
[[ $(jq -r '.scanDate' "$cache_file") == "$today" ]] ||
  fail "Qwen collector stamps its scan cache with the day it was made" "$(cat "$cache_file")"
jq '.scanDate = "2000-01-01" | .stats.todayTotalTokens = 1' "$cache_file" >"$cache_file.new" && mv "$cache_file.new" "$cache_file"
[[ $(collect "$home" | jq -r '.todayTotalTokens') == "15" ]] ||
  fail "Qwen collector ignores a scan cache from another day"
pass "Qwen collector ignores a scan cache from another day"

# The transcript index reads only what was appended, and starts over when the
# file is replaced.
response c s "$now_iso" m openai 20 0 0 0 rc >>"$chats/s.jsonl"
[[ $(collect "$home" --force | jq -r '.todayTotalTokens') == "35" ]] ||
  fail "Qwen collector picks up lines appended to a transcript"
response d s "$now_iso" m openai 1 0 0 0 rd >"$chats/s.new"
response e s "$now_iso" m openai 2 0 0 0 re >>"$chats/s.new"
response f s "$now_iso" m openai 3 0 0 0 rf >>"$chats/s.new"
response g s "$now_iso" m openai 4 0 0 0 rg >>"$chats/s.new"
mv "$chats/s.new" "$chats/s.jsonl"
[[ $(collect "$home" --force | jq -r '.todayTotalTokens') == "10" ]] ||
  fail "Qwen collector rereads a transcript that was replaced"
pass "Qwen collector reads appends incrementally and rereads a replaced transcript"

response h s "$now_iso" m openai 5 0 0 0 rh >>"$chats/s.jsonl"
chmod 000 "$chats/s.jsonl"
if [[ ! -r $chats/s.jsonl ]]; then
  rm -f "$cache_file"
  collect "$home" --force >/dev/null 2>&1
  [[ ! -e $cache_file ]] ||
    fail "Qwen collector does not cache a scan that could not read every transcript"
  pass "Qwen collector does not cache a scan that could not read every transcript"
else
  skip "Qwen collector does not cache a scan that could not read every transcript (running as root)"
fi
chmod 644 "$chats/s.jsonl"
