#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# Every collector run must use the test cache root: without this, scans would
# write to (or read from) the real XDG cache when it is set in the environment.
export XDG_CACHE_HOME="$TEST_HOME/.cache"

DEVIN_DATA_DIR="$TEST_HOME/.local/share/devin/cli"
mkdir -p "$DEVIN_DATA_DIR"

now=$(date +%s)
today=$(date +%Y-%m-%d)
yesterday=$(date -d yesterday +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)

# Build a mock sessions.db with the schema the collector expects.
python3 - "$DEVIN_DATA_DIR/sessions.db" "$now" "$today" "$yesterday" <<'PY'
import json, sqlite3, sys

db_path, now, today, yesterday = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]

conn = sqlite3.connect(db_path)
conn.execute("CREATE TABLE message_nodes (row_id INTEGER PRIMARY KEY, session_id TEXT, node_id INTEGER, parent_node_id INTEGER, chat_message TEXT, created_at INTEGER, metadata TEXT)")
conn.execute("CREATE TABLE prompt_history (id INTEGER PRIMARY KEY, content TEXT, timestamp INTEGER, session_id TEXT, is_shell INTEGER)")

def assistant_msg(model, inp, out, cache_read=0, cache_write=0):
    return json.dumps({
        "metadata": {
            "metrics": {
                "input_tokens": inp,
                "output_tokens": out,
                "cache_read_tokens": cache_read,
                "cache_creation_tokens": cache_write,
            },
            "generation_model": model,
        }
    })

# Today: two turns with glm-5-2, one with devin-pro
conn.execute("INSERT INTO message_nodes (session_id, node_id, chat_message, created_at) VALUES (?, 1, ?, ?)",
             ("s1", assistant_msg("glm-5-2", 100, 20, 60, 0), now))
conn.execute("INSERT INTO message_nodes (session_id, node_id, chat_message, created_at) VALUES (?, 2, ?, ?)",
             ("s1", assistant_msg("glm-5-2", 80, 10, 50, 0), now))
conn.execute("INSERT INTO message_nodes (session_id, node_id, chat_message, created_at) VALUES (?, 3, ?, ?)",
             ("s1", assistant_msg("devin-pro", 200, 40, 0, 10), now))

# Yesterday: one turn
conn.execute("INSERT INTO message_nodes (session_id, node_id, chat_message, created_at) VALUES (?, 4, ?, ?)",
             ("s2", assistant_msg("glm-5-2", 50, 5, 0, 0), now - 86400))

# A row with no metrics should be skipped
conn.execute("INSERT INTO message_nodes (session_id, node_id, chat_message, created_at) VALUES (?, 5, ?, ?)",
             ("s1", json.dumps({"metadata": {}}), now))

# A malformed row must not abort the whole scan
conn.execute("INSERT INTO message_nodes (session_id, node_id, chat_message, created_at) VALUES (?, 6, ?, ?)",
             ("s1", "{not json", now))

# Prompt history: 3 prompts today across 2 sessions, 2 yesterday — one prompt
# belongs to today's session s1, so per-day session counts sum to 4 while the
# true distinct total is 3
conn.execute("INSERT INTO prompt_history (content, timestamp, session_id, is_shell) VALUES (?, ?, 's1', 0)", ("hello", now))
conn.execute("INSERT INTO prompt_history (content, timestamp, session_id, is_shell) VALUES (?, ?, 's1', 0)", ("world", now))
conn.execute("INSERT INTO prompt_history (content, timestamp, session_id, is_shell) VALUES (?, ?, 's3', 0)", ("test", now))
conn.execute("INSERT INTO prompt_history (content, timestamp, session_id, is_shell) VALUES (?, ?, 's2', 0)", ("yesterday", now - 86400))
conn.execute("INSERT INTO prompt_history (content, timestamp, session_id, is_shell) VALUES (?, ?, 's1', 0)", ("late night", now - 86400))

conn.commit()
conn.close()
PY

result=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin")

# Today: (100+20+60) + (80+10+50) + (200+40+0+10) = 570
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "570" ]] ||
  fail "Devin collector counts today's tokens across models" "$result"
pass "Devin collector counts today's tokens across models"

# 3 prompts today across 2 sessions
[[ $(jq -r '.todayPrompts' <<<"$result") == "3" ]] ||
  fail "Devin collector counts today's prompts" "$result"
[[ $(jq -r '.todaySessions' <<<"$result") == "2" ]] ||
  fail "Devin collector counts today's sessions" "$result"
pass "Devin collector counts today's prompts and sessions"

# Model usage (all-time): glm-5-2 = (100+80+50) input, (20+10+5) output, (60+50+0) cache_read, 0 cache_write
#                         devin-pro = 200 input, 40 output, 0 cache_read, 10 cache_write
[[ $(jq -c '.modelUsage["glm-5-2"]' <<<"$result") == '{"cacheCreationInputTokens":0,"cacheReadInputTokens":110,"inputTokens":230,"outputTokens":35}' ]] ||
  fail "Devin collector aggregates glm-5-2 model usage" "$result"
[[ $(jq -c '.modelUsage["devin-pro"]' <<<"$result") == '{"cacheCreationInputTokens":10,"cacheReadInputTokens":0,"inputTokens":200,"outputTokens":40}' ]] ||
  fail "Devin collector aggregates devin-pro model usage" "$result"
pass "Devin collector aggregates model usage correctly"

# Total prompts = 5 (3 today + 2 yesterday); total sessions = 3 distinct
# (s1, s2, s3) — s1 spans midnight and must not count twice
[[ $(jq -r '.totalPrompts' <<<"$result") == "5" ]] ||
  fail "Devin collector counts total prompts" "$result"
[[ $(jq -r '.totalSessions' <<<"$result") == "3" ]] ||
  fail "Devin collector counts a midnight-spanning session once" "$result"
pass "Devin collector counts total prompts and dedupes cross-day sessions"

# Active days = 2 (today + yesterday)
[[ $(jq -r '.activeDays' <<<"$result") == "2" ]] ||
  fail "Devin collector counts active days" "$result"
pass "Devin collector counts active days"

# Recent days: today should have 570, yesterday should have 55 (50+5)
[[ $(jq -r '[.recentDays[] | select(.date == "'$today'") | .messageCount] | .[0]' <<<"$result") == "570" ]] ||
  fail "Devin collector fills today's recent day" "$result"
[[ $(jq -r '[.recentDays[] | select(.date == "'$yesterday'") | .messageCount] | .[0]' <<<"$result") == "55" ]] ||
  fail "Devin collector fills yesterday's recent day" "$result"
pass "Devin collector fills the seven-day token series"

# No limits
[[ $(jq -c '.limits' <<<"$result") == "[]" ]] ||
  fail "Devin collector reports no limits" "$result"
pass "Devin collector reports no limits"

# Identifies itself
[[ $(jq -r '.id' <<<"$result") == "devin" ]] ||
  fail "Devin collector identifies itself" "$result"
[[ $(jq -r '.name' <<<"$result") == "Devin" ]] ||
  fail "Devin collector names itself" "$result"
pass "Devin collector identifies itself"

# Missing database
rm "$DEVIN_DATA_DIR/sessions.db"
result=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin")
[[ $(jq -r '.usageStatusText' <<<"$result") == "Devin CLI not installed" ]] ||
  fail "Devin collector reports missing database" "$result"
[[ $(jq -r '.authHelpText' <<<"$result") != "" ]] ||
  fail "Devin collector shows install hint for missing database" "$result"
pass "Devin collector reports missing database gracefully"

# Caching: a second run without --force should reuse the cached scan
# (rebuild the DB since we deleted it above)
mkdir -p "$DEVIN_DATA_DIR"
python3 - "$DEVIN_DATA_DIR/sessions.db" "$now" <<'PY'
import json, sqlite3, sys
db_path, now = sys.argv[1], int(sys.argv[2])
conn = sqlite3.connect(db_path)
conn.execute("CREATE TABLE message_nodes (row_id INTEGER PRIMARY KEY, session_id TEXT, node_id INTEGER, chat_message TEXT, created_at INTEGER, metadata TEXT)")
conn.execute("CREATE TABLE prompt_history (id INTEGER PRIMARY KEY, content TEXT, timestamp INTEGER, session_id TEXT, is_shell INTEGER)")
conn.execute("INSERT INTO message_nodes (session_id, node_id, chat_message, created_at) VALUES ('s1', 1, ?, ?)",
             (json.dumps({"metadata": {"metrics": {"input_tokens": 10, "output_tokens": 5, "cache_read_tokens": 0, "cache_creation_tokens": 0}, "generation_model": "test"}}), now))
conn.execute("INSERT INTO prompt_history (content, timestamp, session_id, is_shell) VALUES ('hi', ?, 's1', 0)", (now,))
conn.commit()
conn.close()
PY

# Clear the scan cache the earlier scenarios wrote so this run starts cold
rm -f "$TEST_HOME/.cache/omarchy/agent-usage/devin-scan-"*

# First run populates the cache
result1=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin")
[[ $(jq -r '.todayTotalTokens' <<<"$result1") == "15" ]] ||
  fail "Devin collector first scan populates cache" "$result1"

# Add more data after the cache is written
python3 - "$DEVIN_DATA_DIR/sessions.db" "$now" <<'PY'
import json, sqlite3, sys
db_path, now = sys.argv[1], int(sys.argv[2])
conn = sqlite3.connect(db_path)
conn.execute("INSERT INTO message_nodes (session_id, node_id, chat_message, created_at) VALUES ('s1', 2, ?, ?)",
             (json.dumps({"metadata": {"metrics": {"input_tokens": 100, "output_tokens": 50, "cache_read_tokens": 0, "cache_creation_tokens": 0}, "generation_model": "test"}}), now))
conn.commit()
conn.close()
PY

# Second run without --force should still serve the cached value (15, not 165)
result2=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin")
[[ $(jq -r '.todayTotalTokens' <<<"$result2") == "15" ]] ||
  fail "Devin collector serves cached scan without --force" "$result2"
pass "Devin collector serves cached scan without --force"

# --force bypasses the cache and sees the new data (165)
result3=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$result3") == "165" ]] ||
  fail "Devin collector --force rescans past the cache" "$result3"
pass "Devin collector --force rescans past the cache"

# A scan crossing midnight must not stamp the old day's totals with the new
# date: simulate the date flipping mid-scan, then confirm the entry misses
# on the next read instead of being served as today's.
if ! HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" python3 - "$ROOT" <<'PY'
import importlib.machinery, importlib.util, json, os, sqlite3, sys

loader = importlib.machinery.SourceFileLoader(
    "agent_usage_devin", os.path.join(sys.argv[1], "bin/omarchy-agent-usage-devin"))
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)

conn = sqlite3.connect(os.path.join(os.environ["DEVIN_DATA_DIR"], "sessions.db"))
conn.row_factory = sqlite3.Row

state = {"day": "2000-01-01", "scans": 0}
mod.today_string = lambda: state["day"]

real_scan = mod.run_scan
def crossing_scan(c):
    stats = real_scan(c)
    state["scans"] += 1
    state["day"] = "2000-01-02"  # midnight passes while the scan runs
    return stats
mod.run_scan = crossing_scan

mod._cached_scan(conn, 0)
cache_file, _ = mod.cache_paths()
written = json.loads(cache_file.read_text())
assert written["scanDate"] == "2000-01-01", written["scanDate"]

# On the new day the stale-dated entry must miss and trigger a fresh scan
mod._cached_scan(conn, 9999)
assert state["scans"] == 2, state["scans"]
PY
then
  fail "Devin collector rejects a scan cache written across midnight"
fi
pass "Devin collector rejects a scan cache written across midnight"

# Quota / limits from user-status cache
# Build a minimal protobuf PlanStatus: field 1 (PlanInfo) with field 2 (plan name "Pro"),
# field 14 (daily_remaining_pct=69), field 15 (weekly_remaining_pct=53),
# field 17 (daily_reset_unix), field 18 (weekly_reset_unix)
python3 - "$TEST_HOME/.cache/devin/cli" "$now" <<'PY'
import base64, json, os, struct, sys

cache_dir, now = sys.argv[1], int(sys.argv[2])
os.makedirs(cache_dir, exist_ok=True)

def varint(val):
    out = b""
    while True:
        byte = val & 0x7F
        val >>= 7
        if val:
            out += bytes([byte | 0x80])
        else:
            out += bytes([byte])
            break
    return out

def field(fn, data):
    if isinstance(data, int):
        return varint((fn << 3) | 0) + varint(data)
    return varint((fn << 3) | 2) + varint(len(data)) + data

# PlanInfo: field 2 = "Pro"
plan_info = field(2, b"Pro")
# PlanStatus: field 1 = PlanInfo, field 14 = 69 (remaining), field 15 = 53 (remaining),
#   field 17 = now+3600, field 18 = now+86400*4
plan_status = field(1, plan_info) + field(14, 69) + field(15, 53) + field(17, now + 3600) + field(18, now + 86400 * 4)
# Top-level: field 13 = PlanStatus
payload = field(13, plan_status)

cache = {
    "version": 1,
    "identity_digest": "test123",
    "fetched_at_secs": now,
    "payload": base64.b64encode(payload).decode("ascii"),
}
with open(os.path.join(cache_dir, "user_status.test123.bin"), "w") as f:
    json.dump(cache, f)
PY

result=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin" --force)
[[ $(jq -r '.tierLabel' <<<"$result") == "Pro" ]] ||
  fail "Devin collector reads plan name from user-status cache" "$result"
[[ $(jq -r '.limits[0].label' <<<"$result") == "Daily" ]] ||
  fail "Devin collector reports daily limit label" "$result"
[[ $(jq -r '.limits[0].percent' <<<"$result") == "0.31" ]] ||
  fail "Devin collector reports daily limit percent (31% used = 69% remaining)" "$result"
[[ $(jq -r '.limits[1].label' <<<"$result") == "Weekly" ]] ||
  fail "Devin collector reports weekly limit label" "$result"
[[ $(jq -r '.limits[1].percent' <<<"$result") == "0.47" ]] ||
  fail "Devin collector reports weekly limit percent (47% used = 53% remaining)" "$result"
[[ $(jq -r '.limitsStale' <<<"$result") == "false" ]] ||
  fail "Devin collector marks a just-fetched status cache as current" "$result"
[[ $(jq -r '.limitsFetchedAt' <<<"$result") == "$((now * 1000))" ]] ||
  fail "Devin collector reports when the status cache was fetched" "$result"
pass "Devin collector parses quota from user-status cache"

# Quota without a session database: the status cache alone means the CLI has
# run, so the record is ready with limits rather than "not installed"
rm "$DEVIN_DATA_DIR/sessions.db"
result=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin" --force)
[[ $(jq -r '.ready' <<<"$result") == "true" ]] ||
  fail "Devin collector stays ready on quota without a session database" "$result"
[[ $(jq -r '.limits | length' <<<"$result") == "2" ]] ||
  fail "Devin collector keeps limits without a session database" "$result"
[[ $(jq -r '.usageStatusText' <<<"$result") == "" ]] ||
  fail "Devin collector drops the install hint when quota proves the CLI ran" "$result"
pass "Devin collector reports quota without a session database"

# Status caches fetched under a previous sign-in are dropped: once
# credentials.toml is newer than every fetch, no quota is reported rather than
# the signed-out account's
creds="$TEST_HOME/.local/share/devin/credentials.toml"
echo 'api_server_url = "https://api.devin.ai"' >"$creds"
touch -d "@$((now + 7200))" "$creds"
result=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin" --force)
[[ $(jq -r '.tierLabel' <<<"$result") == "" ]] ||
  fail "Devin collector drops quota fetched before the last sign-in" "$result"
[[ $(jq -c '.limits' <<<"$result") == "[]" ]] ||
  fail "Devin collector drops limits fetched before the last sign-in" "$result"
pass "Devin collector drops status caches from before the last sign-in"

# A credentials file older than the caches leaves the freshest fetch winning
touch -d "@$((now - 7200))" "$creds"
result=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin" --force)
[[ $(jq -r '.tierLabel' <<<"$result") == "Pro" ]] ||
  fail "Devin collector serves quota fetched under the current credentials" "$result"
pass "Devin collector serves quota fetched under the current credentials"

# A status cache older than the freshness window keeps its limits but is
# flagged stale, with its fetch time reported so the panel can warn
python3 - "$TEST_HOME/.cache/devin/cli/user_status.test123.bin" "$now" <<'PY'
import json, sys
path = sys.argv[1]
with open(path) as f:
    cache = json.load(f)
cache["fetched_at_secs"] = int(sys.argv[2]) - 3600
with open(path, "w") as f:
    json.dump(cache, f)
PY

result=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin" --force)
[[ $(jq -r '.limitsStale' <<<"$result") == "true" ]] ||
  fail "Devin collector flags an old status cache as stale" "$result"
[[ $(jq -r '.limitsFetchedAt' <<<"$result") == "$(( (now - 3600) * 1000 ))" ]] ||
  fail "Devin collector reports the stale cache's fetch time" "$result"
[[ $(jq -r '.limits | length' <<<"$result") == "2" ]] ||
  fail "Devin collector keeps limits from a stale cache" "$result"
pass "Devin collector flags old quota as stale with its fetch time"

# A damaged session database must not hide working quota: the scan fails, but
# the limits already read from the user-status cache still render, with the
# database error reported alongside
rm -f "$TEST_HOME/.cache/omarchy/agent-usage/devin-scan-"*
echo "not a database" > "$DEVIN_DATA_DIR/sessions.db"
result=$(HOME="$TEST_HOME" DEVIN_DATA_DIR="$DEVIN_DATA_DIR" \
  "$ROOT/bin/omarchy-agent-usage-devin" --force)
[[ $(jq -r '.usageStatusText' <<<"$result") == "Devin usage unavailable" ]] ||
  fail "Devin collector reports an unreadable session database" "$result"
[[ $(jq -r '.ready' <<<"$result") == "true" ]] ||
  fail "Devin collector stays ready on quota with an unreadable database" "$result"
[[ $(jq -r '.limits | length' <<<"$result") == "2" ]] ||
  fail "Devin collector keeps quota when the session database is unreadable" "$result"
pass "Devin collector keeps quota when the session database is unreadable"
