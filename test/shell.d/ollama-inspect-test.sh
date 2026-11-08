#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - "$ROOT/bin/omarchy-agent-inspect-ollama" <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import subprocess
import sys
import threading

calls = []
running = [{"name": "gemma4", "context_length": 4096}]

class Ollama(BaseHTTPRequestHandler):
  def do_POST(self):
    payload = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
    calls.append(("POST", self.path, payload))
    if self.path != "/api/show":
      self.send_error(404)
      return
    self.reply({
      "details": {"quantization_level": "Q4_K_M"},
      "capabilities": ["completion", "vision"],
      "model_info": {"general.architecture": "gemma4", "gemma4.context_length": 131072},
    })

  def do_GET(self):
    calls.append(("GET", self.path))
    if self.path != "/api/ps":
      self.send_error(404)
      return
    self.reply({"models": running})

  def reply(self, payload):
    self.send_response(200)
    self.end_headers()
    self.wfile.write(json.dumps(payload).encode())

  def log_message(self, *args):
    pass

with HTTPServer(("127.0.0.1", 0), Ollama) as server:
  worker = threading.Thread(target=server.serve_forever)
  worker.start()
  try:
    def inspect(model):
      output = subprocess.check_output(
        [sys.executable, sys.argv[1], model, "--port", str(server.server_port), "--json"],
        timeout=5,
      )
      return json.loads(output)

    report = inspect("gemma4:latest")
    assert report == {
      "model": "gemma4:latest",
      "quantization": "Q4_K_M",
      "capabilities": ["completion", "vision"],
      "max_context_tokens": 131072,
      "loaded": True,
      "active_context_tokens": 4096,
    }, report
    assert calls == [("POST", "/api/show", {"model": "gemma4:latest"}), ("GET", "/api/ps")], calls

    running[:] = [{"name": "gemma4:other", "context_length": 8192}]
    report = inspect("gemma4")
    assert not report["loaded"] and report["active_context_tokens"] is None, report
    assert report["max_context_tokens"] == 131072, report

    invalid = subprocess.run(
      [sys.executable, sys.argv[1], "gemma4", "--port", "65536"],
      capture_output=True, timeout=5,
    )
    assert invalid.returncode == 2 and b"between 1 and 65535" in invalid.stderr, invalid.stderr
  finally:
    server.shutdown()
    worker.join()
PY

pass "Ollama inspect reports the advertised and active context without starting a model"
