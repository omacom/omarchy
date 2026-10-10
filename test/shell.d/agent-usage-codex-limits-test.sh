#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT

HOME="$SCRATCH" python3 - "${1:-$ROOT/bin/omarchy-agent-usage-codex}" <<'PY'
import json
import os
import runpy
import sys
from pathlib import Path

collector = sys.argv[1]
home = Path.home()
codex_home = home / ".codex"
codex_home.mkdir()
(codex_home / "auth.json").write_text("{}")
bin_dir = home / "bin"
bin_dir.mkdir()
stub = bin_dir / "codex"
stub.write_text("#!" + sys.executable + "\n" + '''
import json
import os
import sys
from pathlib import Path

for line in sys.stdin:
  request = json.loads(line)
  method = request["method"]
  if "id" not in request:
    continue
  if method == "account/read":
    with Path(os.environ["RPC_CALLS"]).open("a") as log:
      log.write(method + "\\n")
    reply = {"account": {"planType": "plus"}}
  elif method == "account/rateLimits/read":
    reply = json.loads(os.environ["RPC_LIMITS"])
  else:
    reply = {}
  print(json.dumps({"id": request["id"], "result": reply}), flush=True)
''')
stub.chmod(0o755)
calls = home / "calls"
os.environ.update(PATH=str(bin_dir) + os.pathsep + os.environ["PATH"],
                  CODEX_HOME=str(codex_home), RPC_CALLS=str(calls))


def window(percent, minutes=300):
  return {"usedPercent": percent, "windowDurationMins": minutes}


def check(name, payload, expected, plan="pro", account_read=False, reset_credits=None):
  calls.write_text("")
  os.environ["RPC_LIMITS"] = json.dumps(payload)
  loaded = runpy.run_path(collector, run_name="limits_test")
  record = loaded["fetch_codex_rpc"](codex_home)
  assert record["usageStatusText"] == "", (name, record)
  assert record["authHelpText"] == "", (name, record)
  assert record["tierLabel"] == plan, (name, record)
  assert record["limits"] == expected, (name, record)
  assert bool(calls.read_text()) == account_read, (name, calls.read_text())
  assert record.get("resetCredits") == reset_credits, (name, record)
  print("ok - " + name)


def entry(percent, label="5h window", title=None):
  result = {"label": label, "percent": percent / 100, "resetsAt": ""}
  if title:
    result["title"] = title
  return result


legacy = {"planType": "pro", "primary": window(12)}
check("legacy single-bucket limits keep their display shape", {"rateLimits": legacy}, [entry(12)])
check("map-only limits supply both windows and the plan", {
  "rateLimitsByLimitId": {"codex": {"planType": "pro", "primary": window(25),
                                    "secondary": window(42, 10080)}}
}, [entry(25), entry(42, "Weekly (7-day)")])
check("multi-bucket limits supersede the legacy view without duplicates", {
  "rateLimits": legacy,
  "rateLimitsByLimitId": {"codex": {"planType": "pro", "primary": window(36)}}
}, [entry(36)])
check("named buckets are distinct and general Codex limits come first", {
  "rateLimits": {"planType": "plus", "primary": window(99)},
  "rateLimitsByLimitId": {
    "codex_other": {"planType": "plus", "limitName": "Other model", "primary": window(80, 60)},
    "codex": {"planType": "pro", "primary": window(25)}}
}, [entry(25, title="codex · 5h window"), entry(80, "1h window", "Other model · 1h window")])
check("a single named bucket keeps its model label", {
  "rateLimitsByLimitId": {"codex_other": {"planType": "pro", "limitName": "Other model",
                                          "primary": window(80)}}
}, [entry(80, title="Other model · 5h window")])
check("unnamed model buckets use their identifiers to distinguish equal windows", {
  "rateLimitsByLimitId": {"codex": legacy, "codex_other": {"primary": window(80)}}
}, [entry(12, title="codex · 5h window"), entry(80, title="codex_other · 5h window")])
for unavailable in (None, {}, {"codex": None}, []):
  check("unavailable multi-bucket view falls back to legacy: " + repr(unavailable), {
    "rateLimits": legacy, "rateLimitsByLimitId": unavailable
  }, [entry(12)])
check("invalid map entries do not hide valid buckets", {
  "rateLimitsByLimitId": {"invalid": None, "codex": legacy}
}, [entry(12)])
check("legacy plan metadata is retained when map buckets omit it", {
  "rateLimits": legacy, "rateLimitsByLimitId": {"codex": {"primary": window(33)}}
}, [entry(33)])
check("account metadata remains an optional plan fallback", {
  "rateLimitsByLimitId": {"codex": {"primary": window(33)}}
}, [entry(33)], plan="plus", account_read=True)
check("malformed legacy metadata does not erase valid map limits", {
  "rateLimits": [], "rateLimitsByLimitId": {"codex": {"primary": window(33)}}
}, [entry(33)], plan="plus", account_read=True)
check("multi-bucket limits retain earned reset credits", {
  "rateLimitsByLimitId": {"codex": legacy},
  "rateLimitResetCredits": {"credits": [{"status": "available", "expiresAt": 1900000000}]}
}, [entry(12)], reset_credits={"available": 1, "nextExpiresAt": "2030-03-17T17:46:40+00:00"})
PY
