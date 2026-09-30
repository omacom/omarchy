#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command jq

FEED="$ROOT/shell/plugins/agent-comms/feed.py"
POST="$ROOT/shell/plugins/agent-comms/post.sh"
export PYTHONDONTWRITEBYTECODE=1

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

run_feed() {
  local home="$1"
  local state="$2"
  shift 2
  HOME="$home" XDG_STATE_HOME="$state" python3 "$FEED" "$@"
}

assert_jq() {
  local payload="$1"
  local filter="$2"
  local description="$3"
  if ! jq -e "$filter" <<<"$payload" >/dev/null; then
    fail "$description" "$payload"
  fi
  pass "$description"
}

seed() {
  local home="$1"
  local state="$2"
  mkdir -p "$home/.codex" "$home/.claude" \
    "$state/omarchy/notifications/history" \
    "$state/omarchy/agent-comms"
  printf '%s\n' '{"text":"SESSION_SHOULD_NOT_APPEAR"}' > "$home/.codex/history.jsonl"
  printf '%s\n' '{"text":"CLAUDE_SESSION_SHOULD_NOT_APPEAR"}' > "$home/.claude/history.jsonl"

  cat > "$state/omarchy/notifications/history/0001-chatgpt.json" <<'JSON'
{"app":"ChatGPT","summary":"guide","body":"package is ready","timestamp":1710000000000}
JSON
  cat > "$state/omarchy/notifications/history/0002-long.json" <<'JSON'
{"app":"ChatGPT","summary":"this summary is deliberately longer than thirty two","body":"long name dropped","timestamp":1710000000500}
JSON
  cat > "$state/omarchy/notifications/history/0003-grok.json" <<'JSON'
{"app":"Grok","summary":"Grok","body":"standing by","timestamp":1710000001000}
JSON
  cat > "$state/omarchy/notifications/history/0004-muse.json" <<'JSON'
{"app":"Muse","summary":"Muse","body":"sketch updated","timestamp":1710000002000}
JSON
  cat > "$state/omarchy/notifications/history/0005-files.json" <<'JSON'
{"app":"Files","summary":"Files","body":"copy finished","timestamp":1710000099000}
JSON

  cat > "$state/omarchy/agent-comms/inbox.jsonl" <<'JSON'
{"agent":"runner","role":"out","text":"build finished","ts":1710000004}
{"agent":"runner","role":"in","text":"status?","ts":1710000005}
not json
{"agent":"runner","role":"out","text":"build finished","ts":1710000004}
{"nope":true}
JSON
  printf '%s\n' '{"agent":"helper","text":"  queued   now  ","timestamp":1710000006}' \
    > "$state/omarchy/agent-comms/extra.jsonl"
  printf '%s\n' '{"agent":"clock","role":"out","text":"iso works","ts":"2024-03-09T12:00:00+00:00"}' \
    >> "$state/omarchy/agent-comms/inbox.jsonl"
}

home="$tmp/home"
state="$tmp/state"
seed "$home" "$state"
payload=$(run_feed "$home" "$state" --once)

assert_jq "$payload" '(.items | length) == 8' "feed keeps the eight comms and drops nothing newer"
assert_jq "$payload" 'any(.items[]; .agent == "guide" and .text == "package is ready" and .role == "out")' "ChatGPT summary is the speaker"
assert_jq "$payload" 'any(.items[]; .agent == "ChatGPT" and .text == "long name dropped")' "a long summary falls back to the app name"
assert_jq "$payload" 'any(.items[]; .agent == "Grok" and .text == "standing by")' "Grok notifications are included"
assert_jq "$payload" 'any(.items[]; .agent == "Muse" and .text == "sketch updated")' "Muse notifications are included"
assert_jq "$payload" 'any(.items[]; .agent == "runner" and .role == "in" and .text == "status?")' "inbox lines spoken to an agent keep role in"
assert_jq "$payload" 'any(.items[]; .agent == "helper" and .text == "queued now")' "sibling inbox files are included and whitespace is collapsed"
assert_jq "$payload" 'any(.items[]; .agent == "clock" and .text == "iso works" and .ts > 1000000000)' "ISO timestamps are accepted"
if jq -e 'tostring | contains("copy finished") or contains("SESSION_SHOULD_NOT_APPEAR") or contains("CLAUDE_SESSION_SHOULD_NOT_APPEAR")' <<<"$payload" >/dev/null; then
  fail "unrelated notifications and session transcripts stay out of the feed" "$payload"
fi
pass "unrelated notifications and session transcripts stay out of the feed"

inbox_only=$(run_feed "$home" "$state" --once --apps "")
assert_jq "$inbox_only" 'any(.items[]; .text == "build finished")' "an empty app list still reads the inbox"
if jq -e 'tostring | contains("package is ready") or contains("standing by") or contains("sketch updated")' <<<"$inbox_only" >/dev/null; then
  fail "an empty app list ignores notifications" "$inbox_only"
fi
pass "an empty app list ignores notifications"

muse_only=$(run_feed "$home" "$state" --once --apps "muse")
assert_jq "$muse_only" 'any(.items[]; .agent == "Muse" and .text == "sketch updated")' "an app list can select Muse"
if jq -e 'tostring | contains("package is ready") or contains("standing by")' <<<"$muse_only" >/dev/null; then
  fail "an app list excludes notifications from other apps" "$muse_only"
fi
pass "an app list excludes notifications from other apps"

keep_home="$tmp/keep-home"
keep_state="$tmp/keep-state"
mkdir -p "$keep_home" "$keep_state/omarchy/agent-comms"
inbox="$keep_state/omarchy/agent-comms/inbox.jsonl"
for n in $(seq 1 10); do
  printf '{"agent":"runner","role":"out","text":"m%02d","ts":%s}\n' "$n" "$n" >> "$inbox"
done
kept=$(run_feed "$keep_home" "$keep_state" --once)
assert_jq "$kept" '(.items | length) == 8 and .items[0].text == "m03" and .items[7].text == "m10"' "the feed keeps the eight newest inbox lines"

post_home="$tmp/post-home"
post_state="$tmp/post-state"
mkdir -p "$post_home"
HOME="$post_home" XDG_STATE_HOME="$post_state" "$POST" guide "posted line"
posted=$(run_feed "$post_home" "$post_state" --once)
assert_jq "$posted" 'any(.items[]; .agent == "guide" and .role == "out" and .text == "posted line")' "post.sh appends an inbox line"
HOME="$post_home" XDG_STATE_HOME="$post_state" "$POST" --in guide "are you there"
posted=$(run_feed "$post_home" "$post_state" --once)
assert_jq "$posted" 'any(.items[]; .agent == "guide" and .role == "in" and .text == "are you there")' "post.sh --in records a line said to the agent"

if find "$tmp" -name '*.pyc' -o -name '__pycache__' | grep -q .; then
  fail "feed.py does not write bytecode next to the test"
fi
pass "feed.py does not write bytecode during the test"
