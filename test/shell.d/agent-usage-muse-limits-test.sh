#!/bin/bash

# The Muse collector's limits: the login the Muse CLI keeps, Muse's key
# endpoint and the subscription windows, plan and pay-as-you-go answers it
# gives. The unused-machine record is held centrally by the partition test,
# the limits cache by the contract checks, run here against a real stand-in
# for the key endpoint, and Muse's local stats by its scanner test.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

SUBSCRIBER = {"body": {"subs_tier_name": "Power Usage", "subs_usage": {
  "window": {"used_percent": 8, "window_duration_mins": 300, "resets_at": 4102444800},
  "weekly": {"used_percent": 15, "resets_at": 4103049600}}}}
PAYG = {"body": {"api_key": "minted", "is_subs_active": False, "subs_tier_name": None}}
state = {"spec": SUBSCRIBER}


# A stand-in for Muse's key endpoint, answering the POST from state["spec"]:
# a body, or a status, or raw bytes.
def key_endpoint(request):
  spec = state["spec"]
  if spec.get("status", 200) != 200:
    return spec["status"], b""
  return spec.get("raw") or spec.get("body", {})


ENDPOINT, reqs = stub_server(key_endpoint)
ENDPOINT += "/key"


@contextlib.contextmanager
def serve(mode):
  os.environ["MUSE_KEY_ENDPOINT"] = ENDPOINT
  if mode in ("down", "timeout", "cut", "garbage"):
    with FakeHttp(mode=mode):
      yield
    return
  state["spec"] = SUBSCRIBER if mode == "up" else {"status": mode}
  yield


def muse(spec=None, *args, fresh_cache=True):
  """A run against the key endpoint answering `spec`, from no cache unless
  fresh_cache is False."""
  if fresh_cache:
    for path in limits_cache_files("muse"):
      path.unlink()
  os.environ["MUSE_KEY_ENDPOINT"] = ENDPOINT
  if spec is not None:
    state["spec"] = spec
  return collect("muse", *(args or ("--force",)))


def auth_path():
  return config_home() / "muse" / "auth.json"


def signed_in(token="test-token"):
  write_json(auth_path(), {"schema_version": 1, "providers": {"meta": {"access_token": token, "api_base_url": "https://api.meta.ai/v1"}}})


def auth_state():
  return (auth_path().stat().st_mtime, auth_path().read_bytes(), sorted(path.name for path in auth_path().parent.iterdir()))


# ---------------------------------------------------------------- contract

sandbox()
signed_in()
os.utime(auth_path(), (1767225600, 1767225600))
auth_before = auth_state()

fresh = check_limits_contract(Adapter("muse", serve=serve, count=lambda: len(reqs)))
expect("Muse reads the session and weekly windows, their resets, and the plan from the key endpoint",
       [fresh["tierLabel"], [[entry["label"], entry["percent"], entry["resetsAt"]] for entry in fresh["limits"]]],
       ["Power Usage", [["Session (5-hour)", 0.08, "2100-01-01T00:00:00+00:00"], ["Weekly (7-day)", 0.15, "2100-01-08T00:00:00+00:00"]]], fresh)
expect("Muse authenticates the probe with the saved token", reqs[-1]["headers"].get("Authorization"), "Bearer test-token")

leaks = [str(path) for path in home().rglob("*") if path.is_file() and path != auth_path() and b"test-token" in path.read_bytes()]
expect("Muse keeps the token out of every cache and file of its own", leaks, [])

# The plan is kept with the windows, so a reused or kept answer still names it.
with serve(500):
  reused = collect("muse")
  kept = collect("muse", "--force")
expect("a reused and a kept Muse answer keep the plan", [reused["tierLabel"], kept["tierLabel"], kept["limitsStale"]], ["Power Usage", "Power Usage", True], kept)

# The login file belongs to the Muse CLI: every run so far only read it.
expect("Muse never writes the login file", auth_state(), auth_before)

# MUSE_KEY_ENDPOINT moves the endpoint, but the token only goes over HTTPS or
# plain HTTP to loopback.
before = len(reqs)
for path in limits_cache_files("muse"):
  path.unlink()
with FakeHttp({"/key": SUBSCRIBER["body"]}) as http:
  os.environ["MUSE_KEY_ENDPOINT"] = "http://muse.example.com/key"
  plain = collect("muse", "--force")
os.environ["MUSE_KEY_ENDPOINT"] = ENDPOINT
expect("the Muse token never goes to a plain HTTP endpoint off loopback",
       [http.requests, len(reqs) - before, "HTTPS" in plain["authHelpText"]], [[], 0, True], plain)

# ------------------------------------------------------- answers without windows

# Pay-as-you-go: the key mints, but there is no subscription window to meter
# and no plan name to invent. Local metering only: not an error, not expired.
payg = muse(PAYG)
expect("Muse stays silent for a pay-as-you-go account",
       [payg["limits"], payg["tierLabel"], payg["usageStatusText"], payg["authHelpText"], "retryAdvised" in payg], [[], "", "", "", False], payg)

# An active plan without usage windows (the live Muse Code shape) keeps its
# name and shows local metering only.
plan = muse({"body": {"api_key": "minted", "is_subs_active": True, "subs_tier_name": "Muse Code Everyday Usage"}})
expect("Muse stays silent for an active plan without usage windows",
       [plan["limits"], plan["tierLabel"], plan["usageStatusText"], plan["authHelpText"], "retryAdvised" in plan],
       [[], "Muse Code Everyday Usage", "", "", False], plan)
expect("a Muse sign-in shows before its first session, pay-as-you-go included", [payg["ready"], plan["ready"]], [True, True])
expect("a Muse sign-in with no sessions here has no local stats", [payg["hasLocalStats"], plan["hasLocalStats"]], [False, False])

# A plan that moved to pay-as-you-go leaves its old windows behind: a failed
# check after that brings none of them back. The answer is reused like any
# other, so a panel flick doesn't mint a key again.
muse(SUBSCRIBER)
muse(PAYG, fresh_cache=False)
asked = len(reqs)
reused = collect("muse")
expect("a recent pay-as-you-go answer is reused", [len(reqs) - asked, reused["limits"]], [0, []], reused)
switched = muse({"status": 500}, fresh_cache=False)
expect("a former plan's windows stay out after it moved to pay-as-you-go", switched["limits"], [], switched)

# Neither active nor pay-as-you-go and no windows: a warning, never invented
# meters.
unknown = muse({"body": {"api_key": "minted", "subs_tier_name": "Mystery"}})
expect("Muse reports unavailable limits for an answer of unknown shape", unknown["usageStatusText"], "Muse limits unavailable", unknown)

hours = muse({"body": {"subs_tier_name": "T", "subs_usage": {"window": {"used_percent": 5, "window_duration_mins": 120, "resets_at": 4102444800},
                                                           "weekly": {"used_percent": 1, "resets_at": 4103049600}}}})
expect("Muse labels a whole-hour session window in hours", hours["limits"][0]["label"], "Session (2-hour)", hours)

# omp's schema for these windows takes resets_at as a string or a number, and
# reads a string as an ISO time.
iso = muse({"body": {"subs_tier_name": "T", "subs_usage": {"window": {"used_percent": 5, "resets_at": "2100-01-01T00:00:00Z"},
                                                         "weekly": {"used_percent": 1, "resets_at": "2100-01-08T00:00:00+00:00"}}}})
expect("Muse reads a reset given as an ISO time", [entry["resetsAt"] for entry in iso["limits"]],
       ["2100-01-01T00:00:00+00:00", "2100-01-08T00:00:00+00:00"], iso)

# ---------------------------------------------------------------- the login

# A malformed login file is a missing credential, not a crash: the Muse CLI is
# set up here, so it waits for a sign-in.
for malformed in ("[1,2]", '"nope"', '{"providers":[]}', '{"providers":{"meta":7}}'):
  auth_path().write_text(malformed)
  garbled = muse(SUBSCRIBER)
  expect(f"Muse waits for a sign-in past a malformed login file ({malformed})",
         [garbled["limits"], garbled["usageStatusText"], garbled["ready"]], [[], "Waiting for auth", True], garbled)

# MUSE_AUTH_PATH wins over a different login at the default place.
signed_in("default-token")
custom = home() / "custom auth.json"
write_json(custom, {"providers": {"meta": {"access_token": "custom-token"}}})
os.environ["MUSE_AUTH_PATH"] = str(custom)
muse(SUBSCRIBER)
del os.environ["MUSE_AUTH_PATH"]
expect("Muse honors MUSE_AUTH_PATH over the default login", reqs[-1]["headers"].get("Authorization"), "Bearer custom-token")
PY
