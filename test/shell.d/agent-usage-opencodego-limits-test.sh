#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

PYTHONDONTWRITEBYTECODE=1 python3 - "$ROOT/bin/omarchy-agent-usage-opencodego" <<'PY'
import contextlib
import http.client
import importlib.machinery
import importlib.util
import io
import json
import os
import sys
import tempfile
import unittest
import urllib.error
from pathlib import Path
from unittest.mock import patch

loader = importlib.machinery.SourceFileLoader("opencodego", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
RESET = "2026-10-13T12:00:00Z"
KEY = "synthetic-secret-key"


class LimitsTests(unittest.TestCase):
  def setUp(self):
    self.scratch = tempfile.TemporaryDirectory()
    self.addCleanup(self.scratch.cleanup)
    self.home = Path(self.scratch.name)
    env = patch.dict(os.environ, {
      "HOME": str(self.home), "XDG_DATA_HOME": str(self.home / "data"),
      "XDG_CACHE_HOME": str(self.home / "cache"), "XDG_CONFIG_HOME": str(self.home / "config"),
      "OPENCODE_GO_API_KEY": "", "PI_CODING_AGENT_DIR": "",
    })
    env.start()
    self.addCleanup(env.stop)
    network = patch.object(collector.urllib.request, "urlopen", side_effect=AssertionError("unmocked network"))
    network.start()
    self.addCleanup(network.stop)

  def probe(self, payload):
    def respond(request, timeout):
      self.assertEqual(request.full_url, collector.USAGE_URL)
      self.assertEqual(request.get_header("Authorization"), f"Bearer {KEY}")
      self.assertEqual(request.get_header("User-agent"), "omarchy-agent-usage-opencodego/1.0")
      self.assertEqual(timeout, 10)
      return contextlib.closing(io.BytesIO(json.dumps(payload).encode()))
    with patch.object(collector.urllib.request, "urlopen", side_effect=respond):
      result = collector.probe_limits(KEY)
    self.assertNotIn(KEY, json.dumps(result))
    return result

  def test_success_boundaries_partial_windows(self):
    result = self.probe({"usage": {
      "rolling": {"percent": 0, "resetsAt": RESET},
      "weekly": {"percent": 100, "resetsAt": "2026-10-14T12:30:00+02:00"},
      "monthly": {"percent": 45.5, "resetsAt": RESET},
    }})
    self.assertTrue(result["ok"])
    self.assertEqual([limit["percent"] for limit in result["limits"]], [0, 1, .455])
    partial = self.probe({"usage": {"rolling": {"percent": 20, "resetsAt": RESET}, "weekly": []}})
    self.assertEqual(len(partial["limits"]), 1)

  def test_invalid_percentages(self):
    for value in (True, False, "50", None, -1, 101, float("nan"), float("inf"), -float("inf")):
      with self.subTest(percent=value):
        result = self.probe({"usage": {"rolling": {"percent": value, "resetsAt": RESET}}})
        self.assertFalse(result["ok"])
        self.assertEqual(result["limits"], [])

  def test_invalid_reset_timestamps(self):
    for value in (None, "", " ", "not-a-date", "2026-99-99T12:00:00Z", 123, [], True, "2026-10-13"):
      with self.subTest(reset=value):
        result = self.probe({"usage": {"rolling": {"percent": 20, "resetsAt": value}}})
        self.assertFalse(result["ok"])

  def test_malformed_payload_shapes(self):
    for payload in (None, [], 42, "text", {}, {"usage": []}, {"usage": {"rolling": None}}):
      with self.subTest(payload=payload):
        result = self.probe(payload)
        self.assertFalse(result["ok"])
        self.assertEqual(result["limits"], [])

  def test_http_auth_network_and_json_errors_do_not_leak_keys(self):
    for error in (
      urllib.error.HTTPError(collector.USAGE_URL, 401, KEY, {}, None),
      urllib.error.HTTPError(collector.USAGE_URL, 403, KEY, {}, None),
      urllib.error.HTTPError(collector.USAGE_URL, 500, KEY, {}, None),
      urllib.error.URLError(f"failed request {KEY}"), OSError(KEY),
    ):
      if isinstance(error, urllib.error.HTTPError):
        self.addCleanup(error.close)
      with self.subTest(error=type(error).__name__), \
          patch.object(collector.urllib.request, "urlopen", side_effect=error):
        result = collector.probe_limits(KEY)
        self.assertFalse(result["ok"])
        self.assertEqual(bool(result.get("retryAdvised")), getattr(error, "code", None) not in (401, 403))
        self.assertNotIn(KEY, json.dumps(result))
    with patch.object(collector.urllib.request, "urlopen", return_value=contextlib.closing(io.BytesIO(b"not json"))):
      self.assertFalse(collector.probe_limits(KEY)["ok"])

  def test_incomplete_response_retains_local_stats_without_leaking(self):
    class BrokenResponse(io.BytesIO):
      def read(self):
        raise http.client.IncompleteRead(b"synthetic-secret-response " + KEY.encode(), 100)
    output, errors = io.StringIO(), io.StringIO()
    stats = {"totalPrompts": 7, "todayTotalTokens": 123}
    with patch.object(collector.urllib.request, "urlopen", return_value=BrokenResponse()), \
        patch.object(collector, "scan_opencode_stats", return_value=stats), \
        patch.object(collector, "scan_pi_usage", return_value=None), \
        patch.dict(os.environ, {"OPENCODE_GO_API_KEY": KEY}), \
        patch.object(sys, "argv", ["collector", "--force"]), \
        contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
      self.assertEqual(collector.main(), 0)
    record = json.loads(output.getvalue())
    self.assertEqual(record["totalPrompts"], 7)
    self.assertEqual(record["todayTotalTokens"], 123)
    self.assertEqual(record["limits"], [])
    self.assertTrue(record["retryAdvised"])
    self.assertEqual(record["authHelpText"], "OpenCode Go usage endpoint error: request failed")
    self.assertNotIn(KEY, output.getvalue() + errors.getvalue())
    self.assertNotIn("synthetic-secret-response", output.getvalue() + errors.getvalue())
    self.assertEqual(errors.getvalue(), "")

  def test_key_sources_missing_auth_and_neutral_tier(self):
    self.assertEqual(collector.api_key(), "")
    self.assertEqual(collector.probe_limits("")["limits"], [])
    auth = self.home / "data/opencode/auth.json"
    auth.parent.mkdir(parents=True)
    for value in ([], None, {"opencode-go": {"key": 123}}):
      auth.write_text(json.dumps(value))
      self.assertEqual(collector.api_key(), "")
    auth.write_text(json.dumps({"opencode-go": {"key": KEY}}))
    self.assertEqual(collector.api_key(), KEY)
    with patch.dict(os.environ, {"OPENCODE_GO_API_KEY": "environment-test-key"}):
      self.assertEqual(collector.api_key(), "environment-test-key")
    output = io.StringIO()
    with patch.object(sys, "argv", ["collector", "--limits-only"]), \
        patch.object(collector, "probe_limits", return_value={"ok": True, "limits": [], "usageStatusText": "", "authHelpText": ""}), \
        contextlib.redirect_stdout(output):
      collector.main()
    record = json.loads(output.getvalue())
    self.assertEqual(record["tierLabel"], "")  # Endpoint does not identify Go vs Go Plus.
    self.assertNotEqual(record.get("scope"), "account")  # Token stats are machine-local.
    self.assertNotIn(KEY, output.getvalue())


unittest.main(argv=[sys.argv[0]], verbosity=2)
PY
pass "OpenCode Go validates mocked account limits without disclosing credentials"
