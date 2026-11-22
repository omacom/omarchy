#!/bin/bash

# The Synthetic collector's own sources: the API key from the environment,
# pi, omp, opencode or a named profile, Synthetic's quotas answer, and the
# Hugging Face model names it bills. The unused-machine record and counting
# pi, omp and opencode rows once are held centrally by the partition test,
# and the limits and scan caches by the contract checks, run here against a
# real stand-in for api.synthetic.new.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox
require_command rg

python3 - <<'PY'
from agent_usage_fixtures import *

MODERN = {
  "subscription": {"requests": 0, "limit": 1000, "renewsAt": "2099-08-17T00:00:00Z"},
  "rollingFiveHourLimit": {"remaining": 750, "max": 1000, "limited": False, "nextTickAt": "2099-08-16T02:00:00Z"},
  "weeklyTokenLimit": {"percentRemaining": 64, "remainingCredits": "$31.05", "maxCredits": "$48.00", "nextRegenAt": "2099-08-16T04:00:00Z"},
  "search": {"hourly": {"requests": 25, "limit": 250, "renewsAt": "2099-08-16T03:00:00Z"}},
  "freeToolCalls": {"requests": "many", "limit": 100},
}
state = {"mode": "up"}


# A stand-in for api.synthetic.new: /v2/quotas answers with MODERN while up,
# and with the mode's status otherwise.
def quotas(request):
  # Something to do while the request is in flight, once.
  if state.get("during"):
    state.pop("during")()
  if isinstance(state["mode"], int):
    return state["mode"], {"error": "refused"}
  return MODERN if request["path"] == "/v2/quotas" else {}


BASE_URL, reqs = stub_server(quotas)


# The stub's mode for the runs inside; an unreachable service is FakeHttp's,
# in front of the opener.
@contextlib.contextmanager
def serve(mode):
  os.environ["SYNTHETIC_API_BASE_URL"] = BASE_URL
  if mode in ("down", "timeout", "cut", "garbage"):
    with FakeHttp(mode=mode):
      yield
    return
  state["mode"] = mode
  try:
    yield
  finally:
    state["mode"] = "up"


def synthetic(*args):
  with serve("up"):
    return collect("synthetic", *(args or ("--force",)))


def sessions():
  return home() / ".pi" / "agent" / "sessions"


def key_used(**env):
  for path in limits_cache_files("synthetic"):
    path.unlink()
  saved = {name: os.environ.get(name) for name in env}
  os.environ.update(env)
  try:
    synthetic()
  finally:
    for name, value in saved.items():
      if value is None:
        os.environ.pop(name, None)
      else:
        os.environ[name] = value
  return reqs[-1]["headers"].get("Authorization") if reqs else None


# ---------------------------------------------------------------- the key

# The partition test holds the rest of the unused-machine record; asking
# nothing without a key is Synthetic's own to say.
sandbox()
record = synthetic()
expect("Synthetic asks nothing without a key", [record["ready"], record["limits"], len(reqs)], [False, [], 0], record)

pi_auth(home() / ".omp" / "profiles" / "work" / "agent", "synthetic", "profile-key")
expect("Synthetic reads a named profile's key", key_used(), "Bearer profile-key")
opencode_auth(None, "synthetic", "opencode-key")
expect("Synthetic prefers opencode's key to a profile's", key_used(), "Bearer opencode-key")
pi_auth(home() / ".omp" / "agent", "synthetic", "omp-key")
expect("Synthetic prefers omp's key to opencode's", key_used(), "Bearer omp-key")
pi_auth(None, "synthetic", "$PI_SYNTHETIC")
expect("Synthetic resolves pi's $ENV key", key_used(PI_SYNTHETIC="pi-key"), "Bearer pi-key")
write_json(home() / "moved" / "auth.json", {"synthetic": {"key": "moved-key"}})
expect("Synthetic follows PI_CODING_AGENT_DIR to pi's key", key_used(PI_CODING_AGENT_DIR=str(home() / "moved")), "Bearer moved-key")
expect("Synthetic prefers SYNTHETIC_API_KEY to every stored key", key_used(SYNTHETIC_API_KEY="env-key"), "Bearer env-key")

# ---------------------------------------------------------------- contract

sandbox()


def add_usage():
  add_usage.count = getattr(add_usage, "count", 0) + 1
  write_pi_session(sessions() / "grown" / f"{add_usage.count}.jsonl", [pi_reply("synthetic", 10, id=f"grown-{add_usage.count}")])


adapter = Adapter("synthetic", plant=lambda: os.environ.update(SYNTHETIC_API_KEY="secret"), serve=serve, count=lambda: len(reqs),
                  grow=add_usage, pi_root=sessions)
fresh = check_limits_contract(adapter)

# The rolling limit and the weekly credits regenerate a little at a time, so
# their next tick is no reset time; search renews on the hour.
expect("Synthetic maps the quota windows, leaving regeneration ticks out of reset times",
       [[entry["label"], round(entry["percent"], 3), entry["resetsAt"], entry.get("title", "")] for entry in fresh["limits"]],
       [["Rolling (5h)", 0.25, "", ""], ["Weekly credits", 0.36, "", ""], ["Search (hourly)", 0.1, "2099-08-16T03:00:00Z", "Search"]], fresh)
expect("Synthetic's windows carry only contract fields and no plan",
       [fresh["tierLabel"], sorted({key for entry in fresh["limits"] for key in entry})], ["", ["label", "percent", "resetsAt", "title"]], fresh)

with serve(401):
  record = collect("synthetic", "--force")
expect("a refused key keeps the last quotas beside the sign-in it asks for",
       [record["usageStatusText"], record["limitsStale"], len(record["limits"])], ["Sign-in expired", True, 3], record)

for path in limits_cache_files("synthetic"):
  path.unlink()
with serve(500):
  record = collect("synthetic", "--force")
expect("a failed check with nothing kept says the limits are unavailable",
       [record["usageStatusText"], record["limits"], record["limitsFetchedAt"]], ["Synthetic limits unavailable", [], 0], record)
check("a failed check says what failed", "status 500" in record["authHelpText"], record)

# An answer never rolls back one another run stamped while this one waited
# on the network.
synthetic()
state["during"] = lambda: edit_limits_cache("synthetic", fetched_ago=-60)
synthetic()
expect("Synthetic never overwrites a newer cached answer with its own",
       [json.loads(path.read_text())["fetchedAtMs"] > ms_in(30) for path in limits_cache_files("synthetic")], [True])
for path in limits_cache_files("synthetic"):
  path.unlink()

check_scan_cache(adapter)

# ------------------------------------------------------------- the answer

parse_quotas = load_collector("synthetic").parse_quotas
expect("Synthetic reads the documented subscription bucket",
       [[entry["label"], entry["percent"]] for entry in parse_quotas({"subscription": {"requests": 27, "limit": 135, "renewsAt": "2099-08-17T00:00:00Z"}})],
       [["Subscription requests", 0.2]])
expect("Synthetic fills a limited rolling window and skips an unreadable one",
       [entry["percent"] for entry in parse_quotas({"rollingFiveHourLimit": {"remaining": 900, "max": 1000, "limited": True}, "weeklyTokenLimit": {"percentRemaining": True}})],
       [1.0])

# SYNTHETIC_API_BASE_URL moves the endpoint, never the key onto plain HTTP
# to another machine, nor into a URL that isn't one.
sandbox()
os.environ["SYNTHETIC_API_KEY"] = "secret"
for url in ("http://evil.example", "not a url"):
  os.environ["SYNTHETIC_API_BASE_URL"] = url
  with FakeHttp({"/v2/quotas": MODERN}) as http:
    record = collect("synthetic", "--force")
  expect(f"Synthetic sends its key to no untrusted endpoint ({url})",
         [http.count, record["usageStatusText"], "HTTPS" in record["authHelpText"]], [0, "Synthetic limits unavailable", True], record)
  expect(f"a Synthetic key with no sessions here has no local stats ({url})",
         [record["ready"], record["totalSessions"], record["hasLocalStats"]], [True, 0, False], record)
del os.environ["SYNTHETIC_API_KEY"], os.environ["SYNTHETIC_API_BASE_URL"]

# ------------------------------------------------------------ local stats

# Synthetic serves Hugging Face models as hf:org/model; the model is the last
# part, from pi and opencode alike.
sandbox()
write_pi_session(sessions() / "work" / "one.jsonl", [pi_reply("synthetic", 100, id="a", model="hf:moonshotai/Kimi-K2")])
opencode_db(message=[("m1", "s1", oc_v1("synthetic", 40, model="hf:zai-org/GLM-4.6"))])
record = synthetic()
expect("Synthetic names its Hugging Face models by their last part", sorted(record["modelUsage"]), ["GLM-4.6", "Kimi-K2"], record)
expect("Synthetic in use without a key waits for auth",
       [record["ready"], record["usageStatusText"], record["limits"]], [True, "Waiting for auth", []], record)
expect("Synthetic's sessions here are local stats", record["hasLocalStats"], True, record)
PY
