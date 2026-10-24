#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

PYTHONDONTWRITEBYTECODE=1 python3 - "$ROOT/bin/omarchy-agent-usage-opencodego" <<'PY'
import contextlib
import datetime as dt
import hashlib
import importlib.machinery
import importlib.util
import io
import json
import os
import sqlite3
import sys
import tempfile
import time
import unittest
from pathlib import Path
from unittest.mock import patch

loader = importlib.machinery.SourceFileLoader("opencodego", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
scanner = importlib.util.module_from_spec(spec)
loader.exec_module(scanner)


class ScannerTests(unittest.TestCase):
  def setUp(self):
    self.scratch = tempfile.TemporaryDirectory()
    self.addCleanup(self.scratch.cleanup)
    self.home = Path(self.scratch.name)
    self.env = patch.dict(os.environ, {
      "HOME": str(self.home), "XDG_DATA_HOME": str(self.home / "data"),
      "XDG_CACHE_HOME": str(self.home / "cache"), "XDG_CONFIG_HOME": str(self.home / "config"),
      "OPENCODE_GO_API_KEY": "", "PI_CODING_AGENT_DIR": "", "TZ": "UTC",
    })
    self.env.start()
    self.addCleanup(self.env.stop)
    time.tzset()
    self.addCleanup(time.tzset)
    # Any accidental network use fails, including in the full main() path.
    self.network = patch.object(scanner.urllib.request, "urlopen", side_effect=AssertionError("unexpected network"))
    self.network.start()
    self.addCleanup(self.network.stop)
    self.db = self.home / "data/opencode/opencode.db"
    self.now = int(time.time() * 1000)

  def database(self, versions=(1,), providers=True):
    self.db.parent.mkdir(parents=True, exist_ok=True)
    with contextlib.closing(sqlite3.connect(self.db)) as conn, conn:
      for version in versions:
        table = "message" if version == 1 else "session_message"
        columns = "session_id text, data text" + (", type text" if version == 2 else "")
        conn.execute(f"CREATE TABLE IF NOT EXISTS {table} ({columns})")
        def insert(provider, role="assistant", raw=None):
          entry = {
            "tokens": {"input": 10, "output": 4, "reasoning": 3, "cache": {"read": 2, "write": 1}},
            "time": {"created": self.now},
          }
          if version == 1:
            entry.update(role=role, providerID=provider, modelID="models/shared")
          else:
            entry["model"] = {"providerID": provider, "id": "models/shared"}
          values = ("same-session", json.dumps(entry) if raw is None else raw)
          if version == 2:
            values += (role,)
          conn.execute(f"INSERT INTO {table} VALUES ({','.join('?' for _ in values)})", values)
        insert("opencode-go")
        if providers:
          for provider in ("opencode-go-proxy", "opencode", "opencode-go-plus", "openai"):
            insert(provider)
          insert("opencode-go", role="user")
          for raw in ('not json', '[]', 'null', '{"role":"assistant","providerID":"opencode-go","tokens":[]}'):
            insert("opencode-go", raw=raw)

  def db_cache(self):
    digest = hashlib.sha1(str(self.db).encode()).hexdigest()[:16]
    return self.home / f"cache/omarchy/agent-usage/opencodego-{digest}.json"

  def assert_stats(self, stats, prompts=1, tokens=20, sessions=1):
    self.assertEqual(stats["totalPrompts"], prompts)
    self.assertEqual(stats["todayPrompts"], prompts)
    self.assertEqual(stats["todayTotalTokens"], tokens)
    self.assertEqual(stats["todaySessions"], sessions)
    self.assertEqual(stats["totalSessions"], sessions)
    self.assertEqual(len(stats["recentDays"]), 7)
    self.assertEqual(sum(day["messageCount"] for day in stats["recentDays"]), tokens)

  def test_v1_exact_provider_malformed_rows_and_read_only(self):
    self.database()
    before = self.db.read_bytes()
    stats = scanner.scan_opencode_stats(0)
    self.assert_stats(stats)
    self.assertEqual(stats["modelUsage"]["shared"], {
      "inputTokens": 10, "outputTokens": 7,
      "cacheReadInputTokens": 2, "cacheCreationInputTokens": 1,
    })
    self.assertEqual(self.db.read_bytes(), before)

  def test_v2_only(self):
    self.database((2,))
    self.assert_stats(scanner.scan_opencode_stats(0))

  def test_mixed_database(self):
    self.database((1, 2))
    self.assert_stats(scanner.scan_opencode_stats(0), prompts=2, tokens=40, sessions=2)

  def test_missing_database_and_no_auth_record(self):
    output = io.StringIO()
    with patch.object(sys, "argv", ["collector", "--force"]), contextlib.redirect_stdout(output):
      self.assertEqual(scanner.main(), 0)
    record = json.loads(output.getvalue())
    self.assertFalse(record["ready"])
    self.assertEqual(record["limits"], [])
    self.assert_stats(record, prompts=0, tokens=0, sessions=0)
    self.assertFalse(self.db.exists())

  def test_failed_scan_preserves_cache_and_recovers(self):
    self.database()
    scanner.scan_opencode_stats(0)
    cache = self.db_cache()
    good = cache.read_bytes()
    # A readable file that is temporarily not a database must not replace
    # the good scan with a successful-looking empty cache.
    self.db.write_bytes(b"not sqlite")
    with self.assertRaises(scanner.LocalScanError):
      scanner.scan_opencode_stats(0)
    self.assertEqual(cache.read_bytes(), good)
    self.db.write_bytes(b"")
    self.database((2,))
    self.assert_stats(scanner.scan_opencode_stats(0))

  def test_corrupt_cache_envelopes_and_stats(self):
    self.database()
    good = scanner.scan_opencode_stats(0)
    invalid = [None, [], 42, "scalar", {}, {"stats": []}, {"stats": {}}]
    for field, value in (
      ("todayPrompts", True), ("todayTotalTokens", -1), ("totalSessions", "1"),
      ("todayTokensByModel", []), ("todayTokensByModel", {"shared": float("nan")}),
      ("recentDays", []), ("recentDays", [{"date": "bad", "messageCount": 20}] * 7),
      ("activeDates", [42]), ("activeDays", None), ("modelUsage", {"shared": {}}),
      ("modelUsage", {"shared": dict(scanner.empty_bucket(), inputTokens=True)}),
    ):
      envelope = json.loads(self.db_cache().read_text())
      envelope["stats"] = dict(good, **{field: value})
      invalid.append(envelope)
    for value in invalid:
      with self.subTest(value=value):
        self.db_cache().write_text(json.dumps(value))
        with patch.object(scanner.sqlite3, "connect", wraps=sqlite3.connect) as connect:
          self.assertEqual(scanner.scan_opencode_stats(900), good)
          connect.assert_called_once()
    self.db_cache().write_text('{"stats":')
    self.assert_stats(scanner.scan_opencode_stats(900))

  def test_initial_database_error_does_not_cache_success(self):
    self.db.parent.mkdir(parents=True)
    self.db.write_bytes(b"not sqlite")
    with self.assertRaises(scanner.LocalScanError):
      scanner.scan_opencode_stats(900)
    self.assertFalse(self.db_cache().exists())
    self.db.write_bytes(b"")
    self.database((2,))
    self.assert_stats(scanner.scan_opencode_stats(900))

  def test_valid_cache_hit_and_force_rescan(self):
    self.database()
    self.assert_stats(scanner.scan_opencode_stats(0))
    self.database(providers=False)
    self.assert_stats(scanner.scan_opencode_stats(900))
    self.assert_stats(scanner.scan_opencode_stats(0), prompts=2, tokens=40)

  def test_future_cache_is_rejected(self):
    self.database()
    scanner.scan_opencode_stats(0)
    cached = json.loads(self.db_cache().read_text())
    cached["stats"]["todayTotalTokens"] = 999
    self.db_cache().write_text(json.dumps(cached))
    future = time.time() + 3600
    os.utime(self.db_cache(), (future, future))
    self.assert_stats(scanner.scan_opencode_stats(900))

  def test_midnight_and_timezone_invalidate_cache(self):
    self.database()
    scanner.scan_opencode_stats(0)
    tomorrow = dt.date.today() + dt.timedelta(days=1)
    days = [(tomorrow - dt.timedelta(days=n)).isoformat() for n in range(6, -1, -1)]
    with patch.object(scanner, "local_date_string", return_value=tomorrow.isoformat()), \
        patch.object(scanner, "recent_date_strings", return_value=days):
      stats = scanner.scan_opencode_stats(900)
      self.assertEqual(stats["todayTotalTokens"], 0)
      self.assertEqual(stats["recentDays"][-1]["date"], tomorrow.isoformat())
    scanner.scan_opencode_stats(0)
    cached = json.loads(self.db_cache().read_text())
    cached["stats"]["todayTotalTokens"] = 999
    self.db_cache().write_text(json.dumps(cached))
    with patch.dict(os.environ, {"TZ": "Etc/GMT+12"}):
      time.tzset()
      self.assertNotEqual(scanner.scan_opencode_stats(900)["todayTotalTokens"], 999)
    time.tzset()

  def test_cache_unavailable_is_best_effort(self):
    self.database()
    blocker = self.home / "not-a-directory"
    blocker.write_text("block")
    with patch.dict(os.environ, {"XDG_CACHE_HOME": str(blocker)}):
      self.assert_stats(scanner.scan_opencode_stats(0))
      self.assertIsNone(scanner.scan_pi_usage(0))
    # Permission mocks work even under root and cover both mkdir and writes.
    with patch.object(Path, "mkdir", side_effect=PermissionError("read-only cache")):
      self.assert_stats(scanner.scan_opencode_stats(0))
    with patch.object(scanner.tempfile, "NamedTemporaryFile", side_effect=PermissionError("unwritable cache")):
      self.assert_stats(scanner.scan_opencode_stats(0))

  def test_atomic_cache_failure_preserves_last_success(self):
    self.database()
    scanner.scan_opencode_stats(0)
    before = self.db_cache().read_bytes()
    self.database(providers=False)
    with patch.object(scanner.os, "replace", side_effect=PermissionError("read-only destination")):
      self.assert_stats(scanner.scan_opencode_stats(0), prompts=2, tokens=40)
    self.assertEqual(self.db_cache().read_bytes(), before)
    self.assertEqual(list(self.db_cache().parent.glob("*.tmp")), [])

  def session(self, root, name, timestamp, provider="opencode-go", usage=None):
    root.mkdir(parents=True, exist_ok=True)
    entry = {"type": "message", "id": name, "timestamp": timestamp, "message": {
      "role": "assistant", "provider": provider, "model": "shared",
      "usage": usage or {"input": 10, "output": 4, "cacheRead": 2, "cacheWrite": 1},
    }}
    (root / f"{name}.jsonl").write_text('\n'.join([
      'not json', '[]', '{"type":"message","message":{"role":"assistant","usage":[]}}',
      json.dumps(entry), json.dumps(entry),  # Existing same-file ID semantics.
    ]))

  def test_unreadable_session_does_not_cache_partial_scan(self):
    root = self.home / ".pi/agent/sessions/project"
    iso = dt.datetime.now(dt.timezone.utc).isoformat()
    self.session(root, "good", iso)
    scanner.scan_pi_usage(0)
    cache = self.home / "cache/omarchy/agent-usage/opencodego-pi-sessions.json"
    before = cache.read_bytes()
    self.session(root, "new", iso)
    self.session(root, "unreadable", iso)
    real_open = Path.open
    def open_fixture(path, *args, **kwargs):
      if path.name == "unreadable.jsonl":
        raise PermissionError("unreadable fixture")
      return real_open(path, *args, **kwargs)
    with patch.object(Path, "open", open_fixture), self.assertRaises(scanner.LocalScanError):
      scanner.scan_pi_usage(0)
    self.assertEqual(cache.read_bytes(), before)
    self.assertEqual(scanner.scan_pi_usage(0)["totalPrompts"], 3)

  def test_scan_failures_publish_nothing_and_sanitize_stderr(self):
    self.database()
    iso = dt.datetime.now(dt.timezone.utc).isoformat()
    self.session(self.home / ".pi/agent/sessions/project", "good", iso)
    secret = "synthetic-secret-path-and-key"
    # Cover errors before opening, during discovery, and after partial rows.
    real_stat = Path.stat
    def stat_fixture(path, *args, **kwargs):
      if path == self.db:
        raise PermissionError(secret)
      return real_stat(path, *args, **kwargs)
    class BrokenConnection:
      def execute(self, query):
        if query == "PRAGMA query_only = ON":
          return []
        if "sqlite_master" in query:
          return [("message",)]
        def rows():
          yield ("session", json.dumps({"role": "assistant", "providerID": "opencode-go",
                 "tokens": {"input": 10}}), None)
          raise sqlite3.OperationalError(secret)
        return rows()
      def close(self):
        pass
    self.session(self.home / ".omp/profiles/work/agent/sessions/project", "profile", iso)
    real_scandir = scanner.os.scandir
    def nested_failure(path):
      if str(path).endswith("/project"):
        raise PermissionError(secret)
      return real_scandir(path)
    def session_stat_failure(path, *args, **kwargs):
      if path == self.home / ".pi/agent/sessions":
        raise PermissionError(secret)
      return real_stat(path, *args, **kwargs)
    real_open = Path.open
    def partial_read(path, *args, **kwargs):
      if path.name == "good.jsonl":
        def lines():
          yield json.dumps({"type": "message", "message": {"role": "assistant",
                           "provider": "opencode-go", "usage": {"input": 10}}})
          raise OSError(secret)
        return contextlib.nullcontext(lines())
      return real_open(path, *args, **kwargs)
    failures = [
      ("database stat", patch.object(Path, "stat", stat_fixture)),
      ("partial SQLite cursor", patch.object(scanner.sqlite3, "connect", return_value=BrokenConnection())),
      ("session root stat", patch.object(Path, "stat", session_stat_failure)),
      ("profile discovery", patch.object(Path, "iterdir", side_effect=PermissionError(secret))),
      ("root traversal", patch.object(scanner.os, "scandir", side_effect=PermissionError(secret))),
      ("nested traversal", patch.object(scanner.os, "scandir", side_effect=nested_failure)),
      ("session open", patch.object(Path, "open", side_effect=PermissionError(secret))),
      ("partial session read", patch.object(Path, "open", partial_read)),
    ]
    for name, failure in failures:
      with self.subTest(failure=name), failure:
        output, errors = io.StringIO(), io.StringIO()
        with patch.object(sys, "argv", ["collector", "--force"]), \
            contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
          self.assertNotEqual(scanner.main(), 0)
        self.assertEqual(output.getvalue(), "")
        self.assertEqual(errors.getvalue(), "OpenCode Go local usage scan failed.\n")
    self.assert_stats(scanner.scan_opencode_stats(0))

  def test_custom_pi_roots_replace_default_and_invalidate_only_session_cache(self):
    self.database()
    scanner.scan_opencode_stats(0)
    iso = dt.datetime.now(dt.timezone.utc).isoformat()
    self.session(self.home / ".pi/agent/sessions/project", "default", iso)
    self.session(self.home / ".omp/agent/sessions/project", "omp", iso)
    self.session(self.home / ".omp/profiles/work/agent/sessions/project", "profile", iso)
    self.assertEqual(scanner.scan_pi_usage(0)["totalPrompts"], 3)
    with patch.dict(os.environ, {}, clear=False):
      os.environ.pop("PI_CODING_AGENT_DIR", None)
      self.assertEqual(scanner.scan_pi_usage(900)["totalPrompts"], 3)
    for name, count in (("custom-a", 1), ("custom-b", 2)):
      agent = self.home / name
      for n in range(count):
        self.session(agent / "sessions/project", str(n), iso)
      with patch.dict(os.environ, {"PI_CODING_AGENT_DIR": str(agent)}):
        self.assertEqual(scanner.scan_pi_usage(900)["totalPrompts"], count + 2)
        with patch.object(scanner.sqlite3, "connect", side_effect=AssertionError("SQLite cache invalidated")):
          self.assert_stats(scanner.scan_opencode_stats(900))
    self.assertEqual(scanner.scan_pi_usage(900)["totalPrompts"], 3)

  def test_pi_omp_profiles_and_model_day_merges(self):
    self.database()
    iso = dt.datetime.now(dt.timezone.utc).isoformat()
    yesterday = int((time.time() - 86400) * 1000)
    self.session(self.home / ".pi/agent/sessions/project", "pi", iso)
    self.session(self.home / ".omp/agent/sessions/project", "omp", self.now)
    self.session(self.home / ".omp/profiles/work/agent/sessions/project", "profile", iso,
                 usage={"totalTokens": 8})
    self.session(self.home / ".pi/agent/sessions/project", "old", yesterday)
    self.session(self.home / ".pi/agent/sessions/project", "other", iso, provider="opencode-go-proxy")
    pi = scanner.scan_pi_usage(0)
    self.assertEqual(pi["totalPrompts"], 4)
    self.assertEqual(pi["todayTotalTokens"], 42)
    merged = scanner.merge_stats(scanner.scan_opencode_stats(0), pi)
    self.assertEqual(merged["totalPrompts"], 5)
    self.assertEqual(merged["todayTotalTokens"], 62)
    self.assertEqual(merged["todayTokensByModel"], {"shared": 62})
    self.assertEqual(merged["modelUsage"]["shared"]["cacheReadInputTokens"], 8)
    self.assertEqual(merged["activeDays"], 2)
    self.assertEqual(sum(day["messageCount"] for day in merged["recentDays"]), 79)
    self.assertEqual(scanner.scan_pi_usage(900), pi)
    cache = self.home / "cache/omarchy/agent-usage/opencodego-pi-sessions.json"
    cache.write_text('[]')
    self.assertEqual(scanner.scan_pi_usage(900), pi)


unittest.main(argv=[sys.argv[0]], verbosity=2)
PY
pass "OpenCode Go scans isolated databases, sessions, and best-effort caches"
