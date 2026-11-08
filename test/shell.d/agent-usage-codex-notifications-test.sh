#!/bin/bash

# Codex writes a token_count notification after every request, and repeats
# it whenever its quota or timestamp changes. The Codex collector counts each
# request once from the cumulative counters, within each rollout, without
# losing requests that carry no counters or follow a counter reset.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox
# A stand-in Codex on PATH, so the collector never reaches for a real one.
# Nothing here is signed in, so it is never started either.
fake_codex "$HOME"
rm "$HOME/.codex/auth.json"
export PATH="$HOME/bin:$PATH"

python3 - <<'PY'
from agent_usage_fixtures import *

noon = datetime.fromisoformat(today_stamp())


def tokens(input_tokens=100, output_tokens=10):
  return {"input_tokens": input_tokens, "cached_input_tokens": input_tokens // 2,
          "output_tokens": output_tokens, "reasoning_output_tokens": 2,
          "total_tokens": input_tokens + output_tokens}


def event(total, last=None, offset=0):
  return {"type": "event_msg", "timestamp": (noon + timedelta(seconds=offset)).isoformat(),
          "payload": {"type": "token_count", "info": {
            "total_token_usage": total, "last_token_usage": last or tokens()},
            "rate_limits": {"primary": {"used_percent": offset}}}}


def counts(name, rollouts, expected_tokens):
  sandbox()
  for relative_path, events in rollouts.items():
    write_pi_session(home() / ".codex" / relative_path, events)
  record = collect("codex", "--force")
  counted = sum(sum(bucket.values()) for bucket in record["modelUsage"].values())
  # Requests are no prompts: none here was typed.
  expect(name, [counted, record["totalPrompts"], sum(day["messageCount"] for day in record["recentDays"])],
         [expected_tokens, 0, expected_tokens], record)


counts("repeated snapshots ignore timestamp and quota changes", {
  "sessions/main.jsonl": [event(tokens()), event(tokens(), offset=1), event(tokens(), offset=2)]
}, 110)

counts("equal request sizes count when cumulative usage advances", {
  "sessions/main.jsonl": [event(tokens()), event(tokens(200, 20), offset=1)]
}, 220)

counts("deduplication stays within each rollout", {
  "sessions/first.jsonl": [event(tokens())],
  "archived_sessions/second.jsonl": [event(tokens()), event(tokens(), offset=1)]
}, 220)

counts("requests without cumulative counters remain countable", {
  "sessions/main.jsonl": [event(None), event(None, offset=1), event({}), event({}, offset=1)]
}, 440)

counts("counter resets do not discard new requests", {
  "sessions/main.jsonl": [event(tokens()), event(tokens(200, 20)), event(tokens())]
}, 330)

counts("quota-only events and model context do not reset deduplication", {
  "sessions/main.jsonl": [event(tokens()),
    {"type": "event_msg", "payload": {"type": "token_count", "info": None}},
    {"type": "turn_context", "payload": {"model": "another-model"}},
    event(tokens(), offset=1)]
}, 110)
PY
