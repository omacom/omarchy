#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.config/muse" "$TEST_HOME/bin"
cat >"$TEST_HOME/.config/muse/auth.json" <<'EOF'
{"schema_version":1,"providers":{"meta":{"access_token":"test-token","api_base_url":"https://api.meta.ai/v1"}}}
EOF

# A stub key service: records the Authorization header it was called with
# and answers from canned payloads. The collector must send the OAuth token
# as a Bearer token and never anywhere else.
cat >"$TEST_HOME/stub.py" <<'EOF'
import http.server
import json
import os
import sys

seen_file = os.environ["STUB_SEEN_FILE"]
mode_file = os.environ["STUB_MODE_FILE"]

def stub_mode():
  try:
    with open(mode_file) as handle:
      return handle.read().strip()
  except OSError:
    return "ok"

class Handler(http.server.BaseHTTPRequestHandler):
  def do_POST(self):
    length = int(self.headers.get("Content-Length") or 0)
    self.rfile.read(length)
    with open(seen_file, "a") as handle:
      handle.write(self.headers.get("Authorization") + "\n")
    if stub_mode() == "unauthorized":
      self.send_response(401)
      self.end_headers()
      return
    body = json.dumps({
      "subs_tier_name": "Muse Code Test Plan",
      "subs_usage": {
        "window": {"used_percent": 8, "window_duration_mins": 300, "resets_at": 1788900190},
        "weekly": {"used_percent": 15, "resets_at": 1789344000},
        "tier": "123",
      },
    }).encode()
    self.send_response(200)
    self.send_header("Content-Type", "application/json")
    self.send_header("Content-Length", str(len(body)))
    self.end_headers()
    self.wfile.write(body)

  def log_message(self, *args):
    pass

http.server.HTTPServer(("127.0.0.1", int(sys.argv[1])), Handler).serve_forever()
EOF

port=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
export STUB_SEEN_FILE="$TEST_HOME/seen-headers"
export STUB_MODE_FILE="$TEST_HOME/stub-mode"
printf 'ok' >"$TEST_HOME/stub-mode"
python3 "$TEST_HOME/stub.py" "$port" & stub_pid=$!
trap 'kill "$stub_pid" 2>/dev/null; rm -rf "$TEST_HOME"' EXIT
for _ in $(seq 1 50); do
  (echo >/dev/tcp/127.0.0.1/"$port") 2>/dev/null && break
  sleep 0.1
done

run_collector() {
  HOME="$TEST_HOME" XDG_DATA_HOME="$TEST_HOME/.local/share" XDG_CACHE_HOME="$TEST_HOME/.cache" XDG_CONFIG_HOME="$TEST_HOME/.config" \
    MUSE_KEY_ENDPOINT="http://127.0.0.1:$port/key" \
    "$ROOT/bin/omarchy-agent-usage-muse" "$@"
}

result=$(run_collector --force)

[[ $(jq -c '[.limits[]|{label,percent}]' <<<"$result") == '[{"label":"Session (5-hour)","percent":0.08},{"label":"Weekly (7-day)","percent":0.15}]' ]] ||
  fail "Muse collector reports window and weekly limits from the key endpoint" "$result"
pass "Muse collector reports window and weekly limits from the key endpoint"

[[ $(jq -r '.limits[0].resetsAt' <<<"$result") == "2026-09-08T20:43:10+00:00" ]] ||
  fail "Muse collector converts window reset times to ISO" "$result"
pass "Muse collector converts window reset times to ISO"

[[ $(jq -r '.limits[1].resetsAt' <<<"$result") == "2026-09-14T00:00:00+00:00" ]] ||
  fail "Muse collector converts weekly reset times to ISO" "$result"
pass "Muse collector converts weekly reset times to ISO"

[[ $(jq -r '.tierLabel' <<<"$result") == "Muse Code Test Plan" ]] ||
  fail "Muse collector reports the subscription tier" "$result"
pass "Muse collector reports the subscription tier"

[[ $(cat "$STUB_SEEN_FILE") == "Bearer test-token" ]] ||
  fail "Muse collector authenticates the probe with the saved token" "$(cat "$STUB_SEEN_FILE")"
pass "Muse collector authenticates the probe with the saved token"

# A fresh probe result is reused briefly, so repeated panel opens do not
# turn into a request per flick.
: >"$STUB_SEEN_FILE"
second=$(run_collector)
[[ -s $STUB_SEEN_FILE ]] &&
  fail "Muse collector reuses a recent probe result" "$(cat "$STUB_SEEN_FILE")"
pass "Muse collector reuses a recent probe result"

[[ $(jq -r '.tierLabel' <<<"$second") == "Muse Code Test Plan" ]] ||
  fail "Muse collector reuses the cached tier" "$second"
pass "Muse collector reuses the cached tier"

# A rejected sign-in is an auth problem, not missing data: say so, and keep
# the estimated meters when caps are configured.
printf 'unauthorized' >"$TEST_HOME/stub-mode"
mkdir -p "$TEST_HOME/.config/omarchy/agents"
printf '{"sessionWindowTokens":1000,"weeklyWindowTokens":1000}' >"$TEST_HOME/.config/omarchy/agents/muse.json"
expired=$(run_collector --force)

[[ $(jq -r '.usageStatusText' <<<"$expired") == "Sign-in expired" ]] ||
  fail "Muse collector reports an expired sign-in" "$expired"
pass "Muse collector reports an expired sign-in"

[[ $(jq -c '[.limits[].title]' <<<"$expired") == '["Session (estimated)","Weekly (estimated)"]' ]] ||
  fail "Muse collector falls back to estimated meters when the probe fails" "$expired"
pass "Muse collector falls back to estimated meters when the probe fails"
