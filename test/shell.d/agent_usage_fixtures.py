"""Fixtures the agent usage collector tests share.

Imported from a test's Python heredoc once `agent_sandbox` (in
agent-usage-helpers.sh) has put this directory on PYTHONPATH:

  from agent_usage_fixtures import *

Everything here builds a machine for a collector to read, runs the collector,
or holds its record to the collector contract (docs/agent-usage-collectors.md).
The contract checks drive a collector through main() and assert on the record
it prints, so every collector is held to the same field names.

Files are found through ROOT and OMARCHY_PATH, which base-test.sh exports;
never through this file's own location or HOME.
"""

from __future__ import annotations

import base64
import contextlib
import email.message
import glob
import http.client
import importlib.machinery
import importlib.util
import io
import json
import os
import sqlite3
import sys
import tempfile
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Callable

sys.dont_write_bytecode = True

ROOT = Path(os.environ["ROOT"])
OMARCHY_PATH = Path(os.environ["OMARCHY_PATH"])
sys.path.insert(0, str(OMARCHY_PATH / "shell" / "plugins" / "agents"))

# Variables a developer's own shell may carry that point a collector at a
# real credential or a real store. The sandbox drops every one of them, and
# any *_API_KEY, so a test only ever sees what it planted.
DEVELOPER_PREFIXES = (
  "AGY_", "ANTHROPIC_", "CLAUDE_", "CLOUD_CODE_", "CODEX_", "COPILOT_", "CURSOR_", "DEEPSEEK_",
  "DEVIN_", "DSH_", "FIREWORKS_", "GH_", "GITHUB_", "GROK_", "HERMES_", "KIMCHI_", "KIMI_",
  "MAVIS_", "MINIMAX_", "MISE_", "MMX_", "MUSE_", "OLLAMA_", "OPENAI_", "OPENCLAW_", "OPENCODE_", "OPENROUTER_",
  "PI_CODING_AGENT_", "QWEN_", "SYNTHETIC_", "VIBE_", "ZAI_", "ZHIPU",
)

# A request that slips past FakeHttp or a stub server goes to a port nothing
# listens on, never to a real service. Loopback stays direct for stub servers.
DEAD_PROXY = "http://127.0.0.1:9"


# ------------------------------------------------------------------ output


def check(description: str, condition: Any, detail: Any = "") -> None:
  """A TAP line: `ok - description`, or `not ok` and the detail on stderr,
  ending the test, as check() in agent-usage-shared-test.sh does."""
  if condition:
    print("ok - " + description, flush=True)
    return
  print("not ok - " + description, file=sys.stderr)
  if detail:
    print(detail if isinstance(detail, str) else json.dumps(detail, default=str), file=sys.stderr)
  sys.exit(1)


def expect(description: str, actual: Any, expected: Any, record: Any = None) -> None:
  """check() that actual == expected, printing both (and the record) when not."""
  detail = f"expected: {json.dumps(expected, default=str)}\nactual:   {json.dumps(actual, default=str)}"
  if record is not None:
    detail += "\nrecord:   " + json.dumps(record, default=str)
  check(description, actual == expected, detail)


# ----------------------------------------------------------------- sandbox


def sandbox(root: str | Path | None = None) -> Path:
  """Point HOME and every XDG directory under `root` (a new temporary
  directory when omitted) and drop the developer's agent variables. Returns
  the home, created with the usual directories in it."""
  if root is None:
    root = tempfile.mkdtemp(prefix="agent-usage.", dir=os.environ.get("SANDBOX") or None)
  root = Path(root)
  home = root / "home"
  for name in list(os.environ):
    if name.endswith("_API_KEY") or name.startswith(DEVELOPER_PREFIXES):
      del os.environ[name]
  os.environ.update(
    HOME=str(home),
    XDG_CONFIG_HOME=str(home / ".config"),
    XDG_DATA_HOME=str(home / ".local" / "share"),
    XDG_STATE_HOME=str(home / ".local" / "state"),
    XDG_CACHE_HOME=str(home / ".cache"),
    XDG_RUNTIME_DIR=str(home / ".run"),
    http_proxy=DEAD_PROXY, https_proxy=DEAD_PROXY, HTTP_PROXY=DEAD_PROXY, HTTPS_PROXY=DEAD_PROXY,
    no_proxy="127.0.0.1,localhost", NO_PROXY="127.0.0.1,localhost",
  )
  for path in (home / ".config", home / ".local" / "share", home / ".local" / "state", home / ".cache", home / ".run"):
    path.mkdir(parents=True, exist_ok=True)
  return home


def home() -> Path:
  return Path(os.environ["HOME"])


def data_home() -> Path:
  return Path(os.environ.get("XDG_DATA_HOME") or home() / ".local" / "share")


def config_home() -> Path:
  return Path(os.environ.get("XDG_CONFIG_HOME") or home() / ".config")


def state_home() -> Path:
  return Path(os.environ.get("XDG_STATE_HOME") or home() / ".local" / "state")


def cache_root() -> Path:
  """$XDG_CACHE_HOME/omarchy/agent-usage, where every collector caches."""
  import collectors
  return collectors.cache_root()


# -------------------------------------------------------------- collectors

_loaded = 0


def load_collector(agent_id: str) -> Any:
  """bin/omarchy-agent-usage-<id> as a fresh module. The shared module stays
  imported once, so anything patched on urllib reaches every load."""
  global _loaded
  _loaded += 1
  path = ROOT / "bin" / f"omarchy-agent-usage-{agent_id}"
  loader = importlib.machinery.SourceFileLoader(f"agent_usage_{agent_id.replace('-', '_')}_{_loaded}", str(path))
  spec = importlib.util.spec_from_loader(loader.name, loader)
  module = importlib.util.module_from_spec(spec)
  loader.exec_module(module)
  module.FIXTURE_ID = agent_id
  return module


def run_main(module: Any, *args: str) -> dict:
  """Run a loaded collector's main() with `args` and return the record it
  printed. A collector that exits non-zero or prints no record fails the test."""
  saved = sys.argv
  sys.argv = [f"omarchy-agent-usage-{module.FIXTURE_ID}", *args]
  output = io.StringIO()
  try:
    with contextlib.redirect_stdout(output):
      try:
        code = module.main()
      except SystemExit as exit_:
        code = exit_.code
  finally:
    sys.argv = saved
  lines = [line for line in output.getvalue().splitlines() if line.strip()]
  if code not in (None, 0) or not lines:
    check(f"{module.FIXTURE_ID} {' '.join(args)} prints a record", False, f"exit {code!r}, stdout {output.getvalue()!r}")
  return json.loads(lines[-1])


def collect(agent_id: str, *args: str) -> dict:
  """load_collector() and run_main() in one: a fresh module per run."""
  return run_main(load_collector(agent_id), *args)


# -------------------------------------------------------------------- http


class FakeResponse(io.BytesIO):
  def __init__(self, body: bytes, status: int = 200, url: str = "") -> None:
    super().__init__(body)
    self.status = self.code = status
    self.url = url
    self.headers = self.msg = email.message.Message()
    self.headers["Content-Type"] = "application/json"

  def getcode(self) -> int:
    return self.status

  def geturl(self) -> str:
    return self.url

  def info(self) -> email.message.Message:
    return self.headers


class _CutShort(FakeResponse):
  def read(self, *args: Any) -> bytes:
    raise http.client.IncompleteRead(b'{"cut', 64)


def _body(payload: Any) -> bytes:
  if isinstance(payload, bytes):
    return payload
  if isinstance(payload, str):
    return payload.encode()
  return json.dumps(payload).encode()


class FakeHttp:
  """Stands in for every urllib.request.urlopen call, the one door every
  collector request goes through (collectors.open_json included).

  `routes` maps a URL substring to the answer: a JSON-able payload, bytes or
  a str sent as is, an int answered as that HTTP status, an exception
  raised, or a callable taking the Request and returning any of those. The
  first route whose key is in the URL answers; one matching none is logged
  in `unrouted` and refused with 404.

  `mode` decides the whole service at once, ahead of the routes:
  "up" (the routes answer), "down" (no DNS: URLError), "timeout",
  "reset" (a connection reset), "cut" (a reply cut short), "garbage" (a body
  that isn't JSON), or an int status every request is refused with. Change
  it between runs with `http.mode = 500`.

  Every request lands in `requests` as {url, method, headers, data}.
  """

  def __init__(self, routes: dict | None = None, mode: Any = "up") -> None:
    self.routes = dict(routes or {})
    self.mode = mode
    self.requests: list[dict] = []
    self.unrouted: list[str] = []
    self._saved = None

  def __enter__(self) -> FakeHttp:
    return self.start()

  def __exit__(self, *exc: Any) -> None:
    self.stop()

  def start(self) -> FakeHttp:
    self._saved = urllib.request.urlopen
    urllib.request.urlopen = self.urlopen
    return self

  def stop(self) -> None:
    if self._saved is not None:
      urllib.request.urlopen = self._saved
      self._saved = None

  @property
  def count(self) -> int:
    return len(self.requests)

  @staticmethod
  def refusal(url: str, status: int, body: Any = b"", headers: dict | None = None) -> urllib.error.HTTPError:
    message = email.message.Message()
    for key, value in (headers or {}).items():
      message[key] = value
    return urllib.error.HTTPError(url, status, f"status {status}", message, io.BytesIO(_body(body)))

  def urlopen(self, request: Any, data: Any = None, timeout: Any = None, **_: Any) -> Any:
    if isinstance(request, str):
      request = urllib.request.Request(request, data=data)
    url = request.full_url
    self.requests.append({
      "url": url,
      "method": request.get_method(),
      "headers": {key.lower(): value for key, value in request.header_items()},
      "data": request.data,
    })
    mode = self.mode
    if mode == "down":
      raise urllib.error.URLError(OSError("Name or service not known"))
    if mode == "timeout":
      raise TimeoutError("timed out")
    if mode == "reset":
      raise ConnectionResetError("connection reset by peer")
    if mode == "cut":
      return _CutShort(b"", url=url)
    if mode == "garbage":
      return FakeResponse(b"<html>not json</html>", url=url)
    if isinstance(mode, int) and not isinstance(mode, bool):
      raise self.refusal(url, mode, {"error": "refused"})
    for key, answer in self.routes.items():
      if key in url:
        if callable(answer) and not isinstance(answer, type):
          answer = answer(request)
        if isinstance(answer, BaseException):
          raise answer
        if isinstance(answer, int) and not isinstance(answer, bool):
          raise self.refusal(url, answer, {"error": "refused"})
        return FakeResponse(_body(answer), url=url)
    self.unrouted.append(url)
    raise self.refusal(url, 404, {"error": "no route in the test"})


def stub_server(handler: Any, tls: bool = False) -> tuple[str, list]:
  """A real HTTP server on loopback, for a collector that must be driven
  over a socket: (base_url, requests).

  `handler` is a BaseHTTPRequestHandler subclass, or a function taking
  {method, path, headers, body} and returning a payload, (status, payload)
  or (status, payload, headers). Every request lands in `requests`.

  With `tls`, every https:// request any opener makes is carried to this
  server instead, so a collector keeps its own https URLs, redirect refusal
  and error handling, and only the transport is the fixture's.
  """
  from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

  requests: list[dict] = []

  if isinstance(handler, type):
    base = handler

    class Logged(base):  # type: ignore[valid-type, misc]
      def log_message(self, *args: Any) -> None:
        pass

      def parse_request(self) -> bool:
        parsed = super().parse_request()
        if parsed:
          requests.append({"method": self.command, "path": self.path, "headers": dict(self.headers), "body": None})
        return parsed
  else:
    answer = handler

    class Logged(BaseHTTPRequestHandler):  # type: ignore[no-redef]
      def log_message(self, *args: Any) -> None:
        pass

      def _serve(self) -> None:
        length = int(self.headers.get("Content-Length") or 0)
        body = self.rfile.read(length) if length else b""
        entry = {"method": self.command, "path": self.path, "headers": dict(self.headers), "body": body}
        requests.append(entry)
        result = answer(entry)
        status, payload, headers = 200, result, {}
        if isinstance(result, tuple):
          status, payload, *rest = result
          headers = rest[0] if rest else {}
        data = _body(payload)
        self.send_response(status)
        for key, value in headers.items():
          self.send_header(key, value)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

      do_GET = do_POST = do_PUT = do_DELETE = _serve

  server = ThreadingHTTPServer(("127.0.0.1", 0), Logged)
  threading.Thread(target=server.serve_forever, daemon=True).start()
  base_url = f"http://127.0.0.1:{server.server_port}"
  if tls:
    _route_tls_to(base_url)
  return base_url, requests


def _route_tls_to(base_url: str) -> None:
  real_opener = getattr(urllib.request, "_fixture_real_build_opener", urllib.request.build_opener)
  urllib.request._fixture_real_build_opener = real_opener

  # The fixture's answer goes back unprocessed, so a redirect or an error
  # status is handled by the collector's own opener, not this inner one.
  class PassThrough(urllib.request.HTTPErrorProcessor):
    def http_response(self, request: Any, response: Any) -> Any:
      return response

  class LocalTLS(urllib.request.HTTPSHandler):
    def https_open(self, request: Any) -> Any:
      split = urllib.parse.urlsplit(request.full_url)
      path = split.path + (f"?{split.query}" if split.query else "")
      mapped = urllib.request.Request(base_url + path, data=request.data, headers=dict(request.header_items()), method=request.get_method())
      return real_opener(PassThrough()).open(mapped, timeout=10)

  urllib.request.build_opener = lambda *handlers: real_opener(LocalTLS(), *handlers)
  # The shared module installs its redirect-refusing opener when it is first
  # imported; install it again so it carries the fixture transport.
  import collectors
  urllib.request.install_opener(urllib.request.build_opener(collectors._RefuseRedirects()))


# -------------------------------------------------------------------- time

_frozen_day = None


class _DayClock(datetime):
  """datetime whose now() runs as usual until local midnight past the frozen
  day, then stops at that day's last microsecond. freeze_today() hands it to
  the shared module."""

  @classmethod
  def now(cls, tz: Any = None) -> datetime:
    real = datetime.now(tz)
    if _frozen_day is None or datetime.now().date() <= _frozen_day:
      return real
    end = datetime.combine(_frozen_day, datetime.max.time()).astimezone()
    return end.astimezone(tz) if tz else end.replace(tzinfo=None)


def freeze_today() -> None:
  """Hold "today" to the local day it is now, for the rest of the process:
  the shared module's clock, and the rows the fixtures stamp "now"
  (pi_reply(), opencode rows, today_stamp()), run on as usual until local
  midnight and then stop at that day's last microsecond. A test that
  straddles midnight then dates every row and scan by the day it began;
  time.time(), and so every cache age, runs on. check_scan_cache freezes
  today itself; a test comparing today's totals across runs calls this first."""
  global _frozen_day
  import collectors
  if _frozen_day is None:
    _frozen_day = datetime.now().date()
  collectors.datetime = _DayClock


def fixture_now() -> datetime:
  """Now in UTC, held to the frozen day once freeze_today() has run."""
  return _DayClock.now(timezone.utc)


def iso_in(seconds: float) -> str:
  """An ISO UTC time `seconds` from now (negative for the past)."""
  return (datetime.now(timezone.utc) + timedelta(seconds=seconds)).isoformat()


def ms_in(seconds: float) -> int:
  """An epoch-millisecond stamp `seconds` from now."""
  return int((time.time() + seconds) * 1000)


def today_stamp(hour: int = 12) -> str:
  """An ISO time at `hour` today in local time, with its offset, so it lands
  on today whatever the machine's zone."""
  return fixture_now().astimezone().replace(hour=hour, minute=0, second=0, microsecond=0).isoformat()


def jwt(claims: dict) -> str:
  """An unsigned JWT carrying `claims`, as collectors read them."""
  body = base64.urlsafe_b64encode(json.dumps(claims).encode()).decode().rstrip("=")
  return f"header.{body}.signature"


# ------------------------------------------------------- pi/omp and opencode


def pi_reply(provider: str, tokens: int = 1, id: str | None = None, model: str = "m",
             timestamp: Any = "now", usage: dict | None = None, api: str | None = None) -> dict:
  """One pi/omp assistant line. `timestamp` defaults to now; pass None to
  leave it out."""
  message = {"role": "assistant", "provider": provider, "model": model, "usage": usage or {"input": tokens}}
  if api:
    message["api"] = api
  line: dict[str, Any] = {"type": "message", "message": message}
  if timestamp == "now":
    timestamp = fixture_now().isoformat(timespec="milliseconds").replace("+00:00", "Z")
  if timestamp is not None:
    line["timestamp"] = timestamp
  if id:
    line["id"] = id
  return line


def write_pi_session(path: str | Path, lines: list, parent: str | Path | None = None) -> Path:
  """A pi/omp session file; `parent` makes it a fork naming that session."""
  path = Path(path)
  path.parent.mkdir(parents=True, exist_ok=True)
  with path.open("w") as handle:
    if parent is not None:
      handle.write(json.dumps({"type": "session", "parentSession": str(parent)}) + "\n")
    for line in lines:
      handle.write((line if isinstance(line, str) else json.dumps(line)) + "\n")
  return path


def _oc_now() -> int:
  """An opencode row's default time, in ms on the fixtures' clock: a second
  ago, but never before today's local midnight."""
  now = fixture_now()
  midnight = now.astimezone().replace(hour=0, minute=0, second=0, microsecond=0)
  return int(max(now - timedelta(seconds=1), midnight).timestamp() * 1000)


def _oc_tokens(tokens: Any) -> dict:
  if isinstance(tokens, dict):
    return tokens
  return {"input": tokens, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}}


def oc_v1(provider: str, tokens: Any, model: str = "m", created: int | None = None, role: str = "assistant") -> str:
  """An opencode `message` row's data: provider and model at the top level."""
  return json.dumps({"role": role, "providerID": provider, "modelID": model, "tokens": _oc_tokens(tokens),
                     "time": {"created": _oc_now() if created is None else created}})


def oc_v2(provider: str, tokens: Any, model: str = "m", created: int | None = None) -> str:
  """An opencode V2 `session_message` row's data: the model nested."""
  return json.dumps({"model": {"providerID": provider, "id": model}, "tokens": _oc_tokens(tokens),
                     "time": {"created": _oc_now() if created is None else created}})


OC_TABLES = {
  "message": "CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)",
  "session_message": "CREATE TABLE session_message (id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL, time_created integer NOT NULL, data text NOT NULL)",
  "session_v2": "CREATE TABLE session_v2 (id text PRIMARY KEY, fork_session_id text, time_created integer NOT NULL)",
}


def opencode_db(path: str | Path | None = None, message=(), session_message=(), forks=(),
                tables=("message", "session_message", "session_v2")) -> Path:
  """opencode's database (the default one unless `path`), with the stores in
  `tables` and the rows oc_add() takes."""
  path = Path(path) if path else data_home() / "opencode" / "opencode.db"
  path.parent.mkdir(parents=True, exist_ok=True)
  conn = sqlite3.connect(path)
  for table in tables:
    conn.execute(OC_TABLES[table])
  conn.commit()
  conn.close()
  oc_add(path, message=message, session_message=session_message, forks=forks)
  return path


def oc_add(path: str | Path, message=(), session_message=(), forks=()) -> None:
  """Rows into an opencode database: `message` rows (id, session, data[,
  created_ms]), `session_message` rows (id, session, type, data[,
  created_ms]), and `forks` (session, source session, created_ms)."""
  conn = sqlite3.connect(path)
  now = _oc_now()
  for row in message:
    message_id, session, data, *created = row
    stamp = created[0] if created else now
    conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", (message_id, session, stamp, stamp, data))
  for row in session_message:
    message_id, session, kind, data, *created = row
    conn.execute("INSERT INTO session_message VALUES (?, ?, ?, ?, ?)", (message_id, session, kind, created[0] if created else now, data))
  for session, source, created in forks:
    conn.execute("INSERT INTO session_v2 VALUES (?, ?, ?)", (session, source, created))
  conn.commit()
  conn.close()


# ------------------------------------------------------------ Claude Code


def claude_code_session(name: str, replies: list, base_url: str | None = None) -> Path:
  """A Claude Code transcript under ~/.claude/projects: a typed prompt and its
  reply for each (model, input tokens) in `replies`, as Claude Code 2.1
  writes them. `base_url` sets ANTHROPIC_BASE_URL in Claude Code's settings,
  where pointing it at another provider is documented."""
  stamp = fixture_now().isoformat(timespec="milliseconds").replace("+00:00", "Z")
  lines = []
  for n, (model, tokens) in enumerate(replies):
    lines.append({"type": "user", "uuid": f"{name}-prompt-{n}", "sessionId": name, "timestamp": stamp, "message": {"role": "user", "content": "go"}})
    lines.append({"type": "assistant", "sessionId": name, "timestamp": stamp, "requestId": f"{name}-req-{n}",
                  "message": {"id": f"{name}-msg-{n}", "role": "assistant", "model": model, "usage": {"input_tokens": tokens, "output_tokens": 0}}})
  path = home() / ".claude" / "projects" / "project" / f"{name}.jsonl"
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(line) + "\n" for line in lines))
  if base_url is not None:
    _merge(home() / ".claude" / "settings.json", "env", {"ANTHROPIC_BASE_URL": base_url})
  return path


def mcode_routed_session(name, provider, model, tokens, base_url=None):
  """A MiniMax Code session with one prompt and its reply on `provider`, and,
  for a `custom_provider:<id>`, that provider declared at `base_url` in
  config.yaml, as `mcode provider add` writes it."""
  root = home() / ".minimax"
  session = root / "v2" / "sessions" / "2026" / "10" / "22" / name / "messages.jsonl"
  session.parent.mkdir(parents=True, exist_ok=True)
  session.write_text("".join(json.dumps(line) + "\n" for line in (
    {"message": {"role": "user", "timestamp": ms_in(0), "content": "go"}},
    {"message": {"role": "assistant", "timestamp": ms_in(0), "provider": provider, "model": model, "usage": {"input": tokens}}},
  )))
  if base_url is not None:
    config = root / "config.yaml"
    text = config.read_text() if config.exists() else "custom_provider:\n"
    pid = provider.partition(":")[2]
    config.write_text(text + f"  {pid}:\n    name: {pid}\n    kind: custom\n    options:\n      apiKey: sk-placeholder\n      baseURL: {base_url}\n")
  return session


# ------------------------------------------------------ credentials and state


def write_json(path: str | Path, data: Any) -> Path:
  path = Path(path)
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text(json.dumps(data))
  return path


def _merge(path: Path, key: str, value: Any) -> Path:
  try:
    data = json.loads(path.read_text())
  except (OSError, ValueError):
    data = {}
  data[key] = value
  return write_json(path, data)


def cursor_state_db(path: str | Path | None, token: str) -> Path:
  """The Cursor editor's state.vscdb holding `token` as its sign-in (the
  default place under XDG_CONFIG_HOME when `path` is None)."""
  path = Path(path) if path else config_home() / "Cursor" / "User" / "globalStorage" / "state.vscdb"
  path.parent.mkdir(parents=True, exist_ok=True)
  conn = sqlite3.connect(path)
  conn.execute("CREATE TABLE IF NOT EXISTS ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB)")
  conn.execute("INSERT INTO ItemTable VALUES ('cursorAuth/accessToken', ?)", (token,))
  conn.commit()
  conn.close()
  return path


def pi_auth(directory: str | Path | None, provider: str, key: str) -> Path:
  """A key pi (or omp) keeps from /login: <dir>/auth.json, ~/.pi/agent by
  default, merged with what is there."""
  directory = Path(directory) if directory else home() / ".pi" / "agent"
  return _merge(directory / "auth.json", provider, {"type": "api_key", "key": key})


def opencode_auth(path: str | Path | None, provider: str, key: str) -> Path:
  """A key opencode keeps: its auth.json under XDG_DATA_HOME by default."""
  path = Path(path) if path else data_home() / "opencode" / "auth.json"
  return _merge(path, provider, {"type": "api", "key": key})


def registry(agent_id: str, accounts: list, active: str | None = None, **switch: Any) -> Path:
  """The accounts `omarchy agent account` registered: each account a dict or
  an id; `switch` adds the registry's own settings (switch="auto",
  threshold=90)."""
  entries = [{"id": account} if isinstance(account, str) else account for account in accounts]
  data: dict[str, Any] = {"accounts": entries, **switch}
  if active is not None:
    data["active"] = active
  return write_json(state_home() / "omarchy" / "agents" / "accounts" / f"{agent_id}.json", data)


# ------------------------------------------------------------------ caches


def limits_cache_files(agent_id: str) -> list[Path]:
  """Every limits cache a collector keeps: <id>-limits*.json."""
  return sorted(Path(path) for path in glob.glob(str(cache_root() / f"{glob.escape(agent_id)}-limits*.json")))


def scan_cache_files(agent_id: str) -> list[Path]:
  return sorted(Path(path) for path in glob.glob(str(cache_root() / f"{glob.escape(agent_id)}-scan-*.json")))


def edit_limits_cache(agent_id: str, fetched_ago: float | None = None, resets_past: bool = False) -> list[Path]:
  """Rewrite every limits cache of `agent_id` in place: stamped `fetched_ago`
  seconds back, and with `resets_past` every window's reset an hour gone, as
  if the window elapsed while nothing ran. No sleeping."""
  files = limits_cache_files(agent_id)
  if not files:
    check(f"{agent_id} keeps a limits cache to edit", False, f"nothing under {cache_root()}")
  for path in files:
    data = json.loads(path.read_text())
    if fetched_ago is not None:
      data["fetchedAtMs"] = ms_in(-fetched_ago)
    if resets_past:
      for entry in data.get("limits") or []:
        if isinstance(entry, dict):
          entry["resetsAt"] = iso_in(-3600)
    path.write_text(json.dumps(data))
  return files


def age_scan_cache(target: str | Path, seconds: float) -> None:
  """Move a scan cache's stamp `seconds` into the past (negative: the future,
  a clock that went back). `target` is the file, or an agent id for all of
  its scans. Set `scanDate` with edit_scan_cache instead for another day."""
  edit_scan_cache(target, lambda data: data.update(scannedAtMs=int(data.get("scannedAtMs") or 0) - int(seconds * 1000)))


def edit_scan_cache(target: str | Path, change: Callable[[dict], Any]) -> None:
  files = [Path(target)] if Path(str(target)).is_file() else scan_cache_files(str(target))
  if not files:
    check(f"{target} has a scan cache to edit", False, f"nothing under {cache_root()}")
  for path in files:
    data = json.loads(path.read_text())
    change(data)
    path.write_text(json.dumps(data))


# -------------------------------------------------------- contract checks


def _default_measure(record: dict) -> tuple:
  return (record.get("totalPrompts"), record.get("totalSessions"), record.get("todayTotalTokens"))


@dataclass
class Adapter:
  """What the contract checks need to know about one collector.

  - `id`: the collector, bin/omarchy-agent-usage-<id>.
  - `plant()`: sign the sandbox in (a credential on disk or in os.environ),
    so a healthy service gives limits.
  - `answer`: FakeHttp routes for the healthy service. Its windows' resets
    must lie ahead, so a fresh answer reads as it was given.
  - `requests_per_probe`: requests one probe makes (credits and limits are 2).
  - `refused_status`: usageStatusText for a refused credential (401); None
    when the collector has no such answer.
  - `serve(mode)`: instead of FakeHttp, a context manager making the service
    behave as `mode` for the runs inside it: "up", 500 (a failed check),
    "cut" and "garbage" (an answer cut short, or not JSON), "down" and
    "timeout" (unreachable), 401 (refused). Pair it with
    `count()`, the requests (or CLI starts) made so far, or None when there
    is nothing to count.
  - `retry_modes`: the unreachable modes the service can take; () when it has
    no network at all.
  - `skip`: contract checks that can't apply, each with its reason beside the
    adapter: "reuse", "force", "stale", "cut", "retry", "elapsed", "refused".
  - `grow()`: one more unit of local usage on disk, for check_scan_cache;
    `measure(record)` what it changes (prompts, sessions, today's tokens).
  - `pi_root()`: for a collector reading pi-format sessions, the root it
    reads them from (~/.pi/agent/sessions, or a harness's own), so
    check_scan_cache can hold it to never caching a scan rg couldn't run.
  """

  id: str
  plant: Callable[[], Any] = lambda: None
  answer: Any = None
  requests_per_probe: int = 1
  refused_status: str | None = "Sign-in expired"
  serve: Callable[[Any], Any] | None = None
  count: Callable[[], int] | None = None
  retry_modes: tuple = ("down", "timeout")
  skip: tuple = ()
  grow: Callable[[], Any] | None = None
  measure: Callable[[dict], Any] = _default_measure
  pi_root: Callable[[], Path] | None = None


class _Service:
  """The adapter's service, FakeHttp unless it brings its own."""

  def __init__(self, adapter: Adapter) -> None:
    self.adapter = adapter
    self.http = None if adapter.serve else FakeHttp(adapter.answer or {})

  @contextlib.contextmanager
  def mode(self, mode: Any):
    if self.adapter.serve:
      with self.adapter.serve(mode):
        yield
    else:
      self.http.mode = mode
      with self.http:
        yield

  def count(self) -> int | None:
    if self.adapter.serve:
      return self.adapter.count() if self.adapter.count else None
    return self.http.count

  def run(self, mode: Any, *args: str) -> tuple[dict, int | None]:
    """The record a run prints under `mode`, and the requests it made."""
    with self.mode(mode):
      before = self.count()
      record = collect(self.adapter.id, *args)
      after = self.count()
    return record, None if before is None else after - before


def _windows(record: dict) -> list:
  return [(entry.get("percent"), entry.get("resetsAt")) for entry in record.get("limits") or []]


def check_limits_contract(adapter: Adapter) -> dict:
  """Hold a collector's limits to the contract, through main() and the record
  it prints:

  - fresh: --force asks the service once per probe, and prints live limits
    stamped with when they were measured, no status and no help.
  - reuse: a normal run and --limits-only right after ask nothing and print
    the same limits, live.
  - --force asks again.
  - stale: a failed check (500) keeps the last limits, stale, with their
    limitsFetchedAt, no status, and no retryAdvised.
  - cut: a reply cut short and a body that isn't JSON are answers, not
    transport: they keep the last limits, stale, and advise no retry.
  - retry: an unreachable service (down, timeout) keeps them too, and sets
    retryAdvised.
  - elapsed: kept windows whose reset passed (a cache rewrite, no sleeping)
    come back at 0 with no reset, reused or kept past a failed check.
  - refused: a refused credential (401) says `refused_status`, never presents
    the limits as live, and advises no retry.

  Returns the fresh record, for the collector's own reading of its answer.
  """
  name, skip = adapter.id, set(adapter.skip)
  for path in limits_cache_files(name):
    path.unlink()
  adapter.plant()
  service = _Service(adapter)
  per_probe = adapter.requests_per_probe

  fresh, asked = service.run("up", "--force")
  check(
    f"{name}: fresh limits are live, stamped, healthy, and asked for once per probe",
    fresh.get("ready") is True and fresh.get("limits") and fresh.get("limitsStale") is False and fresh.get("limitsFetchedAt", 0) > 0
    and fresh.get("usageStatusText") == "" and fresh.get("authHelpText") == "" and not fresh.get("retryAdvised")
    and asked in (None, per_probe),
    f"requests: {asked} (expected {per_probe})\nrecord: {json.dumps(fresh)}",
  )
  fetched_at = fresh["limitsFetchedAt"]

  if "reuse" not in skip:
    for args in ((), ("--limits-only",)):
      reused, asked = service.run(500, *args)
      check(
        f"{name}: a {'--limits-only' if args else 'normal'} run inside the probe interval reuses the answer, live",
        asked in (None, 0) and reused.get("limits") == fresh["limits"] and reused.get("limitsFetchedAt") == fetched_at
        and reused.get("limitsStale") is False and reused.get("usageStatusText") == "" and reused.get("authHelpText") == "",
        f"requests: {asked}\nfresh:  {json.dumps(fresh)}\nreused: {json.dumps(reused)}",
      )

  if "force" not in skip:
    forced, asked = service.run("up", "--force")
    check(f"{name}: --force asks again inside the probe interval", asked in (None, per_probe) and forced.get("limitsStale") is False,
          f"requests: {asked} (expected {per_probe})\nrecord: {json.dumps(forced)}")
    fetched_at = forced["limitsFetchedAt"]
    fresh = forced

  if "stale" not in skip:
    kept, _ = service.run(500, "--force")
    check(
      f"{name}: a failed check keeps the last limits, stale, with when they were measured",
      kept.get("limits") == fresh["limits"] and kept.get("limitsStale") is True and kept.get("limitsFetchedAt") == fetched_at
      and kept.get("usageStatusText") == "" and not kept.get("retryAdvised"),
      f"fresh: {json.dumps(fresh)}\nkept:  {json.dumps(kept)}",
    )

  if "cut" not in skip:
    for mode in ("cut", "garbage"):
      answered, _ = service.run(mode, "--force")
      check(
        f"{name}: an answer {'cut short' if mode == 'cut' else 'that is not JSON'} keeps the last limits, stale, and advises no retry",
        not answered.get("retryAdvised") and answered.get("limits") == fresh["limits"]
        and answered.get("limitsStale") is True and answered.get("limitsFetchedAt") == fetched_at
        and answered.get("usageStatusText") == "",
        f"fresh:    {json.dumps(fresh)}\nanswered: {json.dumps(answered)}",
      )

  if "retry" not in skip:
    for mode in adapter.retry_modes:
      unreachable, _ = service.run(mode, "--force")
      check(
        f"{name}: an unreachable service ({mode}) advises a retry and keeps the last limits, stale",
        unreachable.get("retryAdvised") is True and unreachable.get("limits") == fresh["limits"]
        and unreachable.get("limitsStale") is True and unreachable.get("limitsFetchedAt") == fetched_at
        and unreachable.get("usageStatusText") == "",
        json.dumps(unreachable),
      )

  if "elapsed" not in skip:
    edit_limits_cache(name, resets_past=True)
    zeroed = [(0.0, "")] * len(fresh["limits"])
    runs = [service.run(500, "--force")[0]]
    if "reuse" not in skip:
      runs.append(service.run(500)[0])
    check(
      f"{name}: kept windows whose reset passed read 0 with no reset, past a failed check{' and reused' if len(runs) > 1 else ''}",
      all(_windows(record) == zeroed for record in runs) and runs[0].get("limitsStale") is True,
      "\n".join(json.dumps(record) for record in runs),
    )
    service.run("up", "--force")

  if adapter.refused_status is not None and "refused" not in skip:
    refused, _ = service.run(401, "--force")
    check(
      f"{name}: a refused credential says {adapter.refused_status!r}, advises no retry, and shows nothing as live",
      refused.get("usageStatusText") == adapter.refused_status and not refused.get("retryAdvised")
      and (refused.get("limitsStale") is True or not refused.get("limits")),
      json.dumps(refused),
    )

  return fresh


def check_scan_cache(adapter: Adapter) -> None:
  """Hold a collector's local scan cache to the contract, by growing its
  usage on disk between runs and rewriting the cache's stamps (no sleeping):

  - a normal run reuses a scan for 20 seconds, --limits-only for 900, and
    --force never;
  - a scan from another day, or stamped in the future, is a miss;
  - with `pi_root`, a scan that couldn't read the pi sessions (no rg) serves
    its run but is never cached.
  """
  name = adapter.id
  if adapter.grow is None:
    check(f"{name}: the scan adapter says how to add usage (grow)", False)
  # Every run below must date its scan by one day, or a run straddling local
  # midnight misses a cache it should reuse.
  freeze_today()
  for path in scan_cache_files(name):
    path.unlink()
  adapter.plant()
  adapter.grow()
  service = _Service(adapter)

  def seen(*args: str) -> Any:
    return adapter.measure(service.run("up", *args)[0])

  base = seen("--force")
  adapter.grow()
  check(f"{name}: a normal run reuses a scan this recent", seen() == base)
  check(f"{name}: a --limits-only run reuses a scan this recent", seen("--limits-only") == base)
  forced = seen("--force")
  check(f"{name}: --force scans again", forced != base, f"{base} -> {forced}")

  adapter.grow()
  age_scan_cache(name, 60)
  limits_only = seen("--limits-only")
  normal = seen()
  check(f"{name}: a minute-old scan serves --limits-only but not a normal run", limits_only == forced and normal != forced,
        f"forced {forced}, --limits-only {limits_only}, normal {normal}")

  adapter.grow()
  edit_scan_cache(name, lambda data: data.update(scanDate="2000-01-01"))
  other_day = seen("--limits-only")
  check(f"{name}: a scan from another day is made again", other_day != normal, f"{normal} -> {other_day}")

  adapter.grow()
  age_scan_cache(name, -3600)
  future = seen("--limits-only")
  check(f"{name}: a scan stamped in the future is made again", future != other_day, f"{other_day} -> {future}")

  if adapter.pi_root is not None:
    for path in scan_cache_files(name):
      path.unlink()
    write_pi_session(Path(adapter.pi_root()) / "rg-check" / "session.jsonl", [pi_reply("rg-check", 1, id="rg-check")])
    real_path = os.environ.get("PATH", "")
    os.environ["PATH"] = str(home() / "no-rg")
    try:
      with contextlib.redirect_stderr(io.StringIO()):
        service.run("up", "--force")
    finally:
      os.environ["PATH"] = real_path
    check(f"{name}: a scan that couldn't read the pi sessions (no rg) is never cached", not scan_cache_files(name),
          ", ".join(path.name for path in scan_cache_files(name)))
