#!/bin/bash

# The Kimchi collector's own sources: the key and region the Kimchi CLI keeps
# in its config, the gateway's credits and budget answers (each kept on its
# own), and the pi-format sessions under its harness. The unused-machine
# record is held centrally by the partition test, the pi reader by the shared
# test, and the limits and scan caches by the contract checks.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

PERIOD = {"startTime": iso_in(-11 * 86400), "endTime": iso_in(20 * 86400)}

# The gateway answers per key: credits for every key, a budget only for some,
# and a refusal for a revoked one.
CREDITS = {
  "key-coder": {"serverless": True, "tier": "coder", "is_paid_tier": True, "remaining": "24.95", "has_credits": True},
  "key-budget": {"serverless": True, "tier": "TEAMS", "remaining": 30, "has_credits": True},
  "key-empty": {"serverless": True, "tier": "free", "remaining": "0", "has_credits": False},
  "key-sprint": {"serverless": True, "tier": "teams", "remaining": 12, "has_credits": True},
  "key-pair": {"serverless": True, "tier": "teams", "remaining": 5, "has_credits": True},
}
BUDGETS = {
  "key-sprint": {"period": {"startTime": iso_in(-7 * 86400), "endTime": iso_in(7 * 86400)}, "budgets": [
    {"scope": "TEAM_POOLED", "scopeId": "t-1", "budgetLimitUsd": "100", "totalSpendUsd": "10", "providerBudgets": [
      {"provider": "openai", "limitType": "CAPPED", "budgetLimitUsd": "20", "usageUsd": "5"},
    ]},
  ]},
  "key-budget": {"period": PERIOD, "budgets": [
    {"scope": "USER", "scopeId": "u-1", "budgetLimitUsd": "50", "totalSpendUsd": "20", "providerBudgets": [
      {"provider": "anthropic", "limitType": "PROVIDER_LIMIT_TYPE_CAPPED", "budgetLimitUsd": "10", "usageUsd": "2.5"},
      {"provider": "openai", "limitType": "UNLIMITED", "usageUsd": "4"},
    ]},
  ]},
  "key-pair": {"period": PERIOD, "budgets": [
    {"scope": "USER", "scopeId": "u-1", "budgetLimitUsd": "50", "totalSpendUsd": "10", "providerBudgets": [
      {"provider": "anthropic", "limitType": "CAPPED", "budgetLimitUsd": "10", "usageUsd": "9"},
    ]},
    {"scope": "TEAM_POOLED", "scopeId": "t-1", "budgetLimitUsd": "200", "totalSpendUsd": "50", "providerBudgets": [
      {"provider": "openai", "limitType": "CAPPED", "budgetLimitUsd": "40", "usageUsd": "4"},
    ]},
  ]},
}
# An endpoint a test breaks on its own: its answer, whatever the key.
broken = {}
DOWN = urllib.error.URLError(OSError("Name or service not known"))


def gateway(resource, answers):
  def answer(request):
    if resource in broken:
      return broken[resource]
    key = request.get_header("Authorization").split(" ", 1)[1]
    if key == "key-revoked":
      return 401
    if key == "key-offline":
      return DOWN
    return answers.get(key, {"period": {"startTime": "", "endTime": ""}, "budgets": []})
  return answer


ROUTES = {"/v1/credits": gateway("credits", CREDITS), "/v1/budget": gateway("budget", BUDGETS)}


# A Kimchi login the way the CLI leaves it.
def signed_in(key="key-budget", region="us"):
  write_json(home() / ".config" / "kimchi" / "config.json", {"apiKey": key, "region": region})


def kimchi(*args, key=None, **env):
  saved = dict(os.environ)
  if key:
    env["KIMCHI_API_KEY"] = key
  os.environ.update(env)
  try:
    with FakeHttp(ROUTES) as http:
      record = collect("kimchi", *(args or ("--force",)))
  finally:
    os.environ.clear()
    os.environ.update(saved)
  kimchi.asked = sorted({request["url"] for request in http.requests})
  return record


def harness():
  return home() / ".config" / "kimchi" / "harness"


def reply(id, model, usage, timestamp="now"):
  return pi_reply("kimchi-dev", model=model, usage=usage, timestamp=timestamp, id=id)


def kept(record):
  return {"stale": record["limitsStale"], "tierLabel": record["tierLabel"], "limits": record["limits"],
          "credits": (record.get("balance") or {}).get("remaining"), "retry": record.get("retryAdvised"), "status": record["usageStatusText"]}


# ------------------------------------------------------------ the gateway

# Without a key the gateway is never asked; the partition test holds the rest
# of the unused-machine record.
sandbox()
record = kimchi()
expect("no key means the gateway is never asked", [record["ready"], kimchi.asked], [False, []], record)

signed_in("key-coder")
record = kimchi()
expect("a Coder plan reports its plan and prepaid credits",
       {key: record.get(key) for key in ("ready", "tierLabel", "limits", "balance", "usageStatusText", "authHelpText")},
       {"ready": True, "tierLabel": "Coder", "limits": [], "balance": {"remaining": 24.95, "funded": 0, "spent": 0, "currency": "USD", "estimated": False},
        "usageStatusText": "", "authHelpText": ""}, record)
expect("the US region asks the US gateway", kimchi.asked, ["https://llm.kimchi.dev/v1/budget", "https://llm.kimchi.dev/v1/credits"])
signed_in("key-coder", "eu")
kimchi()
expect("the EU region asks the EU gateway", kimchi.asked, ["https://llm.eu.kimchi.dev/v1/budget", "https://llm.eu.kimchi.dev/v1/credits"])
signed_in("key-coder", "EU")
kimchi()
expect("a region is matched whatever its case", kimchi.asked, ["https://llm.eu.kimchi.dev/v1/budget", "https://llm.eu.kimchi.dev/v1/credits"])
kimchi(KIMCHI_BASE_URL="https://gateway.example/openai/v1/")
expect("KIMCHI_BASE_URL names the gateway, without its OpenAI path", kimchi.asked, ["https://gateway.example/v1/budget", "https://gateway.example/v1/credits"])

# A gateway override never sends the key in the clear to another machine;
# plain HTTP is for a gateway on this one.
record = kimchi(KIMCHI_BASE_URL="http://gateway.example")
expect("a plain HTTP KIMCHI_BASE_URL is never sent the key", [kimchi.asked, record["usageStatusText"], "HTTPS" in record["authHelpText"]], [[], "Balance unavailable", True], record)
write_json(home() / ".config" / "kimchi" / "config.json", {"apiKey": "key-coder", "llmEndpoint": "http://gateway.example/openai/v1"})
kimchi()
expect("a plain HTTP llmEndpoint is never sent the key", kimchi.asked, [])
kimchi(KIMCHI_BASE_URL="http://127.0.0.1:9")
expect("plain HTTP to loopback still carries the key", kimchi.asked, ["http://127.0.0.1:9/v1/budget", "http://127.0.0.1:9/v1/credits"])

# Kimchi 1.18's self-hosted login saves the region and its host but no
# llmEndpoint, and its gateway is <host>/llm; KIMCHI_SELF_HOSTED_URL moves it.
# Without a host the key goes nowhere, never to the public gateway.
write_json(home() / ".config" / "kimchi" / "config.json", {"apiKey": "key-coder", "region": "self-hosted", "selfHostedUrl": "https://kimchi.example.internal/"})
kimchi()
expect("a self-hosted login asks its own host's gateway", kimchi.asked,
       ["https://kimchi.example.internal/llm/v1/budget", "https://kimchi.example.internal/llm/v1/credits"])
kimchi(KIMCHI_SELF_HOSTED_URL="https://other.example.internal")
expect("KIMCHI_SELF_HOSTED_URL moves a self-hosted gateway", kimchi.asked,
       ["https://other.example.internal/llm/v1/budget", "https://other.example.internal/llm/v1/credits"])
write_json(home() / ".config" / "kimchi" / "config.json", {"apiKey": "key-coder", "region": "self-hosted"})
record = kimchi()
expect("a self-hosted login with no host sends its key nowhere",
       [kimchi.asked, record["usageStatusText"], record.get("retryAdvised")], [[], "Balance unavailable", None], record)
signed_in("key-coder")
kimchi(KIMCHI_REGION="self-hosted", KIMCHI_SELF_HOSTED_URL="https://ci.example.internal")
expect("KIMCHI_REGION picks the self-hosted region over the saved one", kimchi.asked,
       ["https://ci.example.internal/llm/v1/budget", "https://ci.example.internal/llm/v1/credits"])

# ------------------------------------------------------------- contract

sandbox()


def add_session():
  add_session.count = getattr(add_session, "count", 0) + 1
  write_pi_session(harness() / "sessions" / "--grown--" / f"{add_session.count}.jsonl", [reply(f"g-{add_session.count}", "glm-5.3", {"input": 1})])


adapter = Adapter("kimchi", plant=signed_in, answer=ROUTES, requests_per_probe=2, grow=add_session, pi_root=lambda: harness() / "sessions")
fresh = check_limits_contract(adapter)
expect("a monthly spend budget becomes a Monthly limit, and its cap never poses as funding",
       [fresh["tierLabel"], {key: fresh["limits"][0].get(key) for key in ("label", "title", "percent")}, fresh["balance"]],
       ["Teams", {"label": "Budget", "title": "Monthly", "percent": 0.4}, {"remaining": 30.0, "funded": 0, "spent": 0, "currency": "USD", "estimated": False}], fresh)
expect("a capped provider is a scoped allowance on the budget's clock, an uncapped one isn't",
       [{"title": limit["title"], "percent": limit["percent"]} for limit in fresh["limits"][1:]], [{"title": "Anthropic Monthly", "percent": 0.25}], fresh)
expect("the budget resets when its period ends", fresh["limits"][0]["resetsAt"], PERIOD["endTime"], fresh)
check_scan_cache(adapter)

# ------------------------------------------------------------ the answer

sandbox()
signed_in()
record = kimchi(key="key-sprint")
expect("a period with no clock name still shows its capped providers",
       [{"title": limit.get("title"), "percent": limit["percent"]} for limit in record["limits"]],
       [{"title": None, "percent": 0.1}, {"title": "Openai budget", "percent": 0.25}], record)

# Two budgets on one clock: the panel hangs a cap on the meter its title
# names, so each budget is titled by its scope and its caps name the budget
# they belong to, instead of both caps landing on the last Monthly meter.
record = kimchi(key="key-pair")
expect("several budgets on one clock each keep their own provider caps",
       [{"title": limit["title"], "percent": limit["percent"]} for limit in record["limits"]],
       [{"title": "Budget Monthly", "percent": 0.2}, {"title": "Anthropic budget (Budget)", "percent": 0.9},
        {"title": "Team pool Monthly", "percent": 0.25}, {"title": "Openai budget (Team pool)", "percent": 0.1}], record)

record = kimchi(key="key-empty")
expect("an empty balance shows, out of credits, with the rate limiting in the help",
       [record["tierLabel"], record["balance"]["remaining"], record["usageStatusText"], record["authHelpText"]],
       ["Community", 0.0, "Out of credits", "Kimchi's gateway is rate limiting requests until the account has credits again."], record)

record = kimchi(key="key-revoked")
expect("a rejected key says to log in again in Kimchi", "Log in again in Kimchi" in record["authHelpText"], True, record)
record = kimchi(key="key-offline")
expect("an unreachable gateway with nothing kept says the balance is unavailable and asks for a sooner retry",
       [record["usageStatusText"], record.get("retryAdvised")], ["Balance unavailable", True], record)

# Another key never shows the last key's numbers.
kimchi(key="key-budget")
broken.update(credits=DOWN, budget=DOWN)
record = kimchi(key="key-coder")
broken.clear()
expect("another key never shows the last key's numbers", [record["tierLabel"], record["limits"]], ["", []], record)

# One endpoint failing keeps that endpoint's last answer and takes the other's
# fresh one, without letting the half that came back replace the cache.
BUDGET_LIMITS = kimchi(key="key-budget")["limits"]
check("key-budget answers two limits", len(BUDGET_LIMITS) == 2, BUDGET_LIMITS)
broken["budget"] = DOWN
record = kimchi(key="key-budget")
expect("a failed budget endpoint keeps its last limits beside fresh credits", kept(record),
       {"stale": True, "tierLabel": "Teams", "limits": BUDGET_LIMITS, "credits": 30.0, "retry": True, "status": ""}, record)
broken.clear()
broken["credits"] = DOWN
record = kimchi(key="key-budget")
expect("a failed credits endpoint keeps its last plan and balance beside fresh limits", kept(record),
       {"stale": True, "tierLabel": "Teams", "limits": BUDGET_LIMITS, "credits": 30.0, "retry": True, "status": ""}, record)
broken.clear()

# A reply of an unexpected shape is a failed check, not an empty account: the
# last answer stays up, stale, and a server that answered isn't retried sooner.
for odd in ("budget", "credits"):
  for body in ({"message": "ok"}, [], None):
    kimchi(key="key-budget")
    broken[odd] = b"null" if body is None else body
    record = kimchi(key="key-budget")
    broken.clear()
    expect(f"an unexpected {odd} reply ({json.dumps(body)}) keeps the last answer, stale", kept(record),
           {"stale": True, "tierLabel": "Teams", "limits": BUDGET_LIMITS, "credits": 30.0, "retry": None, "status": ""}, record)

# A part that fails before anything was cached is missing, not current: the
# record is stale, but a server that answered with an error isn't retried
# sooner.
for path in limits_cache_files("kimchi"):
  path.unlink()
broken["budget"] = 500
record = kimchi(key="key-sprint")
broken.clear()
expect("a budget endpoint failing with nothing cached leaves the record stale",
       [record["limitsStale"], record["limits"], record["balance"]["remaining"], record.get("retryAdvised"), record["usageStatusText"]], [True, [], 12.0, None, ""], record)
for path in cache_root().glob("kimchi-credits-*.json"):
  path.unlink()
broken["credits"] = 500
record = kimchi(key="key-sprint")
broken.clear()
expect("a credits endpoint failing with nothing cached says credits are unavailable",
       [record["limitsStale"], record.get("balance"), record["usageStatusText"], record.get("retryAdvised")], [True, None, "Balance unavailable", None], record)

# Refreshes can overlap; an answer fetched earlier never replaces one fetched
# later, so a slow run finishing last can't roll the cache back.
kimchi(key="key-budget")
credits_cache = max(cache_root().glob("kimchi-credits-*.json"), key=lambda path: path.stat().st_mtime)
write_json(credits_cache, dict(json.loads(credits_cache.read_text()), fetchedAtMs=ms_in(60), tierLabel="Enterprise"))
kimchi(key="key-budget")
expect("an earlier answer never replaces a later one", json.loads(credits_cache.read_text())["tierLabel"], "Enterprise")
broken.update(credits=DOWN, budget=DOWN)
expect("an outage falls back to the latest answer", kimchi(key="key-budget")["tierLabel"], "Enterprise")

# The same key asked of another gateway is another answer.
record = kimchi(key="key-budget", KIMCHI_BASE_URL="https://gateway.example")
broken.clear()
expect("another gateway never shows the last gateway's numbers",
       [record["tierLabel"], record["limits"], record["usageStatusText"]], ["", [], "Balance unavailable"], record)

# A budget cached under its old name, kimchi-budget-*, is still read, its
# elapsed window zeroed and one with no reset time kept as it is.
for path in cache_root().glob("kimchi-credits-*.json"):
  path.unlink()
kimchi(key="key-budget")
limits_cache = max(limits_cache_files("kimchi"), key=lambda path: path.stat().st_mtime)
cached = json.loads(limits_cache.read_text())
cached["limits"][0].update(resetsAt=iso_in(-3600), percent=0.9)
cached["limits"][1]["resetsAt"] = ""
write_json(limits_cache.with_name(limits_cache.name.replace("kimchi-limits-", "kimchi-budget-")), cached)
limits_cache.unlink()
broken["budget"] = DOWN
record = kimchi(key="key-budget")
broken.clear()
expect("a budget cached under its old name is read, elapsed at zero and an unclocked one as it was",
       [[round(limit["percent"] * 100), limit["resetsAt"]] for limit in record["limits"]] + [record["limitsStale"]], [[0, ""], [25, ""], True], record)

# ---------------------------------------------------------------- sessions

# Tokens come from assistant messages in the harness's pi session files:
# cached input kept apart, a repeated entry counted once, user turns and other
# entries skipped. The one typed prompt today books on its first reply, not
# on each step; a file without user messages keeps one per reply.
sandbox()
sessions = harness() / "sessions" / "--home-me--"
now = iso_in(0)
write_pi_session(sessions / "today.jsonl", [
  {"type": "session", "id": "s-1"},
  {"type": "message", "id": "u-1", "timestamp": now, "message": {"role": "user", "content": "hi", "usage": {"input": 999}}},
  reply("a-1", "minimax-m3", {"input": 100, "output": 20, "cacheRead": 800, "cacheWrite": 5, "totalTokens": 925}),
  reply("a-1", "minimax-m3", {"input": 100, "output": 20, "cacheRead": 800, "cacheWrite": 5, "totalTokens": 925}),
  reply("a-2", "glm-5.3", {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "totalTokens": 75}),
  {"type": "custom", "id": "c-1", "timestamp": now, "data": {"usage": {"input": 999}}},
  {"type": "message", "id": "a-3", "message": {"role": "assistant", "model": "glm-5.3", "timestamp": ms_in(0), "usage": {"input": 10, "output": 5}}},
])
write_pi_session(sessions / "old.jsonl", [reply("b-1", "minimax-m3", {"input": 300, "output": 30, "cacheRead": 0, "cacheWrite": 0}, timestamp="2026-01-02T10:00:00Z")])
record = kimchi(key="key-coder")
expect("Kimchi counts sessions, prompts, and tokens from its session files",
       {key: record[key] for key in ("hasLocalStats", "todayPrompts", "todaySessions", "totalPrompts", "totalSessions", "activeDays", "todayTotalTokens", "todayTokensByModel")}
       | {"today": record["recentDays"][6]["messageCount"]},
       {"hasLocalStats": True, "todayPrompts": 1, "todaySessions": 1, "totalPrompts": 2, "totalSessions": 2, "activeDays": 2,
        "todayTotalTokens": 1015, "todayTokensByModel": {"minimax-m3": 925, "glm-5.3": 90}, "today": 1015}, record)
expect("Kimchi's tokens by model keep cached input apart", record["modelUsage"], {
  "minimax-m3": {"inputTokens": 400, "outputTokens": 50, "cacheReadInputTokens": 800, "cacheCreationInputTokens": 5},
  "glm-5.3": {"inputTokens": 85, "outputTokens": 5, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
}, record)

# Kimchi 1.18 names a reply's route as kimchi-dev/<upstream> on its gateway,
# but `kimchi --provider openrouter` (or a custom provider in models.json)
# runs a session that provider bills, which isn't Kimchi's usage.
write_pi_session(sessions / "routed.jsonl", [
  {"type": "session", "id": "s-3"},
  pi_reply("kimchi-dev/moonshotai", id="r-1", model="kimi-k2.6", usage={"input": 1234, "output": 51, "cacheRead": 71, "totalTokens": 1356}),
  pi_reply("kimchi-experimental", id="r-2", model="glm-5.3", usage={"input": 4, "output": 1}),
  pi_reply("openrouter", id="r-3", model="z-ai/glm-4.6", usage={"input": 5234, "output": 55, "cacheRead": 75, "totalTokens": 5364}),
  pi_reply("kimchi-devious", id="r-4", model="glm-5.3", usage={"input": 999}),
])
record = kimchi(key="key-coder")
expect("Kimchi counts only replies on its own gateway routes",
       [record["todayTotalTokens"], record["todayTokensByModel"]], [1015 + 1356 + 5, {"minimax-m3": 925, "glm-5.3": 95, "kimi-k2.6": 1356}], record)
(sessions / "routed.jsonl").unlink()

# KIMCHI_CODING_AGENT_DIR moves the harness, as it does for the CLI.
write_pi_session(home() / "elsewhere" / "sessions" / "--elsewhere--" / "s.jsonl", [reply("x-1", "kimi-k2.6", {"input": 7, "output": 3})])
record = kimchi(key="key-coder", KIMCHI_CODING_AGENT_DIR=str(home() / "elsewhere"))
expect("KIMCHI_CODING_AGENT_DIR names the harness the sessions are read from",
       [record["totalSessions"], record["todayTokensByModel"]], [1, {"kimi-k2.6": 10}], record)

# Sessions on disk without a key: Kimchi is in use here and waits for a sign-in.
record = kimchi()
expect("local sessions without a key wait for auth",
       {key: record[key] for key in ("ready", "usageStatusText", "authHelpText", "hasLocalStats")},
       {"ready": True, "usageStatusText": "Waiting for auth", "authHelpText": "Start Kimchi and log in, or set KIMCHI_API_KEY.", "hasLocalStats": True}, record)

# ------------------------------------------------- Kimchi's gateway elsewhere

# Kimchi's gateway bills whatever reaches it, through whichever agent: pi and
# omp sessions on its provider ids wherever they live (a models.json
# provider named kimchi, as pi 1.4.0 and omp 18.12.6 write them), harness
# sessions on plain `kimchi`, and the setups `kimchi claudecode`, `kimchi
# codex` and its opencode integration write, which point Claude Code, Codex
# and opencode at llm.kimchi.dev or llm.eu.kimchi.dev. A Claude or kimi-*
# model through the gateway is Kimchi's, not Anthropic's or Kimi's.
sandbox()
STAMP = today_stamp()
NOW_MS = ms_in(0)


def pi_turns(path, provider, model, tokens, omp=False):
  switch = {"type": "model_change", "id": "m0", "parentId": None, "timestamp": STAMP}
  switch.update({"runtime": {"version": "18.12.6"}, "model": f"{provider}/{model}"} if omp else {"provider": provider, "modelId": model})
  user = {"role": "user", "content": [{"type": "text", "text": "Say hi"}], "timestamp": NOW_MS}
  if omp:
    user["attribution"] = "user"
  write_pi_session(path, [
    {"type": "session", "version": 3, "id": path.stem, "timestamp": STAMP, "cwd": "/home/me"},
    switch,
    {"type": "message", "id": f"u-{path.stem}", "parentId": "m0", "timestamp": STAMP, "message": user},
    {"type": "message", "id": f"a-{path.stem}", "parentId": f"u-{path.stem}", "timestamp": STAMP, "message": {
      "role": "assistant", "content": [{"type": "text", "text": "hi"}], "api": "openai-completions", "provider": provider, "model": model,
      "usage": {"input": tokens, "output": 82, "cacheRead": 102, "cacheWrite": 0, "totalTokens": tokens + 184, "cost": {"total": 0}},
      "stopReason": "stop", "timestamp": NOW_MS}},
  ])


pi_turns(home() / ".pi/agent/sessions/--home-me--/pi-kimchi.jsonl", "kimchi", "minimax-m3", 4201)
pi_turns(home() / ".pi/agent/sessions/--home-me--/pi-kimchi-dev.jsonl", "kimchi-dev", "kimi-k2.6", 5201)
pi_turns(home() / ".omp/agent/sessions/-/omp-kimchi.jsonl", "kimchi", "kimi-k2.5", 6201, omp=True)
pi_turns(home() / ".omp/agent/sessions/-/omp-upstream.jsonl", "kimchi-dev/zai", "glm-5.2", 7201, omp=True)
pi_turns(harness() / "sessions/--home-me--/harness-kimchi.jsonl", "kimchi", "glm-5.2", 8201)
# Someone else's gateway that only shares the name is not Kimchi's.
pi_turns(home() / ".pi/agent/sessions/--home-me--/pi-lookalike.jsonl", "kimchi-proxy", "minimax-m3", 999)
# opencode rows as opencode 1.19.3 writes them for the provider Kimchi's
# opencode setup adds.
opencode_db(message=[
  ("msg_u1", "ses_k", json.dumps({"role": "user", "time": {"created": NOW_MS}, "agent": "build", "model": {"providerID": "kimchi", "modelID": "minimax-m3"}})),
  ("msg_a1", "ses_k", json.dumps({"parentID": "msg_u1", "role": "assistant", "mode": "build", "agent": "build", "cost": 0, "modelID": "minimax-m3", "providerID": "kimchi",
                                  "tokens": {"total": 9201, "input": 9201, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
                                  "time": {"created": NOW_MS + 1, "completed": NOW_MS + 2}, "finish": "stop"})),
])
claude_code_session("kc", [("claude-sonnet-4-5", 3000), ("kimi-k2.6", 2387), ("deepseek-v4-flash", 3390)], base_url="https://llm.eu.kimchi.dev/anthropic")
os.environ["CODEX_HOME"] = str(home() / ".codex")
(home() / ".codex").mkdir()
(home() / ".codex/config.toml").write_text('model_provider = "kimchi"\nmodel = "minimax-m3"\n\n[model_providers.kimchi]\nname = "Kimchi Gateway"\nbase_url = "https://llm.kimchi.dev/openai/v1"\nwire_api = "responses"\n')
rollouts = home() / ".codex/sessions" / datetime.now().strftime("%Y/%m/%d")
rollouts.mkdir(parents=True)
(rollouts / "rollout-kimchi.jsonl").write_text("".join(json.dumps(line) + "\n" for line in (
  {"timestamp": STAMP, "type": "session_meta", "payload": {"model_provider": "kimchi"}},
  {"timestamp": STAMP, "type": "turn_context", "payload": {"model": "minimax-m3"}},
  {"timestamp": STAMP, "type": "event_msg", "payload": {"type": "user_message", "message": "go"}},
  {"timestamp": STAMP, "type": "event_msg", "payload": {"type": "token_count", "info": {
    "last_token_usage": {"input_tokens": 1000, "cached_input_tokens": 0, "output_tokens": 10}, "total_token_usage": {"input_tokens": 1000}}}},
)))
record = kimchi()
os.environ.pop("CODEX_HOME")
expect("Kimchi counts its gateway's usage from pi, omp, opencode, Claude Code and Codex",
       {key: record[key] for key in ("todayTotalTokens", "todayPrompts", "todaySessions", "todayTokensByModel")},
       {"todayTotalTokens": 4385 + 5385 + 6385 + 7385 + 8385 + 9201 + 3000 + 2387 + 3390 + 1010, "todayPrompts": 10, "todaySessions": 8,
        "todayTokensByModel": {"minimax-m3": 4385 + 9201 + 1010, "kimi-k2.6": 5385 + 2387, "kimi-k2.5": 6385, "glm-5.2": 7385 + 8385,
                               "claude-sonnet-4-5": 3000, "deepseek-v4-flash": 3390}}, record)
for other in ("claude", "kimi", "deepseek", "zai", "minimax", "local"):
  os.environ["CODEX_HOME"] = str(home() / ".codex")
  counted = collect(other, "--force")
  os.environ.pop("CODEX_HOME")
  expect(f"{other} counts none of Kimchi's gateway usage", [counted.get("todayTotalTokens") or 0, counted.get("todayPrompts") or 0], [0, 0], counted)
PY
