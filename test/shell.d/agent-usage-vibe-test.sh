#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3
require_command rg

COLLECTOR="$ROOT/bin/omarchy-agent-usage-vibe"
TMP_ROOT=$(mktemp -d)
trap 'rm -rf "$TMP_ROOT"' EXIT

unset VIBE_HOME PI_CODING_AGENT_DIR OPENCODE_DB XDG_DATA_HOME XDG_CACHE_HOME

today=$(date +%Y-%m-%d)
now_iso=$(date -u +%Y-%m-%dT%H:%M:%S+00:00)
two_days_ago=$(date -d '2 days ago' +%Y-%m-%d)
two_days_ago_iso=$(date -u -d '2 days ago' +%Y-%m-%dT%H:%M:%S+00:00)

new_home() {
  local home="$TMP_ROOT/$1"
  mkdir -p "$home"
  printf '%s\n' "$home"
}

collect() {
  local home="$1"
  shift
  HOME="$home" XDG_CACHE_HOME="$home/.cache" XDG_DATA_HOME="$home/.local/share" "$COLLECTOR" "$@"
}

# write_meta <session dir> <start time> <prompt> <cached> <completion> <config json>
write_meta() {
  mkdir -p "$1"
  cat >"$1/meta.json" <<EOF
{"session_id":"$(basename "$1")","start_time":"$2","stats":{"session_prompt_tokens":$3,"session_cached_tokens":$4,"session_completion_tokens":$5},"config":$6}
EOF
}

MISTRAL_CONFIG='{"active_model":"mistral-medium-3.5","models":{"mistral-medium-3.5":{"name":"mistral-vibe-cli-latest","provider":"mistral","alias":"mistral-medium-3.5"},"local":{"name":"qwen","provider":"llamacpp","alias":"local"}},"providers":[{"name":"mistral","api_base":"https://api.mistral.ai/v1","backend":"mistral"},{"name":"llamacpp","api_base":"http://127.0.0.1:8080/v1","backend":"generic"}]}'
LOCAL_CONFIG=${MISTRAL_CONFIG/\"active_model\":\"mistral-medium-3.5\"/\"active_model\":\"local\"}

# ---------------------------------------------------------------- unused

home=$(new_home empty)
record=$(collect "$home" --force)
[[ $(jq -c '{schemaVersion, id, name, ready, tierLabel, usageStatusText, authHelpText, limits, limitsStale, limitsFetchedAt, balance: has("balance"), todayPrompts, todaySessions, todayTotalTokens, todayTokensByModel, totalPrompts, totalSessions, activeDays, activeDates, modelUsage, days: (.recentDays | length)}' <<<"$record") == '{"schemaVersion":1,"id":"vibe","name":"Mistral Vibe","ready":false,"tierLabel":"","usageStatusText":"","authHelpText":"","limits":[],"limitsStale":false,"limitsFetchedAt":0,"balance":false,"todayPrompts":0,"todaySessions":0,"todayTotalTokens":0,"todayTokensByModel":{},"totalPrompts":0,"totalSessions":0,"activeDays":0,"activeDates":[],"modelUsage":{},"days":7}' ]] ||
  fail "Vibe collector prints a full empty record the panel skips on an unused machine" "$record"
pass "Vibe collector prints a full empty record the panel skips on an unused machine"

# ---------------------------------------------------------------- Vibe sessions

home=$(new_home vibe)
sessions="$home/.vibe/logs/session"
write_meta "$sessions/session_20260101_120000_aaaa" "$now_iso" 1000 400 200 "$MISTRAL_CONFIG"
cat >"$sessions/session_20260101_120000_aaaa/messages.jsonl" <<'EOF'
{"role": "user", "content": "Fix the bug"}
{"role": "assistant", "content": "Done"}
{"role": "user", "content": "<reminder>", "injected": true}
{"role": "user", "content": "summary", "context_boundary": "compaction"}
{"role": "tool", "content": "ok"}
{"role": "user", "content": "Thanks"}
EOF
# A subagent's totals belong to the session that spawned it; its task is not
# a prompt anyone typed.
write_meta "$sessions/session_20260101_120000_aaaa/agents/explore_20260101_120100_bbbb" "$now_iso" 300 0 50 "$MISTRAL_CONFIG"
printf '%s\n' '{"role": "user", "content": "Look around"}' >"$sessions/session_20260101_120000_aaaa/agents/explore_20260101_120100_bbbb/messages.jsonl"
# A session on the local llama.cpp provider is not Mistral usage.
write_meta "$sessions/session_20260101_130000_cccc" "$now_iso" 9000 0 9000 "$LOCAL_CONFIG"
printf '%s\n' '{"role": "user", "content": "local"}' >"$sessions/session_20260101_130000_cccc/messages.jsonl"
# Running totals are booked on the day the session started.
write_meta "$sessions/session_20260101_140000_dddd" "$two_days_ago_iso" 100 0 10 "$MISTRAL_CONFIG"

record=$(collect "$home" --force)
[[ $(jq -c '{ready, todayPrompts, todaySessions, todayTotalTokens, totalPrompts, totalSessions, activeDays}' <<<"$record") == '{"ready":true,"todayPrompts":2,"todaySessions":1,"todayTotalTokens":1550,"totalPrompts":2,"totalSessions":2,"activeDays":2}' ]] ||
  fail "Vibe collector counts Mistral sessions, their subagents, and typed prompts only" "$record"
pass "Vibe collector counts Mistral sessions, their subagents, and typed prompts only"

[[ $(jq -c '.modelUsage' <<<"$record") == '{"mistral-medium-3.5":{"inputTokens":1000,"outputTokens":260,"cacheReadInputTokens":400,"cacheCreationInputTokens":0}}' ]] ||
  fail "Vibe collector splits cached prompt tokens out of input and skips other providers" "$record"
pass "Vibe collector splits cached prompt tokens out of input and skips other providers"

[[ $(jq -r --arg day "$two_days_ago" '.recentDays[] | select(.date == $day) | .messageCount' <<<"$record") == "110" ]] ||
  fail "Vibe collector books a session on the day it started" "$record"
pass "Vibe collector books a session on the day it started"

# ---------------------------------------------------------------- model resolution

home=$(new_home resolve)
sessions="$home/.vibe/logs/session"
# Unpinned: Vibe falls back to its default alias.
write_meta "$sessions/session_1" "$now_iso" 10 0 0 '{"active_model":"","models":{"local":{"name":"q","provider":"llamacpp","alias":"local"},"mistral-medium-3.5":{"name":"m","provider":"mistral","alias":"mistral-medium-3.5"}},"providers":[{"name":"mistral","backend":"mistral"},{"name":"llamacpp","backend":"generic"}]}'
# Older releases dump the models as a list.
write_meta "$sessions/session_2" "$now_iso" 20 0 0 '{"active_model":"devstral","models":[{"name":"devstral-2","provider":"mistral","alias":"devstral"}],"providers":[{"name":"mistral","backend":"mistral"}]}'
# A generic provider aimed at Mistral's API is still Mistral.
write_meta "$sessions/session_3" "$now_iso" 40 0 0 '{"active_model":"codestral","models":{"codestral":{"name":"codestral-latest","provider":"la-plateforme","alias":"codestral"}},"providers":[{"name":"la-plateforme","api_base":"https://codestral.mistral.ai/v1","backend":"generic"}]}'
# A lookalike host is not.
write_meta "$sessions/session_4" "$now_iso" 80 0 0 '{"active_model":"x","models":{"x":{"name":"x","provider":"proxy","alias":"x"}},"providers":[{"name":"proxy","api_base":"https://mistral.ai.example.com/v1","backend":"generic"}]}'
record=$(collect "$home" --force)
[[ $(jq -c '[.modelUsage | to_entries[] | {(.key): .value.inputTokens}] | add' <<<"$record") == '{"mistral-medium-3.5":10,"devstral":20,"codestral":40}' ]] ||
  fail "Vibe collector resolves the session model and its provider as Vibe does" "$record"
pass "Vibe collector resolves the session model and its provider as Vibe does"

# ---------------------------------------------------------------- untrusted fields

home=$(new_home untrusted)
sessions="$home/.vibe/logs/session"
write_meta "$sessions/session_bad_time" "not a time" 500 0 500 "$MISTRAL_CONFIG"
write_meta "$sessions/session_future" "2999-01-01T00:00:00+00:00" 500 0 500 "$MISTRAL_CONFIG"
write_meta "$sessions/session_odd_tokens" "$now_iso" '"700"' true NaN "$MISTRAL_CONFIG"
write_meta "$sessions/session_negative" "$now_iso" -5 0 7 "$MISTRAL_CONFIG"
mkdir -p "$sessions/session_not_json" && printf '[1, 2' >"$sessions/session_not_json/meta.json"
record=$(collect "$home" --force 2>/dev/null)
[[ $(jq -c '{ready, todayTotalTokens, totalSessions}' <<<"$record") == '{"ready":true,"todayTotalTokens":7,"totalSessions":1}' ]] ||
  fail "Vibe collector skips bad times and bad token fields without losing the record" "$record"
pass "Vibe collector skips bad times and bad token fields without losing the record"

# A meta.json that fails to parse leaves the scan incomplete, so it isn't cached.
[[ -z $(find "$home/.cache/omarchy/agent-usage" -name 'vibe-scan-*.json' 2>/dev/null) ]] ||
  fail "Vibe collector does not cache a scan that could not read every session"
pass "Vibe collector does not cache a scan that could not read every session"

# Nor does a pi session rg couldn't read, even when another file matched.
if (( EUID != 0 )); then
  home=$(new_home pi-unreadable)
  pi_dir="$home/.pi/agent/sessions/--work--"
  mkdir -p "$pi_dir"
  printf '{"type":"message","id":"m1","timestamp":"%s","message":{"role":"assistant","provider":"mistral","model":"devstral-2","usage":{"input":5,"output":6}}}\n' "$now_iso" >"$pi_dir/readable.jsonl"
  printf '{"type":"message","id":"m2","timestamp":"%s","message":{"role":"assistant","provider":"mistral","model":"devstral-2","usage":{"input":50,"output":60}}}\n' "$now_iso" >"$pi_dir/locked.jsonl"
  chmod 000 "$pi_dir/locked.jsonl"
  record=$(collect "$home" --force 2>/dev/null)
  chmod 644 "$pi_dir/locked.jsonl"
  [[ $(jq -r '.todayTotalTokens' <<<"$record") == "11" ]] ||
    fail "Vibe collector counts the pi sessions it could read" "$record"
  [[ -z $(find "$home/.cache/omarchy/agent-usage" -name 'vibe-scan-*.json' 2>/dev/null) ]] ||
    fail "Vibe collector does not cache a scan with an unreadable pi session"
  pass "Vibe collector does not cache a scan with an unreadable pi session"
fi

# ---------------------------------------------------------------- plan

home=$(new_home plan)
mkdir -p "$home/.vibe"
cat >"$home/.vibe/whoami_cache.json" <<'EOF'
{"old":{"stored_at_timestamp":100,"payload":{"plan_type":"api","plan_name":"FREE_TRIAL"}},"new":{"stored_at_timestamp":200,"payload":{"plan_type":"chat","plan_name":"individual"}}}
EOF
record=$(collect "$home" --force)
[[ $(jq -c '{ready, tierLabel}' <<<"$record") == '{"ready":true,"tierLabel":"Pro"}' ]] ||
  fail "Vibe collector names the newest cached plan as Vibe does" "$record"
pass "Vibe collector names the newest cached plan as Vibe does"

printf '%s\n' '{"a":{"stored_at_timestamp":1,"payload":{"plan_type":"chat","plan_name":"MYSTERY"}}}' >"$home/.vibe/whoami_cache.json"
record=$(collect "$home" --force)
[[ $(jq -c '{ready, tierLabel}' <<<"$record") == '{"ready":false,"tierLabel":""}' ]] ||
  fail "Vibe collector leaves a plan Vibe cannot name unnamed" "$record"
pass "Vibe collector leaves a plan Vibe cannot name unnamed"

# ---------------------------------------------------------------- VIBE_HOME and save_dir

home=$(new_home relocated)
mkdir -p "$home/vibe-home"
cat >"$home/vibe-home/config.toml" <<EOF
[session_logging]
save_dir = "$home/elsewhere"
session_prefix = "run"
EOF
write_meta "$home/elsewhere/run_1" "$now_iso" 30 0 3 "$MISTRAL_CONFIG"
write_meta "$home/elsewhere/session_1" "$now_iso" 999 0 999 "$MISTRAL_CONFIG"
record=$(HOME="$home" XDG_CACHE_HOME="$home/.cache" XDG_DATA_HOME="$home/.local/share" VIBE_HOME="$home/vibe-home" "$COLLECTOR" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$record") == "33" ]] ||
  fail "Vibe collector honors VIBE_HOME and session_logging in config.toml" "$record"
pass "Vibe collector honors VIBE_HOME and session_logging in config.toml"

# ---------------------------------------------------------------- pi, omp, opencode

home=$(new_home harnesses)
mkdir -p "$home/.pi/agent/sessions/p" "$home/.omp/profiles/work/agent/sessions/p"
cat >"$home/.pi/agent/sessions/p/a.jsonl" <<EOF
{"type":"message","id":"m1","timestamp":"$now_iso","message":{"role":"assistant","provider":"mistral","model":"devstral-medium","usage":{"input":10,"output":5,"cacheRead":2,"cacheWrite":1}}}
{"type":"message","id":"m2","timestamp":"$now_iso","message":{"role":"assistant","provider":"openrouter","model":"mistralai/devstral","usage":{"input":999,"output":999}}}
{"type":"message","timestamp":"$now_iso","message":{"role":"assistant","provider":"mistral","model":"devstral-medium","usage":{"input":4}}}
EOF
# A fork repeats its parent's messages with the same id and time.
cat >"$home/.omp/profiles/work/agent/sessions/p/fork.jsonl" <<EOF
{"type":"message","id":"m1","timestamp":"$now_iso","message":{"role":"assistant","provider":"mistral","model":"devstral-medium","usage":{"input":10,"output":5,"cacheRead":2,"cacheWrite":1}}}
{"type":"message","id":"m3","timestamp":"$now_iso","message":{"role":"assistant","provider":"mistral","model":"mistral-large:high","usage":{"input":true,"output":"8","cacheRead":-1,"totalTokens":6}}}
EOF
python3 - "$home/.local/share/opencode/opencode.db" <<'PY'
import json, sqlite3, sys, time
from pathlib import Path
db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, data text NOT NULL)")
now_ms = int(time.time() * 1000)
def row(id, provider, tokens):
  return (id, "ses_1", json.dumps({"role": "assistant", "providerID": provider, "modelID": "mistral/codestral-latest", "tokens": tokens, "time": {"created": now_ms}}))
conn.executemany("INSERT INTO message VALUES (?, ?, ?)", [
  row("o1", "mistral", {"input": 100, "output": 20, "reasoning": 5, "cache": {"read": 30, "write": 0}}),
  row("o2", "mistral-proxy", {"input": 999, "output": 999}),
])
conn.commit()
PY
record=$(collect "$home" --force)
[[ $(jq -c '.modelUsage' <<<"$record") == '{"devstral-medium":{"inputTokens":14,"outputTokens":5,"cacheReadInputTokens":2,"cacheCreationInputTokens":1},"mistral-large":{"inputTokens":6,"outputTokens":0,"cacheReadInputTokens":0,"cacheCreationInputTokens":0},"codestral-latest":{"inputTokens":100,"outputTokens":25,"cacheReadInputTokens":30,"cacheCreationInputTokens":0}}' ]] ||
  fail "Vibe collector counts pi, omp profile, and opencode messages on the mistral provider once" "$record"
pass "Vibe collector counts pi, omp profile, and opencode messages on the mistral provider once"

[[ $(jq -c '{ready, todayPrompts, totalSessions}' <<<"$record") == '{"ready":true,"todayPrompts":4,"totalSessions":3}' ]] ||
  fail "Vibe collector counts each harness message as one prompt in its own session" "$record"
pass "Vibe collector counts each harness message as one prompt in its own session"

home=$(new_home pi-dir)
mkdir -p "$home/custom-pi/sessions/p"
printf '%s\n' "{\"type\":\"message\",\"id\":\"x\",\"timestamp\":\"$now_iso\",\"message\":{\"role\":\"assistant\",\"provider\":\"mistral\",\"model\":\"m\",\"usage\":{\"input\":9}}}" >"$home/custom-pi/sessions/p/a.jsonl"
# A $HOME that is a git checkout must not hide session files from rg.
printf '*\n' >"$home/.gitignore"
git -C "$home" init -q
record=$(HOME="$home" XDG_CACHE_HOME="$home/.cache" PI_CODING_AGENT_DIR="$home/custom-pi" "$COLLECTOR" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$record") == "9" ]] ||
  fail "Vibe collector honors PI_CODING_AGENT_DIR and ignores git ignore rules" "$record"
pass "Vibe collector honors PI_CODING_AGENT_DIR and ignores git ignore rules"

# ---------------------------------------------------------------- scan cache

home=$(new_home cache)
sessions="$home/.vibe/logs/session"
write_meta "$sessions/session_1" "$now_iso" 10 0 0 "$MISTRAL_CONFIG"
first=$(collect "$home")
write_meta "$sessions/session_2" "$now_iso" 5 0 0 "$MISTRAL_CONFIG"
[[ $(collect "$home" | jq -r '.todayTotalTokens') == "10" ]] ||
  fail "Vibe collector reuses a scan from the last few seconds"
[[ $(collect "$home" --limits-only | jq -r '.todayTotalTokens') == "10" ]] ||
  fail "Vibe collector reuses a recent scan for --limits-only"
[[ $(collect "$home" --force | jq -r '.todayTotalTokens') == "15" ]] ||
  fail "Vibe collector rescans with --force"
pass "Vibe collector reuses a recent scan and rescans with --force"

cache_file=$(find "$home/.cache/omarchy/agent-usage" -name 'vibe-scan-*.json' -print -quit)
[[ $(jq -r '.scanDate' "$cache_file") == "$today" ]] ||
  fail "Vibe collector stamps its scan cache with the day it was made" "$(cat "$cache_file")"
jq '.scanDate = "2000-01-01" | .stats.todayTotalTokens = 1' "$cache_file" >"$cache_file.new" && mv "$cache_file.new" "$cache_file"
[[ $(collect "$home" | jq -r '.todayTotalTokens') == "15" ]] ||
  fail "Vibe collector ignores a scan cache from another day"
pass "Vibe collector ignores a scan cache from another day"

# The per-session index is only an optimization: a changed session is reread.
write_meta "$sessions/session_1" "$now_iso" 50 0 0 "$MISTRAL_CONFIG"
[[ $(collect "$home" --force | jq -r '.todayTotalTokens') == "55" ]] ||
  fail "Vibe collector rereads a session whose meta.json changed"
pass "Vibe collector rereads a session whose meta.json changed"
