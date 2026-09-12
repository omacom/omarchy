#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

timestamp="$(date +%Y-%m-%d)T12:00:00Z"

# 1. Pi and omp session transcripts for Gemini/Antigravity providers
mkdir -p "$TEST_HOME/.pi/agent/sessions/project" "$TEST_HOME/.omp/agent/sessions/project"

cat >"$TEST_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"pi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"google","model":"google-antigravity/gemini-2.5-pro","usage":{"input":100,"output":50,"cacheRead":25,"cacheWrite":10,"totalTokens":185}}}
EOF

cat >"$TEST_HOME/.omp/agent/sessions/project/omp.jsonl" <<EOF
{"type":"message","id":"omp-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"google-antigravity","model":"gemini-2.5-flash","usage":{"input":200,"output":80,"cacheRead":40,"cacheWrite":20,"totalTokens":340}}}
{"type":"message","id":"other-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"anthropic","model":"claude-3-5-sonnet","usage":{"input":999,"output":999}}}
EOF

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_STATE_HOME="$TEST_HOME/.local/state" \
  "$ROOT/bin/omarchy-agent-usage-gemini")

[[ $(jq -r '.id' <<<"$result") == "gemini" ]] ||
  fail "Gemini collector identifies itself with id gemini" "$result"
pass "Gemini collector identifies itself with id gemini"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "525" ]] ||
  fail "Gemini collector totals today's tokens across pi and omp sessions" "$result"
pass "Gemini collector totals today's tokens across pi and omp sessions"

[[ $(jq -r '.modelUsage["gemini-2.5-pro"].inputTokens' <<<"$result") == "100" && \
   $(jq -r '.modelUsage["gemini-2.5-pro"].outputTokens' <<<"$result") == "50" && \
   $(jq -r '.modelUsage["gemini-2.5-pro"].cacheReadInputTokens' <<<"$result") == "25" && \
   $(jq -r '.modelUsage["gemini-2.5-pro"].cacheCreationInputTokens' <<<"$result") == "10" ]] ||
  fail "Gemini collector strips provider prefixes and records per-model token buckets" "$result"
pass "Gemini collector strips provider prefixes and records per-model token buckets"

# 2. Antigravity CLI history scanning
mkdir -p "$TEST_HOME/.gemini/antigravity-cli"
cat >"$TEST_HOME/.gemini/antigravity-cli/history.jsonl" <<EOF
{"timestamp":"$timestamp","query":"explain quickshell"}
{"timestamp":"$timestamp","role":"assistant","query":"assistant rows must not count as prompts"}
EOF

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_STATE_HOME="$TEST_HOME/.local/state" \
  "$ROOT/bin/omarchy-agent-usage-gemini" --force)

[[ $(jq -r '.totalPrompts' <<<"$result") == "3" ]] ||
  fail "Gemini collector counts prompts from antigravity CLI history, skipping response rows" "$result"
pass "Gemini collector counts prompts from antigravity CLI history, skipping response rows"

# 3. Opencode SQLite database scanning
OPENCODE_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$OPENCODE_HOME"' EXIT
mkdir -p "$OPENCODE_HOME/.local/share/opencode"

python3 - "$OPENCODE_HOME/.local/share/opencode/opencode.db" <<'PY'
import json
import sqlite3
import sys

conn = sqlite3.connect(sys.argv[1])
conn.execute("CREATE TABLE message (session_id TEXT, data TEXT)")

conn.execute(
  "INSERT INTO message VALUES (?, ?)",
  (
    "sess-1",
    json.dumps({
      "role": "assistant",
      "providerID": "google",
      "modelID": "gemini-2.5-flash",
      "tokens": {
        "input": 300,
        "output": 120,
        "reasoning": 30,
        "cache": {"read": 50, "write": 20},
      },
    }),
  ),
)

conn.execute(
  "INSERT INTO message VALUES (?, ?)",
  (
    "sess-2",
    json.dumps({
      "role": "assistant",
      "providerID": "anthropic",
      "modelID": "claude-3-7-sonnet",
      "tokens": {"input": 500, "output": 200},
    }),
  ),
)

conn.commit()
conn.close()
PY

result=$(HOME="$OPENCODE_HOME" XDG_CACHE_HOME="$OPENCODE_HOME/.cache" XDG_DATA_HOME="$OPENCODE_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-gemini" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "520" ]] ||
  fail "Gemini collector counts tokens from opencode database including reasoning" "$result"
pass "Gemini collector counts tokens from opencode database including reasoning"

# 4. Cache behavior with --limits-only and --force
result=$(HOME="$OPENCODE_HOME" XDG_CACHE_HOME="$OPENCODE_HOME/.cache" XDG_DATA_HOME="$OPENCODE_HOME/.local/share" \
  "$ROOT/bin/omarchy-agent-usage-gemini" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "520" ]] ||
  fail "Gemini collector reuses cached scan data on --limits-only" "$result"
pass "Gemini collector reuses cached scan data on --limits-only"

# 5. Plan tier detection
python3 - "$ROOT/bin/omarchy-agent-usage-gemini" <<'PY' || fail "Gemini plan tier parser maps subscription tiers accurately"
import sys
from importlib.machinery import SourceFileLoader

mod = SourceFileLoader("gemini_usage", sys.argv[1]).load_module()
assert mod.plan_label({"paidTier": {"id": "g1-pro-tier", "name": "Google AI Pro"}}) == "Pro"
assert mod.plan_label({"paidTier": {"id": "g1-ultra-tier", "name": "Google AI Ultra"}}) == "Ultra"
assert mod.plan_label({"currentTier": {"id": "standard-tier", "name": "Antigravity"}}) == "Standard"
assert mod.plan_label({"currentTier": {"id": "free-tier", "name": "Antigravity"}}) == "Free"
assert mod.plan_label({}) == "Free"
PY
pass "Gemini plan tier parser maps subscription tiers accurately"

# 6. Quota parsing survives malformed buckets and falls back across endpoints
python3 - "$ROOT/bin/omarchy-agent-usage-gemini" <<'PY' || fail "Gemini quota parser skips malformed buckets and falls back across endpoints"
import json
import sys
import urllib.error
from importlib.machinery import SourceFileLoader

mod = SourceFileLoader("gemini_usage", sys.argv[1]).load_module()

class FakeResponse:
  def __init__(self, payload):
    self._payload = json.dumps(payload).encode("utf-8")
  def read(self):
    return self._payload
  def __enter__(self):
    return self
  def __exit__(self, *args):
    return False

body = {"groups": [{
  "displayName": "Gemini",
  "buckets": [
    {"bucketId": "b-null", "window": "5h", "remainingFraction": None},
    {"bucketId": "b-nan", "window": "5h", "remainingFraction": float("nan")},
    {"bucketId": "b-text", "window": "5h", "remainingFraction": "abc"},
    {"bucketId": "b-week", "window": "week", "remainingFraction": 0.5, "resetTime": "2030-01-01T00:00:00Z"},
  ],
}]}

calls = []
def fake_urlopen(req, timeout=0):
  calls.append(req.full_url)
  return FakeResponse(body)
mod.urllib.request.urlopen = fake_urlopen

result = mod.probe_limits("token")
assert result["ok"] is True, result
assert len(result["limits"]) == 1, result
assert result["limits"][0]["title"] == "Weekly", result
assert abs(result["limits"][0]["percent"] - 0.5) < 1e-9, result
# The canary endpoint is consulted first and succeeds, so production is never hit.
assert calls and all("daily-cloudcode-pa" in url for url in calls), calls

# A transport failure on the canary endpoint falls through to production.
def failing_urlopen(req, timeout=0):
  if "daily-cloudcode-pa" in req.full_url:
    raise urllib.error.URLError("canary down")
  return FakeResponse(body)
mod.urllib.request.urlopen = failing_urlopen

result = mod.probe_limits("token")
assert result["ok"] is True and len(result["limits"]) == 1, result
PY
pass "Gemini quota parser skips malformed buckets and falls back across endpoints"

# 7. Cache preservation, open-ended expiry, and owner-only permissions
python3 - "$ROOT/bin/omarchy-agent-usage-gemini" <<'PY' || fail "Gemini collector preserves cached limits and writes owner-only cache files"
import json
import os
import stat
import sys
import tempfile
import time
from importlib.machinery import SourceFileLoader

mod = SourceFileLoader("gemini_usage", sys.argv[1]).load_module()

os.environ["XDG_CACHE_HOME"] = tempfile.mkdtemp()
good_limits = [{"label": "Session (5-hour)", "title": "Session", "percent": 0.4, "resetsAt": "2030-01-01T00:00:00Z"}]

cache_file = mod.cache_root() / "gemini-limits.json"
mod.write_json(cache_file, {"fetchedAtMs": 1000, "limits": good_limits, "tierLabel": "Pro"})

# write_json must leave the cache owner-only.
assert stat.S_IMODE(cache_file.stat().st_mode) == 0o600, oct(cache_file.stat().st_mode)

# An ok probe with no buckets (error-shaped 200) must not wipe cached limits.
mod.probe_limits = lambda token: {"ok": True, "limits": [], "tierLabel": ""}
result = mod.collect_limits("token", 0, False)
assert result["limits"] == good_limits, result
assert result["tierLabel"] == "Pro", result
assert json.loads(cache_file.read_text())["limits"] == good_limits

# Open-ended entries (no reset time) expire once the cache ages out.
open_ended = {"label": "Open", "title": "Open", "percent": 0.1, "resetsAt": ""}
mod.write_json(cache_file, {"fetchedAtMs": round(time.time() * 1000), "limits": [open_ended], "tierLabel": "Pro"})
assert len(mod.usable_cached_limits(json.loads(cache_file.read_text()))) == 1
stale = {"fetchedAtMs": round((time.time() - 25 * 3600) * 1000), "limits": [open_ended], "tierLabel": "Pro"}
assert mod.usable_cached_limits(stale) == []
PY
pass "Gemini collector preserves cached limits and writes owner-only cache files"

# 8. Security contract: strictly read-only keyring access and a non-truncating lock
if grep -q '"store"' "$ROOT/bin/omarchy-agent-usage-gemini"; then
  fail "collector must never mutate the keyring (secret-tool lookup only)"
fi
pass "collector must never mutate the keyring (secret-tool lookup only)"

if ! grep -q 'open("a") as lock' "$ROOT/bin/omarchy-agent-usage-gemini"; then
  fail "scan lock file must open in append mode so active flock handles survive"
fi
pass "scan lock file must open in append mode so active flock handles survive"
