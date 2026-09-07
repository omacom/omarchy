#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

python3 - "$ROOT/shell/plugins/panels/news/fetch_news.py" <<'PY'
import importlib.util
import io
import json
import sys
import threading
from contextlib import redirect_stdout
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("reader", sys.argv[1])
reader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reader)
slow = reader.SOURCE_CATALOG["omarchy"]
fast = reader.SOURCE_CATALOG["ars-technica"]
release = threading.Event()
snapshots = []

class Output(io.StringIO):
    def flush(self):
        snapshot = json.loads(self.getvalue().splitlines()[-1])
        snapshots.append(snapshot)
        if any(item["id"] == "fast" for item in snapshot["items"]):
            release.set()

def load(source, *args):
    if source is slow:
        assert release.wait(3), "fast feed was blocked behind the slow feed"
    item_id = "slow" if source is slow else "fast"
    return ([{"id": item_id}], {"id": source["id"], "stale": False}, "")

with patch.object(reader, "selected_sources", return_value=[slow, fast]), \
     patch.object(reader, "cached_result", return_value={"items": [{"id": "cached"}]}), \
     patch.object(reader, "load_source", side_effect=load), redirect_stdout(Output()):
    assert reader.main(["--stream"]) == 0
assert len(snapshots) == 3
assert all(item["id"] == "cached" for item in snapshots[0]["items"])
assert not snapshots[0]["stale"] and not snapshots[0]["partial"]
assert all(state["cached"] and state["checking"] for state in snapshots[0]["sources"])
assert {item["id"] for item in snapshots[1]["items"]} == {"cached", "fast"}
assert {item["id"] for item in snapshots[2]["items"]} == {"slow", "fast"}

output = io.StringIO()
with patch.object(reader, "selected_sources", return_value=[slow]), \
     patch.object(reader, "fetch", side_effect=OSError("offline")), \
     patch.object(reader, "cached_result", return_value=None), redirect_stdout(output):
    assert reader.main([]) == 0
result = json.loads(output.getvalue())
assert result["items"] == [] and result["partial"]
assert result["sources"][0]["error"] == "offline"

for cached in (None, {"items": [{"id": "saved"}]}):
    output = io.StringIO()
    with patch.object(reader, "selected_sources", return_value=[slow]), \
         patch.object(reader, "fetch", side_effect=OSError("offline")), \
         patch.object(reader, "cached_result", return_value=cached), redirect_stdout(output):
        assert reader.main(["--stream"]) == 0
    initial, final = map(json.loads, output.getvalue().splitlines())
    assert initial["sources"][0]["checking"] and not initial["stale"]
    assert initial["sources"][0]["error"] == ""
    assert not final["sources"][0]["checking"]
    assert final["sources"][0]["error"] == "offline"
    assert final["sources"][0]["cached"] == (cached is not None)
    assert final["stale"] == (cached is not None)
PY
pass "cached articles emit before fetching and fast feeds bypass slow feeds"
pass "total feed failure retains structured source errors"
pass "streamed sources stay checking until resolved, with offline state only after failure"

run_node_test <<'JS'
const fs = require('fs')
const manager = fs.readFileSync(path.join(root, 'shell/plugins/panels/news/FeedManager.qml'), 'utf8')
const body = manager.match(/function sourceStatus\(url\) \{([\s\S]*?)\n  \}/)[1]
const status = new Function('sourceState', 'news', 'url', body)
const label = state => status(() => state, {refreshing: false}, 'https://example.com/feed')
assertEqual(label(null), 'WAITING', 'unresolved feeds are not live')
assertEqual(label({checking: true, cached: false, error: ''}), 'CHECKING', 'first fetch is checking')
assertEqual(label({checking: true, cached: true, error: ''}), 'CHECKING', 'cached snapshot is checking')
assertEqual(label({checking: false, cached: true, error: ''}), 'CACHED', 'fresh cache is labelled cached')
assertEqual(label({checking: false, cached: false, error: ''}), 'LIVE', 'successful fetch is live')
assertEqual(label({checking: false, cached: true, stale: true, error: 'offline'}), 'CACHED', 'failed refresh retains cached state')
assertEqual(label({checking: false, cached: false, error: 'offline'}), 'ERROR', 'failed first fetch is an error')
JS
