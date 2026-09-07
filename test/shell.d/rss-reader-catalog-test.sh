#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

python3 - "$ROOT" <<'PY'
import importlib.util
import json
import re
import sys
from pathlib import Path

plugin = Path(sys.argv[1]) / "shell/plugins/panels/news"
spec = importlib.util.spec_from_file_location("reader", plugin / "fetch_news.py")
reader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reader)
service = (plugin / "Service.qml").read_text()
catalog = json.loads(re.search(r"readonly property var feedCatalog: (\[[\s\S]*?\n  \])", service)[1])
tech_ids = json.loads(re.search(r"readonly property var techFeedIds: (\[[^\n]+\])", service)[1])
manifest = json.loads((plugin / "manifest.json").read_text())
options = next(entry["options"] for entry in manifest["barWidget"]["schema"] if entry["key"] == "enabledFeeds")
ids = [entry["id"] for entry in catalog]
assert ids == list(reader.TECH_FEED_IDS) == tech_ids == [entry["value"] for entry in options]
assert len(ids) == len(set(ids)), "duplicate curated feed"
assert set(reader.SOURCE_CATALOG) == {"omarchy", *ids}, "catalog membership differs"
for entry, option in zip(catalog, options):
    source = reader.SOURCE_CATALOG[entry["id"]]
    for key in ("id", "name", "category", "url"):
        assert entry[key] == source[key], f"{entry['id']}: {key} differs between QML and Python"
    assert option["label"] == entry["name"], f"{entry['id']}: manifest label differs"
    assert option["description"] == entry["description"], f"{entry['id']}: manifest description differs"
pinned = json.loads(re.search(r"var result = (\[\{[\s\S]*?\}\])", service)[1])[0]
for key, value in pinned.items():
    assert reader.SOURCE_CATALOG["omarchy"][key] == value, f"pinned feed {key} differs"
PY
pass "Python, QML and manifest feed catalogs agree on membership and shared metadata"
