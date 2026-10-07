#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

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
