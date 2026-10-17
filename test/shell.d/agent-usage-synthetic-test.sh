#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3
require_command rg

TEST_HOME=$(mktemp -d)
SERVER_PID=""
cleanup() {
  [[ -n $SERVER_PID ]] && kill "$SERVER_PID" 2>/dev/null
  rm -rf "$TEST_HOME"
}
trap cleanup EXIT

export HOME="$TEST_HOME"
export XDG_CACHE_HOME="$TEST_HOME/cache"
export XDG_DATA_HOME="$TEST_HOME/data"
export XDG_CONFIG_HOME="$TEST_HOME/config"
unset SYNTHETIC_API_KEY PI_CODING_AGENT_DIR OPENCODE_DB

collector="$ROOT/bin/omarchy-agent-usage-synthetic"
STATE="$TEST_HOME/server"
mkdir -p "$STATE"
LIMITS_CACHE="$XDG_CACHE_HOME/omarchy/agent-usage"

# A stand-in for api.synthetic.new: answers /v2/quotas with $STATE/body and
# the status in $STATE/status, and notes each request and its key.
python3 - "$STATE" <<'PY' &
import http.server, pathlib, sys
state = pathlib.Path(sys.argv[1])

class Handler(http.server.BaseHTTPRequestHandler):
  def do_GET(self):
    count = state / "count"
    count.write_text(str(int(count.read_text() if count.exists() else "0") + 1))
    (state / "auth").write_text(self.headers.get("Authorization", ""))
    status = int((state / "status").read_text()) if (state / "status").exists() else 200
    body = (state / "body").read_bytes() if self.path == "/v2/quotas" else b"{}"
    self.send_response(status)
    self.send_header("Content-Type", "application/json")
    self.end_headers()
    self.wfile.write(body)

  def log_message(self, *args):
    pass

server = http.server.HTTPServer(("127.0.0.1", 0), Handler)
(state / "port").write_text(str(server.server_address[1]))
server.serve_forever()
PY
SERVER_PID=$!
for _ in $(seq 50); do
  [[ -s $STATE/port ]] && break
  sleep 0.1
done
[[ -s $STATE/port ]] || fail "Synthetic test server starts"
export SYNTHETIC_API_BASE_URL="http://127.0.0.1:$(cat "$STATE/port")"

requests() {
  cat "$STATE/count" 2>/dev/null || echo 0
}

serve() {
  printf '%s' "$1" >"$STATE/status"
  printf "%s" "${2-}" >"$STATE/body"
}

modern='{
  "subscription": {"requests": 0, "limit": 1000, "renewsAt": "2099-08-17T00:00:00Z"},
  "rollingFiveHourLimit": {"remaining": 750, "max": 1000, "limited": false, "nextTickAt": "2099-08-16T02:00:00Z"},
  "weeklyTokenLimit": {"percentRemaining": 64, "remainingCredits": "$31.05", "maxCredits": "$48.00", "nextRegenAt": "2099-08-16T04:00:00Z"},
  "search": {"hourly": {"requests": 25, "limit": 250, "renewsAt": "2099-08-16T03:00:00Z"}},
  "freeToolCalls": {"requests": "many", "limit": 100}
}'
serve 200 "$modern"

# ------------------------------------------------------------ unused machine

result=$("$collector")
[[ $(jq -c '[.ready, .limits, .usageStatusText, .authHelpText, .tierLabel, .todayTotalTokens, (.recentDays | length), has("retryAdvised")]' <<<"$result") == '[false,[],"","","",0,7,false]' ]] ||
  fail "Synthetic collector prints an empty, not-ready record on an unused machine" "$result"
[[ $(requests) == "0" ]] ||
  fail "Synthetic collector asks nothing without a key" "$(requests)"
pass "Synthetic collector prints an empty, not-ready record on an unused machine"

# ---------------------------------------------------------------- credentials

key_used() {
  rm -f "$LIMITS_CACHE"/synthetic-limits-*.json
  "$@" "$collector" --force >/dev/null
  cat "$STATE/auth"
}

mkdir -p "$TEST_HOME/.pi/agent" "$TEST_HOME/.omp/agent" "$XDG_DATA_HOME/opencode" "$TEST_HOME/moved" "$TEST_HOME/.omp/profiles/work/agent"
echo '{"synthetic":{"type":"api_key","key":"profile-key"}}' >"$TEST_HOME/.omp/profiles/work/agent/auth.json"
[[ $(key_used env) == "Bearer profile-key" ]] || fail "Synthetic collector reads a named profile's key" "$(cat "$STATE/auth")"
echo '{"synthetic":{"type":"api_key","key":"opencode-key"}}' >"$XDG_DATA_HOME/opencode/auth.json"
[[ $(key_used env) == "Bearer opencode-key" ]] || fail "Synthetic collector reads opencode's key" "$(cat "$STATE/auth")"
echo '{"synthetic":{"type":"api_key","key":"omp-key"}}' >"$TEST_HOME/.omp/agent/auth.json"
[[ $(key_used env) == "Bearer omp-key" ]] || fail "Synthetic collector prefers omp's key to opencode's" "$(cat "$STATE/auth")"
echo '{"synthetic":{"type":"api_key","key":"$PI_SYNTHETIC"}}' >"$TEST_HOME/.pi/agent/auth.json"
[[ $(key_used env PI_SYNTHETIC=pi-key) == "Bearer pi-key" ]] || fail "Synthetic collector resolves pi's \$ENV key" "$(cat "$STATE/auth")"
echo '{"synthetic":{"key":"moved-key"}}' >"$TEST_HOME/moved/auth.json"
[[ $(key_used env PI_CODING_AGENT_DIR="$TEST_HOME/moved") == "Bearer moved-key" ]] || fail "Synthetic collector follows PI_CODING_AGENT_DIR" "$(cat "$STATE/auth")"
[[ $(key_used env SYNTHETIC_API_KEY=env-key) == "Bearer env-key" ]] || fail "Synthetic collector prefers SYNTHETIC_API_KEY" "$(cat "$STATE/auth")"
rm -f "$TEST_HOME/.pi/agent/auth.json" "$TEST_HOME/.omp/agent/auth.json" "$XDG_DATA_HOME/opencode/auth.json" "$TEST_HOME/.omp/profiles/work/agent/auth.json"
pass "Synthetic collector reads its key from the environment, pi, omp, opencode, then a profile"

export SYNTHETIC_API_KEY=secret

# --------------------------------------------------------------- fresh quotas

rm -f "$LIMITS_CACHE"/synthetic-limits-*.json
result=$("$collector")
[[ $(jq -c '[.limits[] | [.label, (.percent * 1000 | round / 1000), .resetsAt, (.title // "")]]' <<<"$result") == '[["Rolling (5h)",0.25,"",""],["Weekly credits",0.36,"",""],["Search (hourly)",0.1,"2099-08-16T03:00:00Z","Search"]]' ]] ||
  fail "Synthetic collector maps the quota windows" "$result"
[[ $(jq -c '[.ready, .tierLabel, .limitsStale, .usageStatusText, .authHelpText, ([.limits[] | keys[]] | unique)]' <<<"$result") == '[true,"",false,"","",["label","percent","resetsAt","title"]]' ]] ||
  fail "Synthetic collector reports a healthy record with only contract fields" "$result"
pass "Synthetic collector reads fresh quotas, leaving regeneration ticks out of reset times"

limits() {
  SYNTHETIC_COLLECTOR="$collector" PAYLOAD="$1" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os
loader = importlib.machinery.SourceFileLoader("collector", os.environ["SYNTHETIC_COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
print(json.dumps(collector.parse_quotas(json.loads(os.environ["PAYLOAD"]))))
PY
}
[[ $(jq -c '[.[] | [.label, .percent]]' <<<"$(limits '{"subscription":{"requests":27,"limit":135,"renewsAt":"2099-08-17T00:00:00Z"}}')") == '[["Subscription requests",0.2]]' ]] ||
  fail "Synthetic collector reads the documented subscription bucket" "$(limits '{"subscription":{"requests":27,"limit":135}}')"
[[ $(jq -c '[.[] | .percent]' <<<"$(limits '{"rollingFiveHourLimit":{"remaining":900,"max":1000,"limited":true},"weeklyTokenLimit":{"percentRemaining":true}}')") == '[1.0]' ]] ||
  fail "Synthetic collector fills a limited rolling window and skips an unreadable one" "$(limits '{"rollingFiveHourLimit":{"remaining":900,"max":1000,"limited":true}}')"
pass "Synthetic collector reads the documented bucket and untrusted quota fields"

# ------------------------------------------------------------- probe reuse

before=$(requests)
"$collector" >/dev/null
[[ $(requests) == "$before" ]] ||
  fail "Synthetic collector reuses a check from seconds ago" "$(requests)"
"$collector" --force >/dev/null
[[ $(requests) == "$((before + 1))" ]] ||
  fail "Synthetic collector --force checks again" "$(requests)"
pass "Synthetic collector reuses a recent check and --force checks again"

# -------------------------------------------------------------- failures

cache_file=$(ls "$LIMITS_CACHE"/synthetic-limits-*.json)
age_cache() {
  local fetched=$((($(date +%s) - 3600) * 1000))
  jq -c --argjson t "$fetched" '.fetchedAtMs = $t' "$cache_file" >"$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
}

age_cache
serve 500
result=$("$collector")
[[ $(jq -c '[.limitsStale, (.limits | length), .usageStatusText, has("retryAdvised"), .limitsFetchedAt > 0]' <<<"$result") == '[true,3,"",false,true]' ]] ||
  fail "Synthetic collector keeps the last quotas stale after a failed check" "$result"
pass "Synthetic collector keeps the last quotas stale after a failed check"

# A kept window whose reset passed comes back at zero.
jq -c '.limits[2].resetsAt = "2000-01-01T00:00:00Z"' "$cache_file" >"$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
result=$("$collector")
[[ $(jq -c '.limits[2] | [.label, .percent, .resetsAt]' <<<"$result") == '["Search (hourly)",0.0,""]' ]] ||
  fail "Synthetic collector zeroes a kept window that reset" "$result"
pass "Synthetic collector zeroes a kept window that reset"

result=$(SYNTHETIC_API_BASE_URL="http://127.0.0.1:1" "$collector")
[[ $(jq -c '[.retryAdvised, .limitsStale, .usageStatusText]' <<<"$result") == '[true,true,""]' ]] ||
  fail "Synthetic collector advises a retry when the endpoint is unreachable" "$result"
pass "Synthetic collector advises a retry only when the endpoint is unreachable"

serve 401
result=$("$collector")
[[ $(jq -c '[.usageStatusText, .limitsStale, (.limits | length)]' <<<"$result") == '["Sign-in expired",true,3]' ]] ||
  fail "Synthetic collector says a refused key needs signing in again" "$result"
pass "Synthetic collector says a refused key needs signing in again"

rm -f "$cache_file"
serve 500
result=$("$collector")
[[ $(jq -c '[.usageStatusText, .limits, .limitsFetchedAt]' <<<"$result") == '["Synthetic limits unavailable",[],0]' ]] ||
  fail "Synthetic collector says the limits are unavailable with nothing kept" "$result"
[[ $(jq -r '.authHelpText' <<<"$result") == *"status 500"* ]] ||
  fail "Synthetic collector says what failed" "$result"
pass "Synthetic collector says the limits are unavailable with nothing kept"

# ------------------------------------------------------------- local stats

serve 200 "$modern"
today=$(date +%Y-%m-%d)
sessions="$TEST_HOME/.pi/agent/sessions/--work--"
mkdir -p "$sessions" "$TEST_HOME/.omp/profiles/side/agent/sessions"
line() {
  printf '{"type":"message","id":"%s","timestamp":"%sT12:00:00.000Z","message":{"role":"assistant","provider":"%s","model":"hf:moonshotai/Kimi-K2","usage":{"input":%s,"output":10,"cacheRead":0,"cacheWrite":0}}}\n' "$1" "$today" "$2" "$3"
}
{ line a synthetic 100; line b synthetic 200; line c openrouter 999; line d synthetic NaN; } >"$sessions/one.jsonl"
# A fork names its parent in its header and repeats the parent's messages.
{
  printf '{"type":"session","parentSession":"%s"}\n' "$sessions/one.jsonl"
  line b synthetic 200
} >"$TEST_HOME/.omp/profiles/side/agent/sessions/fork.jsonl"
printf '*\n' >"$TEST_HOME/.gitignore"
git -C "$TEST_HOME" init -q

{ python3 - "$XDG_DATA_HOME/opencode/opencode.db" || true; } 2>/dev/null <<'PY'
import json, sqlite3, sys, time
conn = sqlite3.connect(sys.argv[1]); now = int(time.time() * 1000)
conn.execute("PRAGMA journal_mode=WAL")
conn.execute("CREATE TABLE message (id TEXT PRIMARY KEY, session_id TEXT, time_created INTEGER, time_updated INTEGER, data TEXT)")
conn.execute("CREATE TABLE session_message (id TEXT PRIMARY KEY, session_id TEXT, type TEXT, time_created INTEGER, data TEXT)")
def tokens(i, o, r=0): return {"input": i, "output": o, "reasoning": r, "cache": {"read": 0, "write": 0}}
conn.execute("INSERT INTO message VALUES ('m1', 's1', ?, ?, ?)", (now, now, json.dumps({"role": "assistant", "providerID": "synthetic", "modelID": "hf:zai-org/GLM-4.6", "tokens": tokens(40, 5, 5), "time": {"created": now}})))
conn.execute("INSERT INTO message VALUES ('m2', 's1', ?, ?, ?)", (now, now, json.dumps({"role": "assistant", "providerID": "anthropic", "modelID": "claude", "tokens": tokens(999, 999), "time": {"created": now}})))
conn.execute("INSERT INTO session_message VALUES ('v1', 's2', 'compaction', ?, ?)", (now, json.dumps({"model": {"providerID": "synthetic", "id": "hf:zai-org/GLM-4.6"}, "tokens": tokens(30, 0), "time": {"created": now}})))
conn.execute("INSERT INTO session_message VALUES ('m1', 's1', 'assistant', ?, ?)", (now, json.dumps({"model": {"providerID": "synthetic", "id": "hf:zai-org/GLM-4.6"}, "tokens": tokens(40, 5, 5), "time": {"created": now}})))
conn.commit()
# Left open, so the rows stay in the write-ahead log and an immutable open
# would not see them.
import os
os.kill(os.getpid(), 9)
PY

result=$("$collector" --force)
# pi: a 110 + b 210 (the fork's copy counts once, NaN reads as 10 output);
# opencode: m1 50 once across both stores + compaction 30.
[[ $(jq -c '[.todayTotalTokens, .todayPrompts, .modelUsage["Kimi-K2"].inputTokens, .modelUsage["GLM-4.6"].inputTokens, .todaySessions]' <<<"$result") == "[410,5,300,70,3]" ]] ||
  fail "Synthetic collector counts pi, omp and opencode usage on the synthetic provider once" "$result"
pass "Synthetic collector counts pi, omp and opencode usage on the synthetic provider once"

unset SYNTHETIC_API_KEY
result=$("$collector" --force)
[[ $(jq -c '[.ready, .usageStatusText, .limits]' <<<"$result") == '[true,"Waiting for auth",[]]' ]] ||
  fail "Synthetic collector waits for auth when in use without a key" "$result"
pass "Synthetic collector waits for auth when in use without a key"
