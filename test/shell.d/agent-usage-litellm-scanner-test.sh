#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.config/omarchy/agents"

# Without a URL and key the collector must still print a full record. The
# update runner writes whatever valid JSON appears on stdout, and the panel
# hides a record that has no usage.
no_key=$(HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" \
  env -u LITELLM_BASE_URL -u LITELLM_API_KEY -u LITELLM_MASTER_KEY \
  "$ROOT/bin/omarchy-agent-usage-litellm")

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.hasPromptStats | tostring) + ":" + .scope' <<<"$no_key") == "litellm:false:false:account" ]] ||
  fail "LiteLLM collector prints a valid record without credentials" "$no_key"
pass "LiteLLM collector prints a valid record without credentials"

[[ $(jq -r '.authHelpText | contains("LITELLM_BASE_URL")' <<<"$no_key") == "true" ]] ||
  fail "LiteLLM collector tells the user how to configure the proxy" "$no_key"
pass "LiteLLM collector tells the user how to configure the proxy"

result=$(python3 - "$ROOT/bin/omarchy-agent-usage-litellm" <<'PY'
import importlib.machinery
import importlib.util
import json
import os
import sys
import time
from datetime import date
from pathlib import Path

os.environ["TZ"] = "UTC"
time.tzset()
for name in ("LITELLM_BASE_URL", "LITELLM_API_KEY", "LITELLM_MASTER_KEY"):
  os.environ.pop(name, None)

collector_path = str(Path(sys.argv[1]))
loader = importlib.machinery.SourceFileLoader("litellm_collector", collector_path)
spec = importlib.util.spec_from_loader(loader.name, loader)
scanner = importlib.util.module_from_spec(spec)
loader.exec_module(scanner)

payload = {
  "results": [
    {
      "date": "2026-07-31",
      "metrics": {
        "spend": 0.4,
        "prompt_tokens": 100,
        "completion_tokens": 20,
        "cache_read_input_tokens": 40,
        "cache_creation_input_tokens": 10,
        "api_requests": 3,
      },
      "breakdown": {
        "models": {
          "ollama/qwen2.5": {
            "metrics": {
              "prompt_tokens": 100,
              "completion_tokens": 20,
              "cache_read_input_tokens": 40,
              "cache_creation_input_tokens": 10,
            }
          }
        }
      },
    },
    {
      "date": "2026-07-30T00:00:00Z",
      "metrics": {
        "prompt_tokens": 50,
        "completion_tokens": 10,
        "api_requests": 1,
      },
      "breakdown": {
        "models": {
          "gpt-4": {"prompt_tokens": 50, "completion_tokens": 10}
        }
      },
    },
  ],
  "metadata": {"total_spend": 1.25},
}

summary = scanner.summarize_activity(payload, date(2026, 7, 31))
legacy = scanner.summarize_activity({
  "daily_data": [
    {"date": "Jul 31", "api_requests": 4, "total_tokens": 90},
    {"date": "Jul 30", "api_requests": 1, "total_tokens": 10},
    {"date": "Jan 02", "api_requests": 1, "total_tokens": 5},
  ],
  "sum_total_tokens": 105,
}, date(2026, 7, 31))
summary["legacyToday"] = legacy["todayTotalTokens"]
summary["legacyRequests"] = legacy["totalPrompts"]
summary["legacyModels"] = legacy["modelUsage"]
summary["legacyYear"] = scanner.parse_activity_date("Dec 28", date(2026, 1, 5)) == "2025-12-28"
series = scanner.summarize_model_series({
  "results": [
    {
      "model": "ollama/qwen",
      "sum_total_tokens": 90,
      "daily_data": [{"date": "Jul 31", "total_tokens": 70, "api_requests": 2}],
    },
    {"model": "", "sum_total_tokens": 10, "daily_data": []},
    {"model": "quiet", "sum_total_tokens": 0, "daily_data": []},
  ]
}, date(2026, 7, 31))
summary["seriesTotal"] = series["modelUsage"]["ollama/qwen"]["inputTokens"]
summary["seriesSplit"] = series["modelUsage"]["ollama/qwen"]["outputTokens"]
summary["seriesToday"] = series["todayTokensByModel"]["ollama/qwen"]
summary["seriesSkipped"] = list(series["modelUsage"]) == ["ollama/qwen"]
summary["uncached"] = summary["modelUsage"]["ollama/qwen2.5"]["inputTokens"]
summary["cacheRead"] = summary["modelUsage"]["ollama/qwen2.5"]["cacheReadInputTokens"]
summary["flatModel"] = summary["modelUsage"]["gpt-4"]["outputTokens"]

calls = []
RealClient = scanner.LiteLLMClient

class GlobalClient:
  def __init__(self, base_url, api_key):
    calls.append(("init", base_url, api_key))

  def activity(self, start_day, end_day):
    calls.append(("activity", start_day.isoformat(), end_day.isoformat()))
    return payload, "global"

  def key_budget(self):
    return (4.0, 20.0)

class ForbiddenGlobal:
  def __init__(self, base_url, api_key):
    pass

  def activity(self, start_day, end_day):
    raise scanner.LiteLLMError("LiteLLM rejected the API key", 403)

class UserFallback(ForbiddenGlobal):
  def activity(self, start_day, end_day):
    return payload, "user"

  def key_budget(self):
    return None

scanner.LiteLLMClient = GlobalClient
record = scanner.scan({"baseUrl": "http://proxy.example:4000/v1", "apiKey": "sk-test"})
summary["record"] = {
  "id": record["id"],
  "ready": record["ready"],
  "scope": record["scope"],
  "tierLabel": record["tierLabel"],
  "hasPromptStats": record["hasPromptStats"],
  "limits": record["limits"],
  "balance": record["balance"],
  "todayTotalTokens": record["todayTotalTokens"],
}
summary["normalizedBase"] = scanner.normalize_base_url("http://proxy.example:4000/v1")
start = date.fromisoformat(calls[1][1])
end = date.fromisoformat(calls[1][2])
summary["windowDays"] = (end - start).days == 29 and end == date.today()

scanner.LiteLLMClient = UserFallback
user_record = scanner.scan({"baseUrl": "https://proxy.example", "apiKey": "sk-user", "maxBudget": 10})
summary["userTier"] = user_record["tierLabel"]
summary["estimatedBalance"] = user_record["balance"]

class LegacyModelClient:
  def __init__(self, base_url, api_key):
    pass

  def activity(self, start_day, end_day):
    return {"daily_data": [{"date": "Jul 31", "api_requests": 4, "total_tokens": 90}]}, "global"

  def model_series(self, start_day, end_day):
    return {
      "results": [{
        "model": "ollama/qwen",
        "sum_total_tokens": 90,
        "daily_data": [{"date": "Jul 31", "total_tokens": 90}],
      }]
    }

  def key_budget(self):
    return None

scanner.LiteLLMClient = LegacyModelClient
legacy_record = scanner.scan({"baseUrl": "http://proxy.example:4000", "apiKey": "sk-old"})
summary["legacyScanModel"] = legacy_record["modelUsage"]["ollama/qwen"]["inputTokens"]
summary["legacyScanReady"] = legacy_record["ready"] and legacy_record["tierLabel"] == "Proxy"

refused = False
try:
  scanner.normalize_base_url("http://user:secret@proxy.example:4000")
except scanner.LiteLLMError:
  refused = True
summary["refusesCredentialsInUrl"] = refused

# A 401 is the key itself, not a missing admin route, so activity() must not
# fall through to the user endpoint.
class RejectingGet:
  def __init__(self):
    self.paths = []

  def get(self, path, query=None):
    self.paths.append(path)
    raise scanner.LiteLLMError("LiteLLM rejected the API key", 401)

client = RealClient.__new__(RealClient)
rejecting = RejectingGet()
client.get = rejecting.get
try:
  client.activity(date(2026, 7, 1), date(2026, 7, 31))
  summary["authStops"] = False
except scanner.LiteLLMError:
  summary["authStops"] = rejecting.paths == ["/global/activity"]

class FallbackGet:
  def __init__(self):
    self.paths = []

  def get(self, path, query=None):
    self.paths.append(path)
    if path == "/global/activity":
      raise scanner.LiteLLMError("LiteLLM rejected the API key", 403)
    return payload

client.get = FallbackGet().get
body, scope_name = client.activity(date(2026, 7, 1), date(2026, 7, 31))
summary["fallsBack"] = scope_name == "user" and body["metadata"]["total_spend"] == 1.25
print(json.dumps(summary, separators=(",", ":")))
PY
)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "120" ]] ||
  fail "LiteLLM collector totals today's uncached, cache, and output tokens once" "$result"
pass "LiteLLM collector totals today's uncached, cache, and output tokens once"

[[ $(jq -r '.uncached' <<<"$result") == "50" ]] ||
  fail "LiteLLM collector splits cache tokens out of prompt tokens" "$result"
pass "LiteLLM collector splits cache tokens out of prompt tokens"

[[ $(jq -r '.cacheRead' <<<"$result") == "40" ]] ||
  fail "LiteLLM collector keeps cache reads on their own counter" "$result"
pass "LiteLLM collector keeps cache reads on their own counter"

[[ $(jq -r '.flatModel' <<<"$result") == "10" ]] ||
  fail "LiteLLM collector accepts model rows that are not nested under metrics" "$result"
pass "LiteLLM collector accepts model rows that are not nested under metrics"

[[ $(jq -r '.recentDays[-1].messageCount' <<<"$result") == "120" ]] ||
  fail "LiteLLM collector builds the seven-day token series" "$result"
pass "LiteLLM collector builds the seven-day token series"

[[ $(jq -r '.totalPrompts' <<<"$result") == "4" ]] ||
  fail "LiteLLM collector counts logged API requests" "$result"
pass "LiteLLM collector counts logged API requests"

[[ $(jq -r '.windowSpend' <<<"$result") == "1.25" ]] ||
  fail "LiteLLM collector prefers the metadata spend total" "$result"
pass "LiteLLM collector prefers the metadata spend total"

[[ $(jq -c '.record | {id, ready, scope, tierLabel, hasPromptStats, limits}' <<<"$result") == '{"id":"litellm","ready":true,"scope":"account","tierLabel":"Proxy","hasPromptStats":false,"limits":[]}' ]] ||
  fail "LiteLLM collector prints the display-ready record contract" "$result"
pass "LiteLLM collector prints the display-ready record contract"

[[ $(jq -c '.record.balance' <<<"$result") == '{"remaining":16.0,"funded":20.0,"spent":4.0,"currency":"USD","estimated":false}' ]] ||
  fail "LiteLLM collector uses the key budget when the proxy reports one" "$result"
pass "LiteLLM collector uses the key budget when the proxy reports one"

[[ $(jq -r '.normalizedBase' <<<"$result") == "http://proxy.example:4000" ]] ||
  fail "LiteLLM collector strips a trailing /v1 from the proxy URL" "$result"
pass "LiteLLM collector strips a trailing /v1 from the proxy URL"

[[ $(jq -r '.windowDays' <<<"$result") == "true" ]] ||
  fail "LiteLLM collector asks for the last 30 days" "$result"
pass "LiteLLM collector asks for the last 30 days"

[[ $(jq -r '.userTier' <<<"$result") == "This key" ]] ||
  fail "LiteLLM collector labels a non-admin key as its own usage" "$result"
pass "LiteLLM collector labels a non-admin key as its own usage"

[[ $(jq -c '.estimatedBalance' <<<"$result") == '{"remaining":8.75,"funded":10.0,"spent":1.25,"currency":"USD","estimated":true}' ]] ||
  fail "LiteLLM collector estimates a balance from the configured budget" "$result"
pass "LiteLLM collector estimates a balance from the configured budget"

[[ $(jq -r '.refusesCredentialsInUrl' <<<"$result") == "true" ]] ||
  fail "LiteLLM collector refuses a base URL that embeds a password" "$result"
pass "LiteLLM collector refuses a base URL that embeds a password"

[[ $(jq -r '.authStops' <<<"$result") == "true" ]] ||
  fail "LiteLLM collector does not fall back when the key itself is rejected" "$result"
pass "LiteLLM collector does not fall back when the key itself is rejected"

[[ $(jq -r '.fallsBack' <<<"$result") == "true" ]] ||
  fail "LiteLLM collector falls back to the user activity route" "$result"
pass "LiteLLM collector falls back to the user activity route"

[[ $(jq -r '.legacyToday' <<<"$result") == "90" && $(jq -r '.legacyRequests' <<<"$result") == "6" && $(jq -r '.legacyYear' <<<"$result") == "true" && $(jq -c '.legacyModels' <<<"$result") == "{}" ]] ||
  fail "LiteLLM collector reads the older global activity day series" "$result"
pass "LiteLLM collector reads the older global activity day series"

[[ $(jq -r '.seriesTotal' <<<"$result") == "90" && $(jq -r '.seriesSplit' <<<"$result") == "0" && $(jq -r '.seriesToday' <<<"$result") == "70" && $(jq -r '.seriesSkipped' <<<"$result") == "true" ]] ||
  fail "LiteLLM collector reads per-model totals from the model activity route" "$result"
pass "LiteLLM collector reads per-model totals from the model activity route"

[[ $(jq -r '.legacyScanModel' <<<"$result") == "90" && $(jq -r '.legacyScanReady' <<<"$result") == "true" ]] ||
  fail "LiteLLM collector attaches model rows when the day series has none" "$result"
pass "LiteLLM collector attaches model rows when the day series has none"
