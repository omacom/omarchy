#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

timestamp="$(date +%Y-%m-%d)T12:00:00Z"

# ---------------------------------------------------------------- pi and omp

PI_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$PI_HOME"' EXIT
mkdir -p "$PI_HOME/.pi/agent/sessions/project" "$PI_HOME/.omp/agent/sessions/project"

cat >"$PI_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"pi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"deepseek","model":"deepseek-pi","usage":{"input":10,"output":4,"cacheRead":3,"cacheWrite":2,"totalTokens":19}}}
{"type":"message","id":"pi-2","timestamp":"$timestamp","message":{"role":"assistant","provider":"anthropic","model":"claude-test","usage":{"input":999,"output":999}}}
{"type":"message","id":"pi-3","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","model":"gpt-test","usage":{"input":999,"output":999}}}
EOF
cat >"$PI_HOME/.omp/agent/sessions/project/omp.jsonl" <<EOF
{ "type": "message", "id": "omp-1", "timestamp": "$timestamp", "message": { "role": "assistant", "provider": "deepseek", "model": "deepseek-omp", "usage": { "input": 20, "output": 5, "cacheRead": 4, "cacheWrite": 1, "totalTokens": 30 } } }
EOF

result=$(HOME="$PI_HOME" XDG_DATA_HOME="$PI_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-deepseek" 2>/dev/null)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "49" ]] ||
  fail "DeepSeek collector counts usage from pi and omp sessions" "$result"
pass "DeepSeek collector counts usage from pi and omp sessions"

[[ $(jq -c '.modelUsage' <<<"$result") == '{"deepseek-pi":{"inputTokens":10,"outputTokens":4,"cacheReadInputTokens":3,"cacheCreationInputTokens":2},"deepseek-omp":{"inputTokens":20,"outputTokens":5,"cacheReadInputTokens":4,"cacheCreationInputTokens":1}}' ]] ||
  fail "DeepSeek collector filters pi and omp sessions to DeepSeek providers" "$result"
pass "DeepSeek collector filters pi and omp sessions to DeepSeek providers"

[[ $(jq -r '"\(.todayPrompts):\(.todaySessions)"' <<<"$result") == "2:2" ]] ||
  fail "DeepSeek collector counts each message once per session" "$result"
pass "DeepSeek collector counts each message once per session"

# Without a key the record must still be complete and hidden-by-default:
# the panel shows local stats and simply omits the balance section.
[[ $(jq -r '.id + ":" + (.ready|tostring) + ":" + (.hasPromptStats|tostring) + ":" + (has("balance")|tostring)' <<<"$result") == "deepseek:true:true:false" ]] ||
  fail "DeepSeek collector prints a valid record without a key" "$result"
pass "DeepSeek collector prints a valid record without a key"

# ---------------------------------------------------------------- opencode

OPENCODE_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$PI_HOME" "$OPENCODE_HOME"' EXIT

python3 - "$OPENCODE_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
now_ms = int(time.time() * 1000)

def message(id, provider, model, input=0, output=0, reasoning=0, read=0, write=0):
  return (id, "ses_1", now_ms, now_ms, json.dumps({
    "role": "assistant",
    "providerID": provider,
    "modelID": model,
    "tokens": {"input": input, "output": output, "reasoning": reasoning, "cache": {"read": read, "write": write}},
    "time": {"created": now_ms},
  }))

conn.executemany(
  "INSERT INTO message VALUES (?, ?, ?, ?, ?)",
  [
    message("m-1", "deepseek", "deepseek-model", input=100, output=20, reasoning=5, read=30, write=2),
    message("m-2", "openai", "gpt-model", input=999, output=999),
    message("m-3", "anthropic", "claude-model", input=999, output=999),
  ],
)
conn.commit()
conn.close()
PY

result=$(HOME="$OPENCODE_HOME" XDG_DATA_HOME="$OPENCODE_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-deepseek" 2>/dev/null)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "157" ]] ||
  fail "DeepSeek collector counts opencode messages on a DeepSeek provider" "$result"
pass "DeepSeek collector counts opencode messages on a DeepSeek provider"

[[ $(jq -c '.modelUsage["deepseek-model"]' <<<"$result") == '{"inputTokens":100,"outputTokens":25,"cacheReadInputTokens":30,"cacheCreationInputTokens":2}' ]] ||
  fail "DeepSeek collector keeps reasoning with output and cache apart in opencode" "$result"
pass "DeepSeek collector keeps reasoning with output and cache apart in opencode"

# ---------------------------------------------------------------- balance

result=$(python3 - "$ROOT/bin/omarchy-agent-usage-deepseek" "$TEST_HOME/.config" <<'PY'
import importlib.machinery
import importlib.util
import json
import os
import sys
from decimal import Decimal
from pathlib import Path

collector_path = str(Path(sys.argv[1]))
os.environ["XDG_CONFIG_HOME"] = sys.argv[2]

loader = importlib.machinery.SourceFileLoader("deepseek_collector", collector_path)
spec = importlib.util.spec_from_loader(loader.name, loader)
scanner = importlib.util.module_from_spec(spec)
loader.exec_module(scanner)
real_fetch_balance = scanner.fetch_balance

config_dir = Path(sys.argv[2]) / "omarchy" / "agents"
config_dir.mkdir(parents=True, exist_ok=True)
(config_dir / "deepseek.json").write_text(json.dumps({"fundedAmount": 20}))

scanner.fetch_balance = lambda base_url, key: {
  "remaining": Decimal("8.15"),
  "granted": Decimal("0"),
  "toppedUp": Decimal("8.15"),
  "currency": "USD",
}
balance = scanner.balance_record("test-key", "https://example.invalid")
summary = {"withConfig": balance}

scanner.fetch_balance = lambda base_url, key: (_ for _ in ()).throw(
  scanner.DeepSeekError("balance endpoint unavailable")
)
import contextlib
import io
with contextlib.redirect_stderr(io.StringIO()):
  summary["onFailure"] = scanner.balance_record("test-key", "https://example.invalid")
scanner.fetch_balance = real_fetch_balance

# The real request must carry the bearer key and hit /user/balance.
captured = {}

class FakeResponse:
  def __init__(self, payload):
    self.payload = payload

  def __enter__(self):
    return self

  def __exit__(self, *args):
    return False

  def read(self):
    return json.dumps({
      "is_available": True,
      "balance_infos": [{
        "currency": "CNY",
        "total_balance": "42.50",
        "granted_balance": "2.50",
        "topped_up_balance": "40.00",
      }],
    }).encode("utf-8")

import urllib.request
real_urlopen = urllib.request.urlopen
urllib.request.urlopen = lambda request, timeout=15: (
  captured.update({"url": request.full_url, "auth": request.get_header("Authorization")})
  or FakeResponse(None)
)
try:
  live = scanner.fetch_balance("https://api.deepseek.com", "key-123")
finally:
  urllib.request.urlopen = real_urlopen

summary["liveShape"] = {
  "remaining": float(live["remaining"]),
  "granted": float(live["granted"]),
  "toppedUp": float(live["toppedUp"]),
  "currency": live["currency"],
}
summary["requestShape"] = {"url": captured.get("url"), "auth": captured.get("auth")}
print(json.dumps(summary, separators=(",", ":")))
PY
)

[[ $(jq -c '.withConfig | {remaining, funded, spent, currency, estimated}' <<<"$result") == '{"remaining":8.15,"funded":20.0,"spent":11.85,"currency":"USD","estimated":true}' ]] ||
  fail "DeepSeek collector derives the estimated ledger from fundedAmount" "$result"
pass "DeepSeek collector derives the estimated ledger from fundedAmount"

[[ $(jq -r '.onFailure' <<<"$result") == "null" ]] ||
  fail "DeepSeek collector omits the balance when the endpoint fails" "$result"
pass "DeepSeek collector omits the balance when the endpoint fails"

[[ $(jq -c '.liveShape' <<<"$result") == '{"remaining":42.5,"granted":2.5,"toppedUp":40.0,"currency":"CNY"}' ]] ||
  fail "DeepSeek collector parses the live balance response" "$result"
pass "DeepSeek collector parses the live balance response"

[[ $(jq -c '.requestShape' <<<"$result") == '{"url":"https://api.deepseek.com/user/balance","auth":"Bearer key-123"}' ]] ||
  fail "DeepSeek collector requests /user/balance with the bearer key" "$result"
pass "DeepSeek collector requests /user/balance with the bearer key"
