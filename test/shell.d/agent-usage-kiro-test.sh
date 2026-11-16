#!/bin/bash

# The Kiro collector's one source: the per-session messages.jsonl logs Kiro CLI
# writes under ~/.kiro/sessions. A `user` entry is a typed prompt; replies, tool
# calls and usage summaries are not. Kiro records no tokens and exposes no plan,
# so there are no limits or tokens to hold, only prompts and sessions.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

freeze_today()
NOW = fixture_now().isoformat(timespec="milliseconds").replace("+00:00", "Z")
TWO_DAYS_AGO = (fixture_now() - timedelta(days=2)).isoformat(timespec="milliseconds").replace("+00:00", "Z")


def kiro(*args):
  return collect("kiro", *(args or ("--force",)))


def entry(kind, timestamp, **payload):
  return {"id": f"{kind}-{timestamp}", "timestamp": timestamp, "payload": {"type": kind, **payload}}


def session(workspace, name, lines):
  path = home() / ".kiro" / "sessions" / workspace / f"sess_{name}" / "messages.jsonl"
  path.parent.mkdir(parents=True, exist_ok=True)
  with path.open("w") as handle:
    for line in lines:
      handle.write((line if isinstance(line, str) else json.dumps(line)) + "\n")
  return path


# A machine that never ran Kiro CLI has nothing to show.
sandbox()
record = kiro()
expect("Kiro with no usage says it has no local stats", [record["ready"], record["hasLocalStats"], record["totalSessions"]], [False, False, 0], record)

sandbox()
session("w1", "a", [
  entry("user", NOW, content="hi"),
  # Replies, tools and the credit summary are not prompts, and a reply that
  # quotes the word "user" is not one either.
  entry("assistant", NOW, content='said "user"'),
  entry("usage_summary", NOW, promptTurnSummaries=[{"unit": "credit", "usage": 0.5}]),
  entry("user", NOW, content="again"),
  "not json but mentions \"user\"",
  entry("user", "not a time", content="skipped"),
])
session("w1", "b", [entry("user", TWO_DAYS_AGO, content="earlier")])
session("w2", "c", [entry("assistant", NOW, content="never prompted")])

record = kiro()
two_days_ago = (fixture_now().astimezone() - timedelta(days=2)).strftime("%Y-%m-%d")
expect("Kiro counts typed prompts and the sessions they came in, booked on the day each was typed", {
  "name": record["name"],
  "counts": {key: record[key] for key in ("ready", "hasLocalStats", "hasPromptStats", "todayPrompts", "todaySessions", "totalPrompts", "totalSessions", "activeDays")},
  "tokens": [record["todayTotalTokens"], record["modelUsage"]],
  "plan": [record["tierLabel"], record["usageStatusText"], record["limits"]],
  "two days ago": next(day["messageCount"] for day in record["recentDays"] if day["date"] == two_days_ago),
}, {
  "name": "Kiro",
  "counts": {"ready": True, "hasLocalStats": True, "hasPromptStats": True, "todayPrompts": 2, "todaySessions": 1, "totalPrompts": 3, "totalSessions": 2, "activeDays": 2},
  "tokens": [0, {}],
  "plan": ["", "", []],
  "two days ago": 0,
}, record)

# A scan that couldn't read every log isn't cached.
unreadable = session("w3", "d", [entry("user", NOW, content="hidden")])
unreadable.chmod(0)
try:
  if os.access(unreadable, os.R_OK):
    print("ok - Kiro does not cache a scan that could not read every log # SKIP running as root")
  else:
    for path in scan_cache_files("kiro"):
      path.unlink()
    with contextlib.redirect_stderr(io.StringIO()):
      kiro()
    check("Kiro does not cache a scan that could not read every log", not scan_cache_files("kiro"),
          ", ".join(path.name for path in scan_cache_files("kiro")))
finally:
  unreadable.chmod(0o644)

# Nor one that couldn't list a workspace, whose logs would go missing unsaid.
workspace = unreadable.parent.parent
workspace.chmod(0)
try:
  if os.access(workspace, os.R_OK):
    print("ok - Kiro does not cache a scan that could not list a workspace # SKIP running as root")
  else:
    for path in scan_cache_files("kiro"):
      path.unlink()
    with contextlib.redirect_stderr(io.StringIO()):
      kiro()
    check("Kiro does not cache a scan that could not list a workspace", not scan_cache_files("kiro"),
          ", ".join(path.name for path in scan_cache_files("kiro")))
finally:
  workspace.chmod(0o755)
PY
