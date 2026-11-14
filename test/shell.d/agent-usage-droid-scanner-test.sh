#!/bin/bash

# The Droid collector's local stats: own token usage and no child roll-up,
# thinking counted as output, prompts from typed user messages only, a missing
# transcript still counting its tokens, and the scan-cache contract. The
# unused-machine record is held by the partition test; the limits are the
# limits test's.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *
import os

freeze_today()
FROZEN_DAY = fixture_now().astimezone().date().isoformat()


def session_dir():
  folder = home() / ".factory" / "sessions" / "project"
  folder.mkdir(parents=True, exist_ok=True)
  return folder


def prompt(role, text, source=None):
  message = {"role": role, "content": [{"type": "text", "text": text}]}
  if source:
    message["userMessageSource"] = source
  return {"type": "message", "message": message}


def write_session(name, usage, prompts=()):
  folder = session_dir()
  settings = write_json(folder / f"{name}.settings.json", {
    "model": "droid-test",
    "tokenUsage": usage,
    # A child roll-up that must not be counted on top of the session's own.
    "inclusiveTokenUsage": {"inputTokens": 9999, "outputTokens": 9999, "cacheReadTokens": 9999, "cacheCreationTokens": 9999, "thinkingTokens": 9999},
  })
  # No session index here: the settings file's mtime dates the session. Stamp
  # it with the frozen clock so a test crossing midnight still dates today.
  moment = fixture_now().timestamp()
  os.utime(settings, (moment, moment))
  if prompts:
    with (folder / f"{name}.jsonl").open("w", encoding="utf-8") as handle:
      for event in prompts:
        handle.write(json.dumps(event) + "\n")


def droid(*args):
  return collect("droid", *(args or ("--force",)))


# A typed prompt counts; a context message without a source does not; a
# malformed line does not fail the session.
sandbox()
write_session("typed", {"inputTokens": 100, "outputTokens": 20, "thinkingTokens": 5, "cacheReadTokens": 5, "cacheCreationTokens": 1}, [
  prompt("user", "Fix the build", "cli_tui"),
  prompt("user", "<system>context</system>"),
  prompt("assistant", "Working on it"),
])
folder = session_dir()
with (folder / "typed.jsonl").open("a", encoding="utf-8") as handle:
  handle.write("not-json\n")

record = droid()
expect("Droid counts only its own tokens, thinking as output, and one typed prompt", {
  "ready": record["ready"], "local": record["hasLocalStats"], "promptStats": record["hasPromptStats"],
  "todayPrompts": record["todayPrompts"], "totalPrompts": record["totalPrompts"],
  "sessions": record["totalSessions"], "tokens": record["todayTotalTokens"],
  "model": record["modelUsage"].get("droid-test"),
  "recent": record["recentDays"][-1],
}, {
  "ready": True, "local": True, "promptStats": True,
  "todayPrompts": 1, "totalPrompts": 1, "sessions": 1, "tokens": 131,
  "model": {"inputTokens": 100, "outputTokens": 25, "cacheReadInputTokens": 5, "cacheCreationInputTokens": 1},
  "recent": {"date": FROZEN_DAY, "messageCount": 131},
}, record)
expect("Droid waits for a credential while its local stats stand alone", {
  "status": record["usageStatusText"], "help": "Sign in with Droid" in record["authHelpText"],
}, {"status": "Waiting for auth", "help": True}, record)

# A session with no transcript still counts its tokens, with no prompt.
sandbox()
write_session("silent", {"inputTokens": 10, "outputTokens": 2, "thinkingTokens": 0, "cacheReadTokens": 0, "cacheCreationTokens": 0})
record = droid()
expect("Droid counts a session whose transcript is missing, with no prompt", {
  "prompts": record["totalPrompts"], "sessions": record["totalSessions"], "tokens": record["todayTotalTokens"],
}, {"prompts": 0, "sessions": 1, "tokens": 12}, record)

# Invalid UTF-8 in a transcript must not stop the whole collector.
sandbox()
write_session("bad-bytes", {"inputTokens": 10, "outputTokens": 2, "thinkingTokens": 0, "cacheReadTokens": 0, "cacheCreationTokens": 0}, [
  prompt("user", "Still readable", "cli_tui"),
])
with (session_dir() / "bad-bytes.jsonl").open("ab") as handle:
  handle.write(b"\xff\xfe\n")
record = droid()
expect("Droid survives invalid UTF-8 in a transcript", {
  "ready": record["ready"], "prompts": record["totalPrompts"], "sessions": record["totalSessions"], "tokens": record["todayTotalTokens"],
}, {"ready": True, "prompts": 1, "sessions": 1, "tokens": 12}, record)

# A transcript that cannot be read is not cached; after permissions return,
# a normal run counts its prompts.
sandbox()
write_session("unreadable", {"inputTokens": 10, "outputTokens": 2, "thinkingTokens": 0, "cacheReadTokens": 0, "cacheCreationTokens": 0}, [
  prompt("user", "Read me later", "cli_tui"),
])
transcript = session_dir() / "unreadable.jsonl"
transcript.chmod(0)
record = droid("--force")
expect("Droid still counts a token session whose transcript is unreadable", {
  "prompts": record["totalPrompts"], "sessions": record["totalSessions"], "tokens": record["todayTotalTokens"],
}, {"prompts": 0, "sessions": 1, "tokens": 12}, record)
transcript.chmod(0o600)
record = collect("droid")
expect("Droid rescans instead of caching an unreadable transcript", {
  "prompts": record["totalPrompts"], "sessions": record["totalSessions"], "tokens": record["todayTotalTokens"],
}, {"prompts": 1, "sessions": 1, "tokens": 12}, record)

# An unreadable session index falls back to mtimes and is not fatal.
sandbox()
write_session("index-broken", {"inputTokens": 10, "outputTokens": 2, "thinkingTokens": 0, "cacheReadTokens": 0, "cacheCreationTokens": 0}, [
  prompt("user", "Index is broken", "cli_tui"),
])
index = home() / ".factory" / "cache" / "session-index" / "index.db"
index.parent.mkdir(parents=True, exist_ok=True)
index.write_text("not a database\n")
record = droid("--force")
expect("Droid survives an unreadable session index", {
  "ready": record["ready"], "prompts": record["totalPrompts"], "sessions": record["totalSessions"], "tokens": record["todayTotalTokens"],
}, {"ready": True, "prompts": 1, "sessions": 1, "tokens": 12}, record)

# The scan cache contract: growth is a new session with its own transcript.
sandbox()


def add_session():
  add_session.count = getattr(add_session, "count", 0) + 1
  write_session(f"grown-{add_session.count}", {"inputTokens": 10, "outputTokens": 5, "thinkingTokens": 0, "cacheReadTokens": 0, "cacheCreationTokens": 0}, [
    prompt("user", "Grow", "cli_tui"),
  ])


check_scan_cache(Adapter("droid", grow=add_session))
PY
