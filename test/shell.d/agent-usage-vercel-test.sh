#!/bin/bash

# Catch subscription misdetection, one balance replacing another, forbidden
# reporting hiding valid credits, and remote/local usage counted twice. The
# shared partition test holds the route filters; the scan adapter below holds
# local cache reuse. There are no quota windows for check_limits_contract.
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"
agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

freeze_today()
sandbox()
answer = {"balance": "12.50", "total_used": "1000", "token_pass": {"remaining": "42.25", "resets_at": iso_in(86400)}}
routes = {"/credits": lambda request: answer, "/report?": 403}


def vercel(mode="up", args=("--force",)):
  with FakeHttp(routes, mode=mode) as http:
    record = collect("vercel", *args)
  return record, http


record, http = vercel()
expect("Vercel makes no request on an unused machine", [record["ready"], http.count], [False, 0])
os.environ["AI_GATEWAY_API_KEY"] = "gateway-key"
record, http = vercel()
expect("Vercel discovers the Pass and keeps both independent balances",
       [record["tierLabel"], record["balance"]["remaining"], record["tokenPass"]["remaining"], record["tokenPass"]["resetsAt"], record["usageStatusText"]],
       ["Token Pass", 12.5, 42.25, answer["token_pass"]["resets_at"], ""], record)
check("a reporting refusal doesn't hide valid credits or expire the key", "reports are unavailable" in record["authHelpText"] and record["ready"] and http.count == 2, record)
check("requests use the fixed Gateway origin and the saved key", all(r["url"].startswith("https://ai-gateway.vercel.sh/v1/") and r["headers"].get("authorization") == "Bearer gateway-key" for r in http.requests))
fetched_at = record["limitsFetchedAt"]
for args in ((), ("--limits-only",)):
  reused, http = vercel(500, args)
  expect("a recent balance and report denial are reused " + str(args), [http.count, reused["limitsFetchedAt"], reused["limitsStale"]], [0, fetched_at, False])

for remaining in ("0", None):
  answer["token_pass"]["remaining"] = remaining
  record, _ = vercel()
  expect("zero and unknown credit keep the subscription distinct", [record["tierLabel"], record["tokenPass"]["remaining"]], ["Token Pass", 0 if remaining == "0" else None], record)
answer["token_pass"] = None
answer["balance"] = "-0.01"
record, _ = vercel()
expect("a confirmed absent Pass leaves normal Gateway credits, including settled debt", ["tokenPass" in record, record["tierLabel"], record["balance"]["remaining"]], [False, "", -0.01], record)

answer["token_pass"] = {"remaining": "5", "resets_at": iso_in(86400)}
fresh, _ = vercel()
for mode, retry in ((500, False), ("down", True), ("timeout", True), ("cut", False), ("garbage", False), (401, False)):
  record, _ = vercel(mode)
  expect("failed credits keep both balances per key: " + str(mode),
         [record.get("balance"), record.get("tokenPass"), record["limitsStale"], record["limitsFetchedAt"], bool(record.get("retryAdvised"))],
         [fresh["balance"], fresh["tokenPass"], True, fresh["limitsFetchedAt"], retry], record)
  if mode == 401:
    expect("a refused credits credential asks for sign-in", record["usageStatusText"], "Sign-in expired")

for broken in ({}, {"balance": True, "token_pass": None}, {"balance": "NaN", "token_pass": None}, {"balance": "1e400", "token_pass": None}, {"balance": "2"}, {"balance": "2", "token_pass": {"remaining": -1, "resets_at": iso_in(86400)}}):
  with FakeHttp({"/credits": broken, "/report?": 403}):
    record = collect("vercel", "--force")
  expect("malformed credits don't replace the last good balance " + str(broken), [record["balance"], record["tokenPass"], record["limitsStale"]], [fresh["balance"], fresh["tokenPass"], True])

os.environ["AI_GATEWAY_API_KEY"] = "another-key"
record, _ = vercel("down")
expect("another credential never inherits these balances", ["balance" in record, "tokenPass" in record, record["usageStatusText"]], [False, False, "Balance unavailable"])

# Discovery is read-only and never executes pi's dynamic credential entries.
sandbox()
module = load_collector("vercel")
pi_auth(None, "vercel-ai-gateway", "pi-key")
expect("pi's Gateway login is discovered", module.api_key(), "pi-key")
opencode_auth(None, "vercel", "opencode-key")
expect("OpenCode's Gateway login is discovered", module.api_key(), "opencode-key")
os.environ["AI_GATEWAY_API_KEY"] = "explicit"
expect("an explicit Gateway key wins", module.api_key(), "explicit")
sandbox()
pi_auth(None, "vercel-ai-gateway", "!echo credential")
pi_auth(home() / ".omp/agent", "vercel-ai-gateway", "$DYNAMIC_KEY")
expect("dynamic keys are left to their harness", module.api_key(), "")
write_json(config_home() / "omarchy/agents/vercel.json", {"apiKey": "configured"})
expect("headless collection can use an explicit config", module.api_key(), "configured")

# Reports replace the local rows and retain account scope; requests and
# reasoning tokens must never masquerade as prompts or additional output.
sandbox()
os.environ["AI_GATEWAY_API_KEY"] = "report-key"
write_pi_session(home() / ".pi/agent/sessions/local.jsonl", [pi_reply("vercel-ai-gateway", 999, model="zai/glm-5.3")])
row = {"input_tokens": 100, "output_tokens": 20, "cached_input_tokens": 30, "cache_creation_input_tokens": 10, "reasoning_tokens": 5, "total_cost": 0.5, "request_count": 8}
hour = fixture_now().strftime("%Y-%m-%dT%H")


def reported(request):
  if "group_by=model" in request.full_url:
    return {"results": [dict(row, model="zai/glm-5.3")]}
  return {"results": [dict(row, hour=hour)]}


with FakeHttp({"/credits": answer, "/report?": reported}):
  record = collect("vercel", "--force")
expect("reports replace local usage and split cache tokens without double counting",
       [record["modelUsage"], record["todayTotalTokens"], record["scope"], record["hasLocalStats"], record["hasPromptStats"], record["totalPrompts"], record["spend"]["amount"]],
       [{"zai/glm-5.3": {"inputTokens": 60, "outputTokens": 20, "cacheReadInputTokens": 30, "cacheCreationInputTokens": 10}}, 120, "account", False, False, 0, 0.5], record)
record, _ = vercel(500)
expect("a failed report keeps the last account report instead of adding local data", [record["modelUsage"], record["scope"]], [{"zai/glm-5.3": {"inputTokens": 60, "outputTokens": 20, "cacheReadInputTokens": 30, "cacheCreationInputTokens": 10}}, "account"])
with FakeHttp({"/credits": answer, "/report?": {"results": []}}):
  record = collect("vercel", "--force")
expect("an empty account report is valid and doesn't inherit local work", [record["modelUsage"], record["spend"]["amount"]], [{}, 0])

# The provider's scan cache contract, with reports unavailable and no real
# network. Its sources are held to the same reuse windows as every collector.
sandbox()
count = 0


def grow():
  global count
  count += 1
  write_pi_session(home() / ".pi/agent/sessions" / (str(count) + ".jsonl"), [pi_reply("vercel-ai-gateway", 7, id=str(count), model="zai/glm-5.3")])


check_scan_cache(Adapter(id="vercel", grow=grow, pi_root=lambda: home() / ".pi/agent/sessions"))
PY
