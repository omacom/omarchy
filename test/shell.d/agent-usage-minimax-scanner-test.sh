#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

today="$(date +%Y-%m-%d)"
timestamp="${today}T12:00:00Z"
now_ms=$(python3 -c 'import time; print(round(time.time() * 1000))')

# MiniMax Code's own sessions: user messages are prompts, assistant usage is
# tokens. A row with a garbage timestamp or token count drops on its own.
mkdir -p "$TEST_HOME/.minimax/v2/sessions/s1" "$TEST_HOME/.minimax/v2/sessions/s2"
cat >"$TEST_HOME/.minimax/v2/sessions/s1/messages.jsonl" <<EOF
{"message":{"role":"user","timestamp":$now_ms,"content":"hi"}}
{"message":{"role":"assistant","timestamp":$now_ms,"model":"MiniMax-M2","usage":{"input":10,"output":5,"cacheRead":3,"cacheWrite":2,"totalTokens":20}}}
{"message":{"role":"assistant","timestamp":true,"model":"MiniMax-M2","usage":{"input":9999}}}
{"message":{"role":"assistant","timestamp":$now_ms,"model":"MiniMax-M2","usage":{"input":-4,"output":1e300}}}
not json
EOF
cat >"$TEST_HOME/.minimax/v2/sessions/s2/messages.jsonl" <<EOF
{"message":{"role":"user","timestamp":"2020-01-01T00:00:00Z"}}
{"message":{"role":"assistant","timestamp":"2020-01-01T00:00:01Z","model":"MiniMax-M2","usage":{"totalTokens":7}}}
EOF

# pi sessions on MiniMax providers, one in an omp profile; other providers drop.
mkdir -p "$TEST_HOME/.pi/agent/sessions/p" "$TEST_HOME/.omp/profiles/work/agent/sessions/p"
cat >"$TEST_HOME/.pi/agent/sessions/p/a.jsonl" <<EOF
{"type":"message","id":"m1","timestamp":"$timestamp","message":{"role":"assistant","provider":"minimax","model":"MiniMax-M2","usage":{"input":100,"output":50}}}
{"type":"message","id":"m2","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai","model":"gpt","usage":{"input":999}}}
EOF
cat >"$TEST_HOME/.omp/profiles/work/agent/sessions/p/b.jsonl" <<EOF
{"type":"session","id":"fork","parentSession":"$TEST_HOME/.pi/agent/sessions/p/a.jsonl"}
{"type":"message","id":"m1","timestamp":"$timestamp","message":{"role":"assistant","provider":"minimax","model":"MiniMax-M2","usage":{"input":100,"output":50}}}
{"type":"message","id":"m3","timestamp":"$timestamp","message":{"role":"assistant","provider":"minimax-cn","model":"MiniMax-M2","usage":{"input":1000}}}
EOF

# opencode messages on a MiniMax provider.
mkdir -p "$TEST_HOME/.local/share/opencode"
python3 - "$TEST_HOME/.local/share/opencode/opencode.db" "$now_ms" <<'PY'
import json, sqlite3, sys
conn = sqlite3.connect(sys.argv[1])
conn.execute("CREATE TABLE message (id TEXT, session_id TEXT, data TEXT)")
now = int(sys.argv[2])
rows = [
  ("o1", "ses1", {"role": "assistant", "providerID": "minimax-coding-plan", "modelID": "MiniMax-M2", "tokens": {"input": 7, "output": 2, "reasoning": 1, "cache": {"read": 0, "write": 0}}, "time": {"created": now}}),
  ("o2", "ses1", {"role": "assistant", "providerID": "anthropic", "modelID": "claude", "tokens": {"input": 999}, "time": {"created": now}}),
]
conn.executemany("INSERT INTO message VALUES (?, ?, ?)", [(i, s, json.dumps(d)) for i, s, d in rows])
conn.commit()
PY

run() {
  env -u MINIMAX_API_KEY -u MINIMAX_DATA_DIR -u MAVIS_DATA_DIR -u PI_CODING_AGENT_DIR -u MINIMAX_BASE_URL -u OPENCODE_DB \
    HOME="$TEST_HOME" XDG_DATA_HOME="$TEST_HOME/.local/share" XDG_CACHE_HOME="$TEST_HOME/.cache" \
    MMX_CONFIG_DIR="$TEST_HOME/missing" "$@"
}

result=$(run "$ROOT/bin/omarchy-agent-usage-minimax")

# Today: mcode 20, pi 150 (the forked copy counts once) + 1000, opencode 10.
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "1180" ]] ||
  fail "MiniMax collector counts MiniMax Code, pi/omp, and opencode usage" "$result"
pass "MiniMax collector counts MiniMax Code, pi/omp, and opencode usage"

# Prompts: two mcode user messages, two pi turns, one opencode turn.
[[ $(jq -c '{todayPrompts, totalPrompts, totalSessions, activeDays}' <<<"$result") == '{"todayPrompts":4,"totalPrompts":5,"totalSessions":5,"activeDays":2}' ]] ||
  fail "MiniMax collector counts prompts and sessions per source" "$result"
[[ $(jq -Sc '.modelUsage["MiniMax-M2"]' <<<"$result") == '{"cacheCreationInputTokens":2,"cacheReadInputTokens":3,"inputTokens":1124,"outputTokens":58}' ]] ||
  fail "MiniMax collector splits tokens and skips garbage rows" "$result"
pass "MiniMax collector counts prompts, sessions, and tokens, skipping garbage rows"

# In use here without a key: local stats show and the limits wait for one.
[[ $(jq -c '{ready, hasLocalStats, hasPromptStats, usageStatusText, limits, tierLabel}' <<<"$result") == '{"ready":true,"hasLocalStats":true,"hasPromptStats":true,"usageStatusText":"Waiting for auth","limits":[],"tierLabel":""}' ]] ||
  fail "MiniMax collector waits for auth when used without a key" "$result"
pass "MiniMax collector waits for auth when used without a key"

# MINIMAX_DATA_DIR moves MiniMax Code's data, ahead of MAVIS_DATA_DIR.
mkdir -p "$TEST_HOME/moved/v2/sessions/s"
printf '{"message":{"role":"assistant","timestamp":%s,"model":"MiniMax-M2","usage":{"input":5}}}\n' "$now_ms" >"$TEST_HOME/moved/v2/sessions/s/messages.jsonl"
moved=$(run env MINIMAX_DATA_DIR="$TEST_HOME/moved" MAVIS_DATA_DIR="$TEST_HOME/.minimax" "$ROOT/bin/omarchy-agent-usage-minimax" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$moved") == "1165" ]] ||
  fail "MiniMax collector reads MiniMax Code's sessions from MINIMAX_DATA_DIR" "$moved"
pass "MiniMax collector reads MiniMax Code's sessions from MINIMAX_DATA_DIR"

# --limits-only reuses today's scan; --force rescans.
printf '{"message":{"role":"assistant","timestamp":%s,"model":"MiniMax-M2","usage":{"input":1}}}\n' "$now_ms" >>"$TEST_HOME/.minimax/v2/sessions/s1/messages.jsonl"
reused=$(run "$ROOT/bin/omarchy-agent-usage-minimax" --limits-only)
forced=$(run "$ROOT/bin/omarchy-agent-usage-minimax" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$reused") == "1180" && $(jq -r '.todayTotalTokens' <<<"$forced") == "1181" ]] ||
  fail "MiniMax collector reuses a recent scan for --limits-only and rescans on --force" "$reused $forced"
pass "MiniMax collector reuses a recent scan for --limits-only and rescans on --force"

# A scan that couldn't read a source isn't kept for the next run.
if (( EUID != 0 )); then
  rm -f "$TEST_HOME/.cache/omarchy/agent-usage/"minimax-scan-*.json
  chmod 000 "$TEST_HOME/.minimax/v2/sessions/s2/messages.jsonl"
  run "$ROOT/bin/omarchy-agent-usage-minimax" --force >/dev/null
  chmod 644 "$TEST_HOME/.minimax/v2/sessions/s2/messages.jsonl"
  partial=$(run "$ROOT/bin/omarchy-agent-usage-minimax" --limits-only)
  [[ $(jq -r '.totalPrompts' <<<"$partial") == "5" ]] ||
    fail "MiniMax collector does not cache a scan that missed a file" "$partial"
  pass "MiniMax collector does not cache a scan that missed a file"
else
  skip "MiniMax collector does not cache a scan that missed a file (root reads anything)"
fi

# OpenCode V2 nests the provider under `model` and spends tokens on
# compactions too, for every MiniMax provider id. A message migrated into
# both stores counts once, and a fork's copies of its source's messages don't
# count again. OPENCODE_DB points at the database the way opencode reads it.
V2_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$V2_HOME"' EXIT
python3 - "$V2_HOME/elsewhere/opencode-dev.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL, time_created integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE TABLE session_v2 (id text PRIMARY KEY, fork_session_id text, time_created integer NOT NULL)")
now_ms = int(time.time() * 1000)
forked_ms = now_ms - 1000

def v2(id, session, kind, provider, input, created=now_ms):
  return (id, session, kind, created, json.dumps({
    "model": {"providerID": provider, "id": "MiniMax-M3"},
    "tokens": {"input": input, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": created},
  }))

conn.executemany("INSERT INTO session_v2 VALUES (?, ?, ?)", [("ses_a", None, now_ms - 5000), ("ses_b", "ses_a", forked_ms)])
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?)", [
  v2("msg_1", "ses_a", "assistant", "minimax", 100, now_ms - 4000),
  v2("msg_2", "ses_a", "compaction", "minimax-cn", 10, now_ms - 3000),
  v2("msg_3", "ses_a", "assistant", "minimax-coding-plan", 20),
  v2("msg_4", "ses_a", "assistant", "minimax-cn-coding-plan", 30),
  v2("msg_5", "ses_a", "assistant", "minimax-proxy", 999),
  v2("msg_6", "ses_b", "assistant", "minimax", 100, forked_ms - 4000),
  v2("msg_7", "ses_b", "assistant", "minimax", 1),
])
conn.execute("INSERT INTO message VALUES ('msg_1', 'ses_a', ?, ?, ?)", (now_ms, now_ms, json.dumps({
  "role": "assistant", "providerID": "minimax", "modelID": "MiniMax-M3",
  "tokens": {"input": 100, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
  "time": {"created": now_ms - 4000},
})))
conn.commit()
conn.close()
PY

v2_run() {
  env -u MINIMAX_API_KEY -u MINIMAX_DATA_DIR -u MAVIS_DATA_DIR -u PI_CODING_AGENT_DIR -u MINIMAX_BASE_URL -u OPENCODE_DB \
    HOME="$V2_HOME" XDG_DATA_HOME="$V2_HOME/.local/share" XDG_CACHE_HOME="$V2_HOME/.cache" \
    MMX_CONFIG_DIR="$V2_HOME/missing" "$@"
}

result=$(v2_run env OPENCODE_DB="$V2_HOME/elsewhere/opencode-dev.db" "$ROOT/bin/omarchy-agent-usage-minimax")
[[ $(jq -c '{todayTotalTokens, totalPrompts, totalSessions, models: (.modelUsage | keys)}' <<<"$result") == '{"todayTotalTokens":161,"totalPrompts":5,"totalSessions":2,"models":["MiniMax-M3"]}' ]] ||
  fail "MiniMax collector reads opencode V2 records once each, without fork copies" "$result"
pass "MiniMax collector reads opencode V2 records once each, without fork copies"

# Only a build whose channel was "v2" wrote opencode-v2.db; it is read when
# the usual database is missing.
mkdir -p "$V2_HOME/.local/share/opencode"
cp "$V2_HOME/elsewhere/opencode-dev.db" "$V2_HOME/.local/share/opencode/opencode-v2.db"
result=$(v2_run "$ROOT/bin/omarchy-agent-usage-minimax" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "161" ]] ||
  fail "MiniMax collector falls back to opencode-v2.db" "$result"
pass "MiniMax collector falls back to opencode-v2.db"
