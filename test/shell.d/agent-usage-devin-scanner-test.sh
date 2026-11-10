#!/bin/bash

# The Devin collector's own sources: the CLI's session database (and the
# older per-session layout), and the user-status caches the CLI writes, which
# are its quota. pi, omp and opencode usage on the devin provider is read the
# shared way and held by the shared and partition tests, as is the
# unused-machine record; the scan cache and the limits go through the
# contract checks.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
import base64

from agent_usage_fixtures import *

now = int(time.time())


def devin(*args):
  with FakeHttp():
    return collect("devin", *(args or ("--force",)))


def cli_dir():
  return data_home() / "devin" / "cli"


def status_dir():
  return Path(os.environ["XDG_CACHE_HOME"]) / "devin" / "cli"


def credentials():
  return data_home() / "devin" / "credentials.toml"


# The CLI's sessions.db: one message_nodes row per reply, its metrics in the
# chat message's metadata, and one prompt_history row per typed prompt.
def node(session, created, model, inp, out, cache_read=0, cache_write=0, chat=None):
  metrics = {"input_tokens": inp, "output_tokens": out, "cache_read_tokens": cache_read, "cache_creation_tokens": cache_write}
  return (session, chat if chat is not None else json.dumps({"metadata": {"metrics": metrics, "generation_model": model}}), created)


def sessions_db(nodes=(), prompts=()):
  path = cli_dir() / "sessions.db"
  path.parent.mkdir(parents=True, exist_ok=True)
  conn = sqlite3.connect(path)
  conn.execute("CREATE TABLE IF NOT EXISTS message_nodes (row_id INTEGER PRIMARY KEY, session_id TEXT, node_id INTEGER, parent_node_id INTEGER, chat_message TEXT, created_at INTEGER, metadata TEXT)")
  conn.execute("CREATE TABLE IF NOT EXISTS prompt_history (id INTEGER PRIMARY KEY, content TEXT, timestamp INTEGER, session_id TEXT, is_shell INTEGER)")
  conn.executemany("INSERT INTO message_nodes (session_id, chat_message, created_at) VALUES (?, ?, ?)", nodes)
  conn.executemany("INSERT INTO prompt_history (content, timestamp, session_id, is_shell) VALUES (?, ?, ?, 0)", prompts)
  conn.commit()
  conn.close()
  return path


# A user-status cache as the CLI writes it: GetUserStatus's protobuf fields,
# base64 in a small JSON file.
def varint(value):
  value &= (1 << 64) - 1
  out = b""
  while True:
    byte = value & 0x7F
    value >>= 7
    out += bytes([byte | 0x80]) if value else bytes([byte])
    if not value:
      return out


def field(number, data):
  if isinstance(data, int):
    return varint(number << 3) + varint(data)
  return varint((number << 3) | 2) + varint(len(data)) + data


def write_status(name, fetched_at, **options):
  plan = field(2, options["plan"].encode()) if options.get("plan") else b""
  for key, number in (("tier", 1), ("billing", 35), ("hideDaily", 36), ("hideWeekly", 37), ("promptLimit", 12)):
    if key in options:
      plan += field(number, int(options[key]))
  status = field(1, plan)
  for key, number in (("daily", 14), ("weekly", 15), ("dailyReset", 17), ("weeklyReset", 18), ("promptUsed", 6)):
    if key in options:
      status += field(number, int(options[key]))
  if "planEnd" in options:
    status += field(3, field(1, int(options["planEnd"])))
  payload = field(13, status)
  return write_json(status_dir() / f"user_status.{name}.bin",
                    {"version": 1, "identity_digest": name, "fetched_at_secs": fetched_at, "payload": base64.b64encode(payload).decode()})


def signed_in_at(moment):
  credentials().parent.mkdir(parents=True, exist_ok=True)
  if not credentials().exists():
    credentials().write_text('api_server_url = "https://example.invalid"\n')
  os.utime(credentials(), (moment, moment))


def windows(record):
  return [[entry["label"], entry["percent"]] for entry in record["limits"]]


def day(offset):
  return (datetime.now() + timedelta(days=offset)).strftime("%Y-%m-%d")


# ------------------------------------------------------- the CLI's database

# Untrusted fields skip themselves, or the row, never the scan: a boolean, a
# negative count and a string count read as nothing; a row with a broken
# timestamp, no metrics, or no JSON at all adds nothing.
sandbox()
sessions_db(nodes=[
  node("s1", now, "glm-5-2", 100, 20, 60, 0),
  node("s1", now, "glm-5-2", 80, 10, 50, 0),
  node("s1", now, "devin-pro", 200, 40, 0, 10),
  node("s2", now - 86400, "glm-5-2", 50, 5),
  node("s1", now, "glm-5-2", True, -5, "7", 0),
  node("s1", "yesterday-ish", "glm-5-2", 999, 999),
  node("s1", 10**15, "glm-5-2", 999, 999),
  node("s1", now, None, 0, 0, chat=json.dumps({"metadata": {}})),
  node("s1", now, None, 0, 0, chat='{not json "metrics"'),
], prompts=[("a", now, "s1"), ("b", now, "s1"), ("c", now, "s3"), ("d", now - 86400, "s2"), ("e", now - 86400, "s1")])

# (100+20+60) + (80+10+50) + (200+40+10) = 570. Prompts come from
# prompt_history, and a session spanning midnight counts once.
record = devin()
expect("Devin reads the CLI's session database, skipping untrusted fields", {
  "name": record["name"],
  "today": record["todayTotalTokens"],
  "counts": [record[key] for key in ("todayPrompts", "todaySessions", "totalPrompts", "totalSessions", "activeDays")],
  "models": record["modelUsage"],
  "yesterday": next(entry["messageCount"] for entry in record["recentDays"] if entry["date"] == day(-1)),
}, {
  "name": "Devin",
  "today": 570,
  "counts": [3, 2, 5, 3, 2],
  "models": {
    "glm-5-2": {"inputTokens": 230, "outputTokens": 35, "cacheReadInputTokens": 110, "cacheCreationInputTokens": 0},
    "devin-pro": {"inputTokens": 200, "outputTokens": 40, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 10},
  },
  "yesterday": 55,
}, record)

# In use without any sign-in: the quota has nowhere to come from.
expect("Devin in use without a sign-in waits for auth", [record["ready"], record["usageStatusText"], record["limits"]], [True, "Waiting for auth", []], record)
expect("Devin's sessions here are local stats", record["hasLocalStats"], True, record)

# A database it cannot read costs the stats, never the record, and is not
# cached as the whole story.
good = (cli_dir() / "sessions.db").read_bytes()
(cli_dir() / "sessions.db").write_text("not a database")
for path in scan_cache_files("devin"):
  path.unlink()
with contextlib.redirect_stderr(io.StringIO()):
  record = devin()
expect("Devin survives an unreadable session database and doesn't cache that scan",
       [record["id"], record["todayTotalTokens"], scan_cache_files("devin")], ["devin", 0, []], record)
expect("an unreadable session database says Devin is unavailable rather than hiding it",
       [record["ready"], record["usageStatusText"], str(cli_dir() / "sessions.db") in record["authHelpText"]], [True, "Devin unavailable", True], record)
(cli_dir() / "sessions.db").write_bytes(good)
(cli_dir() / "sessions.db").chmod(0)
with contextlib.redirect_stderr(io.StringIO()):
  record = devin()
(cli_dir() / "sessions.db").chmod(0o644)
expect("a session database it may not open says Devin is unavailable", [record["ready"], record["usageStatusText"]], [True, "Devin unavailable"], record)

# ------------------------------------------------------- the older layout

# Builds without the cli/ directory kept one lifetime total per session.
sandbox()
old = data_home() / "devin" / "cli_sessions.db"
old.parent.mkdir(parents=True)
conn = sqlite3.connect(old)
conn.execute("CREATE TABLE sessions (id TEXT, working_directory TEXT, backend_type TEXT, model TEXT, permission_mode TEXT, created_at INTEGER, last_activity_at INTEGER, total_tokens INTEGER, current_epoch INTEGER)")
conn.execute("CREATE TABLE messages (id TEXT, session_id TEXT, sequence_number INTEGER, role TEXT, content TEXT, tool_call_id TEXT, tool_calls_json TEXT, timestamp INTEGER, compaction_epoch INTEGER)")
conn.execute("INSERT INTO sessions (id, model, created_at, last_activity_at, total_tokens) VALUES ('o1', 'swe-1.5', ?, ?, 4000)", (now - 86400, now))
conn.execute("INSERT INTO messages (id, session_id, role, timestamp) VALUES ('1', 'o1', 'user', ?), ('2', 'o1', 'assistant', ?), ('3', 'o1', 'assistant', ?)", (now, now, now))
conn.commit()
conn.close()
record = devin()
expect("Devin falls back to the older per-session layout",
       [record["todayTotalTokens"], record["todayPrompts"], record["totalSessions"], record["modelUsage"]["swe-1.5"]["inputTokens"]], [4000, 2, 1, 4000], record)

# Once the CLI's own database exists, the older files are not read again.
sessions_db()
expect("Devin reads only the CLI's own database once it exists", devin()["todayTotalTokens"], 0)

# ---------------------------------------------------------------- contract

sandbox()


def plant_status():
  write_status("a", int(time.time()), plan="Pro", daily=69, weekly=53, dailyReset=now + 3600, weeklyReset=now + 4 * 86400)


def add_reply():
  sessions_db(nodes=[node("grown", int(time.time()), "glm-5-2", 5, 0)])


# Devin's quota is the CLI's own cache, read on every run: there is no
# request to count, retry or refuse, no check of its own to fail stale or cut
# short, and no limits cache of the collector's to elapse (its own
# elapsed-window case is below).
adapter = Adapter("devin", plant=plant_status, grow=add_reply, requests_per_probe=0, retry_modes=(), refused_status=None,
                  skip=("stale", "cut", "elapsed"), pi_root=lambda: home() / ".pi" / "agent" / "sessions")
fresh = check_limits_contract(adapter)
expect("Devin's plan and quota come from the CLI's user-status cache, with the service's own reset times", {
  "tierLabel": fresh["tierLabel"], "windows": windows(fresh), "fetchedAt": fresh["limitsFetchedAt"] // 1000 >= now,
  "reset": fresh["limits"][0]["resetsAt"], "retry": "retryAdvised" in fresh,
}, {
  "tierLabel": "Pro", "windows": [["Daily", 0.31], ["Weekly", 0.47]], "fetchedAt": True,
  "reset": datetime.fromtimestamp(now + 3600, timezone.utc).isoformat(), "retry": False,
}, fresh)
check_scan_cache(adapter)

# ------------------------------------------------------------- the quota

sandbox()

# The quota is read on every run, past the scan reuse, so a fetch the CLI
# just made shows without --force.
write_status("a", now, plan="Pro", daily=69, weekly=53, dailyReset=now + 3600, weeklyReset=now + 4 * 86400)
devin()
write_status("a", now, plan="Pro", daily=50, weekly=53, dailyReset=now + 3600, weeklyReset=now + 4 * 86400)
expect("Devin reads the quota cache on every run", devin("--limits-only")["limits"][0]["percent"], 0.5)

# Spent windows: proto3 leaves a zero off the wire, so a dated window with no
# percent has nothing left.
write_status("a", now, plan="Pro", dailyReset=now + 3600)
expect("Devin reads a missing percent on a dated window as spent", windows(devin()), [["Daily", 1.0]])

# A cache from more than fifteen minutes ago still describes the account, but
# is reported stale with its age; a window that reset since is back at zero.
write_status("a", now - 7200, plan="Pro", daily=10, weekly=40, dailyReset=now - 60, weeklyReset=now + 86400)
record = devin()
expect("Devin reports an old quota stale, with elapsed windows at zero", {
  "stale": record["limitsStale"], "fetchedAt": record["limitsFetchedAt"], "status": record["usageStatusText"],
  "windows": [[entry["label"], entry["percent"], entry["resetsAt"] != ""] for entry in record["limits"]],
}, {"stale": True, "fetchedAt": (now - 7200) * 1000, "status": "", "windows": [["Daily", 0.0, False], ["Weekly", 0.6, True]]}, record)

# The fetch stamp is floored to the millisecond, never rounded up.
fraction = now - 7200 + 0.9996
write_status("a", fraction, plan="Pro", daily=10, weekly=40, weeklyReset=now + 86400)
expect("Devin floors the fetch stamp", devin()["limitsFetchedAt"], int(fraction * 1000))

# Fetches from before the last sign-in describe another account.
signed_in_at(now + 600)
write_status("a", now, plan="Pro", daily=69, weekly=53, dailyReset=now + 3600, weeklyReset=now + 86400)
record = devin()
expect("Devin drops quota fetched before the last sign-in and says how to refresh it",
       [record["ready"], record["tierLabel"], record["limits"], record["usageStatusText"], "Start Devin" in record["authHelpText"]],
       [True, "", [], "Devin limits unavailable", True], record)

# Of the caches fetched since, the newest wins, whichever name sorts first.
signed_in_at(now - 600)
for name in ("0", "b"):
  write_status(name, now - 300, plan="Max", daily=0, weekly=0, dailyReset=now + 3600)
expect("Devin serves the newest fetch under the current sign-in, sorted between older ones", devin()["tierLabel"], "Pro")
for name in ("0", "b"):
  (status_dir() / f"user_status.{name}.bin").unlink()

# The old account's last fetch can land in the seconds before a switch, inside
# the allowance for the new account's first fetch. Having been served under
# the old sign-in, it is known to be the old account's and stays out.
signed_in_at(now - 3600)
write_status("a", now - 100, plan="Pro", daily=69, weekly=53, dailyReset=now + 3600, weeklyReset=now + 86400)
expect("Devin serves the account signed in", devin()["tierLabel"], "Pro")
signed_in_at(now - 90)
record = devin()
expect("Devin drops the old account's fetch from just before a switch",
       [record["tierLabel"], record["limits"], record["usageStatusText"]], ["", [], "Devin limits unavailable"], record)
write_status("b", now - 95, plan="Max", daily=0, weekly=0, dailyReset=now + 3600)
expect("Devin serves the new account's first fetch from just before the switch", devin()["tierLabel"], "Max")
(status_dir() / "user_status.b.bin").unlink()
write_status("a", now, plan="Pro", daily=69, weekly=53, dailyReset=now + 3600, weeklyReset=now + 86400)
expect("Devin serves a fetch made after the sign-in", devin()["tierLabel"], "Pro")

# A plan can hide a window; credit buckets run to the plan's end; a plan
# without a name of its own is named by its tier.
write_status("a", now, tier=16, hideDaily=1, daily=10, weekly=80, dailyReset=now + 3600, weeklyReset=now + 86400,
             promptLimit=500, promptUsed=125, planEnd=now + 20 * 86400)
record = devin()
expect("Devin honors hidden windows, credit buckets and tier names",
       [record["tierLabel"], windows(record)], ["Devin Pro", [["Weekly", 0.2], ["Prompt credits", 0.25]]], record)

write_status("a", now, plan="Pro", hideWeekly=1, daily=10, weekly=80, dailyReset=now + 3600, weeklyReset=now + 86400)
expect("Devin honors a hidden weekly window", windows(devin()), [["Daily", 0.9]])

# TeamsTier, as the Devin protocol numbers it, has 8 and 11 too.
names = []
for tier in (8, 11):
  write_status("a", now, tier=tier, daily=10, weekly=80, dailyReset=now + 3600, weeklyReset=now + 86400)
  names.append(devin()["tierLabel"])
expect("Devin names every tier the protocol numbers", names, ["Pro Ultimate", "Enterprise Saas Pooled"])

# A fetch stamped ahead of the clock (one that went back) isn't current.
write_status("a", now + 3600, plan="Pro", daily=10, weekly=80, dailyReset=now + 7200, weeklyReset=now + 86400)
record = devin()
expect("Devin reports a fetch stamped in the future stale", [record["limitsStale"], windows(record)], [True, [["Daily", 0.9], ["Weekly", 0.2]]], record)

# A credit plan leaves the quota percents at their defaults with no reset:
# those windows are not meters.
write_status("a", now, plan="Pro", billing=1)
expect("Devin shows no quota windows on a credit plan", devin()["limits"], [])

# A broken cache file is no quota at all.
write_json(status_dir() / "user_status.a.bin", {"fetched_at_secs": True, "payload": "%%%"})
expect("Devin ignores a broken quota cache", devin()["usageStatusText"], "Devin limits unavailable")

# A sign-in with no sessions on this machine shows, with no local stats.
sandbox()
signed_in_at(now - 600)
write_status("a", now, plan="Pro", daily=10, weekly=40, weeklyReset=now + 86400)
record = devin()
expect("a Devin sign-in with no sessions here has no local stats",
       [record["ready"], record["totalSessions"], record["hasLocalStats"]], [True, 0, False], record)
PY
