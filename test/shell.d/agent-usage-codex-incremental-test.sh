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
import time
from pathlib import Path
from datetime import datetime, timedelta
from unittest.mock import patch

script = sys.argv[1]
with tempfile.TemporaryDirectory() as temp:
  home = Path(temp)
  root = home / "sessions"
  root.mkdir()
  path = root / "test.jsonl"
  cache = home / "native.json"
  os.environ["CODEX_HOME"] = temp

  def context(model):
    return json.dumps({"type": "turn_context", "payload": {"model": model}}) + "\n"

  def usage(n):
    return json.dumps({"type": "event_msg", "payload": {"type": "token_count", "info": {"last_token_usage": {"input_tokens": n}}}}) + "\n"

  def scan(force=False, unopened=False, forbidden=None):
    ns = runpy.run_path(script)
    original_open, original_loads = Path.open, json.loads

    def checked_open(self, *args, **kwargs):
      assert not (unopened and self.suffix == ".jsonl"), "Unchanged transcript was opened"
      return original_open(self, *args, **kwargs)

    def checked_loads(raw, *args, **kwargs):
      assert forbidden is None or raw != forbidden, "Previously consumed record was parsed again"
      return original_loads(raw, *args, **kwargs)

    with patch.object(Path, "open", checked_open), patch.object(json, "loads", checked_loads):
      ns["scan_native_codex_sessions"](cache, force)
    return ns["local_stats"]()

  def equivalent(label):
    incremental = scan()
    assert incremental == scan(force=True), label
    print("ok - " + label)
    return incremental

  path.write_text(context("first") + usage(7))
  initial = equivalent("cold scan matches full rebuild")
  assert scan(unopened=True) == initial
  print("ok - unchanged transcripts are never opened")

  with path.open("a") as handle:
    handle.write(usage(11) + context("second") + usage(3))
  appended = scan(forbidden=usage(7))
  assert appended["totalPrompts"] == 3
  assert appended["modelUsage"]["first"]["inputTokens"] == 18
  assert appended["modelUsage"]["second"]["inputTokens"] == 3
  assert appended == scan(force=True)
  print("ok - appends parse only new records and retain model context")

  with path.open("a") as handle:
    handle.write(usage(13)[:-1])
  assert scan() == appended
  assert scan(unopened=True) == appended
  with path.open("a") as handle:
    handle.write("\n")
  assert equivalent("partial trailing line is counted once after completion")["totalPrompts"] == 4

  path.write_text(context("short") + usage(2))
  assert equivalent("truncation replaces old totals")["totalPrompts"] == 1

  replacement = root / "replacement.tmp"
  replacement.write_text(context("replacement") + usage(19))
  replacement.replace(path)
  assert "replacement" in equivalent("inode replacement rebuilds the file")["modelUsage"]

  path.write_text(context("replacement") + usage(29))
  assert equivalent("same-size rewrite rebuilds the file")["todayTotalTokens"] == 29

  path.write_text(context("rewritten") + usage(31) + usage(37))
  assert equivalent("rewrite plus growth fails the prefix check")["todayTotalTokens"] == 68

  second = root / "new.jsonl"
  second.write_text(usage(41))
  assert equivalent("new files are included")["totalSessions"] == 2
  second.unlink()
  assert equivalent("deleted files are removed")["totalSessions"] == 1
  archived = home / "archived_sessions"
  archived.mkdir()
  path.rename(archived / path.name)
  assert equivalent("archiving does not duplicate usage")["totalSessions"] == 1

  cache.write_text('{"schemaVersion":1,"files":[]}')
  equivalent("malformed cache falls back to a full scan")
  envelope = json.loads(cache.read_text())
  for record in envelope["files"].values():
    record["rows"] = [None]
  cache.write_text(json.dumps(envelope))
  equivalent("malformed per-file records rebuild safely")

  with patch.dict(os.environ, {"TZ": "UTC"}):
    equivalent("timezone change rebuilds dated aggregates")

  ns = runpy.run_path(script)
  with patch.object(Path, "replace", side_effect=OSError("cache unavailable")):
    ns["scan_native_codex_sessions"](cache)
  assert ns["local_stats"]() == scan(force=True)
  print("ok - cache write failure preserves usage results")

  path = archived / path.name
  original_loads = json.loads
  changed = False

  def append_during_read(raw, *args, **kwargs):
    global changed
    if raw == usage(31) and not changed:
      changed = True
      with path.open("a") as handle:
        handle.write(usage(43))
    return original_loads(raw, *args, **kwargs)

  ns = runpy.run_path(script)
  with patch.object(json, "loads", append_during_read):
    ns["scan_native_codex_sessions"](cache, force=True)
  assert changed
  assert str(path) not in json.loads(cache.read_text())["files"]
  assert equivalent("file changed during reading is rebuilt next time")["todayTotalTokens"] == 111

  # Daily display fields are rebuilt from aggregates, not frozen in the cache.
  next_day = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
  ns = runpy.run_path(script)
  ns["scan_native_codex_sessions"].__globals__["today"] = next_day
  ns["scan_native_codex_sessions"](cache)
  assert ns["local_stats"]()["todayTotalTokens"] == 0
  assert ns["local_stats"]()["totalPrompts"] == 3
  print("ok - a new day recomputes daily totals from cached aggregates")

  ns = runpy.run_path(script)
  with patch.object(time, "time", return_value=time.time() + 31 * 86400):
    ns["scan_native_codex_sessions"](cache)
  assert ns["local_stats"]()["totalSessions"] == 0
  assert json.loads(cache.read_text())["files"] == {}
  print("ok - expired files are dropped from both totals and cache")

  old_path = root / "2020/01/01/rollout-2020-01-01T00-00-00-id.jsonl"
  old_path.parent.mkdir(parents=True)
  path.rename(old_path)
  assert equivalent("old path dates do not exclude a recently modified file")["totalPrompts"] == 3
  cutoff = time.time() - 30 * 86400
  os.utime(old_path, (cutoff, cutoff))
  ns = runpy.run_path(script)
  with patch.object(time, "time", return_value=cutoff + 30 * 86400):
    ns["scan_native_codex_sessions"](cache)
  assert ns["local_stats"]()["totalPrompts"] == 3
  os.utime(old_path, (cutoff - 1, cutoff - 1))
  ns = runpy.run_path(script)
  with patch.object(time, "time", return_value=cutoff + 30 * 86400):
    ns["scan_native_codex_sessions"](cache)
  assert ns["local_stats"]()["totalPrompts"] == 0
  print("ok - original exact mtime cutoff is retained")
PY
