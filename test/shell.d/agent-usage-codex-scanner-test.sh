#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3
require_command git
require_command rg

# Every fixture home lives under one scratch directory, cleaned up at exit.
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT
TEST_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")

# A fixture home signed in to Codex, with an empty bin/ for its CLI.
signed_in_home() {
  local home
  home=$(mktemp -d "$SCRATCH/home.XXXXXX")
  mkdir -p "$home/bin" "$home/.codex"
  touch "$home/.codex/auth.json"
  printf '%s\n' "$home"
}

mkdir -p "$TEST_HOME/.codex/sessions/$(date +%Y/%m/%d)" "$TEST_HOME/bin"
touch "$TEST_HOME/.codex/auth.json"

cat >"$TEST_HOME/bin/codex" <<'EOF'
#!/bin/bash

if [[ -n ${CODEX_ARGS_FILE:-} ]]; then
  printf '%s\0' "$@" >"$CODEX_ARGS_FILE"
fi

while read -r request; do
  id=$(jq -r '.id // empty' <<<"$request")
  method=$(jq -r '.method // empty' <<<"$request")

  case "$method" in
    initialize)
      jq -cn --argjson id "$id" '{id: $id, result: {}}'
      ;;
    account/read)
      # Codex 0.158 can leave this one unanswered for good.
      [[ -n ${CODEX_ACCOUNT_READ_HANGS:-} ]] ||
        jq -cn --argjson id "$id" '{id: $id, result: {account: {}}}'
      ;;
    account/rateLimits/read)
      if [[ -n ${CODEX_LIMITS_ERROR:-} ]]; then
        jq -cn --argjson id "$id" --arg message "$CODEX_LIMITS_ERROR" '{id: $id, error: {code: -32600, message: $message}}'
        continue
      fi
      jq -cn --argjson id "$id" --argjson limits "${CODEX_RATE_LIMITS:-{\}}" --argjson credits "${CODEX_RESET_CREDITS:-null}" \
        '{id: $id, result: {rateLimits: $limits, rateLimitResetCredits: $credits}}'
      ;;
  esac
done
EOF
chmod +x "$TEST_HOME/bin/codex"

timestamp="$(date +%Y-%m-%d)T12:00:00Z"
collision_timestamp="$(date +%Y-%m-%d)T12:00:01Z"
session="$TEST_HOME/.codex/sessions/$(date +%Y/%m/%d)/rollout.jsonl"
cat >"$session" <<EOF
{"timestamp":"$timestamp","type":"turn_context","payload":{"model":"gpt-test"}}
{"timestamp":"$timestamp","type":"event_msg","payload":{"type":"token_count","info":{"total_token_usage":{"input_tokens":100,"cached_input_tokens":60,"output_tokens":20,"reasoning_output_tokens":5,"total_tokens":120},"last_token_usage":{"input_tokens":100,"cached_input_tokens":60,"output_tokens":20,"reasoning_output_tokens":5,"total_tokens":120}}}}
{"timestamp":"$timestamp","type":"event_msg","payload":{"type":"token_count","info":{"total_token_usage":{"input_tokens":180,"cached_input_tokens":110,"output_tokens":30,"reasoning_output_tokens":8,"total_tokens":210},"last_token_usage":{"input_tokens":80,"cached_input_tokens":50,"output_tokens":10,"reasoning_output_tokens":3,"total_tokens":90}}}}
{"timestamp":"$timestamp","type":"event_msg","payload":{"type":"token_count","info":{"total_token_usage":{"input_tokens":180,"cached_input_tokens":110,"output_tokens":30,"reasoning_output_tokens":8,"total_tokens":210},"last_token_usage":{"input_tokens":80,"cached_input_tokens":50,"output_tokens":10,"reasoning_output_tokens":3,"total_tokens":90}},"rate_limits":{"primary":{"used_percent":10}}}}
EOF

result=$(HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" CODEX_ARGS_FILE="$TEST_HOME/codex-args" XDG_DATA_HOME="$TEST_HOME/.local/share" PATH="$TEST_HOME/bin:$PATH" \
  "$ROOT/bin/omarchy-agent-usage-codex")

# NUL-separated, so the assertion sees argument boundaries: a single "-a on-request"
# would flatten to the same text as two arguments but is not a policy codex accepts.
expected_args=(-s read-only -a on-request app-server)
mapfile -d '' -t codex_args <"$TEST_HOME/codex-args"

[[ ${codex_args[*]@Q} == "${expected_args[*]@Q}" ]] ||
  fail "Codex collector uses the supported approval policy" "${codex_args[*]@Q}"
pass "Codex collector uses the supported approval policy"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "210" ]] ||
  fail "Codex collector counts each turn once" "$result"
pass "Codex collector counts each turn once"

[[ $(jq -r '.todayPrompts' <<<"$result") == "2" ]] ||
  fail "Codex collector does not count repeated quota notifications as prompts" "$result"
pass "Codex collector does not count repeated quota notifications as prompts"

[[ $(jq -c '.modelUsage["gpt-test"]' <<<"$result") == '{"inputTokens":70,"outputTokens":30,"cacheReadInputTokens":110,"cacheCreationInputTokens":0}' ]] ||
  fail "Codex collector does not double-count cache or reasoning tokens" "$result"
pass "Codex collector does not double-count cache or reasoning tokens"

[[ $(jq -c '.id + "/" + (.limits|tostring)' <<<"$result") == '"codex/[]"' ]] ||
  fail "Codex collector identifies itself with an empty limits list" "$result"
pass "Codex collector identifies itself with an empty limits list"

[[ $(jq -r '.authHelpText' <<<"$result") == "" ]] ||
  fail "Codex collector clears login guidance after a successful limits read" "$result"
pass "Codex collector clears login guidance after a successful limits read"

# Pi and omp can both spend a Codex subscription without creating native
# Codex sessions. Their compatible JSONL transcripts must be included.
PI_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$PI_HOME/bin" "$PI_HOME/.pi/agent/sessions/project" "$PI_HOME/.omp/agent/sessions/project" \
  "$PI_HOME/.omp/profiles/codex/agent/sessions/project"
mkdir -p "$PI_HOME/.codex" && touch "$PI_HOME/.codex/auth.json"
cp "$TEST_HOME/bin/codex" "$PI_HOME/bin/codex"
real_rg=$(command -v rg)
cat >"$PI_HOME/bin/rg" <<EOF
#!/bin/bash
exec "$real_rg" --sort path "\$@"
EOF
chmod +x "$PI_HOME/bin/rg"
cat >"$PI_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"deadbeef","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","api":"openai-codex-responses","model":"gpt-pi","usage":{"input":10,"output":4,"cacheRead":3,"cacheWrite":2,"totalTokens":19}}}
EOF
cat >"$PI_HOME/.pi/agent/sessions/project/pi-fork.jsonl" <<EOF
{"type":"session","id":"pi-fork","parentSession":"$PI_HOME/.pi/agent/sessions/project/pi.jsonl"}
{"type":"message","id":"deadbeef","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","api":"openai-codex-responses","model":"gpt-pi","usage":{"input":10,"output":4,"cacheRead":3,"cacheWrite":2,"totalTokens":19}}}
{"type":"message","id":"cafebabe","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","api":"openai-codex-responses","model":"gpt-pi","usage":{"input":6,"output":1,"cacheRead":0,"cacheWrite":0,"totalTokens":7}}}
EOF
cat >"$PI_HOME/.pi/agent/sessions/project/pi-id-collision.jsonl" <<EOF
{"type":"message","id":"deadbeef","timestamp":"$collision_timestamp","message":{"role":"assistant","provider":"openai-codex","api":"openai-codex-responses","model":"gpt-pi","usage":{"input":8,"output":0,"cacheRead":0,"cacheWrite":0,"totalTokens":8}}}
EOF
cat >"$PI_HOME/.omp/agent/sessions/project/omp.jsonl" <<EOF
{ "type": "message", "id": "omp-1", "timestamp": "$timestamp", "message": { "role": "assistant", "provider": "openai-codex", "model": "gpt-omp", "usage": { "input": 20, "output": 5, "cacheRead": 4, "cacheWrite": 1, "totalTokens": 30 } } }
{"type":"message","id":"other-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"anthropic","model":"claude-test","usage":{"input":999,"output":999}}}
EOF
# `omp --profile=<name>` moves the whole agent tree under profiles/<name>/, so a
# subscription spent entirely through a profile leaves the default root empty.
cat >"$PI_HOME/.omp/profiles/codex/agent/sessions/project/omp-profile.jsonl" <<EOF
{"type":"message","id":"omp-profile-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","model":"gpt-omp-profile","usage":{"input":7,"output":3,"cacheRead":2,"cacheWrite":1,"totalTokens":13}}}
EOF

result=$(HOME="$PI_HOME" CODEX_HOME="$PI_HOME/.codex" XDG_DATA_HOME="$PI_HOME/.local/share" \
  PATH="$PI_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "77" ]] ||
  fail "Codex collector counts Pi fork, OMP, and profile usage once" "$result"
[[ $(jq -c '.modelUsage' <<<"$result") == '{"gpt-pi":{"inputTokens":24,"outputTokens":5,"cacheReadInputTokens":3,"cacheCreationInputTokens":2},"gpt-omp":{"inputTokens":20,"outputTokens":5,"cacheReadInputTokens":4,"cacheCreationInputTokens":1},"gpt-omp-profile":{"inputTokens":7,"outputTokens":3,"cacheReadInputTokens":2,"cacheCreationInputTokens":1}}' ]] ||
  fail "Codex collector filters pi and omp sessions to Codex providers" "$result"
[[ $(jq -r '.todayPrompts' <<<"$result") == "5" ]] ||
  fail "Codex collector keeps distinct Pi messages with colliding IDs" "$result"
[[ $(jq -c '[.todaySessions,.totalSessions]' <<<"$result") == '[5,5]' ]] ||
  fail "Codex collector attributes new fork usage to its own session" "$result"
pass "Codex collector deduplicates Pi forks without collapsing ID collisions, profiles included"

# A Pi transcript can be partially written or use a timestamp unit this
# collector does not understand. Skip that entry without losing neighboring
# Codex usage from the same scan.
cat >"$PI_HOME/.pi/agent/sessions/project/pi-malformed.jsonl" <<EOF
{"type":"message","id":"bad-time","timestamp":1.7e18,"message":{"role":"assistant","provider":"openai-codex","model":"gpt-pi","usage":{"input":999}}}
EOF
result=$(HOME="$PI_HOME" CODEX_HOME="$PI_HOME/.codex" XDG_DATA_HOME="$PI_HOME/.local/share" \
  PATH="$PI_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "77" ]] ||
  fail "Codex collector skips a Pi entry with an out-of-range timestamp" "$result"
pass "Codex collector skips a Pi entry with an out-of-range timestamp"

# A $HOME that is itself a git checkout (a common dotfiles setup with a
# whitelist .gitignore) must not hide the session files from the scan:
# ripgrep applies the parent repo's ignore rules to searched directories,
# which would otherwise make the scan silently count zero usage.
GIT_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$GIT_HOME/bin" "$GIT_HOME/.pi/agent/sessions/project"
cp "$TEST_HOME/bin/codex" "$GIT_HOME/bin/codex"
cat >"$GIT_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"git-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","model":"gpt-git","usage":{"input":6,"output":2}}}
EOF
git -C "$GIT_HOME" init -q
printf '*\n' >"$GIT_HOME/.gitignore"

result=$(HOME="$GIT_HOME" CODEX_HOME="$GIT_HOME/.codex" XDG_DATA_HOME="$GIT_HOME/.local/share" \
  PATH="$GIT_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "8" ]] ||
  fail "Codex collector counts pi sessions when HOME is a git checkout" "$result"
pass "Codex collector counts pi sessions when HOME is a git checkout"

# A subscription burned entirely through opencode has no native session files;
# usage must come from opencode's message database, filtered to OpenAI.
OPENCODE_HOME=$(signed_in_home)
cp "$TEST_HOME/bin/codex" "$OPENCODE_HOME/bin/codex"

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
  message("msg_1", "openai", "gpt-5.2-codex", input=80, output=40, reasoning=5, read=30),
  message("msg_2", "anthropic", "claude-opus-5", input=999, output=999),
  message("msg_3", "openai", "gpt-5.2-codex", role="user"),
  message("msg_4", "openai-local", "gpt-5.2-codex", input=999, output=999),
])
conn.execute("INSERT INTO message VALUES ('msg_5', 'ses_1', ?, ?, '[\"not\",\"an\",\"object\"]')", (now_ms, now_ms))
conn.commit()
conn.close()
PY

result=$(HOME="$OPENCODE_HOME" CODEX_HOME="$OPENCODE_HOME/.codex" XDG_DATA_HOME="$OPENCODE_HOME/.local/share" \
  PATH="$OPENCODE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "155" ]] ||
  fail "Codex collector counts OpenAI usage, reasoning included, from opencode sessions" "$result"
pass "Codex collector counts OpenAI usage, reasoning included, from opencode sessions"

[[ $(jq -c '.modelUsage' <<<"$result") == '{"gpt-5.2-codex":{"inputTokens":80,"outputTokens":45,"cacheReadInputTokens":30,"cacheCreationInputTokens":0}}' ]] ||
  fail "Codex collector ignores prefix-colliding providers, user messages, and malformed rows" "$result"
pass "Codex collector ignores prefix-colliding providers, user messages, and malformed rows"

# A warm cache makes --limits-only cheap: local stats come from the last scan
# instead of another walk over the opencode database, and --force bypasses it.
CACHE_HOME=$(signed_in_home)
cp "$TEST_HOME/bin/codex" "$CACHE_HOME/bin/codex"

python3 - "$CACHE_HOME/.local/share/opencode/opencode.db" <<'PY'
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
  message("c_1", "openai", "gpt-5.2-codex", input=5),
])
conn.commit()
conn.close()
PY

result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "5" ]] ||
  fail "Codex collector writes a fresh local-stats cache on first scan" "$result"
cache_file=$(ls "$CACHE_HOME/.cache/omarchy/agent-usage/"/codex-scan-*.json 2>/dev/null | head -n 1)
[[ -n $cache_file && -s $cache_file ]] ||
  fail "Codex collector leaves a cache file behind" "$result"
[[ $(stat -c %a "$cache_file") == "644" ]] ||
  fail "Codex collector keeps cache files readable" "$result"
[[ $(jq -r '.schemaVersion' "$cache_file") == "2" && $(jq -r '.stats.todayTotalTokens' "$cache_file") == "5" ]] ||
  fail "Codex collector writes a versioned cache envelope" "$result"
pass "Codex collector writes a local-stats cache on first scan"

# A still-fresh cache from before native notification deduplication must not
# restore inflated counts, even when only quota limits were requested.
jq '.schemaVersion = 1 | .stats.todayTotalTokens = 999' "$cache_file" >"$CACHE_HOME/old-cache.json"
mv "$CACHE_HOME/old-cache.json" "$cache_file"
result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "5" && $(jq -r '.schemaVersion' "$cache_file") == "2" ]] ||
  fail "Codex collector invalidates pre-deduplication cached totals" "$result"
pass "Codex collector invalidates pre-deduplication cached totals"

# A corrupt-but-parseable cache (wrong shape) is a cache miss: rescan and
# rewrite instead of emitting a garbage record.
printf '[]' >"$cache_file"
result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "5" ]] ||
  fail "Codex collector recovers from a corrupt cache file" "$result"
[[ $(jq -r '.schemaVersion' "$cache_file") == "2" ]] ||
  fail "Codex collector rewrites the cache after a corrupt read" "$result"
pass "Codex collector recovers from a corrupt cache file"

# A new opencode message changes what a scan would find; a --limits-only run
# must reuse the cached stats instead of rescanning.
python3 - "$CACHE_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
conn = sqlite3.connect(db)
now_ms = int(time.time() * 1000)
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", (
  "c_2", "ses_1", now_ms, now_ms, json.dumps({
    "role": "assistant",
    "providerID": "openai",
    "modelID": "gpt-5.2-codex",
    "tokens": {"input": 10, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }),
))
conn.commit()
conn.close()
PY

result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "5" ]] ||
  fail "Codex collector --limits-only reuses cached local stats" "$result"
[[ $(jq -c '.modelUsage' <<<"$result") == '{"gpt-5.2-codex":{"inputTokens":5,"outputTokens":0,"cacheReadInputTokens":0,"cacheCreationInputTokens":0}}' ]] ||
  fail "Codex collector --limits-only emits a complete record from cache" "$result"
pass "Codex collector --limits-only reuses cached local stats"

# --force must ignore the cache and pick up the new message.
result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "15" ]] ||
  fail "Codex collector --force rescans past the cache" "$result"
pass "Codex collector --force rescans past the cache"

# The forced scan refreshed the cache, so a following --limits-only sees it.
result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "15" ]] ||
  fail "Codex collector --limits-only sees a refreshed cache after --force" "$result"
pass "Codex collector --limits-only sees a refreshed cache after --force"

# An expired cache makes --limits-only rescan too: stale today* stats must
# never be served under a fresh updatedAt.
python3 - "$CACHE_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
conn = sqlite3.connect(db)
now_ms = int(time.time() * 1000)
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", (
  "c_3", "ses_1", now_ms, now_ms, json.dumps({
    "role": "assistant",
    "providerID": "openai",
    "modelID": "gpt-5.2-codex",
    "tokens": {"input": 10, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }),
))
conn.commit()
conn.close()
PY
touch -d "2 hours ago" "$cache_file"
result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "25" ]] ||
  fail "Codex collector --limits-only rescans when the cache is stale" "$result"
pass "Codex collector --limits-only rescans when the cache is stale"

# The 15-minute reuse window belongs to --limits-only alone. A no-flag run
# (the widget's periodic refresh) reuses a scan only while it is young enough
# to be a concurrent collector run; past that it rescans, so stats stay as
# fresh as refreshIntervalSec, however low the user sets it.
python3 - "$CACHE_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
conn = sqlite3.connect(db)
now_ms = int(time.time() * 1000)
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", (
  "c_4", "ses_1", now_ms, now_ms, json.dumps({
    "role": "assistant",
    "providerID": "openai",
    "modelID": "gpt-5.2-codex",
    "tokens": {"input": 10, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }),
))
conn.commit()
conn.close()
PY

result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "25" ]] ||
  fail "Codex collector no-flag reuses a seconds-old cache" "$result"

# 30 seconds is the lowest refreshIntervalSec the widget supports, so a
# cache that old must already be past the no-flag reuse window.
touch -d "30 seconds ago" "$cache_file"
result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "35" ]] ||
  fail "Codex collector no-flag rescans past the concurrent-run window" "$result"
pass "Codex collector no-flag mode rescans instead of serving a stale cache"

# The same age from the other side: a cache far past the no-flag window but
# well inside 15 minutes is still good enough for --limits-only.
python3 - "$CACHE_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
conn = sqlite3.connect(db)
now_ms = int(time.time() * 1000)
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", (
  "c_5", "ses_1", now_ms, now_ms, json.dumps({
    "role": "assistant",
    "providerID": "openai",
    "modelID": "gpt-5.2-codex",
    "tokens": {"input": 10, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }),
))
conn.commit()
conn.close()
PY
touch -d "10 minutes ago" "$cache_file"
result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "35" ]] ||
  fail "Codex collector --limits-only reuses a scan the no-flag mode would refresh" "$result"
pass "Codex collector --limits-only reuses a scan the no-flag mode would refresh"

# A cache written on another local date holds another day's today* stats even
# under a fresh mtime (midnight passed, or the clock moved backwards): the
# envelope's scanDate must turn it into a miss.
jq -c '.scanDate = "1999-01-01"' "$cache_file" >"$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "45" ]] ||
  fail "Codex collector treats a cache from another day as a miss" "$result"
[[ $(jq -r '.scanDate' "$cache_file") == "$(date +%Y-%m-%d)" ]] ||
  fail "Codex collector stamps the rewritten cache with the scan date" "$result"
pass "Codex collector treats a cache from another day as a miss"

# A cache stamped in the future (the clock was set backwards after the write)
# has no trustworthy age: it must be a miss, not fresh until the clock
# catches up.
python3 - "$CACHE_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
conn = sqlite3.connect(db)
now_ms = int(time.time() * 1000)
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", (
  "c_6", "ses_1", now_ms, now_ms, json.dumps({
    "role": "assistant",
    "providerID": "openai",
    "modelID": "gpt-5.2-codex",
    "tokens": {"input": 10, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }),
))
conn.commit()
conn.close()
PY
touch -d "@$(( $(date +%s) + 3600 ))" "$cache_file"
result=$(HOME="$CACHE_HOME" CODEX_HOME="$CACHE_HOME/.codex" XDG_CACHE_HOME="$CACHE_HOME/.cache" XDG_DATA_HOME="$CACHE_HOME/.local/share" \
  PATH="$CACHE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "55" ]] ||
  fail "Codex collector treats a future-dated cache as a miss" "$result"
pass "Codex collector treats a future-dated cache as a miss"

# First --limits-only on a machine with no cache falls back to a full scan.
FRESH_HOME=$(signed_in_home)
cp "$TEST_HOME/bin/codex" "$FRESH_HOME/bin/codex"

python3 - "$FRESH_HOME/.local/share/opencode/opencode.db" <<'PY'
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
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", (
  "f_1", "ses_1", now_ms, now_ms, json.dumps({
    "role": "assistant",
    "providerID": "openai",
    "modelID": "gpt-5.2-codex",
    "tokens": {"input": 7, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }),
))
conn.commit()
conn.close()
PY

result=$(HOME="$FRESH_HOME" CODEX_HOME="$FRESH_HOME/.codex" XDG_CACHE_HOME="$FRESH_HOME/.cache" XDG_DATA_HOME="$FRESH_HOME/.local/share" \
  PATH="$FRESH_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "7" ]] ||
  fail "Codex collector --limits-only falls back to a full scan without a cache" "$result"
pass "Codex collector --limits-only falls back to a full scan without a cache"

# A malformed opencode row must not abort the scan: json_valid() guards the
# parse, so the good rows are still counted. Real opencode data also stores
# compact JSON, so one row is serialized compactly here on purpose.
MALFORMED_HOME=$(signed_in_home)
cp "$TEST_HOME/bin/codex" "$MALFORMED_HOME/bin/codex"

python3 - "$MALFORMED_HOME/.local/share/opencode/opencode.db" <<'PY'
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

def message(id, input=0, compact=False):
  payload = {
    "role": "assistant",
    "providerID": "openai",
    "modelID": "gpt-5.2-codex",
    "tokens": {"input": input, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }
  if compact:
    return (id, "ses_1", now_ms, now_ms, json.dumps(payload, separators=(",", ":")))
  return (id, "ses_1", now_ms, now_ms, json.dumps(payload))

conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  message("mm_1", input=5, compact=True),
  message("mm_2", input=7),
])
# Valid JSON followed by trailing garbage: without json_valid() this row
# makes json_extract() raise and aborts the whole scan.
good = json.dumps({"role": "assistant", "providerID": "openai", "modelID": "gpt-5.2-codex",
                   "tokens": {"input": 999, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
                   "time": {"created": now_ms}})
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", ("mm_3", "ses_1", now_ms, now_ms, good + " trailing-garbage"))
# Completely broken row: not JSON at all.
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", ("mm_4", "ses_1", now_ms, now_ms, "this is not json"))
conn.commit()
conn.close()
PY

result=$(HOME="$MALFORMED_HOME" CODEX_HOME="$MALFORMED_HOME/.codex" XDG_CACHE_HOME="$MALFORMED_HOME/.cache" XDG_DATA_HOME="$MALFORMED_HOME/.local/share" \
  PATH="$MALFORMED_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "12" ]] ||
  fail "Codex collector counts good opencode rows past malformed ones" "$result"
pass "Codex collector counts good opencode rows past malformed ones"

# An unwritable cache must not kill the collector: the record is the contract.
UNWRITABLE_HOME=$(signed_in_home)
cp "$TEST_HOME/bin/codex" "$UNWRITABLE_HOME/bin/codex"

python3 - "$UNWRITABLE_HOME/.local/share/opencode/opencode.db" <<'PY'
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
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", (
  "u_1", "ses_1", now_ms, now_ms, json.dumps({
    "role": "assistant",
    "providerID": "openai",
    "modelID": "gpt-5.2-codex",
    "tokens": {"input": 3, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }),
))
conn.commit()
conn.close()
PY

# XDG_CACHE_HOME points at a regular file, so mkdir inside cache_root fails.
touch "$UNWRITABLE_HOME/not-a-dir"
result=$(HOME="$UNWRITABLE_HOME" CODEX_HOME="$UNWRITABLE_HOME/.codex" XDG_CACHE_HOME="$UNWRITABLE_HOME/not-a-dir" XDG_DATA_HOME="$UNWRITABLE_HOME/.local/share" \
  PATH="$UNWRITABLE_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "3" ]] ||
  fail "Codex collector still prints a complete record when the cache is unwritable" "$result"
pass "Codex collector still prints a complete record when the cache is unwritable"

# A scan cut short by a database error (schema migration, transient lock,
# corruption) must not be cached as the whole story, or the missing usage
# would be suppressed for every reader until the cache expires.
INTERRUPTED_HOME=$(signed_in_home)
cp "$TEST_HOME/bin/codex" "$INTERRUPTED_HOME/bin/codex"

# A database without the message table makes the scan fail mid-flight.
python3 - "$INTERRUPTED_HOME/.local/share/opencode/opencode.db" <<'PY'
import sqlite3
import sys
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE unrelated (id text PRIMARY KEY)")
conn.commit()
conn.close()
PY

result=$(HOME="$INTERRUPTED_HOME" CODEX_HOME="$INTERRUPTED_HOME/.codex" XDG_CACHE_HOME="$INTERRUPTED_HOME/.cache" XDG_DATA_HOME="$INTERRUPTED_HOME/.local/share" \
  PATH="$INTERRUPTED_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "0" ]] ||
  fail "Codex collector reports what it could read from a broken database" "$result"
[[ -z $(ls "$INTERRUPTED_HOME/.cache/omarchy/agent-usage/"codex-scan-*.json 2>/dev/null) ]] ||
  fail "Codex collector must not cache an interrupted scan" "$result"

# Once the database is whole again, the very next --limits-only run scans it
# instead of reusing a zero snapshot.
python3 - "$INTERRUPTED_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
now_ms = int(time.time() * 1000)
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", (
  "i_1", "ses_1", now_ms, now_ms, json.dumps({
    "role": "assistant",
    "providerID": "openai",
    "modelID": "gpt-5.2-codex",
    "tokens": {"input": 9, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }),
))
conn.commit()
conn.close()
PY

result=$(HOME="$INTERRUPTED_HOME" CODEX_HOME="$INTERRUPTED_HOME/.codex" XDG_CACHE_HOME="$INTERRUPTED_HOME/.cache" XDG_DATA_HOME="$INTERRUPTED_HOME/.local/share" \
  PATH="$INTERRUPTED_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "9" ]] ||
  fail "Codex collector does not reuse a snapshot from an interrupted scan" "$result"
pass "Codex collector does not cache an interrupted opencode scan"

# The limits name the plan themselves, so an account/read that never answers
# costs nothing: the limits still arrive, and quickly.
started=$(date +%s)
result=$(HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" XDG_DATA_HOME="$TEST_HOME/.local/share" PATH="$TEST_HOME/bin:$PATH" \
  CODEX_ACCOUNT_READ_HANGS=1 CODEX_RATE_LIMITS='{"planType":"pro","primary":{"usedPercent":36,"windowDurationMins":10080}}' \
  "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)
(( $(date +%s) - started < 4 )) || fail "Codex collector doesn't wait on account/read when the limits name the plan"
[[ $(jq -c '{tierLabel, usageStatusText, limits: [.limits[] | {label, percent}]}' <<<"$result") == '{"tierLabel":"pro","usageStatusText":"","limits":[{"label":"Weekly (7-day)","percent":0.36}]}' ]] ||
  fail "Codex collector reads limits even when account/read never answers" "$result"
pass "Codex collector reads limits even when account/read never answers"

# Free full resets ride along with the limits: only available ones count, and
# the soonest to lapse is the one worth mentioning.
result=$(HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" XDG_DATA_HOME="$TEST_HOME/.local/share" PATH="$TEST_HOME/bin:$PATH" \
  CODEX_RATE_LIMITS='{"planType":"pro","primary":{"usedPercent":42,"windowDurationMins":10080}}' \
  CODEX_RESET_CREDITS='{"availableCount":2,"credits":[{"status":"available","expiresAt":2000000000},{"status":"available","expiresAt":1900000000},{"status":"used","expiresAt":1800000000}]}' \
  "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)
[[ $(jq -c '.resetCredits' <<<"$result") == '{"available":2,"nextExpiresAt":"2030-03-17T17:46:40+00:00"}' ]] ||
  fail "Codex collector reports its available free resets" "$result"
pass "Codex collector reports its available free resets"

# A home nobody is signed in to answers with an error, which reads as a
# sign-in to restore rather than as missing numbers.
result=$(HOME="$TEST_HOME" CODEX_HOME="$TEST_HOME/.codex" XDG_DATA_HOME="$TEST_HOME/.local/share" PATH="$TEST_HOME/bin:$PATH" \
  CODEX_LIMITS_ERROR="codex account authentication required to read rate limits" \
  "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)
[[ $(jq -r '.usageStatusText' <<<"$result") == "Waiting for auth" ]] ||
  fail "Codex collector reports a missing sign-in as one" "$result"
pass "Codex collector reports a missing sign-in as one"

# The app-server batches notifications with replies in one write. A reply
# that shares a write with a notification must not be stranded in a read
# buffer, and bytes left over from one request must carry into the next.
BATCHED_HOME=$(signed_in_home)
cat >"$BATCHED_HOME/bin/codex" <<'EOF'
#!/bin/bash

while read -r request; do
  id=$(jq -r '.id // empty' <<<"$request")
  method=$(jq -r '.method // empty' <<<"$request")

  case "$method" in
    initialize)
      # One write: this reply and a trailing notification.
      printf '%s\n%s\n' \
        "$(jq -cn --argjson id "$id" '{id: $id, result: {}}')" \
        '{"method":"remoteControl/status/changed","params":{"status":"disabled"}}'
      ;;
    account/rateLimits/read)
      # One write: a notification ahead of this reply.
      printf '%s\n%s\n' \
        '{"method":"account/updated","params":{"authMode":"chatgpt","planType":"plus"}}' \
        "$(jq -cn --argjson id "$id" '{id: $id, result: {rateLimits: {planType: "plus", primary: {usedPercent: 5, windowDurationMins: 300, resetsAt: 1790659194}}}}')"
      ;;
  esac
done
EOF
chmod +x "$BATCHED_HOME/bin/codex"

result=$(HOME="$BATCHED_HOME" CODEX_HOME="$BATCHED_HOME/.codex" XDG_CACHE_HOME="$BATCHED_HOME/.cache" XDG_DATA_HOME="$BATCHED_HOME/.local/share" \
  PATH="$BATCHED_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -c '{tierLabel, usageStatusText, limits: [.limits[] | {label, percent}]}' <<<"$result") == '{"tierLabel":"plus","usageStatusText":"","limits":[{"label":"5h window","percent":0.05}]}' ]] ||
  fail "Codex collector reads replies batched with notifications" "$result"
pass "Codex collector reads replies batched with notifications"

# Without temporary space the probe still runs; it only loses Codex's error
# text, so stderr goes nowhere instead of failing the probe.
NO_TEMP_PYTHON="$BATCHED_HOME/python"
mkdir -p "$NO_TEMP_PYTHON"
cat >"$NO_TEMP_PYTHON/sitecustomize.py" <<'EOF'
import tempfile

def no_space(*args, **kwargs):
  raise OSError(28, "No space left on device")

tempfile.TemporaryFile = no_space
EOF

result=$(HOME="$BATCHED_HOME" CODEX_HOME="$BATCHED_HOME/.codex" XDG_CACHE_HOME="$BATCHED_HOME/.cache" XDG_DATA_HOME="$BATCHED_HOME/.local/share" \
  PYTHONPATH="$NO_TEMP_PYTHON" PATH="$BATCHED_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --force)

[[ $(jq -c '[.limits[] | .percent]' <<<"$result") == '[0.05]' ]] ||
  fail "Codex collector probes without temporary space" "$result"
pass "Codex collector probes without temporary space"

# The lazy launcher at ~/.local/bin/codex runs `mise use -g` when executed, so
# a read-only usage probe on a machine without Codex must never spawn it. A
# private tools dir keeps a real codex or mise on the host out of the probe:
# PATH holds only the interpreter and file tools the collector may exec.
LAUNCH_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
SAFE_PATH="$LAUNCH_HOME/tools"
mkdir -p "$SAFE_PATH"
for tool in python3 rg; do
  if command -v "$tool" >/dev/null; then
    ln -s "$(command -v "$tool")" "$SAFE_PATH/$tool"
  fi
done
mkdir -p "$LAUNCH_HOME/bin" "$LAUNCH_HOME/.local/bin" "$LAUNCH_HOME/.codex"
touch "$LAUNCH_HOME/.codex/auth.json"
cat >"$LAUNCH_HOME/.local/bin/codex" <<'LAUNCHER'
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "npm:@openai/codex" || exit 1
exec mise x "npm:@openai/codex" -- codex "$@"
LAUNCHER
chmod +x "$LAUNCH_HOME/.local/bin/codex"
cat >"$LAUNCH_HOME/bin/mise" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$MISE_CALLS_FILE"
exit 1
STUB
chmod +x "$LAUNCH_HOME/bin/mise"

result=$(HOME="$LAUNCH_HOME" CODEX_HOME="$LAUNCH_HOME/.codex" MISE_CALLS_FILE="$LAUNCH_HOME/mise-calls" XDG_DATA_HOME="$LAUNCH_HOME/.local/share" \
  PATH="$LAUNCH_HOME/bin:$SAFE_PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.usageStatusText' <<<"$result") == "Codex unavailable" ]] ||
  fail "Codex collector reports Codex unavailable when only the launcher exists" "$result"
# The launcher would log `use -g ...` through the mise stub if it ever ran;
# `which codex` is the only permitted call.
[[ ! -s $LAUNCH_HOME/mise-calls || $(cat "$LAUNCH_HOME/mise-calls") == "which codex" ]] ||
  fail "Codex collector must not execute the lazy codex launcher" "$(cat "$LAUNCH_HOME/mise-calls" 2>/dev/null)"
pass "Codex collector resolves through mise which instead of running the launcher"

# When mise reports an installed binary, that binary is probed, not the
# launcher that shadows it on PATH.
cp "$TEST_HOME/bin/codex" "$LAUNCH_HOME/real-codex"
cat >"$LAUNCH_HOME/bin/mise" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >>"$LAUNCH_HOME/mise-calls"
echo "$LAUNCH_HOME/real-codex"
STUB

rm -f "$LAUNCH_HOME/mise-calls"
result=$(HOME="$LAUNCH_HOME" CODEX_HOME="$LAUNCH_HOME/.codex" CODEX_ARGS_FILE="$LAUNCH_HOME/codex-args" XDG_DATA_HOME="$LAUNCH_HOME/.local/share" \
  PATH="$LAUNCH_HOME/bin:$SAFE_PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ -f $LAUNCH_HOME/codex-args && $(cat "$LAUNCH_HOME/mise-calls") == "which codex" ]] ||
  fail "Codex collector probes the binary mise which reports" "$result"
pass "Codex collector probes the mise-resolved binary"

# A symlink at the launcher path is the user's own binary, so it is probed
# directly without asking mise at all.
LINK_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$LINK_HOME/bin" "$LINK_HOME/.local/bin" "$LINK_HOME/.codex"
touch "$LINK_HOME/.codex/auth.json"
ln -s "$TEST_HOME/bin/codex" "$LINK_HOME/.local/bin/codex"
cat >"$LINK_HOME/bin/mise" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >>"$LINK_HOME/mise-calls"
echo "$LINK_HOME/real-codex"
STUB
chmod +x "$LINK_HOME/bin/mise"

result=$(HOME="$LINK_HOME" CODEX_HOME="$LINK_HOME/.codex" CODEX_ARGS_FILE="$LINK_HOME/codex-args" XDG_DATA_HOME="$LINK_HOME/.local/share" \
  PATH="$LINK_HOME/bin:$SAFE_PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ -f $LINK_HOME/codex-args && ! -s $LINK_HOME/mise-calls ]] ||
  fail "Codex collector probes a symlinked codex without invoking mise" "$result"
pass "Codex collector probes a user-owned symlink at the launcher path"

# A mise shim is a symlink to the mise binary itself, so it resolves to mise,
# not to an installed codex — running it would exec `mise x` and install the
# tool. It must be treated as lazy despite being a symlink.
SHIM_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$SHIM_HOME/bin" "$SHIM_HOME/.local/share/mise/shims"
cat >"$SHIM_HOME/bin/mise" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >>"$SHIM_HOME/mise-calls"
exit 1
STUB
chmod +x "$SHIM_HOME/bin/mise"
ln -s "$SHIM_HOME/bin/mise" "$SHIM_HOME/.local/share/mise/shims/codex"

result=$(HOME="$SHIM_HOME" CODEX_HOME="$SHIM_HOME/.codex" MISE_CALLS_FILE="$SHIM_HOME/mise-calls" XDG_DATA_HOME="$SHIM_HOME/.local/share" \
  PATH="$SHIM_HOME/bin:$SAFE_PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.usageStatusText' <<<"$result") == "Codex unavailable" ]] ||
  fail "Codex collector reports Codex unavailable when only a mise shim exists" "$result"
[[ ! -s $SHIM_HOME/mise-calls || $(cat "$SHIM_HOME/mise-calls") == "which codex" ]] ||
  fail "Codex collector must not execute a mise shim" "$(cat "$SHIM_HOME/mise-calls" 2>/dev/null)"
pass "Codex collector treats a shim symlink to mise as lazy"

# Without Codex credentials, account/read can only fail — and starting the
# app-server is not free: it syncs the plugin list, a git fetch per refresh
# that leaves ~/.codex/.tmp/git-* folders behind. The collector must not
# spawn codex at all.
NOAUTH_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$NOAUTH_HOME/bin"
cp "$TEST_HOME/bin/codex" "$NOAUTH_HOME/bin/codex"

result=$(HOME="$NOAUTH_HOME" CODEX_HOME="$NOAUTH_HOME/.codex" CODEX_ARGS_FILE="$NOAUTH_HOME/codex-args" XDG_DATA_HOME="$NOAUTH_HOME/.local/share" \
  PATH="$NOAUTH_HOME/bin:$PATH" env -u OPENAI_API_KEY -u CODEX_API_KEY -u CODEX_ACCESS_TOKEN "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ ! -e $NOAUTH_HOME/codex-args ]] ||
  fail "Codex collector does not spawn app-server without credentials" "$result"
[[ $(jq -r '.usageStatusText' <<<"$result") == "Waiting for auth" ]] ||
  fail "Codex collector waits for auth without credentials" "$result"
pass "Codex collector does not spawn app-server without credentials"

# A non-file credentials store keeps credentials outside auth.json, so the
# probe must still run.
KEYRING_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$KEYRING_HOME/bin" "$KEYRING_HOME/.codex"
cp "$TEST_HOME/bin/codex" "$KEYRING_HOME/bin/codex"
printf 'cli_auth_credentials_store = "keyring"\n' >"$KEYRING_HOME/.codex/config.toml"

result=$(HOME="$KEYRING_HOME" CODEX_HOME="$KEYRING_HOME/.codex" CODEX_ARGS_FILE="$KEYRING_HOME/codex-args" XDG_DATA_HOME="$KEYRING_HOME/.local/share" \
  PATH="$KEYRING_HOME/bin:$PATH" env -u OPENAI_API_KEY -u CODEX_API_KEY -u CODEX_ACCESS_TOKEN "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ -e $KEYRING_HOME/codex-args ]] ||
  fail "Codex collector probes the app-server when the keyring store is configured" "$result"
pass "Codex collector probes the app-server when the keyring store is configured"

# The setting is TOML, so a single-quoted value names the keyring just as well,
# while an explicit file store with no auth.json is still signed out.
for store in "'keyring'" '"file"'; do
  rm -f "$KEYRING_HOME/codex-args"
  printf 'model = "gpt-5"\ncli_auth_credentials_store = %s\n' "$store" >"$KEYRING_HOME/.codex/config.toml"
  HOME="$KEYRING_HOME" CODEX_HOME="$KEYRING_HOME/.codex" CODEX_ARGS_FILE="$KEYRING_HOME/codex-args" XDG_DATA_HOME="$KEYRING_HOME/.local/share" \
    PATH="$KEYRING_HOME/bin:$PATH" env -u OPENAI_API_KEY -u CODEX_API_KEY -u CODEX_ACCESS_TOKEN "$ROOT/bin/omarchy-agent-usage-codex" --limits-only >/dev/null
  if [[ $store == "'keyring'" ]]; then
    [[ -e $KEYRING_HOME/codex-args ]] || fail "Codex collector reads a single-quoted keyring store as TOML"
  else
    [[ ! -e $KEYRING_HOME/codex-args ]] || fail "Codex collector does not probe an empty file store"
  fi
done
pass "Codex collector reads the credentials store as TOML"

# A CODEX_ACCESS_TOKEN is credentials even without auth.json.
TOKEN_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$TOKEN_HOME/bin" "$TOKEN_HOME/.codex"
cp "$TEST_HOME/bin/codex" "$TOKEN_HOME/bin/codex"

result=$(HOME="$TOKEN_HOME" CODEX_HOME="$TOKEN_HOME/.codex" CODEX_ARGS_FILE="$TOKEN_HOME/codex-args" XDG_DATA_HOME="$TOKEN_HOME/.local/share" \
  PATH="$TOKEN_HOME/bin:$PATH" env -u OPENAI_API_KEY -u CODEX_API_KEY CODEX_ACCESS_TOKEN=x "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ -e $TOKEN_HOME/codex-args ]] ||
  fail "Codex collector probes the app-server when CODEX_ACCESS_TOKEN is set" "$result"
pass "Codex collector probes the app-server when CODEX_ACCESS_TOKEN is set"

# An API key alone does not log the app-server in.
APIKEY_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$APIKEY_HOME/bin" "$APIKEY_HOME/.codex"
cp "$TEST_HOME/bin/codex" "$APIKEY_HOME/bin/codex"

result=$(HOME="$APIKEY_HOME" CODEX_HOME="$APIKEY_HOME/.codex" CODEX_ARGS_FILE="$APIKEY_HOME/codex-args" XDG_DATA_HOME="$APIKEY_HOME/.local/share" \
  PATH="$APIKEY_HOME/bin:$PATH" env -u CODEX_API_KEY -u CODEX_ACCESS_TOKEN OPENAI_API_KEY=x "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ ! -e $APIKEY_HOME/codex-args ]] ||
  fail "Codex collector does not spawn app-server for an API key alone" "$result"
pass "Codex collector does not spawn app-server for an API key alone"

# A codex that exits before speaking the protocol (rejected flag, crash, etc.)
# must not leave the panel showing the bare RPC method name "initialize".
EXIT_HOME=$(signed_in_home)
cat >"$EXIT_HOME/bin/codex" <<'EOF'
#!/bin/bash
echo "error: invalid value 'untrusted' for '--ask-for-approval <APPROVAL_POLICY>'" >&2
echo "  [possible values: on-request, never]" >&2
exit 2
EOF
chmod +x "$EXIT_HOME/bin/codex"

result=$(HOME="$EXIT_HOME" CODEX_HOME="$EXIT_HOME/.codex" XDG_CACHE_HOME="$EXIT_HOME/.cache" XDG_DATA_HOME="$EXIT_HOME/.local/share" \
  PATH="$EXIT_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.usageStatusText' <<<"$result") == "Codex limits unavailable" ]] ||
  fail "Codex collector reports limits unavailable when app-server rejects argv" "$result"
help=$(jq -r '.authHelpText' <<<"$result")
[[ $help == *"invalid value 'untrusted'"* ]] ||
  fail "Codex collector surfaces the CLI's own error" "$result"
[[ $help != "initialize" ]] ||
  fail "Codex collector must not leak the raw RPC method name" "$result"
pass "Codex collector surfaces a rejected app-server call instead of the RPC method name"

# EOF on stdout during initialize (process died) is reported as an exit, not a bare method.
DEAD_HOME=$(signed_in_home)
cat >"$DEAD_HOME/bin/codex" <<'EOF'
#!/bin/bash
exec 1>&-
exec sleep 30
EOF
chmod +x "$DEAD_HOME/bin/codex"

result=$(HOME="$DEAD_HOME" CODEX_HOME="$DEAD_HOME/.codex" XDG_CACHE_HOME="$DEAD_HOME/.cache" XDG_DATA_HOME="$DEAD_HOME/.local/share" \
  PATH="$DEAD_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

help=$(jq -r '.authHelpText' <<<"$result")
[[ $help == "Codex app-server exited before initialize" ]] ||
  fail "Codex collector identifies an app-server that exits during startup" "$result"
pass "Codex collector identifies an app-server that exits during startup"

# Failure while sending the initialized notification after initialize answered.
HALF_HOME=$(signed_in_home)
cat >"$HALF_HOME/bin/codex" <<'EOF'
#!/bin/bash
read -r request
exec 0<&-
jq -cn --argjson id "$(jq -r '.id' <<<"$request")" '{id: $id, result: {}}'
exec sleep 30
EOF
chmod +x "$HALF_HOME/bin/codex"

result=$(HOME="$HALF_HOME" CODEX_HOME="$HALF_HOME/.codex" XDG_CACHE_HOME="$HALF_HOME/.cache" XDG_DATA_HOME="$HALF_HOME/.local/share" \
  PATH="$HALF_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

help=$(jq -r '.authHelpText' <<<"$result")
[[ $help == "Codex app-server exited before initialized" ]] ||
  fail "Codex collector translates failure to send the initialized notification" "$result"
pass "Codex collector translates failure to send the initialized notification"

# Silent clean exit with no stderr: fall back to the login hint.
SILENT_HOME=$(signed_in_home)
cat >"$SILENT_HOME/bin/codex" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$SILENT_HOME/bin/codex"

result=$(HOME="$SILENT_HOME" CODEX_HOME="$SILENT_HOME/.codex" XDG_CACHE_HOME="$SILENT_HOME/.cache" XDG_DATA_HOME="$SILENT_HOME/.local/share" \
  PATH="$SILENT_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

help=$(jq -r '.authHelpText' <<<"$result")
[[ $help == "Run \`codex login\` to authenticate." ]] ||
  fail "Codex collector falls back to the login hint when the CLI is silent" "$result"
pass "Codex collector falls back to the login hint when the app-server says nothing"

# Live app-server that stalls on account/rateLimits/read: keep a clear stall message, not login.
STALL_HOME=$(signed_in_home)
cat >"$STALL_HOME/bin/codex" <<'EOF'
#!/bin/bash
while read -r request; do
  id=$(jq -r '.id // empty' <<<"$request")
  method=$(jq -r '.method // empty' <<<"$request")
  case "$method" in
    initialize) jq -cn --argjson id "$id" '{id: $id, result: {}}' ;;
    account/rateLimits/read) : ;;
  esac
done
EOF
chmod +x "$STALL_HOME/bin/codex"

result=$(HOME="$STALL_HOME" CODEX_HOME="$STALL_HOME/.codex" XDG_CACHE_HOME="$STALL_HOME/.cache" XDG_DATA_HOME="$STALL_HOME/.local/share" \
  PATH="$STALL_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

help=$(jq -r '.authHelpText' <<<"$result")
[[ $help != "Run \`codex login\` to authenticate." ]] ||
  fail "Codex collector must not blame auth when the app-server is merely stalled" "$result"
[[ $help == "Codex app-server did not answer account/rateLimits/read" ]] ||
  fail "Codex collector names the stalled RPC method clearly" "$result"
[[ $help != "account/rateLimits/read" && $help != "initialize" ]] ||
  fail "Codex collector must not leak a bare method name" "$result"
pass "Codex collector names a stalled RPC instead of leaking the method name"

# A stalled app-server that has logged to stderr is still running: its logging
# is not why it stopped, and it has not exited.
NOISY_HOME=$(signed_in_home)
sed 's/^while read/echo "WARN codex_core: startup notice" >\&2\nwhile read/' "$STALL_HOME/bin/codex" >"$NOISY_HOME/bin/codex"
chmod +x "$NOISY_HOME/bin/codex"

result=$(HOME="$NOISY_HOME" CODEX_HOME="$NOISY_HOME/.codex" XDG_CACHE_HOME="$NOISY_HOME/.cache" XDG_DATA_HOME="$NOISY_HOME/.local/share" \
  PATH="$NOISY_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.authHelpText' <<<"$result") == "Codex app-server did not answer account/rateLimits/read" ]] ||
  fail "Codex collector reports a stall, not an exit, when a live app-server has logged" "$result"
pass "Codex collector reports a stall, not an exit, when a live app-server has logged"

# A CLI that logs plenty before failing must still show the failure, not the logging.
CHATTY_HOME=$(signed_in_home)
cat >"$CHATTY_HOME/bin/codex" <<'EOF'
#!/bin/bash
for i in {1..20}; do echo "WARN codex_core::config: ignoring unknown key number $i" >&2; done
echo "error: failed to start app-server" >&2
exit 1
EOF
chmod +x "$CHATTY_HOME/bin/codex"

result=$(HOME="$CHATTY_HOME" CODEX_HOME="$CHATTY_HOME/.codex" XDG_CACHE_HOME="$CHATTY_HOME/.cache" XDG_DATA_HOME="$CHATTY_HOME/.local/share" \
  PATH="$CHATTY_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only)

[[ $(jq -r '.authHelpText' <<<"$result") == "codex app-server exited: "*"error: failed to start app-server" ]] ||
  fail "Codex collector keeps the CLI's final error past its startup logging" "$result"
pass "Codex collector keeps the CLI's final error past its startup logging"

# Codex CLI can front any OpenAI-compatible backend (`--oss`, or a custom
# model_provider in config.toml). Those rollouts land in the same sessions
# directory but spend a local box or a third party, never this subscription.
PROVIDER_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$PROVIDER_HOME/bin" "$PROVIDER_HOME/.codex/sessions/$(date +%Y/%m/%d)"
cp "$TEST_HOME/bin/codex" "$PROVIDER_HOME/bin/codex"

provider_session() {
  local name=$1 meta=$2 model=$3 input=$4 output=$5
  local file="$PROVIDER_HOME/.codex/sessions/$(date +%Y/%m/%d)/rollout-$name.jsonl"
  [[ -n $meta ]] && echo "{\"timestamp\":\"$timestamp\",\"type\":\"session_meta\",\"payload\":{\"model_provider\":\"$meta\"}}" >"$file"
  cat >>"$file" <<EOF
{"timestamp":"$timestamp","type":"turn_context","payload":{"model":"$model"}}
{"timestamp":"$timestamp","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":$input,"cached_input_tokens":0,"cache_write_input_tokens":0,"output_tokens":$output,"reasoning_output_tokens":0}}}}
EOF
}

provider_session native openai gpt-native 100 10
provider_session ollama ollama qwen3-coder:30b 9000 900
provider_session openrouter openrouter claude-test 5000 500
# Rollouts written before Codex recorded the field have a session_meta with no
# provider; they must still count rather than silently drop a user's history.
provider_session legacy "" gpt-legacy 40 0
sed -i "1i {\"timestamp\":\"$timestamp\",\"type\":\"session_meta\",\"payload\":{\"id\":\"legacy\"}}" \
  "$PROVIDER_HOME/.codex/sessions/$(date +%Y/%m/%d)/rollout-legacy.jsonl"
# A fork copies its parent's session_meta after its own; the first one decides.
provider_session fork openai gpt-fork 3 0
sed -i "1a {\"timestamp\":\"$timestamp\",\"type\":\"session_meta\",\"payload\":{\"model_provider\":\"ollama\"}}" \
  "$PROVIDER_HOME/.codex/sessions/$(date +%Y/%m/%d)/rollout-fork.jsonl"

result=$(HOME="$PROVIDER_HOME" CODEX_HOME="$PROVIDER_HOME/.codex" XDG_CACHE_HOME="$PROVIDER_HOME/.cache" XDG_DATA_HOME="$PROVIDER_HOME/.local/share" \
  PATH="$PROVIDER_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "153" ]] ||
  fail "Codex collector counts only subscription-backed native sessions" "$result"
[[ $(jq -r '.modelUsage | keys | join(",")' <<<"$result") == "gpt-fork,gpt-legacy,gpt-native" ]] ||
  fail "Codex collector excludes local and third-party providers from native sessions" "$result"
[[ $(jq -r '.todaySessions' <<<"$result") == "3" ]] ||
  fail "Codex collector excludes foreign-provider rollouts from the session count" "$result"
pass "Codex collector ignores native sessions served by a non-OpenAI provider"

# Codex native session scan skips lines without token_count or turn_context before JSON parsing
PREFILTER_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$PREFILTER_HOME/bin" "$PREFILTER_HOME/.codex/sessions/$(date +%Y/%m/%d)"
cp "$TEST_HOME/bin/codex" "$PREFILTER_HOME/bin/codex"

session="$PREFILTER_HOME/.codex/sessions/$(date +%Y/%m/%d)/session.jsonl"
cat >"$session" <<EOF
{"timestamp":"$timestamp","type":"session_meta","payload":{"id":"session-123"}}
this is plain non-json text that should be skipped by the prefilter
{"timestamp":"$timestamp","type":"turn_context","payload":{"model":"gpt-4o"}}
{"timestamp":"$timestamp","type":"user_message","payload":{"content":"Write a sorting algorithm"}}
{"timestamp":"$timestamp","type":"agent_reasoning","payload":{"content":"Thinking about quicksort..."}}
{"timestamp":"$timestamp","type":"response_item","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":50,"cached_input_tokens":20,"output_tokens":15,"total_tokens":65}}}}
{"timestamp":"$timestamp","type":"agent_message","payload":{"content":"Here is quicksort..."}}
{"timestamp":"$timestamp","type":"turn_context","payload":{"model":"o3-mini"}}
{"timestamp":"$timestamp","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":30,"cached_input_tokens":10,"output_tokens":5,"total_tokens":35}}}}
EOF

result=$(HOME="$PREFILTER_HOME" CODEX_HOME="$PREFILTER_HOME/.codex" XDG_CACHE_HOME="$PREFILTER_HOME/.cache" XDG_DATA_HOME="$PREFILTER_HOME/.local/share" \
  PATH="$PREFILTER_HOME/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "100" ]] ||
  fail "Codex collector computes total tokens across models with prefilter" "$result"
[[ $(jq -c '.todayTokensByModel' <<<"$result") == '{"gpt-4o":65,"o3-mini":35}' ]] ||
  fail "Codex collector attributes tokens by model when switching models via turn_context" "$result"
[[ $(jq -c '.modelUsage["gpt-4o"]' <<<"$result") == '{"inputTokens":30,"outputTokens":15,"cacheReadInputTokens":20,"cacheCreationInputTokens":0}' ]] ||
  fail "Codex collector splits cached and input tokens correctly for gpt-4o" "$result"
[[ $(jq -c '.modelUsage["o3-mini"]' <<<"$result") == '{"inputTokens":20,"outputTokens":5,"cacheReadInputTokens":10,"cacheCreationInputTokens":0}' ]] ||
  fail "Codex collector splits cached and input tokens correctly for o3-mini" "$result"
pass "Codex collector prefilters session lines and tracks model context"

# Session history only grows, so a refresh must read the files that changed
# and replay the totals it already has for the rest. Several GB of history
# otherwise goes through the JSONL parser on every widget refresh.
INCREMENTAL_HOME=$(mktemp -d "$SCRATCH/home.XXXXXX")
mkdir -p "$INCREMENTAL_HOME/bin" "$INCREMENTAL_HOME/.codex/sessions/$(date +%Y/%m/%d)" "$INCREMENTAL_HOME/.pi/agent/sessions"
cp "$TEST_HOME/bin/codex" "$INCREMENTAL_HOME/bin/codex"

incremental_timestamp="$(date +%Y-%m-%d)T09:00:00Z"
incremental_session="$INCREMENTAL_HOME/.codex/sessions/$(date +%Y/%m/%d)/rollout.jsonl"
cat >"$incremental_session" <<EOF
{"timestamp":"$incremental_timestamp","type":"turn_context","payload":{"model":"gpt-test"}}
{"timestamp":"$incremental_timestamp","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":10,"cached_input_tokens":0,"output_tokens":5}}}}
EOF

incremental_pi="$INCREMENTAL_HOME/.pi/agent/sessions/session.jsonl"
cat >"$incremental_pi" <<EOF
{"type":"message","id":"m1","timestamp":"$incremental_timestamp","message":{"role":"assistant","provider":"openai-codex","model":"gpt-test","usage":{"input":4,"output":1}}}
EOF

run_incremental() {
  HOME="$INCREMENTAL_HOME" CODEX_HOME="$INCREMENTAL_HOME/.codex" XDG_CACHE_HOME="$INCREMENTAL_HOME/.cache" \
    XDG_DATA_HOME="$INCREMENTAL_HOME/.local/share" PATH="$INCREMENTAL_HOME/bin:$PATH" \
    "$ROOT/bin/omarchy-agent-usage-codex" "$@"
}

# The aggregate scan cache would answer the next run on its own, and it is the
# rescan underneath that this covers.
expire_scan_cache() {
  local cache
  for cache in "$INCREMENTAL_HOME/.cache/omarchy/agent-usage/"codex-scan-*.json; do
    [[ -e $cache ]] && touch -d "2 hours ago" "$cache"
  done
}

result=$(run_incremental)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "20" ]] ||
  fail "Codex collector counts both session sources on a first scan" "$result"

file_cache=$(ls "$INCREMENTAL_HOME/.cache/omarchy/agent-usage/"codex-files-*.json 2>/dev/null | head -n 1)
[[ -n $file_cache && -s $file_cache ]] ||
  fail "Codex collector writes a per-file cache on first scan"
[[ $(jq --arg path "$incremental_session" -r '.files[$path].days | length' "$file_cache") == "1" ]] ||
  fail "Codex collector records the native session file it read" "$(cat "$file_cache")"
# A forked pi session repeats its parent's messages, so pi sessions are only
# deduplicated across the whole tree at once, never replayed per file.
[[ $(jq --arg path "$incremental_pi" -r '.files | has($path)' "$file_cache") == "false" ]] ||
  fail "Codex collector keeps pi sessions out of the per-file cache" "$(cat "$file_cache")"
pass "Codex collector records per-file totals as it scans"

# Unreadable, but unchanged in mtime and size: a run that still reports the
# same totals can only have replayed them.
chmod 000 "$incremental_session"
expire_scan_cache
result=$(run_incremental)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "20" ]] ||
  fail "Codex collector rereads session files it has already counted" "$result"
pass "Codex collector replays unchanged session files instead of rereading them"

# --force means the history itself is re-read, per-file records included.
result=$(run_incremental --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "5" ]] ||
  fail "Codex collector --force reuses per-file records" "$result"
pass "Codex collector --force rereads the history"

chmod 644 "$incremental_session"
# The --force run above could not read the session, so cache it again first,
# or the append below is read from scratch whether or not the cache noticed it.
expire_scan_cache
run_incremental >/dev/null
cat >>"$incremental_session" <<EOF
{"timestamp":"$incremental_timestamp","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":30,"cached_input_tokens":10,"output_tokens":2}}}}
EOF
expire_scan_cache
result=$(run_incremental)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "52" ]] ||
  fail "Codex collector misses turns appended to a session it had cached" "$result"
pass "Codex collector rereads a session file that grew"

# Records are bucketed by local day, so a new timezone has to re-read them.
zone_timestamp="$(date -u +%Y-%m-%d)T02:00:00Z"
zone_session="$INCREMENTAL_HOME/.codex/sessions/zone.jsonl"
cat >"$zone_session" <<EOF
{"timestamp":"$zone_timestamp","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":3,"output_tokens":1}}}}
EOF
expire_scan_cache
TZ=UTC run_incremental >/dev/null
expire_scan_cache
TZ=America/Los_Angeles run_incremental >/dev/null
file_cache=$(ls "$INCREMENTAL_HOME/.cache/omarchy/agent-usage/"codex-files-*.json | head -n 1)
[[ $(jq --arg path "$zone_session" -r '.files[$path].days | keys[0]' "$file_cache") == "$(TZ=America/Los_Angeles date -d "$zone_timestamp" +%Y-%m-%d)" ]] ||
  fail "Codex collector keeps the old timezone's days after a timezone change" "$(cat "$file_cache")"
pass "Codex collector re-reads per-file records after a timezone change"

# A line that stops the read keeps the usage read before it, as it always has.
broken_session="$INCREMENTAL_HOME/.codex/sessions/broken.jsonl"
cat >"$broken_session" <<EOF
{"timestamp":"$incremental_timestamp","type":"turn_context","payload":{"model":"gpt-broken"}}
{"timestamp":"$incremental_timestamp","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":6,"output_tokens":0}}}}
null
EOF
expire_scan_cache
result=$(run_incremental)
[[ $(jq -r '.modelUsage["gpt-broken"].inputTokens' <<<"$result") == "6" ]] ||
  fail "Codex collector drops usage read before a line that stops the read" "$result"
pass "Codex collector keeps usage read before a line that stops the read"
