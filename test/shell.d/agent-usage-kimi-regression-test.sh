#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - "$ROOT/bin/omarchy-agent-usage-kimi" <<'PY'
import contextlib
import importlib.machinery
import importlib.util
import io
import json
import os
import stat
import sys
import tempfile
import threading
import time
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from datetime import datetime, timedelta, timezone
from pathlib import Path

requests = []
state = {}
# A day out, so the window is still open whenever the test runs.
RESET_AT = (datetime.now(timezone.utc) + timedelta(days=1)).strftime("%Y-%m-%dT%H:%M:%SZ")
payload = {"usages": {"limit_5h": {"used_ratio": 0.25, "reset_time": RESET_AT},
                      "limit_7d": {"used_ratio": "0.8"}, "limit_month_total": {"used_ratio": 1},
                      "limit_month_code": {"used_ratio": 0}}}

class Handler(BaseHTTPRequestHandler):
  def log_message(self, *args):
    pass

  def reply(self, status, data):
    self.send_response(status)
    self.end_headers()
    self.wfile.write(json.dumps(data).encode())

  def do_GET(self):
    requests.append((self.path, self.headers.get("Authorization"), None))
    if state.get("drop"):
      # Hang up without an answer, the way an unreachable network looks.
      self.close_connection = True
      self.connection.shutdown(2)
    elif state.get("redirect"):
      self.send_response(302)
      self.send_header("Location", "/sink")
      self.end_headers()
    else:
      self.reply(state.get("usage_status", 200), payload)

  def do_POST(self):
    body = self.rfile.read(int(self.headers["Content-Length"])).decode()
    requests.append((self.path, None, urllib.parse.parse_qs(body)))
    if state.get("token_hook"):
      state["token_hook"]()
    if state.get("entered"):
      state["entered"].set()
    time.sleep(state.get("delay", 0))
    if state.get("token_status"):
      self.reply(state["token_status"], {"error_description": "Echo RT_old"})
    else:
      self.reply(200, state.get("grant", {"access_token": "AT_new", "refresh_token": "RT_new", "expires_in": 3600}))

def run(*flags):
  saved = sys.argv
  sys.argv = [saved[1], *flags]
  output = io.StringIO()
  try:
    with contextlib.redirect_stdout(output):
      assert scanner.main() == 0
  finally:
    sys.argv = saved
  return json.loads(output.getvalue())

server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
threading.Thread(target=server.serve_forever, daemon=True).start()
local_url = f"http://127.0.0.1:{server.server_port}"
real_opener = urllib.request.build_opener

# Hands the fixture's answer back unprocessed, so a redirect or an error
# status is handled by the collector's own opener, not this one.
class PassThrough(urllib.request.HTTPErrorProcessor):
  def http_response(self, request, response):
    return response

# Keep real urllib request/redirect behavior; only TLS transport goes to the fixture.
class LocalTLS(urllib.request.HTTPSHandler):
  def https_open(self, request):
    mapped = urllib.request.Request(local_url + urllib.parse.urlsplit(request.full_url).path,
                                   data=request.data, headers=dict(request.header_items()), method=request.get_method())
    return real_opener(PassThrough()).open(mapped, timeout=10)

# The shared module installs its redirect-refusing opener with build_opener
# when the first collector imports it, so the fixture's transport rides in it.
urllib.request.build_opener = lambda *handlers: real_opener(LocalTLS(), *handlers)

def load(root):
  for key in list(os.environ):
    if key.startswith("KIMI_"):
      del os.environ[key]
  os.environ.update(HOME=str(root / "home with spaces"), KIMI_CODE_HOME=str(root / "code home"),
                    XDG_CACHE_HOME=str(root / "cache"))
  loader = importlib.machinery.SourceFileLoader("kimi_regression", sys.argv[1])
  spec = importlib.util.spec_from_loader(loader.name, loader)
  module = importlib.util.module_from_spec(spec)
  loader.exec_module(module)
  return module

def credentials(token="AT_old", expiry=None):
  path = scanner.CREDENTIALS_PATH
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text(json.dumps({"access_token": token, "refresh_token": "RT_old",
                             "expires_at": time.time() - 10 if expiry is None else expiry}))

def record():
  return run("--force", "--limits-only")

def destination(root):
  for url in ("https://outside.example/api/oauth/token", local_url + "/api/oauth/token"):
    scanner.TOKEN_URL = url
    try:
      scanner.request_refresh("RT_old")
    except scanner.KimiError:
      pass
    else:
      raise AssertionError("refresh accepted an untrusted destination")
  assert not requests, "refresh token reached an untrusted destination"

def home_isolation(root):
  default = Path.home() / ".kimi-code" / "credentials"
  default.mkdir(parents=True)
  (default / "kimi-code.json").write_text("{}")
  assert scanner.credentials_dir() == root / "code home" / "credentials", "explicit home fell back to another account"

def static_token(root):
  credentials("AT_static", 0)
  assert scanner.api_key() == "AT_static" and not requests, "non-expiring token was refreshed"

def cli_lock(root):
  credentials()
  lock = root / "code home" / "oauth" / "kimi-code.lock"
  lock.mkdir(parents=True)
  def peer():
    time.sleep(0.3)
    credentials("AT_peer", time.time() + 3600)
    lock.rmdir()
  thread = threading.Thread(target=peer)
  thread.start()
  try:
    token = scanner.api_key()
  finally:
    thread.join()
  assert token == "AT_peer" and not requests, "collector raced the current CLI's refresh lock"

def lock_failure(root):
  credentials()
  (root / "code home" / "oauth").write_text("blocked")
  try:
    scanner.api_key()
  except (scanner.KimiError, OSError):
    pass
  else:
    raise AssertionError("refresh continued without a lock")
  assert not requests, "refresh posted while lock acquisition failed"

def heartbeat(root):
  credentials()
  state.update(delay=6, entered=threading.Event())
  outcome = []
  def refresh():
    try:
      outcome.append(scanner.api_key())
    except Exception as error:
      outcome.append(error)
  thread = threading.Thread(target=refresh)
  thread.start()
  try:
    assert state["entered"].wait(2), "refresh request did not arrive"
    time.sleep(5.2)
    lock = root / "code home" / "oauth" / "kimi-code.lock"
    assert lock.is_dir() and time.time() - lock.stat().st_mtime < 3, "CLI lock expired during a slow refresh"
  finally:
    thread.join()
  assert outcome == ["AT_new"], "slow refresh failed"
  assert not lock.exists(), "refresh retained its directory lease"

def private_write(root):
  credentials()
  scanner.CREDENTIALS_DIR.chmod(0o777)
  victim = root / "unrelated-file"
  victim.write_text("untouched")
  scanner.CREDENTIALS_PATH.with_suffix(".json.tmp").symlink_to(victim)
  modes, synced = [], []
  fdopen, fsync = os.fdopen, os.fsync
  def private_open(fd, *args, **kwargs):
    modes.append(stat.S_IMODE(os.fstat(fd).st_mode))
    return fdopen(fd, *args, **kwargs)
  os.fdopen = private_open
  os.fsync = lambda fd: (synced.append(fd), fsync(fd))[1]
  try:
    scanner.write_credentials({"access_token": "AT_new", "refresh_token": "RT_new"})
  finally:
    os.fdopen, os.fsync = fdopen, fsync
  assert victim.read_text() == "untouched", "credential write followed a predictable temporary symlink"
  assert modes == [0o600] and synced, "credentials were not private and flushed before publication"
  assert stat.S_IMODE(scanner.CREDENTIALS_DIR.stat().st_mode) == 0o700
  assert stat.S_IMODE(scanner.CREDENTIALS_PATH.stat().st_mode) == 0o600

def modern_quota(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  data = record()
  assert [row["percent"] for row in data["limits"]] == [0.25, 0.8, 1, 0], "current CLI quota windows were dropped"
  assert data["limits"][0]["resetsAt"] == RESET_AT
  assert data["limits"][-1].get("title") == "Code Monthly", "monthly code allowance lost its scope"
  assert not data["hasLocalStats"] and not data["hasPromptStats"], "quota was advertised as local history"
  scanner.USAGE_URL = "https://api.kimi.ai/coding/v1/usages"
  record()
  assert requests[-1][1] == "Bearer AT_env", "global Kimi service lost its authorization header"

def stale_limits(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  good = record()
  state["usage_status"] = 503
  stale = record()
  assert good["limits"] and stale["limits"] == good["limits"], "failed probe hid the provider"
  assert stale["limitsStale"] and stale["limitsFetchedAt"] == good["limitsFetchedAt"]
  assert stale["usageStatusText"] == "" and "retryAdvised" not in stale, "kept limits were flagged as trouble"
  os.environ["KIMI_API_KEY"] = "AT_other_account"
  assert record()["limits"] == [], "cached quota crossed credential identities"

def rotated_cache(root):
  credentials("AT_old", time.time() + 3600)
  good = record()
  credentials()
  state["usage_status"] = 503
  first = record()
  second = record()
  assert first["limits"] == good["limits"] and second["limits"] == good["limits"], "rotation discarded last-good limits"
  assert first["limitsStale"] and first["limitsFetchedAt"] == good["limitsFetchedAt"]

def cache_identity(root):
  credentials("AT_account_a", time.time() + 3600)
  capture = scanner.api_key
  def switched(*args, **kwargs):
    key = capture(*args, **kwargs)
    credentials("AT_account_b", time.time() + 3600)
    return key
  scanner.api_key = switched
  assert record()["limits"]
  scanner.api_key = capture
  state["usage_status"] = 503
  assert record()["limits"] == [], "request quota was cached under a different token"

def concurrent_signin(root):
  credentials()
  state["token_hook"] = lambda: credentials("AT_signed_in", time.time() + 3600)
  assert record()["ready"]
  assert json.loads(scanner.CREDENTIALS_PATH.read_text())["access_token"] == "AT_signed_in", "refresh overwrote a completed sign-in"
  assert requests[-1][1] == "Bearer AT_signed_in", "usage ignored the newly signed-in account"

def concurrent_logout(root):
  credentials()
  state["token_hook"] = scanner.CREDENTIALS_PATH.unlink
  data = record()
  assert not scanner.CREDENTIALS_PATH.exists(), "refresh restored a signed-out account"
  assert data["usageStatusText"] == "Waiting for auth", "a signed-out home did not ask for a sign-in"

def invalid_grant(root):
  for grant in ({"access_token": "AT_new", "expires_in": 3600},
                {"access_token": True, "refresh_token": "RT_new", "expires_in": 3600},
                {"access_token": "AT_new", "refresh_token": "RT_new", "expires_in": 0}):
    credentials()
    before = scanner.CREDENTIALS_PATH.read_text()
    state["grant"] = grant
    data = record()
    assert data["usageStatusText"] == "Kimi limits unavailable" and not data["limits"], "invalid rotated token was accepted"
    assert scanner.CREDENTIALS_PATH.read_text() == before, "invalid grant replaced usable credentials"

def key_help(root):
  os.environ["KIMI_API_KEY"] = "AT_invalid"
  state["usage_status"] = 401
  assert "KIMI_API_KEY" in record()["authHelpText"], "login cannot repair an overriding API key"

def error_redaction(root):
  credentials()
  state["token_status"] = 401
  assert "RT_old" not in json.dumps(record()), "remote refresh error published a token"

def redirects(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  state["redirect"] = True
  data = record()
  assert data["usageStatusText"] == "Kimi limits unavailable" and not data["limits"]
  assert len(requests) == 1 and requests[0][0] == "/coding/v1/usages", "usage followed a redirect"

def unused(root):
  data = run()
  assert data["ready"] is False and data["usageStatusText"] == "" and data["authHelpText"] == "", "an unused machine was flagged"
  assert data["limits"] == [] and not requests, "an unused machine probed"
  today = datetime.now().astimezone().date()
  week = [{"date": (today - timedelta(days=offset)).isoformat(), "messageCount": 0} for offset in range(6, -1, -1)]
  assert data["recentDays"] == week, "an unused machine lacks the seven zeroed days ending today"

def waiting_for_auth(root):
  (root / "code home").mkdir()
  data = run()
  assert data["ready"] and data["usageStatusText"] == "Waiting for auth", "a home without a sign-in did not ask for one"
  assert "kimi login" in data["authHelpText"] and not requests

def refused(root):
  credentials("AT_live", time.time() + 3600)
  good = record()
  state["usage_status"] = 401
  data = record()
  assert data["usageStatusText"] == "Sign-in expired" and "kimi login" in data["authHelpText"], "a refused token read as healthy"
  assert data["limits"] == good["limits"] and data["limitsStale"], "a refused token hid the last good limits"

def refused_refresh(root):
  credentials()
  state["token_status"] = 401
  assert record()["usageStatusText"] == "Sign-in expired", "a lapsed refresh token did not ask for a sign-in"

def elapsed_window(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  path = scanner.limits_cache("AT_env").path
  path.write_text(json.dumps({"fetchedAtMs": 1_700_000_000_000, "limits": [
    {"label": "Session (5-hour)", "percent": 0.9, "resetsAt": "2020-01-01T00:00:00Z"},
    {"label": "Weekly limit", "percent": 0.4, "resetsAt": "2999-01-01T00:00:00Z"},
    {"label": "Monthly total", "percent": 0.2, "resetsAt": ""}]}))
  state["usage_status"] = 503
  data = record()
  assert data["limits"] == [
    {"label": "Session (5-hour)", "percent": 0.0, "resetsAt": ""},
    {"label": "Weekly limit", "percent": 0.4, "resetsAt": "2999-01-01T00:00:00Z"},
    {"label": "Monthly total", "percent": 0.2, "resetsAt": ""}], "an elapsed window was not zeroed"
  assert data["limitsStale"] and data["limitsFetchedAt"] == 1_700_000_000_000

def probe_reuse(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  first = run()
  second = run("--limits-only")
  assert len(requests) == 1 and second["limits"] == first["limits"], "a recent probe was not reused"
  assert second["limitsFetchedAt"] == first["limitsFetchedAt"] and not second["limitsStale"]
  cache = json.loads(scanner.limits_cache("AT_env").path.read_text())
  assert cache["fetchedAtMs"] == first["limitsFetchedAt"] and "fetchedAt" not in cache
  run("--force")
  assert len(requests) == 2, "--force reused a recent probe"
  assert sys.modules["collectors"].PROBE_MIN_INTERVAL_SECONDS == 15

def unreachable(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  good = record()
  state["drop"] = True
  data = record()
  assert data.get("retryAdvised") is True, "an unreachable service did not ask for a retry"
  assert data["limits"] == good["limits"] and data["limitsStale"] and data["usageStatusText"] == ""
  state["drop"] = False
  state["usage_status"] = 500
  assert "retryAdvised" not in record(), "a server error asked for a retry"

cases = {"destination": destination, "home": home_isolation, "static": static_token,
         "cli_lock": cli_lock, "lock_failure": lock_failure, "heartbeat": heartbeat,
         "private_write": private_write, "quota": modern_quota, "stale": stale_limits,
         "rotation_cache": rotated_cache, "cache_identity": cache_identity,
         "concurrent_signin": concurrent_signin, "concurrent_logout": concurrent_logout,
         "invalid_grant": invalid_grant,
         "key_help": key_help, "redaction": error_redaction, "redirects": redirects,
         "unused": unused, "waiting_for_auth": waiting_for_auth, "refused": refused,
         "refused_refresh": refused_refresh, "elapsed_window": elapsed_window,
         "probe_reuse": probe_reuse, "unreachable": unreachable}
failed = False
for name, check in cases.items():
  selected = os.environ.get("OMARCHY_TEST_KIMI_CASE")
  if selected and name != selected:
    continue
  requests.clear()
  state.clear()
  with tempfile.TemporaryDirectory(prefix="omarchy-kimi-regression-") as directory:
    scanner = load(Path(directory))
    try:
      check(Path(directory))
      print(f"ok - Kimi {name}", flush=True)
    except Exception as error:
      print(f"not ok - Kimi {name}: {error}", flush=True)
      failed = True
server.shutdown()
raise SystemExit(1 if failed else 0)
PY
