#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export OMARCHY_PATH="$ROOT"
export XDG_STATE_HOME="$test_tmp/state"
export XDG_CACHE_HOME="$test_tmp/cache"
export PATH="$test_tmp/bin:$PATH"

mkdir -p "$HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$test_tmp/bin"

# Mock secret-tool to serve credentials from a file in test_tmp
cat >"$test_tmp/bin/secret-tool" <<'EOF'
#!/bin/bash
if [[ $1 == "lookup" && $2 == "service" && $3 == "gemini" && $4 == "username" && $5 == "antigravity" ]]; then
  if [[ -f $SECRET_FILE ]]; then
    cat "$SECRET_FILE"
  else
    exit 1
  fi
else
  exit 1
fi
EOF
chmod +x "$test_tmp/bin/secret-tool"

export SECRET_FILE="$test_tmp/secret.json"

collect() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-agy" python3 - "$@" <<'PY'
import importlib.machinery, importlib.util, io, json, os, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

tier = os.environ.get("MOCK_TIER", "Gemini Code Assist")
tier_id = os.environ.get("MOCK_TIER_ID", "standard-tier")
limits_json = os.environ.get("MOCK_LIMITS_JSON", "[]")

def urlopen(request, timeout=None):
  assert str(request.get_header("User-agent", "")).startswith("antigravity/")
  if request.full_url == collector.RETRIEVE_USER_QUOTA_SUMMARY_URL:
    quota_raw = os.environ.get("MOCK_QUOTA_JSON")
    if not quota_raw:
      raise collector.urllib.error.HTTPError(request.full_url, 403, "Subscription required", {}, None)
    return io.BytesIO(quota_raw.encode())
  assert request.full_url == collector.LOAD_CODE_ASSIST_URL
  token = request.get_header("Authorization").split(" ", 1)[1]
  paid_tier_json = os.environ.get("MOCK_PAID_TIER_JSON")
  resp = {
    "allowedTiers": [
      {"name": tier, "id": tier_id}
    ],
    "limits": json.loads(limits_json)
  }
  if paid_tier_json:
    resp["paidTier"] = json.loads(paid_tier_json)
  return io.BytesIO(json.dumps(resp).encode())

collector.urllib.request.urlopen = urlopen
sys.argv = ["omarchy-agent-usage-agy"] + (os.environ.get("COLLECT_ARGS") or "--force").split()
collector.main()
PY
}

# 1. Unauthenticated machine returns ready: false, tierLabel: "", limits: []
rm -f "$SECRET_FILE"
record=$(collect)
[[ $(jq -c '{ready, tierLabel, limits}' <<<"$record") == '{"ready":false,"tierLabel":"","limits":[]}' ]] ||
  fail "an unauthenticated machine returns ready:false and empty tier/limits" "$record"
[[ $(jq -r '.usageStatusText' <<<"$record") == "Waiting for auth" ]] ||
  fail "an unauthenticated machine reports Waiting for auth" "$record"
[[ $(jq -r '.authHelpText' <<<"$record") == "Start agy to sign in." ]] ||
  fail "an unauthenticated machine provides auth help text" "$record"
pass "an unauthenticated machine returns ready:false and empty tier/limits"

# 2. Mocked secret credentials + mocked HTTP loadCodeAssist returns ready: true and tierLabel
future=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=6)).isoformat())')
past=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=1)).isoformat())')

cat >"$SECRET_FILE" <<EOF
{"token":{"access_token":"mock-token-xyz","expiry":"$future","token_type":"Bearer"}}
EOF
export MOCK_TIER="Gemini Code Assist"
record=$(collect)
[[ $(jq -c '{ready, tierLabel, limits}' <<<"$record") == '{"ready":true,"tierLabel":"Google AI Pro","limits":[]}' ]] ||
  fail "mocked secret credentials and HTTP returns ready:true and tierLabel" "$record"
[[ $(jq -r '.usageStatusText' <<<"$record") == "" ]] ||
  fail "successful auth clears usageStatusText" "$record"
[[ $(jq -r '.authHelpText' <<<"$record") == "" ]] ||
  fail "successful auth clears authHelpText" "$record"
pass "mocked secret credentials and HTTP returns ready:true and tierLabel"

# Limits returned from loadCodeAssist normalize percentages and reset times
export MOCK_LIMITS_JSON='[{"label":"Session","percentage":25,"resetsAt":"2026-10-14T12:00:00Z"},{"label":"Weekly","percent":0.5,"resetTime":"2026-10-20T12:00:00Z"}]'
record=$(collect)
[[ $(jq -c '.limits' <<<"$record") == '[{"label":"Session","percent":0.25,"resetsAt":"2026-10-14T12:00:00+00:00"},{"label":"Weekly","percent":0.5,"resetsAt":"2026-10-20T12:00:00+00:00"}]' ]] ||
  fail "limits from loadCodeAssist normalize percentages and reset times" "$record"
pass "limits from loadCodeAssist normalize percentages and reset times"
export MOCK_LIMITS_JSON="[]"

# Limits returned from retrieveUserQuotaSummary calculate utilization and format session/weekly windows
export MOCK_QUOTA_JSON='{"groups":[{"displayName":"Gemini Models","buckets":[{"bucketId":"gemini-5h","displayName":"Five Hour Limit Remaining","window":"5h","resetTime":"2026-10-14T18:00:00Z","remainingFraction":0.8},{"bucketId":"gemini-weekly","displayName":"Weekly Limit Remaining","window":"weekly","resetTime":"2026-10-17T12:00:00Z","remainingFraction":0.4}]},{"displayName":"Claude and GPT models","buckets":[{"bucketId":"3p-5h","displayName":"Five Hour Limit Remaining","window":"5h","resetTime":"2026-10-14T19:00:00Z","remainingFraction":1.0}]}]}'
record=$(collect)
[[ $(jq -r '.limits[0].label' <<<"$record") == "Session (5-hour)" ]] ||
  fail "first limit is Session (5-hour)" "$record"
[[ $(jq -r '.limits[0].title' <<<"$record") == "Session" ]] ||
  fail "first limit title is Session" "$record"
[[ $(jq -r '.limits[0].percent' <<<"$record") == "0.2" ]] ||
  fail "Session utilization is 1.0 - remainingFraction (0.2)" "$record"
[[ $(jq -r '.limits[1].label' <<<"$record") == "Weekly (7-day)" ]] ||
  fail "second limit is Weekly (7-day)" "$record"
[[ $(jq -r '.limits[1].percent' <<<"$record") == "0.6" ]] ||
  fail "Weekly utilization is 1.0 - remainingFraction (0.6)" "$record"
[[ $(jq -r '.limits[2].title' <<<"$record") == "Claude/GPT Session" ]] ||
  fail "third limit is Claude/GPT Session" "$record"
[[ $(jq -r '.limits[2].percent == 0' <<<"$record") == "true" ]] ||
  fail "Claude/GPT percent is 0" "$record"
pass "limits from retrieveUserQuotaSummary calculate utilization and format session/weekly windows"
unset MOCK_QUOTA_JSON

# Expired token reports Waiting for auth
cat >"$SECRET_FILE" <<EOF
{"token":{"access_token":"mock-token-xyz","expiry":"$past","token_type":"Bearer"}}
EOF
record=$(collect)
[[ $(jq -c '{ready, usageStatusText}' <<<"$record") == '{"ready":false,"usageStatusText":"Waiting for auth"}' ]] ||
  fail "an expired token reports ready:false and Waiting for auth" "$record"
pass "an expired token reports ready:false and Waiting for auth"

# Restore valid token
cat >"$SECRET_FILE" <<EOF
{"token":{"access_token":"mock-token-xyz","expiry":"$future","token_type":"Bearer"}}
EOF

# 3. Synthetic history.jsonl and transcript.jsonl correctly calculate daily tokens, prompt counts, and model breakdowns
agy_dir="$HOME/.gemini/antigravity-cli"
mkdir -p "$agy_dir/brain/session-1/.system_generated/logs"
mkdir -p "$agy_dir/brain/session-2/.system_generated/logs"

now_ms=$(python3 -c 'import time; print(int(time.time() * 1000))')
yesterday_ms=$(python3 -c 'import time; print(int((time.time() - 86400) * 1000))')

cat >"$agy_dir/history.jsonl" <<EOF
{"display":"prompt 1","timestamp":$now_ms,"conversationId":"session-1"}
{"display":"prompt 2","timestamp":$now_ms,"conversationId":"session-1"}
{"display":"prompt 3","timestamp":$now_ms,"conversationId":"session-2"}
{"display":"prompt old","timestamp":$yesterday_ms,"conversationId":"session-old"}
EOF

now_iso=$(python3 -c 'import datetime as dt; print(dt.datetime.now(dt.timezone.utc).isoformat())')
yesterday_iso=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=1)).isoformat())')

cat >"$agy_dir/brain/session-1/.system_generated/logs/transcript.jsonl" <<EOF
{"created_at":"$now_iso","model":"Gemini 3.8 Flash (Thinking)","input_tokens":1000,"output_tokens":100,"cache_read_tokens":500}
{"created_at":"$now_iso","model":"Gemini 3.8 Pro","input_tokens":2000,"output_tokens":200,"cache_read_tokens":0}
EOF

cat >"$agy_dir/brain/session-2/.system_generated/logs/transcript.jsonl" <<EOF
{"created_at":"$yesterday_iso","model":"gemini-3.8-flash","input_tokens":500,"output_tokens":50,"cache_read_tokens":0}
EOF

record=$(collect)
[[ $(jq -c '{hasLocalStats, todayPrompts, todaySessions, totalPrompts, totalSessions, activeDays, todayTotalTokens}' <<<"$record") == \
   '{"hasLocalStats":true,"todayPrompts":3,"todaySessions":2,"totalPrompts":4,"totalSessions":3,"activeDays":2,"todayTotalTokens":3800}' ]] ||
  fail "calculates daily tokens and prompt/session counts correctly" "$record"

[[ $(jq -c '.todayTokensByModel' <<<"$record") == '{"gemini-3.8-flash":1600,"gemini-3.8-pro":2200}' ]] ||
  fail "breaks down today tokens by model" "$record"

[[ $(jq -cS '.modelUsage' <<<"$record") == \
   '{"gemini-3.8-flash":{"cacheCreationInputTokens":0,"cacheReadInputTokens":500,"inputTokens":1500,"outputTokens":150},"gemini-3.8-pro":{"cacheCreationInputTokens":0,"cacheReadInputTokens":0,"inputTokens":2000,"outputTokens":200}}' ]] ||
  fail "breaks down all-time token usage by model" "$record"

(( $(jq -r '.recentDays[6].messageCount' <<<"$record") == 3800 )) ||
  fail "recentDays records today token count" "$record"
(( $(jq -r '.recentDays[5].messageCount' <<<"$record") == 550 )) ||
  fail "recentDays records yesterday token count" "$record"
pass "synthetic history.jsonl and transcript.jsonl correctly calculate daily tokens, prompt counts, and model breakdowns"

# 4. Cached stats are reused on subsequent runs until --force
printf '{"display":"prompt new","timestamp":%s,"conversationId":"session-new"}\n' "$now_ms" >>"$agy_dir/history.jsonl"

# With --limits-only, cached stats are reused despite file modifications
record=$(COLLECT_ARGS="--limits-only" collect)
(( $(jq -r '.totalPrompts' <<<"$record") == 4 )) ||
  fail "a limits-only refresh reuses the session scan" "$record"
pass "a limits-only refresh reuses the session scan"

# With --force, cache is bypassed and fresh scan runs
record=$(COLLECT_ARGS="--force" collect)
(( $(jq -r '.totalPrompts' <<<"$record") == 5 )) ||
  fail "force refresh bypasses cached stats" "$record"
pass "force refresh bypasses cached stats"

# A scan from another day is invalidated and re-scanned
stats_cache="$XDG_CACHE_HOME/omarchy/agent-usage/agy-stats.json"
jq '.day = "2000-01-01"' "$stats_cache" >"$test_tmp/stats.json"
mv "$test_tmp/stats.json" "$stats_cache"
printf '{"display":"prompt another","timestamp":%s,"conversationId":"session-another"}\n' "$now_ms" >>"$agy_dir/history.jsonl"
record=$(COLLECT_ARGS="--limits-only" collect)
(( $(jq -r '.totalPrompts' <<<"$record") == 6 )) ||
  fail "a scan from another day is invalidated and made again" "$record"
pass "a scan from another day is invalidated and made again"

# 5. Transcript-only fallback extracts session IDs from brain directory correctly
rm -f "$agy_dir/history.jsonl" "$XDG_CACHE_HOME/omarchy/agent-usage/agy-stats.json"
mkdir -p "$agy_dir/brain/session-3/.system_generated/logs"
cat >"$agy_dir/brain/session-3/.system_generated/logs/transcript.jsonl" <<EOF
{"created_at":"$now_iso","content":"Model Selection\` to Gemini 3.8 Flash. No need to reload","input_tokens":100,"output_tokens":10,"cache_read_tokens":0}
EOF

record=$(COLLECT_ARGS="--force" collect)
(( $(jq -r '.todaySessions' <<<"$record") == 2 )) ||
  fail "extracts session ID from brain path and not .system_generated" "$record"
pass "extracts session ID from brain path and not .system_generated"

# 6. Internal collector helpers (canonical_model_id, normalize_tier_label, parse_timestamp, find_transcript_files)
COLLECTOR="$ROOT/bin/omarchy-agent-usage-agy" python3 - <<'PY' || fail "collector internal helpers adhere to domain invariants"
import importlib.machinery, importlib.util, os, tempfile, time
from datetime import datetime, timedelta, timezone
from pathlib import Path

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

# canonical_model_id maps display names to canonical IDs
assert collector.canonical_model_id("Gemini 3.8 Flash") == "gemini-3.8-flash"
assert collector.canonical_model_id("Gemini 3.8 Pro") == "gemini-3.8-pro"
assert collector.canonical_model_id("Gemini 3.8 Flash (Thinking)") == "gemini-3.8-flash"
assert collector.canonical_model_id("gemini-3.8-flash") == "gemini-3.8-flash"
assert collector.canonical_model_id(None) == "gemini-3.8-flash"

# normalize_tier_label maps service tiers correctly
assert collector.normalize_tier_label("standard-tier", "Gemini Code Assist") == "Google AI Pro"
assert collector.normalize_tier_label("g1-pro-tier", "Google AI Pro") == "Google AI Pro"
assert collector.normalize_tier_label("g1-ultra-tier", "Google AI Ultra") == "Google AI Ultra"
assert collector.normalize_tier_label("ultra-tier", "Google AI Ultra") == "Google AI Ultra"
assert collector.normalize_tier_label("free-tier", "Free") == "Free"
assert collector.normalize_tier_label("", "Custom Tier") == "Custom Tier"

# parse_timestamp parses various timestamp formats
assert collector.parse_timestamp(None) is None
ts_sec = 1700000000.0
assert collector.parse_timestamp(ts_sec) == datetime.fromtimestamp(ts_sec, tz=timezone.utc).astimezone()
ts_ms = 1700000000000
assert collector.parse_timestamp(ts_ms) == datetime.fromtimestamp(ts_ms / 1000.0, tz=timezone.utc).astimezone()
assert collector.parse_timestamp("1700000000000") == datetime.fromtimestamp(ts_ms / 1000.0, tz=timezone.utc).astimezone()
iso = "2026-10-14T12:00:00Z"
assert collector.parse_timestamp(iso) == datetime.fromisoformat("2026-10-14T12:00:00+00:00")

# find_transcript_files filters by since_dt cutoff
with tempfile.TemporaryDirectory() as tmp:
  p1 = Path(tmp) / "brain" / "s1" / ".system_generated" / "logs" / "transcript.jsonl"
  p2 = Path(tmp) / "brain" / "s2" / ".system_generated" / "logs" / "transcript.jsonl"
  p1.parent.mkdir(parents=True, exist_ok=True)
  p2.parent.mkdir(parents=True, exist_ok=True)
  p1.write_text("{}")
  p2.write_text("{}")

  now = time.time()
  os.utime(p1, (now - 100, now - 100))
  os.utime(p2, (now - 10000, now - 10000))

  cutoff = datetime.now(timezone.utc) - timedelta(seconds=500)
  recent = collector.find_transcript_files(tmp, since_dt=cutoff)
  assert str(p1) in recent
  assert str(p2) not in recent

  all_files = collector.find_transcript_files(tmp)
  assert str(p1) in all_files and str(p2) in all_files
PY
pass "collector internal helpers adhere to domain invariants"

# 7. get_antigravity_version and user_agent discover CLI version and fall back gracefully
cat >"$test_tmp/bin/agy" <<'EOF'
#!/bin/bash
if [[ $1 == "--version" ]]; then
  echo "2.1.0"
  exit 0
fi
exit 1
EOF
chmod +x "$test_tmp/bin/agy"

COLLECTOR="$ROOT/bin/omarchy-agent-usage-agy" python3 - <<'PY' || fail "get_antigravity_version and user_agent work with fallbacks"
import importlib.machinery, importlib.util, os
loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

# Successful execution of stubbed agy --version
collector._DETECTED_VERSION = None
assert collector.get_antigravity_version() == "2.1.0"
assert collector.user_agent() == "antigravity/2.1.0"

# Fallback when command is not found in PATH
collector._DETECTED_VERSION = None
os.environ["PATH"] = ""
assert collector.get_antigravity_version() == collector.DEFAULT_FALLBACK_VERSION
assert collector.user_agent() == f"antigravity/{collector.DEFAULT_FALLBACK_VERSION}"
PY
pass "get_antigravity_version and user_agent work with fallbacks"
rm -f "$test_tmp/bin/agy"

# 8. paidTier takes precedence over currentTier and allowedTiers
export MOCK_PAID_TIER_JSON='{"id":"g1-pro-tier","name":"Google AI Pro"}'
export MOCK_TIER_ID="free-tier"
export MOCK_TIER="Free"
record=$(collect)
[[ $(jq -r '.tierLabel' <<<"$record") == "Google AI Pro" ]] ||
  fail "paidTier takes precedence over free currentTier" "$record"
pass "paidTier takes precedence over free currentTier"
unset MOCK_PAID_TIER_JSON

