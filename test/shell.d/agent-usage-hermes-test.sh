#!/bin/bash

# The Hermes collector's own source: the state.db in Hermes' home and in each
# named profile under ~/.hermes/profiles. Hermes has no subscription, so it has
# no limits. The unused-machine record is held centrally by the partition test,
# and the scan cache by the contract check.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
import datetime as dt
import sqlite3

from agent_usage_fixtures import *

SCHEMA = """
CREATE TABLE sessions (id TEXT PRIMARY KEY, started_at REAL NOT NULL);
CREATE TABLE messages (id INTEGER PRIMARY KEY, session_id TEXT NOT NULL, role TEXT NOT NULL, timestamp REAL NOT NULL);
CREATE TABLE session_model_usage (
  session_id TEXT NOT NULL, model TEXT NOT NULL,
  input_tokens INTEGER NOT NULL DEFAULT 0, output_tokens INTEGER NOT NULL DEFAULT 0,
  cache_read_tokens INTEGER NOT NULL DEFAULT 0, cache_write_tokens INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (session_id, model)
);
"""


# A Hermes state.db with one session today, its prompt and reply, and usage
# for each model given as (name, base), every count being base plus a
# per-field offset.
def state_db(path, *models):
  path = Path(path)
  path.parent.mkdir(parents=True, exist_ok=True)
  conn = sqlite3.connect(path)
  conn.executescript(SCHEMA)
  now = time.time()
  conn.execute("INSERT INTO sessions VALUES ('session-1', ?)", (now,))
  conn.executemany("INSERT INTO messages VALUES (?, 'session-1', ?, ?)", [(1, "user", now), (2, "assistant", now)])
  for name, base in models:
    conn.execute("INSERT INTO session_model_usage VALUES ('session-1', ?, ?, ?, ?, ?)", (name, base, base + 10, base + 20, base + 30))
  conn.commit()
  conn.close()
  return path


def hermes(*args):
  return collect("hermes", *(args or ("--force",)))


# ---------------------------------------------------------------- state.db

sandbox()
state_db(home() / ".hermes" / "state.db", ("gpt-6-astra", 10), ("gpt-6-sol", 11))
record = hermes()
expect("Hermes reads each model's usage, today's totals, and its prompts and sessions from state.db", {
  "ready": record["ready"],
  "status": record["usageStatusText"],
  "astra": record["modelUsage"]["gpt-6-astra"],
  "solToday": record["todayTokensByModel"]["gpt-6-sol"],
  "today": record["todayTotalTokens"],
  "week": [len(record["recentDays"]), record["recentDays"][-1]["messageCount"]],
  "counts": [record["totalPrompts"], record["todayPrompts"], record["totalSessions"], record["todaySessions"]],
}, {
  "ready": True,
  "status": "",
  "astra": {"inputTokens": 10, "outputTokens": 20, "cacheReadInputTokens": 30, "cacheCreationInputTokens": 40},
  "solToday": 104,
  "today": 204,
  "week": [7, 204],
  "counts": [1, 1, 1, 1],
}, record)

# A state.db with no usage table still counts its sessions and prompts.
sandbox()
bare = state_db(home() / ".hermes" / "state.db")
conn = sqlite3.connect(bare)
conn.execute("DROP TABLE session_model_usage")
conn.commit()
conn.close()
record = hermes()
expect("a state.db without a usage table still counts its sessions and prompts",
       [record["usageStatusText"], record["totalSessions"], record["todayPrompts"], record["modelUsage"]], ["", 1, 1, {}], record)

# A start or a prompt stamped as text, or in the future, is no today.
sandbox()
odd = state_db(home() / ".hermes" / "state.db")
conn = sqlite3.connect(odd)
conn.execute("INSERT INTO sessions VALUES ('text', 'soon')")
conn.execute("INSERT INTO sessions VALUES ('future', ?)", (time.time() + 3 * 86400,))
conn.executemany("INSERT INTO messages VALUES (?, 'text', 'user', ?)", [(3, "soon"), (4, time.time() + 3 * 86400)])
conn.commit()
conn.close()
record = hermes()
expect("text and future times count in the totals but not today",
       [record["totalSessions"], record["todaySessions"], record["totalPrompts"], record["todayPrompts"]], [3, 1, 3, 1], record)

# A negative count is no count; it never nets out another row's usage.
sandbox()
netted = state_db(home() / ".hermes" / "state.db", ("gpt-6-astra", 10))
conn = sqlite3.connect(netted)
conn.execute("INSERT INTO sessions VALUES ('session-2', ?)", (time.time(),))
conn.execute("INSERT INTO session_model_usage VALUES ('session-2', 'gpt-6-astra', -5, 'many', 1e300, 0)")
conn.commit()
conn.close()
record = hermes()
expect("negative, text and huge counts are left out of the sums",
       record["modelUsage"]["gpt-6-astra"], {"inputTokens": 10, "outputTokens": 20, "cacheReadInputTokens": 30, "cacheCreationInputTokens": 40}, record)

# Named profiles live under ~/.hermes/profiles even when HERMES_HOME moves the
# default home elsewhere.
sandbox()
state_db(home() / "elsewhere" / "state.db", ("gpt-6-astra", 100))
state_db(home() / ".hermes" / "profiles" / "work" / "state.db", ("gpt-6-sol", 1000))
os.environ["HERMES_HOME"] = str(home() / "elsewhere")
record = hermes()
del os.environ["HERMES_HOME"]
expect("Hermes reads HERMES_HOME and every named profile",
       [record["modelUsage"]["gpt-6-astra"]["inputTokens"], record["modelUsage"]["gpt-6-sol"]["inputTokens"], record["totalSessions"], record["totalPrompts"]],
       [100, 1000, 2, 2], record)

# Hermes expands ~ and $VARs in HERMES_HOME, and a custom home at
# <root>/profiles/<name> keeps its sibling profiles under <root>/profiles
# (hermes_constants._hermes_root_of).
sandbox()
state_db(home() / "srv" / "profiles" / "work" / "state.db", ("gpt-6-astra", 100))
state_db(home() / "srv" / "profiles" / "play" / "state.db", ("gpt-6-sol", 1000))
os.environ["HERMES_ROOT_FOR_TEST"] = "srv"
os.environ["HERMES_HOME"] = "~/$HERMES_ROOT_FOR_TEST/profiles/work"
record = hermes()
del os.environ["HERMES_HOME"], os.environ["HERMES_ROOT_FOR_TEST"]
expect("Hermes expands HERMES_HOME and reads the profiles beside a custom profile home",
       [record["modelUsage"].get("gpt-6-astra", {}).get("inputTokens"), record["modelUsage"].get("gpt-6-sol", {}).get("inputTokens"), record["totalSessions"]],
       [100, 1000, 2], record)

# A shell with a profile active exports HERMES_HOME=~/.hermes/profiles/<name>;
# the root ~/.hermes is still the default profile, so it counts too
# (hermes_cli.profiles.list_profiles), as with HERMES_HOME unset.
sandbox()
state_db(home() / ".hermes" / "state.db", ("gpt-6-astra", 100))
state_db(home() / ".hermes" / "profiles" / "side" / "state.db", ("gpt-6-sol", 1000))
os.environ["HERMES_HOME"] = str(home() / ".hermes" / "profiles" / "side")
record = hermes()
del os.environ["HERMES_HOME"]
expect("Hermes reads the default profile beside an active named profile",
       [record["modelUsage"].get("gpt-6-astra", {}).get("inputTokens"), record["modelUsage"].get("gpt-6-sol", {}).get("inputTokens"), record["totalSessions"]],
       [100, 1000, 2], record)

# The same holds for a custom root's profile home: <root>/state.db is its
# default profile.
sandbox()
state_db(home() / "srv" / "state.db", ("gpt-6-astra", 100))
state_db(home() / "srv" / "profiles" / "work" / "state.db", ("gpt-6-sol", 1000))
os.environ["HERMES_HOME"] = str(home() / "srv" / "profiles" / "work")
record = hermes()
del os.environ["HERMES_HOME"]
expect("Hermes reads a custom root's default profile beside its active profile",
       [record["modelUsage"].get("gpt-6-astra", {}).get("inputTokens"), record["modelUsage"].get("gpt-6-sol", {}).get("inputTokens"), record["totalSessions"]],
       [100, 1000, 2], record)

# A custom root beside a used ~/.hermes: ~/.hermes is read whole, its own
# state.db (its default profile) with its named profiles, not the profiles
# alone.
sandbox()
state_db(home() / "custom-hermes" / "profiles" / "work" / "state.db", ("gpt-6-astra", 100))
state_db(home() / ".hermes" / "state.db", ("gpt-6-sol", 1000))
state_db(home() / ".hermes" / "profiles" / "side" / "state.db", ("gpt-6-luna", 10000))
os.environ["HERMES_HOME"] = str(home() / "custom-hermes")
record = hermes()
del os.environ["HERMES_HOME"]
expect("Hermes reads ~/.hermes whole beside a custom root",
       [record["modelUsage"].get(model, {}).get("inputTokens") for model in ("gpt-6-astra", "gpt-6-sol", "gpt-6-luna")] + [record["totalSessions"]],
       [100, 1000, 10000, 3], record)

# HERMES_DATA_DIR_SUFFIX names the default home.
sandbox()
state_db(home() / ".hermes-beta" / "state.db", ("gpt-6-astra", 100))
os.environ["HERMES_DATA_DIR_SUFFIX"] = "-beta"
record = hermes()
del os.environ["HERMES_DATA_DIR_SUFFIX"]
expect("Hermes reads the default home HERMES_DATA_DIR_SUFFIX names",
       record["modelUsage"].get("gpt-6-astra", {}).get("inputTokens"), 100, record)

# A profile that is a link to the home is the home: counted once.
sandbox()
state_db(home() / ".hermes" / "state.db", ("gpt-6-astra", 100))
(home() / ".hermes" / "profiles").mkdir()
(home() / ".hermes" / "profiles" / "default").symlink_to(home() / ".hermes")
record = hermes()
expect("Hermes counts a profile linked to its home once",
       [record["modelUsage"]["gpt-6-astra"]["inputTokens"], record["totalSessions"], record["totalPrompts"]], [100, 1, 1], record)

# A session counts where Hermes billed it: Nous Portal is Hermes', a server
# you run the local collector's, and Anthropic's API (or a Claude model on a
# local proxy), OpenRouter or a gateway nobody's here. A session Hermes kept
# no route for goes where its first request did, and one that never reached a
# provider is nobody's, its prompt and all. The rows are shaped as Hermes Agent
# wrote them against a mock of each API.
sandbox()
db = home() / ".hermes" / "state.db"
db.parent.mkdir(parents=True)
conn = sqlite3.connect(db)
conn.executescript("""
CREATE TABLE sessions (id TEXT PRIMARY KEY, source TEXT, model TEXT, started_at REAL NOT NULL, billing_provider TEXT, billing_base_url TEXT, billing_mode TEXT);
CREATE TABLE messages (id INTEGER PRIMARY KEY, session_id TEXT NOT NULL, role TEXT NOT NULL, timestamp REAL NOT NULL);
CREATE TABLE session_model_usage (
  session_id TEXT NOT NULL, model TEXT NOT NULL, billing_provider TEXT NOT NULL DEFAULT '', billing_base_url TEXT NOT NULL DEFAULT '',
  billing_mode TEXT NOT NULL DEFAULT '', task TEXT NOT NULL DEFAULT '',
  input_tokens INTEGER NOT NULL DEFAULT 0, output_tokens INTEGER NOT NULL DEFAULT 0,
  cache_read_tokens INTEGER NOT NULL DEFAULT 0, cache_write_tokens INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (session_id, model, billing_provider, billing_base_url, billing_mode, task)
);
""")
now = time.time()
ROUTES = [
  ("nous", "Hermes-4-405B", "nous", "https://inference-api.nousresearch.com/v1", 100),
  ("custom", "hermes-mock-model", "custom", "http://127.0.0.1:18473/v1", 1000),
  ("anthropic", "claude-mock-hermes", "anthropic", "http://127.0.0.1:18473", 10000),
  ("router", "z-ai/glm-4.6", "openrouter", "https://openrouter.ai/api/v1", 100000),
  ("gateway", "acme-1", "custom", "https://llm.acme.example/v1", 1000000),
]
for n, (session, model, provider, url, tokens) in enumerate(ROUTES):
  conn.execute("INSERT INTO sessions VALUES (?, 'oneshot', ?, ?, ?, ?, NULL)", (session, model, now, provider, url))
  conn.execute("INSERT INTO messages VALUES (?, ?, 'user', ?)", (n + 1, session, now))
  conn.execute("INSERT INTO session_model_usage (session_id, model, billing_provider, billing_base_url, input_tokens) VALUES (?, ?, ?, ?, ?)", (session, model, provider, url, tokens))
  # The session title is a request of its own, on the session's route.
  conn.execute("INSERT INTO session_model_usage (session_id, model, billing_provider, billing_base_url, task, input_tokens) VALUES (?, ?, ?, ?, 'title_generation', ?)", (session, model, provider, url + "/", tokens))
# A session whose route Hermes didn't keep, and two that failed before any
# request Hermes accounted, one with the prompt typed into it.
conn.execute("INSERT INTO sessions VALUES ('unrouted', 'oneshot', 'hermes-mock-model', ?, NULL, NULL, NULL)", (now,))
conn.execute("INSERT INTO session_model_usage (session_id, model, billing_provider, billing_base_url, input_tokens) VALUES ('unrouted', 'hermes-mock-model', 'custom', 'http://127.0.0.1:18473/v1', 7)")
conn.execute("INSERT INTO sessions VALUES ('failed', 'oneshot', 'claude-mock-hermes', ?, NULL, NULL, NULL)", (now,))
conn.execute("INSERT INTO messages VALUES (99, 'failed', 'user', ?)", (now,))
conn.execute("INSERT INTO messages VALUES (100, 'failed', 'assistant', ?)", (now,))
conn.execute("INSERT INTO sessions VALUES ('failed-silent', 'oneshot', 'claude-mock-hermes', ?, NULL, NULL, NULL)", (now,))
conn.commit()
conn.close()
record = hermes()
expect("Hermes counts the sessions Nous Portal billed, not ones that reached no provider",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"]], [{"Hermes-4-405B": 200}, 1, 1], record)
local = collect("local", "--force")
expect("Local counts the Hermes sessions a server you run answered",
       [local["todayTokensByModel"], local["todayPrompts"], local["todaySessions"]], [{"hermes-mock-model": 2007}, 1, 2], local)

# An unreadable state.db says Hermes is unavailable, naming it in the help
# text, while the readable profiles still count, and that scan isn't cached.
sandbox()
state_db(home() / ".hermes" / "profiles" / "work" / "state.db", ("gpt-6-sol", 1000))
(home() / ".hermes" / "state.db").write_text("not a database at all, just text that is long enough to read")
record = hermes()
expect("an unreadable state.db reports Hermes unavailable, the readable profiles still counted",
       [record["ready"], record["usageStatusText"], record["hasLocalStats"], record["totalSessions"]],
       [True, "Hermes unavailable", True, 1], record)
check("the help text names the unreadable state.db",
      record["authHelpText"].startswith(f"Couldn't read Hermes' state.db ({home() / '.hermes' / 'state.db'}: "), record["authHelpText"])
check("a scan that missed a database isn't cached", not scan_cache_files("hermes"), scan_cache_files("hermes"))

# Every active date travels, not only the latest 400, and broken token counts
# or start times skip their row instead of inflating the record.
sandbox()
db = state_db(home() / ".hermes" / "state.db")
conn = sqlite3.connect(db)
# Local noon on each earlier day, so a daylight-saving change can't put two
# sessions on one date the way fixed 86400-second steps can near midnight.
today = dt.date.today()
noons = [dt.datetime.combine(today - dt.timedelta(days=n + 1), dt.time(12)).timestamp() for n in range(450)]
conn.executemany("INSERT INTO sessions VALUES (?, ?)", [(f"old-{n}", noons[n]) for n in range(450)])
conn.execute("INSERT INTO sessions VALUES ('broken', 'not a time')")
conn.executemany("INSERT INTO session_model_usage VALUES (?, ?, ?, 0, 0, 0)", [
  ("old-1", "negative", -500),
  ("old-2", "huge", 10**15),
  ("broken", "untimed", 5),
])
conn.commit()
conn.close()
record = hermes()
expect("Hermes emits every active date", [record["activeDays"], len(record["activeDates"])], [451, 451], record)
expect("Hermes skips broken token counts, and counts an untimed session's in the totals", sorted(record["modelUsage"]), ["untimed"], record)

# A start time outside 2000-2100 is a damaged stamp: the session counts, but
# names no day.
sandbox()
db = state_db(home() / ".hermes" / "state.db")
conn = sqlite3.connect(db)
conn.executemany("INSERT INTO sessions VALUES (?, ?)", [("stray", 1), ("far", 12307334400)])
conn.commit()
conn.close()
record = hermes()
expect("a start time outside 2000-2100 names no active day",
       [record["totalSessions"], record["activeDates"]], [3, [dt.date.today().isoformat()]], record)

# ---------------------------------------------------------------- contract

sandbox()


def plant():
  if not (home() / ".hermes" / "state.db").exists():
    state_db(home() / ".hermes" / "state.db", ("gpt-6-astra", 10))


def add_session():
  add_session.count = getattr(add_session, "count", 0) + 1
  conn = sqlite3.connect(home() / ".hermes" / "state.db")
  conn.execute("INSERT INTO sessions VALUES (?, ?)", (f"grown-{add_session.count}", time.time()))
  conn.commit()
  conn.close()


check_scan_cache(Adapter("hermes", plant=plant, grow=add_session))
PY
