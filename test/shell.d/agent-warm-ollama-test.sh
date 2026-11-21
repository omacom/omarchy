#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

python3 - "$ROOT" <<'PY'
import contextlib
import http.client
import io
import json
from pathlib import Path
import sys
from unittest.mock import patch

command = Path(sys.argv[1]) / "bin/omarchy-agent-warm-ollama"
code = compile(command.read_text().split("<<'PY'\n", 1)[1].rsplit("\nPY", 1)[0], str(command), "exec")


def run(args, replies):
  calls = []
  output = io.StringIO()

  class Connection:
    def __init__(self, host, port, timeout):
      assert (host, port) == ("127.0.0.1", 11434)

    def request(self, method, endpoint, body, headers):
      calls.append((method, endpoint, json.loads(body) if body else None))

    def getresponse(self):
      item = replies.pop(0)
      if isinstance(item, Exception):
        raise item
      self.status = 200
      self.body = json.dumps(item).encode()
      return self

    def read(self, limit):
      return self.body[:limit]

    def close(self):
      pass

  with (
    patch.object(sys, "argv", [str(command), *args]),
    patch.object(http.client, "HTTPConnection", Connection),
    contextlib.redirect_stdout(output),
    contextlib.redirect_stderr(output),
  ):
    try:
      exec(code, {"__name__": "__main__"})
      status = 0
    except SystemExit as error:
      status = error.code
  return status, calls, output.getvalue()


tags = {"models": [{"name": "gemma4:latest"}]}
show = {"capabilities": ["completion"]}
status, calls, output = run(["gemma4", "--minutes", "15"], [tags, show, {"done": True}])
assert status == 0, output
assert calls[-1] == (
  "POST",
  "/api/generate",
  {"model": "gemma4:latest", "prompt": "", "stream": False, "keep_alive": "15m"},
)
print("ok - warms only the installed model, with an empty prompt and a bounded keep-alive")

for args, replies in [
  (["absent"], [tags]),
  (["gemma4"], [tags, {**show, "remote_host": "https://ollama.com"}]),
  (["gemma4"], [tags, {"capabilities": ["embedding"]}]),
]:
  status, calls, output = run(args, replies)
  assert status == 1, output
  assert all(endpoint != "/api/generate" for _, endpoint, _ in calls)
print("ok - rejects missing, cloud-backed and embedding-only models before loading")

status, calls, output = run(["gemma4", "--minutes", "0"], [])
assert status == 2 and not calls
status, calls, output = run(["gemma4"], [ConnectionRefusedError("daemon is stopped")])
assert status == 1 and "daemon is stopped" in output
status, calls, output = run(["gemma4"], [tags, show, {"done": False}])
assert status == 1 and "Loaded" not in output
print("ok - reports invalid durations, a stopped daemon and incomplete loads without success claims")
PY
