#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3
require_command rg

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# Every path the collector reads or writes lives in the test home.
export HOME="$TEST_HOME"
export XDG_CACHE_HOME="$TEST_HOME/cache"
export XDG_DATA_HOME="$TEST_HOME/data"
export XDG_CONFIG_HOME="$TEST_HOME/config"
unset DEVIN_DATA_DIR DEVIN_CACHE_DIR PI_CODING_AGENT_DIR OPENCODE_DB

collector="$ROOT/bin/omarchy-agent-usage-devin"
DATA_DIR="$XDG_DATA_HOME/devin/cli"
STATUS_DIR="$XDG_CACHE_HOME/devin/cli"
SCAN_CACHE="$XDG_CACHE_HOME/omarchy/agent-usage"

now=$(date +%s)
today=$(date +%Y-%m-%d)
yesterday=$(date -d yesterday +%Y-%m-%d)

run() {
  "$collector" "$@"
}

# ------------------------------------------------------------ unused machine

result=$(run)
[[ $(jq -r '.ready' <<<"$result") == "false" ]] ||
  fail "Devin collector is not ready on an unused machine" "$result"
[[ $(jq -c '[.limits, .usageStatusText, .authHelpText, .tierLabel, .todayTotalTokens, (.recentDays | length), .modelUsage, has("balance"), has("retryAdvised")]' <<<"$result") == '[[],"","","",0,7,{},false,false]' ]] ||
  fail "Devin collector prints an empty record on an unused machine" "$result"
[[ $(jq -r '.id + ":" + .name' <<<"$result") == "devin:Devin" ]] ||
  fail "Devin collector identifies itself" "$result"
pass "Devin collector prints an empty, not-ready record on an unused machine"

# ------------------------------------------------------- the CLI's database

mkdir -p "$DATA_DIR"
python3 - "$DATA_DIR/sessions.db" "$now" <<'PY'
import json, sqlite3, sys

db_path, now = sys.argv[1], int(sys.argv[2])
conn = sqlite3.connect(db_path)
conn.execute("CREATE TABLE message_nodes (row_id INTEGER PRIMARY KEY, session_id TEXT, node_id INTEGER, parent_node_id INTEGER, chat_message TEXT, created_at INTEGER, metadata TEXT)")
conn.execute("CREATE TABLE prompt_history (id INTEGER PRIMARY KEY, content TEXT, timestamp INTEGER, session_id TEXT, is_shell INTEGER)")

def node(session, created, model, inp, out, cache_read=0, cache_write=0):
  metrics = {"input_tokens": inp, "output_tokens": out, "cache_read_tokens": cache_read, "cache_creation_tokens": cache_write}
  conn.execute("INSERT INTO message_nodes (session_id, chat_message, created_at) VALUES (?, ?, ?)",
               (session, json.dumps({"metadata": {"metrics": metrics, "generation_model": model}}), created))

node("s1", now, "glm-5-2", 100, 20, 60, 0)
node("s1", now, "glm-5-2", 80, 10, 50, 0)
node("s1", now, "devin-pro", 200, 40, 0, 10)
node("s2", now - 86400, "glm-5-2", 50, 5)
# Untrusted fields skip themselves, or the row, never the scan: a boolean,
# a negative count and a string count read as nothing; a row with a broken
# timestamp, no metrics, or no JSON at all adds nothing.
node("s1", now, "glm-5-2", True, -5, "7", 0)
node("s1", "yesterday-ish", "glm-5-2", 999, 999)
node("s1", 10**15, "glm-5-2", 999, 999)
conn.execute("INSERT INTO message_nodes (session_id, chat_message, created_at) VALUES ('s1', ?, ?)", (json.dumps({"metadata": {}}), now))
conn.execute("INSERT INTO message_nodes (session_id, chat_message, created_at) VALUES ('s1', '{not json \"metrics\"', ?)", (now,))

for content, timestamp, session in (("a", now, "s1"), ("b", now, "s1"), ("c", now, "s3"), ("d", now - 86400, "s2"), ("e", now - 86400, "s1")):
  conn.execute("INSERT INTO prompt_history (content, timestamp, session_id, is_shell) VALUES (?, ?, ?, 0)", (content, timestamp, session))
conn.commit()
conn.close()
PY

result=$(run --force)
# (100+20+60) + (80+10+50) + (200+40+10) = 570; the boolean and negative
# counts read as nothing, so the odd row adds nothing.
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "570" ]] ||
  fail "Devin collector counts today's tokens across models" "$result"
[[ $(jq -c '[.todayPrompts, .todaySessions, .totalPrompts, .totalSessions, .activeDays]' <<<"$result") == "[3,2,5,3,2]" ]] ||
  fail "Devin collector counts prompts from prompt_history and a midnight-spanning session once" "$result"
[[ $(jq -c '.modelUsage["glm-5-2"]' <<<"$result") == '{"cacheCreationInputTokens":0,"cacheReadInputTokens":110,"inputTokens":230,"outputTokens":35}' ]] ||
  fail "Devin collector aggregates glm-5-2 model usage" "$result"
[[ $(jq -c '.modelUsage["devin-pro"]' <<<"$result") == '{"cacheCreationInputTokens":10,"cacheReadInputTokens":0,"inputTokens":200,"outputTokens":40}' ]] ||
  fail "Devin collector aggregates devin-pro model usage" "$result"
[[ $(jq -r --arg d "$yesterday" '.recentDays[] | select(.date == $d) | .messageCount' <<<"$result") == "55" ]] ||
  fail "Devin collector fills yesterday's recent day" "$result"
pass "Devin collector reads the CLI's session database, skipping untrusted fields"

# In use without any sign-in: the quota has nowhere to come from.
[[ $(jq -c '[.ready, .usageStatusText, .limits]' <<<"$result") == '[true,"Waiting for auth",[]]' ]] ||
  fail "Devin collector waits for auth when the CLI was never signed in" "$result"
pass "Devin collector waits for auth when in use without a sign-in"

# ---------------------------------------------------------- scan reuse

python3 - "$DATA_DIR/sessions.db" "$now" <<'PY'
import json, sqlite3, sys
conn = sqlite3.connect(sys.argv[1])
conn.execute("INSERT INTO message_nodes (session_id, chat_message, created_at) VALUES ('s1', ?, ?)",
             (json.dumps({"metadata": {"metrics": {"input_tokens": 1000, "output_tokens": 0}, "generation_model": "glm-5-2"}}), int(sys.argv[2])))
conn.commit()
conn.close()
PY

[[ $(jq -r '.todayTotalTokens' <<<"$(run)") == "570" ]] ||
  fail "Devin collector reuses a seconds-old scan" "$(run)"
[[ $(jq -r '.todayTotalTokens' <<<"$(run --limits-only)") == "570" ]] ||
  fail "Devin collector reuses a scan for --limits-only" "$(run --limits-only)"
[[ $(jq -r '.todayTotalTokens' <<<"$(run --force)") == "1570" ]] ||
  fail "Devin collector --force rescans past the cache" "$(run --force)"
pass "Devin collector reuses a recent scan and --force rescans"

# A cache from another day holds another day's today* numbers.
cache_file=$(ls "$SCAN_CACHE"/devin-scan-*.json | head -n 1)
jq -c '.scanDate = "1999-01-01" | .stats.todayTotalTokens = 1' "$cache_file" >"$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
[[ $(jq -r '.todayTotalTokens' <<<"$(run --limits-only)") == "1570" ]] ||
  fail "Devin collector treats a scan from another day as a miss" "$(run --limits-only)"
pass "Devin collector treats a scan from another day as a miss"

# A database it cannot read costs the stats, never the record, and is not
# cached as the whole story.
cp "$DATA_DIR/sessions.db" "$TEST_HOME/sessions.db.good"
echo "not a database" >"$DATA_DIR/sessions.db"
rm -f "$SCAN_CACHE"/devin-scan-*.json
result=$(run --force 2>/dev/null)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "0" && $(jq -r '.id' <<<"$result") == "devin" ]] ||
  fail "Devin collector survives an unreadable session database" "$result"
[[ -z $(ls "$SCAN_CACHE"/devin-scan-*.json 2>/dev/null) ]] ||
  fail "Devin collector does not cache a scan that could not read the database" "$result"
pass "Devin collector survives an unreadable database without caching it"
mv "$TEST_HOME/sessions.db.good" "$DATA_DIR/sessions.db"

# ------------------------------------------------------------- quota cache

# write_status <file> <fetched_at> [key=value...]: a user-status cache the CLI
# would write, built from the GetUserStatus fields the collector reads.
write_status() {
  python3 - "$STATUS_DIR" "$@" <<'PY'
import base64, json, os, sys

directory, name, fetched_at = sys.argv[1], sys.argv[2], int(sys.argv[3])
options = dict(arg.split("=", 1) for arg in sys.argv[4:])
os.makedirs(directory, exist_ok=True)

def varint(value):
  value &= (1 << 64) - 1
  out = b""
  while True:
    byte = value & 0x7F
    value >>= 7
    out += bytes([byte | 0x80]) if value else bytes([byte])
    if not value:
      return out

def field(number, data):
  if isinstance(data, int):
    return varint(number << 3) + varint(data)
  return varint((number << 3) | 2) + varint(len(data)) + data

plan = b""
if options.get("plan"):
  plan += field(2, options["plan"].encode())
for key, number in (("tier", 1), ("billing", 35), ("hideDaily", 36), ("hideWeekly", 37), ("promptLimit", 12)):
  if key in options:
    plan += field(number, int(options[key]))
status = field(1, plan)
for key, number in (("daily", 14), ("weekly", 15), ("dailyReset", 17), ("weeklyReset", 18), ("promptUsed", 6)):
  if key in options:
    status += field(number, int(options[key]))
if "planEnd" in options:
  status += field(3, field(1, int(options["planEnd"])))
payload = field(13, status)
if "userTier" in options:
  payload = field(10, int(options["userTier"])) + payload

with open(os.path.join(directory, f"user_status.{name}.bin"), "w") as handle:
  json.dump({"version": 1, "identity_digest": name, "fetched_at_secs": fetched_at, "payload": base64.b64encode(payload).decode()}, handle)
PY
}

write_status a "$now" plan=Pro daily=69 weekly=53 dailyReset=$((now + 3600)) weeklyReset=$((now + 4 * 86400))
result=$(run)
[[ $(jq -c '[.tierLabel, [.limits[] | [.label, .percent]], .limitsStale, .limitsFetchedAt, .usageStatusText, .authHelpText]' <<<"$result") == "[\"Pro\",[[\"Daily\",0.31],[\"Weekly\",0.47]],false,$((now * 1000)),\"\",\"\"]" ]] ||
  fail "Devin collector reads fresh quota from the user-status cache" "$result"
[[ $(jq -r '.limits[0].resetsAt' <<<"$result") == "$(date -u -d "@$((now + 3600))" +%Y-%m-%dT%H:%M:%S+00:00)" ]] ||
  fail "Devin collector keeps the service's own reset time" "$result"
[[ $(jq -r 'has("retryAdvised")' <<<"$result") == "false" ]] ||
  fail "Devin collector never advises a retry, having no check to retry" "$result"
pass "Devin collector reads fresh quota from the CLI's cache"

# The quota is read on every run, past the scan reuse, so a fetch the CLI
# just made shows without --force.
write_status a "$now" plan=Pro daily=50 weekly=53 dailyReset=$((now + 3600)) weeklyReset=$((now + 4 * 86400))
[[ $(jq -r '.limits[0].percent' <<<"$(run)") == "0.5" ]] ||
  fail "Devin collector reads the quota cache on every run" "$(run)"
pass "Devin collector reads the quota cache on every run"

# Spent windows: proto3 leaves a zero off the wire, so a dated window with
# no percent has nothing left.
write_status a "$now" plan=Pro dailyReset=$((now + 3600))
[[ $(jq -c '[.limits[] | [.label, .percent]]' <<<"$(run)") == '[["Daily",1.0]]' ]] ||
  fail "Devin collector reads a missing percent on a dated window as spent" "$(run)"
pass "Devin collector reads a missing percent on a dated window as spent"

# A cache from more than fifteen minutes ago still describes the account, but
# is reported stale with its age; a window that reset since is back at zero.
write_status a $((now - 7200)) plan=Pro daily=10 weekly=40 dailyReset=$((now - 60)) weeklyReset=$((now + 86400))
result=$(run)
[[ $(jq -c '[.limitsStale, .limitsFetchedAt, [.limits[] | [.label, .percent, .resetsAt != ""]], .usageStatusText]' <<<"$result") == "[true,$(((now - 7200) * 1000)),[[\"Daily\",0.0,false],[\"Weekly\",0.6,true]],\"\"]" ]] ||
  fail "Devin collector keeps an old quota stale and zeroes an elapsed window" "$result"
pass "Devin collector reports an old quota stale, with elapsed windows at zero"

# Fetches from before the last sign-in describe another account.
creds="$XDG_DATA_HOME/devin/credentials.toml"
echo 'api_server_url = "https://example.invalid"' >"$creds"
touch -d "@$((now + 600))" "$creds"
write_status a "$now" plan=Pro daily=69 weekly=53 dailyReset=$((now + 3600)) weeklyReset=$((now + 86400))
result=$(run)
[[ $(jq -c '[.ready, .tierLabel, .limits, .usageStatusText]' <<<"$result") == '[true,"",[],"Devin limits unavailable"]' ]] ||
  fail "Devin collector drops quota fetched before the last sign-in" "$result"
[[ $(jq -r '.authHelpText' <<<"$result") == *"Start Devin"* ]] ||
  fail "Devin collector says how to refresh the quota after a sign-in" "$result"
pass "Devin collector drops quota fetched before the last sign-in"

# Of the caches fetched since, the newest wins.
touch -d "@$((now - 600))" "$creds"
write_status b $((now - 300)) plan=Max daily=0 weekly=0 dailyReset=$((now + 3600))
[[ $(jq -r '.tierLabel' <<<"$(run)") == "Pro" ]] ||
  fail "Devin collector serves the newest fetch under the current sign-in" "$(run)"
rm "$STATUS_DIR/user_status.b.bin"
pass "Devin collector serves the newest fetch under the current sign-in"

# The old account's last fetch can land in the seconds before a switch, inside
# the allowance for the new account's first fetch. Having been served under
# the old sign-in, it is known to be the old account's and stays out.
touch -d "@$((now - 3600))" "$creds"
write_status a $((now - 100)) plan=Pro daily=69 weekly=53 dailyReset=$((now + 3600)) weeklyReset=$((now + 86400))
[[ $(jq -r '.tierLabel' <<<"$(run)") == "Pro" ]] ||
  fail "Devin collector serves the account signed in" "$(run)"
touch -d "@$((now - 90))" "$creds"
result=$(run)
[[ $(jq -c '[.tierLabel, .limits, .usageStatusText]' <<<"$result") == '["",[],"Devin limits unavailable"]' ]] ||
  fail "Devin collector drops the old account's fetch from just before a switch" "$result"
write_status b $((now - 95)) plan=Max daily=0 weekly=0 dailyReset=$((now + 3600))
[[ $(jq -r '.tierLabel' <<<"$(run)") == "Max" ]] ||
  fail "Devin collector serves the new account's first fetch from just before the switch" "$(run)"
rm "$STATUS_DIR/user_status.b.bin"
write_status a "$now" plan=Pro daily=69 weekly=53 dailyReset=$((now + 3600)) weeklyReset=$((now + 86400))
[[ $(jq -r '.tierLabel' <<<"$(run)") == "Pro" ]] ||
  fail "Devin collector serves a fetch made after the sign-in" "$(run)"
pass "Devin collector keeps the old account's quota out across a quick switch"

# A plan can hide a window; credit buckets run to the plan's end; a plan
# without a name of its own is named by its tier.
write_status a "$now" tier=16 hideDaily=1 daily=10 weekly=80 dailyReset=$((now + 3600)) weeklyReset=$((now + 86400)) promptLimit=500 promptUsed=125 planEnd=$((now + 20 * 86400))
result=$(run)
[[ $(jq -c '[.tierLabel, [.limits[] | [.label, .percent]]]' <<<"$result") == '["Devin Pro",[["Weekly",0.2],["Prompt credits",0.25]]]' ]] ||
  fail "Devin collector honors hidden windows, credit buckets and tier names" "$result"
pass "Devin collector honors hidden windows, credit buckets and tier names"

# A credit plan leaves the quota percents at their defaults with no reset:
# those windows are not meters.
write_status a "$now" plan=Pro billing=1
[[ $(jq -c '.limits' <<<"$(run)") == "[]" ]] ||
  fail "Devin collector shows no quota windows on a credit plan" "$(run)"
pass "Devin collector shows no quota windows on a credit plan"

# A broken cache file is no quota at all.
echo '{"fetched_at_secs": true, "payload": "%%%"}' >"$STATUS_DIR/user_status.a.bin"
[[ $(jq -r '.usageStatusText' <<<"$(run)") == "Devin limits unavailable" ]] ||
  fail "Devin collector ignores a broken quota cache" "$(run)"
pass "Devin collector ignores a broken quota cache"
rm -rf "$STATUS_DIR" "$creds"

# ------------------------------------------------------------- pi and omp

rm -rf "$DATA_DIR"
pi_sessions="$TEST_HOME/.pi/agent/sessions/--work--"
omp_profile="$TEST_HOME/.omp/profiles/work/agent/sessions/--work--"
mkdir -p "$pi_sessions" "$omp_profile"
stamp="${today}T12:00:00.000Z"
pi_line() {
  local id=$1 provider=$2 input=$3 output=$4
  printf '{"type":"message","id":"%s","timestamp":"%s","message":{"role":"assistant","provider":"%s","model":"swe-1.6","usage":{"input":%s,"output":%s,"cacheRead":10,"cacheWrite":0}}}\n' "$id" "$stamp" "$provider" "$input" "$output"
}
{
  pi_line m1 devin 100 20
  pi_line m2 devin 200 40
  pi_line m3 anthropic 999 999
} >"$pi_sessions/one.jsonl"
# A fork repeats its parent's message with the same id and timestamp.
{
  pi_line m2 devin 200 40
  pi_line m4 devin 1 1
} >"$omp_profile/fork.jsonl"
# A $HOME that is a git checkout ignoring everything must not hide sessions.
printf '*\n' >"$TEST_HOME/.gitignore"
git -C "$TEST_HOME" init -q

result=$(run --force)
# m1 130 + m2 250 + m4 12; the fork's copy of m2 and the anthropic message
# are not Devin's to count.
[[ $(jq -c '[.todayTotalTokens, .todayPrompts, .todaySessions, .modelUsage["swe-1.6"].inputTokens]' <<<"$result") == "[392,3,2,301]" ]] ||
  fail "Devin collector counts pi/omp devin messages once, profiles included" "$result"
pass "Devin collector counts pi and omp sessions on the devin provider once"

# PI_CODING_AGENT_DIR moves pi's sessions, read as well as the default tree,
# which keeps what was written before the move: 392 + m9's 20.
moved="$TEST_HOME/elsewhere"
mkdir -p "$moved/sessions/--work--"
pi_line m9 devin 5 5 >"$moved/sessions/--work--/moved.jsonl"
[[ $(jq -r '.todayTotalTokens' <<<"$(PI_CODING_AGENT_DIR="$moved" run --force)") == "412" ]] ||
  fail "Devin collector follows PI_CODING_AGENT_DIR" "$(PI_CODING_AGENT_DIR="$moved" run --force)"
pass "Devin collector follows PI_CODING_AGENT_DIR"
rm -rf "$TEST_HOME/.pi" "$TEST_HOME/.omp"

# --------------------------------------------------------- the older layout

# Builds without the cli/ directory kept one lifetime total per session.
python3 - "$XDG_DATA_HOME/devin/cli_sessions.db" "$now" <<'PY'
import sqlite3, sys
conn = sqlite3.connect(sys.argv[1]); now = int(sys.argv[2])
conn.execute("CREATE TABLE sessions (id TEXT, working_directory TEXT, backend_type TEXT, model TEXT, permission_mode TEXT, created_at INTEGER, last_activity_at INTEGER, total_tokens INTEGER, current_epoch INTEGER)")
conn.execute("CREATE TABLE messages (id TEXT, session_id TEXT, sequence_number INTEGER, role TEXT, content TEXT, tool_call_id TEXT, tool_calls_json TEXT, timestamp INTEGER, compaction_epoch INTEGER)")
conn.execute("INSERT INTO sessions (id, model, created_at, last_activity_at, total_tokens) VALUES ('o1', 'swe-1.5', ?, ?, 4000)", (now - 86400, now))
conn.execute("INSERT INTO messages (id, session_id, role, timestamp) VALUES ('1', 'o1', 'user', ?), ('2', 'o1', 'assistant', ?), ('3', 'o1', 'assistant', ?)", (now, now, now))
conn.commit(); conn.close()
PY
result=$(run --force)
[[ $(jq -c '[.todayTotalTokens, .todayPrompts, .totalSessions, .modelUsage["swe-1.5"].inputTokens]' <<<"$result") == "[4000,2,1,4000]" ]] ||
  fail "Devin collector falls back to the older per-session layout" "$result"
pass "Devin collector falls back to the older per-session layout"

# Once the CLI's own database exists, the older files are not read again.
mkdir -p "$DATA_DIR"
python3 - "$DATA_DIR/sessions.db" <<'PY'
import sqlite3, sys
conn = sqlite3.connect(sys.argv[1])
conn.execute("CREATE TABLE message_nodes (row_id INTEGER PRIMARY KEY, session_id TEXT, chat_message TEXT, created_at INTEGER)")
conn.execute("CREATE TABLE prompt_history (id INTEGER PRIMARY KEY, timestamp INTEGER, session_id TEXT)")
conn.commit(); conn.close()
PY
[[ $(jq -r '.todayTotalTokens' <<<"$(run --force)") == "0" ]] ||
  fail "Devin collector reads only the CLI's own database when it exists" "$(run --force)"
pass "Devin collector reads only the CLI's own database when it exists"

# --------------------------------------------------------------- opencode

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

OC_HOME="$TEST_HOME/opencode-home"
mkdir -p "$OC_HOME/data/opencode"
opencode_fixture "$OC_HOME/data/opencode/opencode.db" devin swe-1.5 devin swe-1.6 opencode swe-1.5
oc_run() {
  env "$@" HOME="$OC_HOME" XDG_DATA_HOME="$OC_HOME/data" XDG_CACHE_HOME="$OC_HOME/cache" XDG_CONFIG_HOME="$OC_HOME/config" \
    "$collector" --force
}
oc=$(oc_run)
[[ $(jq -c '[.todayTotalTokens, .totalPrompts, .totalSessions, .modelUsage["swe-1.5"].outputTokens, .modelUsage["swe-1.6"].inputTokens]' <<<"$oc") == "[141,4,3,7,80]" ]] ||
  fail "Devin collector counts devin rows from both opencode stores once, skipping fork copies" "$oc"
pass "Devin collector counts devin rows from both opencode stores once"

# OPENCODE_DB names the database opencode reads, a relative name beside the
# default one; opencode-v2.db is read only when opencode.db is absent.
mv "$OC_HOME/data/opencode/opencode.db" "$OC_HOME/data/opencode/custom.db"
oc=$(oc_run OPENCODE_DB=custom.db)
[[ $(jq -r '.todayTotalTokens' <<<"$oc") == "141" ]] ||
  fail "Devin collector reads the opencode database OPENCODE_DB names" "$oc"
mv "$OC_HOME/data/opencode/custom.db" "$OC_HOME/data/opencode/opencode-v2.db"
oc=$(oc_run)
[[ $(jq -r '.todayTotalTokens' <<<"$oc") == "141" ]] ||
  fail "Devin collector falls back to opencode-v2.db" "$oc"
pass "Devin collector honours OPENCODE_DB and the opencode-v2.db fallback"
