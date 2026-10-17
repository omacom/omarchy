#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

COLLECTOR="$ROOT/bin/omarchy-agent-usage-agy"

# probe_antigravity reaches Google's Cloud Code endpoints, so the readers that
# interpret the answers are exercised with recorded payloads standing in.

test_tier() {
  COLLECTOR="$COLLECTOR" PAYLOAD="$1" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

payload = json.loads(os.environ["PAYLOAD"])
print(collector.extract_tier(payload))
PY
}

ultra_tier=$(test_tier '{
  "currentTier": { "id": "free-tier", "name": "Antigravity" },
  "paidTier": { "id": "g1-ultra-tier", "name": "Google AI Ultra" }
}')
[[ $ultra_tier == "Ultra" ]] ||
  fail "Antigravity collector extracts Ultra tier from paidTier" "$ultra_tier"
pass "Antigravity collector extracts Ultra tier from paidTier"

pro_tier=$(test_tier '{
  "currentTier": { "id": "free-tier", "name": "Antigravity" },
  "paidTier": { "id": "g1-pro-tier", "name": "Google AI Pro" }
}')
[[ $pro_tier == "Pro" ]] ||
  fail "Antigravity collector extracts Pro tier from paidTier" "$pro_tier"
pass "Antigravity collector extracts Pro tier from paidTier"

free_tier=$(test_tier '{
  "currentTier": { "id": "free-tier", "name": "Antigravity" }
}')
[[ $free_tier == "Free" ]] ||
  fail "Antigravity collector extracts Free tier when no paidTier" "$free_tier"
pass "Antigravity collector extracts Free tier when no paidTier"

# Test quota extraction
test_limits() {
  COLLECTOR="$COLLECTOR" PAYLOAD="$1" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

payload = json.loads(os.environ["PAYLOAD"])
print(json.dumps(collector.extract_limits(payload)))
PY
}

quota_payload='{
  "groups": [
    {
      "displayName": "Gemini Models",
      "buckets": [
        {
          "bucketId": "gemini-weekly",
          "displayName": "Weekly Limit Remaining",
          "window": "weekly",
          "resetTime": "2026-09-17T18:19:42Z",
          "remainingFraction": 0.95
        },
        {
          "bucketId": "gemini-5h",
          "displayName": "Five Hour Limit Remaining",
          "window": "5h",
          "resetTime": "2026-09-15T19:31:46Z",
          "remainingFraction": 0.90
        }
      ]
    },
    {
      "displayName": "Claude and GPT models",
      "buckets": [
        {
          "bucketId": "3p-weekly",
          "displayName": "Weekly Limit Remaining",
          "window": "weekly",
          "resetTime": "2026-09-18T12:56:14Z",
          "remainingFraction": 0.98
        },
        {
          "bucketId": "3p-5h",
          "displayName": "Five Hour Limit Remaining",
          "window": "5h",
          "resetTime": "2026-09-15T22:16:22Z",
          "remainingFraction": 1.0
        }
      ]
    }
  ]
}'

limits=$(test_limits "$quota_payload")

[[ $(jq -r '.[0].label' <<<"$limits") == "Session (5-hour)" ]] ||
  fail "Antigravity collector places Session window first" "$limits"
pass "Antigravity collector places Session window first"

[[ $(jq -r '.[0].percent' <<<"$limits") == "0.1" ]] ||
  fail "Antigravity collector calculates used percentage from remainingFraction" "$limits"
pass "Antigravity collector calculates used percentage from remainingFraction"

[[ $(jq -r '.[1].label' <<<"$limits") == "Weekly (7-day)" ]] ||
  fail "Antigravity collector places Weekly window second" "$limits"
pass "Antigravity collector places Weekly window second"

[[ $(jq -r '.[1].percent' <<<"$limits") == "0.05" ]] ||
  fail "Antigravity collector calculates weekly used percentage" "$limits"
pass "Antigravity collector calculates weekly used percentage"

[[ $(jq -r '.[2].title' <<<"$limits") == "Claude/GPT Weekly" ]] ||
  fail "Antigravity collector includes used scoped 3P limits" "$limits"
pass "Antigravity collector includes used scoped 3P limits"

[[ $(jq -r '.[2].percent' <<<"$limits") == "0.02" ]] ||
  fail "Antigravity collector calculates 3P used percentage" "$limits"
pass "Antigravity collector calculates 3P used percentage"

[[ $(jq -r 'length' <<<"$limits") == "3" ]] ||
  fail "Antigravity collector omits unused 3P session limit" "$limits"
pass "Antigravity collector omits unused 3P session limit"

reordered=$(test_limits '{"groups": [
  {"displayName": "Claude and GPT models", "buckets": [{"window": "5h", "remainingFraction": 1.0}]},
  {"displayName": "Gemini Models", "buckets": [{"window": "weekly", "remainingFraction": 0.5}]}
]}')
[[ $(jq -c 'map({label, percent})' <<<"$reordered") == '[{"label":"Weekly (7-day)","percent":0.5}]' ]] ||
  fail "Antigravity collector finds the Gemini group wherever it is listed" "$reordered"
pass "Antigravity collector finds the Gemini group wherever it is listed"

snake=$(test_limits '{"buckets": [
  {"window": "5h", "remaining_fraction": 0.4, "reset_time": "2026-09-15T19:31:46Z"},
  {"window": "weekly", "remainingFraction": "plenty"},
  {"bucketId": "gemini-weekly", "remainingFraction": Infinity}
]}')
[[ $(jq -c 'map({label, percent, resetsAt})' <<<"$snake") == '[{"label":"Session (5-hour)","percent":0.6,"resetsAt":"2026-09-15T19:31:46+00:00"}]' ]] ||
  fail "Antigravity collector reads snake_case buckets listed without groups and skips unreadable fractions" "$snake"
pass "Antigravity collector reads snake_case buckets listed without groups and skips unreadable fractions"

# The whole record with Google's endpoints and the keyring standing in. The
# keyring answers with keyring.json, Google answers as STATE says, and each
# request's endpoint, token, and host is logged so a test can tell what was
# asked.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/secret-tool" <<'EOF'
#!/bin/bash
cat "$HOME/keyring.json" 2>/dev/null
EOF
chmod +x "$test_tmp/bin/secret-tool"
in_an_hour=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=1)).isoformat())')
an_hour_ago=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=1)).isoformat())')
reset_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=3)).isoformat())')

# The id token names the account: header.{"email":"me@example.com"}.signature
me_id_token="header.eyJlbWFpbCI6Im1lQGV4YW1wbGUuY29tIn0.signature"
other_id_token="header.eyJlbWFpbCI6Im90aGVyQGV4YW1wbGUuY29tIn0.signature"

sign_in() {
  local refresh=${4-refresh-main}
  printf '{"auth_method":"consumer","id_token":"%s","token":{"access_token":"%s","refresh_token":"%s","expiry":"%s"}}\n' \
    "${3:-$me_id_token}" "$1" "$refresh" "$2" >"$test_tmp/keyring.json"
}

collect() {
  local state=$1
  shift
  HOME="$test_tmp" AGY_DIR="$test_tmp/agy" XDG_CACHE_HOME="$test_tmp/cache" PATH="$test_tmp/bin:$PATH" \
    COLLECTOR="$COLLECTOR" RESET_AT="$reset_at" STATE="$state" ASKED="$test_tmp/asked" python3 - "$@" <<'PY'
import importlib.machinery, importlib.util, io, json, os, sys, urllib.error

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

answers = {
  "loadCodeAssist": {"paidTier": {"id": "g1-pro-tier", "name": "Google AI Pro"}},
  "retrieveUserQuotaSummary": {"groups": [{"displayName": "Gemini Models", "buckets": [
    {"window": "5h", "remainingFraction": 0.75, "resetTime": os.environ["RESET_AT"]}
  ]}]},
}
state = os.environ["STATE"]

def urlopen(request, timeout=None):
  endpoint = request.full_url.rsplit(":", 1)[1]
  with open(os.environ["ASKED"], "a") as asked:
    asked.write(f"{endpoint} {request.get_header('Authorization')} {request.full_url.split('/')[2]}\n")
  if state == "down":
    raise urllib.error.URLError("offline")
  if state in ("401", "500"):
    raise urllib.error.HTTPError(request.full_url, int(state), "No", {}, io.BytesIO())
  if state == "noquota" and endpoint == "retrieveUserQuotaSummary":
    return io.BytesIO(b'{"groups": []}')
  return io.BytesIO(json.dumps(answers[endpoint]).encode())

collector.urllib.request.urlopen = urlopen
sys.argv = ["omarchy-agent-usage-agy"] + sys.argv[1:]
collector.main()
PY
}

asked() {
  if [[ -e $test_tmp/asked ]]; then
    cat "$test_tmp/asked"
    rm -f "$test_tmp/asked"
  fi
}

sign_in token-main "$in_an_hour"
record=$(collect up --force)
[[ $(jq -c '{id, ready, tierLabel, usageStatusText, authHelpText, stale: .limitsStale, retryAdvised, percent: .limits[0].percent}' <<<"$record") == '{"id":"agy","ready":true,"tierLabel":"Pro","usageStatusText":"","authHelpText":"","stale":false,"retryAdvised":false,"percent":0.25}' ]] ||
  fail "Antigravity collector reports its plan and live limits" "$record"
(( $(jq '.limitsFetchedAt' <<<"$record") > 0 )) || fail "Antigravity collector says when the limits were fetched" "$record"
[[ $(asked | awk '{print $3}' | sort -u) == "token-main" ]] || fail "Antigravity collector asks with agy's token" "$record"
pass "Antigravity collector reports its plan and live limits"

caches=$(cd "$test_tmp/cache/omarchy/agent-usage" && ls agy-limits-*.json)
[[ $caches =~ ^agy-limits-[0-9a-f]{16}\.json$ && ! -e $test_tmp/cache/omarchy/agent-usage/agy-limits.json ]] ||
  fail "Antigravity collector caches limits per account" "$caches"
grep -q "me@example.com" <<<"$caches" && fail "Antigravity collector names its cache by a digest, not the email" "$caches"
pass "Antigravity collector caches limits per account"

# Within the probe interval a normal run reuses the answer it just got;
# --force asks again.
record=$(collect up)
[[ -z $(asked) && $(jq -c '{stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"stale":false,"percent":0.25}' ]] ||
  fail "Antigravity collector reuses a fresh answer without asking Google again" "$record"
record=$(collect up --force)
[[ $(asked | wc -l) == "2" ]] || fail "Antigravity collector asks again when forced" "$record"
pass "Antigravity collector reuses a fresh answer, and asks again when forced"

fetched=$(jq '.limitsFetchedAt' <<<"$record")
record=$(collect down --force)
[[ $(jq -c '{tierLabel, usageStatusText, stale: .limitsStale, retryAdvised, percent: .limits[0].percent}' <<<"$record") == '{"tierLabel":"Pro","usageStatusText":"","stale":true,"retryAdvised":true,"percent":0.25}' ]] ||
  fail "Antigravity collector keeps the last limits, marked stale, after a failed check" "$record"
[[ $(jq '.limitsFetchedAt' <<<"$record") == "$fetched" ]] || fail "stale Antigravity limits keep when they were fetched" "$record"
[[ $(jq -r '.authHelpText' <<<"$record") == *"Couldn't reach"* ]] || fail "Antigravity collector says the check couldn't reach Google" "$record"
pass "Antigravity collector keeps the last limits, marked stale, after a failed check"

record=$(collect 500 --force)
[[ $(jq -c '{usageStatusText, stale: .limitsStale, retryAdvised}' <<<"$record") == '{"usageStatusText":"","stale":true,"retryAdvised":false}' ]] ||
  fail "Antigravity collector advises no quick retry when Google answered with an error" "$record"
pass "Antigravity collector advises no quick retry when Google answered with an error"

record=$(collect 401 --force)
[[ $(jq -c '{usageStatusText, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"usageStatusText":"Sign-in expired","stale":true,"percent":0.25}' ]] ||
  fail "Antigravity collector reports a refused sign-in as expired" "$record"
asked >/dev/null
pass "Antigravity collector reports a refused sign-in as expired"

# A kept window whose reset has passed is back at zero, not dropped.
cache_file=$(ls "$test_tmp/cache/omarchy/agent-usage"/agy-limits-*.json)
python3 - "$cache_file" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
data["limits"][0]["resetsAt"] = "2020-01-01T00:00:00+00:00"
data["limits"].append("damaged")
json.dump(data, open(path, "w"))
PY
record=$(collect down --force)
[[ $(jq -c '.limits' <<<"$record") == '[{"label":"Session (5-hour)","title":"Session","percent":0.0,"resetsAt":""}]' ]] ||
  fail "Antigravity collector shows an elapsed kept window at zero" "$record"
asked >/dev/null
pass "Antigravity collector shows an elapsed kept window at zero"

# A lapsed access token is renewed the next time agy runs, so the kept limits
# stay up without a new sign-in; without a refresh token behind it, a new
# sign-in is needed. Neither is sent to Google.
sign_in token-main "$an_hour_ago"
record=$(collect up --force)
[[ -z $(asked) && $(jq -c '{usageStatusText, stale: .limitsStale, n: (.limits | length)}' <<<"$record") == '{"usageStatusText":"Limits paused","stale":true,"n":1}' ]] ||
  fail "Antigravity collector pauses limits while agy's access token has lapsed" "$record"
[[ $(jq -r '.authHelpText' <<<"$record") == *"signing in again is not needed"* ]] || fail "Antigravity collector says no new sign-in is needed" "$record"
pass "Antigravity collector pauses limits while agy's access token has lapsed"

sign_in token-main "$an_hour_ago" "$me_id_token" ""
record=$(collect up --force)
[[ -z $(asked) && $(jq -r '.usageStatusText' <<<"$record") == "Sign-in expired" ]] ||
  fail "Antigravity collector reports a lapsed sign-in without a refresh token as expired" "$record"
pass "Antigravity collector reports a lapsed sign-in without a refresh token as expired"

# Another account signed in here never wears the last one's limits.
sign_in token-other "$an_hour_ago" "$other_id_token"
record=$(collect down --force)
[[ $(jq -c '{limits, tierLabel, limitsFetchedAt}' <<<"$record") == '{"limits":[],"tierLabel":"","limitsFetchedAt":0}' ]] ||
  fail "Antigravity collector shows no other account's kept limits" "$record"
pass "Antigravity collector shows no other account's kept limits"

# A plan with no quota windows to report is healthy, with no meters.
sign_in token-other "$in_an_hour" "$other_id_token"
record=$(collect noquota --force)
[[ $(jq -c '{limits, tierLabel, usageStatusText, authHelpText, stale: .limitsStale}' <<<"$record") == '{"limits":[],"tierLabel":"Pro","usageStatusText":"","authHelpText":"","stale":false}' ]] ||
  fail "Antigravity collector treats a plan without quota windows as healthy" "$record"
asked >/dev/null
pass "Antigravity collector treats a plan without quota windows as healthy"

# The bearer token goes only to an https destination.
record=$(CLOUD_CODE_URL="http://evil.example" collect up --force)
[[ $(asked | awk '{print $4}' | sort -u) == "daily-cloudcode-pa.googleapis.com" ]] ||
  fail "Antigravity collector ignores a plain-http destination" "$record"
record=$(CLOUD_CODE_URL="https://mirror.example" collect up --force)
[[ $(asked | awk '{print $4}' | sort -u) == "mirror.example" ]] ||
  fail "Antigravity collector honors an https destination" "$record"
pass "Antigravity collector asks only an https destination, defaulting to Google's"

rm -rf "$test_tmp/cache"
record=$(collect down --force)
[[ $(jq -c '{limits, usageStatusText, retryAdvised}' <<<"$record") == '{"limits":[],"usageStatusText":"Antigravity limits unavailable","retryAdvised":true}' ]] ||
  fail "Antigravity collector invents no limits when it has never reached Google" "$record"
asked >/dev/null
pass "Antigravity collector invents no limits when it has never reached Google"

# A normal run reuses a scan for a few seconds; --force rescans.
mkdir -p "$test_tmp/agy"
now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo '{"timestamp":"'"$now"'","conversation_id":"c1"}' >"$test_tmp/agy/history.jsonl"
record=$(collect up --force)
echo '{"timestamp":"'"$now"'","conversation_id":"c2"}' >>"$test_tmp/agy/history.jsonl"
record=$(collect up)
[[ $(jq '.totalPrompts' <<<"$record") == "1" ]] || fail "Antigravity collector reuses a recent scan" "$record"
record=$(collect up --limits-only)
[[ $(jq '.totalPrompts' <<<"$record") == "1" ]] || fail "Antigravity collector reuses a scan on a limits-only run" "$record"
record=$(collect up --force)
[[ $(jq '.totalPrompts' <<<"$record") == "2" ]] || fail "Antigravity collector rescans when forced" "$record"
asked >/dev/null
pass "Antigravity collector reuses a recent scan, and rescans when forced"
