#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

python3 - "$ROOT" <<'PY'
import contextlib
import http.client
import io
import json
import os
from pathlib import Path
import sys
import tempfile
from unittest.mock import patch

command = Path(sys.argv[1]) / "bin/omarchy-file-search-semantic"
code = compile(command.read_text().split("<<'PY'\n", 1)[1].rsplit("\nPY", 1)[0], str(command), "exec")
tags = {"models": [{"name": "embeddinggemma:latest", "digest": "revision-a"}]}
show = {"capabilities": ["embedding"]}


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


with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"XDG_CACHE_HOME": str(Path(tmp) / "cache"), "OLLAMA_HOST": "https://remote.invalid"}):
    first, second = Path(tmp) / "budget.md", Path(tmp) / "plants.md"
    first.write_text("Travel expense receipts")
    second.write_text("Water the plants")
    args = ["reimbursement", str(first), str(second), "--model", "embeddinggemma", "--json"]
    status, calls, output = run(args, [tags, show, {"embeddings": [[1, 0]]}, {"embeddings": [[3, 0]]}, {"embeddings": [[0, 2]]}])
    assert status == 0, output
    results = json.loads(output)
    assert [item["file"] for item in results] == [str(first), str(second)]
    assert [item["score"] for item in results] == [1, 0]
    assert all(payload["truncate"] is False for endpoint, payload in calls if endpoint == "/api/embed")
    print("ok - ranks actual passages by cosine similarity over loopback with truncation disabled")

    status, calls, output = run(args, [tags, show, {"embeddings": [[1, 0]]}])
    assert status == 0 and len([call for call in calls if call[0] == "/api/embed"]) == 1, output
    cache_files = list((Path(tmp) / "cache/omarchy/semantic-search").glob("*.json"))
    assert all(item.stat().st_mode & 0o077 == 0 for item in cache_files)
    assert all("receipts" not in item.read_text() for item in cache_files)
    print("ok - reuses private embedding caches without storing source text")

    first.write_text("Updated travel budget")
    status, calls, output = run(args, [tags, show, {"embeddings": [[1, 0]]}, {"embeddings": [[2, 0]]}])
    assert status == 0 and len([call for call in calls if call[0] == "/api/embed"]) == 2, output
    revised = {"models": [{**tags["models"][0], "digest": "revision-b"}]}
    status, calls, output = run(args, [revised, show, {"embeddings": [[1, 0]]}, {"embeddings": [[2, 0]]}, {"embeddings": [[0, 1]]}])
    assert status == 0 and len([call for call in calls if call[0] == "/api/embed"]) == 3, output
    print("ok - content edits and model revision changes invalidate cached embeddings")

    status, calls, output = run(args, [tags, {**show, "remote_host": "https://ollama.com"}])
    assert status == 1 and all(endpoint != "/api/embed" for endpoint, _ in calls)
    status, calls, output = run(args, [tags, show, {"embeddings": [[0, 0]]}])
    assert status == 1
    first.write_bytes(b"binary\0data")
    status, calls, output = run(args, [])
    assert status == 1 and not calls
    print("ok - rejects cloud models, unusable embeddings and binary files without partial results")
PY
