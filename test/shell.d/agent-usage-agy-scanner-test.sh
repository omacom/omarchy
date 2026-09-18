#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.gemini/antigravity/conversations"

# Create a test sqlite database structure
python3 -c "
import sqlite3
conn = sqlite3.connect('$TEST_HOME/.gemini/antigravity/conversations/test.db')
conn.execute('CREATE TABLE steps (idx integer primary key, metadata blob)')
conn.execute('CREATE TABLE gen_metadata (idx integer primary key, data blob)')
conn.close()
"

result=$(HOME="$TEST_HOME" "$ROOT/bin/omarchy-agent-usage-agy")

[[ $(jq -r '.id' <<<"$result") == "agy" ]] ||
  fail "Antigravity collector identifies itself as agy" "$result"
pass "Antigravity collector identifies itself as agy"

[[ $(jq -r '.name' <<<"$result") == "Antigravity" ]] ||
  fail "Antigravity collector names itself Antigravity" "$result"
pass "Antigravity collector names itself Antigravity"

[[ $(jq -r '.ready' <<<"$result") == "true" ]] ||
  fail "Antigravity collector reports ready" "$result"
pass "Antigravity collector reports ready"

[[ $(jq -r '.tierLabel' <<<"$result") == "Pro" ]] ||
  fail "Antigravity collector reports Pro tier" "$result"
pass "Antigravity collector reports Pro tier"

[[ $(jq -r '.limits | length' <<<"$result") == "2" ]] ||
  fail "Antigravity collector reports session and weekly limits" "$result"
pass "Antigravity collector reports session and weekly limits"

[[ $(jq -r '.limits[0].label' <<<"$result") == "Session (5-hour)" ]] ||
  fail "Antigravity collector reports Session (5-hour) limit" "$result"
pass "Antigravity collector reports Session (5-hour) limit"

[[ $(jq -r '.limits[1].label' <<<"$result") == "Weekly (7-day)" ]] ||
  fail "Antigravity collector reports Weekly (7-day) limit" "$result"
pass "Antigravity collector reports Weekly (7-day) limit"
