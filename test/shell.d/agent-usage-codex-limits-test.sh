#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT
mkdir -p "$TEST_HOME/bin"

cat >"$TEST_HOME/bin/codex" <<'PY'
#!/usr/bin/python3
import json
import os
import sys
import time

for line in sys.stdin:
  request = json.loads(line)
  method = request["method"]
  if method == "initialized":
    continue
  messages = []
  if method == "initialize":
    result = {}
  else:
    messages = [
      {"method": "remoteControl/status/changed", "params": {}},
      {"method": "account/updated", "params": {}},
    ]
    if method == "account/read":
      result = {"account": {"planType": "prolite"}}
    else:
      result = {"rateLimits": {"primary": {"usedPercent": 25, "windowDurationMins": 10080}}}
  messages.append({"id": request["id"], "result": result})
  payload = ("\n".join(json.dumps(message) for message in messages) + "\n").encode()
  mode = os.environ["CODEX_RPC_MODE"]
  if method != "initialize" and mode != "batched":
    os.write(1, payload[:-2])
    if mode == "eof":
      break
    if mode == "stalled":
      continue
    time.sleep(0.05)
    os.write(1, payload[-2:])
  else:
    os.write(1, payload)
PY
chmod +x "$TEST_HOME/bin/codex"

python3 - "$TEST_HOME" <<'PY'
import json
import os
from pathlib import Path
import subprocess
import sys
import time

home = Path(sys.argv[1])
env = dict(os.environ, HOME=str(home), CODEX_HOME=str(home / ".codex"),
           XDG_CACHE_HOME=str(home / ".cache"), XDG_DATA_HOME=str(home / ".local/share"),
           PATH=str(home / "bin") + os.pathsep + os.environ["PATH"])
collector = Path(os.environ["ROOT"]) / "bin/omarchy-agent-usage-codex"

for mode in ("batched", "split", "stalled", "eof"):
  started = time.monotonic()
  proc = subprocess.run([collector, "--limits-only"], env=dict(env, CODEX_RPC_MODE=mode),
                        capture_output=True, text=True, check=True, timeout=7)
  elapsed = time.monotonic() - started
  record = json.loads(proc.stdout)
  if mode in ("batched", "split"):
    assert record["usageStatusText"] == "", record
    assert record["tierLabel"] == "prolite", record
    assert record["limits"] == [{"label": "Weekly (7-day)", "percent": 0.25, "resetsAt": ""}], record
    print(f"ok - Codex collector reads {mode} notifications and replies")
  else:
    assert record["usageStatusText"] == "Codex limits unavailable", record
    assert record["authHelpText"] == "account/read", record
    if mode == "eof":
      assert elapsed < 3, f"EOF took {elapsed:.2f}s"
    print(f"ok - Codex collector handles {mode} partial replies without hanging")
PY
