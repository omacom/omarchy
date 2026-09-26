#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# Without credentials the collector must still print a full, hidden-by-default
# record: the update runner writes whatever valid JSON appears on stdout.
no_auth=$(HOME="$TEST_HOME" GROK_HOME="$TEST_HOME/missing" "$ROOT/bin/omarchy-agent-usage-grok")

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + .usageStatusText' <<<"$no_auth") == "grok:false:Waiting for auth" ]] ||
  fail "Grok collector prints a valid record without credentials" "$no_auth"
pass "Grok collector prints a valid record without credentials"

result=$(python3 - "$ROOT/bin/omarchy-agent-usage-grok" "$TEST_HOME" <<'PY'
import importlib.machinery
import importlib.util
import json
import os
import sys
import time
from datetime import date
from pathlib import Path

collector_path = Path(sys.argv[1])
home = Path(sys.argv[2]) / "grok"
os.environ["TZ"] = "UTC"
time.tzset()

loader = importlib.machinery.SourceFileLoader("grok_collector", str(collector_path))
spec = importlib.util.spec_from_loader(loader.name, loader)
scanner = importlib.util.module_from_spec(spec)
loader.exec_module(scanner)

session = home / "sessions" / "%2Ftmp" / "01a0aaaa-1111-2222-3333-444444444444"
session.mkdir(parents=True)
subagent = session / "subagents" / "01a0bbbb-1111-2222-3333-555555555555"
subagent.mkdir(parents=True)

(session / "summary.json").write_text(json.dumps({
  "info": {"id": session.name, "cwd": "/tmp"},
  "created_at": "2026-09-18T12:00:00Z",
  "updated_at": "2026-09-18T15:00:00Z",
  "last_active_at": "2026-09-18T15:00:00Z",
  "num_chat_messages": 2,
}))

# Two completed turns share a prompt_id so they count once; a third is unique.
# A nested subagent directory must not be walked.
def turn_line(ts, prompt_id, input_tokens, output_tokens, cached=0):
  return json.dumps({
    "timestamp": ts,
    "method": "_x.ai/session/update",
    "params": {
      "sessionId": session.name,
      "update": {
        "sessionUpdate": "turn_completed",
        "prompt_id": prompt_id,
        "usage": {
          "inputTokens": input_tokens,
          "outputTokens": output_tokens,
          "cachedReadTokens": cached,
          "cacheCreationTokens": 0,
          "primaryModelId": "grok-4.6-build",
          "modelUsage": {
            "grok-4.6-build": {
              "inputTokens": input_tokens,
              "outputTokens": output_tokens,
              "cachedReadTokens": cached,
              "cacheCreationTokens": 0,
            }
          },
        },
      },
    },
  })

# 2026-09-18 12:00 UTC and 15:00 UTC
(session / "updates.jsonl").write_text("\n".join([
  turn_line(1789732800, "prompt-a", 100, 20, 40),
  turn_line(1789743600, "prompt-a", 150, 30, 50),  # retry of the same prompt
  turn_line(1789743600, "prompt-b", 10, 5, 0),
]) + "\n")

(subagent / "updates.jsonl").write_text(turn_line(1789743600, "prompt-sub", 9999, 9999) + "\n")

# Fallback session with usage.json and no updates.jsonl
fallback = home / "sessions" / "%2Fwork" / "01a0cccc-1111-2222-3333-666666666666"
fallback.mkdir(parents=True)
(fallback / "summary.json").write_text(json.dumps({
  "created_at": "2026-09-17T08:00:00Z",
  "last_active_at": "2026-09-17T08:00:00Z",
}))
(fallback / "usage.json").write_text(json.dumps({
  "sessionId": fallback.name,
  "updatedAt": "2026-09-17T08:00:00Z",
  "session": {
    "inputTokens": 80,
    "outputTokens": 8,
    "cachedReadTokens": 20,
    "cacheCreationTokens": 0,
    "primaryModelId": "grok-4.6-build",
    "modelUsage": {
      "grok-4.6-build": {
        "inputTokens": 80,
        "outputTokens": 8,
        "cachedReadTokens": 20,
        "cacheCreationTokens": 0,
      }
    },
  },
  "turns": [
    {
      "endedAt": "2026-09-17T08:00:00Z",
      "inputTokens": 80,
      "outputTokens": 8,
      "cachedReadTokens": 20,
      "cacheCreationTokens": 0,
      "primaryModelId": "grok-4.6-build",
      "modelUsage": {
        "grok-4.6-build": {
          "inputTokens": 80,
          "outputTokens": 8,
          "cachedReadTokens": 20,
          "cacheCreationTokens": 0,
        }
      },
    }
  ],
}))

(home / "auth.json").write_text(json.dumps({
  "https://auth.x.ai::test": {"auth_mode": "oidc", "key": "test-token"}
}))

def get_json(url, token):
  if token != "test-token":
    raise scanner.GrokError("bad token")
  if "billing" in url:
    return {
      "config": {
        "currentPeriod": {
          "type": "USAGE_PERIOD_TYPE_WEEKLY",
          "end": "2026-09-21T22:20:08+00:00",
        },
        "creditUsagePercent": 10.0,
        "productUsage": [
          {"product": "GrokBuild", "usagePercent": 10.0},
          {"product": "Chat", "usagePercent": 80.0},
        ],
        "prepaidBalance": {"val": 0},
      }
    }
  if "user" in url:
    return {"subscriptionTier": "SuperGrokPlus"}
  raise scanner.GrokError("unexpected url")

record = scanner.collect(home=home, today=date(2026, 9, 18), get_json=get_json)
print(json.dumps({
  "id": record["id"],
  "ready": record["ready"],
  "tierLabel": record["tierLabel"],
  "todayPrompts": record["todayPrompts"],
  "todaySessions": record["todaySessions"],
  "todayTotalTokens": record["todayTotalTokens"],
  "totalPrompts": record["totalPrompts"],
  "totalSessions": record["totalSessions"],
  "modelUsage": record["modelUsage"],
  "limits": record["limits"],
  "hasBalance": "balance" in record,
  "friendlyPremium": scanner.friendly_tier("XPremiumPlus"),
  "percentTen": scanner.percent_from_api(10.0),
  "percentFraction": scanner.percent_from_api(0.42),
}))
PY
)

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + .tierLabel' <<<"$result") == "grok:true:SuperGrok Plus" ]] ||
  fail "Grok collector names SuperGrok Plus from subscriptionTier" "$result"
pass "Grok collector names SuperGrok Plus from subscriptionTier"

[[ $(jq -r '.todayPrompts' <<<"$result") == "2" ]] ||
  fail "Grok collector counts each prompt_id once" "$result"
pass "Grok collector counts each prompt_id once"

[[ $(jq -r '.totalSessions' <<<"$result") == "2" ]] ||
  fail "Grok collector skips nested subagent session directories" "$result"
pass "Grok collector skips nested subagent session directories"

[[ $(jq -c '.modelUsage["grok-4.6-build"]' <<<"$result") == '{"inputTokens":240,"outputTokens":43,"cacheReadInputTokens":70,"cacheCreationInputTokens":0}' ]] ||
  fail "Grok collector keeps exclusive token buckets and usage.json fallback" "$result"
pass "Grok collector keeps exclusive token buckets and usage.json fallback"

[[ $(jq -r '.limits[0].percent' <<<"$result") == "0.1" ]] ||
  fail "Grok collector maps creditUsagePercent 10 to a 0.1 weekly meter" "$result"
pass "Grok collector maps creditUsagePercent 10 to a 0.1 weekly meter"

[[ $(jq -r '.limits[1].title' <<<"$result") == "Grok Build" ]] ||
  fail "Grok collector adds a Grok Build slice and ignores chat" "$result"
pass "Grok collector adds a Grok Build slice and ignores chat"

[[ $(jq -r '.hasBalance' <<<"$result") == "false" ]] ||
  fail "Grok collector does not publish a zero prepaid balance" "$result"
pass "Grok collector does not publish a zero prepaid balance"

[[ $(jq -r '.friendlyPremium + ":" + (.percentTen | tostring) + ":" + (.percentFraction | tostring)' <<<"$result") == "X Premium+:0.1:0.42" ]] ||
  fail "Grok collector maps CamelCase tiers and 0-100 vs 0-1 percents" "$result"
pass "Grok collector maps CamelCase tiers and 0-100 vs 0-1 percents"
