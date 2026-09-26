#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$STUB_PID_FILE"' EXIT

# The collector's protobuf helpers are importable (the __main__ guard keeps
# main() out), which lets the test build a real GetUserStatusResponse instead
# of asserting against a magic blob.
COLLECTOR="$ROOT/bin/omarchy-agent-usage-devin"
export COLLECTOR

stub_usage_server() {
  # $1: port file; serves one canned response per request until killed.
# stdout/stderr are detached: a background child holding the caller's stdout
# pipe open would block the command substitution that waits for its PID.
  python3 - "$1" >/dev/null 2>&1 <<'PY' &
import http.server
import importlib.machinery
import importlib.util
import os
import sys

loader = importlib.machinery.SourceFileLoader("devin_collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader("devin_collector", loader)
c = importlib.util.module_from_spec(spec)
loader.exec_module(c)

port_file = sys.argv[1]

# GetUserStatusResponse: user_status{10: tier, 13: plan_status{14: daily%,
# 15: weekly%, 17/18: resets}}, plan_info{1: tier, 2: name, 35: strategy}.
def response(daily_p=60, weekly_p=40, daily_reset=1789891200, weekly_reset=1790409600,
             plan_name="Pro", tier=16, billing=2):
  plan_status = b"".join([
    c.tag(14, 0) + c.varint(daily_p),
    c.tag(15, 0) + c.varint(weekly_p),
    c.tag(17, 0) + c.varint(daily_reset),
    c.tag(18, 0) + c.varint(weekly_reset),
  ])
  plan_info = b"".join([
    c.tag(1, 0) + c.varint(tier),
    c.estr(2, plan_name),
    c.tag(35, 0) + c.varint(billing),
  ])
  user_status = b"".join([
    c.tag(10, 0) + c.varint(tier),
    c.emsg(13, plan_status),
  ])
  return c.emsg(1, user_status) + c.emsg(2, plan_info)

class Handler(http.server.BaseHTTPRequestHandler):
  def do_POST(self):
    length = int(self.headers.get("content-length") or 0)
    body = self.rfile.read(length)

    def walk(buf, want):
      # First length-delimited field numbered `want`, walked by hand so the
      # stub can read the api_key back out of the request metadata.
      i = 0
      while i < len(buf):
        t, i = c.dec_varint(buf, i)
        num, w = t >> 3, t & 7
        if w == 0:
          _, i = c.dec_varint(buf, i)
        elif w == 2:
          ln, i = c.dec_varint(buf, i)
          v = buf[i:i + ln]
          i += ln
          if num == want:
            return v
        elif w == 5:
          i += 4
        elif w == 1:
          i += 8
      return None

    # Echo the api_key the collector sent as the plan name: the test then
    # asserts against exactly what arrived on the wire. The full canned
    # response rides along in field 33 so the RPC branch still sees a plan.
    meta = walk(body, 1)
    api_key = walk(meta, 3).decode() if meta else "?"
    body = c.emsg(2, c.emsg(33, c.estr(2, api_key))) + response()
    self.send_response(200)
    self.send_header("content-type", "application/proto")
    self.send_header("content-length", str(len(body)))
    self.end_headers()
    self.wfile.write(body)
  def log_message(self, *args):
    pass

server = http.server.HTTPServer(("127.0.0.1", 0), Handler)
open(port_file, "w").write(str(server.server_address[1]))
server.serve_forever()
PY
  echo $!
}

write_credentials() {
  # $1: home dir; $2: api_server_url
  mkdir -p "$1/.local/share/devin"
  cat >"$1/.local/share/devin/credentials.toml" <<'EOF'
windsurf_api_key = "devin-session-token$fake-token-for-tests"
EOF
  cat >>"$1/.local/share/devin/credentials.toml" <<EOF
api_server_url = "$2"
devin_webapp_host = "app.devin.ai"
devin_api_url = "https://api.devin.ai"
EOF
}

STUB_PORT_FILE=$(mktemp)
STUB_PID_FILE="$STUB_PORT_FILE.pid"
STUB_PID=$(stub_usage_server "$STUB_PORT_FILE")
echo "$STUB_PID" >"$STUB_PID_FILE"
trap 'rm -rf "$TEST_HOME" "$STUB_PORT_FILE" "$STUB_PID_FILE"; kill "$STUB_PID" 2>/dev/null' EXIT
for _ in 1 2 3 4 5 6 7 8 9 10; do [[ -s $STUB_PORT_FILE ]] && break; sleep 0.2; done
STUB_URL="http://127.0.0.1:$(cat "$STUB_PORT_FILE")"

# ── pi/omp sessions on the devin provider ───────────────────────────────────

timestamp="$(date +%Y-%m-%d)T12:00:00Z"
mkdir -p "$TEST_HOME/.pi/agent/sessions/project" "$TEST_HOME/.omp/agent/sessions/project"
cat >"$TEST_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"pi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"devin","model":"swe-2","usage":{"input":10,"output":4,"cacheRead":3,"cacheWrite":2,"totalTokens":19}}}
{"type":"message","id":"pi-2","timestamp":"$timestamp","message":{"role":"assistant","provider":"openai-codex","model":"gpt-x","usage":{"input":999,"output":999}}}
{"type":"message","id":"pi-3","timestamp":"$timestamp","message":{"role":"user","provider":"devin"}}
EOF
cat >"$TEST_HOME/.omp/agent/sessions/project/omp.jsonl" <<EOF
{"type":"message","id":"omp-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"devin","model":"glm-5.3-flash","usage":{"input":20,"output":5,"cacheRead":4,"cacheWrite":1,"totalTokens":30}}}
EOF

result=$(HOME="$TEST_HOME" XDG_DATA_HOME="$TEST_HOME/.local/share" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  PATH="$TEST_HOME/bin:$PATH" "$COLLECTOR")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "49" ]] ||
  fail "Devin collector counts usage from pi and omp sessions on the devin provider" "$result"
[[ $(jq -c '.modelUsage' <<<"$result") == '{"swe-2":{"inputTokens":10,"outputTokens":4,"cacheReadInputTokens":3,"cacheCreationInputTokens":2},"glm-5.3-flash":{"inputTokens":20,"outputTokens":5,"cacheReadInputTokens":4,"cacheCreationInputTokens":1}}' ]] ||
  fail "Devin collector filters pi and omp sessions to the devin provider" "$result"
pass "Devin collector counts pi and omp subscription usage"

# Without credentials the quota probe reports not-ready and asks for a retry;
# local stats still stand on their own.
[[ $(jq -r '.ready' <<<"$result") == "false" ]] ||
  fail "Devin collector is not ready without credentials" "$result"
[[ $(jq -r '.retryAdvised' <<<"$result") == "true" && $(jq -r '.usageStatusText' <<<"$result") == "Devin quota unavailable" ]] ||
  fail "Devin collector advises a retry when the quota probe fails" "$result"
pass "Devin collector reports quota unavailable without credentials"

# ── quota RPC against the stub ──────────────────────────────────────────────

RPC_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$RPC_HOME" "$STUB_PORT_FILE" "$STUB_PID_FILE"; kill "$STUB_PID" 2>/dev/null' EXIT
write_credentials "$RPC_HOME" "$STUB_URL"

result=$(HOME="$RPC_HOME" XDG_DATA_HOME="$RPC_HOME/.local/share" XDG_CACHE_HOME="$RPC_HOME/.cache" \
  PATH="$RPC_HOME/bin:$PATH" "$COLLECTOR")

# The wire reports REMAINING percent; the record reports the fraction used.
# The RPC branch prefers the plan name from plan_info (field 2); the stub
# echoes the api_key there, so this also proves the token reached the wire.
[[ $(jq -r '"\(.ready) \(.tierLabel)"' <<<"$result") == "true devin-session-token\$fake-token-for-tests" ]] ||
  fail "Devin collector reports the plan from GetUserStatus" "$result"
[[ $(jq -c '.limits' <<<"$result") == '[{"label":"Daily quota","percent":0.4,"resetsAt":"2026-09-20T08:00:00+00:00"},{"label":"Weekly quota","percent":0.6,"resetsAt":"2026-09-26T08:00:00+00:00"}]' ]] ||
  fail "Devin collector converts remaining quota to fraction used" "$result"
pass "Devin collector converts remaining quota to fraction used"

# A signed-in pi session is a second credential source for machines where
# Devin only ever ran through pi. The stub echoes the api_key it received
# back as the plan name, so the assertion sees the token on the wire — and
# that it went to the api_server_url the CLI's credentials.toml names, even
# when the token itself came from pi. The CLI's own key is deliberately left
# out: with both present the CLI wins, and this branch would never run.
PI_AUTH_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$RPC_HOME" "$PI_AUTH_HOME" "$STUB_PORT_FILE" "$STUB_PID_FILE"; kill "$STUB_PID" 2>/dev/null' EXIT
mkdir -p "$PI_AUTH_HOME/.pi/agent" "$PI_AUTH_HOME/.local/share/devin"
cat >"$PI_AUTH_HOME/.pi/agent/auth.json" <<'EOF'
{"devin": {"type": "oauth", "access": "devin-session-token$pi-token", "expires": 9999999999999}}
EOF
cat >"$PI_AUTH_HOME/.local/share/devin/credentials.toml" <<EOF
api_server_url = "$STUB_URL"
EOF

result=$(HOME="$PI_AUTH_HOME" XDG_DATA_HOME="$PI_AUTH_HOME/.local/share" XDG_CACHE_HOME="$PI_AUTH_HOME/.cache" \
  PATH="$PI_AUTH_HOME/bin:$PATH" "$COLLECTOR" --limits-only)

[[ $(jq -r '.tierLabel' <<<"$result") == "devin-session-token\$pi-token" ]] ||
  fail "Devin collector sends pi's stored session token to the CLI's api_server_url" "$result"
pass "Devin collector sends pi's stored session token to the CLI's api_server_url"

# ── native CLI/Desktop session database ─────────────────────────────────────

NATIVE_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$RPC_HOME" "$PI_AUTH_HOME" "$NATIVE_HOME" "$STUB_PORT_FILE" "$STUB_PID_FILE"; kill "$STUB_PID" 2>/dev/null' EXIT

python3 - "$NATIVE_HOME/.local/share/devin/cli_sessions.db" <<'PY'
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE sessions (id TEXT PRIMARY KEY, working_directory TEXT NOT NULL, backend_type TEXT NOT NULL, model TEXT NOT NULL, permission_mode TEXT NOT NULL, created_at INTEGER NOT NULL, last_activity_at INTEGER NOT NULL, total_tokens INTEGER NOT NULL, current_epoch INTEGER NOT NULL DEFAULT 0)")
conn.execute("CREATE TABLE messages (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id TEXT NOT NULL, sequence_number INTEGER NOT NULL, role TEXT NOT NULL, content TEXT NOT NULL, tool_call_id TEXT, tool_calls_json TEXT, timestamp INTEGER NOT NULL, compaction_epoch INTEGER NOT NULL DEFAULT 0)")
now_s = int(time.time())
conn.execute("INSERT INTO sessions VALUES ('s-1', '/repo', 'cli', 'swe-2', 'default', ?, ?, 500, 0)", (now_s, now_s))
conn.executemany("INSERT INTO messages (session_id, sequence_number, role, content, timestamp) VALUES (?, ?, ?, '{}', ?)", [
  ("s-1", 1, "user", now_s),
  ("s-1", 2, "assistant", now_s),
  ("s-1", 3, "assistant", now_s),
])
conn.commit()
conn.close()
PY

result=$(HOME="$NATIVE_HOME" XDG_DATA_HOME="$NATIVE_HOME/.local/share" XDG_CACHE_HOME="$NATIVE_HOME/.cache" \
  PATH="$NATIVE_HOME/bin:$PATH" "$COLLECTOR")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "500" ]] ||
  fail "Devin collector attributes a native session's tokens to its last-activity day" "$result"
[[ $(jq -r '.todayPrompts' <<<"$result") == "2" && $(jq -r '.todaySessions' <<<"$result") == "1" ]] ||
  fail "Devin collector counts native assistant turns and sessions" "$result"
[[ $(jq -c '.modelUsage["swe-2"]' <<<"$result") == '{"inputTokens":500,"outputTokens":0,"cacheReadInputTokens":0,"cacheCreationInputTokens":0}' ]] ||
  fail "Devin collector keeps a native session's total in one bucket" "$result"
pass "Devin collector counts native CLI/Desktop session usage"

# ── scan cache ──────────────────────────────────────────────────────────────

CACHE_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$RPC_HOME" "$PI_AUTH_HOME" "$NATIVE_HOME" "$CACHE_HOME" "$STUB_PORT_FILE" "$STUB_PID_FILE"; kill "$STUB_PID" 2>/dev/null' EXIT
mkdir -p "$CACHE_HOME/.pi/agent/sessions/project"
cat >"$CACHE_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"c-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"devin","model":"swe-2","usage":{"input":5,"output":0}}}
EOF

result=$(HOME="$CACHE_HOME" XDG_DATA_HOME="$CACHE_HOME/.local/share" XDG_CACHE_HOME="$CACHE_HOME/.cache" \
  PATH="$CACHE_HOME/bin:$PATH" "$COLLECTOR")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "5" ]] ||
  fail "Devin collector writes a fresh local-stats cache on first scan" "$result"
cache_file=$(ls "$CACHE_HOME/.cache/omarchy/agent-usage/"/devin-scan-*.json 2>/dev/null | head -n 1)
[[ -n $cache_file && -s $cache_file && $(stat -c %a "$cache_file") == "644" ]] ||
  fail "Devin collector leaves a readable versioned cache file behind" "$result"
pass "Devin collector writes a local-stats cache on first scan"

cat >"$CACHE_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"c-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"devin","model":"swe-2","usage":{"input":5,"output":0}}}
{"type":"message","id":"c-2","timestamp":"$timestamp","message":{"role":"assistant","provider":"devin","model":"swe-2","usage":{"input":10,"output":0}}}
EOF

result=$(HOME="$CACHE_HOME" XDG_DATA_HOME="$CACHE_HOME/.local/share" XDG_CACHE_HOME="$CACHE_HOME/.cache" \
  PATH="$CACHE_HOME/bin:$PATH" "$COLLECTOR" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "5" ]] ||
  fail "Devin collector --limits-only reuses cached local stats" "$result"
pass "Devin collector --limits-only reuses cached local stats"

result=$(HOME="$CACHE_HOME" XDG_DATA_HOME="$CACHE_HOME/.local/share" XDG_CACHE_HOME="$CACHE_HOME/.cache" \
  PATH="$CACHE_HOME/bin:$PATH" "$COLLECTOR" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "15" ]] ||
  fail "Devin collector --force rescans past the cache" "$result"
pass "Devin collector --force rescans past the cache"

# A scan cut short by a database error must not be cached as the whole story.
BROKEN_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$RPC_HOME" "$PI_AUTH_HOME" "$NATIVE_HOME" "$CACHE_HOME" "$BROKEN_HOME" "$STUB_PORT_FILE" "$STUB_PID_FILE"; kill "$STUB_PID" 2>/dev/null' EXIT

python3 - "$BROKEN_HOME/.local/share/devin/cli_sessions.db" <<'PY'
import sqlite3
import sys
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE unrelated (id TEXT PRIMARY KEY)")
conn.commit()
conn.close()
PY

result=$(HOME="$BROKEN_HOME" XDG_DATA_HOME="$BROKEN_HOME/.local/share" XDG_CACHE_HOME="$BROKEN_HOME/.cache" \
  PATH="$BROKEN_HOME/bin:$PATH" "$COLLECTOR")

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "0" ]] ||
  fail "Devin collector reports what it could read from a database without the schema" "$result"
[[ -z $(ls "$BROKEN_HOME/.cache/omarchy/agent-usage/"devin-scan-*.json 2>/dev/null) ]] ||
  fail "Devin collector must not cache an interrupted scan" "$result"
pass "Devin collector does not cache an interrupted native scan"
