#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3
require_command sqlite3

COLLECTOR="$ROOT/bin/omarchy-agent-usage-agy"

# Antigravity signed in through another harness, with agy itself absent: the
# record still carries the plan and limits, asked with that harness' token.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/secret-tool" <<'EOF'
#!/bin/bash
exit 1
EOF
# omp answers `omp usage` with the report in omp-report.json, when there is
# one, and fails otherwise.
cat >"$test_tmp/bin/omp" <<'EOF'
#!/bin/bash
[[ "$*" == "usage --json --provider google-antigravity" ]] || exit 2
cat "$HOME/omp-report.json" 2>/dev/null
EOF
chmod +x "$test_tmp/bin/secret-tool" "$test_tmp/bin/omp"

in_ms() {
  python3 -c "import sys, time; print(round((time.time() + float(sys.argv[1])) * 1000))" "$1"
}

omp_login() {
  mkdir -p "$test_tmp/.omp/agent"
  rm -f "$test_tmp/.omp/agent/agent.db"
  sqlite3 "$test_tmp/.omp/agent/agent.db" \
    "CREATE TABLE auth_credentials (id INTEGER PRIMARY KEY, provider TEXT, credential_type TEXT, data TEXT, disabled_cause TEXT);
     INSERT INTO auth_credentials (provider, credential_type, data) VALUES
       ('google-antigravity', 'oauth', '{\"access\":\"$1\",\"refresh\":\"r\",\"expires\":$2,\"email\":\"$3\"}');"
}

pi_login() {
  mkdir -p "$test_tmp/.pi/agent"
  printf '{"google-antigravity":{"type":"oauth","access":"%s","refresh":"r","expires":%s,"email":"%s"}}\n' "$1" "$2" "$3" \
    >"$test_tmp/.pi/agent/auth.json"
}

# Google answers every token in ACCEPTED and refuses the rest; each request's
# token is logged so a test can tell which sign-in was asked.
collect() {
  env -u PI_CODING_AGENT_DIR -u OPENCLAW_STATE_DIR -u XDG_CONFIG_HOME -u XDG_DATA_HOME \
    HOME="$test_tmp" XDG_CACHE_HOME="$test_tmp/cache" PATH="$test_tmp/bin:$PATH" \
    COLLECTOR="$COLLECTOR" ACCEPTED="$1" ASKED="$test_tmp/asked" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, sys, urllib.error

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

answers = {
  "loadCodeAssist": {"paidTier": {"id": "g1-pro-tier", "name": "Google AI Pro"}},
  "retrieveUserQuotaSummary": {"groups": [{"displayName": "Gemini Models", "buckets": [
    {"window": "5h", "remainingFraction": 0.75, "resetTime": "2999-01-01T00:00:00Z"}
  ]}]},
}
# An account on a plan with no quota windows to report.
plans_without_quota = {
  "no-quota-token": {
    "loadCodeAssist": {"paidTier": {"id": "g1-ultra-tier", "name": "Google AI Ultra"}},
    "retrieveUserQuotaSummary": {"groups": []},
  },
}

def urlopen(request, timeout=None):
  token = request.get_header("Authorization").removeprefix("Bearer ")
  with open(os.environ["ASKED"], "a") as asked:
    asked.write(token + "\n")
  if token not in os.environ["ACCEPTED"].split():
    raise urllib.error.HTTPError(request.full_url, 403, "Forbidden", {}, io.BytesIO())
  endpoint = request.full_url.rsplit(":", 1)[1]
  return io.BytesIO(json.dumps(plans_without_quota.get(token, answers)[endpoint]).encode())

collector.urllib.request.urlopen = urlopen
sys.argv = ["omarchy-agent-usage-agy", "--force"]
collector.main()
PY
}

asked() {
  sort -u "$test_tmp/asked" | paste -sd' '
  rm -f "$test_tmp/asked"
}

omp_login omp-token "$(in_ms 3600)" me@example.com
record=$(collect omp-token)
[[ $(jq -c '{ready, tierLabel, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"ready":true,"tierLabel":"Pro","stale":false,"percent":0.25}' ]] ||
  fail "Antigravity collector reports limits from an omp sign-in without agy" "$record"
[[ $(asked) == "omp-token" ]] || fail "Antigravity collector asks Google with omp's token" "$record"
pass "Antigravity collector reports limits from an omp sign-in without agy"

pi_login pi-token "$(in_ms 7200)" me@example.com
record=$(collect "omp-token pi-token")
[[ $(asked) == "pi-token" ]] ||
  fail "Antigravity collector asks with the most recently refreshed sign-in" "$record"
pass "Antigravity collector asks with the most recently refreshed sign-in"

record=$(collect omp-token)
[[ $(asked) == "omp-token pi-token" && $(jq -c '{stale: .limitsStale, usageStatusText}' <<<"$record") == '{"stale":false,"usageStatusText":""}' ]] ||
  fail "Antigravity collector moves on from a sign-in Google refuses" "$record"
pass "Antigravity collector moves on from a sign-in Google refuses"

# The account that earned the kept limits is still signed in, so they stand
# in when a newer sign-in is refused and the rest cannot answer either.
mkdir -p "$test_tmp/.local/share/opencode" "$test_tmp/.config/opencode"
printf '{"google":{"type":"oauth","access":"newer-token","refresh":"newer|p","expires":%s}}\n' "$(in_ms 9999)" \
  >"$test_tmp/.local/share/opencode/auth.json"
echo '{"version":3,"accounts":[]}' >"$test_tmp/.config/opencode/antigravity-accounts.json"
record=$(collect "")
[[ $(jq -c '{stale: .limitsStale, usageStatusText, percent: .limits[0].percent}' <<<"$record") == '{"stale":true,"usageStatusText":"Antigravity sign-in expired","percent":0.25}' ]] ||
  fail "Antigravity collector keeps limits whose account is still signed in when every sign-in fails" "$record"
pass "Antigravity collector keeps limits whose account is still signed in when every sign-in fails"
asked >/dev/null
rm -rf "$test_tmp/.local/share/opencode" "$test_tmp/.config/opencode"

rm -rf "$test_tmp/.pi"
omp_login omp-token "$(in_ms -60)" me@example.com
record=$(collect omp-token)
[[ ! -e $test_tmp/asked ]] || fail "Antigravity collector sends no lapsed token to Google" "$(asked)"
[[ $(jq -c '{ready, stale: .limitsStale, usageStatusText, authHelpText, percent: .limits[0].percent}' <<<"$record") == '{"ready":true,"stale":true,"usageStatusText":"Antigravity sign-in expired","authHelpText":"The Antigravity sign-in omp keeps expired. Start omp to refresh it.","percent":0.25}' ]] ||
  fail "Antigravity collector keeps the last limits and names the harness whose sign-in lapsed" "$record"
pass "Antigravity collector keeps the last limits and names the harness whose sign-in lapsed"

omp_login other-token "$(in_ms -60)" other@example.com
record=$(collect "")
[[ $(jq -c '{limits, tierLabel}' <<<"$record") == '{"limits":[],"tierLabel":""}' ]] ||
  fail "Antigravity collector shows no other Google account's kept limits" "$record"
pass "Antigravity collector shows no other Google account's kept limits"

# omp refreshes its own sign-in when asked for usage, so a lapsed token in
# its database still gets live limits through `omp usage`.
cat >"$test_tmp/omp-report.json" <<'EOF'
{"reports":[{"provider":"google-antigravity","metadata":{"email":"other@example.com"},"limits":[
  {"label":"Gemini","amount":{"usedFraction":0.6},"window":{"id":"5h","resetsAt":32503680000000}},
  {"label":"Gemini","amount":{"usedFraction":0.3},"window":{"id":"weekly","resetsAt":32503680000000}},
  {"label":"Claude & GPT (shared)","amount":{"usedFraction":0.1},"window":{"id":"weekly","resetsAt":32503680000000}},
  {"label":"Claude & GPT (shared)","amount":{"usedFraction":0.1},"window":{"id":"weekly","resetsAt":32503680000000}}
]}]}
EOF
record=$(collect "")
[[ ! -e $test_tmp/asked ]] || fail "Antigravity collector sends omp's lapsed token nowhere" "$(asked)"
[[ $(jq -c '{stale: .limitsStale, usageStatusText, limits: [.limits[] | {title, percent}]}' <<<"$record") == '{"stale":false,"usageStatusText":"","limits":[{"title":"Session","percent":0.6},{"title":"Weekly","percent":0.3},{"title":"Claude/GPT Weekly","percent":0.1}]}' ]] ||
  fail "Antigravity collector takes omp's limits from omp usage" "$record"
rm "$test_tmp/omp-report.json"
pass "Antigravity collector takes omp's limits from omp usage"

# The plan label kept from an earlier check names the account that earned it.
# omp answers for a different account, which reports limits but no plan.
pi_login pi-token "$(in_ms 3600)" me@example.com
record=$(collect pi-token)
asked >/dev/null
pi_login pi-token "$(in_ms -60)" me@example.com
cmp_report='{"reports":[{"provider":"google-antigravity","metadata":{"email":"other@example.com"},"limits":[
  {"label":"Gemini","amount":{"usedFraction":0.6},"window":{"id":"5h","resetsAt":32503680000000}}
]}]}'
omp_login omp-token "$(in_ms -60)" other@example.com
echo "$cmp_report" >"$test_tmp/omp-report.json"
[[ $(jq -r '.tierLabel' <<<"$record") == "Pro" ]] ||
  fail "Antigravity collector records the plan of the account that answered" "$record"
record=$(collect "")
rm -f "$test_tmp/asked"
[[ $(jq -c '{tierLabel, percent: .limits[0].percent, usageStatusText}' <<<"$record") == '{"tierLabel":"","percent":0.6,"usageStatusText":""}' ]] ||
  fail "Antigravity collector keeps no other account's plan label" "$record"
pass "Antigravity collector keeps no other account's plan label"

# A newer account that reports a plan it has no quota windows for must not
# end up wearing the kept account's meters beside that plan.
pi_login pi-token "$(in_ms -60)" me@example.com
omp_login omp-token "$(in_ms -60)" other@example.com
rm -f "$test_tmp/omp-report.json"
pi_login pi-token "$(in_ms 3600)" me@example.com
record=$(collect pi-token)
asked >/dev/null
pi_login pi-token "$(in_ms -60)" me@example.com
mkdir -p "$test_tmp/.local/share/opencode" "$test_tmp/.config/opencode"
printf '{"google":{"type":"oauth","access":"no-quota-token","expires":%s}}\n' "$(in_ms 9999)" \
  >"$test_tmp/.local/share/opencode/auth.json"
echo '{"version":3,"accounts":[]}' >"$test_tmp/.config/opencode/antigravity-accounts.json"
record=$(collect no-quota-token)
[[ $(jq -c '{limits, tierLabel, usageStatusText}' <<<"$record") == '{"limits":[],"tierLabel":"Ultra","usageStatusText":"Antigravity limits unavailable"}' ]] ||
  fail "Antigravity collector never pairs one account's plan with another's limits" "$record"
pass "Antigravity collector never pairs one account's plan with another's limits"
rm -rf "$test_tmp/.local/share/opencode" "$test_tmp/.config/opencode" "$test_tmp/.omp" "$test_tmp/.pi/agent/auth.json"
rm -f "$test_tmp/asked"

# opencode files any Google sign-in under "google"; only the Antigravity
# plugin's accounts file makes it an Antigravity one.
rm -rf "$test_tmp/.omp" "$test_tmp/cache"
mkdir -p "$test_tmp/.local/share/opencode"
printf '{"google":{"type":"oauth","access":"opencode-token","refresh":"r|p","expires":%s}}\n' "$(in_ms 3600)" \
  >"$test_tmp/.local/share/opencode/auth.json"
record=$(collect opencode-token)
[[ $(jq -c '{ready, limits}' <<<"$record") == '{"ready":false,"limits":[]}' && ! -e $test_tmp/asked ]] ||
  fail "Antigravity collector ignores opencode's Google sign-in without the Antigravity plugin" "$record"
mkdir -p "$test_tmp/.config/opencode"
echo '{"version":3,"accounts":[]}' >"$test_tmp/.config/opencode/antigravity-accounts.json"
record=$(collect opencode-token)
[[ $(asked) == "opencode-token" && $(jq '.limits[0].percent' <<<"$record") == "0.25" ]] ||
  fail "Antigravity collector reads opencode's Antigravity plugin sign-in" "$record"
pass "Antigravity collector reads opencode's Antigravity plugin sign-in only with the plugin"

# opencode records no email for its sign-in, so a replaced sign-in has no
# email to compare: without one, the kept limits must go rather than pass
# for the new account's.
printf '{"google":{"type":"oauth","access":"switched-token","refresh":"switched|p","expires":%s}}\n' "$(in_ms 3600)" \
  >"$test_tmp/.local/share/opencode/auth.json"
record=$(collect "")
[[ $(jq -c '{limits, tierLabel, usageStatusText}' <<<"$record") == '{"limits":[],"tierLabel":"","usageStatusText":"Antigravity sign-in expired"}' ]] ||
  fail "Antigravity collector drops kept limits when the account cannot be matched" "$record"
pass "Antigravity collector drops kept limits when the account cannot be matched"

# Antigravity used through pi, omp, OpenClaw, and opencode's plugin counts in
# the local stats; Gemini through any other provider does not, and a forked
# session's copy of an answer counts once.
if command -v rg >/dev/null; then
  now=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)
  mkdir -p "$test_tmp/.omp/agent/sessions/project" "$test_tmp/.openclaw/agents/main/sessions"
  answer='{"type":"message","id":"a1","timestamp":"'$now'","message":{"role":"assistant","provider":"google-antigravity","model":"gemini-3-pro","usage":{"input":100,"output":20,"cacheRead":5,"cacheWrite":0}}}'
  printf '%s\n%s\n' "$answer" \
    '{"type":"message","id":"a2","timestamp":"'$now'","message":{"role":"assistant","provider":"google-gemini-cli","model":"gemini-3-pro","usage":{"input":999,"output":999}}}' \
    >"$test_tmp/.omp/agent/sessions/project/one.jsonl"
  printf '%s\n' "$answer" >"$test_tmp/.omp/agent/sessions/project/fork.jsonl"
  # OpenClaw's entries carry no id; two alike answers are two answers.
  openclaw='{"type":"message","timestamp":"'$now'","message":{"role":"assistant","provider":"google-antigravity","model":"gemini-3-pro","usage":{"input":1,"output":1}}}'
  printf '%s\n%s\n' "$openclaw" "$openclaw" >"$test_tmp/.openclaw/agents/main/sessions/s.jsonl"
  sqlite3 "$test_tmp/.local/share/opencode/opencode.db" \
    "CREATE TABLE message (session_id TEXT, data TEXT);
     INSERT INTO message VALUES
       ('s1', '{\"role\":\"assistant\",\"providerID\":\"google\",\"modelID\":\"antigravity-gemini-3-pro\",\"time\":{\"created\":$(in_ms 0)},\"tokens\":{\"input\":10,\"output\":5,\"reasoning\":1,\"cache\":{\"read\":2,\"write\":0}}}'),
       ('s2', '{\"role\":\"assistant\",\"providerID\":\"google\",\"modelID\":\"gemini-3-pro\",\"time\":{\"created\":$(in_ms 0)},\"tokens\":{\"input\":999,\"output\":999}}');"
  record=$(collect "")
  [[ $(jq -c '{hasLocalStats, totalPrompts, totalSessions, todayTotalTokens, models: (.modelUsage | keys)}' <<<"$record") == '{"hasLocalStats":true,"totalPrompts":4,"totalSessions":3,"todayTotalTokens":147,"models":["antigravity-gemini-3-pro","gemini-3-pro"]}' ]] ||
    fail "Antigravity collector counts usage from pi, omp, OpenClaw, and opencode's plugin" "$record"
  pass "Antigravity collector counts usage from pi, omp, OpenClaw, and opencode's plugin"
else
  skip "Antigravity collector counts usage from pi, omp, OpenClaw, and opencode's plugin (no rg)"
fi
