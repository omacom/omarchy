#!/bin/bash

# The OpenRouter collector's own sources: the key from OPENROUTER_API_KEY,
# opencode's or pi's or omp's saved login, or its config; the /key meter and
# /credits balance, each kept on its own; and with a management key the
# account's 30-day /activity history in place of the local scan. The
# unused-machine record and which local rows count as OpenRouter's are held
# centrally by the partition test, the pi and opencode readers by the shared
# test, and the limits and scan caches by the contract checks.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

# Bucket dates resolve in local time, so pin the zone or the fixtures below
# would shift by a day depending on where the test runs.
export TZ=UTC

python3 - <<'PY'
from agent_usage_fixtures import *

API = "openrouter.ai/api/v1/"
TODAY = datetime.now().astimezone()
METER = {"data": {"limit": 10, "limit_remaining": 4, "limit_reset": "monthly"}}
CREDITS = {"data": {"total_credits": 10, "total_usage": 1}}
ACTIVITY = {"data": [{"date": TODAY.strftime("%Y-%m-%d"), "model": "a/b", "prompt_tokens": 10, "completion_tokens": 5}]}
ROUTES = {API + "activity": ACTIVITY, API + "key": METER, API + "credits": CREDITS}
DOWN = urllib.error.URLError(OSError("Name or service not known"))


def openrouter(*args, routes=None, mode="up", force=True, **env):
  saved = dict(os.environ)
  os.environ.update(env)
  try:
    with FakeHttp(ROUTES if routes is None else routes, mode=mode) as http:
      record = collect("openrouter", *(args or (("--force",) if force else ())))
  finally:
    os.environ.clear()
    os.environ.update(saved)
  openrouter.asked = sorted(f"/{request['url'].rsplit('/', 1)[1]}={request['headers']['authorization'][7:]}" for request in http.requests)
  return record


def with_routes(**answers):
  return dict(ROUTES, **{API + name: answer for name, answer in answers.items()})


def signed_in():
  os.environ["OPENROUTER_API_KEY"] = "sk-test"


def picked(record, *keys):
  return [record.get(key) for key in keys]


def remaining(record):
  return (record.get("balance") or {}).get("remaining")


# ---------------------------------------------------------------- contract

sandbox()


def add_session():
  add_session.count = getattr(add_session, "count", 0) + 1
  write_pi_session(home() / ".pi" / "agent" / "sessions" / "--grown--" / f"{add_session.count}.jsonl",
                   [pi_reply("openrouter", 1, id=f"g-{add_session.count}", model="anthropic/claude-test")])


adapter = Adapter("openrouter", plant=signed_in, answer=ROUTES, requests_per_probe=2, grow=add_session, pi_root=lambda: home() / ".pi" / "agent" / "sessions")
fresh = check_limits_contract(adapter)
expect("an inference key's credit limit drains toward empty, named for its period, beside the balance",
       [fresh["limits"], remaining(fresh), fresh["tierLabel"], fresh["hasPromptStats"]],
       [[{"label": "Monthly key limit", "title": "Monthly key limit", "percent": 0.6, "resetsAt": ""}], 9.0, "Prepaid", True], fresh)
check_scan_cache(adapter)
del os.environ["OPENROUTER_API_KEY"]

# --------------------------------------------------------------- the answer

module = load_collector("openrouter")

# The local scan counts OpenRouter's assistant rows under the model's own
# name, without its provider prefix.
sandbox()
opencode_db(message=[("m1", "ses_a", oc_v1("openrouter", 100, model="openai/gpt-4o-mini"))])
record = openrouter(OPENROUTER_API_KEY="sk-test")
expect("a model is named without its provider prefix", sorted(record["modelUsage"]), ["gpt-4o-mini"], record)

# /activity folds prompt tokens into input and completion tokens into output,
# one bucket per model. Reasoning is part of the completion count (OpenRouter's
# AI SDK provider reads text = completion - reasoning), so it is never added
# again; the first row is the spec's own ActivityItem example. A row naming
# reasoning alone still counts it as output.
activity = module.summarize_activity([
  {"byok_usage_inference": 0.012, "cached_tokens": 10, "completion_tokens": 125, "date": TODAY.strftime("%Y-%m-%d"),
   "endpoint_id": "550e8400-e29b-41d4-a716-446655440000", "model": "openai/gpt-4.1", "model_permaslug": "openai/gpt-4.1-2025-04-14",
   "prompt_tokens": 50, "provider_name": "OpenAI", "reasoning_tokens": 25, "requests": 5, "usage": 0.015},
  {"date": TODAY.strftime("%Y-%m-%d"), "model": "openai/gpt-4o-mini", "prompt_tokens": 5, "completion_tokens": 0, "reasoning_tokens": 4},
  {"date": "2020-01-01", "model": "x/y-model", "prompt_tokens": 7, "completion_tokens": 3, "reasoning_tokens": 0},
  "garbage-row",
], TODAY)
expect("activity folds prompt and completion tokens per model, with its active dates",
       [activity["todayTotalTokens"], sorted(activity["modelUsage"]), len(activity["activeDates"])], [184, ["gpt-4.1-2025-04-14", "gpt-4o-mini", "y-model"], 2], activity)
expect("activity counts reasoning inside the completion tokens, once, as output",
       [activity["modelUsage"]["gpt-4.1-2025-04-14"]["inputTokens"], activity["modelUsage"]["gpt-4.1-2025-04-14"]["outputTokens"],
        activity["modelUsage"]["gpt-4o-mini"]["outputTokens"]], [50, 125, 4], activity)
expect("a key without a credit limit has no meter, and one with a limit names its period, not a reset time",
       [module.key_limit_meter({"limit": None, "limit_remaining": None}), module.key_limit_meter({"limit": 10, "limit_remaining": 4, "limit_reset": "weekly"})],
       [[], [{"label": "Weekly key limit", "title": "Weekly key limit", "percent": 0.6, "resetsAt": ""}]])

# A read that stalls on its body times out the read itself: a transport
# failure like any other.
class StalledBody:
  def __enter__(self):
    return self

  def __exit__(self, *args):
    return False

  def read(self, *args):
    raise TimeoutError("The read operation timed out")


real_urlopen = urllib.request.urlopen
urllib.request.urlopen = lambda request, timeout=None: StalledBody()
try:
  module.api_get("/key", "sk-test")
  stalled = "no error"
except module.OpenRouterTransportError:
  stalled = "transport"
finally:
  urllib.request.urlopen = real_urlopen
expect("a body that stalls is a transport failure", stalled, "transport")

# --------------------------------------------------------------- the keys

# A management key brings the account's 30-day history in place of the
# local scan: account-wide numbers with no prompt counts.
sandbox()
record = openrouter(OPENROUTER_API_KEY="sk-test", OPENROUTER_MANAGEMENT_KEY="sk-mgmt")
expect("a management key's history is account-wide, with no prompt counts, beside the balance",
       picked(record, "scope", "hasPromptStats", "todayTotalTokens") + [remaining(record), openrouter.asked],
       ["account", False, 15, 9.0, ["/activity=sk-mgmt", "/credits=sk-mgmt", "/key=sk-test"]], record)

# A management key alone still collects the history and the balance, with no
# inference key's meter to show.
sandbox()
record = openrouter(OPENROUTER_MANAGEMENT_KEY="sk-mgmt", routes=with_routes(credits={"data": {"total_credits": 10, "total_usage": 4}}))
expect("a management key alone collects history and balance",
       picked(record, "ready", "scope", "limits", "usageStatusText") + [remaining(record), openrouter.asked],
       [True, "account", [], "", 6.0, ["/activity=sk-mgmt", "/credits=sk-mgmt"]], record)

# The history is reused like a scan, and when /activity can't be reached,
# today's last answer stands in for it.
sandbox()
os.environ["OPENROUTER_MANAGEMENT_KEY"] = "sk-mgmt"
openrouter(OPENROUTER_API_KEY="sk-test")
reused = openrouter(OPENROUTER_API_KEY="sk-test", force=False)
expect("the activity history is reused", [[ask for ask in openrouter.asked if ask.startswith("/activity")], reused["scope"]], [[], "account"], reused)
with contextlib.redirect_stderr(io.StringIO()):
  kept = openrouter(OPENROUTER_API_KEY="sk-test", routes=with_routes(activity=DOWN))
expect("the activity history is kept past an unreachable check", picked(kept, "scope", "todayTotalTokens", "retryAdvised"), ["account", 15, True], kept)
del os.environ["OPENROUTER_MANAGEMENT_KEY"]

# A key nothing was spent through, with no credits and no limit, is an
# unused machine: ready=false and no status from outside the vocabulary.
sandbox()
record = openrouter(OPENROUTER_API_KEY="sk-test", routes=with_routes(key={"data": {"limit": None}}, credits={"data": {"total_credits": 0, "total_usage": 0}}))
expect("a key with nothing to show is an unused machine", picked(record, "ready", "usageStatusText", "authHelpText"), [False, "", ""], record)

# Without any key, what pi, omp and opencode spent through OpenRouter here
# still shows, waiting for a key for the balance and meter.
write_pi_session(home() / ".pi" / "agent" / "sessions" / "--p--" / "s.jsonl", [pi_reply("openrouter", 100, id="a1", model="anthropic/claude-test")])
record = openrouter()
expect("local usage without a key makes the record ready and waits for auth",
       picked(record, "ready", "usageStatusText", "tierLabel", "limits", "balance", "hasLocalStats", "totalPrompts") + [openrouter.asked],
       [True, "Waiting for auth", "", [], None, True, 1, []], record)
expect("and says how to add one", record["authHelpText"].startswith("Set OPENROUTER_API_KEY"), True, record)

# The key pi or omp saved with /login is used, a `$VAR` or `!command` entry
# is left to pi, and PI_CODING_AGENT_DIR moves pi's.
sandbox()
pi_auth(None, "openrouter", "sk-pi")
pi_auth(home() / ".omp" / "agent", "openrouter", "sk-omp")
pi_auth(home() / "moved", "openrouter", "$OPENROUTER_KEY")
saved = [module.api_key({})]
os.environ["PI_CODING_AGENT_DIR"] = str(home() / "moved")
saved.append(module.api_key({}))
del os.environ["PI_CODING_AGENT_DIR"]
record = openrouter()
expect("pi's and omp's saved OpenRouter key is used", saved + [openrouter.asked, record["tierLabel"]],
       ["sk-pi", "sk-omp", ["/credits=sk-pi", "/key=sk-pi"], "Prepaid"], record)
opencode_auth(None, "openrouter", "sk-opencode")
record = openrouter()
expect("opencode's saved OpenRouter key comes before pi's", openrouter.asked, ["/credits=sk-opencode", "/key=sk-opencode"], record)

# A "management" key that /activity refuses (an inference key, or one
# revoked) falls back to the local scan: machine numbers with prompt counts,
# and no sign-in asked for, since the inference key still answers, and reads
# the balance /credits refuses the other key.
sandbox()
write_pi_session(home() / ".pi" / "agent" / "sessions" / "--p--" / "s.jsonl", [pi_reply("openrouter", 100, id="a1", model="anthropic/claude-test")])
for code in (401, 403):
  def refused_manager(request, code=code):
    if request.get_header("Authorization") == "Bearer sk-refused":
      return FakeHttp.refusal(request.full_url, code, {"error": {"code": code, "message": "refused"}})
    return CREDITS
  record = openrouter(OPENROUTER_API_KEY="sk-test", OPENROUTER_MANAGEMENT_KEY="sk-refused", routes=with_routes(activity=code, credits=refused_manager))
  expect(f"a management key /activity refuses ({code}) falls back to the local scan",
         picked(record, "scope", "hasPromptStats", "totalPrompts", "todayTotalTokens", "usageStatusText", "retryAdvised") + [remaining(record), openrouter.asked],
         [None, True, 1, 100, "", None, 9.0, ["/activity=sk-refused", "/credits=sk-refused", "/credits=sk-test", "/key=sk-test"]], record)

# ---------------------------------------------------------- failed checks

# Each key keeps its own meter: another key whose check fails never shows
# this one's numbers.
sandbox()
os.environ["OPENROUTER_API_KEY"] = "sk-test"
openrouter()
other = openrouter(mode=500, OPENROUTER_API_KEY="sk-other")
expect("another key never shows this key's meter, and says what failed",
       picked(other, "limits", "usageStatusText", "retryAdvised", "authHelpText") + [len(limits_cache_files("openrouter"))],
       [[], "OpenRouter limits unavailable", None, "OpenRouter's API returned status 500.", 1], other)

# A refused key (403 as well as 401) is a sign-in to redo, never a raw
# status code, and not worth a sooner retry.
for code in (401, 403):
  openrouter()
  refused = openrouter(mode=code)
  expect(f"a {code} keeps the last meter and asks to sign in again",
         picked(refused, "usageStatusText", "limitsStale", "retryAdvised", "ready", "limits") + [refused["authHelpText"].startswith("OpenRouter refused the API key. ")],
         ["Sign-in expired", True, None, True, fresh["limits"], True], refused)

# OpenRouter documents /credits as management-key only, answering an
# inference key with its 403 example. That key is healthy: the meter shows,
# with no balance and nothing to sign in to again, and the refusal is kept, so
# later refreshes don't ask again. A management key, when there is one, reads
# the balance instead, the only /credits request.
def management_only(request):
  if request.get_header("Authorization") == "Bearer sk-mgmt":
    return CREDITS
  return FakeHttp.refusal(request.full_url, 403, {"error": {"code": 403, "message": "Only management keys can perform this operation"}})


sandbox()
record = openrouter(OPENROUTER_API_KEY="sk-test", routes=with_routes(credits=management_only))
expect("an inference key /credits refuses still shows its meter, with no balance and no sign-in asked",
       picked(record, "usageStatusText", "authHelpText", "limitsStale", "balance", "retryAdvised") + [len(record["limits"]), openrouter.asked],
       ["", "", False, None, None, 1, ["/credits=sk-test", "/key=sk-test"]], record)
record = openrouter(OPENROUTER_API_KEY="sk-test", routes=with_routes(credits=management_only))
expect("an inference key /credits refused isn't asked again on the next refresh",
       picked(record, "usageStatusText", "limitsStale", "balance") + [len(record["limits"]), openrouter.asked],
       ["", False, None, 1, ["/key=sk-test"]], record)
record = openrouter(OPENROUTER_API_KEY="sk-test", OPENROUTER_MANAGEMENT_KEY="sk-mgmt",
                    routes=with_routes(credits=management_only))
expect("a management key reads the balance an inference key is refused",
       picked(record, "usageStatusText", "limitsStale") + [remaining(record), openrouter.asked],
       ["", False, 9.0, ["/activity=sk-mgmt", "/credits=sk-mgmt", "/key=sk-test"]], record)

# A management key revoked after that (OpenRouter's 401 "User not found.")
# is a sign-in to redo, with its last good balance kept, stale, whether the
# inference key is refused /credits afresh or by its kept refusal.
def revoked_manager(request):
  if request.get_header("Authorization") == "Bearer sk-mgmt":
    return FakeHttp.refusal(request.full_url, 401, {"error": {"code": 401, "message": "User not found."}})
  return management_only(request)


sandbox()
openrouter(OPENROUTER_API_KEY="sk-test", OPENROUTER_MANAGEMENT_KEY="sk-mgmt", routes=with_routes(credits=management_only))
for attempt in ("afresh", "by its kept refusal"):
  record = openrouter(OPENROUTER_API_KEY="sk-test", OPENROUTER_MANAGEMENT_KEY="sk-mgmt",
                      routes=with_routes(activity=401, credits=revoked_manager))
  expect(f"a revoked management key asks to sign in again and keeps its balance, the inference key refused {attempt}",
         picked(record, "usageStatusText", "limitsStale") + [remaining(record)], ["Sign-in expired", True, 9.0], record)
  # The inference key still answers /key, so the help names the management
  # key to replace, not OPENROUTER_API_KEY.
  expect(f"a revoked management key's help names the management key, the inference key refused {attempt}",
         [record["authHelpText"].startswith("OpenRouter refused the management key. "), "OPENROUTER_MANAGEMENT_KEY" in record["authHelpText"]],
         [True, True], record)

# A management key alone, revoked, names that key too; with the inference
# key refused as well, the help names the inference key.
record = openrouter(OPENROUTER_MANAGEMENT_KEY="sk-mgmt", routes=with_routes(activity=401, credits=revoked_manager))
expect("a revoked management key with no inference key names the management key",
       [record["usageStatusText"], record["authHelpText"].startswith("OpenRouter refused the management key. ")], ["Sign-in expired", True], record)
record = openrouter(OPENROUTER_API_KEY="sk-test", OPENROUTER_MANAGEMENT_KEY="sk-mgmt", routes=with_routes(activity=401, key=401, credits=revoked_manager))
expect("both keys refused names the API key",
       [record["usageStatusText"], record["authHelpText"].startswith("OpenRouter refused the API key. ")], ["Sign-in expired", True], record)

# A key /credits answers, where OpenRouter still lets one read it, in a fresh
# home, since the refusal above is kept for sk-test.
sandbox()
os.environ["OPENROUTER_API_KEY"] = "sk-test"

# A failed /credits keeps the last good balance, marked stale; with none
# kept, the balance says it is unavailable.
openrouter()
record = openrouter(routes=with_routes(credits=502))
expect("a failed balance check keeps the last balance, stale", [remaining(record)] + picked(record, "limitsStale", "usageStatusText"), [9.0, True, ""], record)
for path in cache_root().glob("openrouter-credits-*.json"):
  path.unlink()
record = openrouter(routes=with_routes(credits=502))
expect("a failed balance check with nothing kept says so", picked(record, "balance", "limitsStale", "usageStatusText"), [None, True, "Balance unavailable"], record)

# A /credits answer without both totals is a failed check, not an empty
# balance: it never overwrites the last good one, so a later failure still
# has it to keep.
openrouter()
record = openrouter(routes=with_routes(credits={"data": {"total_usage": 1}}))
expect("an incomplete balance answer keeps the last balance, stale",
       [remaining(record)] + picked(record, "limitsStale", "usageStatusText", "retryAdvised"), [9.0, True, "", None], record)
record = openrouter(routes=with_routes(credits=502))
expect("an incomplete balance answer never replaces the cached balance", [remaining(record), record["limitsStale"]], [9.0, True], record)

# A /key answer without a readable allowance is a failed check too, not an
# unlimited key: the last meter stays, stale, and survives a later failure.
for incomplete in ({"data": {}}, {}, {"data": {"limit": 10}}, {"data": {"limit": 10, "limit_remaining": "lots"}}):
  openrouter()
  record = openrouter(routes=with_routes(key=incomplete))
  expect(f"an incomplete /key answer {incomplete} keeps the last meter, stale",
         picked(record, "limits", "limitsStale", "usageStatusText"), [fresh["limits"], True, ""], record)
  record = openrouter(routes=with_routes(key=502))
  expect(f"an incomplete /key answer {incomplete} never replaces the cached meter", picked(record, "limits", "limitsStale"), [fresh["limits"], True], record)

# An explicitly unlimited key is a good answer that clears the meter.
openrouter()
record = openrouter(routes=with_routes(key={"data": {"limit": None, "limit_remaining": None}}))
expect("an unlimited key replaces the meter with none, fresh", picked(record, "limits", "limitsStale", "usageStatusText"), [[], False, ""], record)
# Claude Code pointed at OpenRouter's Anthropic-compatible API is
# OpenRouter's, counted from this machine even with no key.
sandbox()
claude_code_session("or", [("anthropic/claude-sonnet-4.5", 70), ("claude-sonnet-4-5", 40)])
record = openrouter()
expect("OpenRouter counts no Claude Code reply while Claude Code is sent to Anthropic", [record["todayTokensByModel"], record["ready"]], [{}, False], record)
claude_code_session("or", [("anthropic/claude-sonnet-4.5", 70), ("claude-sonnet-4-5", 40)], base_url="https://openrouter.ai/api")
record = openrouter()
expect("OpenRouter counts every Claude Code reply while Claude Code is pointed at it",
       [record["todayTokensByModel"], record["todayPrompts"], record["usageStatusText"]], [{"claude-sonnet-4.5": 70, "claude-sonnet-4-5": 40}, 2, "Waiting for auth"], record)

# OpenRouter usage that other harnesses keep: DeepSeek Harness's pi-ai
# `openrouter` route (its DeepSeek routes are DeepSeek's), a Kimchi session
# run with `--provider openrouter` (its gateway routes are Kimchi's), and a
# MiniMax Code custom provider at openrouter.ai (one elsewhere isn't).
sandbox()
os.environ["DSH_HOME"] = str(home() / "dsh")
dsh_log = home() / "dsh" / "sessions" / "--home-me--" / "s1" / "session.v4.jsonl"
dsh_log.parent.mkdir(parents=True)
dsh_log.write_text("".join(json.dumps(line) + "\n" for line in (
  {"type": "session", "version": 4, "id": "s1", "createdAt": ms_in(0), "isSeeded": False},
  {"type": "user/message", "seq": 0, "time": ms_in(0), "data": {"source": {"kind": "user"}, "role": "user", "id": "u1"}},
  {"type": "request/header", "seq": 1, "time": ms_in(0), "data": {"header": {"config": {"provider": "openrouter", "model": "z-ai/glm-mock"}}}},
  {"type": "assistant/message", "seq": 2, "time": ms_in(0), "data": {"turn": 1, "step": 1, "usage": {"inputTokens": 5234, "outputTokens": 55, "cacheReadTokens": 75}}},
  {"type": "request/header", "seq": 3, "time": ms_in(0), "data": {"header": {"config": {"provider": "deepseek-official", "model": "deepseek-flash"}}}},
  {"type": "assistant/message", "seq": 4, "time": ms_in(0), "data": {"turn": 2, "step": 1, "usage": {"inputTokens": 999}}},
)))
write_pi_session(home() / ".config" / "kimchi" / "harness" / "sessions" / "--home-me--" / "k.jsonl", [
  pi_reply("openrouter", id="k1", model="z-ai/glm-or-mock", usage={"input": 5234, "output": 55, "cacheRead": 75, "totalTokens": 5364}),
  pi_reply("kimchi-dev/zai", id="k2", model="glm-mock", usage={"input": 777}),
])
mcode_routed_session("m1", "custom_provider:router", "z-ai/glm-mcode", 2358, base_url="https://openrouter.ai/api/v1")
mcode_routed_session("m2", "custom_provider:acme", "acme", 444, base_url="https://llm.acme.example/v1")
record = openrouter()
expect("OpenRouter counts dsh's openrouter route, Kimchi's --provider openrouter, and MiniMax Code at openrouter.ai, nothing else of theirs",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"]],
       [{"glm-mock": 5364, "glm-or-mock": 5364, "glm-mcode": 2358}, 3, 3], record)
del os.environ["DSH_HOME"]

PY
