#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

python3 "$ROOT/agents/generate-rss-catalog.py" --check

python3 - "$ROOT" <<'PY'
import copy
import importlib.util
import io
import json
import sys
import tempfile
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch

root = Path(sys.argv[1])
plugin = root / "shell/plugins/panels/news"

def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

generator = load("generator", root / "agents/generate-rss-catalog.py")
reader = load("reader", plugin / "fetch_news.py")
feeds = generator.load_catalog(plugin / "feeds.json")
assert reader.SOURCE_CATALOG == {feed["id"]: feed for feed in feeds}
assert reader.TECH_FEED_IDS == tuple(feed["id"] for feed in feeds if "tech" in feed["packs"])
assert reader.FEED_URL == "https://omarchy.org/news/rss.xml"

with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    for name in ("feeds.json", "manifest.json"):
        (fixture / name).write_bytes((plugin / name).read_bytes())
    expected = generator.outputs(fixture)
    for path, content in expected.items():
        path.write_text(content)
    assert generator.outputs(fixture) == expected, "generation is not deterministic"
    with patch.object(generator, "PLUGIN", fixture), patch.object(sys, "argv", ["generator", "--check"]), redirect_stdout(io.StringIO()):
        assert generator.main() == 0
        generated = fixture / "FeedCatalog.js"
        generated.write_text("stale")
        assert generator.main() == 1
        assert generated.read_text() == "stale", "--check must not rewrite output"
        generated.write_text(expected[generated])
        manifest = json.loads((fixture / "manifest.json").read_text())
        next(entry for entry in manifest["barWidget"]["schema"] if entry["key"] == "enabledFeeds")["options"] = []
        (fixture / "manifest.json").write_text(json.dumps(manifest))
        assert generator.main() == 1, "stale manifest options must fail"

    changed = copy.deepcopy(feeds)
    changed[1].update(name="Updated publisher", url="https://news.ycombinator.com/updated-rss", packs=[])
    (fixture / "feeds.json").write_text(json.dumps(changed))
    updated = generator.outputs(fixture)
    assert "Updated publisher" in updated[fixture / "FeedCatalog.js"]
    assert "https://news.ycombinator.com/updated-rss" in updated[fixture / "FeedCatalog.js"]
    options = next(entry["options"] for entry in json.loads(updated[fixture / "manifest.json"])["barWidget"]["schema"] if entry["key"] == "enabledFeeds")
    assert options[0]["label"] == "Updated publisher"
    assert '"hacker-news"' not in updated[fixture / "FeedCatalog.js"].split("var techFeedIds = ")[1]
    original = json.loads((plugin / "manifest.json").read_text())
    regenerated = json.loads(updated[fixture / "manifest.json"])
    for manifest in (original, regenerated):
        next(entry for entry in manifest["barWidget"]["schema"] if entry["key"] == "enabledFeeds").pop("options")
    assert original == regenerated, "generation changed hand-authored settings"

    invalid = [feeds + [feeds[0]], [feed for feed in feeds if feed["id"] != "omarchy"]]
    for key, value in (("article_hosts", []), ("allow_external_articles", "true"), ("url", "http://omarchy.org/news/rss.xml")):
        candidate = copy.deepcopy(feeds)
        candidate[0][key] = value
        invalid.append(candidate)
    for candidate in invalid:
        (fixture / "feeds.json").write_text(json.dumps(candidate))
        try:
            generator.outputs(fixture)
        except ValueError:
            pass
        else:
            raise AssertionError("invalid catalogue accepted")
PY
pass "catalogue drives Python and generated metadata; generation is deterministic and check-only"
pass "stale outputs and invalid feed policies fail; hand-authored manifest settings survive"

run_node_test <<'JS'
const catalog = requireFromRoot('shell/plugins/panels/news/FeedCatalog.js')
const feeds = requireFromRoot('shell/plugins/panels/news/feeds.json')
const display = feed => Object.fromEntries(['id', 'name', 'description', 'category', 'url'].map(key => [key, feed[key]]))
assertDeepEqual(catalog.officialFeed, display(feeds.find(feed => feed.id === 'omarchy')), 'official feed metadata comes from the catalogue')
assertDeepEqual(catalog.feeds, feeds.filter(feed => feed.id !== 'omarchy').map(display), 'generated JavaScript preserves publisher order and metadata')
assertDeepEqual(catalog.techFeedIds, feeds.filter(feed => feed.packs.includes('tech')).map(feed => feed.id), 'tech pack membership comes from the catalogue')
const fs = require('fs')
const service = fs.readFileSync(path.join(root, 'shell/plugins/panels/news/Service.qml'), 'utf8')
const body = service.match(/function listSetting\(name\) \{([\s\S]*?)\n  \}/)[1]
const select = new Function('setting', 'techFeedIds', 'feedCatalog', 'name', body)
assertDeepEqual(select((key, fallback) => key === 'feedPack' ? 'Omarchy + Tech top 10' : fallback, catalog.techFeedIds, catalog.feeds, 'enabledFeeds'), catalog.techFeedIds, 'legacy tech pack selection still works')
assertDeepEqual(select(() => ['new-publisher', 'unknown'], [], [{id: 'new-publisher'}], 'enabledFeeds'), ['new-publisher'], 'optional feeds can be selected independently of tech pack membership')
JS
