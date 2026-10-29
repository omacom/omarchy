#!/bin/bash

# The Kimi collector's own sources: the key in KIMI_API_KEY or the sign-in the
# Kimi CLI keeps (refreshed under the CLI's own lock), the hosts a token may
# go to, and Kimi's quota answers. Kimi Code's local stats are held by
# agent-usage-kimi-stats-test.sh, the unused-machine record centrally by the
# partition test, and the limits cache by the contract checks.
#
# Each case runs in a fresh sandbox against a real stand-in for Kimi's
# services, which every https:// request is carried to. Set
# OMARCHY_TEST_KIMI_CASE to run one case.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
import stat
from http.server import BaseHTTPRequestHandler

from agent_usage_fixtures import *

state = {}
# A day out, so the window is still open whenever the test runs.
RESET_AT = (datetime.now(timezone.utc) + timedelta(days=1)).strftime("%Y-%m-%dT%H:%M:%SZ")
PAYLOAD = {"usages": {"limit_5h": {"used_ratio": 0.25, "reset_time": RESET_AT},
                      "limit_7d": {"used_ratio": "0.8"}, "limit_month_total": {"used_ratio": 1},
                      "limit_month_code": {"used_ratio": 0}}}


# Kimi's usage service (GET) and its login service (POST), as state says.
class Handler(BaseHTTPRequestHandler):
  def reply(self, status, data):
    self.send_response(status)
    self.end_headers()
    self.wfile.write(json.dumps(data).encode())

  def do_GET(self):
    if state.get("redirect"):
      self.send_response(302)
      self.send_header("Location", "/sink")
      self.end_headers()
    else:
      self.reply(state.get("usage_status", 200), state.get("payload", PAYLOAD))

  def do_POST(self):
    self.rfile.read(int(self.headers["Content-Length"]))
    if state.get("token_hook"):
      state["token_hook"]()
    if state.get("entered"):
      state["entered"].set()
    time.sleep(state.get("delay", 0))
    if state.get("token_status"):
      self.reply(state["token_status"], {"error_description": "Echo RT_old"})
    else:
      self.reply(200, state.get("grant", {"access_token": "AT_new", "refresh_token": "RT_new", "expires_in": 3600}))


LOCAL_URL, reqs = stub_server(Handler, tls=True)


def auth_header():
  return reqs[-1]["headers"].get("Authorization") if reqs else None


def credentials(token="AT_old", expiry=None):
  path = scanner.CREDENTIALS_PATH
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text(json.dumps({"access_token": token, "refresh_token": "RT_old",
                              "expires_at": time.time() - 10 if expiry is None else expiry}))


def record():
  return run_main(scanner, "--force", "--limits-only")


# ----------------------------------------------------------------- contract

@contextlib.contextmanager
def serve(mode):
  if mode in ("down", "timeout", "cut", "garbage"):
    with FakeHttp(mode=mode):
      yield
    return
  state["usage_status"] = 200 if mode == "up" else mode
  yield


def contract(root):
  check_limits_contract(Adapter("kimi", plant=lambda: os.environ.update(KIMI_API_KEY="AT_env"), serve=serve, count=lambda: len(reqs)))


# -------------------------------------------------------------- credentials

def env_key(root):
  credentials("AT_file", time.time() + 3600)
  os.environ["KIMI_API_KEY"] = "kimi_env"
  expect("KIMI_API_KEY wins over the stored sign-in", [scanner.api_key(), len(reqs)], ["kimi_env", 0])


def stores(root):
  del os.environ["KIMI_CODE_HOME"]
  legacy = home() / ".kimi" / "credentials"
  write_json(legacy / "kimi-code.json", {})
  expect("the legacy kimi-cli store is the fallback", load_collector("kimi").credentials_dir(), legacy)
  write_json(home() / ".kimi-code" / "credentials" / "kimi-code.json", {})
  expect("the kimi-code store wins over the legacy one", load_collector("kimi").credentials_dir(), home() / ".kimi-code" / "credentials")


# kimi-cli keeps its sign-in under KIMI_SHARE_DIR when that is set
# (kimi_cli/share.py), refreshed under the file lock beside it.
def share_dir(root):
  del os.environ["KIMI_CODE_HOME"]
  share = root / "share dir"
  os.environ["KIMI_SHARE_DIR"] = str(share)
  try:
    write_json(share / "credentials" / "kimi-code.json", {"access_token": "AT_old", "refresh_token": "RT_old", "expires_at": time.time() - 10})
    expect("the legacy kimi-cli store follows KIMI_SHARE_DIR", load_collector("kimi").credentials_dir(), share / "credentials")
    scanner = load_collector("kimi")
    token = scanner.api_key()
    expect("a KIMI_SHARE_DIR sign-in is refreshed under its own file lock",
           [token, (share / "credentials" / "kimi-code.lock").is_file(), (share / "oauth").exists()], ["AT_new", True, False])
  finally:
    del os.environ["KIMI_SHARE_DIR"]


def home_isolation(root):
  default = home() / ".kimi-code" / "credentials"
  default.mkdir(parents=True)
  (default / "kimi-code.json").write_text("{}")
  expect("an explicit KIMI_CODE_HOME never falls back to another account", scanner.credentials_dir(), root / "code home" / "credentials")


def static_token(root):
  credentials("AT_fresh", time.time() + 3600)
  expect("a fresh token is used as it is", [scanner.api_key(), len(reqs)], ["AT_fresh", 0])
  credentials("AT_static", 0)
  expect("a token that never expires is never refreshed", [scanner.api_key(), len(reqs)], ["AT_static", 0])


def refresh(root):
  credentials()
  data = record()
  persisted = json.loads(scanner.CREDENTIALS_PATH.read_text())
  expect("a lapsed token is refreshed, and the usage asked with the new one",
         [[request["method"] + " " + request["path"] for request in reqs], auth_header(), bool(data["limits"])],
         [["POST /api/oauth/token", "GET /coding/v1/usages"], "Bearer AT_new", True], data)
  expect("the rotated single-use refresh token is kept", [persisted["access_token"], persisted["refresh_token"]], ["AT_new", "RT_new"], persisted)


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
  expect("the collector waits out the Kimi CLI's refresh lock and takes its token", [token, len(reqs)], ["AT_peer", 0])


def stale_lock(root):
  credentials()
  lock = root / "code home" / "oauth" / "kimi-code.lock"
  lock.mkdir(parents=True)
  os.utime(lock, (0, 0))
  started = time.monotonic()
  token = scanner.api_key()
  expect("a lease left by a CLI that died is taken over, not waited out",
         [token, time.monotonic() - started < 5, lock.exists()], ["AT_new", True, False])


def lock_failure(root):
  credentials()
  (root / "code home" / "oauth").write_text("blocked")
  try:
    scanner.api_key()
    refused = False
  except (scanner.KimiError, OSError):
    refused = True
  expect("no lock, no refresh, and nothing posted", [refused, len(reqs)], [True, 0])


def heartbeat(root):
  credentials()
  state.update(delay=6, entered=threading.Event())
  outcome = []
  lock = root / "code home" / "oauth" / "kimi-code.lock"

  def refresh():
    try:
      outcome.append(scanner.api_key())
    except Exception as error:
      outcome.append(error)

  thread = threading.Thread(target=refresh)
  thread.start()
  try:
    check("the refresh request arrives", state["entered"].wait(2))
    time.sleep(5.2)
    check("the CLI lock is renewed through a slow refresh", lock.is_dir() and time.time() - lock.stat().st_mtime < 3)
  finally:
    thread.join()
  expect("a slow refresh succeeds and lets go of its lease", [outcome, lock.exists()], [["AT_new"], False])


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
  expect("a credential write never follows a predictable temporary symlink", victim.read_text(), "untouched")
  check("credentials are private and flushed before they replace the old ones", modes == [0o600] and synced, f"modes {modes}, synced {synced}")
  expect("the credential directory and file are private",
         [stat.S_IMODE(scanner.CREDENTIALS_DIR.stat().st_mode), stat.S_IMODE(scanner.CREDENTIALS_PATH.stat().st_mode)], [0o700, 0o600])


def concurrent_signin(root):
  credentials()
  state["token_hook"] = lambda: credentials("AT_signed_in", time.time() + 3600)
  data = record()
  expect("a refresh never overwrites a sign-in made meanwhile, and the usage asks for the new account",
         [data["ready"], json.loads(scanner.CREDENTIALS_PATH.read_text())["access_token"], auth_header()], [True, "AT_signed_in", "Bearer AT_signed_in"], data)


def concurrent_logout(root):
  credentials()
  state["token_hook"] = scanner.CREDENTIALS_PATH.unlink
  data = record()
  expect("a refresh never restores an account signed out meanwhile, which then waits for a sign-in",
         [scanner.CREDENTIALS_PATH.exists(), data["usageStatusText"]], [False, "Waiting for auth"], data)


def invalid_grant(root):
  for grant in ({"access_token": "AT_new", "expires_in": 3600},
                {"access_token": True, "refresh_token": "RT_new", "expires_in": 3600},
                {"access_token": "AT_new", "refresh_token": "RT_new", "expires_in": 0}):
    credentials()
    before = scanner.CREDENTIALS_PATH.read_text()
    state["grant"] = grant
    data = record()
    expect(f"an invalid grant is refused and keeps the usable credentials ({json.dumps(grant)})",
           [data["usageStatusText"], data["limits"], scanner.CREDENTIALS_PATH.read_text() == before], ["Kimi limits unavailable", [], True], data)


def refused_refresh(root):
  credentials()
  state["token_status"] = 401
  data = record()
  expect("a lapsed refresh token asks for a sign-in", data["usageStatusText"], "Sign-in expired", data)
  check("a refused refresh never publishes a token", "RT_old" not in json.dumps(data), data)


def key_help(root):
  os.environ["KIMI_API_KEY"] = "AT_invalid"
  state["usage_status"] = 401
  data = record()
  # AUTH_HELP names KIMI_API_KEY too, so the check is for this remedy's own words.
  expect("a refused KIMI_API_KEY says to change it, which a login can't", data["authHelpText"], "Kimi rejected the credentials. Update or unset KIMI_API_KEY.", data)


def refused(root):
  credentials("AT_live", time.time() + 3600)
  good = record()
  state["usage_status"] = 401
  data = record()
  expect("a refused sign-in says so beside the last good limits, kept stale",
         [data["usageStatusText"], data["authHelpText"], data["limits"] == good["limits"], data["limitsStale"]],
         ["Sign-in expired", "Kimi rejected the credentials. Sign in again with `kimi login`.", True, True], data)


def waiting_for_auth(root):
  (root / "code home").mkdir()
  data = run_main(scanner)
  expect("a Kimi home without a sign-in waits for one, asking nothing",
         [data["ready"], data["usageStatusText"], "kimi login" in data["authHelpText"], len(reqs)], [True, "Waiting for auth", True, 0], data)


# ------------------------------------------------------------ where tokens go

def trust(root):
  try:
    scanner.trusted_url("http://evil.example.com/usages")
    refused = False
  except scanner.KimiError:
    refused = True
  expect("plain HTTP is refused off loopback", refused, True)
  expect("loopback HTTP is allowed but sent no token", scanner.trusted_url("http://127.0.0.1:9000/usages")[1], False)
  expect("kimi.com is trusted with a token", scanner.trusted_url("https://api.kimi.com/coding/v1/usages")[1], True)
  expect("a domain merely ending in kimi.com is sent no token", scanner.trusted_url("https://evilkimi.com/x")[1], False)


def destination(root):
  for where, url in (("another domain", "https://outside.example/api/oauth/token"), ("loopback", LOCAL_URL + "/api/oauth/token")):
    scanner.TOKEN_URL = url
    try:
      scanner.request_refresh("RT_old")
      accepted = True
    except scanner.KimiError:
      accepted = False
    expect(f"a refresh token never goes to an untrusted destination ({where})", [accepted, len(reqs)], [False, 0])


def redirects(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  state["redirect"] = True
  data = record()
  expect("the usage request never follows a redirect",
         [data["usageStatusText"], data["limits"], [request["path"] for request in reqs]], ["Kimi limits unavailable", [], ["/coding/v1/usages"]], data)


# ------------------------------------------------------------------ the answer

def modern_quota(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  data = record()
  expect("the current CLI's quota windows are read, the monthly code allowance titled",
         [[row["percent"] for row in data["limits"]], data["limits"][0]["resetsAt"], data["limits"][-1].get("title")],
         [[0.25, 0.8, 1, 0], RESET_AT, "Code Monthly"], data)
  expect("Kimi's quota is this machine's record, with no local stats while no session has run",
         [data.get("scope"), data["hasLocalStats"], data["hasPromptStats"]], [None, False, True], data)
  scanner.USAGE_URL = "https://api.kimi.ai/coding/v1/usages"
  record()
  expect("the global Kimi service gets the authorization header too", auth_header(), "Bearer AT_env")


def legacy_quota(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  state["payload"] = {
    "usage": {"limit": 100, "used": 33, "reset_at": "2026-08-23T11:52:13.042087123Z"},
    "limits": [
      {"window": {"duration": 300, "timeUnit": "MINUTES"}, "detail": {"limit": 50, "remaining": 17, "reset_at": "2026-08-17T16:52:13Z"}},
      {"window": {"duration": 7, "timeUnit": "DAYS"}, "detail": {"name": "Weekly quota", "limit": 200, "used": 50}},
      {"window": {"duration": 0}, "detail": {"limit": 0, "used": 0}},
    ],
  }
  data = record()
  # Used comes from remaining when only that is given, nanosecond stamps are
  # trimmed, and a window without a limit is no window.
  expect("the earlier quota answer reads its weekly limit and windows", data["limits"], [
    {"label": "Weekly limit", "percent": 0.33, "resetsAt": "2026-08-23T11:52:13.042087Z"},
    {"label": "Session (5-hour)", "percent": 0.66, "resetsAt": "2026-08-17T16:52:13Z"},
    {"label": "Weekly quota", "percent": 0.25, "resetsAt": ""}], data)


def odd_resets(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  odd = ("garbage", "2030-13-45", "99999999999999999999999", "9" * 5000, "-5", "1e10", True, [1])
  for value in odd:
    state["payload"] = {"usages": {"limit_5h": {"used_ratio": 0.5, "reset_time": value}}}
    data = record()
    expect(f"a reset time that won't parse names no reset ({str(value)[:30]})", [row["resetsAt"] for row in data["limits"]], [""], data)


# ------------------------------------------------------------------ the cache

def cache_identity(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  check("a probe keeps limits", record()["limits"])
  os.environ["KIMI_API_KEY"] = "AT_other_account"
  state["usage_status"] = 503
  expect("another key never falls back on this one's limits", record()["limits"], [])


def rotated_cache(root):
  credentials("AT_old", time.time() + 3600)
  good = record()
  credentials()
  state["usage_status"] = 503
  first = record()
  second = record()
  expect("a refresh that rotates the token keeps the last good limits, stale",
         [first["limits"] == good["limits"], second["limits"] == good["limits"], first["limitsStale"], first["limitsFetchedAt"] == good["limitsFetchedAt"]],
         [True, True, True, True], first)


def empty_answer(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  state["payload"] = {"usages": {}}
  first = record()
  second = run_main(scanner, "--limits-only")
  expect("an answer without windows stands in for the next probe",
         [first["limits"], second["limits"], second["usageStatusText"], len(reqs)], [[], [], "", 1], second)


def odd_answer(root):
  os.environ["KIMI_API_KEY"] = "AT_env"
  good = record()
  state["payload"] = {"something": "else"}
  data = record()
  expect("an answer of another shape keeps the last good limits, stale",
         [data["limits"] == good["limits"], data["limitsStale"], data["limitsFetchedAt"] == good["limitsFetchedAt"], data.get("retryAdvised")],
         [True, True, True, None], data)
  expect("an answer of another shape never replaces the cached one", run_main(scanner, "--limits-only")["limits"], good["limits"])


def switched_cache(root):
  credentials("AT_account_a", time.time() + 3600)
  capture = scanner.api_key

  def switched(*args, **kwargs):
    key = capture(*args, **kwargs)
    credentials("AT_account_b", time.time() + 3600)
    return key

  scanner.api_key = switched
  check("a probe across a sign-in change still answers", record()["limits"])
  scanner.api_key = capture
  state["usage_status"] = 503
  expect("an answer is never kept under a token it wasn't asked with", record()["limits"], [])


cases = {"contract": contract, "env_key": env_key, "stores": stores, "share_dir": share_dir, "home": home_isolation, "static": static_token,
         "refresh": refresh, "cli_lock": cli_lock, "stale_lock": stale_lock,"lock_failure": lock_failure, "heartbeat": heartbeat,
         "private_write": private_write, "concurrent_signin": concurrent_signin, "concurrent_logout": concurrent_logout,
         "invalid_grant": invalid_grant, "refused_refresh": refused_refresh, "key_help": key_help, "refused": refused,
         "waiting_for_auth": waiting_for_auth, "trust": trust, "destination": destination, "redirects": redirects,
         "quota": modern_quota, "legacy_quota": legacy_quota, "cache_identity": cache_identity,
         "rotation_cache": rotated_cache, "switched_cache": switched_cache, "empty_answer": empty_answer,
         "odd_answer": odd_answer, "odd_resets": odd_resets}
selected = os.environ.get("OMARCHY_TEST_KIMI_CASE")
for name, case in cases.items():
  if selected and name != selected:
    continue
  reqs.clear()
  state.clear()
  # A home and a Kimi home with spaces in their names, as people have them.
  root = Path(tempfile.mkdtemp(prefix="kimi with spaces.", dir=os.environ["SANDBOX"]))
  sandbox(root)
  os.environ["KIMI_CODE_HOME"] = str(root / "code home")
  scanner = load_collector("kimi")
  case(root)
PY
