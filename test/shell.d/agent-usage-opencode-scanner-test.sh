#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

unset OPENCODE_API_KEY OPENCODE_DB

timestamp="$(date +%Y-%m-%d)T12:00:00Z"

# pi and omp can spend an OpenCode subscription without opencode's CLI ever
# running, so its own database cannot be the only source.
PI_HOME=$(mktemp -d)
trap 'rm -rf "$PI_HOME"' EXIT
mkdir -p "$PI_HOME/.pi/agent/sessions/project" "$PI_HOME/.omp/agent/sessions/project"

cat >"$PI_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"pi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"opencode","model":"deepseek-v4.1-flash:high","usage":{"input":100,"output":10,"reasoning":5,"cacheRead":20,"cacheWrite":3}}}
{"type":"message","id":"pi-2","timestamp":"$timestamp","message":{"role":"assistant","provider":"opencode-local","model":"gpt-nope","usage":{"input":999,"output":999}}}
{"type":"message","id":"pi-3","timestamp":"$timestamp","message":{"role":"user","provider":"opencode","model":"deepseek-v4.1-flash","usage":{"input":999,"output":999}}}
EOF
cat >"$PI_HOME/.omp/agent/sessions/project/omp.jsonl" <<EOF
{ "type": "message", "id": "omp-1", "timestamp": "$timestamp", "message": { "role": "assistant", "provider": "opencode-go", "model": "minimax-m3", "usage": { "input": 50, "output": 4, "reasoning": 1, "cacheRead": 5, "cacheWrite": 0 } } }
{"type":"message","id":"other-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","model":"gpt-nope","usage":{"input":999,"output":999}}}
EOF

result=$(HOME="$PI_HOME" XDG_CACHE_HOME="$PI_HOME/.cache" XDG_DATA_HOME="$PI_HOME/.local/share" \
  PATH="$PI_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-opencode")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "198" ]] ||
  fail "OpenCode collector counts usage from pi and omp sessions" "$result"
[[ $(jq -c '.modelUsage' <<<"$result") == '{"deepseek-v4.1-flash":{"inputTokens":100,"outputTokens":15,"cacheReadInputTokens":20,"cacheCreationInputTokens":3},"minimax-m3":{"inputTokens":50,"outputTokens":5,"cacheReadInputTokens":5,"cacheCreationInputTokens":0}}' ]] ||
  fail "OpenCode collector folds reasoning into output and strips the thinking suffix" "$result"
pass "OpenCode collector counts pi and omp subscription usage"

[[ $(jq -r '.id + "/" + (.name) + "/" + (.limits|tostring)' <<<"$result") == 'opencode/OpenCode/[]' ]] ||
  fail "OpenCode collector identifies itself with an empty limits list" "$result"
pass "OpenCode collector identifies itself with an empty limits list"

# A subscription burned entirely through opencode has no pi session files;
# usage must come from opencode's message database, filtered to its providers.
OPENCODE_HOME=$(mktemp -d)
trap 'rm -rf "$PI_HOME" "$OPENCODE_HOME"' EXIT

python3 - "$OPENCODE_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
now_ms = int(time.time() * 1000)

def message(id, provider, model, role="assistant", input=0, output=0, reasoning=0, read=0, write=0):
  return (id, "ses_1", now_ms, now_ms, json.dumps({
    "role": role,
    "providerID": provider,
    "modelID": model,
    "tokens": {"input": input, "output": output, "reasoning": reasoning, "cache": {"read": read, "write": write}},
    "time": {"created": now_ms},
  }))

conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  message("msg_1", "opencode", "deepseek-v4-flash", input=80, output=40, reasoning=5, read=30),
  message("msg_2", "opencode-go", "minimax-m3", input=10, output=2),
  message("msg_3", "anthropic", "claude-opus-5", input=999, output=999),
  message("msg_7", "openai", "gpt-5.5", input=999, output=999),
  message("msg_4", "opencode-local", "gpt-nope", input=999, output=999),
  message("msg_5", "opencode", "deepseek-v4-flash", role="user", input=999, output=999),
])
conn.execute("INSERT INTO message VALUES ('msg_6', 'ses_1', ?, ?, '[\"not\",\"an\",\"object\"]')", (now_ms, now_ms))
conn.commit()
conn.close()
PY

result=$(HOME="$OPENCODE_HOME" XDG_CACHE_HOME="$OPENCODE_HOME/.cache" XDG_DATA_HOME="$OPENCODE_HOME/.local/share" \
  PATH="$OPENCODE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-opencode")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "167" ]] ||
  fail "OpenCode collector counts opencode database usage, reasoning included" "$result"
[[ $(jq -c '.modelUsage' <<<"$result") == '{"deepseek-v4-flash":{"inputTokens":80,"outputTokens":45,"cacheReadInputTokens":30,"cacheCreationInputTokens":0},"minimax-m3":{"inputTokens":10,"outputTokens":2,"cacheReadInputTokens":0,"cacheCreationInputTokens":0}}' ]] ||
  fail "OpenCode collector leaves Anthropic and OpenAI runs to their own records, and ignores prefix-colliding providers, user messages, and malformed rows" "$result"
[[ $(jq -r '.totalSessions' <<<"$result") == "1" ]] ||
  fail "OpenCode collector counts a database session once" "$result"
pass "OpenCode collector counts opencode database usage"

# The cache is an optimization: the record must stay complete either way.
CACHE_HOME=$(mktemp -d)
trap 'rm -rf "$PI_HOME" "$OPENCODE_HOME" "$CACHE_HOME"' EXIT
mkdir -p "$CACHE_HOME/bin" "$CACHE_HOME/.pi/agent/sessions/project"

cat >"$CACHE_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"pi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"opencode","model":"deepseek-v4.1-flash","usage":{"input":7,"output":3}}}
EOF

result=$(HOME="$CACHE_HOME" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-opencode")
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "10" ]] ||
  fail "OpenCode collector scans without a cache" "$result"

cache_file=$(find "$CACHE_HOME/.cache/omarchy/agent-usage" -name 'opencode-scan-*.json' -print -quit)
[[ -n $cache_file ]] ||
  fail "OpenCode collector writes a local-stats cache" "$cache_file"

result=$(HOME="$CACHE_HOME" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-opencode" --limits-only)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "10" && $(jq -r '.totalPrompts' <<<"$result") == "1" ]] ||
  fail "OpenCode collector --limits-only emits a complete record from cache" "$result"
pass "OpenCode collector caches and reuses local stats"

# Some builds move the same message JSON into session_message with the role in
# a type column, and it reads on its own.
SESSION_HOME=$(mktemp -d)
trap 'rm -rf "$PI_HOME" "$OPENCODE_HOME" "$CACHE_HOME" "$SESSION_HOME"' EXIT

python3 - "$SESSION_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute(
  "CREATE TABLE session_message (id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL,"
  " seq integer NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)"
)
now_ms = int(time.time() * 1000)

def message(id, kind, provider, model, input=0, output=0):
  return (id, "ses_1", kind, 1, now_ms, now_ms, json.dumps({
    "providerID": provider,
    "modelID": model,
    "tokens": {"input": input, "output": output, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }))

conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?, ?, ?)", [
  message("msg_1", "assistant", "opencode", "deepseek-v4.1-flash", input=5, output=2),
  message("msg_2", "user", "opencode", "deepseek-v4.1-flash"),
  message("msg_3", "assistant", "anthropic", "claude-opus-5", input=999, output=999),
])
conn.commit()
conn.close()
PY

result=$(HOME="$SESSION_HOME" XDG_CACHE_HOME="$SESSION_HOME/.cache" XDG_DATA_HOME="$SESSION_HOME/.local/share" \
  PATH="$SESSION_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-opencode")
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "7" ]] ||
  fail "OpenCode collector falls back to the session_message store" "$result"
[[ $(jq -r '.totalSessions' <<<"$result") == "1" ]] ||
  fail "OpenCode collector counts a fallback session once" "$result"
pass "OpenCode collector falls back to the session_message store"

# OpenCode V2 nests the provider under `model` and spends tokens on
# compactions too. A message migrated into both stores counts once, and a
# fork's copies of its source's messages don't count again. OPENCODE_DB
# points at the database the way opencode itself reads it.
V2_HOME=$(mktemp -d)
trap 'rm -rf "$PI_HOME" "$OPENCODE_HOME" "$CACHE_HOME" "$SESSION_HOME" "$V2_HOME"' EXIT

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

def v2(id, session, kind, provider, model, input, created=now_ms):
  return (id, session, kind, created, json.dumps({
    "model": {"providerID": provider, "id": model},
    "tokens": {"input": input, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": created},
  }))

conn.executemany("INSERT INTO session_v2 VALUES (?, ?, ?)", [("ses_a", None, now_ms - 5000), ("ses_b", "ses_a", forked_ms)])
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?)", [
  v2("msg_1", "ses_a", "assistant", "opencode-go", "kimi-k3", 100, now_ms - 4000),
  v2("msg_2", "ses_a", "compaction", "opencode-go", "kimi-k3", 10, now_ms - 3000),
  v2("msg_3", "ses_a", "assistant", "anthropic", "claude-opus-5", 999),
  v2("msg_4", "ses_b", "assistant", "opencode-go", "kimi-k3", 100, forked_ms - 4000),
  v2("msg_5", "ses_b", "assistant", "opencode-go", "kimi-k3", 1),
])
conn.execute("INSERT INTO message VALUES ('msg_1', 'ses_a', ?, ?, ?)", (now_ms, now_ms, json.dumps({
  "role": "assistant", "providerID": "opencode-go", "modelID": "kimi-k3",
  "tokens": {"input": 100, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
  "time": {"created": now_ms - 4000},
})))
conn.commit()
conn.close()
PY

result=$(HOME="$V2_HOME" XDG_CACHE_HOME="$V2_HOME/.cache" XDG_DATA_HOME="$V2_HOME/.local/share" \
  OPENCODE_DB="$V2_HOME/elsewhere/opencode-dev.db" PATH="$V2_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-opencode")
[[ $(jq -c '{todayTotalTokens, totalPrompts, totalSessions}' <<<"$result") == '{"todayTotalTokens":111,"totalPrompts":3,"totalSessions":2}' ]] ||
  fail "OpenCode collector reads V2 records once each, without fork copies" "$result"
pass "OpenCode collector reads V2 records once each, without fork copies"

# Valid JSON with a nested field of the wrong shape (a numeric time, a list of
# tokens or of cache counts, a list for a pi message) costs that field or that
# row, never the record.
ODD_HOME=$(mktemp -d)
trap 'rm -rf "$PI_HOME" "$OPENCODE_HOME" "$CACHE_HOME" "$SESSION_HOME" "$V2_HOME" "$ODD_HOME"' EXIT
mkdir -p "$ODD_HOME/.pi/agent/sessions/project"
cat >"$ODD_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"pi-odd","timestamp":"$timestamp","message":["provider","opencode"]}
{"type":"message","id":"pi-usage","timestamp":"$timestamp","message":{"role":"assistant","provider":"opencode","model":"kimi-k3","usage":[1,2]}}
EOF
python3 - "$ODD_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, data text NOT NULL)")
now_ms = int(time.time() * 1000)
rows = [
  ("odd_time", {"role": "assistant", "providerID": "opencode", "modelID": "kimi-k3", "tokens": {"input": 40, "output": 0}, "time": 12345}),
  ("odd_tokens", {"role": "assistant", "providerID": "opencode", "modelID": "kimi-k3", "tokens": [1, 2], "time": {"created": now_ms}}),
  ("odd_cache", {"role": "assistant", "providerID": "opencode", "modelID": "kimi-k3", "tokens": {"input": 2, "cache": [9]}, "time": {"created": now_ms}}),
]
conn.executemany("INSERT INTO message VALUES (?, 'ses_odd', ?)", [(id, json.dumps(data)) for id, data in rows])
conn.commit()
conn.close()
PY
result=$(HOME="$ODD_HOME" XDG_CACHE_HOME="$ODD_HOME/.cache" XDG_DATA_HOME="$ODD_HOME/.local/share" \
  PATH="$ODD_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-opencode")
[[ $(jq -c '{totalPrompts, input: .modelUsage["kimi-k3"].inputTokens}' <<<"$result") == '{"totalPrompts":2,"input":42}' ]] ||
  fail "OpenCode collector survives malformed nested fields" "$result"
pass "OpenCode collector survives malformed nested fields"

# A machine nobody uses OpenCode's subscription on gives a record the panel
# skips: no plan, no limits, no usage.
EMPTY_HOME=$(mktemp -d)
trap 'rm -rf "$PI_HOME" "$OPENCODE_HOME" "$CACHE_HOME" "$SESSION_HOME" "$V2_HOME" "$ODD_HOME" "$EMPTY_HOME"' EXIT
result=$(HOME="$EMPTY_HOME" XDG_CACHE_HOME="$EMPTY_HOME/.cache" XDG_DATA_HOME="$EMPTY_HOME/.local/share" \
  OPENCODE_API_KEY= PATH="$EMPTY_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-opencode")
[[ $(jq -c '{ready, tierLabel, limits, totalPrompts, limitsStale}' <<<"$result") == '{"ready":false,"tierLabel":"","limits":[],"totalPrompts":0,"limitsStale":false}' ]] ||
  fail "OpenCode collector gives an empty record where nobody uses it" "$result"
pass "OpenCode collector gives an empty record where nobody uses it"
