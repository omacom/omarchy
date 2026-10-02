#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command python3

unset OPENCODE_API_KEY OPENCODE_DB

# collect_limits reaches the Zen gateway, so the reader that interprets its
# answer is exercised on its own: the collector loads as a module, and a fake
# urlopen stands in for the response.
TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

COLLECTOR="$ROOT/bin/omarchy-agent-usage-opencode" TEST_HOME="$TEST_HOME" python3 - <<'PY'
import importlib.machinery
import importlib.util
import io
import json
import os
import pathlib
import sys
import urllib.error

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

home = os.environ["TEST_HOME"]
os.environ["XDG_CACHE_HOME"] = os.path.join(home, "cache")
# Never the real sign-ins: every credential store lives under the test home.
os.environ["HOME"] = os.path.join(home, "empty")
os.environ["XDG_DATA_HOME"] = os.path.join(home, "empty-data")
cache_dir = pathlib.Path(os.environ["XDG_CACHE_HOME"]) / "omarchy" / "agent-usage"


def check(description, condition, detail=""):
  if condition:
    print("ok - " + description)
    return
  print("not ok - " + description, file=sys.stderr)
  if detail:
    print(detail, file=sys.stderr)
  sys.exit(1)


def answer(payload=None, error=None):
  def open_(request, timeout=None):
    if error is not None:
      raise error
    return io.BytesIO(json.dumps(payload).encode())
  return open_


def clear_cache():
  for cache in cache_dir.glob("opencode-limits-*.json"):
    cache.unlink()


def clear_key():
  os.environ.pop("OPENCODE_API_KEY", None)
  os.environ["XDG_DATA_HOME"] = os.path.join(home, "empty-data")
  os.environ["HOME"] = os.path.join(home, "empty")
  os.makedirs(os.environ["HOME"], exist_ok=True)
  clear_cache()


os.environ["OPENCODE_API_KEY"] = "zen_test"
collector.urllib.request.urlopen = answer({"usage": {
  "rolling": {"percent": 16, "resetsAt": "2999-01-01T00:00:00.000Z"},
  "weekly": {"percent": 6, "resetsAt": "2999-01-05T00:00:00.000Z"},
  "monthly": {"percent": 29, "resetsAt": "2999-01-11T15:38:40.000Z"},
}})
result = collector.collect_limits(True)
check(
  "OpenCode collector maps every Zen usage window",
  [(w["label"], w["percent"]) for w in result["limits"]] == [("Rolling (5h)", 0.16), ("Weekly (7-day)", 0.06), ("Monthly", 0.29)]
  and result["tierLabel"] == "Go" and result["usageStatusText"] == "",
  json.dumps(result),
)

# A panel that opens and shuts repeatedly must not probe every time.
collector.urllib.request.urlopen = answer(error=RuntimeError("probe should have been skipped"))
result = collector.collect_limits(False)
check(
  "OpenCode collector reuses a fresh probe cache without a request",
  [(w["label"], w["percent"]) for w in result["limits"]] == [("Rolling (5h)", 0.16), ("Weekly (7-day)", 0.06), ("Monthly", 0.29)]
  and result["usageStatusText"] == "",
  json.dumps(result),
)

collector.urllib.request.urlopen = answer({"usage": {"rolling": {"percent": 50, "resetsAt": "2999-01-01T00:00:00.000Z"}}})
result = collector.collect_limits(True)
check(
  "OpenCode collector --force probes past the cache",
  [(w["label"], w["percent"]) for w in result["limits"]] == [("Rolling (5h)", 0.5)],
  json.dumps(result),
)

clear_cache()
collector.urllib.request.urlopen = answer({"usage": {}})
result = collector.collect_limits(True)
check(
  "OpenCode collector reports a payload without windows",
  result["limits"] == [] and result["usageStatusText"] == "OpenCode limits unavailable",
  json.dumps(result),
)

clear_cache()
collector.urllib.request.urlopen = answer(error=urllib.error.HTTPError("https://x", 401, "Unauthorized", {}, None))
result = collector.collect_limits(True)
check(
  "OpenCode collector asks for a fresh key on 401",
  result["limits"] == [] and result["usageStatusText"] == "OpenCode limits unavailable" and "rejected the saved key" in result["authHelpText"],
  json.dumps(result),
)

clear_cache()
collector.urllib.request.urlopen = answer(error=urllib.error.HTTPError("https://x", 403, "Forbidden", {}, None))
result = collector.collect_limits(True)
check(
  "OpenCode collector names a missing Go subscription on 403",
  "no OpenCode Go subscription" in result["authHelpText"],
  json.dumps(result),
)

clear_cache()
collector.urllib.request.urlopen = answer(error=urllib.error.HTTPError("https://x", 500, "Server Error", {}, None))
result = collector.collect_limits(True)
check(
  "OpenCode collector shows a non-auth status code",
  "returned status 500" in result["authHelpText"],
  json.dumps(result),
)

clear_cache()
collector.urllib.request.urlopen = answer(error=urllib.error.URLError("no route"))
result = collector.collect_limits(True)
check(
  "OpenCode collector advises a retry when no server answered",
  result["retryAdvised"] is True and result["usageStatusText"] == "OpenCode limits unavailable",
  json.dumps(result),
)

clear_key()
collector.urllib.request.urlopen = answer({"usage": {"rolling": {"percent": 1}}})
result = collector.collect_limits(True)
check(
  "OpenCode collector falls back to local stats without a key",
  result["limits"] == [] and result["usageStatusText"] == "Local usage only" and result["authHelpText"] != "",
  json.dumps(result),
)

# A failed probe keeps the last good numbers, marked stale with when they
# were measured, but only until each window resets.
os.environ["OPENCODE_API_KEY"] = "zen_test"
collector.cache_root().mkdir(parents=True, exist_ok=True)
collector.limits_cache_path("zen_test").write_text(json.dumps({
  "fetchedAtMs": 1700000000000,
  "limits": [
    {"label": "Rolling (5h)", "percent": 0.9, "resetsAt": "2020-01-01T00:00:00.000Z"},
    {"label": "Monthly", "percent": 0.4, "resetsAt": "2999-01-01T00:00:00.000Z"},
  ],
}))
collector.urllib.request.urlopen = answer(error=urllib.error.HTTPError("https://x", 500, "Server Error", {}, None))
result = collector.collect_limits(True)
check(
  "OpenCode collector keeps open cached windows, stale, after a failed probe",
  [w["label"] for w in result["limits"]] == ["Monthly"] and result["stale"] is True
  and result["fetchedAtMs"] == 1700000000000 and result["tierLabel"] == "Go" and result["usageStatusText"] == "",
  json.dumps(result),
)

collector.urllib.request.urlopen = answer({"usage": {"monthly": {"percent": 41, "resetsAt": "2999-01-01T00:00:00.000Z"}}})
result = collector.collect_limits(True)
check(
  "OpenCode collector marks fresh limits live",
  result["stale"] is False and result["fetchedAtMs"] > 1700000000000,
  json.dumps(result),
)

# Another sign-in never shows this one's numbers.
os.environ["OPENCODE_API_KEY"] = "zen_other"
collector.urllib.request.urlopen = answer(error=urllib.error.URLError("no route"))
result = collector.collect_limits(True)
check("OpenCode collector caches limits per credential", result["limits"] == [] and result["stale"] is True, json.dumps(result))

# Another deployment spells the windows <window>Usage, and a rate-limited
# window is spent whatever it reads.
clear_cache()
collector.urllib.request.urlopen = answer({
  "rollingUsage": {"usagePercent": 40, "resetInSec": 3600, "status": "rate-limited"},
  "weeklyUsage": {"usagePercent": "12.5", "resetInSec": 0},
})
result = collector.collect_limits(True)
check(
  "OpenCode collector reads the alternate payload shape",
  [(w["label"], w["percent"]) for w in result["limits"]] == [("Rolling (5h)", 1.0), ("Weekly (7-day)", 0.125)]
  and result["limits"][0]["resetsAt"] != "" and result["limits"][1]["resetsAt"] == "",
  json.dumps(result),
)

# The key can come from opencode's own credential stores or, when a machine
# codes through pi, from pi's.
clear_key()
opencode_home = os.path.join(home, "opencode-data")
os.makedirs(os.path.join(opencode_home, "opencode"), exist_ok=True)
with open(os.path.join(opencode_home, "opencode", "auth.json"), "w") as handle:
  json.dump({"opencode": {"type": "api_key", "key": "from_opencode"}}, handle)
os.environ["XDG_DATA_HOME"] = opencode_home
check("OpenCode collector reads opencode's own credential", [c.token for c in collector.credential_candidates()] == ["from_opencode"])

clear_key()
pi_home = os.path.join(home, "pi")
os.makedirs(os.path.join(pi_home, ".pi", "agent"), exist_ok=True)
with open(os.path.join(pi_home, ".pi", "agent", "auth.json"), "w") as handle:
  json.dump({"opencode-go": {"type": "api_key", "key": "from_pi"}}, handle)
os.environ["HOME"] = pi_home
check("OpenCode collector reads pi's credential as a last resort", [c.token for c in collector.credential_candidates()] == ["from_pi"])

# OpenCode V2 keeps its credentials in the database: a Go key first, and the
# Console session last, asked on Console's endpoint with its workspace.
import sqlite3
import time
clear_key()
v2_home = os.path.join(home, "v2-data")
os.makedirs(os.path.join(v2_home, "opencode"), exist_ok=True)
conn = sqlite3.connect(os.path.join(v2_home, "opencode", "opencode.db"))
conn.execute("CREATE TABLE credential (id text, integration_id text, active integer, time_updated integer, value text)")
conn.executemany("INSERT INTO credential VALUES (?, ?, ?, ?, ?)", [
  ("c1", "opencode-go", 1, 2, json.dumps({"type": "key", "key": "store_key"})),
  ("c2", "opencode-go", 0, 3, json.dumps({"type": "key", "key": "inactive_key"})),
  ("c3", "opencode", 1, 1, json.dumps({"type": "oauth", "access": "console_token", "expires": int(time.time() * 1000) + 60000, "metadata": {"orgID": "org_1"}})),
])
conn.commit()
conn.close()
os.environ["XDG_DATA_HOME"] = v2_home
candidates = collector.credential_candidates()
check(
  "OpenCode collector reads V2 credentials, the Console session last",
  [(c.token, c.url.endswith("/inference/go/v1/usage"), c.headers) for c in candidates]
  == [("store_key", False, {}), ("console_token", True, {"x-opencode-org-id": "org_1"})],
  repr(candidates),
)

asked = []
def refuse_key(request, timeout=None):
  asked.append((request.full_url, request.get_header("Authorization"), request.get_header("X-opencode-org-id")))
  if "store_key" in request.get_header("Authorization"):
    raise urllib.error.HTTPError(request.full_url, 401, "Unauthorized", {}, None)
  return io.BytesIO(json.dumps({"usage": {"weekly": {"percent": 30, "resetsAt": "2999-01-01T00:00:00.000Z"}}}).encode())
collector.urllib.request.urlopen = refuse_key
result = collector.collect_limits(True)
check(
  "OpenCode collector hands a refused key over to the Console session",
  [(w["label"], w["percent"]) for w in result["limits"]] == [("Weekly (7-day)", 0.3)]
  and asked[-1] == ("https://opencode.ai/inference/go/v1/usage", "Bearer console_token", "org_1"),
  json.dumps({"result": result, "asked": asked}),
)

# Every way in refused, with the Console session expired, says so.
conn = sqlite3.connect(os.path.join(v2_home, "opencode", "opencode.db"))
conn.execute("UPDATE credential SET value = ? WHERE id = 'c3'", (json.dumps({"type": "oauth", "access": "console_token", "expires": 1000}),))
conn.commit()
conn.close()
clear_cache()
collector.urllib.request.urlopen = answer(error=urllib.error.HTTPError("https://x", 401, "Unauthorized", {}, None))
result = collector.collect_limits(True)
check(
  "OpenCode collector names an expired Console session",
  result["usageStatusText"] == "OpenCode Console session expired" and result["limits"] == [],
  json.dumps(result),
)
PY
