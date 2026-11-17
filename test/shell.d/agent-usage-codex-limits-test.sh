#!/bin/bash

# The Codex collector's limits: what its app-server's rate-limit answer says
# (single and multi-bucket views, named models, spend caps, reset credits),
# how each way the app-server can fail reads, and whose limits a home's
# cache may show. The unused-machine record is held centrally by the
# partition test, the limits cache by the contract checks, run here against
# a stand-in app-server, and Codex's local stats by its scanner test.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox
fake_codex "$HOME"
export PATH="$HOME/bin:$PATH"

python3 - <<'PY'
from agent_usage_fixtures import *

MODES = {"up": "ok", 500: "backend", "down": "died", 401: "auth"}


# The stand-in app-server answers as CODEX_FAKE says.
@contextlib.contextmanager
def serve(mode):
  os.environ["CODEX_FAKE"] = MODES.get(mode, mode)
  yield


def starts():
  try:
    return len((home() / "codex-starts").read_text().splitlines())
  except FileNotFoundError:
    return 0


def codex(mode, *args, **env):
  saved = {name: os.environ.get(name) for name in env}
  os.environ.update(env)
  try:
    with serve(mode):
      return collect("codex", *(args or ("--force",)))
  finally:
    for name, value in saved.items():
      if value is None:
        os.environ.pop(name, None)
      else:
        os.environ[name] = value


# Signs ~/.codex in as a user of a workspace, the way Codex writes it: the
# workspace as account_id, the user in the ID token's claims.
def login(workspace, user):
  claims = {"https://api.openai.com/auth": {"chatgpt_account_id": workspace, "chatgpt_user_id": user}}
  write_json(home() / ".codex" / "auth.json", {"tokens": {"id_token": jwt(claims), "account_id": workspace}})


# ---------------------------------------------------------------- contract

login("ws-one", "user-a")
# "cut": the app-server talks JSON-RPC over a pipe, not HTTP, so there is no
# reply to cut short; its own failures are covered below.
fresh = check_limits_contract(Adapter("codex", serve=serve, count=starts, refused_status="Waiting for auth", retry_modes=("down",),
                                      skip=("cut",)))
expect("fresh Codex limits read both windows and the plan",
       [[entry["percent"] for entry in fresh["limits"]], fresh["tierLabel"]], [[0.4, 0.7], "Pro 200"], fresh)

# ------------------------------------------------------- a failed probe

# However the app-server fails, the last limits stand, stale, and the help
# says what went wrong. Only a network that isn't there yet asks the panel to
# retry soon: a stalled app-server, or one that died unable to reach OpenAI.
# A refusal, or a crash of its own, would only fail again; a sign-out says so.
good = codex("ok")
for mode, retry, status in (("backend", False, ""), ("died", True, ""), ("crashed", False, ""), ("empty", False, ""), ("auth", False, "Waiting for auth")):
  kept = codex(mode)
  expect(f"a failed Codex probe ({mode}) keeps the last limits, stale, and says what went wrong", {
    "limits": kept["limits"] == good["limits"], "stale": kept["limitsStale"], "at": kept["limitsFetchedAt"] == good["limitsFetchedAt"],
    "tier": kept["tierLabel"], "status": kept["usageStatusText"], "help": bool(kept["authHelpText"]), "retry": kept.get("retryAdvised", False),
  }, {"limits": True, "stale": True, "at": True, "tier": "Pro 200", "status": status, "help": True, "retry": retry}, kept)

# A plan without windows is an answer too: a later failed probe has no limits
# to lose, so it is no trouble, whatever went wrong. A sign-out still says so.
no_windows = codex("ok", CODEX_RATE_LIMITS=json.dumps({"planType": "free"}))
expect("a Codex plan without windows is a healthy answer", [no_windows["limits"], no_windows["usageStatusText"], no_windows["tierLabel"]], [[], "", "Free"], no_windows)
for mode, retry, status in (("backend", False, ""), ("died", True, ""), ("crashed", False, ""), ("auth", False, "Waiting for auth")):
  failed = codex(mode)
  expect(f"a failed Codex probe ({mode}) after a plan without windows is no trouble", {
    "limits": failed["limits"], "tier": failed["tierLabel"], "status": failed["usageStatusText"], "help": bool(failed["authHelpText"]),
    "retry": failed.get("retryAdvised", False),
  }, {"limits": [], "tier": "Free", "status": status, "help": bool(status), "retry": retry}, failed)
good = codex("ok")

# A stall costs the app-server's whole 8-second answer timeout, so this run's
# collector waits half a second instead. (The collector reads its
# environment when it loads, so it loads inside the mode.)
with serve("stall"):
  collector = load_collector("codex")
  rpc_request = collector.rpc_request
  collector.rpc_request = lambda proc, request_id, method, params=None, timeout=8: rpc_request(proc, request_id, method, params, min(timeout, 0.5))
  stalled = run_main(collector, "--force")
expect("a stalled Codex app-server advises a retry beside the last limits",
       [stalled.get("retryAdvised"), stalled["limitsStale"], stalled["limits"] == good["limits"]], [True, True, True], stalled)

# --------------------------------------------------------- whose limits

for workspace, user in (("ws-two", "user-a"), ("ws-one", "user-b")):
  login(workspace, user)
  other = codex("backend")
  expect(f"a home signed in to someone else never shows the last one's limits ({workspace} {user})",
         [other["limits"], other["usageStatusText"]], [[], "Codex limits unavailable"], other)
login("ws-one", "user-a")

# The login auth.json names only answers when nothing overrides it.
token = codex("backend", CODEX_ACCESS_TOKEN="another")
expect("an access token in the environment never shows auth.json's account's limits", token["limits"], [], token)

# The token signs in the primary home alone: a registered home without a login
# of its own waits for one rather than answering for the token's account.
side = state_home() / "omarchy" / "agents" / "accounts" / "codex" / "side"
side.mkdir(parents=True)
registry("codex", [
  {"id": "main", "label": "Main", "home": "", "primary": True},
  {"id": "side", "label": "Side", "home": str(side), "primary": False},
], active="main")
before_starts = starts()
tokened = codex("ok", CODEX_ACCESS_TOKEN="another")
expect("CODEX_ACCESS_TOKEN signs in only the primary of several Codex homes",
       [[(account["id"], account["usageStatusText"], bool(account["limits"])) for account in tokened["accounts"]], starts() - before_starts],
       [[("main", "", True), ("side", "Waiting for auth", False)], 1], tokened)
for path in (state_home() / "omarchy" / "agents" / "accounts").glob("codex.json"):
  path.unlink()

(home() / ".codex" / "config.toml").write_text('cli_auth_credentials_store = "keyring"\n')
keyring = codex("backend")
(home() / ".codex" / "config.toml").unlink()
expect("a keyring login, which can't be told apart, keeps no limits", keyring["limits"], [], keyring)

# An API-key login has no plan limits, so no app-server is started to ask and
# there is no sign-in to ask for: Codex's own auth_mode, or a key without
# ChatGPT tokens. A ChatGPT auth_mode beside a key still asks Codex.
for shape in ({"auth_mode": "apikey", "OPENAI_API_KEY": "sk-test"}, {"OPENAI_API_KEY": "sk-test"}, {"OPENAI_API_KEY": "sk-test", "tokens": None},
              {"OPENAI_API_KEY": "sk-test", "tokens": {"id_token": "x", "access_token": "y", "refresh_token": "z"}}):
  write_json(home() / ".codex" / "auth.json", shape)
  before_starts = starts()
  keyed = [codex("ok"), codex("ok", "--limits-only")]
  expect(f"an API-key Codex login starts no app-server and waits for no auth ({json.dumps(sorted(shape))})",
         [[(run["limits"], run["usageStatusText"], run["authHelpText"], run["limitsStale"]) for run in keyed], starts() - before_starts],
         [[([], "", "Signed in with an API key, which has no plan limits.", False)] * 2, 0], keyed)
write_json(home() / ".codex" / "auth.json", {"auth_mode": "chatgpt", "OPENAI_API_KEY": "sk-test"})
before_starts = starts()
chatgpt = codex("ok")
expect("a ChatGPT auth_mode beside an API key still asks the app-server", [bool(chatgpt["limits"]), starts() - before_starts], [True, 1], chatgpt)
login("ws-one", "user-a")

own = codex("backend")
expect("the file store's own account keeps its limits", [own["limitsStale"], own["limits"] == good["limits"]], [True, True], own)

# Signed in to someone else while the probe ran: the answer is shown, but kept
# for neither login. It reads 55% where the kept answer read 40%.
os.environ["CODEX_RATE_LIMITS"] = json.dumps({"planType": "pro", "primary": {"usedPercent": 55, "windowDurationMins": 300, "resetsAt": int(time.time()) + 3600}})
with serve("up"):
  collector = load_collector("codex")
  fetch = collector.fetch_codex_rpc

  def fetch_across_login_change(home_dir=None, primary=True):
    answer = fetch(home_dir, primary)
    login("ws-three", "user-c")
    return answer

  collector.fetch_codex_rpc = fetch_across_login_change
  switched = run_main(collector, "--force")
del os.environ["CODEX_RATE_LIMITS"]
expect("a probe across a login change still reports what it got", [switched["limitsStale"], switched["limits"][0]["percent"]], [False, 0.55], switched)
after = codex("backend")
expect("limits from a probe across a login change aren't kept for the new login", after["limits"], [], after)
login("ws-one", "user-a")
before = codex("backend")
expect("limits from a probe across a login change don't replace the old login's", [before["limits"] == good["limits"], before["limitsFetchedAt"] == good["limitsFetchedAt"]], [True, True], before)

# A user id that isn't valid text, a token list, or a missing ID token: the
# collector still prints a record, with nothing kept to show.
login("ws-one", "\udced\udca0\udc80")
for shape in ("surrogate user", {"tokens": ["unexpected"]}, {"tokens": {"account_id": "ws-one"}}):
  if shape != "surrogate user":
    write_json(home() / ".codex" / "auth.json", shape)
  odd = codex("backend")
  expect(f"an auth.json of another shape still gives a record ({json.dumps(shape)})", odd["usageStatusText"], "Codex limits unavailable", odd)

# ---------------------------------------------------- a plan without windows

# A plan the app-server gives no windows for is an answer, reused like any
# other rather than starting an app-server every run.
login("ws-five", "user-e")
bare = codex("ok", CODEX_RATE_LIMITS=json.dumps({"planType": "free"}))
before_starts = starts()
reused = codex("ok", "--limits-only", CODEX_RATE_LIMITS=json.dumps({"planType": "free"}))
expect("an answer without windows stands in for the next probe",
       [bare["limits"], bare["tierLabel"], reused["limits"], reused["tierLabel"], reused["limitsStale"], starts() - before_starts],
       [[], "Free", [], "Free", False, 0], reused)

# ------------------------------------------------------------ a spend cap

# A spend cap is kept like any window: stale past a failed check, and back at
# zero once the reset it named has passed (a cache rewrite, no sleeping).
login("ws-four", "user-d")
spend = {"planType": "business", "individualLimit": {"limit": "6000", "used": "3000", "remainingPercent": 50, "resetsAt": int(time.time()) + 3600}}
spent = codex("ok", CODEX_RATE_LIMITS=json.dumps(spend))
expect("a Codex spend cap reads as a titled meter with its reset time",
       [spent["limitsStale"], [[entry["title"], entry["percent"], bool(entry["resetsAt"])] for entry in spent["limits"]]],
       [False, [["Spend limit", 0.5, True]]], spent)
edit_limits_cache("codex", resets_past=True)
kept = codex("backend")
expect("a kept Codex spend cap whose reset passed comes back at zero, stale",
       [kept["limitsStale"], kept["limitsFetchedAt"] == spent["limitsFetchedAt"], [[entry["title"], entry["percent"], entry["resetsAt"]] for entry in kept["limits"]]],
       [True, True, [["Spend limit", 0.0, ""]]], kept)

# ------------------------------------------------------------- no CLI

# A Codex home puts Codex in use, so a missing CLI is then worth saying.
sandbox()
(home() / ".codex" / "sessions").mkdir(parents=True)
path = os.environ["PATH"]
os.environ["PATH"] = str(home() / "empty-bin")
try:
  missing = collect("codex", "--force")
finally:
  os.environ["PATH"] = path
expect("a Codex home without the CLI says the CLI is missing",
       [missing["usageStatusText"], missing["authHelpText"]], ["Codex limits unavailable", "codex not found in PATH"], missing)

# --------------------------------------------------------------- the answer

# The app-server's rate-limit answer as fetch_codex_rpc reads it, from a
# stand-in that answers RPC_LIMITS whole and logs every account/read.
sandbox()
codex_home = home() / ".codex"
write_json(codex_home / "auth.json", {})
stub = home() / "rpc-bin" / "codex"
stub.parent.mkdir()
stub.write_text("#!" + sys.executable + "\n" + '''
import json, os, sys
from pathlib import Path

for line in sys.stdin:
  request = json.loads(line)
  if "id" not in request:
    continue
  method = request["method"]
  if method == "account/read":
    with Path(os.environ["RPC_CALLS"]).open("a") as log:
      log.write(method + "\\n")
    reply = {"account": {"planType": "plus"}}
  elif method == "account/rateLimits/read":
    reply = json.loads(os.environ["RPC_LIMITS"])
  else:
    reply = {}
  print(json.dumps({"id": request["id"], "result": reply}), flush=True)
''')
stub.chmod(0o755)
calls = home() / "calls"
os.environ.update(PATH=str(stub.parent) + os.pathsep + path, RPC_CALLS=str(calls))


def window(percent, minutes=300):
  return {"usedPercent": percent, "windowDurationMins": minutes}


def entry(percent, label="5h window", title=None):
  result = {"label": label, "percent": percent / 100, "resetsAt": ""}
  if title:
    result["title"] = title
  return result


def reads(name, payload, expected, plan="Pro 200", account_read=False, reset_credits=None):
  calls.write_text("")
  os.environ["RPC_LIMITS"] = json.dumps(payload)
  result = load_collector("codex").fetch_codex_rpc(codex_home)
  expect(name, {
    "status": result["usageStatusText"], "help": result["authHelpText"], "plan": result["tierLabel"], "limits": result["limits"],
    "accountRead": bool(calls.read_text()), "resetCredits": result.get("resetCredits"),
  }, {"status": "", "help": "", "plan": plan, "limits": expected, "accountRead": account_read, "resetCredits": reset_credits}, result)


legacy = {"planType": "pro", "primary": window(12)}
reads("legacy single-bucket limits keep their display shape", {"rateLimits": legacy}, [entry(12)])
reads("map-only limits supply both windows and the plan", {
  "rateLimitsByLimitId": {"codex": {"planType": "pro", "primary": window(25), "secondary": window(42, 10080)}}
}, [entry(25), entry(42, "Weekly (7-day)")])
reads("multi-bucket limits supersede the legacy view without duplicates", {
  "rateLimits": legacy, "rateLimitsByLimitId": {"codex": {"planType": "pro", "primary": window(36)}}
}, [entry(36)])
reads("named buckets are titled for their model and window, general Codex limits first", {
  "rateLimits": {"planType": "plus", "primary": window(99)},
  "rateLimitsByLimitId": {
    "codex_other": {"planType": "plus", "limitName": "Other model", "primary": window(80, 60)},
    "codex": {"planType": "pro", "primary": window(25)}}
}, [entry(25), entry(80, "1h window", "Other model Session")])
reads("a single named bucket keeps its model label", {
  "rateLimitsByLimitId": {"codex_other": {"planType": "pro", "limitName": "Other model", "primary": window(80)}}
}, [entry(80, title="Other model Session")])
reads("unnamed model buckets are titled with their identifiers", {
  "rateLimitsByLimitId": {"codex": legacy, "codex_other": {"primary": window(80)}}
}, [entry(12), entry(80, title="codex_other Session")])
for unavailable in (None, {}, {"codex": None}, []):
  reads("unavailable multi-bucket view falls back to legacy: " + repr(unavailable), {
    "rateLimits": legacy, "rateLimitsByLimitId": unavailable
  }, [entry(12)])
reads("invalid map entries do not hide valid buckets", {"rateLimitsByLimitId": {"invalid": None, "codex": legacy}}, [entry(12)])
reads("legacy plan metadata is retained when map buckets omit it", {
  "rateLimits": legacy, "rateLimitsByLimitId": {"codex": {"primary": window(33)}}
}, [entry(33)])
reads("account metadata remains an optional plan fallback", {
  "rateLimitsByLimitId": {"codex": {"primary": window(33)}}
}, [entry(33)], plan="Plus", account_read=True)
reads("malformed legacy metadata does not erase valid map limits", {
  "rateLimits": [], "rateLimitsByLimitId": {"codex": {"primary": window(33)}}
}, [entry(33)], plan="Plus", account_read=True)
reads("a weekly model bucket attaches to the weekly window", {
  "rateLimitsByLimitId": {"codex": legacy, "codex_spark": {"limitName": "Spark", "secondary": window(30, 10080)}}
}, [entry(12), entry(30, "Weekly (7-day)", "Spark Weekly")])
reads("an untrusted percentage or reset time costs only that window or field", {
  "rateLimits": {"planType": "pro", "primary": {"usedPercent": "lots", "windowDurationMins": 300},
                 "secondary": {"usedPercent": 250, "windowDurationMins": 10080, "resetsAt": -5}}
}, [entry(100, "Weekly (7-day)")])
reads("multi-bucket limits retain earned reset credits", {
  "rateLimitsByLimitId": {"codex": legacy},
  "rateLimitResetCredits": {"credits": [{"status": "available", "expiresAt": 1900000000}]}
}, [entry(12)], reset_credits={"available": 1, "nextExpiresAt": "2030-03-17T17:46:40+00:00"})

cap = {"limit": "6000", "used": "1500", "remainingPercent": 75, "resetsAt": 1793491200}


def spend_entry(share, resets_at="2026-11-01T00:00:00+00:00"):
  return {"label": "Spend limit", "percent": share, "resetsAt": resets_at, "title": "Spend limit"}


reads("a spend cap follows the windows once, however many views carry it", {
  "rateLimits": dict(legacy, individualLimit=cap),
  "rateLimitsByLimitId": {"codex": dict(legacy, individualLimit=cap),
                          "codex_spark": {"limitName": "Spark", "secondary": window(30, 10080), "individualLimit": cap}}
}, [entry(12), entry(30, "Weekly (7-day)", "Spark Weekly"), spend_entry(0.25)])
reads("a spend cap only the backward-compatible view carries still counts", {
  "rateLimits": dict(legacy, individualLimit=cap), "rateLimitsByLimitId": {"codex": legacy}
}, [entry(12), spend_entry(0.25)])
reads("a spend cap without usable amounts reads its reported percentage", {
  "rateLimits": dict(legacy, individualLimit={"limit": True, "used": "NaN", "remainingPercent": 75, "resetsAt": -5})
}, [entry(12), spend_entry(0.25, "")])
reads("an untrusted spend cap costs only its own meter", {
  "rateLimits": dict(legacy, individualLimit={"limit": "6000", "used": "lots", "remainingPercent": float("nan")})
}, [entry(12)])

# The plan reads as Codex 0.163's /status names it (SubscriptionDisplay::Status),
# not as its wire planType, and one newer than that keeps its wire name.
for wire, shown in (("free", "Free"), ("go", "Go"), ("plus", "Plus"), ("pro", "Pro 200"), ("prolite", "Pro 100"), ("promax", "Pro 500"),
                    ("team", "Business"), ("self_serve_business_usage_based", "Business"), ("self_serve_business_prolite", "Business Premium"),
                    ("business", "Enterprise"), ("enterprise_cbp_automation", "Enterprise (Automation)"), ("enterprise_cbp_usage_based", "Enterprise"),
                    ("ent26", "Enterprise"), ("enterprise", "Enterprise"), ("edu", "Edu"), ("edu_plus", "Edu Plus"), ("edu_pro", "Edu Pro"),
                    ("ultra_max", "ultra max")):
  reads(f"the {wire} plan reads as {shown!r}", {"rateLimits": dict(legacy, planType=wire)}, [entry(12)], plan=shown)
PY
