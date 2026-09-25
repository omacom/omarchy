#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

today="$(date +%Y-%m-%d)"
timestamp="${today}T12:00:00Z"

write_usage() {
  local dir="$1" session="$2"
  mkdir -p "$dir/sessions/project/$session"
  cat >"$dir/sessions/project/$session/usage.json"
}

result=$(HOME="$TEST_HOME" GROK_HOME="$TEST_HOME/.grok" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok" --force)

[[ $(jq -r '.id + "/" + (.ready|tostring) + "/" + (.todayTotalTokens|tostring)' <<<"$result") == "grok/false/0" ]] ||
  fail "Grok collector identifies itself with an empty record when there are no sessions" "$result"
[[ $(jq -r '.authHelpText' <<<"$result") == "Run \`grok\` and sign in to start recording usage." ]] ||
  fail "Grok collector asks for a sign-in when there is no auth and no usage" "$result"
pass "Grok collector identifies itself with an empty record when there are no sessions"

write_usage "$TEST_HOME/.grok" "session-1" <<EOF
{
  "sessionId": "session-1",
  "updatedAt": "$timestamp",
  "session": {
    "inputTokens": 180,
    "outputTokens": 30,
    "cachedReadTokens": 110,
    "cacheCreationTokens": 4,
    "primaryModelId": "grok-test"
  },
  "turns": [
    {
      "turnNumber": 1,
      "endedAt": "$timestamp",
      "inputTokens": 100,
      "outputTokens": 20,
      "cachedReadTokens": 60,
      "cacheCreationTokens": 4,
      "primaryModelId": "grok-test",
      "modelUsage": {
        "grok-test": {
          "inputTokens": 100,
          "outputTokens": 20,
          "cachedReadTokens": 60,
          "cacheCreationTokens": 4
        }
      }
    },
    {
      "turnNumber": 2,
      "endedAt": "$timestamp",
      "inputTokens": 80,
      "outputTokens": 10,
      "cachedReadTokens": 50,
      "cacheCreationTokens": 0,
      "primaryModelId": "grok-test",
      "modelUsage": {
        "grok-test": {
          "inputTokens": 80,
          "outputTokens": 10,
          "cachedReadTokens": 50,
          "cacheCreationTokens": 0
        }
      }
    }
  ]
}
EOF

result=$(HOME="$TEST_HOME" GROK_HOME="$TEST_HOME/.grok" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "214" ]] ||
  fail "Grok collector counts each turn once and does not add session totals" "$result"
pass "Grok collector counts each turn once and does not add session totals"

[[ $(jq -c '.modelUsage["grok-test"]' <<<"$result") == '{"cacheCreationInputTokens":4,"cacheReadInputTokens":110,"inputTokens":70,"outputTokens":30}' ]] ||
  fail "Grok collector keeps mutually exclusive token categories" "$result"
pass "Grok collector keeps mutually exclusive token categories"

[[ $(jq -r '(.todayPrompts|tostring) + "/" + (.todaySessions|tostring) + "/" + (.ready|tostring)' <<<"$result") == "2/1/true" ]] ||
  fail "Grok collector counts turns as prompts and unique session ids" "$result"
pass "Grok collector counts turns as prompts and unique session ids"

[[ $(jq -c '.limits' <<<"$result") == "[]" ]] ||
  fail "Grok collector identifies itself with an empty limits list" "$result"
pass "Grok collector identifies itself with an empty limits list"

# Session-level totals still count when Grok has not written a turns array yet.
SESSION_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$SESSION_HOME"' EXIT
write_usage "$SESSION_HOME/.grok" "session-only" <<EOF
{
  "sessionId": "session-only",
  "updatedAt": "$timestamp",
  "session": {
    "inputTokens": 50,
    "outputTokens": 5,
    "cachedReadTokens": 10,
    "cacheCreationTokens": 2,
    "primaryModelId": "grok-session"
  }
}
EOF

result=$(HOME="$SESSION_HOME" GROK_HOME="$SESSION_HOME/.grok" XDG_CACHE_HOME="$SESSION_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "57" ]] ||
  fail "Grok collector falls back to session totals without turns" "$result"
[[ $(jq -c '.modelUsage' <<<"$result") == '{"grok-session":{"cacheCreationInputTokens":2,"cacheReadInputTokens":10,"inputTokens":40,"outputTokens":5}}' ]] ||
  fail "Grok collector names the session's primary model" "$result"
pass "Grok collector falls back to session totals without turns"

# A turn billed on two models is still one prompt; tokens split across models.
MULTI_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$SESSION_HOME" "$MULTI_HOME"' EXIT
write_usage "$MULTI_HOME/.grok" "multi" <<EOF
{
  "sessionId": "multi",
  "updatedAt": "$timestamp",
  "turns": [
    {
      "endedAt": "$timestamp",
      "primaryModelId": "grok-a",
      "modelUsage": {
        "grok-a": {"inputTokens": 10, "outputTokens": 2, "cachedReadTokens": 0, "cacheCreationTokens": 0},
        "grok-b": {"inputTokens": 4, "outputTokens": 1, "cachedReadTokens": 0, "cacheCreationTokens": 0}
      }
    }
  ]
}
EOF

result=$(HOME="$MULTI_HOME" GROK_HOME="$MULTI_HOME/.grok" XDG_CACHE_HOME="$MULTI_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok" --force)

[[ $(jq -r '(.todayPrompts|tostring) + "/" + (.todayTotalTokens|tostring)' <<<"$result") == "1/17" ]] ||
  fail "Grok collector counts a multi-model turn as one prompt" "$result"
pass "Grok collector counts a multi-model turn as one prompt"

# A malformed usage.json must not abort the scan.
write_usage "$MULTI_HOME/.grok" "broken" <<EOF
{ this is not json
EOF

result=$(HOME="$MULTI_HOME" GROK_HOME="$MULTI_HOME/.grok" XDG_CACHE_HOME="$MULTI_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "17" ]] ||
  fail "Grok collector counts good sessions past a malformed usage.json" "$result"
pass "Grok collector counts good sessions past a malformed usage.json"

# GROK_HOME relocates the scan; ~/.grok is ignored when it is set.
OTHER_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$SESSION_HOME" "$MULTI_HOME" "$OTHER_HOME"' EXIT
write_usage "$OTHER_HOME/ignored" "ignored" <<EOF
{"sessionId":"ignored","updatedAt":"$timestamp","session":{"inputTokens":999,"outputTokens":999,"primaryModelId":"nope"}}
EOF
write_usage "$OTHER_HOME/custom" "kept" <<EOF
{"sessionId":"kept","updatedAt":"$timestamp","session":{"inputTokens":3,"outputTokens":1,"primaryModelId":"grok-home"}}
EOF

result=$(HOME="$OTHER_HOME/ignored" GROK_HOME="$OTHER_HOME/custom" XDG_CACHE_HOME="$OTHER_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "4" ]] ||
  fail "Grok collector honors GROK_HOME" "$result"
pass "Grok collector honors GROK_HOME"

# Signed-in with no sessions yet should not nag about auth.
mkdir -p "$OTHER_HOME/empty"
printf '{}\n' >"$OTHER_HOME/empty/auth.json"
result=$(HOME="$OTHER_HOME" GROK_HOME="$OTHER_HOME/empty" XDG_CACHE_HOME="$OTHER_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok" --force)

[[ $(jq -r '.authHelpText' <<<"$result") == "" ]] ||
  fail "Grok collector stays quiet when signed in with no usage yet" "$result"
pass "Grok collector stays quiet when signed in with no usage yet"

CACHE_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$SESSION_HOME" "$MULTI_HOME" "$OTHER_HOME" "$CACHE_HOME"' EXIT
write_usage "$CACHE_HOME/.grok" "cached" <<EOF
{"sessionId":"cached","updatedAt":"$timestamp","session":{"inputTokens":5,"outputTokens":0,"primaryModelId":"grok-cache"}}
EOF

result=$(HOME="$CACHE_HOME" GROK_HOME="$CACHE_HOME/.grok" XDG_CACHE_HOME="$CACHE_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "5" ]] ||
  fail "Grok collector writes a fresh local-stats cache on first scan" "$result"
cache_file=$(ls "$CACHE_HOME/.cache/omarchy/agent-usage/"/grok-scan-*.json 2>/dev/null | head -n 1)
[[ -n $cache_file && -s $cache_file ]] ||
  fail "Grok collector leaves a cache file behind" "$result"
[[ $(stat -c %a "$cache_file") == "644" ]] ||
  fail "Grok collector keeps cache files readable" "$result"
[[ $(jq -r '.schemaVersion' "$cache_file") == "1" && $(jq -r '.stats.todayTotalTokens' "$cache_file") == "5" ]] ||
  fail "Grok collector writes a versioned cache envelope" "$result"
pass "Grok collector writes a local-stats cache on first scan"

write_usage "$CACHE_HOME/.grok" "cached-2" <<EOF
{"sessionId":"cached-2","updatedAt":"$timestamp","session":{"inputTokens":10,"outputTokens":0,"primaryModelId":"grok-cache"}}
EOF

result=$(HOME="$CACHE_HOME" GROK_HOME="$CACHE_HOME/.grok" XDG_CACHE_HOME="$CACHE_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "5" ]] ||
  fail "Grok collector --limits-only reuses cached local stats" "$result"
pass "Grok collector --limits-only reuses cached local stats"

result=$(HOME="$CACHE_HOME" GROK_HOME="$CACHE_HOME/.grok" XDG_CACHE_HOME="$CACHE_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "15" ]] ||
  fail "Grok collector --force rescans past the cache" "$result"
pass "Grok collector --force rescans past the cache"

jq -c '.scanDate = "1999-01-01"' "$cache_file" >"$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
result=$(HOME="$CACHE_HOME" GROK_HOME="$CACHE_HOME/.grok" XDG_CACHE_HOME="$CACHE_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-grok" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "15" ]] ||
  fail "Grok collector treats a cache from another day as a miss" "$result"
[[ $(jq -r '.scanDate' "$cache_file") == "$today" ]] ||
  fail "Grok collector stamps the rewritten cache with the scan date" "$result"
pass "Grok collector treats a cache from another day as a miss"

UNWRITABLE_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$SESSION_HOME" "$MULTI_HOME" "$OTHER_HOME" "$CACHE_HOME" "$UNWRITABLE_HOME"' EXIT
write_usage "$UNWRITABLE_HOME/.grok" "u1" <<EOF
{"sessionId":"u1","updatedAt":"$timestamp","session":{"inputTokens":3,"outputTokens":0,"primaryModelId":"grok-u"}}
EOF
touch "$UNWRITABLE_HOME/not-a-dir"
result=$(HOME="$UNWRITABLE_HOME" GROK_HOME="$UNWRITABLE_HOME/.grok" XDG_CACHE_HOME="$UNWRITABLE_HOME/not-a-dir" \
  "$ROOT/bin/omarchy-agent-usage-grok")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "3" ]] ||
  fail "Grok collector still prints a complete record when the cache is unwritable" "$result"
pass "Grok collector still prints a complete record when the cache is unwritable"

race_output=$(python3 - "$ROOT/bin/omarchy-agent-usage-grok" "$TEST_HOME/race.json" <<'PY'
import importlib.util
import json
import sys
import threading
from importlib.machinery import SourceFileLoader
from pathlib import Path

spec = importlib.util.spec_from_loader("collector", SourceFileLoader("collector", sys.argv[1]))
collector = importlib.util.module_from_spec(spec)
spec.loader.exec_module(collector)

target = Path(sys.argv[2])
failures = []
start = threading.Barrier(8)

def hammer(writer):
  start.wait()
  for round in range(25):
    try:
      collector.write_json(target, {"writer": writer, "round": round})
    except Exception as error:
      failures.append(repr(error))

threads = [threading.Thread(target=hammer, args=(writer,)) for writer in range(8)]
for thread in threads:
  thread.start()
for thread in threads:
  thread.join()

leftovers = sorted(path.name for path in target.parent.glob(target.name + ".*"))
print(json.dumps({
  "failures": failures[:3],
  "mode": oct(target.stat().st_mode & 0o777),
  "payload": json.loads(target.read_text(encoding="utf-8")),
  "leftovers": leftovers,
}))
PY
)

[[ $(jq -c '.failures' <<<"$race_output") == "[]" ]] ||
  fail "Grok collector survives concurrent writes to one cache file" "$race_output"
[[ $(jq -r '.payload.writer != null and (.leftovers | length) == 0' <<<"$race_output") == "true" ]] ||
  fail "Grok collector leaves one intact cache file and no temp files" "$race_output"
[[ $(jq -r '.mode' <<<"$race_output") == "0o644" ]] ||
  fail "Grok collector keeps cache files readable" "$race_output"
pass "Grok collector survives concurrent writes to one cache file"
