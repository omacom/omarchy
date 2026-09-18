# RSS reader catalogue

`shell/plugins/panels/news/feeds.json` is the authoritative catalogue for curated feeds. Each entry contains its stable ID, display metadata, feed URL, pack membership, and explicit article URL policy. IDs identify saved subscriptions and caches; preserve them when changing a publisher's URL or label. Omarchy remains pinned, outside optional packs. The `tech` pack follows catalogue order.

The Python fetcher reads this package-owned file once at startup. User settings and network responses cannot replace its curated URL policies. `article_hosts`, `article_path_prefix`, and `allow_external_articles` retain their existing fetcher semantics; external article links require an explicit exception.

The QML service imports the checked-in `FeedCatalog.js`. The plugin manifest's `enabledFeeds.options` is also generated. Other manifest fields remain hand-authored. The official collection uses the generated official feed metadata.

After editing the catalogue, run from the repository root:

```bash
python3 agents/generate-rss-catalog.py
bash test/shell.d/rss-reader-catalog-test.sh
```

Commit `feeds.json` and both generated outputs together. `python3 agents/generate-rss-catalog.py --check` reports stale outputs without changing files, and the shell test runner includes this check. Generation is a development step; installation and opening the reader need no generator or asynchronous catalogue load.
