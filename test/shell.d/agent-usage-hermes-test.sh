#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT
# The collector caches its scan; keep it out of the real cache.
export XDG_CACHE_HOME="$TEST_HOME/.cache"

# A Hermes state.db at $1 with one session today, its prompt, and usage for
# the models after it, given as name:base where every count is base plus a
# per-field offset.
make_state() {
  mkdir -p "$(dirname "$1")"
  python3 - "$@" <<'PY'
import sqlite3
import sys
import time

path, models = sys.argv[1], sys.argv[2:]
conn = sqlite3.connect(path)
conn.executescript(
  """
  CREATE TABLE sessions (
    id TEXT PRIMARY KEY,
    started_at REAL NOT NULL
  );
  CREATE TABLE messages (
    id INTEGER PRIMARY KEY,
    session_id TEXT NOT NULL,
    role TEXT NOT NULL,
    timestamp REAL NOT NULL
  );
  CREATE TABLE session_model_usage (
    session_id TEXT NOT NULL,
    model TEXT NOT NULL,
    input_tokens INTEGER NOT NULL DEFAULT 0,
    output_tokens INTEGER NOT NULL DEFAULT 0,
    cache_read_tokens INTEGER NOT NULL DEFAULT 0,
    cache_write_tokens INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (session_id, model)
  );
  """
)
now = time.time()
conn.execute("INSERT INTO sessions VALUES (?, ?)", ("session-1", now))
conn.executemany(
  "INSERT INTO messages VALUES (?, ?, ?, ?)",
  [(1, "session-1", "user", now), (2, "session-1", "assistant", now)],
)
for spec in models:
  name, base = spec.split(":")
  base = int(base)
  conn.execute("INSERT INTO session_model_usage VALUES (?, ?, ?, ?, ?, ?)", ("session-1", name, base, base + 10, base + 20, base + 30))
conn.commit()
conn.close()
PY
}

make_state "$TEST_HOME/.hermes/state.db" gpt-6-astra:10 gpt-6-sol:11

record=$(HOME="$TEST_HOME" HERMES_HOME="" "$ROOT/bin/omarchy-agent-usage-hermes" --force) ||
  fail "Hermes collector exits successfully"
pass "Hermes collector exits successfully"

printf '%s\n' "$record" | jq -e '.modelUsage["gpt-6-astra"].inputTokens == 10 and .modelUsage["gpt-6-sol"].inputTokens == 11' >/dev/null ||
  fail "Hermes collector preserves usage for each model"
pass "Hermes collector preserves usage for each model"

printf '%s\n' "$record" | jq -e '.todayTokensByModel["gpt-6-sol"] == 104 and .todayTotalTokens == 204' >/dev/null ||
  fail "Hermes collector reports today's per-model totals"
pass "Hermes collector reports today's per-model totals"

printf '%s\n' "$record" | jq -e '.recentDays | length == 7 and .[-1].messageCount == 204' >/dev/null ||
  fail "Hermes collector reports the last week's tokens by day"
pass "Hermes collector reports the last week's tokens by day"

printf '%s\n' "$record" | jq -e '.totalPrompts == 1 and .todayPrompts == 1 and .totalSessions == 1 and .todaySessions == 1' >/dev/null ||
  fail "Hermes collector reports prompt and session totals"
pass "Hermes collector reports prompt and session totals"

# Named profiles live under ~/.hermes/profiles even when HERMES_HOME moves the
# default home elsewhere.
make_state "$TEST_HOME/elsewhere/state.db" gpt-6-astra:100
make_state "$TEST_HOME/.hermes/profiles/work/state.db" gpt-6-sol:1000
record=$(HOME="$TEST_HOME" HERMES_HOME="$TEST_HOME/elsewhere" "$ROOT/bin/omarchy-agent-usage-hermes")
printf '%s\n' "$record" | jq -e '.modelUsage["gpt-6-astra"].inputTokens == 100 and .modelUsage["gpt-6-sol"].inputTokens == 1000 and .totalSessions == 2 and .totalPrompts == 2' >/dev/null ||
  fail "Hermes collector reads HERMES_HOME and every named profile"
pass "Hermes collector reads HERMES_HOME and every named profile"

empty_home=$(mktemp -d)
record=$(HOME="$empty_home" HERMES_HOME="" PATH=/usr/bin:/bin "$ROOT/bin/omarchy-agent-usage-hermes")
rm -rf "$empty_home"
printf '%s\n' "$record" | jq -e '.limits == [] and .tierLabel == "" and .totalSessions == 0 and .activeDays == 0 and .modelUsage == {}' >/dev/null ||
  fail "Hermes collector prints a record the panel skips without Hermes"
pass "Hermes collector prints a record the panel skips without Hermes"

# No state.db is an unused machine, not trouble: with sync on, another
# machine's Hermes must not show red here.
[[ $(jq -c '{ready, usageStatusText, authHelpText, limitsStale, limitsFetchedAt, hasLocalStats}' <<<"$record") == '{"ready":false,"usageStatusText":"","authHelpText":"","limitsStale":false,"limitsFetchedAt":0,"hasLocalStats":false}' ]] ||
  fail "Hermes collector reports no trouble without Hermes state" "$record"
pass "Hermes collector reports no trouble without Hermes state"
# The last seven local days ending today, none with messages: an unused
# record still carries the full week, zeroed.
empty_week=$(for offset in 6 5 4 3 2 1 0; do date -d "$(date +%F) 12:00 $offset days ago" +%F; done | jq -Rsc 'split("\n")[:-1] | map({date: ., messageCount: 0})')
[[ $(jq -c '[.todayPrompts, .todaySessions, .todayTotalTokens, .todayTokensByModel, .recentDays, .totalPrompts, .totalSessions, .activeDays, .activeDates, .modelUsage]' <<<"$record") == "[0,0,0,{},$empty_week,0,0,0,[],{}]" ]] ||
  fail "Hermes collector prints the full empty stats block without Hermes state" "$record"
pass "Hermes collector prints the full empty stats block without Hermes state"

# Hermes on the machine is ready whether or not the hermes command is on PATH.
record=$(HOME="$TEST_HOME" HERMES_HOME="" PATH=/usr/bin:/bin "$ROOT/bin/omarchy-agent-usage-hermes" --force)
[[ $(jq -c '{ready, usageStatusText, authHelpText}' <<<"$record") == '{"ready":true,"usageStatusText":"","authHelpText":""}' ]] ||
  fail "Hermes collector is ready once Hermes state exists" "$record"
pass "Hermes collector is ready once Hermes state exists"

# An unreadable state.db says Hermes is unavailable, with the detail in the
# help text, and the readable profiles still count.
bad_home=$(mktemp -d)
make_state "$bad_home/.hermes/profiles/work/state.db" gpt-6-sol:1000
mkdir -p "$bad_home/.hermes"
printf 'not a database at all, just text that is long enough to read' >"$bad_home/.hermes/state.db"
record=$(HOME="$bad_home" HERMES_HOME="" XDG_CACHE_HOME="$bad_home/.cache" "$ROOT/bin/omarchy-agent-usage-hermes" --force)
[[ $(jq -c '{ready, usageStatusText, hasLocalStats, totalSessions}' <<<"$record") == '{"ready":true,"usageStatusText":"Hermes unavailable","hasLocalStats":true,"totalSessions":1}' ]] ||
  fail "Hermes collector reports an unreadable state.db" "$record"
[[ $(jq -r .authHelpText <<<"$record") == "Couldn't read Hermes' state.db ($bad_home/.hermes/state.db: "* ]] ||
  fail "Hermes collector names the unreadable state.db" "$record"
pass "Hermes collector reports an unreadable state.db"
[[ -z $(find "$bad_home/.cache" -name 'hermes-scan-*.json' 2>/dev/null) ]] ||
  fail "Hermes collector doesn't cache a scan that missed a database"
pass "Hermes collector doesn't cache a scan that missed a database"
rm -rf "$bad_home"

# The scan is reused for SCAN_REUSE_SECONDS, for LIMITS_ONLY_REUSE_SECONDS on
# --limits-only, and never on --force.
cache_home=$(mktemp -d)
make_state "$cache_home/.hermes/state.db" gpt-6-astra:10
run_cached() {
  HOME="$cache_home" HERMES_HOME="" XDG_CACHE_HOME="$cache_home/.cache" "$ROOT/bin/omarchy-agent-usage-hermes" "$@" | jq -r .totalSessions
}
add_session() {
  python3 - "$cache_home/.hermes/state.db" "$1" <<'PY'
import sqlite3, sys, time
conn = sqlite3.connect(sys.argv[1])
conn.execute("INSERT INTO sessions VALUES (?, ?)", (sys.argv[2], time.time()))
conn.commit()
PY
}
age_cache() {
  local file
  for file in "$cache_home"/.cache/omarchy/agent-usage/hermes-scan-*.json; do
    jq -c --argjson age "$1" '.scannedAtMs -= $age * 1000' "$file" >"$file.new" && mv "$file.new" "$file"
  done
}
[[ $(run_cached) == "1" ]] || fail "Hermes collector scans on first run"
add_session session-2
[[ $(run_cached) == "1" ]] || fail "Hermes collector reuses a scan from seconds ago"
pass "Hermes collector reuses a scan from seconds ago"
[[ $(run_cached --force) == "2" ]] || fail "Hermes collector rescans on --force"
pass "Hermes collector rescans on --force"
add_session session-3
age_cache 120
[[ $(run_cached --limits-only) == "2" ]] || fail "Hermes collector reuses a recent scan on --limits-only"
pass "Hermes collector reuses a recent scan on --limits-only"
[[ $(run_cached) == "3" ]] || fail "Hermes collector rescans once the reuse window passes"
pass "Hermes collector rescans once the reuse window passes"
add_session session-4
age_cache -3600
[[ $(run_cached --limits-only) == "4" ]] || fail "Hermes collector never reuses a future-dated scan"
pass "Hermes collector never reuses a future-dated scan"

# The scan is rebuilt under its lock: a concurrent run waits for it.
lock_file=$(find "$cache_home/.cache/omarchy/agent-usage" -name 'hermes-scan-*.lock' | head -n 1)
[[ -n $lock_file ]] || fail "Hermes collector keeps a scan lock"
waited=$(python3 - "$lock_file" "$ROOT/bin/omarchy-agent-usage-hermes" "$cache_home" <<'PY'
import fcntl, os, subprocess, sys, time
lock = open(sys.argv[1], "w")
fcntl.flock(lock, fcntl.LOCK_EX)
env = dict(os.environ, HOME=sys.argv[3], HERMES_HOME="", XDG_CACHE_HOME=sys.argv[3] + "/.cache")
started = time.time()
proc = subprocess.Popen([sys.argv[2], "--force"], env=env, stdout=subprocess.DEVNULL)
time.sleep(1.2)
still_running = proc.poll() is None
fcntl.flock(lock, fcntl.LOCK_UN)
proc.wait()
print("true" if still_running else "false")
PY
)
[[ $waited == "true" ]] || fail "Hermes collector rebuilds the scan under its lock"
pass "Hermes collector rebuilds the scan under its lock"
rm -rf "$cache_home"

# Every active date travels, not only the latest 400, and broken token counts
# or start times skip their row instead of inflating the record.
dates_home=$(mktemp -d)
make_state "$dates_home/.hermes/state.db"
python3 - "$dates_home/.hermes/state.db" <<'PY'
import datetime as dt, sqlite3, sys
conn = sqlite3.connect(sys.argv[1])
# Local noon on each earlier day, so a daylight-saving change can't put two
# sessions on one date the way fixed 86400-second steps can near midnight.
today = dt.date.today()
noons = [dt.datetime.combine(today - dt.timedelta(days=n + 1), dt.time(12)).timestamp() for n in range(450)]
conn.executemany("INSERT INTO sessions VALUES (?, ?)", [(f"old-{n}", noons[n]) for n in range(450)])
conn.execute("INSERT INTO sessions VALUES ('broken', 'not a time')")
conn.executemany("INSERT INTO session_model_usage VALUES (?, ?, ?, ?, ?, ?)", [
  ("old-1", "negative", -500, 0, 0, 0),
  ("old-2", "huge", 10**15, 0, 0, 0),
  ("broken", "untimed", 5, 0, 0, 0),
])
conn.commit()
PY
record=$(HOME="$dates_home" HERMES_HOME="" XDG_CACHE_HOME="$dates_home/.cache" "$ROOT/bin/omarchy-agent-usage-hermes" --force)
rm -rf "$dates_home"
[[ $(jq -c '[.activeDays, (.activeDates | length)]' <<<"$record") == '[451,451]' ]] ||
  fail "Hermes collector emits every active date" "$record"
pass "Hermes collector emits every active date"
[[ $(jq -c '.modelUsage | keys' <<<"$record") == '["untimed"]' ]] ||
  fail "Hermes collector skips broken token counts" "$record"
pass "Hermes collector skips broken token counts"
