#!/bin/bash

# These fixtures catch inclusive-counter double counting, fork replayed prompts,
# injected user messages, mixed-model misattribution, incomplete scan reuse, and
# Factory's Core windows, Extra Usage balance, and plan answers.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"
agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *
from unittest.mock import patch
import ctypes
import ctypes.util

freeze_today()


def message(id, offset=0, role="user", source="desktop", model=None, **fields):
  payload = {"role": role, "content": [{"type": "text", "text": "private transcript sentinel"}]}
  if source is not None:
    payload["userMessageSource"] = source
  if model is not None:
    payload["modelId"] = model
  payload.update(fields)
  return {"type": "message", "id": id, "timestamp": iso_in(offset), "parentId": "previous", "seq": 1, "message": payload}


def session(id, tokens=(100, 20, 30, 40), messages=(), parent=None, fork=None, directory="project", **settings):
  path = home() / ".factory" / "sessions" / directory / f"{id}.jsonl"
  path.parent.mkdir(parents=True, exist_ok=True)
  start = {"type": "session_start", "id": id, "title": "private title sentinel", "cwd": "/private/project", "hostId": "private host"}
  if parent:
    start.update(callingSessionId=parent, callingToolUseId="task")
  if fork:
    start["parent"] = fork
  path.write_text("".join(json.dumps(row) + "\n" for row in [start, *messages]))
  own = dict(zip(("inputTokens", "outputTokens", "cacheReadTokens", "cacheCreationTokens"), tokens))
  write_json(path.with_suffix(".settings.json"), {
    "model": "latest-pin",
    "tokenUsage": {**own, "thinkingTokens": 7, "factoryCredits": 5000000},
    "inclusiveTokenUsage": {"inputTokens": 999999},
    "childInclusiveTokenUsageBySessionId": {"child": {"inputTokens": 999999}},
    "lastCallTokenUsage": {"inputTokens": 999999},
    **settings,
  })
  return path


def droid(*args):
  return collect("droid", *(args or ("--force",)))


sandbox()
old = -2 * 86400
original = message("original-prompt", old)
root = session("root", messages=[
  original, message("reply-old", old, role="assistant", source=None, model="claude-sonnet-4"),
  message("prompt-now"), message("reply-now", role="assistant", source=None, model="gpt-5"),
  message("reminder", visibility="llm_only"),
  message("local-output", visibility="user_only"),
  message("agent-event", source=None, sender={"kind": "agent", "sessionId": "child"}),
  message("background", source=None, sender={"kind": "orchestrator", "sessionId": "root"}),
  message("tool", source=None, content=[{"type": "tool_result", "tool_use_id": "tool", "content": "private result"}]),
  {**message("compaction", source=None, visibility="llm_only"), "compactionSummaryId": "summary"},
  message("injected", source="compaction"),
  message("legacy", source=None),
])
session("child", tokens=(10, 2, 3, 4), parent="root",
        messages=[message("task-prompt"), message("child-reply", role="assistant", source=None, model="gpt-5")])
session("grandchild", tokens=(1, 2, 3, 4), parent="child",
        messages=[message("nested-task"), message("nested-reply", role="assistant", source=None, model="gpt-5")])
session("fork", tokens=(5, 1, 0, 0), fork="root", messages=[original, original, message("new-fork-prompt", source="cli_tui")])
session("archive", tokens=(8, 2, 0, 0), directory="archive/project",
        messages=[message("archived-prompt", old, source="web"), message("archived-reply", old, role="assistant", source=None, model="gpt-5")])
# A moved copy with the same id is not another session's counters.
session("root", messages=[original, message("prompt-now"), message("legacy", source=None),
                         message("reply-copy", role="assistant", source=None, model="gpt-5")], directory="archive/copy")
with FakeHttp() as http:
  record = droid()
expect("Droid sums own counters once, folds child sessions into roots, and deduplicates real prompts across forks", {
  key: record[key] for key in ("ready", "hasLocalStats", "todayTotalTokens", "todayPrompts", "totalPrompts", "totalSessions", "activeDays")
}, {"ready": True, "hasLocalStats": True, "todayTotalTokens": 225, "todayPrompts": 3, "totalPrompts": 5, "totalSessions": 3, "activeDays": 2}, record)
expect("mixed or missing history is unallocated, while a single observed model keeps its own bucket", record["modelUsage"], {
  "Droid (unallocated)": {"inputTokens": 105, "outputTokens": 21, "cacheReadInputTokens": 30, "cacheCreationInputTokens": 40},
  "gpt-5": {"inputTokens": 19, "outputTokens": 6, "cacheReadInputTokens": 6, "cacheCreationInputTokens": 8},
}, record)
expect("Droid books aggregate tokens on last activity, not the earlier prompt's date",
       next(day["messageCount"] for day in record["recentDays"] if day["date"] == datetime.fromisoformat(original["timestamp"].replace("Z", "+00:00")).astimezone().strftime("%Y-%m-%d")), 10, record)
expect("signed-out Droid keeps local usage without probing and waits for auth",
       [http.requests, record["limits"], record["tierLabel"], record["usageStatusText"], record["authHelpText"], record.get("balance")],
       [[], [], "", "Waiting for auth", "Run `droid` to sign in again, or update FACTORY_API_KEY.", None])
cached_text = "\n".join(path.read_text() for path in scan_cache_files("droid"))
check("Droid output and cache contain no transcript, title, host, project, or prompt ids",
      all(value not in json.dumps(record) + cached_text for value in ("private", "original-prompt", "latest-pin")))

sandbox()
session("post-compaction", tokens=(5, 0, 0, 0), messages=[
  {**message("summary", source=None, visibility="llm_only"), "compactionSummaryId": "summary-id"},
  {**message("typed-after-compaction", source="cli_tui"), "compactionSummaryId": "summary-id"},
])
expect("compaction lineage metadata does not hide the next real prompt", droid()["todayPrompts"], 1)

sandbox()
session("unsafe", tokens=("999", True, float("nan"), -7),
        messages=[message("u"), message("a", role="assistant", source=None, model="<b>unsafe</b>")])
session("control", tokens=(1, 2, 0, 0),
        messages=[message("a2", role="assistant", source=None, model="model\nname")])
session("long", tokens=(1, 2, 0, 0),
        messages=[message("a3", role="assistant", source=None, model="x" * 121)])
session("missing-date", tokens=(3, 4, 0, 0))
session("bad-date", tokens=(5, 6, 0, 0), messages=[{**message("bad-time"), "timestamp": "not-a-date"}])
record = droid()
expect("Droid validates token and model fields without losing lifetime totals with unknown dates",
       [record["todayTotalTokens"], record["totalPrompts"], record["totalSessions"], record["modelUsage"]],
       [6, 1, 5, {"Droid (unallocated)": {"inputTokens": 10, "outputTokens": 14, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0}}], record)

for fault in ("settings-missing", "settings-malformed", "counters-missing", "transcript-missing", "transcript-torn", "transcript-malformed", "unreadable"):
  sandbox()
  session("good", tokens=(3, 2, 0, 0), messages=[message("good-u")])
  broken = session("broken")
  settings = broken.with_suffix(".settings.json")
  if fault == "settings-missing":
    settings.unlink()
  elif fault == "settings-malformed":
    settings.write_text('{"private secret":')
  elif fault == "counters-missing":
    write_json(settings, {"inclusiveTokenUsage": {"inputTokens": 900}})
  elif fault == "transcript-missing":
    broken.unlink()
  elif fault == "transcript-torn":
    with broken.open("a") as handle:
      handle.write('{"private secret":')
  elif fault == "transcript-malformed":
    with broken.open("a") as handle:
      handle.write('{"private secret":\n')
  real_open = Path.open
  def open_source(path, *args, **kwargs):
    if path == broken and fault == "unreadable":
      raise PermissionError("private secret")
    return real_open(path, *args, **kwargs)
  diagnostics = io.StringIO()
  with patch.object(Path, "open", open_source), contextlib.redirect_stderr(diagnostics):
    record = droid()
  expect(f"Droid keeps readable usage but never caches a {fault} source",
         [record["todayTotalTokens"], bool(scan_cache_files("droid"))], [5, False], record)
  check(f"Droid diagnostics redact {fault} source contents and project paths",
        "private" not in diagnostics.getvalue() and str(broken) not in diagnostics.getvalue())

sandbox()
counter = 0
def grow():
  global counter
  counter += 1
  session(f"grown-{counter}", tokens=(5, 0, 0, 0), messages=[message(f"u-{counter}")])
check_scan_cache(Adapter("droid", grow=grow))
before = droid()["todayTotalTokens"]
settings = home() / ".factory/sessions/project/grown-1.settings.json"
write_json(settings, {"tokenUsage": {"inputTokens": 50}})
record = droid()
expect("Droid rescans changed settings after force", record["todayTotalTokens"] - before, 45, record)
sandbox()
session("another-home", tokens=(2, 0, 0, 0), messages=[message("u")])
expect("another HOME never reuses Droid's old source cache", droid("--limits-only")["todayTotalTokens"], 2)


def encrypt_login(data, key):
  crypto = ctypes.CDLL(ctypes.util.find_library("crypto"))
  pointer, integer = ctypes.c_void_p, ctypes.c_int
  for name, result, arguments in (
    ("EVP_CIPHER_CTX_new", pointer, []),
    ("EVP_CIPHER_CTX_free", None, [pointer]),
    ("EVP_aes_256_gcm", pointer, []),
    ("EVP_EncryptInit_ex", integer, [pointer, pointer, pointer, pointer, pointer]),
    ("EVP_EncryptUpdate", integer, [pointer, pointer, ctypes.POINTER(integer), pointer, integer]),
    ("EVP_EncryptFinal_ex", integer, [pointer, pointer, ctypes.POINTER(integer)]),
    ("EVP_CIPHER_CTX_ctrl", integer, [pointer, integer, integer, pointer]),
  ):
    function = getattr(crypto, name)
    function.restype, function.argtypes = result, arguments
  context = crypto.EVP_CIPHER_CTX_new()
  raw, iv = json.dumps(data).encode(), b"0123456789abcdef"
  output, tag = ctypes.create_string_buffer(len(raw) + 16), ctypes.create_string_buffer(16)
  size, final = integer(), integer()
  try:
    assert crypto.EVP_EncryptInit_ex(context, crypto.EVP_aes_256_gcm(), None, None, None) == 1
    assert crypto.EVP_CIPHER_CTX_ctrl(context, 0x9, len(iv), None) == 1
    assert crypto.EVP_EncryptInit_ex(context, None, None, key, iv) == 1
    assert crypto.EVP_EncryptUpdate(context, output, ctypes.byref(size), raw, len(raw)) == 1
    assert crypto.EVP_EncryptFinal_ex(context, ctypes.byref(output, size.value), ctypes.byref(final)) == 1
    assert crypto.EVP_CIPHER_CTX_ctrl(context, 0x10, 16, tag) == 1
    return ":".join(base64.b64encode(part).decode() for part in (iv, tag.raw, output.raw[:size.value + final.value]))
  finally:
    crypto.EVP_CIPHER_CTX_free(context)


REAL_PATH = os.environ["PATH"]
KEY = b"k" * 32
ENDPOINT = "api/billing/limits"
ME = "api/app/auth/me"
ANSWER = {ME: {"organization": {"subscription": {"factoryTier": "team"}}},
          ENDPOINT: {"hasActiveSubscription": True, "limits": {"standard": {
  "fiveHour": {"usedPercent": 18, "windowEnd": iso_in(3600)},
  "weekly": {"usedPercent": 6, "windowEnd": iso_in(7 * 86400)},
  "monthly": {"usedPercent": 3, "windowEnd": iso_in(30 * 86400)},
}, "core": {"fiveHour": {"usedPercent": 90, "windowEnd": iso_in(3600)}}}}}


def machine():
  sandbox()
  stub = home() / "bin" / "secret-tool"
  stub.parent.mkdir(parents=True, exist_ok=True)
  stub.write_text('#!/bin/bash\n[[ "$*" == "lookup service Factory CLI account auth-encryption-key" ]] || exit 1\ncat "$HOME/keyring-key" 2>/dev/null\n')
  stub.chmod(0o755)
  os.environ["PATH"] = f"{stub.parent}:{REAL_PATH}"


def sign_in(subject="user-main", org="active-org", expired=False, tier="team", fallback=False):
  token = jwt({"sub": subject, "org_id": "jwt-org-not-active", "exp": time.time() + (-3600 if expired else 3600)})
  root = home() / ".factory"
  root.mkdir(parents=True, exist_ok=True)
  (root / ("auth.v2.file" if fallback else "auth.v2.keyring")).write_text(encrypt_login({
    "access_token": token, "active_organization_id": org, "refresh_token": "private-refresh-sentinel",
  }, KEY))
  (root / "auth.v2.key" if fallback else home() / "keyring-key").write_text(base64.b64encode(KEY).decode())
  write_json(root / "org-managed-settings.cache.json", {"factoryTier": tier})
  return token


def limits_record(mode="up", routes=ANSWER, args=("--force",)):
  with FakeHttp(routes, mode=mode) as http:
    record = collect("droid", *args)
  return record, http


machine()
fresh = check_limits_contract(Adapter("droid", plant=sign_in, answer=ANSWER, requests_per_probe=2))
expect("Droid reads Standard windows, attaches active Core windows to them, and names its Factory plan",
       [fresh["tierLabel"], [(w["label"], w["percent"], w.get("title")) for w in fresh["limits"]]],
       ["Pro", [("Session (5-hour)", 0.18, None), ("Weekly (7-day)", 0.06, None), ("Monthly", 0.03, None),
                ("Core Session (5-hour)", 0.9, "Core Session")]], fresh)

token = sign_in()
record, http = limits_record()
expect("Droid sends its decrypted access token and active organization, not the JWT organization",
       [(r["headers"].get("authorization"), r["headers"].get("x-factory-org-id")) for r in http.requests],
       [(f"Bearer {token}", "active-org")] * 2)
stored = [(path, path.read_bytes()) for path in (home() / ".factory").glob("auth.v2.*")]
record, _ = limits_record("down")
check("Droid never changes its credential files and keeps no credential in limits caches",
      all(path.read_bytes() == raw for path, raw in stored)
      and all("private-refresh-sentinel" not in path.read_text() and token not in path.read_text()
              for path in limits_cache_files("droid")))

sign_in(expired=True)
record, http = limits_record(args=())
expect("a lapsed Droid access token pauses without a request even while the probe cache is fresh",
       [record["usageStatusText"], record["limitsStale"], len(record["limits"]), http.count, record["retryAdvised"]],
       ["Limits paused", True, 4, 0, False], record)
sign_in(org="other-org", expired=True)
record, _ = limits_record()
expect("a different active organization never shows the previous organization's limits", record["limits"], [], record)
sign_in(subject="other-user", expired=True)
record, _ = limits_record()
expect("a different signed-in user never shows the previous user's limits", record["limits"], [], record)

os.environ["FACTORY_API_KEY"] = "fixture-api-key"
record, http = limits_record()
expect("FACTORY_API_KEY takes precedence over even a lapsed stored login",
       [record["ready"], record["usageStatusText"], http.requests[0]["headers"].get("authorization"),
        http.requests[0]["headers"].get("x-factory-org-id")],
       [True, "", "Bearer fixture-api-key", None], record)
os.environ["FACTORY_API_KEY"] = "another-api-key"
record, _ = limits_record("down")
expect("another Factory API key cannot reuse the previous key's limits", record["limits"], [], record)
del os.environ["FACTORY_API_KEY"]

machine()
session("signed-out", messages=[message("typed")])
sign_in()
(home() / "keyring-key").unlink()
record, http = limits_record()
expect("Droid local sessions with no keyring entry wait for auth without a request",
       [record["ready"], record["hasLocalStats"], record["usageStatusText"], http.count],
       [True, True, "Waiting for auth", 0], record)
sign_in()
encrypted = home() / ".factory" / "auth.v2.keyring"
parts = encrypted.read_text().split(":")
parts[1] = base64.b64encode(b"bad-auth-tag-16b!").decode()
encrypted.write_text(":".join(parts))
record, http = limits_record()
expect("Droid refuses an encrypted login whose authentication tag does not verify",
       [record["usageStatusText"], http.count], ["Waiting for auth", 0], record)
sign_in(fallback=True)
record, _ = limits_record()
expect("Droid reads its base64 file-key fallback without a usable keyring login",
       [record["usageStatusText"], record["limits"][0]["percent"]], ["", 0.18], record)

for tier, label in (("team", "Pro"), ("team_annual", "Pro Annual"), ("pro_plus", "Plus"),
                    ("max", "Max"), ("ultra", "Ultra"), ("teams", "Teams"), ("enterprise", "")):
  sign_in(tier=tier)
  record, _ = limits_record(routes={ENDPOINT: ANSWER[ENDPOINT]})
  expect(f"Droid displays Factory's own plan name for {tier}", record["tierLabel"], label, record)
for raw in ('{"factoryTier":', '{"factoryTier": []}'):
  (home() / ".factory" / "org-managed-settings.cache.json").write_text(raw)
  record, _ = limits_record(routes={ENDPOINT: ANSWER[ENDPOINT]})
  expect("a malformed Droid plan cache invents no tier", record["tierLabel"], "", record)

sign_in()
for payload in ({"hasActiveSubscription": False}, {"hasActiveSubscription": True, "limits": {}}):
  record, _ = limits_record(routes={ENDPOINT: payload})
  expect("a Factory plan without standard limits is healthy",
         [record["limits"], record["usageStatusText"], record["authHelpText"], record["limitsStale"]],
         [[], "", "", False], record)
record, _ = limits_record(routes={ENDPOINT: {"hasActiveSubscription": True, "limits": {"standard": {
  "fiveHour": {"usedPercent": 180, "windowEnd": iso_in(3600)},
  "weekly": {"usedPercent": 80, "windowEnd": iso_in(-3600)},
  "monthly": {"usedPercent": 99, "windowEnd": None},
}}}})
expect("Droid clamps overspent windows and zeroes elapsed and not-started windows",
       [(w["percent"], bool(w["resetsAt"])) for w in record["limits"]],
       [(1.0, True), (0.0, False), (0.0, False)], record)
record, _ = limits_record(routes={ENDPOINT: {"hasActiveSubscription": True, "limits": {"standard": {
  "fiveHour": {"usedPercent": True, "windowEnd": iso_in(3600)},
}}}})
expect("an unreadable Factory percentage keeps the last limits stale, not a fabricated fraction",
       [record["limitsStale"], record["limits"][0]["percent"], record["retryAdvised"]], [True, 1.0, False], record)
for status in (401, 403):
  record, _ = limits_record(status)
  expect(f"Factory refusing the credential with {status} asks to sign in again",
         [record["usageStatusText"], "droid" in record["authHelpText"], record["retryAdvised"]],
         ["Sign-in expired", True, False], record)

for base, allowed in (("https://mirror.example", True), ("http://127.0.0.1:8080", True), ("http://evil.example", False)):
  os.environ["FACTORY_API_BASE_URL"] = base
  record, http = limits_record()
  expect(f"Droid only sends credentials to a trusted override at {base}",
         [r["url"] for r in http.requests], [base + "/api/billing/limits", base + "/api/app/auth/me"] if allowed else [])
os.environ["FACTORY_API_BASE_URL"] = "https://mirror.example"
limits_record()
os.environ["FACTORY_API_BASE_URL"] = "https://other.example"
record, http = limits_record(args=())
expect("a fresh answer from one API base does not stand in for another", http.count, 2, record)
os.environ["FACTORY_API_BASE_URL"] = "https://third.example"
record, _ = limits_record("down")
expect("an unreachable API base never shows another base's limits", record["limits"], [], record)
del os.environ["FACTORY_API_BASE_URL"]
sign_in(tier="team")
record, _ = limits_record(routes={**ANSWER, ME: {"organization": {"subscription": {
  "factoryTier": "team", "orbSubscription": {"plan": {"name": "Factory Pro Plan"}},
}}}})
expect("Droid uses the billing plan's name before the internal tier", record["tierLabel"], "Factory Pro Plan", record)
record, _ = limits_record(routes={**ANSWER, ME: {"organization": {"subscription": {"factoryTier": "max"}}}})
expect("Factory's account answer names the plan over a stale managed-settings cache", record["tierLabel"], "Max", record)
record, _ = limits_record("down")
expect("Droid keeps the account's plan beside stale limits", [record["tierLabel"], record["limitsStale"]], ["Max", True], record)

sign_in()
idle_core = {"fiveHour": {"usedPercent": 0, "windowEnd": None, "secondsRemaining": None},
             "weekly": {"usedPercent": 0, "windowEnd": None, "secondsRemaining": None}}
record, _ = limits_record(routes={ENDPOINT: {"hasActiveSubscription": True, "limits": {
  "standard": ANSWER[ENDPOINT]["limits"]["standard"], "core": idle_core}}})
expect("an unused Core pool adds no windows", [w["label"] for w in record["limits"]],
       ["Session (5-hour)", "Weekly (7-day)", "Monthly"], record)

def billed(**fields):
  return {ENDPOINT: {**ANSWER[ENDPOINT], **fields}}

record, _ = limits_record(routes=billed(extraUsageBalanceCents=1250, extraUsageAllowed=True))
expect("a funded Extra Usage balance shows what remains in dollars", record.get("balance"),
       {"remaining": 12.5, "funded": 0, "spent": 0, "currency": "USD", "estimated": False}, record)
record, _ = limits_record("down")
expect("Droid keeps the Extra Usage balance beside stale limits", [record.get("balance", {}).get("remaining"), record["limitsStale"]], [12.5, True], record)
for fields in ({"extraUsageBalanceCents": 0, "extraUsageAllowed": True},
               {"extraUsageBalanceCents": 1250, "extraUsageAllowed": False},
               {"extraUsageBalanceCents": True, "extraUsageAllowed": True}):
  record, _ = limits_record(routes=billed(**fields))
  expect(f"no Extra Usage balance for {fields}", "balance" in record, False, record)
PY
