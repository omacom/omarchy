#!/bin/bash

# Muse's native sessions repeat a completion under its record id: in retained
# frames, in copied sessions, and in the .msp-view directories that hold views
# of the same history. Each completion counts once, while records without a
# usable id count one by one.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
import shutil

from agent_usage_fixtures import *

sandbox()
# Only view directories inside the sessions tree are left out, so a data
# directory whose own parent looks like one is still read.
os.environ["MUSE_DATA_DIR"] = str(home() / ".msp-view-parent" / "muse")
root = Path(os.environ["MUSE_DATA_DIR"]) / "sessions"
VIEWS = (".msp-view", ".msp-view.saved", "2026/09/08/session/.msp-view-backup")


def event(event_id, tokens):
  return {
    "id": event_id,
    "recorded_at": int(time.time() * 1_000_000),
    "payload": {"kind": "run", "event": {"kind": "model_completed", "model": "muse-test", "usage": {"input_tokens": tokens}}},
  }


def write(relative, entries):
  path = root / relative / "session.jsonl"
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(entry) + "\n" for entry in entries))


first = event("first", 110)
child = event("child", 55)
# A record whose usage is malformed claims no id, so a later valid record
# with the same id still counts.
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
for view in VIEWS:
  write(view, [event(None, 9000)])

# 110 + 55 + 7 + 7 + 3 + 5.
record = collect("muse", "--force")
expect("Muse counts unique completions across plain records, retained frames, and copied sessions",
       [record["todayTotalTokens"], record["totalPrompts"], record["modelUsage"]["muse-test"]["inputTokens"]], [187, 6, 187], record)

for view in VIEWS:
  shutil.rmtree(root / view)
record = collect("muse", "--force")
expect("Muse leaves out view copies without dropping records with a missing or malformed id",
       [record["todayTotalTokens"], record["totalPrompts"]], [187, 6], record)

# A scan cached before completions were deduplicated is made again, even for
# --limits-only.
def predates_dedup(cached):
  cached["museSchema"] = cached.get("museSchema", 0) - 1
  cached["stats"]["todayTotalTokens"] = 999999


edit_scan_cache("muse", predates_dedup)
record = collect("muse", "--limits-only")
expect("Muse rescans a scan cached before completions were deduplicated", record["todayTotalTokens"], 187, record)
PY
