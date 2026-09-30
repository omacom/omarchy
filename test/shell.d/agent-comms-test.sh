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

python3 - "$FEED" "$tmp" <<'PY'
import contextlib
import importlib.util
import io
import json
import math
import os
import subprocess
import sys
import time
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("feed", sys.argv[1])
feed = importlib.util.module_from_spec(spec)
spec.loader.exec_module(feed)
os.environ["HOME"] = str(Path(sys.argv[2]) / "regression-home")
os.environ["XDG_STATE_HOME"] = str(Path(sys.argv[2]) / "regression-state")
paths = feed.state_paths()
paths["state"].mkdir(parents=True)
paths["notes"].mkdir(parents=True)

def check(condition, description):
  if not condition:
    raise AssertionError(description)
  print("ok - " + description)

apps = feed.parse_apps(" ChatGPT , GROK, muse ")
check(feed.agent_app(" CHATGPT ", apps), "allowlist normalizes case and whitespace")
check(not any(feed.agent_app(name, apps) for name in ("chatgpt-helper", "grok-extra", "museplayer")),
      "allowlist rejects unlisted app names with an allowed prefix")
check(feed.agent_app("ChatGPT-helper", feed.parse_apps("chatgpt-helper")),
      "an app with a suffix can be explicitly allowed")

bad_stamps = ("NaN", "Infinity", "-Infinity", "1e999", float("nan"), float("inf"), -float("inf"), 10 ** 400)
check(all(feed.stamp(value) == 0 for value in bad_stamps), "non-finite and overflowing timestamps are normalized")
paths["inbox"].write_text("\n".join(json.dumps({"text": "bad clock", "ts": value}) for value in bad_stamps)
                          + '\n{"text":"valid message","ts":1710000000}\n')
rows = feed.collect(paths, apps)
with contextlib.redirect_stdout(io.StringIO()):
  feed.publish(paths, rows)
def reject_constant(value):
  raise AssertionError("invalid JSON constant: " + value)
published = json.loads(paths["feed"].read_text(), parse_constant=reject_constant)
check(all(math.isfinite(row["ts"]) for row in published["items"])
      and published["items"][-1]["text"] == "valid message",
      "invalid clocks do not poison the published JSON or hide later messages")

paths["inbox"].write_text('{"text":"untimed inbox"}\n')
original_read_bytes = Path.read_bytes
def remove_after_read(path):
  data = original_read_bytes(path)
  path.unlink()
  return data
with patch.object(Path, "read_bytes", remove_after_read):
  rows = feed.from_inbox(paths)
check(len(rows) == 1 and rows[0]["text"] == "untimed inbox" and rows[0]["ts"] > 0,
      "removing an inbox after its read does not interrupt collection")

note = paths["popups"] / "0001.json"
note.write_text('{"app":"ChatGPT","body":"untimed popup"}')
original_read_text = Path.read_text
def remove_note_after_read(path, *args, **kwargs):
  data = original_read_text(path, *args, **kwargs)
  path.unlink()
  return data
with patch.object(Path, "read_text", remove_note_after_read):
  rows = feed.from_notes(paths, apps)
check(len(rows) == 1 and rows[0]["text"] == "untimed popup" and rows[0]["ts"] > 0,
      "removing a notification after its read does not interrupt collection")

paths["inbox"].write_text('{"text":"vanishing inbox"}\n')
original_stat = Path.stat
def vanish_at_stat(path, *args, **kwargs):
  if path == paths["inbox"]:
    raise FileNotFoundError(str(path))
  return original_stat(path, *args, **kwargs)
with patch.object(Path, "stat", vanish_at_stat):
  check(feed.from_inbox(paths) == [], "an inbox disappearing before its metadata read is skipped")
paths["inbox"].unlink()

sibling = paths["state"] / "sibling.jsonl"
sibling.write_text('{"text":"first sibling","ts":1710000001}\n')
producer = subprocess.Popen([sys.executable, "-B", "-u", sys.argv[1]],
                            stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
def wait_for_message(text):
  deadline = time.monotonic() + 4
  while time.monotonic() < deadline:
    if producer.poll() is not None:
      raise AssertionError("feeder exited: " + producer.stderr.read().decode())
    try:
      payload = json.loads(paths["feed"].read_text())
      if any(row["text"] == text for row in payload["items"]):
        return payload
    except (OSError, json.JSONDecodeError):
      pass
    time.sleep(0.05)
  raise AssertionError("feeder did not publish: " + text)

try:
  wait_for_message("first sibling")
  # Let the feeder observe its own initial publication before appending.
  time.sleep(0.9)
  before = feed.snapshot(paths)
  directory_stamp = paths["state"].stat().st_mtime_ns
  with sibling.open("a") as inbox:
    inbox.write('{"text":"appended sibling","ts":1710000002}\n')
  check(paths["state"].stat().st_mtime_ns == directory_stamp and feed.snapshot(paths) != before,
        "appending to an existing sibling changes the watch snapshot without changing its directory")
  wait_for_message("appended sibling")
  check(True, "the running feeder publishes an append to an existing sibling inbox")

  note.write_text('{"app":"ChatGPT","summary":"dot","body":"live popup","timestamp":1710000003000}')
  wait_for_message("live popup")
  check(True, "the running feeder publishes a live popup before it reaches history")
  archived = paths["notes"] / note.name
  archived.write_bytes(note.read_bytes())
  rows = feed.collect(paths, apps)
  check(sum(row["text"] == "live popup" for row in rows) == 1,
        "overlapping live and history copies yield one message")
  signature = feed.signature(rows)
  note.unlink()
  check(feed.signature(feed.collect(paths, apps)) == signature,
        "archiving a popup does not change or republish the message")

  newer = paths["popups"] / "9999.json"
  newer.write_text('{"app":"Grok","body":"newest popup","timestamp":1710000004000}')
  wait_for_message("newest popup")
  time.sleep(0.9)
  before = feed.snapshot(paths)
  archived.write_text('{"app":"ChatGPT","summary":"dot","body":"updated earlier popup","timestamp":1710000003000}')
  check(feed.snapshot(paths) != before, "editing an earlier notification changes the watch snapshot")
  wait_for_message("updated earlier popup")
  check(True, "the running feeder watches updates to every retained notification file")
finally:
  producer.terminate()
  try:
    producer.wait(timeout=2)
  except subprocess.TimeoutExpired:
    producer.kill()
    producer.wait()
  producer.stderr.close()
PY
