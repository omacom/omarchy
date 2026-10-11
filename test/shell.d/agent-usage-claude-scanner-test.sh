#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

# Every fixture home lives under one scratch directory, cleaned up at exit.
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT
TEST_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")

projects="$TEST_HOME/.claude/projects/example"
mkdir -p "$projects"

timestamp="$(date +%Y-%m-%d)T12:00:00Z"
cat >"$projects/session.jsonl" <<EOF
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-1","message":{"id":"message-1","role":"assistant","model":"claude-test","usage":{"input_tokens":2,"cache_creation_input_tokens":28857,"cache_read_input_tokens":0,"output_tokens":231}}}
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-2","message":{"id":"message-1","role":"assistant","model":"claude-test","usage":{"input_tokens":2,"cache_creation_input_tokens":28857,"cache_read_input_tokens":0,"output_tokens":231}}}
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-3","message":{"id":"message-2","role":"assistant","model":"claude-test","usage":{"input_tokens":2,"cache_creation_input_tokens":454,"cache_read_input_tokens":28857,"output_tokens":390}}}
EOF

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_DATA_HOME="$TEST_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "58793" ]] ||
  fail "Claude collector counts each API message once" "$result"
pass "Claude collector counts each API message once"

[[ $(jq -c '.modelUsage["claude-test"]' <<<"$result") == '{"cacheCreationInputTokens":29311,"cacheReadInputTokens":28857,"inputTokens":4,"outputTokens":621}' ]] ||
  fail "Claude collector keeps mutually exclusive token categories" "$result"
pass "Claude collector keeps mutually exclusive token categories"


[[ $(jq -r '.id + "/" + .usageStatusText' <<<"$result") == "claude/Waiting for auth" ]] ||
  fail "Claude collector identifies itself and reports missing auth" "$result"
pass "Claude collector identifies itself and reports missing auth"

# Transcripts only ever grow, so a refresh reads what was appended since the
# last one and takes the rest from the scan index.
cat >>"$projects/session.jsonl" <<EOF
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-4","message":{"id":"message-3","role":"assistant","model":"claude-test","usage":{"input_tokens":1,"cache_creation_input_tokens":0,"cache_read_input_tokens":200,"output_tokens":6}}}
EOF

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_DATA_HOME="$TEST_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --cache-seconds 0)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "59000" ]] ||
  fail "Claude collector picks up lines appended since the last scan" "$result"
pass "Claude collector picks up lines appended since the last scan"

index=$(ls "$TEST_HOME"/.cache/omarchy/agent-usage/claude-index-*.json 2>/dev/null | head -1)
[[ -n $index && $(jq -r '.files | to_entries[0].value.records | length' "$index") == "3" ]] ||
  fail "Claude collector keeps one record per API message in the scan index" "$(cat "$index" 2>/dev/null)"
pass "Claude collector keeps one record per API message in the scan index"

# An unchanged file is not opened again: its records come from the index.
chmod 000 "$projects/session.jsonl"
result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_DATA_HOME="$TEST_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --cache-seconds 0 2>/dev/null)
chmod 644 "$projects/session.jsonl"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "59000" ]] ||
  fail "Claude collector serves unchanged transcripts from the scan index" "$result"
pass "Claude collector serves unchanged transcripts from the scan index"

# A file that shrank was rewritten, not appended to; it is read from the start.
head -n 1 "$projects/session.jsonl" >"$projects/session.jsonl.new"
mv "$projects/session.jsonl.new" "$projects/session.jsonl"
result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_DATA_HOME="$TEST_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --cache-seconds 0)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "29090" ]] ||
  fail "Claude collector rescans a transcript that was rewritten" "$result"
pass "Claude collector rescans a transcript that was rewritten"

# A transcript replaced by a larger one, or rewritten in place with more than
# it had, is a new file rather than an append: nothing of the old one stays,
# and the new one is read from its start.
INDEX_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
index_projects="$INDEX_HOME/.claude/projects/example"
mkdir -p "$index_projects"
index_line() {
  printf '{"timestamp":"%s","type":"assistant","sessionId":"s","message":{"id":"%s","role":"assistant","model":"claude-test","usage":{"input_tokens":%s,"output_tokens":0}}}\n' "$timestamp" "$1" "$2"
}
index_scan() {
  HOME="$INDEX_HOME" XDG_CACHE_HOME="$INDEX_HOME/.cache" XDG_DATA_HOME="$INDEX_HOME/.local/share" \
    "$ROOT/bin/omarchy-agent-usage-claude" --cache-seconds 0 "$@"
}

index_line old-1 1000 >"$index_projects/session.jsonl"
index_scan >/dev/null
{ index_line new-1 20; index_line new-2 30; } >"$index_projects/session.jsonl.new"
mv "$index_projects/session.jsonl.new" "$index_projects/session.jsonl"
[[ $(index_scan | jq -c '[.todayTotalTokens, .totalPrompts]') == '[50,2]' ]] ||
  fail "Claude collector reads a transcript replaced by a larger one from its start" "$(index_scan)"

{ index_line other-1 7; index_line other-2 8; index_line other-3 9; } >"$index_projects/session.jsonl"
[[ $(index_scan | jq -c '[.todayTotalTokens, .totalPrompts]') == '[24,3]' ]] ||
  fail "Claude collector reads a transcript rewritten in place from its start" "$(index_scan)"
pass "Claude collector rereads a transcript that was replaced or rewritten"

# A rewrite in place that grows the file and changes only its end keeps the
# first kilobytes, so the end of what was read is checked too.
for i in $(seq 1 60); do index_line "long-$i" 100; done >"$index_projects/session.jsonl"
index_scan >/dev/null
{ for i in $(seq 1 59); do index_line "long-$i" 100; done; index_line long-60 5000; index_line long-61 1; } >"$index_projects/session.jsonl"
[[ $(index_scan | jq -r '.todayTotalTokens') == "10901" ]] ||
  fail "Claude collector rereads a transcript whose end was rewritten in place" "$(index_scan)"
pass "Claude collector rereads a transcript whose end was rewritten in place"

# A larger replacement that matches both ends of what was read but differs in
# between is still a different file, so it is read from its start.
for i in $(seq 1 200); do index_line "mid-$i" 100; done >"$index_projects/session.jsonl"
index_scan >/dev/null
{ for i in $(seq 1 200); do if (( i == 100 )); then index_line "mid-$i" 900; else index_line "mid-$i" 100; fi; done; index_line mid-201 1; } >"$index_projects/session.jsonl.new"
mv "$index_projects/session.jsonl.new" "$index_projects/session.jsonl"
[[ $(index_scan | jq -r '.todayTotalTokens') == "20801" ]] ||
  fail "Claude collector rereads a replacement whose ends match" "$(index_scan)"
pass "Claude collector rereads a replacement whose ends match"

# The index holds local days, so a new timezone reads every transcript again
# rather than keep the days another timezone gave them.
zone_timestamp="$(date -u +%Y-%m-%d)T01:00:00Z"
printf '{"timestamp":"%s","type":"assistant","sessionId":"s","message":{"id":"zone-1","role":"assistant","model":"claude-test","usage":{"input_tokens":5,"output_tokens":0}}}\n' "$zone_timestamp" >"$index_projects/session.jsonl"
TZ=UTC index_scan >/dev/null
zone_dates=$(TZ=America/Los_Angeles index_scan | jq -r '.activeDates | join(",")')
[[ $zone_dates == "$(TZ=America/Los_Angeles date -d "$zone_timestamp" +%Y-%m-%d)" ]] ||
  fail "Claude collector recomputes indexed days after a timezone change" "$zone_dates"
pass "Claude collector recomputes indexed days after a timezone change"

# A streamed response is several lines sharing one message id. The first
# line's output_tokens is a placeholder and the last line has the real count,
# so the message is counted from the line with the highest output.
STREAM_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
stream_projects="$STREAM_HOME/.claude/projects/example"
mkdir -p "$stream_projects"
cat >"$stream_projects/session.jsonl" <<EOF
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-1","message":{"id":"message-1","role":"assistant","model":"claude-test","usage":{"input_tokens":8,"cache_creation_input_tokens":100,"cache_read_input_tokens":2000,"output_tokens":1}}}
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-2","message":{"id":"message-1","role":"assistant","model":"claude-test","usage":{"input_tokens":8,"cache_creation_input_tokens":100,"cache_read_input_tokens":2000,"output_tokens":1}}}
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-3","message":{"id":"message-1","role":"assistant","model":"claude-test","usage":{"input_tokens":8,"cache_creation_input_tokens":100,"cache_read_input_tokens":2000,"output_tokens":260}}}
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-4","message":{"id":"message-2","role":"assistant","model":"claude-test","usage":{"input_tokens":10,"cache_creation_input_tokens":300,"cache_read_input_tokens":4000,"output_tokens":1}}}
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-5","message":{"id":"message-2","role":"assistant","model":"claude-fallback","usage":{"input_tokens":10,"cache_creation_input_tokens":0,"cache_read_input_tokens":3500,"output_tokens":40}}}
EOF

result=$(HOME="$STREAM_HOME" XDG_CACHE_HOME="$STREAM_HOME/.cache" XDG_DATA_HOME="$STREAM_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --force)

[[ $(jq -c '.modelUsage["claude-test"]' <<<"$result") == '{"cacheCreationInputTokens":100,"cacheReadInputTokens":2000,"inputTokens":8,"outputTokens":260}' ]] ||
  fail "Claude collector counts a streamed message from its final usage line" "$result"
pass "Claude collector counts a streamed message from its final usage line"

# A response that fell back to another model mid-stream has lines that are
# separate snapshots: the final line's model and cache figures are kept whole
# rather than a maximum taken per field across both.
[[ $(jq -c '.modelUsage["claude-fallback"]' <<<"$result") == '{"cacheCreationInputTokens":0,"cacheReadInputTokens":3500,"inputTokens":10,"outputTokens":40}' ]] ||
  fail "Claude collector keeps the final line whole after a mid-stream fallback" "$result"
[[ $(jq -r '.totalPrompts' <<<"$result") == "2" ]] ||
  fail "Claude collector keeps the final line whole after a mid-stream fallback" "$result"
pass "Claude collector keeps the final line whole after a mid-stream fallback"

# A stream still being written when the index was taken finishes in lines
# appended later; the indexed message takes the higher count from them.
result=$(HOME="$STREAM_HOME" XDG_CACHE_HOME="$STREAM_HOME/.cache" XDG_DATA_HOME="$STREAM_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --cache-seconds 0)
cat >>"$stream_projects/session.jsonl" <<EOF
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-6","message":{"id":"message-2","role":"assistant","model":"claude-fallback","usage":{"input_tokens":10,"cache_creation_input_tokens":0,"cache_read_input_tokens":3500,"output_tokens":90}}}
EOF
result=$(HOME="$STREAM_HOME" XDG_CACHE_HOME="$STREAM_HOME/.cache" XDG_DATA_HOME="$STREAM_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --cache-seconds 0)
[[ $(jq -c '[.modelUsage["claude-fallback"].outputTokens, .totalPrompts]' <<<"$result") == '[90,2]' ]] ||
  fail "Claude collector takes a streamed message's final count from appended lines" "$result"
pass "Claude collector takes a streamed message's final count from appended lines"

# A cache stamped in the future can happen when NTP moves the clock backwards
# after an early boot scan. Its age is not trustworthy, so it must be a miss
# rather than freezing the usage snapshot until wall time catches up.
cat >>"$projects/session.jsonl" <<EOF
{"timestamp":"$timestamp","type":"assistant","sessionId":"session-1","uuid":"event-4","message":{"id":"message-3","role":"assistant","model":"claude-test","usage":{"input_tokens":7,"cache_creation_input_tokens":0,"cache_read_input_tokens":0,"output_tokens":3}}}
EOF
cache_file=$(find "$TEST_HOME/.cache/omarchy/agent-usage" -name 'claude-scan-*.json' -print -quit)
touch -d "@$(( $(date +%s) + 3600 ))" "$cache_file"

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_DATA_HOME="$TEST_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "29100" ]] ||
  fail "Claude collector treats a future-dated scan cache as a miss" "$result"
pass "Claude collector treats a future-dated scan cache as a miss"

# A machine with no transcripts and no stats-cache still gets today's counts
# from history.jsonl alone.
HISTORY_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$HISTORY_HOME/.claude"

now_ms=$(($(date +%s) * 1000))
cat >"$HISTORY_HOME/.claude/history.jsonl" <<EOF
{"timestamp":86400000,"sessionId":"old","display":"ancient"}
{"timestamp":$now_ms,"sessionId":"s1","display":"one"}
{"timestamp":$now_ms,"sessionId":"s2","display":"two"}
EOF

result=$(HOME="$HISTORY_HOME" XDG_CACHE_HOME="$HISTORY_HOME/.cache" XDG_DATA_HOME="$HISTORY_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --force)

[[ $(jq -r '(.todayPrompts|tostring) + "/" + (.todaySessions|tostring)' <<<"$result") == "2/2" ]] ||
  fail "Claude collector falls back to history.jsonl without a stats-cache" "$result"
pass "Claude collector falls back to history.jsonl without a stats-cache"

# A subscription burned entirely through opencode has no ~/.claude transcripts;
# usage must come from opencode's message database, filtered to Anthropic.
OPENCODE_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")

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
  message("msg_1", "anthropic", "claude-opus-5", input=100, output=50, reasoning=7, read=25, write=10),
  message("msg_2", "fireworks-ai", "accounts/fireworks/models/kimi-k3", input=999, output=999),
  message("msg_3", "openai", "gpt-5.2-codex", input=999, output=999),
  message("msg_4", "anthropic", "claude-opus-5", role="user"),
  message("msg_5", "anthropic-proxy", "claude-opus-5", input=999, output=999),
])
conn.execute("INSERT INTO message VALUES ('msg_6', 'ses_1', ?, ?, '[\"not\",\"an\",\"object\"]')", (now_ms, now_ms))
conn.commit()
conn.close()
PY

result=$(HOME="$OPENCODE_HOME" XDG_CACHE_HOME="$OPENCODE_HOME/.cache" XDG_DATA_HOME="$OPENCODE_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --force)

[[ $(jq -r '(.ready|tostring) + "/" + (.todayTotalTokens|tostring)' <<<"$result") == "true/192" ]] ||
  fail "Claude collector counts Anthropic usage, reasoning included, from opencode sessions" "$result"
pass "Claude collector counts Anthropic usage, reasoning included, from opencode sessions"

[[ $(jq -c '.modelUsage' <<<"$result") == '{"claude-opus-5":{"cacheCreationInputTokens":10,"cacheReadInputTokens":25,"inputTokens":100,"outputTokens":57}}' ]] ||
  fail "Claude collector ignores prefix-colliding providers, user messages, and malformed rows" "$result"
pass "Claude collector ignores prefix-colliding providers, user messages, and malformed rows"

# opencode v2 writes session_message instead of message: the role is its own
# column and the provider and model nest under data.model. An upgraded
# database keeps its v1 rows, so both tables count.
OPENCODE_V2_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")

python3 - "$OPENCODE_V2_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
now_ms = int(time.time() * 1000)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.execute("INSERT INTO message VALUES ('msg_1', 'ses_1', ?, ?, ?)", (now_ms, now_ms, json.dumps({
  "role": "assistant", "providerID": "anthropic", "modelID": "claude-opus-5",
  "tokens": {"input": 1, "output": 1, "reasoning": 0, "cache": {"read": 0, "write": 0}},
  "time": {"created": now_ms},
})))
conn.execute("""CREATE TABLE session_message (
  id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL,
  seq integer NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)""")

def v2_message(id, provider, model, type="assistant", input=0, output=0, reasoning=0, read=0, write=0):
  return (id, "ses_v2", type, 1, now_ms, now_ms, json.dumps({
    "model": {"id": model, "providerID": provider, "variant": "xhigh"},
    "tokens": {"input": input, "output": output, "reasoning": reasoning, "cache": {"read": read, "write": write}},
    "time": {"created": now_ms, "completed": now_ms},
  }))

conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?, ?, ?)", [
  v2_message("v_1", "anthropic", "claude-opus-5-5", input=4, output=96, reasoning=775, write=50180),
  v2_message("v_2", "anthropic", "claude-opus-5-5", type="user", input=999),
  v2_message("v_3", "anthropic-proxy", "claude-opus-5-5", input=999),
  v2_message("v_4", "openai", "gpt-5.6", input=999),
])
conn.execute("INSERT INTO session_message VALUES ('v_5', 'ses_v2', 'assistant', 1, ?, ?, 'not json')", (now_ms, now_ms))
conn.commit()
conn.close()
PY

result=$(HOME="$OPENCODE_V2_HOME" XDG_CACHE_HOME="$OPENCODE_V2_HOME/.cache" XDG_DATA_HOME="$OPENCODE_V2_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --force)

[[ $(jq -r '(.todayTotalTokens|tostring) + "/" + (.todaySessions|tostring)' <<<"$result") == "51057/2" ]] ||
  fail "Claude collector counts Anthropic usage from opencode v2 sessions" "$result"
pass "Claude collector counts Anthropic usage from opencode v2 sessions"

[[ $(jq -c '.modelUsage["claude-opus-5-5"]' <<<"$result") == '{"cacheCreationInputTokens":50180,"cacheReadInputTokens":0,"inputTokens":4,"outputTokens":871}' ]] ||
  fail "Claude collector reads the model from opencode v2's nested model" "$result"
pass "Claude collector reads the model from opencode v2's nested model"

# A fresh v2 install has no legacy message table at all.
python3 -c 'import sqlite3, sys; c = sqlite3.connect(sys.argv[1]); c.execute("DROP TABLE message"); c.commit()' \
  "$OPENCODE_V2_HOME/.local/share/opencode/opencode.db"

result=$(HOME="$OPENCODE_V2_HOME" XDG_CACHE_HOME="$OPENCODE_V2_HOME/.cache" XDG_DATA_HOME="$OPENCODE_V2_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --force)

[[ $(jq -r '(.todayTotalTokens|tostring) + "/" + (.todaySessions|tostring)' <<<"$result") == "51055/1" ]] ||
  fail "Claude collector counts a v2-only opencode database" "$result"
pass "Claude collector counts a v2-only opencode database"

# Pi and omp can both spend a Claude subscription without writing native
# Claude Code transcripts. Their compatible JSONL sessions must be included.
PI_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$PI_HOME/.pi/agent/sessions/project" "$PI_HOME/.omp/agent/sessions/project" \
  "$PI_HOME/.omp/profiles/work/agent/sessions/project"

cat >"$PI_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"pi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"anthropic","api":"anthropic-messages","model":"claude-pi","usage":{"input":10,"output":4,"cacheRead":3,"cacheWrite":2,"totalTokens":19}}}
{"type":"message","id":"codex-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","model":"gpt-test","usage":{"input":999,"output":999}}}
{"type":"message","id":"kimi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"kimi-coding","api":"anthropic-messages","model":"k3","usage":{"input":999,"output":999}}}
EOF
cat >"$PI_HOME/.omp/agent/sessions/project/omp.jsonl" <<EOF
{ "type": "message", "id": "omp-1", "timestamp": "$timestamp", "message": { "role": "assistant", "provider": "anthropic", "model": "claude-omp", "usage": { "input": 20, "output": 5, "cacheRead": 4, "cacheWrite": 1, "totalTokens": 30 } } }
EOF
# `omp --profile=<name>` moves the whole agent tree under profiles/<name>/, so a
# subscription spent entirely through a profile leaves the default root empty.
cat >"$PI_HOME/.omp/profiles/work/agent/sessions/project/omp-profile.jsonl" <<EOF
{"type":"message","id":"omp-profile-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"anthropic","model":"claude-omp-profile","usage":{"input":7,"output":3,"cacheRead":2,"cacheWrite":1,"totalTokens":13}}}
EOF

result=$(HOME="$PI_HOME" XDG_CACHE_HOME="$PI_HOME/.cache" XDG_DATA_HOME="$PI_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-claude" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "62" ]] ||
  fail "Claude collector counts usage from pi and omp sessions" "$result"
[[ $(jq -c '.modelUsage' <<<"$result") == '{"claude-omp":{"cacheCreationInputTokens":1,"cacheReadInputTokens":4,"inputTokens":20,"outputTokens":5},"claude-omp-profile":{"cacheCreationInputTokens":1,"cacheReadInputTokens":2,"inputTokens":7,"outputTokens":3},"claude-pi":{"cacheCreationInputTokens":2,"cacheReadInputTokens":3,"inputTokens":10,"outputTokens":4}}' ]] ||
  fail "Claude collector filters pi and omp sessions to Anthropic providers" "$result"
pass "Claude collector counts pi and omp subscription usage, profiles included"

# Collectors overlap in practice: the update command backgrounds one per agent
# while the panel refreshes on its own. Two writers aiming at one cache file
# must both land, not trip over a shared temp path.
race_output=$(python3 - "$ROOT/bin/omarchy-agent-usage-claude" "$TEST_HOME/race.json" <<'PY'
import importlib.util
import json
import sys
import threading
from importlib.machinery import SourceFileLoader
from pathlib import Path

# The collector has no .py suffix, so name its loader explicitly.
spec = importlib.util.spec_from_loader("collector", SourceFileLoader("collector", sys.argv[1]))
collector = importlib.util.module_from_spec(spec)
spec.loader.exec_module(collector)

target = Path(sys.argv[2])
failures = []
start = threading.Barrier(8)

def hammer(writer):
  start.wait()
  for round in range(25):
    try:
      collector.write_json(target, {"writer": writer, "round": round})
    except Exception as error:
      failures.append(repr(error))

threads = [threading.Thread(target=hammer, args=(writer,)) for writer in range(8)]
for thread in threads:
  thread.start()
for thread in threads:
  thread.join()

leftovers = sorted(path.name for path in target.parent.glob(target.name + ".*"))
print(json.dumps({
  "failures": failures[:3],
  "mode": oct(target.stat().st_mode & 0o777),
  "payload": json.loads(target.read_text(encoding="utf-8")),
  "leftovers": leftovers,
}))
PY
)

[[ $(jq -c '.failures' <<<"$race_output") == "[]" ]] ||
  fail "Claude collector survives concurrent writes to one cache file" "$race_output"
[[ $(jq -r '.payload.writer != null and (.leftovers | length) == 0' <<<"$race_output") == "true" ]] ||
  fail "Claude collector leaves one intact cache file and no temp files" "$race_output"
[[ $(jq -r '.mode' <<<"$race_output") == "0o644" ]] ||
  fail "Claude collector keeps cache files readable" "$race_output"
pass "Claude collector survives concurrent writes to one cache file"

# Unreadable transcript files are expected when an agent has run as another
# user, so report one bounded summary rather than one log line per file.
UNREADABLE_DIR=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$UNREADABLE_DIR/project"
touch "$UNREADABLE_DIR/project/unreadable-1.jsonl" \
  "$UNREADABLE_DIR/project/unreadable-2.jsonl" \
  "$UNREADABLE_DIR/project/unreadable-3.jsonl" \
  "$UNREADABLE_DIR/project/unreadable-4.jsonl" \
  "$UNREADABLE_DIR/project/unreadable-5.jsonl"

warning=$(python3 - "$ROOT/bin/omarchy-agent-usage-claude" "$UNREADABLE_DIR" <<'PY'
import contextlib
import importlib.util
import io
import sys
from importlib.machinery import SourceFileLoader
from pathlib import Path

spec = importlib.util.spec_from_loader("collector", SourceFileLoader("collector", sys.argv[1]))
collector = importlib.util.module_from_spec(spec)
spec.loader.exec_module(collector)

original_open = Path.open

def deny_unreadable(path, *args, **kwargs):
  if path.name.startswith("unreadable-"):
    raise PermissionError("permission denied")
  return original_open(path, *args, **kwargs)

collector.Path.open = deny_unreadable
with contextlib.redirect_stderr(io.StringIO()) as stderr:
  collector.scan_projects(Path(sys.argv[2]))
print(stderr.getvalue(), end="")
PY
)

[[ $(grep -c '^Ignoring ' <<<"$warning") == 1 ]] ||
  fail "Claude collector emits one bounded warning for unreadable transcripts" "$warning"
grep -q '^Ignoring 5 unreadable Claude project files' <<<"$warning" ||
  fail "Claude collector reports the unreadable transcript count" "$warning"
pass "Claude collector bounds unreadable transcript warnings"
