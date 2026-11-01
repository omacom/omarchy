#!/bin/bash

# Antigravity signed in through another harness, with agy itself absent: the
# record still carries the plan and limits, asked with that harness' token,
# and counts the answers OpenClaw records. How pi, omp and opencode sessions
# are read (forks, profiles, moved roots, both opencode stores) is held for
# every collector by the shared and partition tests.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

import hashlib
import shutil

ANSWERS = {
  "loadCodeAssist": {"paidTier": {"id": "g1-pro-tier", "name": "Google AI Pro"}},
  "retrieveUserQuotaSummary": {"groups": [{"displayName": "Gemini Models", "buckets": [
    {"window": "5h", "remainingFraction": 0.75, "resetTime": "2999-01-01T00:00:00Z"},
  ]}]},
}
REAL_PATH = os.environ["PATH"]


# No keyring, and an omp that answers `omp usage` with the report in
# omp-report.json when there is one, and fails otherwise.
def machine():
  sandbox()
  stubs = home() / "bin"
  stubs.mkdir()
  for name, body in (("secret-tool", "exit 1"),
                     ("omp", '[[ "$*" == "usage --json --provider google-antigravity" ]] || exit 2\n'
                             '[[ $(readlink /proc/$$/fd/0) == /dev/null ]] || { echo "stdin is not /dev/null" >>"$HOME/omp-stdin"; exit 3; }\n'
                             'cat "$HOME/omp-report.json" 2>/dev/null')):
    (stubs / name).write_text(f"#!/bin/bash\n{body}\n")
    (stubs / name).chmod(0o755)
  os.environ["PATH"] = f"{stubs}:{REAL_PATH}"


def omp_login(token, expires, email):
  database = home() / ".omp" / "agent" / "agent.db"
  database.parent.mkdir(parents=True, exist_ok=True)
  database.unlink(missing_ok=True)
  conn = sqlite3.connect(database)
  conn.execute("CREATE TABLE auth_credentials (id INTEGER PRIMARY KEY, provider TEXT, credential_type TEXT, data TEXT, disabled_cause TEXT)")
  conn.execute("INSERT INTO auth_credentials (provider, credential_type, data) VALUES ('google-antigravity', 'oauth', ?)",
               (json.dumps({"access": token, "refresh": "r", "expires": expires, "email": email}),))
  conn.execute("INSERT INTO auth_credentials (provider, credential_type, data, disabled_cause) VALUES ('google-antigravity', 'oauth', ?, 'revoked')",
               (json.dumps({"access": "disabled-token", "refresh": "r", "expires": ms_in(99999), "email": email}),))
  conn.commit()
  conn.close()


def pi_login(token, expires, email, directory=None):
  write_json(Path(directory or home() / ".pi" / "agent") / "auth.json",
             {"google-antigravity": {"type": "oauth", "access": token, "refresh": "r", "expires": expires, "email": email}})


# Google answers every token in `accepted` and refuses the rest.
def agy(*accepted):
  def answer(request):
    token = request.get_header("Authorization").removeprefix("Bearer ")
    if token not in accepted:
      return 403
    return ANSWERS[request.full_url.rsplit(":", 1)[1]]
  with FakeHttp({"v1internal:": answer}) as http:
    record = collect("agy", "--force")
  asked = sorted({r["headers"]["authorization"].removeprefix("Bearer ") for r in http.requests})
  return record, asked


# Every store the collector reads, so a test can tell none was written.
def stores():
  return sorted((str(path), hashlib.md5(path.read_bytes()).hexdigest())
                for root in (".omp", ".pi", ".local/share/opencode", ".gemini", "pi-elsewhere")
                for path in (home() / root).rglob("*") if path.is_file())


# ---------------------------------------------------------- the sign-ins

machine()
omp_login("omp-token", ms_in(3600), "me@example.com")
record, asked = agy("omp-token")
expect("Antigravity collector reports limits from an omp sign-in without agy, never asking with a disabled one",
       [record["ready"], record["tierLabel"], record["usageStatusText"], record["authHelpText"], record["limitsStale"], record["limits"][0]["percent"], asked],
       [True, "Pro", "", "", False, 0.25, ["omp-token"]], record)

pi_login("pi-token", ms_in(7200), "me@example.com")
_, asked = agy("omp-token", "pi-token")
expect("Antigravity collector asks with the most recently refreshed sign-in", asked, ["pi-token"])

record, asked = agy("omp-token")
expect("Antigravity collector moves on from a sign-in Google refuses",
       [asked, record["limitsStale"], record["usageStatusText"]], [["omp-token", "pi-token"], False, ""], record)

record, _ = agy()
expect("Antigravity collector reports every sign-in refused as expired, keeping the account's limits, and names the harness",
       [record["usageStatusText"], record["limitsStale"], record["limits"][0]["percent"], record["authHelpText"]],
       ["Sign-in expired", True, 0.25, "Google refused the Antigravity sign-in pi keeps. Start pi to sign in again."], record)

# A lapsed token is renewed the next time its harness runs, so the limits are
# paused, not signed out, and the token goes nowhere.
shutil.rmtree(home() / ".pi")
omp_login("omp-token", ms_in(-60), "me@example.com")
before = stores()
record, asked = agy("omp-token")
check("Antigravity collector keeps the last limits while omp's token has lapsed, sending it nowhere",
      asked == [] and record["ready"] is True and record["limitsStale"] is True and record["usageStatusText"] == "Limits paused"
      and record["limits"][0]["percent"] == 0.25 and record["authHelpText"].endswith("Start omp to refresh it; signing in again is not needed."), record)
expect("Antigravity collector never writes omp's store", stores(), before)

omp_login("other-token", ms_in(-60), "other@example.com")
record, _ = agy()
expect("Antigravity collector shows no other Google account's kept limits", [record["limits"], record["tierLabel"]], [[], ""], record)

# omp renews its own sign-in when asked for usage, so a lapsed token in its
# database still gets live limits through `omp usage`.
write_json(home() / "omp-report.json", {"reports": [{"provider": "google-antigravity", "metadata": {"email": "other@example.com"}, "limits": [
  {"label": "Gemini", "amount": {"usedFraction": 0.6}, "window": {"id": "5h", "resetsAt": 32503680000000}},
  {"label": "Gemini", "amount": {"usedFraction": 0.3}, "window": {"id": "weekly", "resetsAt": 32503680000000}},
  {"label": "Claude & GPT (shared)", "amount": {"usedFraction": 0.1}, "window": {"id": "weekly", "resetsAt": 32503680000000}},
  {"label": "Claude & GPT (shared)", "amount": {"usedFraction": 0.1}, "window": {"id": "weekly", "resetsAt": 32503680000000}},
  {"label": "Gemini", "amount": {"usedFraction": "lots"}, "window": {"id": "daily"}},
]}]})
record, asked = agy()
expect("Antigravity collector takes omp's limits from omp usage, sending omp's lapsed token nowhere",
       [asked, record["limitsStale"], record["usageStatusText"], record["authHelpText"], [(entry["title"], entry["percent"]) for entry in record["limits"]]],
       [[], False, "", "", [("Session", 0.6), ("Weekly", 0.3), ("Claude/GPT Weekly", 0.1)]], record)

check("omp usage runs with nothing on its stdin", not (home() / "omp-stdin").exists())

# An omp report of another shape is no answer: the kept limits stand, stale.
report = {"provider": "google-antigravity", "metadata": {"email": "other@example.com"}}
kept = []
for shape in ({"reports": [dict(report, limits="x")]}, {"reports": [dict(report, limits=5)]}, {"reports": 5}):
  write_json(home() / "omp-report.json", shape)
  record, _ = agy()
  kept.append([record["limitsStale"], [entry["percent"] for entry in record["limits"]]])
expect("Antigravity collector keeps the last limits over an omp report of another shape", kept, [[True, [0.6, 0.3, 0.1]]] * 3, kept)

# A window id of another shape still names one window, and a report naming no
# account, with several omp sign-ins, is shown but kept for none of them.
conn = sqlite3.connect(home() / ".omp" / "agent" / "agent.db")
conn.execute("INSERT INTO auth_credentials (provider, credential_type, data) VALUES ('google-antigravity', 'oauth', ?)",
             (json.dumps({"access": "third-token", "refresh": "r3", "expires": ms_in(-60), "email": "third@example.com"}),))
conn.commit()
conn.close()
for path in limits_cache_files("agy"):
  path.unlink()
write_json(home() / "omp-report.json", {"reports": [{"provider": "google-antigravity", "limits": [
  {"label": "Gemini", "amount": {"usedFraction": 0.2}, "window": {"id": ["odd"], "resetsAt": 32503680000000}},
  {"label": "Gemini", "amount": {"usedFraction": 0.6}, "window": {"id": "5h", "resetsAt": 32503680000000}},
]}]})
record, asked = agy()
expect("an anonymous omp report with several sign-ins is shown, kept for none, past an odd window id",
       [asked, record["limitsStale"], [entry["percent"] for entry in record["limits"]], limits_cache_files("agy")], [[], False, [0.6], []], record)

# opencode files any Google sign-in under "google"; only the Antigravity
# plugin's accounts file makes it an Antigravity one.
machine()
write_json(data_home() / "opencode" / "auth.json", {"google": {"type": "oauth", "access": "opencode-token", "refresh": "r|p", "expires": ms_in(3600)}})
record, asked = agy("opencode-token")
expect("Antigravity collector ignores opencode's Google sign-in without the Antigravity plugin", [record["ready"], record["limits"], asked], [False, [], []], record)
write_json(config_home() / "opencode" / "antigravity-accounts.json", {"version": 3, "accounts": []})
record, asked = agy("opencode-token")
expect("Antigravity collector reads opencode's Antigravity plugin sign-in", [asked, record["limits"][0]["percent"]], [["opencode-token"], 0.25], record)

# opencode records no email for its sign-in, so a replaced sign-in is told
# apart by its refresh token: the kept limits go rather than pass for the
# new account's.
write_json(data_home() / "opencode" / "auth.json", {"google": {"type": "oauth", "access": "switched-token", "refresh": "switched|p", "expires": ms_in(3600)}})
record, _ = agy()
expect("Antigravity collector drops kept limits when the account cannot be matched",
       [record["limits"], record["tierLabel"], record["usageStatusText"]], [[], "", "Sign-in expired"], record)

# Without a keyring, agy keeps its sign-in in a file under its home.
machine()
write_json(home() / ".gemini" / "antigravity-cli" / "antigravity-oauth-token",
           {"token": {"access_token": "agy-file-token", "refresh_token": "agy-refresh", "expiry": "2999-01-01T00:00:00Z"}})
record, asked = agy("agy-file-token")
expect("Antigravity collector reads agy's sign-in file when there is no keyring", [asked, record["limits"][0]["percent"]], [["agy-file-token"], 0.25], record)

# PI_CODING_AGENT_DIR moves pi's sign-in.
machine()
pi_login("moved-token", ms_in(3600), "me@example.com", home() / "pi-elsewhere")
os.environ["PI_CODING_AGENT_DIR"] = str(home() / "pi-elsewhere")
before = stores()
record, asked = agy("moved-token")
expect("Antigravity collector reads pi's sign-in where PI_CODING_AGENT_DIR puts it", [asked, record["limits"][0]["percent"]], [["moved-token"], 0.25], record)
expect("Antigravity collector never writes pi's store", stores(), before)

# ---------------------------------------------------------- local stats

# OpenClaw keeps pi's format, one directory per agent; its entries carry no
# id, so two alike answers are two answers. Gemini through any provider but
# Antigravity's counts nowhere: pi's google-gemini-cli, and opencode's
# "google" without the plugin's antigravity- model prefix.
machine()
openclaw = pi_reply("google-antigravity", 1, model="gemini-3-pro", usage={"input": 1, "output": 1})
write_pi_session(home() / ".openclaw" / "agents" / "main" / "sessions" / "s.jsonl", [openclaw, openclaw])
write_pi_session(home() / ".pi" / "agent" / "sessions" / "p" / "s.jsonl",
                 [pi_reply("google-gemini-cli", 999, id="g1", model="gemini-3-pro"),
                  pi_reply("google-antigravity", 10, id="a1", model="gemini-3-pro", usage={"input": 10, "output": 2})])
opencode_db(message=[("m1", "s1", oc_v1("google", 999, "gemini-3-pro")), ("m2", "s2", oc_v1("google", 4, "antigravity-gemini-3-pro"))])
record, _ = agy()
expect("Antigravity collector counts OpenClaw's answers and only Antigravity's provider",
       [record["ready"], record["usageStatusText"], record["totalPrompts"], record["todayTotalTokens"],
        {model: bucket["inputTokens"] for model, bucket in record["modelUsage"].items()}],
       [True, "Waiting for auth", 4, 20, {"gemini-3-pro": 12, "antigravity-gemini-3-pro": 4}], record)
expect("waiting for auth with no limits kept is nothing stale", [record["limits"], record["limitsStale"]], [[], False], record)
PY
