#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp"
unset XDG_DATA_HOME || true

activity="$ROOT/bin/omarchy-activity"

[[ -x $activity ]] || fail "omarchy-activity is executable"

# Empty database reports an empty map.
[[ $("$activity" top) == "{}" ]] || fail "activity top is empty on a fresh database"
pass "activity top is empty on a fresh database"

"$activity" record app firefox "Firefox" || fail "activity record app succeeds"
"$activity" record app firefox || fail "activity record repeat succeeds"
"$activity" record menu style.theme || fail "activity record menu succeeds"

top_json=$("$activity" top)
[[ $(jq -r '.firefox.count' <<<"$top_json") == "2" ]] ||
  fail "activity top counts repeat records" "$top_json"
pass "activity top counts repeat records"

jq -e '.firefox.lastUsed > 0 and .["style.theme"].count == 1' <<<"$top_json" >/dev/null ||
  fail "activity top reports lastUsed per target" "$top_json"
pass "activity top reports lastUsed per target"

# Kind filter scopes the map to one namespace.
kind_json=$("$activity" top --kind app)
jq -e 'has("firefox") and (has("style.theme") | not)' <<<"$kind_json" >/dev/null ||
  fail "activity top --kind filters namespaces" "$kind_json"
pass "activity top --kind filters namespaces"

# Visit history is capped so the database cannot grow per keystroke forever.
for _ in $(seq 1 12); do "$activity" record app firefox >/dev/null; done
visit_count=$(python3 -c "import sqlite3,os; print(sqlite3.connect(os.environ['HOME'] + '/.local/share/omarchy/activity.db').execute(\"select count(*) from visits where target='firefox'\").fetchone()[0])")
(( visit_count <= 10 )) || fail "activity caps stored visits per target" "$visit_count"
pass "activity caps stored visits per target"

# Legacy import takes the valid targets and skips the malformed ones.
cat >"$test_tmp/legacy.json" <<'JSON'
{"kitty": {"count": 4, "lastUsed": 1700000000000}, "broken": 7, "zero": {"count": 0, "lastUsed": 5}}
JSON
import_out=$("$activity" import-frecency "$test_tmp/legacy.json")
[[ $import_out == "imported 1 targets" ]] || fail "activity import reports imported targets" "$import_out"
pass "activity import reports imported targets"

jq -e '.kitty.count == 4' <<<"$("$activity" top)" >/dev/null ||
  fail "activity import preserves legacy counts"
pass "activity import preserves legacy counts"

"$activity" import-frecency "$test_tmp/missing.json" >/dev/null 2>&1 &&
  fail "activity import fails on a missing file"
pass "activity import fails on a missing file"

# Scores follow the bucket weights: three fresh visits outrank one.
"$activity" record app alpha >/dev/null
"$activity" record app alpha >/dev/null
"$activity" record app alpha >/dev/null
"$activity" record app beta >/dev/null
ranked=$("$activity" top --kind app)
jq -e '.alpha.score > .beta.score' <<<"$ranked" >/dev/null ||
  fail "activity scores frequency" "$ranked"
pass "activity scores frequency"
[[ $(jq -r 'keys[0]' <<<"$ranked") == "alpha" ]] ||
  fail "activity orders by score" "$ranked"
pass "activity orders by score"

# ...while recency still beats stale frequency: five 100-day-old visits lose
# to one fresh visit (5x10 < 1x100).
python3 - <<'PY'
import os, sqlite3, time
db = os.environ["HOME"] + "/.local/share/omarchy/activity.db"
old = int(time.time() * 1000) - 100 * 86400 * 1000
c = sqlite3.connect(db)
c.execute("INSERT INTO items(target, kind) VALUES('stale-multi', 'app')")
c.executemany("INSERT INTO visits(target, at) VALUES('stale-multi', ?)", [(old,)] * 5)
c.execute("INSERT INTO items(target, kind) VALUES('fresh-single', 'app')")
c.commit()
PY
"$activity" record app fresh-single >/dev/null
ranked=$("$activity" top --kind app)
jq -e '.["fresh-single"].score > .["stale-multi"].score' <<<"$ranked" >/dev/null ||
  fail "activity scores recency over stale frequency" "$ranked"
pass "activity scores recency over stale frequency"

# Forgetting erases a target and is idempotent.
[[ $("$activity" forget beta) == "forgot beta" ]] || fail "activity forget confirms"
pass "activity forget confirms"
jq -e 'has("beta") | not' <<<"$("$activity" top)" >/dev/null ||
  fail "activity forget erases the target"
pass "activity forget erases the target"
"$activity" forget never-seen >/dev/null || fail "activity forget is idempotent"
pass "activity forget is idempotent"

# Recording prunes stale single-visit noise but keeps revisited history.
python3 - <<'PY'
import os, sqlite3, time
db = os.environ["HOME"] + "/.local/share/omarchy/activity.db"
old = int(time.time() * 1000) - 100 * 86400 * 1000
c = sqlite3.connect(db)
c.execute("INSERT INTO items(target, kind) VALUES('stale-single', 'app')")
c.execute("INSERT INTO visits(target, at) VALUES('stale-single', ?)", (old,))
c.commit()
PY
"$activity" record app keeper >/dev/null
pruned=$("$activity" top --kind app)
jq -e 'has("stale-single") | not' <<<"$pruned" >/dev/null ||
  fail "activity prunes stale single visits" "$pruned"
pass "activity prunes stale single visits"
jq -e 'has("stale-multi") and has("keeper")' <<<"$pruned" >/dev/null ||
  fail "activity keeps revisited and fresh targets" "$pruned"
pass "activity keeps revisited and fresh targets"

# Stats exposes per-kind coverage for spotting dead sources.
stats=$("$activity" stats)
jq -e '.kinds.app.targets > 0 and .kinds.app.visits > 0 and .kinds.app.newest > 0 and .targets > 0' <<<"$stats" >/dev/null ||
  fail "activity stats reports per-kind coverage" "$stats"
pass "activity stats reports per-kind coverage"

# Pinning floats a target above scored results and releases cleanly.
"$activity" record app plain >/dev/null
"$activity" record app lucky >/dev/null
[[ $("$activity" pin lucky) == "pinned lucky" ]] || fail "activity pin confirms"
pass "activity pin confirms"
[[ $(jq -r 'keys_unsorted | map(select(. == "lucky" or . == "plain")) | join(",")' <<<"$("$activity" top --kind app)") == "lucky,plain" ]] ||
  fail "activity pin outranks scored results"
pass "activity pin outranks scored results"
"$activity" unpin lucky >/dev/null || fail "activity unpin succeeds"
pass "activity unpin succeeds"
"$activity" pin ghost-target >/dev/null 2>&1 &&
  fail "activity pin rejects unknown targets"
pass "activity pin rejects unknown targets"

# Views blend into the default ranking at a fraction of a pick: history
# accumulates from sightings, decisions come from picks.
"$activity" record app seen-app "" --via view >/dev/null
"$activity" record app picked-app >/dev/null
blended=$("$activity" top --kind app)
jq -e '.["picked-app"].score == 100 and .["seen-app"].score == 25' <<<"$blended" >/dev/null ||
  fail "activity blends views at a fraction" "$blended"
pass "activity blends views at a fraction"
[[ $(jq -r 'keys_unsorted | map(select(. == "picked-app" or . == "seen-app")) | join(",")' <<<"$blended") == "picked-app,seen-app" ]] ||
  fail "activity ranks picks above blended views" "$blended"
pass "activity ranks picks above blended views"
jq -e 'has("seen-app") | not' <<<"$("$activity" top --via pick)" >/dev/null ||
  fail "activity top --via pick excludes views"
pass "activity top --via pick excludes views"
jq -e '.["seen-app"].count == 1' <<<"$("$activity" top --via all)" >/dev/null ||
  fail "activity top --via all includes views"
pass "activity top --via all includes views"
jq -e '.vias.view.visits > 0 and .vias.pick.visits > 0' <<<"$("$activity" stats)" >/dev/null ||
  fail "activity stats splits provenance"
pass "activity stats splits provenance"

# An empty title never clobbers a known label.
"$activity" record app titled "Real Title" >/dev/null
"$activity" record app titled "" --via view >/dev/null
[[ $(python3 -c "import sqlite3,os; print(sqlite3.connect(os.environ['HOME'] + '/.local/share/omarchy/activity.db').execute(\"select title from items where target='titled'\").fetchone()[0])") == "Real Title" ]] ||
  fail "activity keeps known titles on empty re-record"
pass "activity keeps known titles on empty re-record"

# Gtk recent files seed the file namespace; non-files and dupes are skipped.
[[ $("$activity" import-xbel "$ROOT/test/shell.d/fixtures/activity-recent.xbel") == "imported 2 files" ]] ||
  fail "activity import-xbel reports imported files"
pass "activity import-xbel reports imported files"
xbel_top=$("$activity" top --kind file --via all)
jq -e '.["/home/user/Documents/report.pdf"].count == 1 and .["/home/user/Music/song one.mp3"].count == 1' <<<"$xbel_top" >/dev/null ||
  fail "activity import-xbel seeds file visits" "$xbel_top"
pass "activity import-xbel seeds file visits"

"$activity" import-xbel "$test_tmp/missing.xbel" >/dev/null 2>&1 &&
  fail "activity import-xbel fails on a missing file"
pass "activity import-xbel fails on a missing file"

# rank-files floats scored paths first by score, keeping input order otherwise.
"$activity" record file /tmp/used-twice >/dev/null
"$activity" record file /tmp/used-twice >/dev/null
"$activity" record file /tmp/used-once >/dev/null
ranked=$(printf '%s\n' /tmp/fresh /tmp/used-once /tmp/used-twice | "$activity" rank-files)
[[ $ranked == "/tmp/used-twice
/tmp/used-once
/tmp/fresh" ]] || fail "activity rank-files orders by score" "$ranked"
pass "activity rank-files orders by score"

# ...and never breaks its caller: empty in, empty out, no database, no problem.
[[ -z $(printf '' | "$activity" rank-files) ]] || fail "activity rank-files passes empty through"
pass "activity rank-files passes empty through"
printf '%s\n' /tmp/a /tmp/a /tmp/b | "$activity" rank-files | sort | uniq -c | grep -q ' 1 /tmp/a' ||
  fail "activity rank-files dedupes"
pass "activity rank-files dedupes"

# A record blocked behind a locked database retries instead of dropping.
python3 -c "import sqlite3,os; sqlite3.connect(os.environ['HOME'] + '/.local/share/omarchy/activity.db').executescript('CREATE TABLE IF NOT EXISTS items(target TEXT PRIMARY KEY, kind TEXT NOT NULL, title TEXT NOT NULL DEFAULT \'\', bonus INTEGER NOT NULL DEFAULT 0); CREATE TABLE IF NOT EXISTS visits(target TEXT NOT NULL, at INTEGER NOT NULL);')"
python3 - "$test_tmp" <<'PY' &
import sqlite3, os, sys, time
conn = sqlite3.connect(os.environ["HOME"] + "/.local/share/omarchy/activity.db")
conn.execute("BEGIN EXCLUSIVE")
conn.execute("INSERT INTO items(target, kind) VALUES('lock-holder', 'app')")
time.sleep(2.5)
conn.commit()
PY
locker=$!
"$activity" record app survives-lock >/dev/null || fail "activity record retries past a lock"
wait "$locker"
jq -e 'has("survives-lock")' <<<"$("$activity" top --via all)" >/dev/null ||
  fail "activity retried record landed"
pass "activity retried record landed"

# Composite key isolates identical target names across different kinds.
"$activity" record app shared-name "App Title" >/dev/null
"$activity" record cmd shared-name "Command Title" >/dev/null
app_scoped=$("$activity" top --kind app)
cmd_scoped=$("$activity" top --kind cmd)
jq -e 'has("shared-name")' <<<"$app_scoped" >/dev/null || fail "composite key preserves app target"
jq -e 'has("shared-name")' <<<"$cmd_scoped" >/dev/null || fail "composite key preserves cmd target"
pass "composite key isolates identical target names across kinds"

# Generic rank sorts stdin lines by kind score, keeping input order for unvisited items.
"$activity" record project /tmp/proj-high >/dev/null
"$activity" record project /tmp/proj-high >/dev/null
"$activity" record project /tmp/proj-low >/dev/null
proj_ranked=$(printf '%s\n' /tmp/proj-unknown /tmp/proj-low /tmp/proj-high | "$activity" rank --kind project)
[[ $proj_ranked == "/tmp/proj-high
/tmp/proj-low
/tmp/proj-unknown" ]] || fail "activity rank --kind orders by score" "$proj_ranked"
pass "activity rank --kind orders by score"

# import-zoxide seeds directories into kind='project'
cat >"$test_tmp/zoxide.txt" <<'EOF'
  10.0 /tmp/zo-high
   2.0 /tmp/zo-low
EOF
zo_out=$("$activity" import-zoxide "$test_tmp/zoxide.txt")
[[ $zo_out == "imported 2 projects from zoxide" ]] || fail "activity import-zoxide reports count" "$zo_out"
pass "activity import-zoxide reports count"

zo_top=$("$activity" top --kind project --via all)
jq -e '.["/tmp/zo-high"].count == 10 and .["/tmp/zo-low"].count == 2' <<<"$zo_top" >/dev/null ||
  fail "activity import-zoxide seeds visits matching score" "$zo_top"
pass "activity import-zoxide seeds visits matching score"

# import-agents seeds workspaces and sessions from Antigravity and Codex
mkdir -p "$test_tmp/ag" "$test_tmp/.codex"
cat >"$test_tmp/ag/history.jsonl" <<'EOF'
{"display": "Refactor database queries\nDetails here", "timestamp": 1788730000000, "workspace": "/tmp/ag-work", "conversationId": "ag-sess-1"}
EOF
cat >"$test_tmp/.codex/session_index.jsonl" <<'EOF'
{"id": "codex-sess-1", "thread_name": "Fix race condition", "updated_at": "2026-09-07T03:30:55Z"}
EOF
cat >"$test_tmp/.codex/config.toml" <<'EOF'
[projects."/tmp/codex-work"]
trust_level = "trusted"
EOF

agent_out=$("$activity" import-agents --antigravity "$test_tmp/ag/history.jsonl" --codex "$test_tmp/.codex/session_index.jsonl")
[[ $agent_out =~ "imported 2 projects and 2 agent sessions" ]] ||
  fail "activity import-agents reports imported counts" "$agent_out"
pass "activity import-agents reports imported counts"

ag_proj=$("$activity" top --kind project --via all)
jq -e 'has("/tmp/ag-work") and has("/tmp/codex-work")' <<<"$ag_proj" >/dev/null ||
  fail "activity import-agents seeds projects" "$ag_proj"
pass "activity import-agents seeds projects"

ag_sess=$("$activity" top --kind agent-session --via all)
jq -e 'has("ag-sess-1") and has("codex-sess-1")' <<<"$ag_sess" >/dev/null ||
  fail "activity import-agents seeds sessions" "$ag_sess"
pass "activity import-agents seeds sessions"

# search queries SQLite FTS5 index
search_out=$("$activity" search "Refactor queries" --kind agent-session)
jq -e 'length == 1 and .[0].target == "ag-sess-1" and .[0].label == "Refactor database queries"' <<<"$search_out" >/dev/null ||
  fail "activity search matches session title via FTS5" "$search_out"
pass "activity search matches session title via FTS5"

search_prefix=$("$activity" search "rac" --kind agent-session)
jq -e 'length == 1 and .[0].target == "codex-sess-1" and .[0].label == "Fix race condition"' <<<"$search_prefix" >/dev/null ||
  fail "activity search supports prefix matching" "$search_prefix"
pass "activity search supports prefix matching"

search_empty=$("$activity" search "nonexistentterm999" --kind agent-session)
jq -e 'length == 0' <<<"$search_empty" >/dev/null ||
  fail "activity search returns empty array for no match" "$search_empty"
pass "activity search returns empty array for no match"

