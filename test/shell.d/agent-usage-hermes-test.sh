#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.hermes"
HOME="$TEST_HOME" python3 - <<'PY'
import os
import sqlite3
import time
from pathlib import Path

path = Path(os.environ["HOME"]) / ".hermes" / "state.db"
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
conn.executemany(
    "INSERT INTO session_model_usage VALUES (?, ?, ?, ?, ?, ?)",
    [
        ("session-1", "gpt-6-astra", 10, 20, 30, 40),
        ("session-1", "gpt-6-sol", 11, 21, 31, 41),
    ],
)
conn.commit()
conn.close()
PY

record=$(HOME="$TEST_HOME" "$ROOT/bin/omarchy-agent-usage-hermes") ||
  fail "Hermes collector exits successfully"
pass "Hermes collector exits successfully"

printf '%s\n' "$record" | jq -e '.modelUsage["gpt-6-astra"].inputTokens == 10 and .modelUsage["gpt-6-sol"].inputTokens == 11' >/dev/null ||
  fail "Hermes collector preserves usage for each model"
pass "Hermes collector preserves usage for each model"

printf '%s\n' "$record" | jq -e '.todayTokensByModel["gpt-6-sol"] == 104 and .todayTotalTokens == 204' >/dev/null ||
  fail "Hermes collector reports today's per-model totals"
pass "Hermes collector reports today's per-model totals"

printf '%s\n' "$record" | jq -e '.totalPrompts == 1 and .todayPrompts == 1 and .totalSessions == 1 and .todaySessions == 1' >/dev/null ||
  fail "Hermes collector reports prompt and session totals"
pass "Hermes collector reports prompt and session totals"

HOME="$TEST_HOME" XDG_STATE_HOME="" "$ROOT/bin/omarchy-agent-usage-hermes" --write ||
  fail "Hermes collector writes an atomic usage record"
pass "Hermes collector writes an atomic usage record"

[[ $(jq -r '.modelUsage | keys | join(",")' "$TEST_HOME/.local/state/omarchy/agents/usage/hermes.json") == "gpt-6-astra,gpt-6-sol" ]] ||
  fail "written Hermes record retains all model names"
pass "written Hermes record retains all model names"
