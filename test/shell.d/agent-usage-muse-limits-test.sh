#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

unset MUSE_DATA_DIR MUSE_AUTH_PATH MUSE_KEY_ENDPOINT

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.config/muse" "$TEST_HOME/.cache"
cat >"$TEST_HOME/.config/muse/auth.json" <<'EOF'
{"schema_version":1,"providers":{"meta":{"access_token":"test-token","api_base_url":"https://api.meta.ai/v1"}}}
EOF

# A stub key service: records the Authorization header it was called with
# and answers from a canned payload file. The collector must send the OAuth
# token as a Bearer token and never persist it anywhere.
cat >"$TEST_HOME/stub.py" <<'EOF'
import http.server
import json
import os
import sys

seen_file = os.environ["STUB_SEEN_FILE"]
payload_file = os.environ["STUB_PAYLOAD_FILE"]

class Handler(http.server.BaseHTTPRequestHandler):
  def do_POST(self):
    length = int(self.headers.get("Content-Length") or 0)
    self.rfile.read(length)
    with open(seen_file, "a") as handle:
      handle.write((self.headers.get("Authorization") or "") + "\n")
    try:
      with open(payload_file) as handle:
        spec = json.load(handle)
    except OSError:
      spec = {"status": 500}
    status = spec.get("status", 200)
    self.send_response(status)
    if status != 200:
      self.end_headers()
      return
    raw = spec.get("raw")
    body = raw.encode() if isinstance(raw, str) else json.dumps(spec.get("body", {})).encode()
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
export STUB_PAYLOAD_FILE="$TEST_HOME/stub-payload.json"
: >"$STUB_SEEN_FILE"
printf '{"status":500}' >"$STUB_PAYLOAD_FILE"
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

set_payload() {
  printf '%s' "$1" >"$STUB_PAYLOAD_FILE"
  : >"$STUB_SEEN_FILE"
  # Each stub case starts without a previous probe's cache, so fallback
  # behavior never leaks across cases.
  rm -f "$TEST_HOME/.cache/omarchy/agent-usage/muse-limits.json"
}

# Subscriber with usage: window + weekly percents, resets, tier.
set_payload '{"body":{"subs_tier_name":"Power Usage","subs_usage":{"window":{"used_percent":8,"window_duration_mins":300,"resets_at":1788900190},"weekly":{"used_percent":15,"resets_at":1789344000}}}}'
result=$(run_collector --force)

[[ $(jq -c '[.limits[]|{label,percent}]' <<<"$result") == '[{"label":"Session (5-hour)","percent":0.08},{"label":"Weekly (7-day)","percent":0.15}]' ]] ||
  fail "Muse collector reports window and weekly limits from the key endpoint" "$result"
pass "Muse collector reports window and weekly limits from the key endpoint"

[[ $(jq -r '.limits[0].resetsAt' <<<"$result") == "2026-09-08T20:43:10+00:00" ]] ||
  fail "Muse collector converts window reset times to ISO" "$result"
pass "Muse collector converts window reset times to ISO"

[[ $(jq -r '.tierLabel' <<<"$result") == "Power Usage" ]] ||
  fail "Muse collector reports the subscription tier" "$result"
pass "Muse collector reports the subscription tier"

[[ $(cat "$STUB_SEEN_FILE") == "Bearer test-token" ]] ||
  fail "Muse collector authenticates the probe with the saved token" "$(cat "$STUB_SEEN_FILE")"
pass "Muse collector authenticates the probe with the saved token"

# Token and minted key must not leak into the record or the caches.
grep -rq "test-token" "$TEST_HOME/.cache" "$TEST_HOME/.local" 2>/dev/null &&
  fail "Muse collector keeps the token out of caches" "$(grep -r "test-token" "$TEST_HOME/.cache" 2>/dev/null)"
pass "Muse collector keeps the token out of caches"

# A fresh probe result is reused briefly, so repeated panel opens do not
# turn into a request per flick.
: >"$STUB_SEEN_FILE"
second=$(run_collector)
[[ -s $STUB_SEEN_FILE ]] &&
  fail "Muse collector reuses a recent probe result" "$(cat "$STUB_SEEN_FILE")"
pass "Muse collector reuses a recent probe result"

[[ $(jq -r '.tierLabel' <<<"$second") == "Power Usage" ]] ||
  fail "Muse collector reuses the cached tier" "$second"
pass "Muse collector reuses the cached tier"

# Pay-as-you-go: key mints fine but there is no subscription window to
# meter. Silent local metering — not an error, not expired.
set_payload '{"body":{"api_key":"minted","is_subs_active":false,"subs_tier_name":null}}'
payg=$(run_collector --force)
[[ $(jq -c '[.limits,.tierLabel,.usageStatusText,.authHelpText]' <<<"$payg") == '[[],"Account","",""]' ]] ||
  fail "Muse collector stays silent for pay-as-you-go accounts" "$payg"
pass "Muse collector stays silent for pay-as-you-go accounts"

[[ $(jq 'has("retryAdvised")' <<<"$payg") == "false" ]] ||
  fail "Muse collector does not retry a pay-as-you-go answer" "$payg"
pass "Muse collector does not retry a pay-as-you-go answer"

# Subscriber without a usage snapshot yet: keep the tier, say limits are
# unavailable, never invent meters.
set_payload '{"body":{"api_key":"minted","is_subs_active":true,"subs_tier_name":"Muse Code Everyday Usage"}}'
nosnap=$(run_collector --force)
[[ $(jq -r '.tierLabel' <<<"$nosnap") == "Muse Code Everyday Usage" ]] ||
  fail "Muse collector keeps the tier without a usage snapshot" "$nosnap"
pass "Muse collector keeps the tier without a usage snapshot"

[[ $(jq -r '.usageStatusText' <<<"$nosnap") == "Muse limits unavailable" ]] ||
  fail "Muse collector reports unavailable limits without a snapshot" "$nosnap"
pass "Muse collector reports unavailable limits without a snapshot"

# A rejected sign-in is an auth problem, not missing data: say so.
set_payload '{"status":401}'
expired=$(run_collector --force)
[[ $(jq -r '.usageStatusText' <<<"$expired") == "Sign-in expired" ]] ||
  fail "Muse collector reports an expired sign-in" "$expired"
pass "Muse collector reports an expired sign-in"

# A malformed login file is a missing credential, not a crash.
for malformed in '[1,2]' '"nope"' '{"providers":[]}' '{"providers":{"meta":7}}'; do
  printf '%s' "$malformed" >"$TEST_HOME/.config/muse/auth.json"
  garbled=$(run_collector --force) ||
    fail "Muse collector survives a malformed login file" "$malformed"
  [[ $(jq -c '[.limits,.usageStatusText]' <<<"$garbled") == '[[],""]' ]] ||
    fail "Muse collector survives a malformed login file" "$malformed -> $garbled"
done
pass "Muse collector survives a malformed login file"
printf '{"providers":{"meta":{"access_token":"test-token"}}}' >"$TEST_HOME/.config/muse/auth.json"

# The override must win over a different login at the default location.
export MUSE_AUTH_PATH="$TEST_HOME/custom auth.json"
printf '{"providers":{"meta":{"access_token":"test-token"}}}' >"$MUSE_AUTH_PATH"
printf '{"providers":{"meta":{"access_token":"default-token"}}}' >"$TEST_HOME/.config/muse/auth.json"
set_payload '{"body":{"subs_tier_name":"T","subs_usage":{"window":{"used_percent":5,"window_duration_mins":300}}}}'
custom=$(run_collector --force)
[[ $(cat "$STUB_SEEN_FILE") == "Bearer test-token" ]] ||
  fail "Muse collector honors MUSE_AUTH_PATH over the default login" "$(cat "$STUB_SEEN_FILE")"
pass "Muse collector honors MUSE_AUTH_PATH over the default login"
unset MUSE_AUTH_PATH
