#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

python3 - "$ROOT/bin/omarchy-agent-usage-codex" <<'PY'
import json
import os
import runpy
import sys
import tempfile
from datetime import datetime, timedelta
from pathlib import Path

collector = sys.argv[1]
now = datetime.now().astimezone().replace(hour=12, minute=0, second=0, microsecond=0)


def tokens(input_tokens=100, output_tokens=10):
  return {"input_tokens": input_tokens, "cached_input_tokens": input_tokens // 2,
          "output_tokens": output_tokens, "reasoning_output_tokens": 2,
          "total_tokens": input_tokens + output_tokens}


def event(total, last=None, offset=0):
  return {"type": "event_msg", "timestamp": (now + timedelta(seconds=offset)).isoformat(),
          "payload": {"type": "token_count", "info": {
            "total_token_usage": total, "last_token_usage": last or tokens()},
            "rate_limits": {"primary": {"used_percent": offset}}}}


def check(name, rollouts, expected_tokens, expected_prompts):
  with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    os.environ["CODEX_HOME"] = str(root)
    for relative_path, events in rollouts.items():
      path = root / relative_path
      path.parent.mkdir(parents=True, exist_ok=True)
      path.write_text("\n".join(json.dumps(item) for item in events) + "\n")
    loaded = runpy.run_path(collector, run_name="notification_test")
    loaded["scan_native_codex_sessions"]()
    stats = loaded["local_stats"]()
    actual = sum(sum(bucket.values()) for bucket in stats["modelUsage"].values())
    assert actual == expected_tokens, (name, actual, expected_tokens)
    assert stats["totalPrompts"] == expected_prompts, (name, stats)
    assert sum(day["messageCount"] for day in stats["recentDays"]) == expected_tokens, (name, stats)
    print("ok - " + name)


check("native repeated snapshots ignore timestamp and quota changes", {
  "sessions/main.jsonl": [event(tokens()), event(tokens(), offset=1), event(tokens(), offset=2)]
}, 110, 1)

check("native equal request sizes count when cumulative usage advances", {
  "sessions/main.jsonl": [event(tokens()), event(tokens(200, 20), offset=1)]
}, 220, 2)

check("native notification deduplication stays within each rollout", {
  "sessions/first.jsonl": [event(tokens())],
  "archived_sessions/second.jsonl": [event(tokens()), event(tokens(), offset=1)]
}, 220, 2)

check("native requests without cumulative counters remain countable", {
  "sessions/main.jsonl": [event(None), event(None, offset=1), event({}), event({}, offset=1)]
}, 440, 4)

check("native counter resets do not discard new requests", {
  "sessions/main.jsonl": [event(tokens()), event(tokens(200, 20)), event(tokens())]
}, 330, 3)

check("native quota-only events and model context do not reset deduplication", {
  "sessions/main.jsonl": [event(tokens()),
    {"type": "event_msg", "payload": {"type": "token_count", "info": None}},
    {"type": "turn_context", "payload": {"model": "another-model"}},
    event(tokens(), offset=1)]
}, 110, 1)
PY
