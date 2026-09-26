#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

no_key=$(HOME="$TEST_HOME" XDG_DATA_HOME="$TEST_HOME/.local/share" \
  XDG_CACHE_HOME="$TEST_HOME/.cache" OPENCODE_API_KEY="" \
  "$ROOT/bin/omarchy-agent-usage-opencode-go")

[[ $(jq -r '[.id, .ready, .name, .tierLabel] | join(":")' <<<"$no_key") == \
  "opencode-go:false:OpenCode:Go" ]] ||
  fail "OpenCode collector prints a valid offline record" "$no_key"
pass "OpenCode collector prints a valid offline record"

result=$(python3 - "$ROOT/bin/omarchy-agent-usage-opencode-go" "$TEST_HOME" <<'PY'
import datetime as dt
import importlib.machinery
import importlib.util
import io
import json
import os
import sqlite3
import sys
import time
from pathlib import Path

collector_path = Path(sys.argv[1])
test_home = Path(sys.argv[2])
os.environ["TZ"] = "UTC"
time.tzset()
os.environ.pop("OPENCODE_API_KEY", None)
os.environ.pop("OPENCODE_DB", None)

os.environ["XDG_CACHE_HOME"] = str(test_home / "cache" / "default")
loader = importlib.machinery.SourceFileLoader("collector", str(collector_path))
spec = importlib.util.spec_from_loader(loader.name, loader)
scanner = importlib.util.module_from_spec(spec)
loader.exec_module(scanner)
real_client = scanner.GoUsageClient


def first_token(auth_path, db=None):
  found = scanner.credential_candidates(auth_path, db)
  return found[0].token if found else ""


def probe_limits(key, force=False):
  candidates = [scanner.Credential(key, scanner.USAGE_PATH, {})] if key else []
  return scanner.collect_limits(candidates, "https://example.invalid", force)


data_home = test_home / "data"
os.environ["XDG_DATA_HOME"] = str(data_home)
auth_path = data_home / "opencode" / "auth.json"
auth_path.parent.mkdir(parents=True, exist_ok=True)
auth_path.write_text(json.dumps({"opencode-go": {"type": "api", "key": "sk_auth"}}))
now_ms = int(time.time() * 1000)


def day_offset(days):
  return now_ms - days * 86400 * 1000


def v1_message(message_id, session_id, provider, model, role="assistant", **tokens):
  data = {
    "role": role,
    "providerID": provider,
    "modelID": model,
    "tokens": {
      "input": tokens.get("input", 0),
      "output": tokens.get("output", 0),
      "reasoning": tokens.get("reasoning", 0),
      "cache": {
        "read": tokens.get("read", 0),
        "write": tokens.get("write", 0),
      },
    },
    "time": {"created": tokens.get("created", now_ms)},
  }
  return message_id, session_id, json.dumps(data)


def v2_message(message_id, session_id, provider, model, message_type="assistant", **tokens):
  data = {
    "time": {"created": tokens.get("created", now_ms)},
    "model": {"id": model, "providerID": provider},
    "tokens": {
      "input": tokens.get("input", 0),
      "output": tokens.get("output", 0),
      "reasoning": tokens.get("reasoning", 0),
      "cache": {
        "read": tokens.get("read", 0),
        "write": tokens.get("write", 0),
      },
    },
  }
  return (
    message_id, session_id, message_type, 1, now_ms, now_ms, json.dumps(data)
  )


def create_v1_table(conn):
  conn.execute(
    "CREATE TABLE message (id TEXT PRIMARY KEY, session_id TEXT NOT NULL, "
    "data TEXT NOT NULL)"
  )


def create_v2_table(conn):
  conn.execute(
    "CREATE TABLE session_message (id TEXT PRIMARY KEY, session_id TEXT NOT NULL, "
    "type TEXT NOT NULL, seq INTEGER NOT NULL, time_created INTEGER NOT NULL, "
    "time_updated INTEGER NOT NULL, data TEXT NOT NULL)"
  )


db = data_home / "opencode" / "opencode.db"
conn = sqlite3.connect(db)
create_v1_table(conn)
create_v2_table(conn)
v1_rows = [
  v1_message(
    "m1", "s1", "opencode-go", "deepseek-v4-flash",
    input=900, output=500, reasoning=100, read=200, write=50,
  ),
  v1_message(
    "m2", "s2", "opencode-go", "deepseek-v4-flash",
    input=100, output=20, created=day_offset(2),
  ),
  v1_message(
    "m3", "s3", "opencode-go", "deepseek-v4-flash",
    input=50, output=10, created=day_offset(8),
  ),
  v1_message(
    "user", "s4", "opencode-go", "deepseek-v4-flash",
    role="user", input=9999, output=9999,
  ),
  v1_message(
    "other", "s5", "anthropic", "claude-opus", input=9999, output=9999,
  ),
  v1_message("zero", "s6", "opencode-go", "deepseek-v4-flash"),
]
conn.executemany(
  "INSERT INTO message (id, session_id, data) VALUES (?, ?, ?)", v1_rows
)
v2_rows = [
  # This duplicate is deliberately different: V2 must win without double-counting.
  v2_message(
    "m1", "s1", "opencode-go", "deepseek-v4-flash",
    input=1000, output=500, reasoning=100, read=200, write=50,
  ),
  v2_message(
    "v2-1", "s-v2", "opencode-go", "deepseek-v4-pro",
    input=7, output=3, reasoning=2, read=1, write=4,
  ),
  v2_message(
    "wrong", "s-wrong", "opencode-proxy", "deepseek-v4-pro",
    input=999, output=999,
  ),
  v2_message(
    "v2-user", "s-user", "opencode-go", "deepseek-v4-pro",
    message_type="user", input=999, output=999,
  ),
  v2_message("v2-zero", "s-zero", "opencode-go", "deepseek-v4-pro"),
  ("v2-bad", "s-bad", "assistant", 1, now_ms, now_ms, "not json"),
]
conn.executemany(
  "INSERT INTO session_message "
  "(id, session_id, type, seq, time_created, time_updated, data) "
  "VALUES (?, ?, ?, ?, ?, ?, ?)",
  v2_rows,
)
conn.commit()
conn.close()

stats, complete = scanner.scan_opencode_db(db)

v1_db = data_home / "v1-only.db"
conn = sqlite3.connect(v1_db)
create_v1_table(conn)
conn.execute(
  "INSERT INTO message (id, session_id, data) VALUES (?, ?, ?)", v1_rows[0]
)
conn.commit()
conn.close()
v1_stats, v1_complete = scanner.scan_opencode_db(v1_db)

v2_db = data_home / "v2-only.db"
conn = sqlite3.connect(v2_db)
create_v2_table(conn)
conn.execute(
  "INSERT INTO session_message "
  "(id, session_id, type, seq, time_created, time_updated, data) "
  "VALUES (?, ?, ?, ?, ?, ?, ?)",
  v2_message("v2-only", "s-v2-only", "opencode-go", "deepseek-v4-pro", input=11, reasoning=1),
)
conn.commit()
conn.close()
v2_stats, v2_complete = scanner.scan_opencode_db(v2_db)

selected_db = data_home / "opencode" / "opencode-v2.db"
conn = sqlite3.connect(selected_db)
create_v2_table(conn)
conn.execute(
  "CREATE TABLE credential (id TEXT PRIMARY KEY, integration_id TEXT, "
  "label TEXT NOT NULL, value TEXT NOT NULL, active INTEGER, "
  "time_updated INTEGER NOT NULL)"
)
conn.execute(
  "INSERT INTO session_message "
  "(id, session_id, type, seq, time_created, time_updated, data) "
  "VALUES (?, ?, ?, ?, ?, ?, ?)",
  v2_message(
    "selected", "s-selected", "opencode-go", "muse-spark-1.3-contributor",
    input=13, output=2, reasoning=1,
  ),
)
conn.execute(
  "INSERT INTO credential VALUES (?, ?, ?, ?, ?, ?)",
  (
    "active", "opencode-go", "default",
    json.dumps({"type": "key", "key": "sk_v2"}), 1, now_ms,
  ),
)
conn.commit()
conn.close()

tui_db = data_home / "opencode" / "opencode-tui-v2.db"
sqlite3.connect(tui_db).close()
selected = scanner.opencode_db_path()
os.environ["OPENCODE_DB"] = str(v1_db)
override = scanner.opencode_db_path()
os.environ.pop("OPENCODE_DB")
v2_key = first_token(auth_path, selected_db)
empty_auth = test_home / "empty-auth.json"
empty_auth.write_text("{}")
conn = sqlite3.connect(selected_db)
conn.execute("UPDATE credential SET active = 0")
conn.commit()
conn.close()
inactive_key = first_token(empty_auth, selected_db)
selected_db.unlink()
fallback = scanner.opencode_db_path()

live_payload = {
  "usage": {
    "rolling": {"status": "ok", "percent": 2, "resetsAt": "2026-08-13T00:15:17.598Z"},
    "weekly": {"status": "ok", "percent": 3, "resetsAt": "2026-08-17T00:00:00.598Z"},
    "monthly": {"status": "ok", "percent": 38, "resetsAt": "2026-08-27T01:24:06.598Z"},
  }
}
pr_payload = {
  "rollingUsage": {"status": "ok", "usagePercent": 19, "resetInSec": 7200},
  "weeklyUsage": {"status": "ok", "usagePercent": 5, "resetInSec": 3600},
}
limits = scanner.parse_usage_payload(live_payload)
old_limits = scanner.parse_usage_payload(pr_payload)
rate_limited = scanner.parse_usage_payload(
  {"usage": {"rolling": {"status": "rate-limited", "percent": 88}}}
)
percentages = [
  scanner.normalize_percent(value)
  for value in (0, 0.5, 1, 100, -1, "x")
]
zero_limits = scanner.parse_usage_payload(
  {"usage": {"rolling": {"status": "ok", "percent": 0}}}
)

os.environ["OPENCODE_API_KEY"] = "sk_env"
env_key = first_token(auth_path) == "sk_env"
os.environ.pop("OPENCODE_API_KEY")
auth_key = first_token(auth_path) == "sk_auth"
missing_key = first_token(empty_auth) == ""


class FakeClient:
  mode = "live"
  calls = 0
  reject = set()
  last_path = ""
  last_headers = {}

  def __init__(self, token, base_url, path, headers=None):
    self.token = token
    FakeClient.last_path = path
    FakeClient.last_headers = headers or {}

  def probe(self):
    FakeClient.calls += 1
    if self.token in FakeClient.reject:
      raise scanner.GoUsageError("rejected", auth=True)
    if FakeClient.mode == "live":
      return live_payload
    if FakeClient.mode == "reject":
      raise scanner.GoUsageError("rejected", auth=True)
    if FakeClient.mode == "entitlement":
      raise scanner.GoUsageError("subscription required", entitlement=True)
    if FakeClient.mode == "offline":
      raise scanner.GoUsageError("offline", transport=True)
    return {}


scanner.GoUsageClient = FakeClient
cache_root = test_home / "cache" / "records"
os.environ["XDG_CACHE_HOME"] = str(cache_root)
record = scanner.scan(auth_path, db, "https://example.invalid")
FakeClient.mode = "reject"
os.environ["XDG_CACHE_HOME"] = str(test_home / "cache" / "reject")
rejected = scanner.scan(auth_path, db, "https://example.invalid")
FakeClient.mode = "offline"
os.environ["XDG_CACHE_HOME"] = str(test_home / "cache" / "offline")
offline = scanner.scan(auth_path, db, "https://example.invalid")


def seed_limits(name, entries, age=3600, fetched_at_ms=None, key="sk_auth"):
  os.environ["XDG_CACHE_HOME"] = str(test_home / "cache" / name)
  cache_file = scanner.limits_cache_path(key)
  cache_file.parent.mkdir(parents=True, exist_ok=True)
  if fetched_at_ms is None:
    fetched_at_ms = int((time.time() - age) * 1000)
  cache_file.write_text(json.dumps({"fetchedAtMs": fetched_at_ms, "limits": entries}))


open_window = {
  "label": "Weekly (7-day)",
  "percent": 0.4,
  "resetsAt": (dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=6)).isoformat(),
}
closed_window = {
  "label": "Session (5-hour)",
  "percent": 0.9,
  "resetsAt": (dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=1)).isoformat(),
}
seed_limits("stale", [closed_window, open_window])
stale = probe_limits("sk_auth")
seed_limits("reuse", [open_window], age=0)
FakeClient.mode = "offline"
reused = probe_limits("sk_auth")
FakeClient.mode = "live"
before_force = FakeClient.calls
forced = probe_limits("sk_auth", True)
forced_calls = FakeClient.calls - before_force
seed_limits("expired", [closed_window], age=0)
expired = probe_limits("sk_auth")
seed_limits("rejected-cache", [closed_window, open_window])
FakeClient.mode = "reject"
rejected_cached = probe_limits("sk_auth")
seed_limits("entitlement", [open_window])
FakeClient.mode = "entitlement"
entitlement = probe_limits("sk_auth")
seed_limits("other-account", [open_window])
FakeClient.mode = "offline"
other_account = probe_limits("sk_other")
no_key = probe_limits("")

os.environ["XDG_CACHE_HOME"] = str(test_home / "cache" / "corrupt-limit")
cache_file = scanner.limits_cache_path("sk_auth")
cache_file.parent.mkdir(parents=True, exist_ok=True)
cache_file.write_text("[]")
FakeClient.mode = "live"
corrupt_limits = probe_limits("sk_auth")


# opencode v2 signs in to OpenCode Console, and the opencode-go provider
# resolves its credentials through that same integration: a different endpoint,
# workspace scoped, and last in line behind every explicit key.
def console_db(name, expires_delta, org="wrk_1"):
  path = data_home / "opencode" / name
  conn = sqlite3.connect(path)
  create_v2_table(conn)
  conn.execute(
    "CREATE TABLE credential (id TEXT PRIMARY KEY, integration_id TEXT, "
    "label TEXT NOT NULL, value TEXT NOT NULL, active INTEGER, "
    "time_updated INTEGER NOT NULL)"
  )
  metadata = {"email": "a@example.com"}
  if org:
    metadata["orgID"] = org
  conn.execute(
    "INSERT INTO credential VALUES (?, ?, ?, ?, ?, ?)",
    (
      "console", "opencode", "Default",
      json.dumps({
        "type": "oauth", "methodID": "device", "access": "sess_console",
        "refresh": "r", "expires": now_ms + expires_delta, "metadata": metadata,
      }),
      1, now_ms,
    ),
  )
  conn.commit()
  conn.close()
  return path


live_console_db = console_db("console-live.db", 86400000)
stale_console_db = console_db("console-stale.db", -1000)
no_org_db = console_db("console-no-org.db", 86400000, org="")
console_candidates = scanner.credential_candidates(auth_path, live_console_db)
console = console_candidates[-1]
console_parse = {
  "count": len(console_candidates),
  "token": console.token,
  "path": console.path,
  "org": console.headers.get(scanner.CONSOLE_ORG_HEADER),
  "expired": console.expired,
}

# A dead key in front must not hide the live Console session behind it.
FakeClient.mode = "live"
FakeClient.reject = {"sk_auth"}
os.environ["XDG_CACHE_HOME"] = str(test_home / "cache" / "console")
fallthrough = scanner.collect_limits(
  console_candidates, "https://example.invalid", False
)
console_path = FakeClient.last_path
console_headers = dict(FakeClient.last_headers)
FakeClient.reject = set()

# An expired session is a refresh problem, not a rejected sign-in.
FakeClient.mode = "reject"
os.environ["XDG_CACHE_HOME"] = str(test_home / "cache" / "console-expired")
expired_session = scanner.collect_limits(
  scanner.credential_candidates(empty_auth, stale_console_db),
  "https://example.invalid", False,
)
FakeClient.mode = "live"
stale_console = scanner.credential_candidates(empty_auth, stale_console_db)[0]
# A wrong workspace is a hard 403, so the header is dropped rather than guessed.
no_org = scanner.credential_candidates(empty_auth, no_org_db)[0]


captured = {}


class FakeResponse:
  def __init__(self, body):
    self.body = body

  def read(self):
    return self.body

  def __enter__(self):
    return self

  def __exit__(self, *args):
    return False


def fake_urlopen(request, timeout=None):
  captured["url"] = request.full_url
  captured["headers"] = {
    name.lower(): value for name, value in request.header_items()
  }
  if fake_urlopen.error:
    raise fake_urlopen.error
  return FakeResponse(fake_urlopen.body)


fake_urlopen.error = None
fake_urlopen.body = json.dumps(live_payload).encode()
scanner.urllib.request.urlopen = fake_urlopen
probe_client = real_client("sk_probe", "https://example.invalid")
probe_client.probe()


def probe_error(error):
  fake_urlopen.error = error
  try:
    probe_client.probe()
  except scanner.GoUsageError as caught:
    return type(caught).__name__ + ":" + str(caught)
  return "no-error"


errors = {
  "401": probe_error(
    scanner.urllib.error.HTTPError(
      "https://example.invalid", 401, "Unauthorized", {}, None
    )
  ),
  "403": probe_error(
    scanner.urllib.error.HTTPError(
      "https://example.invalid", 403, "Forbidden", {},
      io.BytesIO(b'{"error":{"type":"EntitlementError"}}'),
    )
  ),
  "500": probe_error(
    scanner.urllib.error.HTTPError(
      "https://example.invalid", 500, "Server Error", {}, None
    )
  ),
  "offline": probe_error(scanner.urllib.error.URLError(OSError("offline"))),
}


def cache_dir(name):
  return test_home / "cache" / "stats" / name


def cached(name, age):
  os.environ["XDG_CACHE_HOME"] = str(cache_dir(name))
  return scanner.cached_scan(db, age)


stats_cache = cached("envelope", 0)
cache_file = next((cache_dir("envelope") / "omarchy" / "agent-usage").glob("*.json"))
envelope = json.loads(cache_file.read_text())
cache_file.write_text("[]")
cache_recovered = cached("envelope", 900)

cached("modes", 0)
conn = sqlite3.connect(db)
conn.execute(
  "INSERT INTO message (id, session_id, data) VALUES (?, ?, ?)",
  v1_message("extra", "s-extra", "opencode-go", "deepseek-v4-flash", input=10),
)
conn.commit()
conn.close()
limits_only = cached("modes", 900)
forced_stats = cached("modes", 0)

bad_db = test_home / "broken" / "opencode.db"
bad_db.parent.mkdir(parents=True, exist_ok=True)
sqlite3.connect(bad_db).close()
os.environ["XDG_CACHE_HOME"] = str(cache_dir("broken"))
broken_stats, broken_complete = scanner.scan_opencode_db(bad_db)
scanner.cached_scan(bad_db, 20)
broken_cache = list((cache_dir("broken") / "omarchy" / "agent-usage").glob("*.json"))
conn = sqlite3.connect(bad_db)
create_v1_table(conn)
conn.execute(
  "INSERT INTO message (id, session_id, data) VALUES (?, ?, ?)",
  v1_message("recovered", "s", "opencode-go", "deepseek-v4-flash", input=9),
)
conn.commit()
conn.close()
rescanned = scanner.cached_scan(bad_db, 900)

unwritable = test_home / "not-a-directory"
unwritable.write_text("blocked")
os.environ["XDG_CACHE_HOME"] = str(unwritable)
unwritable_stats = scanner.cached_scan(db, 20)

print(json.dumps({
  "stats": stats,
  "complete": complete,
  "v1": [v1_stats["totalPrompts"], v1_stats["todayTotalTokens"], v1_complete],
  "v2": [v2_stats["totalPrompts"], v2_stats["todayTotalTokens"], v2_complete],
  "selection": {
    "v2": selected.resolve() == selected_db.resolve(),
    "override": override == v1_db.resolve(),
    "fallback": fallback.resolve() == db.resolve(),
    "ignoresTui": selected != tui_db,
    "v2Key": v2_key == "sk_v2",
    "inactiveIgnored": inactive_key == "",
  },
  "limits": {
    "live": limits,
    "old": old_limits,
    "rate": rate_limited,
    "percentages": percentages,
    "zero": zero_limits,
  },
  "auth": [env_key, auth_key, missing_key],
  "record": {
    "schemaVersion": record["schemaVersion"],
    "id": record["id"],
    "name": record["name"],
    "ready": record["ready"],
    "limits": record["limits"],
  },
  "rejected": [rejected["usageStatusText"], rejected["totalPrompts"]],
  "offline": [offline.get("retryAdvised"), offline["totalPrompts"]],
  "cacheLimits": {
    "stale": [w["label"] for w in stale["limits"]],
    "reused": [w["label"] for w in reused["limits"]],
    "forcedCalls": forced_calls,
    "expired": [w["label"] for w in expired["limits"]],
    "rejected": [w["label"] for w in rejected_cached["limits"]],
    "rejectedStatus": rejected_cached["usageStatusText"],
    "entitlement": entitlement["usageStatusText"],
    "other": [other_account["limits"], other_account["usageStatusText"]],
    "noKey": [no_key["limits"], no_key["usageStatusText"]],
    "corrupt": len(corrupt_limits["limits"]),
  },
  "probe": {
    "url": captured["url"],
    "auth": captured["headers"]["authorization"],
    "ua": captured["headers"]["user-agent"],
    "errors": errors,
  },
  "console": {
    "parse": console_parse,
    "path": console_path,
    "orgHeader": console_headers.get(scanner.CONSOLE_ORG_HEADER),
    "fallsThrough": [len(fallthrough["limits"]), fallthrough["usageStatusText"]],
    "stale": stale_console.expired,
    "expiredStatus": expired_session["usageStatusText"],
    "droppedOrg": no_org.headers,
  },
  "statsCache": {
    "date": envelope["scanDate"] == scanner.local_date_string(),
    "schema": envelope["schemaVersion"],
    "tokens": stats_cache["todayTotalTokens"],
    "recovered": cache_recovered["todayTotalTokens"],
    "limitsOnly": limits_only["totalPrompts"],
    "forced": forced_stats["totalPrompts"],
    "broken": [broken_stats["todayTotalTokens"], broken_complete, bool(broken_cache)],
    "rescanned": rescanned["todayTotalTokens"],
    "unwritable": unwritable_stats["totalPrompts"],
  },
}, separators=(",", ":")))
PY
)

[[ $(jq -r '[.stats.todayTotalTokens, .stats.totalPrompts, .complete] | join(":")' \
  <<<"$result") == "1867:4:true" ]] ||
  fail "OpenCode collector scans V1 and V2 without double-counting" "$result"
pass "OpenCode collector scans V1 and V2 without double-counting"

[[ $(jq -c '.stats.modelUsage["deepseek-v4-flash"]' <<<"$result") == \
  '{"inputTokens":1150,"outputTokens":630,"cacheReadInputTokens":200,'\
'"cacheCreationInputTokens":50}' ]] ||
  fail "OpenCode collector prefers V2 data for duplicate message IDs" "$result"
pass "OpenCode collector prefers V2 data for duplicate message IDs"

{ [[ $(jq -c '.v1' <<<"$result") == '[1,1750,true]' ]] &&
  [[ $(jq -c '.v2' <<<"$result") == '[1,12,true]' ]] &&
  [[ $(jq -r '.stats.activeDays' <<<"$result") == "3" ]]; } ||
  fail "OpenCode collector supports both SQLite generations and date totals" "$result"
pass "OpenCode collector supports both SQLite generations and date totals"

[[ $(jq -c '.selection' <<<"$result") == \
  '{"v2":true,"override":true,"fallback":true,"ignoresTui":true,'\
'"v2Key":true,"inactiveIgnored":true}' ]] ||
  fail "OpenCode collector selects V2, honors overrides, and ignores inactive credentials" "$result"
pass "OpenCode collector selects V2, honors overrides, and ignores inactive credentials"

{ jq -e '.limits.live | map(.percent) == [0.02, 0.03, 0.38]' <<<"$result" >/dev/null &&
  jq -e '.limits.old | map(.percent) == [0.19, 0.05]' <<<"$result" >/dev/null &&
  jq -e '.limits.percentages == [0, 0.005, 0.01, 1, null, null]' <<<"$result" >/dev/null &&
  jq -e '[.limits.rate[0].percent, .limits.zero[0].percent] == [1, 0]' \
    <<<"$result" >/dev/null; } ||
  fail "OpenCode collector parses and normalizes all limit response shapes" "$result"
pass "OpenCode collector parses and normalizes all limit response shapes"

[[ $(jq -c '.auth' <<<"$result") == '[true,true,true]' ]] ||
  fail "OpenCode collector applies API key precedence" "$result"
pass "OpenCode collector applies API key precedence"

{ [[ $(jq -c '.record | {schemaVersion,id,name,ready}' <<<"$result") == \
    '{"schemaVersion":1,"id":"opencode-go","name":"OpenCode","ready":true}' ]] &&
  [[ $(jq -c '.rejected' <<<"$result") == '["Sign-in rejected",4]' ]] &&
  [[ $(jq -c '.offline' <<<"$result") == '[true,4]' ]]; } ||
  fail "OpenCode collector preserves local stats through auth and transport failures" "$result"
pass "OpenCode collector preserves local stats through auth and transport failures"

{ [[ $(jq -c '.cacheLimits.stale' <<<"$result") == '["Weekly (7-day)"]' ]] &&
  [[ $(jq -c '.cacheLimits.reused' <<<"$result") == '["Weekly (7-day)"]' ]] &&
  [[ $(jq -r '.cacheLimits.forcedCalls' <<<"$result") == "1" ]] &&
  [[ $(jq -c '.cacheLimits.expired' <<<"$result") == \
    '["Session (5-hour)","Weekly (7-day)","Monthly (30-day)"]' ]] &&
  [[ $(jq -r '.cacheLimits.rejectedStatus' <<<"$result") == "Sign-in rejected" ]]; } ||
  fail "OpenCode collector keeps only current, account-specific limit caches" "$result"
pass "OpenCode collector keeps only current, account-specific limit caches"

{ [[ $(jq -r '.cacheLimits.entitlement' <<<"$result") == \
    "OpenCode Go subscription required" ]] &&
  [[ $(jq -c '.cacheLimits.other' <<<"$result") == \
    '[[],"OpenCode Go limits unavailable"]' ]] &&
  [[ $(jq -c '.cacheLimits.noKey' <<<"$result") == '[[],"Waiting for auth"]' ]] &&
  [[ $(jq -r '.cacheLimits.corrupt' <<<"$result") == "3" ]]; } ||
  fail "OpenCode collector separates entitlement, account, and corrupt-cache failures" "$result"
pass "OpenCode collector separates entitlement, account, and corrupt-cache failures"

{ [[ $(jq -r '.probe.url' <<<"$result") == \
    "https://example.invalid/zen/go/v1/usage" ]] &&
  [[ $(jq -r '.probe.auth + ":" + .probe.ua' <<<"$result") == \
    "Bearer sk_probe:omarchy-agent-usage/1" ]] &&
  [[ $(jq -r '.probe.errors["401"]' <<<"$result") == *"rejected"* ]] &&
  [[ $(jq -r '.probe.errors["403"]' <<<"$result") == *"subscription required"* ]] &&
  [[ $(jq -r '.probe.errors["500"]' <<<"$result") == *"status 500"* ]] &&
  [[ $(jq -r '.probe.errors.offline' <<<"$result") == *"Could not reach"* ]]; } ||
  fail "OpenCode probe maps endpoint authentication and transport failures" "$result"
pass "OpenCode probe maps endpoint authentication and transport failures"

{ [[ $(jq -c '.console.parse' <<<"$result") == \
    '{"count":2,"token":"sess_console","path":"/inference/go/v1/usage",'\
'"org":"wrk_1","expired":false}' ]] &&
  [[ $(jq -r '.console.path' <<<"$result") == "/inference/go/v1/usage" ]] &&
  [[ $(jq -r '.console.orgHeader' <<<"$result") == "wrk_1" ]] &&
  [[ $(jq -c '.console.fallsThrough' <<<"$result") == '[3,""]' ]] &&
  [[ $(jq -r '.console.stale' <<<"$result") == "true" ]] &&
  [[ $(jq -r '.console.expiredStatus' <<<"$result") == \
    "OpenCode Console session expired" ]] &&
  [[ $(jq -c '.console.droppedOrg' <<<"$result") == '{}' ]]; } ||
  fail "OpenCode collector falls through to the Console session on its own endpoint" "$result"
pass "OpenCode collector falls through to the Console session on its own endpoint"

{ [[ $(jq -r '[.statsCache.date, .statsCache.schema, .statsCache.tokens] | join(":")' \
    <<<"$result") == "true:2:1867" ]] &&
  [[ $(jq -c '.statsCache.recovered' <<<"$result") == "1867" ]] &&
  [[ $(jq -c '[.statsCache.limitsOnly, .statsCache.forced]' <<<"$result") == "[4,5]" ]] &&
  [[ $(jq -c '.statsCache.broken' <<<"$result") == '[0,false,false]' ]] &&
  [[ $(jq -r '.statsCache.rescanned' <<<"$result") == "9" ]] &&
  [[ $(jq -r '.statsCache.unwritable' <<<"$result") == "5" ]]; } ||
  fail "OpenCode collector validates and safely bypasses local stats caches" "$result"
pass "OpenCode collector validates and safely bypasses local stats caches"
