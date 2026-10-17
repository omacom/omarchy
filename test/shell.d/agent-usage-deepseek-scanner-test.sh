#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

# A key in the environment would send the collector to DeepSeek.
unset DEEPSEEK_API_KEY DEEPSEEK_API_BASE_URL DSH_HOME PI_CODING_AGENT_DIR OPENCODE_DB

timestamp="$(date +%Y-%m-%d)T12:00:00Z"
now_ms="$(date +%s)000"

HOMES=()
trap 'rm -rf "${HOMES[@]}"' EXIT

new_home() {
  local home
  home=$(mktemp -d)
  HOMES+=("$home")
  printf '%s\n' "$home"
}

# The collector run as it is installed, with every store under one home.
collect() {
  local home="$1"
  shift
  HOME="$home" XDG_CACHE_HOME="$home/.cache" XDG_DATA_HOME="$home/.local/share" XDG_CONFIG_HOME="$home/.config" \
    "$ROOT/bin/omarchy-agent-usage-deepseek" "$@" 2>/dev/null
}

# ---------------------------------------------------------------- pi and omp

PI_HOME=$(new_home)
mkdir -p "$PI_HOME/.pi/agent/sessions/project" "$PI_HOME/.omp/agent/sessions/project"

cat >"$PI_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"pi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-pi","usage":{"input":10,"output":4,"cacheRead":3,"cacheWrite":2,"totalTokens":19}}}
{"type":"message","id":"pi-2","timestamp":"$timestamp","message":{"role":"assistant","provider":"anthropic","model":"claude-test","usage":{"input":999,"output":999}}}
{"type":"message","id":"pi-3","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","model":"gpt-test","usage":{"input":999,"output":999}}}
EOF
cat >"$PI_HOME/.omp/agent/sessions/project/omp.jsonl" <<EOF
{ "type": "message", "id": "omp-1", "timestamp": "$timestamp", "message": { "role": "assistant", "provider": "deepseek", "model": "deepseek-omp", "usage": { "input": 20, "output": 5, "cacheRead": 4, "cacheWrite": 1, "totalTokens": 30 } } }
EOF

result=$(collect "$PI_HOME")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "49" ]] ||
  fail "DeepSeek collector counts usage from pi and omp sessions" "$result"
pass "DeepSeek collector counts usage from pi and omp sessions"

[[ $(jq -c '.modelUsage' <<<"$result") == '{"deepseek-pi":{"inputTokens":10,"outputTokens":4,"cacheReadInputTokens":3,"cacheCreationInputTokens":2},"deepseek-omp":{"inputTokens":20,"outputTokens":5,"cacheReadInputTokens":4,"cacheCreationInputTokens":1}}' ]] ||
  fail "DeepSeek collector filters pi and omp sessions to DeepSeek providers" "$result"
pass "DeepSeek collector filters pi and omp sessions to DeepSeek providers"

[[ $(jq -r '"\(.todayPrompts):\(.todaySessions)"' <<<"$result") == "2:2" ]] ||
  fail "DeepSeek collector counts each message once per session" "$result"
pass "DeepSeek collector counts each message once per session"

# Local usage alone puts DeepSeek in use; without a key there is no plan and
# no balance section.
[[ $(jq -c '{id, ready, tierLabel, hasPromptStats, balance: has("balance"), usageStatusText, authHelpText}' <<<"$result") == '{"id":"deepseek","ready":true,"tierLabel":"","hasPromptStats":true,"balance":false,"usageStatusText":"","authHelpText":""}' ]] ||
  fail "DeepSeek collector prints a valid record without a key" "$result"
pass "DeepSeek collector prints a valid record without a key"

# Nothing used and no key: a record the panel skips, with the full empty
# stats block.
EMPTY_HOME=$(new_home)
result=$(collect "$EMPTY_HOME")
[[ $(jq -c '{ready, tierLabel, limits, limitsStale, limitsFetchedAt, usageStatusText, authHelpText, totalPrompts, activeDays, activeDates, modelUsage, recentDays: (.recentDays | length), balance: has("balance")}' <<<"$result") == '{"ready":false,"tierLabel":"","limits":[],"limitsStale":false,"limitsFetchedAt":0,"usageStatusText":"","authHelpText":"","totalPrompts":0,"activeDays":0,"activeDates":[],"modelUsage":{},"recentDays":7,"balance":false}' ]] ||
  fail "DeepSeek collector prints a record the panel skips without DeepSeek" "$result"
pass "DeepSeek collector prints a record the panel skips without DeepSeek"

# Profiles keep their own session trees, PI_CODING_AGENT_DIR moves pi's, and
# a home that is a git checkout ignoring everything still gets scanned. A
# fork's copy of its parent's message counts once, a line without an id
# always counts, a usage block with only a total still counts, and either
# spelling of the token fields reads.
ROOTS_HOME=$(new_home)
mkdir -p "$ROOTS_HOME/.git" "$ROOTS_HOME/.pi/agent/sessions/p" "$ROOTS_HOME/.omp/profiles/work/agent/sessions/p" "$ROOTS_HOME/moved/sessions/p"
printf '*\n' >"$ROOTS_HOME/.gitignore"
cat >"$ROOTS_HOME/.pi/agent/sessions/p/parent.jsonl" <<EOF
{"type":"message","id":"m-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":1}}}
{"type":"message","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":2}}}
{"type":"message","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":2}}}
EOF
cat >"$ROOTS_HOME/.pi/agent/sessions/p/fork.jsonl" <<EOF
{"type":"message","id":"m-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":1}}}
EOF
cat >"$ROOTS_HOME/.omp/profiles/work/agent/sessions/p/omp.jsonl" <<EOF
{"type":"message","id":"w-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"totalTokens":40}}}
{"type":"message","id":"w-2","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"inputTokens":100,"output_tokens":200,"cache_read_input_tokens":300,"cacheWriteTokens":400}}}
EOF
cat >"$ROOTS_HOME/moved/sessions/p/pi.jsonl" <<EOF
{"type":"message","id":"d-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":5000}}}
EOF
result=$(PI_CODING_AGENT_DIR="$ROOTS_HOME/moved" collect "$ROOTS_HOME")
[[ $(jq -c '{todayTotalTokens, totalPrompts, usage: .modelUsage["deepseek-v4"]}' <<<"$result") == '{"todayTotalTokens":6045,"totalPrompts":6,"usage":{"inputTokens":5145,"outputTokens":200,"cacheReadInputTokens":300,"cacheCreationInputTokens":400}}' ]] ||
  fail "DeepSeek collector reads every pi and omp session root once per message" "$result"
pass "DeepSeek collector reads every pi and omp session root once per message"

# A timestamp or token count that can't be trusted costs its row or field,
# never the scan.
BAD_HOME=$(new_home)
mkdir -p "$BAD_HOME/.pi/agent/sessions/p"
cat >"$BAD_HOME/.pi/agent/sessions/p/pi.jsonl" <<EOF
{"type":"message","id":"b-1","timestamp":true,"message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":1000}}}
{"type":"message","id":"b-2","timestamp":-5,"message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":1000}}}
{"type":"message","id":"b-3","timestamp":1e300,"message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":1000}}}
{"type":"message","id":"b-4","timestamp":"yesterday-ish","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":1000}}}
{"type":"message","id":"b-5","timestamp":NaN,"message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":1000}}}
{"type":"message","id":"b-6","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":7,"output":true,"cacheRead":-50,"cacheWrite":1e300}}}
{"type":"message","id":"b-7","timestamp":$now_ms,"message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":3}}}
EOF
result=$(collect "$BAD_HOME")
[[ $(jq -c '{todayTotalTokens, totalPrompts}' <<<"$result") == '{"todayTotalTokens":10,"totalPrompts":2}' ]] ||
  fail "DeepSeek collector skips untrusted timestamps and token counts" "$result"
pass "DeepSeek collector skips untrusted timestamps and token counts"

# ---------------------------------------------------------------- opencode

OPENCODE_HOME=$(new_home)

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

def message(id, provider, model, input=0, output=0, reasoning=0, read=0, write=0):
  return (id, "ses_1", now_ms, now_ms, json.dumps({
    "role": "assistant",
    "providerID": provider,
    "modelID": model,
    "tokens": {"input": input, "output": output, "reasoning": reasoning, "cache": {"read": read, "write": write}},
    "time": {"created": now_ms},
  }))

conn.executemany(
  "INSERT INTO message VALUES (?, ?, ?, ?, ?)",
  [
    message("m-1", "deepseek", "deepseek-model", input=100, output=20, reasoning=5, read=30, write=2),
    message("m-2", "openai", "gpt-model", input=999, output=999),
    message("m-3", "anthropic", "claude-model", input=999, output=999),
  ],
)
conn.commit()
conn.close()
PY

result=$(collect "$OPENCODE_HOME")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "157" ]] ||
  fail "DeepSeek collector counts opencode messages on a DeepSeek provider" "$result"
pass "DeepSeek collector counts opencode messages on a DeepSeek provider"

[[ $(jq -c '.modelUsage["deepseek-model"]' <<<"$result") == '{"inputTokens":100,"outputTokens":25,"cacheReadInputTokens":30,"cacheCreationInputTokens":2}' ]] ||
  fail "DeepSeek collector keeps reasoning with output and cache apart in opencode" "$result"
pass "DeepSeek collector keeps reasoning with output and cache apart in opencode"

# A day active in both pi and opencode is still one active day.
mkdir -p "$OPENCODE_HOME/.pi/agent/sessions/project"
cp "$PI_HOME/.pi/agent/sessions/project/pi.jsonl" "$OPENCODE_HOME/.pi/agent/sessions/project/"
result=$(collect "$OPENCODE_HOME" --force)

[[ $(jq -r '"\(.todayTotalTokens):\(.totalSessions):\(.activeDays)"' <<<"$result") == "176:2:1" ]] ||
  fail "DeepSeek collector counts a day shared by pi and opencode once" "$result"
pass "DeepSeek collector counts a day shared by pi and opencode once"

# OpenCode V2 nests the provider under `model` and spends tokens on
# compactions too. A message migrated into both stores counts once, and a
# fork's copies of its source's messages don't count again. OPENCODE_DB
# points at the database the way opencode itself reads it.
V2_HOME=$(new_home)

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
  v2("msg_1", "ses_a", "assistant", "deepseek", "deepseek-v4", 100, now_ms - 4000),
  v2("msg_2", "ses_a", "compaction", "deepseek", "deepseek-v4", 10, now_ms - 3000),
  v2("msg_3", "ses_a", "assistant", "deepseek-proxy", "deepseek-v4", 999),
  v2("msg_4", "ses_b", "assistant", "deepseek", "deepseek-v4", 100, forked_ms - 4000),
  v2("msg_5", "ses_b", "assistant", "deepseek", "deepseek-v4", 1),
])
conn.execute("INSERT INTO message VALUES ('msg_1', 'ses_a', ?, ?, ?)", (now_ms, now_ms, json.dumps({
  "role": "assistant", "providerID": "deepseek", "modelID": "deepseek-v4",
  "tokens": {"input": 100, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
  "time": {"created": now_ms - 4000},
})))
conn.commit()
conn.close()
PY

result=$(OPENCODE_DB="$V2_HOME/elsewhere/opencode-dev.db" collect "$V2_HOME")
[[ $(jq -c '{todayTotalTokens, totalPrompts, totalSessions, models: (.modelUsage | keys)}' <<<"$result") == '{"todayTotalTokens":111,"totalPrompts":3,"totalSessions":2,"models":["deepseek-v4"]}' ]] ||
  fail "DeepSeek collector reads opencode V2 records once each, without fork copies" "$result"
pass "DeepSeek collector reads opencode V2 records once each, without fork copies"

# Only a build whose channel was "v2" wrote opencode-v2.db; it is read when
# the usual database is missing.
LEGACY_HOME=$(new_home)
mkdir -p "$LEGACY_HOME/.local/share/opencode"
cp "$V2_HOME/elsewhere/opencode-dev.db" "$LEGACY_HOME/.local/share/opencode/opencode-v2.db"
result=$(collect "$LEGACY_HOME")
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "111" ]] ||
  fail "DeepSeek collector falls back to opencode-v2.db" "$result"
pass "DeepSeek collector falls back to opencode-v2.db"

# ---------------------------------------------------------- DeepSeek Harness

# dsh keeps one event log per session under $DSH_HOME/sessions, Zstandard-
# compressed by default. Only its DeepSeek routes count; a retry's settled
# answer replaces the streamed sample of the same step; a fork's inherited
# history is its parent's; a torn final record is dropped; and only the
# newest generation of a session is read.
DSH_ROOT=$(new_home)
python3 - "$DSH_ROOT/dsh/sessions" "$now_ms" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
now = int(sys.argv[2])

try:
  from compression import zstd
except ImportError:
  zstd = None


def header(session, seeded=False):
  return {"type": "session", "version": 4, "id": session, "createdAt": now, "isSeeded": seeded, "delegationDepth": 0}


def route(provider, model, seq=1):
  return {"type": "request/header", "seq": seq, "time": now, "data": {"header": {"config": {"provider": provider, "model": model}}, "reason": "initial"}}


def message(turn, step, usage, seq=2, kind="assistant/message"):
  data = {"turn": turn, "step": step, "stream": []}
  if kind == "assistant/message":
    data["usage"] = usage
  else:
    data["stream"] = [{"type": "chunk", "chunk": {"type": "usage", "usage": usage}}]
  return {"type": kind, "seq": seq, "time": now, "data": data}


def usage(input, output=0, read=0, write=0):
  return {"inputTokens": input, "outputTokens": output, "cacheReadTokens": read, "cacheWriteTokens": write}


def write(path, records, compressed, torn=b""):
  path.parent.mkdir(parents=True, exist_ok=True)
  lines = [(json.dumps(record) + "\n").encode() for record in records]
  if compressed:
    path.write_bytes(b"".join(zstd.compress(line) for line in lines) + torn)
  else:
    path.write_bytes(b"".join(lines) + torn)


compressed = zstd is not None
suffix = ".jsonl.zstd" if compressed else ".jsonl"
project = root / "--home-me-code--"

# A DeepSeek session: one step streamed a sample, then settled with the real
# count; a retry of step 2 adds a second billed attempt.
write(project / "s1" / ("session.v4" + suffix), [
  header("s1"),
  route("deepseek-official", "deepseek-v4-pro"),
  message(1, 1, usage(1, 1), kind="assistant/attempt"),
  message(1, 1, usage(100, 10, 20, 0)),
  message(1, 2, usage(5, 1), kind="assistant/attempt"),
  {"type": "llm/retry-started", "seq": 9, "time": now, "data": {"turn": 1, "step": 2}},
  message(1, 2, usage(7, 3)),
], compressed, torn=b'{"type":"assistant/mess' if not compressed else b"\x28\xb5\x2f\xfd")
# An older generation of the same session is migration history only.
write(project / "s1" / "session.jsonl", [header("s1"), route("deepseek-official", "deepseek-v4-pro"), message(1, 1, usage(999999))], False)

# A route billed by someone else.
write(project / "s2" / ("session.v4" + suffix), [
  header("s2"),
  route("pi-ai:anthropic", "claude-opus-5"),
  message(1, 1, usage(888888)),
], compressed)

# A fork of s1: its copy of the parent's step is inherited, and only what
# follows its seed marker was spent in it.
write(project / "s3" / ("session.v4" + suffix), [
  header("s3", seeded=True),
  route("deepseek-official", "deepseek-v4-pro"),
  message(1, 1, usage(100, 10, 20, 0)),
  {"type": "session/end-seed", "seq": 4, "time": now, "data": {"inherited": True}},
  route("deepseek-account", "deepseek-v4-flash", seq=5),
  message(2, 1, usage(4000, 6, 0, 1)),
], compressed)

# A root written with compression off reads the same, torn tail and all.
write(project / "s4" / "session.v4.jsonl", [
  header("s4"),
  route("deepseek-official", "deepseek-chat"),
  message(1, 1, usage(30000)),
], False, torn=b'{"type":"assistant/mess')
PY

result=$(DSH_HOME="$DSH_ROOT/dsh" collect "$DSH_ROOT")
[[ $(jq -c '{todayTotalTokens, totalPrompts, totalSessions, modelUsage}' <<<"$result") == '{"todayTotalTokens":34153,"totalPrompts":5,"totalSessions":3,"modelUsage":{"deepseek-v4-pro":{"inputTokens":112,"outputTokens":14,"cacheReadInputTokens":20,"cacheCreationInputTokens":0},"deepseek-v4-flash":{"inputTokens":4000,"outputTokens":6,"cacheReadInputTokens":0,"cacheCreationInputTokens":1},"deepseek-chat":{"inputTokens":30000,"outputTokens":0,"cacheReadInputTokens":0,"cacheCreationInputTokens":0}}}' ]] ||
  fail "DeepSeek collector counts DeepSeek Harness sessions on its DeepSeek routes" "$result"
pass "DeepSeek collector counts DeepSeek Harness sessions on its DeepSeek routes"

# dsh keeps its key in its managed .credentials.yaml, or a .env beside it.
# With no network to answer, the key still makes DeepSeek ready and prepaid.
mkdir -p "$DSH_ROOT/dsh"
cat >"$DSH_ROOT/dsh/.credentials.yaml" <<'EOF'
# managed by dsh
version: 1
refs:
  OTHER_KEY: nope
  DEEPSEEK_API_KEY: "sk-from-dsh" # stored by the Models page
EOF
key=$(HOME="$DSH_ROOT" DSH_HOME="$DSH_ROOT/dsh" python3 - "$ROOT/bin/omarchy-agent-usage-deepseek" <<'PY'
import importlib.machinery
import importlib.util
import sys

loader = importlib.machinery.SourceFileLoader("deepseek_collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
first = collector.api_key()
(collector.dsh_home() / ".credentials.yaml").unlink()
(collector.dsh_home() / ".env").write_text("export DEEPSEEK_API_KEY='sk-from-env-file'\n")
print(first + " " + collector.api_key())
PY
)
[[ $key == "sk-from-dsh sk-from-env-file" ]] ||
  fail "DeepSeek collector reads dsh's stored key" "$key"
pass "DeepSeek collector reads dsh's stored key"

# --------------------------------------------------------------- scan cache

# A normal run reuses a scan for a few seconds, --limits-only for longer,
# and --force rescans.
CACHE_HOME=$(new_home)
mkdir -p "$CACHE_HOME/.pi/agent/sessions/p"
cat >"$CACHE_HOME/.pi/agent/sessions/p/pi.jsonl" <<EOF
{"type":"message","id":"c-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":7,"output":3}}}
EOF
result=$(collect "$CACHE_HOME")
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "10" ]] ||
  fail "DeepSeek collector scans without a cache" "$result"
[[ -n $(find "$CACHE_HOME/.cache/omarchy/agent-usage" -name 'deepseek-scan-*.json' -print -quit) ]] ||
  fail "DeepSeek collector writes a scan cache"

cat >>"$CACHE_HOME/.pi/agent/sessions/p/pi.jsonl" <<EOF
{"type":"message","id":"c-2","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-v4","usage":{"input":90}}}
EOF
result=$(collect "$CACHE_HOME")
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "10" ]] ||
  fail "DeepSeek collector reuses a recent scan" "$result"
result=$(collect "$CACHE_HOME" --limits-only)
[[ $(jq -c '{todayTotalTokens, totalPrompts}' <<<"$result") == '{"todayTotalTokens":10,"totalPrompts":1}' ]] ||
  fail "DeepSeek collector --limits-only emits a complete record from cache" "$result"
result=$(collect "$CACHE_HOME" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "100" ]] ||
  fail "DeepSeek collector --force rescans" "$result"
pass "DeepSeek collector caches and reuses local stats"

# Without rg the sessions can't be read, and a scan missing them is never
# cached as the whole story.
rm -rf "$CACHE_HOME/.cache"
HOME="$CACHE_HOME" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/no-bin" "$ROOT/bin/omarchy-agent-usage-deepseek" >/dev/null 2>&1
[[ -z $(find "$CACHE_HOME/.cache" -name 'deepseek-scan-*.json' 2>/dev/null) ]] ||
  fail "DeepSeek collector doesn't cache a scan that couldn't read the sessions"
pass "DeepSeek collector doesn't cache a scan that couldn't read the sessions"
