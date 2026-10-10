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
  os.environ["CODEX_HOME"] = temp
  os.environ["XDG_CACHE_HOME"] = temp
  cache = runpy.run_path(script)["file_cache_path"]()

  def context(model):
    return json.dumps({"type": "turn_context", "payload": {"model": model}}, ensure_ascii=False) + "\n"

  def usage(n, total=None):
    return json.dumps({"type": "event_msg", "payload": {"type": "token_count", "info": {
      "last_token_usage": {"input_tokens": n}, "total_token_usage": total}}}) + "\n"

  def meta(provider):
    return json.dumps({"type": "session_meta", "payload": {"model_provider": provider}}) + "\n"

  def scan(force=False, unopened=False, forbidden=None):
    ns = runpy.run_path(script)
    original_open, original_loads = Path.open, json.loads
    opened, parsed = [], []

    def checked_open(self, *args, **kwargs):
      opened.append(self)
      return original_open(self, *args, **kwargs)

    def checked_loads(raw, *args, **kwargs):
      parsed.append(raw)
      return original_loads(raw, *args, **kwargs)

    with patch.object(Path, "open", checked_open), patch.object(json, "loads", checked_loads):
      scanned = {}
      ns["scan_native_codex_sessions"]({} if force else ns["read_file_cache"](), scanned)
      ns["write_file_cache"](scanned)
    assert not (unopened and any(p.suffix == ".jsonl" for p in opened)), "Unchanged transcript was opened"
    assert forbidden is None or forbidden not in parsed, "Previously consumed record was parsed again"
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
    handle.write(usage(13)[:-3])
  assert scan() == appended
  with path.open("a") as handle:
    handle.write(usage(13)[-3:])
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
    record["days"] = {"bad": {"model": [None]}}
  cache.write_text(json.dumps(envelope))
  equivalent("malformed per-file records rebuild safely")

  with patch.dict(os.environ, {"TZ": "UTC"}):
    equivalent("timezone change rebuilds dated aggregates")

  ns = runpy.run_path(script)
  with patch.object(Path, "replace", side_effect=OSError("cache unavailable")):
    scanned = {}
    ns["scan_native_codex_sessions"](ns["read_file_cache"](), scanned)
    ns["write_file_cache"](scanned)
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
    scanned = {}
    ns["scan_native_codex_sessions"]({}, scanned)
    ns["write_file_cache"](scanned)
  assert changed
  assert str(path) not in json.loads(cache.read_text())["files"]
  assert equivalent("file changed during reading is rebuilt next time")["todayTotalTokens"] == 111

  # Daily display fields are rebuilt from aggregates, not frozen in the cache.
  next_day = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
  ns = runpy.run_path(script)
  ns["merge_file_record"].__globals__["today"] = next_day
  ns["scan_native_codex_sessions"](ns["read_file_cache"](), {})
  assert ns["local_stats"]()["todayTotalTokens"] == 0
  assert ns["local_stats"]()["totalPrompts"] == 3
  print("ok - a new day recomputes daily totals from cached aggregates")

  ns = runpy.run_path(script)
  with patch.object(time, "time", return_value=time.time() + 31 * 86400):
    scanned = {}
    ns["scan_native_codex_sessions"](ns["read_file_cache"](), scanned)
    ns["write_file_cache"](scanned)
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
    ns["scan_native_codex_sessions"](ns["read_file_cache"](), {})
  assert ns["local_stats"]()["totalPrompts"] == 3
  os.utime(old_path, (cutoff - 1, cutoff - 1))
  ns = runpy.run_path(script)
  with patch.object(time, "time", return_value=cutoff + 30 * 86400):
    ns["scan_native_codex_sessions"](ns["read_file_cache"](), {})
  assert ns["local_stats"]()["totalPrompts"] == 0
  print("ok - original exact mtime cutoff is retained")

  old_path.unlink()
  path = root / "test.jsonl"

  # Resume offsets must be bytes, even when the model name contains Unicode.
  path.write_text(meta("openai") + context("模型") + usage(5))
  scan()
  with path.open("a") as handle:
    handle.write(meta("ollama") + usage(7))
  result = scan(forbidden=usage(5))
  assert result["modelUsage"]["模型"]["inputTokens"] == 12
  assert result == scan(force=True)
  print("ok - Unicode byte offsets and the first provider decision survive appends")

  for provider in ("ollama", "openrouter"):
    path.write_text(meta(provider) + context("foreign") + usage(900))
    assert scan()["totalPrompts"] == 0
    with path.open("a") as handle:
      handle.write(meta("openai") + usage(800))
    assert scan(forbidden=usage(800))["totalPrompts"] == 0
    equivalent("foreign provider remains excluded after appending: " + provider)

  path.write_text(meta("") + context("legacy") + usage(9))
  scan()
  with path.open("a") as handle:
    handle.write(usage(11))
  assert equivalent("legacy rollouts without a provider still count after appends")["todayTotalTokens"] == 20

  path.write_text(meta("openai") + context("dedup") + usage(5, {"input_tokens": 5}))
  scan()
  with path.open("a") as handle:
    handle.write(context("changed") + usage(5, {"input_tokens": 5}) + usage(5, {"input_tokens": 10}))
  result = scan(forbidden=context("dedup"))
  assert result["totalPrompts"] == 2
  assert result["modelUsage"]["dedup"]["inputTokens"] == 5
  assert result["modelUsage"]["changed"]["inputTokens"] == 5
  assert result == scan(force=True)
  print("ok - repeated quota snapshots stay deduplicated across the resume boundary")

  # Complete JSON without a newline contributes now and is retried safely.
  path.write_text(context("tail") + usage(2))
  scan()
  previous = json.loads(cache.read_text())["files"][str(path)]
  with path.open("a") as handle:
    handle.write(usage(3)[:-1])
  assert scan()["todayTotalTokens"] == 5
  assert scan()["todayTotalTokens"] == 5
  assert json.loads(cache.read_text())["files"][str(path)] == previous
  with path.open("a") as handle:
    handle.write("\n" + usage(7))
  assert equivalent("unterminated complete records count once when the tail finishes")["todayTotalTokens"] == 12

  # Keep the old resume point when a writer races an append scan.
  previous = json.loads(cache.read_text())["files"][str(path)]
  with path.open("a") as handle:
    handle.write(usage(11))
  changed = False

  def race_append(raw, *args, **kwargs):
    global changed
    if raw == usage(11) and not changed:
      changed = True
      with path.open("a") as handle:
        handle.write(usage(13))
    return original_loads(raw, *args, **kwargs)

  with patch.object(json, "loads", race_append):
    assert scan()["todayTotalTokens"] == 23
  assert changed
  assert json.loads(cache.read_text())["files"][str(path)] == previous
  result = scan(forbidden=usage(2))
  assert result["todayTotalTokens"] == 36
  assert result == scan(force=True)
  print("ok - concurrent appends retain the last safe resume point")

  path.write_text(context("truncated") + usage(3) + "x" * 20000 + "\n")
  changed = False

  def truncate_during_read(raw, *args, **kwargs):
    global changed
    if raw == usage(3) and not changed:
      changed = True
      path.write_text(context("truncated") + usage(7))
    return original_loads(raw, *args, **kwargs)

  with patch.object(json, "loads", truncate_during_read):
    assert scan(force=True)["todayTotalTokens"] == 3
  assert changed
  assert str(path) not in json.loads(cache.read_text())["files"]
  assert equivalent("truncation during reading finishes and rebuilds next time")["todayTotalTokens"] == 7

  # A malformed matching line stops only its rollout, keeping prior usage.
  healthy = root / "healthy.jsonl"
  healthy.write_text(context("healthy") + usage(17))
  for broken in (
    '{"type":"turn_context","payload":[1]}\n',
    '{"type":"event_msg","timestamp":1e300,"payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":19}}}}\n',
  ):
    path.write_text(context("broken") + usage(3))
    scan()
    previous = json.loads(cache.read_text())["files"][str(path)]
    with path.open("a") as handle:
      handle.write(broken + usage(29))
    result = scan()
    assert result["todayTotalTokens"] == 20
    assert result["modelUsage"]["broken"]["inputTokens"] == 3
    assert json.loads(cache.read_text())["files"][str(path)] == previous
    assert result == scan(force=True)
  print("ok - malformed rollouts preserve partial totals and do not stop other files")

  healthy.unlink()
  path.write_text(context("schema") + usage(23))
  scan()
  envelope = json.loads(cache.read_text())
  envelope["schemaVersion"] = 1
  envelope["files"][str(path)]["days"] = {"bad": {"stale": [999, 0, 0, 0, 1]}}
  cache.write_text(json.dumps(envelope))
  assert equivalent("the landed cache schema is rebuilt with resume state")["todayTotalTokens"] == 23

  # Undated records use the current file mtime when an append crosses a day.
  path.write_text(context("undated") + usage(2))
  yesterday = (datetime.now() - timedelta(days=1)).timestamp()
  os.utime(path, (yesterday, yesterday))
  assert scan()["todayTotalTokens"] == 0
  with path.open("a") as handle:
    handle.write(usage(3))
  assert equivalent("undated cached turns follow the new mtime day")["todayTotalTokens"] == 5
PY
