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

command = Path(sys.argv[1]) / "bin/omarchy-agent-benchmark-ollama"
code = compile(command.read_text().split("<<'PY'\n", 1)[1].rsplit("\nPY", 1)[0], str(command), "exec")


def run(args, replies):
  calls = []
  output = io.StringIO()

  class Connection:
    def __init__(self, host, port, timeout):
      assert (host, port) == ("127.0.0.1", 11434)

    def request(self, method, endpoint, body, headers):
      calls.append((endpoint, json.loads(body) if body else None))

    def getresponse(self):
      self.body = json.dumps(replies.pop(0)).encode()
      self.status = 200
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
warm = {"done": True, "load_duration": 500000000}
sample = {"done": True, "eval_count": 20, "eval_duration": 2000000000}
status, calls, output = run(
  ["gemma4", "--runs", "3", "--json"],
  [tags, show, warm, sample, {**sample, "eval_duration": 1000000000}, {**sample, "eval_duration": 4000000000}],
)
assert status == 0, output
report = json.loads(output)
assert report["load_seconds"] == 0.5 and report["median_tokens_per_second"] == 10
assert len(report["runs"]) == 3 and calls[2][1]["prompt"] == "Reply with one word: ready."
assert calls[2][1]["options"]["num_predict"] == 1
assert all(call[1]["options"]["num_predict"] == 128 for call in calls[3:])
print("ok - separates warm-up from generation and computes the median from nanosecond timings")

for args, replies in [
  (["missing"], [tags]),
  (["gemma4"], [tags, {**show, "remote_model": "cloud"}]),
  (["gemma4"], [tags, {"capabilities": ["embedding"]}]),
  (["gemma4", "--runs", "0"], []),
]:
  status, calls, output = run(args, replies)
  assert status != 0
  assert all(endpoint != "/api/generate" for endpoint, _ in calls)
print("ok - rejects absent, cloud and non-text models, and invalid bounds before generation")

for bad in [
  {**sample, "eval_duration": 0},
  {**sample, "eval_count": -1},
  {**sample, "eval_duration": float("nan")},
  {**sample, "done": False},
]:
  status, calls, output = run(["gemma4", "--runs", "1", "--json"], [tags, show, warm, bad])
  assert status == 1 and "median_tokens_per_second" not in output
print("ok - refuses incomplete or invalid metrics instead of publishing misleading throughput")
PY
