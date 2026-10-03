#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_STATE_HOME="$test_tmp/state"
export XDG_CACHE_HOME="$test_tmp/cache"

collector="$ROOT/bin/omarchy-agent-usage-freebuff"
projects="$HOME/.config/manicode/projects/testproj/chats"

# Freebuff stores each chat as a directory named for its UTC start time,
# holding a chat-messages.json array. Message ids carry the epoch
# milliseconds of their creation; user messages are plain strings and AI
# replies keep text in typed blocks.
make_chat() {
  local dir="$1"
  mkdir -p "$dir"
  cat >"$dir/chat-messages.json"
}

today=$(python3 -c 'import datetime as dt; print(dt.datetime.now().strftime("%Y-%m-%d"))')
yesterday=$(python3 -c 'import datetime as dt; print((dt.datetime.now() - dt.timedelta(days=1)).strftime("%Y-%m-%d"))')
now_ms=$(python3 -c 'import time; print(int(time.time() * 1000))')
yesterday_ms=$(python3 -c 'import time; print(int((time.time() - 86400) * 1000))')

# One chat from yesterday, one from today: two prompts and two replies total.
make_chat "$projects/2026-09-30T10-00-00.000Z" <<EOF
[
  {"id": "user-$yesterday_ms", "variant": "user", "timestamp": "10:00 AM", "content": "fix the login bug"},
  {"id": "ai-$((yesterday_ms + 2000))-abc", "variant": "ai", "timestamp": "10:00 AM", "content": "", "blocks": [{"type": "text", "content": "On it. Reading the auth module now."}]},
  {"id": "user-$((yesterday_ms + 4000))", "variant": "user", "timestamp": "10:01 AM", "content": "thanks, ship it"}
]
EOF
make_chat "$projects/2026-10-01T15-30-00.000Z" <<EOF
[
  {"id": "user-$now_ms", "variant": "user", "timestamp": "03:30 PM", "content": "add a usage collector"},
  {"id": "ai-$((now_ms + 2000))-def", "variant": "ai", "timestamp": "03:31 PM", "content": "", "blocks": [{"type": "text", "content": "Done — the collector prints the panel record."}]}
]
EOF

record=$("$collector" --force)

# The record is one line of JSON with the schema the panel reads.
[[ $(printf '%s' "$record" | jq -e '.schemaVersion' ) == 1 ]] || fail "schemaVersion"
pass "record carries schemaVersion 1"

[[ $(printf '%s' "$record" | jq -r '.id') == "freebuff" ]] || fail "id"
[[ $(printf '%s' "$record" | jq -r '.name') == "Freebuff" ]] || fail "name"
pass "record identifies as freebuff / Freebuff"

[[ $(printf '%s' "$record" | jq '.totalPrompts') == 3 ]] || fail "totalPrompts"
[[ $(printf '%s' "$record" | jq '.totalSessions') == 2 ]] || fail "totalSessions"
[[ $(printf '%s' "$record" | jq '.activeDays') == 2 ]] || fail "activeDays"
pass "prompts, sessions, and active days counted across chats"

[[ $(printf '%s' "$record" | jq '.todayPrompts') == 1 ]] || fail "todayPrompts"
[[ $(printf '%s' "$record" | jq '.todaySessions') == 1 ]] || fail "todaySessions"
[[ $(printf '%s' "$record" | jq '.todayTotalTokens') -gt 0 ]] || fail "todayTotalTokens"
pass "today's numbers cover only today's chat"

# Tokens are estimated from message text (~4 chars/token) in one bucket.
[[ $(printf '%s' "$record" | jq '.modelUsage.freebuff.inputTokens') -gt 0 ]] || fail "inputTokens"
[[ $(printf '%s' "$record" | jq '.modelUsage.freebuff.outputTokens') -gt 0 ]] || fail "outputTokens"
[[ $(printf '%s' "$record" | jq '.modelUsage.freebuff.cacheReadInputTokens') == 0 ]] || fail "cacheRead"
pass "token estimates land in one freebuff model bucket"

[[ $(printf '%s' "$record" | jq '[.recentDays[] | select(.messageCount > 0)] | length') == 2 ]] || fail "recentDays"
pass "weekly chart has two non-zero days"

# Unsigned in: no credentials file, so the record says how to fix it.
[[ $(printf '%s' "$record" | jq '.ready') == "false" ]] || fail "ready"
[[ $(printf '%s' "$record" | jq -r '.authHelpText') == "Start Freebuff, or run \`freebuff login\`, to sign in." ]] || fail "authHelpText"
pass "unsigned-in record points at sign-in"

mkdir -p "$HOME/.config/manicode"
printf '{}' >"$HOME/.config/manicode/credentials.json"
record=$("$collector")
[[ $(printf '%s' "$record" | jq '.ready') == "true" ]] || fail "ready signed-in"
[[ $(printf '%s' "$record" | jq -r '.tierLabel') == "Free" ]] || fail "tierLabel"
[[ $(printf '%s' "$record" | jq -r '.usageStatusText') == "" ]] || fail "usageStatusText"
pass "signed-in record reports the Free tier"

# A chat caught mid-write (invalid JSON) must not take the scan down: its
# prompts are still counted, from the escaped user-variant fallback.
mkdir -p "$projects/2026-10-01T16-00-00.000Z"
printf '[{"id": "user-%s", "variant": "user", "content": "half written' "$now_ms" \
  >"$projects/2026-10-01T16-00-00.000Z/chat-messages.json"
# --force: the collector dedups concurrent runs through a recent-scan cache,
# so a normal rerun inside the test would legitimately reuse the scan above.
record=$("$collector" --force)
[[ $(printf '%s' "$record" | jq '.totalPrompts') == 4 ]] || fail "midwrite prompts"
[[ $(printf '%s' "$record" | jq '.totalSessions') == 3 ]] || fail "midwrite sessions"
pass "mid-write chat still counts its prompts"

# The update wrapper writes the record where the panel reads it. It scans for
# collectors under OMARCHY_PATH, which the running shell points at the
# installed tree, so the test points it at this checkout the same way.
export PATH="$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
"$ROOT/bin/omarchy-agent-usage-update" freebuff
[[ -f "$XDG_STATE_HOME/omarchy/agents/usage/freebuff.json" ]] || fail "wrapper record"
jq -e '.id == "freebuff"' "$XDG_STATE_HOME/omarchy/agents/usage/freebuff.json" >/dev/null || fail "wrapper json"
pass "usage-update writes the panel's freebuff.json"

# And the stock agents still collect through the same wrapper.
"$ROOT/bin/omarchy-agent-usage-update" codex
[[ -f "$XDG_STATE_HOME/omarchy/agents/usage/codex.json" ]] || fail "codex via wrapper"
pass "usage-update still serves the stock collectors"
