#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command python3
require_command jq

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

export HOME="$TEST_HOME"
export XDG_CONFIG_HOME="$TEST_HOME/config"
export XDG_CACHE_HOME="$TEST_HOME/cache"
export XDG_DATA_HOME="$TEST_HOME/data"
# Only view directories within the sessions tree should be excluded.
export MUSE_DATA_DIR="$TEST_HOME/.msp-view-parent/muse"
export MUSE_AUTH_PATH="$TEST_HOME/no-auth.json"

python3 - <<'PY'
import json
import os
import time
from pathlib import Path

root = Path(os.environ["MUSE_DATA_DIR"]) / "sessions"

def event(event_id, tokens):
  return {
    "id": event_id,
    "recorded_at": int(time.time() * 1_000_000),
    "payload": {"kind": "run", "event": {
      "kind": "model_completed", "model": "muse-test",
      "usage": {"input_tokens": tokens},
    }},
  }

def write(relative, entries):
  path = root / relative / "session.jsonl"
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(entry) + "\n" for entry in entries))

first = event("first", 110)
child = event("child", 55)
rejected = event("later-valid", 0)
rejected["payload"]["event"]["usage"] = []
write("2026/09/08/session", [
  {"id": "first", "payload": {"kind": "metadata", "record": {"model_id": "muse-test"}}},
  first, first,
  {"children": [{"record_json": json.dumps(first)}, {"record_json": json.dumps(child)}]},
  event(None, 7), event(None, 7), event([], 3),
  rejected, event("later-valid", 5),
])
write("2026/09/08/session/subagent/child", [child])
write("2026/09/08/copied-session", [first])
for view in (".msp-view", ".msp-view.saved", "2026/09/08/session/.msp-view-backup"):
  write(view, [event(None, 9000)])
PY

result=$("$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -c '[.todayTotalTokens,.totalPrompts,.modelUsage["muse-test"].inputTokens]' <<<"$result") == '[187,6,187]' ]] ||
  fail "Muse counts unique completions across plain records, retained frames, and copied sessions" "$result"
pass "Muse counts unique completions across plain records, retained frames, and copied sessions"

# The same IDs without view copies must produce exactly the same record
# totals; records without a usable ID are still counted individually.
python3 - <<'PY'
import os
import shutil
from pathlib import Path
root = Path(os.environ["MUSE_DATA_DIR"]) / "sessions"
for relative in (".msp-view", ".msp-view.saved", "2026/09/08/session/.msp-view-backup"):
  shutil.rmtree(root / relative)
PY
without_views=$("$ROOT/bin/omarchy-agent-usage-muse" --force)
[[ $(jq -c '[.todayTotalTokens,.totalPrompts]' <<<"$without_views") == '[187,6]' ]] ||
  fail "Muse excludes view copies without dropping missing or malformed IDs" "$without_views"
pass "Muse excludes view copies without dropping missing or malformed IDs"

# Discard a pre-deduplication cache even during --limits-only refreshes.
python3 - <<'PY'
import json
import os
from pathlib import Path
for path in Path(os.environ["XDG_CACHE_HOME"]).rglob("muse-scan-*.json"):
  cached = json.loads(path.read_text())
  cached["schemaVersion"] = 1
  cached["stats"]["todayTotalTokens"] = 999999
  path.write_text(json.dumps(cached))
PY
refreshed=$("$ROOT/bin/omarchy-agent-usage-muse" --limits-only)
[[ $(jq '.todayTotalTokens' <<<"$refreshed") == 187 ]] ||
  fail "Muse rescans caches produced before event deduplication" "$refreshed"
pass "Muse rescans caches produced before event deduplication"
