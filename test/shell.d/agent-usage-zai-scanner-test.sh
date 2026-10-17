#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.pi/agent/sessions/project"

today="$(date +%Y-%m-%d)"
timestamp="${today}T12:00:00Z"

# One session file exercises the whole scan contract:
#   a  zai, today, with reasoning + cache tokens        -> counted, today
#   b  zhipu, today                                     -> counted, today
#   c  openai provider                                  -> ignored
#   d  zai but a user turn                              -> ignored
#   a' a repeated message id                            -> deduped
#   f  zai, no top-level timestamp, message.timestamp   -> counted, NOT today
#   e  malformed JSON                                   -> skipped, rest survive
session="$TEST_HOME/.pi/agent/sessions/project/pi.jsonl"
cat >"$session" <<EOF
{"type":"message","id":"a","timestamp":"$timestamp","message":{"role":"assistant","provider":"zai","model":"glm-5.3","usage":{"input":10,"output":4,"reasoning":6,"cacheRead":3,"cacheWrite":2}}}
{"type":"message","id":"b","timestamp":"$timestamp","message":{"role":"assistant","provider":"zhipu","model":"glm-4.7","usage":{"input":20,"output":5}}}
{"type":"message","id":"c","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai","model":"gpt","usage":{"input":999,"output":999}}}
{"type":"message","id":"d","timestamp":"$timestamp","message":{"role":"user","provider":"zai","model":"glm-5.3","usage":{"input":500,"output":500}}}
{"type":"message","id":"a","timestamp":"$timestamp","message":{"role":"assistant","provider":"zai","model":"glm-5.3","usage":{"input":77,"output":77}}}
{"type":"message","id":"f","message":{"role":"assistant","provider":"zai","model":"glm-4.6","timestamp":"2020-01-01T00:00:00Z","usage":{"input":7}}}
{"type":"message","id":"e","message":{"role":"assistant","provider":"zai","usage":{ broken
EOF

run() {
  env -u ZAI_API_KEY -u ZHIPU_API_KEY -u ZHIPUAI_API_KEY \
    HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" XDG_CACHE_HOME="$TEST_HOME/.cache" \
    "$ROOT/bin/omarchy-agent-usage-zai" "$@"
}

result=$(run)

[[ $(jq -r '.id + "/" + .name + "/" + (.limits|tostring) + "/" + (.ready|tostring)' <<<"$result") == "zai/Z.ai/[]/true" ]] ||
  fail "Z.ai collector identifies itself and is ready on local stats alone (no key)" "$result"
pass "Z.ai collector reports itself, empty limits, ready on local stats"

# In use here, but no key to ask for its limits.
[[ $(jq -r '.usageStatusText' <<<"$result") == "Waiting for auth" && $(jq -r '.authHelpText' <<<"$result") == *"ZAI_API_KEY"* ]] ||
  fail "Z.ai collector waits for auth when used without a key" "$result"
pass "Z.ai collector waits for auth when used without a key"

# Reasoning tokens fold into output; cache tokens split out; the repeated id is
# counted once, so the glm-5.3 bucket is exactly message a.
[[ $(jq -Sc '.modelUsage["glm-5.3"]' <<<"$result") == '{"cacheCreationInputTokens":2,"cacheReadInputTokens":3,"inputTokens":10,"outputTokens":10}' ]] ||
  fail "Z.ai collector adds reasoning to output and dedups repeated message ids" "$result"
pass "Z.ai collector adds reasoning to output and dedups repeated ids"

# a + b land today (25 + 25); f is an old day and must not inflate today.
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "50" && $(jq -r '.todayPrompts' <<<"$result") == "2" ]] ||
  fail "Z.ai collector keeps a message.timestamp-dated turn out of today's totals" "$result"
[[ $(jq -r '.totalPrompts' <<<"$result") == "3" && $(jq -r '.activeDays' <<<"$result") == "2" ]] ||
  fail "Z.ai collector still counts the old-dated turn in all-time totals" "$result"
pass "Z.ai collector dates turns by message.timestamp, not a dead ts fallback"

# openai (wrong provider), the user turn, and the malformed line all drop out.
[[ $(jq -Sc '.modelUsage | keys' <<<"$result") == '["glm-4.6","glm-4.7","glm-5.3"]' ]] ||
  fail "Z.ai collector filters to Z.ai assistant turns and survives a malformed line" "$result"
pass "Z.ai collector filters providers/roles and survives malformed lines"

# The scan is cached so the panel's per-open --limits-only does not re-walk
# every session file; --force bypasses it.
cache_file=$(ls "$TEST_HOME/.cache/omarchy/agent-usage/"zai-scan-*.json 2>/dev/null | head -n 1)
[[ -n $cache_file && $(jq -r '.schemaVersion' "$cache_file") == "2" && $(jq -r '.stats.todayTotalTokens' "$cache_file") == "50" ]] ||
  fail "Z.ai collector writes a versioned local-stats cache on first scan" "$result"
pass "Z.ai collector writes a local-stats cache on first scan"

# A new turn arrives; --limits-only must reuse the cache instead of rescanning.
cat >>"$session" <<EOF
{"type":"message","id":"g","timestamp":"$timestamp","message":{"role":"assistant","provider":"zai","model":"glm-5.3","usage":{"input":100}}}
EOF

result=$(run --limits-only)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "50" ]] ||
  fail "Z.ai collector --limits-only reuses the cached scan" "$result"
pass "Z.ai collector --limits-only reuses cached local stats"

result=$(run --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "150" ]] ||
  fail "Z.ai collector --force rescans past the cache" "$result"
pass "Z.ai collector --force rescans past the cache"

result=$(run --limits-only)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "150" ]] ||
  fail "Z.ai collector --limits-only sees the cache refreshed by --force" "$result"
pass "Z.ai collector --limits-only sees a refreshed cache after --force"

# Sessions outside the default root: an omp profile, a pi profile, and a pi
# agent dir moved by PI_CODING_AGENT_DIR, all under a $HOME that is a git
# checkout ignoring everything. A forked session repeats its parent's message
# (same id and timestamp) and counts once; lines without an id always count;
# rows whose timestamp or tokens are garbage drop without taking the rest.
ROOTS_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$ROOTS_HOME"' EXIT
mkdir -p "$ROOTS_HOME/.git"
printf '*\n' >"$ROOTS_HOME/.gitignore"
mkdir -p "$ROOTS_HOME/.omp/profiles/work/agent/sessions/p" "$ROOTS_HOME/.pi/profiles/home/agent/sessions/p" "$ROOTS_HOME/moved/sessions/p"
line() {
  printf '{"type":"message",%s"timestamp":%s,"message":{"role":"assistant","provider":"zai","model":"glm-5","usage":{"input":%s}}}\n' "$1" "$2" "$3"
}
{
  line '"id":"parent",' "\"$timestamp\"" 100
  line '' "\"$timestamp\"" 1
  line '' "\"$timestamp\"" 1
} >"$ROOTS_HOME/.omp/profiles/work/agent/sessions/p/a.jsonl"
{
  line '"id":"parent",' "\"$timestamp\"" 100
  line '"id":"child",' "\"$timestamp\"" 10
  line '"id":"bad-ts",' 0 5000
  line '"id":"bad-ts2",' '"not a date"' 5000
  line '"id":"bad-tokens",' "\"$timestamp\"" true
  line '"id":"huge-tokens",' "\"$timestamp\"" 1e300
} >"$ROOTS_HOME/.pi/profiles/home/agent/sessions/p/fork.jsonl"
line '"id":"moved",' "\"$timestamp\"" 1000 >"$ROOTS_HOME/moved/sessions/p/m.jsonl"

roots=$(env -u ZAI_API_KEY -u ZHIPU_API_KEY -u ZHIPUAI_API_KEY \
  HOME="$ROOTS_HOME" PI_CODING_AGENT_DIR="$ROOTS_HOME/moved" XDG_CONFIG_HOME="$ROOTS_HOME/.config" XDG_CACHE_HOME="$ROOTS_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-zai" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$roots") == "1112" && $(jq -r '.totalPrompts' <<<"$roots") == "5" ]] ||
  fail "Z.ai collector scans profiles and PI_CODING_AGENT_DIR past ignore rules, dedups forks, counts id-less lines, skips garbage rows" "$roots"
pass "Z.ai collector scans every pi/omp root, dedups forks, and skips garbage rows"

# opencode's database, both stores side by side as a migrated install keeps
# them: a row only in the original `message` table (reasoning folds into
# output), a V2 compaction only in `session_message`, a migrated row in both
# under one id (counted once), a fork's copy of its source's message (skipped)
# and what the fork added after (counted), plus another provider's row, a user
# turn and a malformed row, none of them counted. 21 + 30 + 40 + 50 = 141.
opencode_fixture() {
  python3 - "$@" <<'PY'
import json, sqlite3, sys, time
db, provider_a, model_a, provider_b, model_b, decoy_provider, decoy_model = sys.argv[1:]
now = int(time.time() * 1000) - 5000
def v1(provider, model, tokens, role="assistant"):
  return json.dumps({"role": role, "providerID": provider, "modelID": model, "tokens": tokens, "time": {"created": now}})
def v2(provider, model, tokens):
  return json.dumps({"model": {"providerID": provider, "id": model}, "tokens": tokens, "time": {"created": now}})
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text, time_created integer, time_updated integer, data text)")
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text, type text, time_created integer, data text)")
conn.execute("CREATE TABLE session_v2 (id text PRIMARY KEY, fork_session_id text, time_created integer)")
conn.execute("INSERT INTO session_v2 VALUES ('ses_fork', 'ses_v2', ?)", (now - 30000,))
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  ("msg_v1", "ses_v1", now, now, v1(provider_a, model_a, {"input": 10, "output": 5, "reasoning": 2, "cache": {"read": 3, "write": 1}})),
  ("msg_both", "ses_v1", now, now, v1(provider_a, model_a, {"input": 40})),
  ("msg_decoy", "ses_v1", now, now, v1(decoy_provider, decoy_model, {"input": 999})),
  ("msg_user", "ses_v1", now, now, v1(provider_a, model_a, {"input": 777}, role="user")),
])
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?)", [
  ("msg_v2", "ses_v2", "compaction", now, v2(provider_b, model_b, {"input": 30})),
  ("msg_both", "ses_v1", "assistant", now, v2(provider_a, model_a, {"input": 40})),
  ("msg_copy", "ses_fork", "assistant", now - 60000, v2(provider_b, model_b, {"input": 1000})),
  ("msg_forked", "ses_fork", "assistant", now - 10000, v2(provider_b, model_b, {"input": 50})),
  ("msg_bad", "ses_v2", "assistant", now, '{"model":{"providerID":"%s"' % provider_b),
])
conn.commit()
conn.close()
PY
}

OC_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$ROOTS_HOME" "$OC_HOME"' EXIT
mkdir -p "$OC_HOME/.local/share/opencode"
opencode_fixture "$OC_HOME/.local/share/opencode/opencode.db" zai glm-5.3 zhipu glm-4.7 opencode glm-5.3
oc_run() {
  env -u ZAI_API_KEY -u ZHIPU_API_KEY -u ZHIPUAI_API_KEY -u PI_CODING_AGENT_DIR -u XDG_DATA_HOME -u OPENCODE_DB "$@" \
    HOME="$OC_HOME" XDG_CONFIG_HOME="$OC_HOME/.config" XDG_CACHE_HOME="$OC_HOME/.cache" \
    "$ROOT/bin/omarchy-agent-usage-zai" --force
}
oc=$(oc_run)
[[ $(jq -c '[.todayTotalTokens, .totalPrompts, .modelUsage["glm-5.3"].outputTokens, .modelUsage["glm-4.7"].inputTokens]' <<<"$oc") == "[141,4,7,80]" ]] ||
  fail "Z.ai collector counts zai and zhipu rows from both opencode stores once, skipping fork copies" "$oc"
pass "Z.ai collector counts zai and zhipu rows from both opencode stores once"

# OPENCODE_DB names the database opencode reads, a relative name beside the
# default one; opencode-v2.db is read only when opencode.db is absent.
mv "$OC_HOME/.local/share/opencode/opencode.db" "$OC_HOME/.local/share/opencode/custom.db"
oc=$(oc_run OPENCODE_DB=custom.db)
[[ $(jq -r '.todayTotalTokens' <<<"$oc") == "141" ]] ||
  fail "Z.ai collector reads the opencode database OPENCODE_DB names" "$oc"
mv "$OC_HOME/.local/share/opencode/custom.db" "$OC_HOME/.local/share/opencode/opencode-v2.db"
oc=$(oc_run)
[[ $(jq -r '.todayTotalTokens' <<<"$oc") == "141" ]] ||
  fail "Z.ai collector falls back to opencode-v2.db" "$oc"
pass "Z.ai collector honours OPENCODE_DB and the opencode-v2.db fallback"
