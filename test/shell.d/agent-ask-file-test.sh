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
import tempfile
from unittest.mock import patch

command = Path(sys.argv[1]) / "bin/omarchy-agent-ask-file"
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

    with patch.object(sys, "argv", [str(command), *args]), patch.object(http.client, "HTTPConnection", Connection), contextlib.redirect_stdout(output), contextlib.redirect_stderr(output):
        try:
            exec(code, {"__name__": "__main__"})
            status = 0
        except SystemExit as error:
            status = error.code
    return status, calls, output.getvalue()


tags = {"models": [{"name": "gemma4:latest"}]}
show = {"capabilities": ["completion"], "model_info": {"gemma.context_length": 32768}}
with tempfile.TemporaryDirectory() as tmp:
    document = Path(tmp) / "notes $(touch surprise).md"
    original = "Ship the prototype.\nReview it on Friday.\n"
    document.write_text(original)
    args = [str(document), "When is the review?", "--model", "gemma4"]
    status, calls, output = run(args, [tags, show, {"done": True, "message": {"content": "Friday (line 2)."}}])
    assert status == 0 and output.strip() == "Friday (line 2).", output
    payload = calls[-1][1]
    content = json.loads(payload["messages"][1]["content"])
    assert content == {"question": "When is the review?", "document": "1: Ship the prototype.\n2: Review it on Friday."}
    assert document.read_text() == original and not (Path(tmp) / "surprise").exists()
    print("ok - sends the complete numbered text and question literally, preserving the source")

    for raw in [b"a" * 8193, b"binary\0data", b"\xff", b"\n" * 257, b""]:
        document.write_bytes(raw)
        status, calls, output = run(args, [])
        assert status == 1 and not calls, output
    print("ok - rejects oversized, binary, invalid UTF-8 and empty documents before contacting a model")

    document.write_text(original)
    for info in [{**show, "remote_host": "https://ollama.com"}, {**show, "model_info": {"gemma.context_length": 4096}}, {"capabilities": ["embedding"]}]:
        status, calls, output = run(args, [tags, info])
        assert status == 1 and all(endpoint != "/api/chat" for endpoint, _ in calls)
    print("ok - refuses cloud-backed, undersized-context and non-text models")

    status, calls, output = run(args, [tags, show, {"done": True, "message": {"content": ""}}])
    assert status == 1
    print("ok - reports an empty answer as a failure")
PY
