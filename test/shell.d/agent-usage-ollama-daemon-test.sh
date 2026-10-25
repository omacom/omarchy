#!/bin/bash

# The local daemon's account: with no API key, the Ollama Cloud collector
# asks the daemon for the allowance and the plan of the account it is signed
# in to, and sends it no credential. The daemon that isn't running, isn't
# signed in, or can't be asked says so instead of guessing.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

freeze_today()
DAEMON = "127.0.0.1:11434"
BALANCE = f"{DAEMON}/api/balance"
ME = f"{DAEMON}/api/me"
SESSION_RESET = iso_in(3 * 3600)
WEEKLY_RESET = iso_in(4 * 86400)
# The daemon answers for the account it holds, in the shape
# docs.ollama.com/api/balance documents; ollama.com answers for the account
# a key signs in to, in the same shape.
LEGACY = {
  "included": {
    "session": {"remaining_percent": 75, "resets_at": SESSION_RESET},
    "weekly": {"remaining_percent": 40, "resets_at": WEEKLY_RESET},
  },
  "purchased": {"balance_usd": 0},
}
ROUTES = {
  BALANCE: LEGACY,
  ME: {"plan": "pro"},
  "ollama.com/api/balance": LEGACY,
  "ollama.com/api/me": {"plan": "pro"},
}


def sessions():
  return home() / ".pi" / "agent" / "sessions"


def ollama(*args, routes=None, mode="up"):
  with FakeHttp(ROUTES if routes is None else routes, mode=mode) as http:
    record = collect("ollama", *(args or ("--force",)))
  return record, http.requests


def cloud():
  """A pi session on the cloud provider, so the machine is in use."""
  write_pi_session(sessions() / "project" / "pi.jsonl", [
    pi_reply("ollama-cloud", id="pi-1", model="deepseek-v4-pro",
             usage={"input": 10, "output": 4, "cacheRead": 3, "cacheWrite": 2, "totalTokens": 19}),
  ])


# The daemon holds the account of whoever signed in to it, so it answers the
# balance and the plan without a key, and the panel shows the same windows a
# keyed account gets.
sandbox()
cloud()
record, requests = ollama()
expect("Ollama reads the allowance and the plan from the local daemon", {
  "tierLabel": record["tierLabel"], "limits": record["limits"], "status": record["usageStatusText"],
}, {
  "tierLabel": "Pro", "limits": [
    {"label": "Session (5-hour)", "percent": 0.25, "resetsAt": SESSION_RESET},
    {"label": "Weekly (7-day)", "percent": 0.6, "resetsAt": WEEKLY_RESET},
  ], "status": "",
}, record)

# The daemon is asked on this machine, and it is asked without a credential:
# it knows the account already.
expect("Ollama asks the local daemon itself, and sends it no credential",
       [(request["url"], "authorization" in request["headers"]) for request in requests],
       [(f"http://{DAEMON}/api/balance", False), (f"http://{DAEMON}/api/me", False)], record)

# The daemon's account is kept apart from every key's: another sign-in never
# shows this one's numbers.
daemon_cache = limits_cache_files("ollama")
os.environ["OLLAMA_API_KEY"] = "a-key"
record, requests = ollama()
expect("Ollama asks ollama.com itself once a key is there",
       [request["url"] for request in requests],
       ["https://ollama.com/api/balance", "https://ollama.com/api/me"], record)
expect("Ollama keeps the daemon's answer apart from a key's",
       len(limits_cache_files("ollama")) > len(daemon_cache), True, record)
del os.environ["OLLAMA_API_KEY"]

# A daemon that isn't signed in knows no account: the limits wait for a
# sign-in, which is what a person can do about it.
sandbox()
cloud()
record, requests = ollama(routes={BALANCE: 401, ME: 401})
expect("Ollama waits for a sign-in when the local daemon has no account",
       [record["usageStatusText"], record["retryAdvised"] if "retryAdvised" in record else None,
        "ollama signin" in record["authHelpText"].lower()],
       ["Waiting for auth", None, True], record)

# A daemon that isn't running says so, and the one thing to do about it.
record, requests = ollama(mode="down")
expect("Ollama names the local daemon it couldn't reach",
       [record["usageStatusText"], record["retryAdvised"] if "retryAdvised" in record else None,
        DAEMON in record["authHelpText"]],
       ["Waiting for auth", None, True], record)

# A daemon on a plain-HTTP host off this machine is not asked for an
# account's allowance.
os.environ["OLLAMA_HOST"] = "http://192.168.1.5:11434"
record, requests = ollama()
expect("Ollama doesn't ask a plain-HTTP host off this machine", requests, [], record)
expect("Ollama points at a key when the daemon can't be asked",
       [record["usageStatusText"], "OLLAMA_API_KEY" in record["authHelpText"]],
       ["Waiting for auth", True], record)
del os.environ["OLLAMA_HOST"]

# A daemon on this machine over plain HTTP is asked; the address the daemon
# takes is the one it is given.
os.environ["OLLAMA_HOST"] = "127.0.0.1:11434"
record, requests = ollama()
expect("Ollama asks the daemon at the address OLLAMA_HOST names",
       [request["url"] for request in requests],
       [f"http://{DAEMON}/api/balance", f"http://{DAEMON}/api/me"], record)
del os.environ["OLLAMA_HOST"]

# Two daemons are two accounts: the second one's allowance never shows under
# the first one's, neither fresh nor as a fallback, and each keeps its own.
OTHER_DAEMON = "127.0.0.1:11435"
OTHER_LEGACY = {
  "included": {
    "session": {"remaining_percent": 50, "resets_at": SESSION_RESET},
    "weekly": {"remaining_percent": 20, "resets_at": WEEKLY_RESET},
  },
  "purchased": {"balance_usd": 0},
}
sandbox()
cloud()
os.environ["OLLAMA_HOST"] = DAEMON
ollama()
os.environ["OLLAMA_HOST"] = OTHER_DAEMON
record, requests = ollama("--limits-only", routes={**ROUTES, f"{OTHER_DAEMON}/api/balance": OTHER_LEGACY, f"{OTHER_DAEMON}/api/me": {"plan": "free"}})
expect("Ollama asks the second daemon and reads the second account's allowance",
       [[request["url"] for request in requests], record["tierLabel"], [entry["percent"] for entry in record["limits"]]],
       [[f"http://{OTHER_DAEMON}/api/balance", f"http://{OTHER_DAEMON}/api/me"], "Free", [0.5, 0.8]], record)
expect("Ollama keeps each daemon's allowance under its own daemon",
       len(limits_cache_files("ollama")), 2, record)

# A third daemon that cannot answer shows no allowance at all: another
# daemon's numbers are never a fallback.
os.environ["OLLAMA_HOST"] = "127.0.0.1:11436"
record, requests = ollama()
expect("Ollama shows no allowance for a daemon that cannot answer, and none of another's either",
       [record["limits"], record["tierLabel"], record["usageStatusText"]],
       [[], "", "Waiting for auth"], record)
del os.environ["OLLAMA_HOST"]

# A machine that never used Ollama Cloud doesn't ask the daemon either: the
# panel skips the record, and nothing was asked for.
sandbox()
record, requests = ollama()
expect("Ollama asks nothing on a machine that doesn't use it",
       [record["ready"], record["limits"], requests], [False, [], []], record)
PY
