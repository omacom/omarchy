#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command sqlite3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

empty=$(HOME="$TEST_HOME" HERMES_HOME="$TEST_HOME/.hermes" "$ROOT/bin/omarchy-agent-usage-hermes")
[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.hasPromptStats | tostring)' <<<"$empty") == "hermes:false:true" ]] ||
  fail "Hermes collector prints a valid record without a state db" "$empty"
pass "Hermes collector prints a valid record without a state db"

mkdir -p "$TEST_HOME/.hermes"
now=$(date +%s)

sqlite3 "$TEST_HOME/.hermes/state.db" <<SQL
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  source TEXT NOT NULL,
  parent_session_id TEXT,
  started_at REAL NOT NULL,
  last_activity_at REAL,
  message_count INTEGER DEFAULT 0,
  archived INTEGER DEFAULT 0
);
CREATE TABLE session_model_usage (
  session_id TEXT NOT NULL,
  model TEXT NOT NULL,
  billing_provider TEXT NOT NULL DEFAULT '',
  billing_base_url TEXT NOT NULL DEFAULT '',
  billing_mode TEXT NOT NULL DEFAULT '',
  task TEXT NOT NULL DEFAULT '',
  api_call_count INTEGER NOT NULL DEFAULT 0,
  input_tokens INTEGER NOT NULL DEFAULT 0,
  output_tokens INTEGER NOT NULL DEFAULT 0,
  cache_read_tokens INTEGER NOT NULL DEFAULT 0,
  cache_write_tokens INTEGER NOT NULL DEFAULT 0,
  reasoning_tokens INTEGER NOT NULL DEFAULT 0,
  estimated_cost_usd REAL NOT NULL DEFAULT 0,
  actual_cost_usd REAL NOT NULL DEFAULT 0,
  cost_status TEXT,
  cost_source TEXT,
  first_seen REAL,
  last_seen REAL,
  PRIMARY KEY (session_id, model, billing_provider, billing_base_url, billing_mode, task)
);
INSERT INTO sessions(id, source, parent_session_id, started_at, last_activity_at, message_count, archived)
VALUES
  ('root', 'cli', NULL, $now, $now, 4, 0),
  ('child', 'cli', 'root', $now, $now, 2, 0),
  ('old', 'cli', NULL, $now, $now, 9, 1),
  ('empty', 'cli', NULL, $now, $now, 0, 0);
INSERT INTO session_model_usage(
  session_id, model, api_call_count, input_tokens, output_tokens,
  cache_read_tokens, cache_write_tokens, reasoning_tokens, last_seen
) VALUES
  ('root', 'grok-4.6', 3, 100, 20, 40, 5, 7, $now),
  ('child', 'claude-fable-5-1', 2, 10, 4, 8, 1, 0, $now),
  ('old', 'gpt-6-astra', 99, 9000, 9000, 0, 0, 0, $now);
SQL

result=$(HOME="$TEST_HOME" HERMES_HOME="$TEST_HOME/.hermes" "$ROOT/bin/omarchy-agent-usage-hermes" --force)

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.totalPrompts | tostring) + ":" + (.totalSessions | tostring)' <<<"$result") == "hermes:true:5:1" ]] ||
  fail "Hermes collector counts root sessions and every live API call" "$result"
pass "Hermes collector counts root sessions and every live API call"

[[ $(jq -c '.modelUsage["grok-4.6"]' <<<"$result") == '{"cacheCreationInputTokens":5,"cacheReadInputTokens":40,"inputTokens":100,"outputTokens":27}' ]] ||
  fail "Hermes collector folds reasoning tokens into output" "$result"
pass "Hermes collector folds reasoning tokens into output"

[[ $(jq -r '.modelUsage["gpt-6-astra"] // "missing"' <<<"$result") == "missing" ]] ||
  fail "Hermes collector skips archived sessions" "$result"
pass "Hermes collector skips archived sessions"

[[ $(jq -r '.modelUsage["claude-fable-5-1"].inputTokens' <<<"$result") == "10" ]] ||
  fail "Hermes collector keeps child-session usage" "$result"
pass "Hermes collector keeps child-session usage"

(( $(jq -r '.history | length' <<<"$result") >= 1 )) ||
  fail "Hermes collector emits a history array" "$result"
pass "Hermes collector emits a history array"
