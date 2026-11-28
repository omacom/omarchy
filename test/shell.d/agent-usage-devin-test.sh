#!/bin/bash

# The Devin collector's native session database: its totals are reused across
# refreshes while the files are unchanged, and read again on any change.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *
from unittest import mock

freeze_today()
sandbox()
statements = []
during_read = []
writer = None


def reply(tokens, rowid=None):
  message = {"content": "a transcript", "metadata": {"generation_model": "devin-m", "metrics": {"input_tokens": tokens}}}
  writer.execute("INSERT OR REPLACE INTO message_nodes (rowid, session_id, created_at, chat_message) VALUES (?, 's1', ?, ?)",
                 (rowid, int(fixture_now().timestamp()), json.dumps(message)))
  writer.commit()


def plant():
  """The CLI's database as it keeps it: behind a symlink, open in WAL mode, so a
  commit lands in the -wal file and leaves the database file as it was."""
  global writer
  real = data_home() / "devin" / "real.db"
  link = data_home() / "devin" / "cli" / "sessions.db"
  link.parent.mkdir(parents=True, exist_ok=True)
  link.symlink_to(real)
  writer = sqlite3.connect(real)
  writer.executescript("PRAGMA journal_mode = wal; PRAGMA wal_autocheckpoint = 0;")
  writer.executescript("CREATE TABLE message_nodes (session_id text, created_at integer, chat_message text);"
                       "CREATE TABLE prompt_history (session_id text, timestamp integer);")
  writer.execute("INSERT INTO prompt_history VALUES ('s1', ?)", (int(fixture_now().timestamp()),))
  reply(100)
  reply(20, rowid=2)


def devin(*args, wait=900, module=None):
  """A run `wait` seconds after the last (None: with no scan kept), and its
  statements: a database is read from the PRAGMA that makes it read-only."""
  for path in (scan_cache_files("devin") + scan_cache_files("devin-native")) if wait is None else []:
    path.unlink()
  if wait and scan_cache_files("devin"):
    age_scan_cache("devin", wait)
  real_connect = sqlite3.connect

  def trace(statement):
    statements.append(statement)
    if "FROM prompt_history" in statement and during_read:
      during_read.pop()()

  def traced(*a, **k):
    conn = real_connect(*a, **k)
    conn.set_trace_callback(trace)
    return conn

  statements.clear()
  with mock.patch.object(sqlite3, "connect", traced):
    record = run_main(module or load_collector("devin"), *args)
  return record["todayTotalTokens"], sum(s.startswith("PRAGMA query_only") for s in statements), record


# The scan reuse windows every collector keeps.
check_scan_cache(Adapter("devin", plant=plant, grow=lambda: reply(1)))

sandbox()
plant()
expect("the first run reads the database", devin()[:2], (120, 1))
write_pi_session(home() / ".pi" / "agent" / "sessions" / "a" / "s.jsonl", [pi_reply("devin", 7, id="p1"), pi_reply("devin", 3, id="p0", timestamp=(fixture_now() - timedelta(days=1)).isoformat())])
tokens, reads, kept = devin()
expect("a refresh after an unchanged database skips it, and still counts the pi session", (tokens, reads), (127, 0))
forced = devin("--force")
expect("--force reads it again, to the same totals", (forced[1], forced[2] | {"updatedAt": 0}), (1, kept | {"updatedAt": 0}))

reply(30)
expect("a commit that stays in the WAL is read", devin()[:2], (157, 1))
writer.execute("DELETE FROM message_nodes WHERE rowid = 3")
reply(5, rowid=3)
expect("a row replaced under the same row id is read", devin()[:2], (132, 1))

for damage in (lambda stats: stats.pop("todaySessions"), lambda stats: stats["modelUsage"]["devin-m"].update(inputTokens="1"),
               lambda stats: stats.update(activeDates=kept["activeDates"][-1], activeDays=10),
               lambda stats: stats.update(activeDates=kept["activeDates"][:1] * 2, activeDays=2),
               lambda stats: stats.update(activeDates=["2026-13-45", kept["activeDates"][-1]], activeDays=2)):
  edit_scan_cache("devin-native", lambda data: damage(data["stats"]))
  expect("a cache that isn't the shape Stats writes is read again", devin()[:2], (132, 1))
edit_scan_cache("devin-native", lambda data: data["stats"].update(totalPrompts=10 ** 16))
expect("a total past number()'s ceiling is kept exact", devin()[2]["totalPrompts"], 10 ** 16 + 2)

# A read that raced a write sees one commit and serves its run; the refresh around it is kept as ever.
prompts = devin("--force")[2]["totalPrompts"]
during_read.append(lambda: (writer.execute("INSERT INTO prompt_history VALUES ('s1', ?)", (int(fixture_now().timestamp()),)), reply(1000)))
raced = devin("--force", wait=None)
expect("a read that raced a write sees one commit", (raced[0], raced[2]["totalPrompts"]), (132, prompts))
expect("a limits-only refresh reuses it", devin("--limits-only", wait=0)[:2], (132, 0))
expect("until it expires, then reads the native totals again", devin("--limits-only")[:2], (1132, 1))
module = load_collector("devin")
module.today = lambda days=iter([module.today()]): next(days, "2999-01-01")
served = devin("--force", wait=None, module=module)[0]
expect("a scan across midnight serves the run and keeps nothing", (served, *devin(wait=0)[:2]), (1132, 1132, 1))
PY
