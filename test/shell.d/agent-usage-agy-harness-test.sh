#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

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

sqlite() {
  python3 - "$@" <<'PY'
import sqlite3, sys
db = sqlite3.connect(sys.argv[1])
db.executescript(sys.argv[2])
db.commit()
PY
}

omp_login() {
  mkdir -p "$test_tmp/.omp/agent"
  rm -f "$test_tmp/.omp/agent/agent.db"
  sqlite "$test_tmp/.omp/agent/agent.db" \
    "CREATE TABLE auth_credentials (id INTEGER PRIMARY KEY, provider TEXT, credential_type TEXT, data TEXT, disabled_cause TEXT);
     INSERT INTO auth_credentials (provider, credential_type, data) VALUES
       ('google-antigravity', 'oauth', '{\"access\":\"$1\",\"refresh\":\"r\",\"expires\":$2,\"email\":\"$3\"}');
     INSERT INTO auth_credentials (provider, credential_type, data, disabled_cause) VALUES
       ('google-antigravity', 'oauth', '{\"access\":\"disabled-token\",\"refresh\":\"r\",\"expires\":$(in_ms 99999),\"email\":\"$3\"}', 'revoked');"
}

pi_login() {
  mkdir -p "${PI_DIR:-$test_tmp/.pi/agent}"
  printf '{"google-antigravity":{"type":"oauth","access":"%s","refresh":"r","expires":%s,"email":"%s"}}\n' "$1" "$2" "$3" \
    >"${PI_DIR:-$test_tmp/.pi/agent}/auth.json"
}

# Google answers every token in ACCEPTED and refuses the rest; each request's
# token is logged so a test can tell which sign-in was asked.
collect() {
  env -u OPENCLAW_STATE_DIR -u XDG_CONFIG_HOME -u XDG_DATA_HOME -u CLOUD_CODE_URL \
    HOME="$test_tmp" XDG_CACHE_HOME="$test_tmp/cache" PATH="$test_tmp/bin:$PATH" \
    PI_CODING_AGENT_DIR="${PI_DIR:-}" COLLECTOR="$COLLECTOR" ACCEPTED="$1" ASKED="$test_tmp/asked" python3 - <<'PY'
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

def urlopen(request, timeout=None):
  token = request.get_header("Authorization").removeprefix("Bearer ")
  with open(os.environ["ASKED"], "a") as asked:
    asked.write(token + "\n")
  if token not in os.environ["ACCEPTED"].split():
    raise urllib.error.HTTPError(request.full_url, 403, "Forbidden", {}, io.BytesIO())
  return io.BytesIO(json.dumps(answers[request.full_url.rsplit(":", 1)[1]]).encode())

collector.urllib.request.urlopen = urlopen
sys.argv = ["omarchy-agent-usage-agy", "--force"]
collector.main()
PY
}

asked() {
  if [[ -e $test_tmp/asked ]]; then
    sort -u "$test_tmp/asked" | paste -sd' '
    rm -f "$test_tmp/asked"
  fi
}

# Every store the collector reads, so a test can tell none was written.
stores() {
  find "$test_tmp/.omp" "$test_tmp/.pi" "$test_tmp/.local/share/opencode" "$test_tmp/.gemini" "$test_tmp/pi-elsewhere" \
    -type f -exec md5sum {} + 2>/dev/null | sort
}

omp_login omp-token "$(in_ms 3600)" me@example.com
record=$(collect omp-token)
[[ $(jq -c '{ready, tierLabel, usageStatusText, authHelpText, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"ready":true,"tierLabel":"Pro","usageStatusText":"","authHelpText":"","stale":false,"percent":0.25}' ]] ||
  fail "Antigravity collector reports limits from an omp sign-in without agy" "$record"
[[ $(asked) == "omp-token" ]] || fail "Antigravity collector asks Google with omp's token, never a disabled one" "$record"
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

record=$(collect "")
[[ $(jq -c '{usageStatusText, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"usageStatusText":"Sign-in expired","stale":true,"percent":0.25}' ]] ||
  fail "Antigravity collector reports every sign-in refused as expired, keeping the account's limits" "$record"
[[ $(jq -r '.authHelpText' <<<"$record") == "Google refused the Antigravity sign-in pi keeps. Start pi to sign in again." ]] ||
  fail "Antigravity collector names the harness whose sign-in was refused" "$record"
asked >/dev/null
pass "Antigravity collector reports every sign-in refused as expired, keeping the account's limits"

# A lapsed token is renewed the next time its harness runs, so the limits are
# paused, not signed out, and the token goes nowhere.
rm -rf "$test_tmp/.pi"
omp_login omp-token "$(in_ms -60)" me@example.com
before=$(stores)
record=$(collect omp-token)
[[ -z $(asked) ]] || fail "Antigravity collector sends no lapsed token to Google" "$record"
[[ $(jq -c '{ready, stale: .limitsStale, usageStatusText, percent: .limits[0].percent}' <<<"$record") == '{"ready":true,"stale":true,"usageStatusText":"Limits paused","percent":0.25}' ]] ||
  fail "Antigravity collector keeps the last limits while omp's token has lapsed" "$record"
[[ $(jq -r '.authHelpText' <<<"$record") == *"Start omp to refresh it; signing in again is not needed." ]] ||
  fail "Antigravity collector names the harness whose token lapsed" "$record"
[[ $(stores) == "$before" ]] || fail "Antigravity collector never writes omp's store"
pass "Antigravity collector keeps the last limits while omp's token has lapsed"

omp_login other-token "$(in_ms -60)" other@example.com
record=$(collect "")
[[ $(jq -c '{limits, tierLabel}' <<<"$record") == '{"limits":[],"tierLabel":""}' ]] ||
  fail "Antigravity collector shows no other Google account's kept limits" "$record"
pass "Antigravity collector shows no other Google account's kept limits"

# omp renews its own sign-in when asked for usage, so a lapsed token in its
# database still gets live limits through `omp usage`.
cat >"$test_tmp/omp-report.json" <<'EOF'
{"reports":[{"provider":"google-antigravity","metadata":{"email":"other@example.com"},"limits":[
  {"label":"Gemini","amount":{"usedFraction":0.6},"window":{"id":"5h","resetsAt":32503680000000}},
  {"label":"Gemini","amount":{"usedFraction":0.3},"window":{"id":"weekly","resetsAt":32503680000000}},
  {"label":"Claude & GPT (shared)","amount":{"usedFraction":0.1},"window":{"id":"weekly","resetsAt":32503680000000}},
  {"label":"Claude & GPT (shared)","amount":{"usedFraction":0.1},"window":{"id":"weekly","resetsAt":32503680000000}},
  {"label":"Gemini","amount":{"usedFraction":"lots"},"window":{"id":"daily"}}
]}]}
EOF
record=$(collect "")
[[ -z $(asked) ]] || fail "Antigravity collector sends omp's lapsed token nowhere" "$record"
[[ $(jq -c '{stale: .limitsStale, usageStatusText, authHelpText, limits: [.limits[] | {title, percent}]}' <<<"$record") == '{"stale":false,"usageStatusText":"","authHelpText":"","limits":[{"title":"Session","percent":0.6},{"title":"Weekly","percent":0.3},{"title":"Claude/GPT Weekly","percent":0.1}]}' ]] ||
  fail "Antigravity collector takes omp's limits from omp usage" "$record"
rm "$test_tmp/omp-report.json"
pass "Antigravity collector takes omp's limits from omp usage"
rm -rf "$test_tmp/.omp" "$test_tmp/cache"

# opencode files any Google sign-in under "google"; only the Antigravity
# plugin's accounts file makes it an Antigravity one.
mkdir -p "$test_tmp/.local/share/opencode"
printf '{"google":{"type":"oauth","access":"opencode-token","refresh":"r|p","expires":%s}}\n' "$(in_ms 3600)" \
  >"$test_tmp/.local/share/opencode/auth.json"
record=$(collect opencode-token)
[[ $(jq -c '{ready, limits}' <<<"$record") == '{"ready":false,"limits":[]}' && -z $(asked) ]] ||
  fail "Antigravity collector ignores opencode's Google sign-in without the Antigravity plugin" "$record"
mkdir -p "$test_tmp/.config/opencode"
echo '{"version":3,"accounts":[]}' >"$test_tmp/.config/opencode/antigravity-accounts.json"
record=$(collect opencode-token)
[[ $(asked) == "opencode-token" && $(jq '.limits[0].percent' <<<"$record") == "0.25" ]] ||
  fail "Antigravity collector reads opencode's Antigravity plugin sign-in" "$record"
pass "Antigravity collector reads opencode's Antigravity plugin sign-in only with the plugin"

# opencode records no email for its sign-in, so a replaced sign-in is told
# apart by its refresh token: the kept limits go rather than pass for the
# new account's.
printf '{"google":{"type":"oauth","access":"switched-token","refresh":"switched|p","expires":%s}}\n' "$(in_ms 3600)" \
  >"$test_tmp/.local/share/opencode/auth.json"
record=$(collect "")
[[ $(jq -c '{limits, tierLabel, usageStatusText}' <<<"$record") == '{"limits":[],"tierLabel":"","usageStatusText":"Sign-in expired"}' ]] ||
  fail "Antigravity collector drops kept limits when the account cannot be matched" "$record"
asked >/dev/null
pass "Antigravity collector drops kept limits when the account cannot be matched"
rm -rf "$test_tmp/.local/share/opencode" "$test_tmp/.config/opencode"

# Without a keyring, agy keeps its sign-in in a file under its home.
mkdir -p "$test_tmp/.gemini/antigravity-cli"
printf '{"token":{"access_token":"agy-file-token","refresh_token":"agy-refresh","expiry":"2999-01-01T00:00:00Z"}}\n' \
  >"$test_tmp/.gemini/antigravity-cli/antigravity-oauth-token"
record=$(collect agy-file-token)
[[ $(asked) == "agy-file-token" && $(jq '.limits[0].percent' <<<"$record") == "0.25" ]] ||
  fail "Antigravity collector reads agy's sign-in file when there is no keyring" "$record"
pass "Antigravity collector reads agy's sign-in file when there is no keyring"
rm -rf "$test_tmp/.gemini"

# PI_CODING_AGENT_DIR moves pi's sign-in.
PI_DIR="$test_tmp/pi-elsewhere" pi_login moved-token "$(in_ms 3600)" me@example.com
before=$(stores)
record=$(PI_DIR="$test_tmp/pi-elsewhere" collect moved-token)
[[ $(asked) == "moved-token" && $(jq '.limits[0].percent' <<<"$record") == "0.25" ]] ||
  fail "Antigravity collector reads pi's sign-in where PI_CODING_AGENT_DIR puts it" "$record"
[[ $(stores) == "$before" ]] || fail "Antigravity collector never writes pi's store"
pass "Antigravity collector reads pi's sign-in where PI_CODING_AGENT_DIR puts it"

# Antigravity used through pi, omp (and its profiles), OpenClaw, and
# opencode's plugin counts in the local stats; Gemini through any other
# provider does not, and a forked session's copy of an answer counts once.
if command -v rg >/dev/null; then
  rm -rf "$test_tmp/.pi" "$test_tmp/.omp" "$test_tmp/pi-elsewhere" "$test_tmp/cache"
  now=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)
  # The home is a git checkout that ignores everything, as dotfiles setups do.
  printf '*\n' >"$test_tmp/.gitignore"
  mkdir -p "$test_tmp/.git" "$test_tmp/.omp/agent/sessions/project" "$test_tmp/.omp/profiles/work/agent/sessions" \
    "$test_tmp/.openclaw/agents/main/sessions" "$test_tmp/pi-elsewhere/sessions" "$test_tmp/.local/share/opencode"
  answer='{"type":"message","id":"a1","timestamp":"'$now'","message":{"role":"assistant","provider":"google-antigravity","model":"gemini-3-pro","usage":{"input":100,"output":20,"cacheRead":5,"cacheWrite":0}}}'
  printf '%s\n%s\n' "$answer" \
    '{"type":"message","id":"a2","timestamp":"'$now'","message":{"role":"assistant","provider":"google-gemini-cli","model":"gemini-3-pro","usage":{"input":999,"output":999}}}' \
    >"$test_tmp/.omp/agent/sessions/project/one.jsonl"
  printf '%s\n' "$answer" >"$test_tmp/.omp/agent/sessions/project/fork.jsonl"
  # A profile's sessions count, an answer that keeps only a total among
  # them; one with an unreadable time skips only itself, as it does in every
  # collector reading pi.
  printf '%s\n%s\n' '{"type":"message","id":"p1","timestamp":"0001-01-01T00:00:00Z","message":{"role":"assistant","provider":"google-antigravity","model":"gemini-3-pro","usage":{"input":"many","totalTokens":30}}}' \
    '{"type":"message","id":"p2","timestamp":"'$now'","message":{"role":"assistant","provider":"google-antigravity","model":"gemini-3-pro","usage":{"input":"many","totalTokens":30}}}' \
    >"$test_tmp/.omp/profiles/work/agent/sessions/s.jsonl"
  printf '%s\n' '{"type":"message","id":"m1","timestamp":"'$now'","message":{"role":"assistant","provider":"google-antigravity","model":"gemini-3-pro","usage":{"input":3,"output":1}}}' \
    >"$test_tmp/pi-elsewhere/sessions/s.jsonl"
  # OpenClaw's entries carry no id; two alike answers are two answers.
  openclaw='{"type":"message","timestamp":"'$now'","message":{"role":"assistant","provider":"google-antigravity","model":"gemini-3-pro","usage":{"input":1,"output":1}}}'
  printf '%s\n%s\n' "$openclaw" "$openclaw" >"$test_tmp/.openclaw/agents/main/sessions/s.jsonl"
  sqlite "$test_tmp/.local/share/opencode/opencode.db" \
    "CREATE TABLE message (session_id TEXT, data TEXT);
     CREATE TABLE session_message (id TEXT, session_id TEXT, data TEXT, type TEXT);
     INSERT INTO message VALUES
       ('s1', '{\"role\":\"assistant\",\"providerID\":\"google\",\"modelID\":\"antigravity-gemini-3-pro\",\"time\":{\"created\":$(in_ms 0)},\"tokens\":{\"input\":10,\"output\":5,\"reasoning\":1,\"cache\":{\"read\":2,\"write\":0}}}'),
       ('s2', '{\"role\":\"assistant\",\"providerID\":\"google\",\"modelID\":\"gemini-3-pro\",\"time\":{\"created\":$(in_ms 0)},\"tokens\":{\"input\":999,\"output\":999}}'),
       ('s3', '{\"role\":\"user\",\"providerID\":\"google\",\"modelID\":\"antigravity-gemini-3-pro\",\"tokens\":{\"input\":999}}');
     INSERT INTO session_message VALUES
       ('m4', 's4', '{\"model\":{\"providerID\":\"google\",\"id\":\"antigravity-gemini-3-pro\"},\"time\":{\"created\":$(in_ms 0)},\"tokens\":{\"input\":4,\"output\":\"x\"}}', 'assistant');"
  record=$(PI_DIR="$test_tmp/pi-elsewhere" collect "")
  asked >/dev/null
  [[ $(jq -c '{ready, hasLocalStats, totalPrompts, totalSessions, todayPrompts, todayTotalTokens, models: (.modelUsage | keys)}' <<<"$record") == '{"ready":true,"hasLocalStats":true,"totalPrompts":7,"totalSessions":6,"todayPrompts":7,"todayTotalTokens":185,"models":["antigravity-gemini-3-pro","gemini-3-pro"]}' ]] ||
    fail "Antigravity collector counts usage from pi, omp, OpenClaw, and opencode's plugin" "$record"
  [[ $(jq -c '.modelUsage["gemini-3-pro"]' <<<"$record") == '{"inputTokens":135,"outputTokens":23,"cacheReadInputTokens":5,"cacheCreationInputTokens":0}' ]] ||
    fail "Antigravity collector counts each harness answer's tokens once" "$record"
  [[ $(jq -r '.usageStatusText' <<<"$record") == "Waiting for auth" ]] ||
    fail "Antigravity collector in use only through local stats waits for a sign-in" "$record"
  pass "Antigravity collector counts usage from pi, omp, OpenClaw, and opencode's plugin"

  # A migrated message sits in both opencode stores under the same id, and
  # counts once.
  rm "$test_tmp/.local/share/opencode/opencode.db"
  sqlite "$test_tmp/.local/share/opencode/opencode.db" \
    "CREATE TABLE message (id TEXT, session_id TEXT, data TEXT);
     CREATE TABLE session_message (id TEXT, session_id TEXT, data TEXT, type TEXT);
     INSERT INTO message VALUES
       ('m1', 's1', '{\"role\":\"assistant\",\"providerID\":\"google\",\"modelID\":\"antigravity-gemini-3-pro\",\"time\":{\"created\":$(in_ms 0)},\"tokens\":{\"input\":10,\"output\":5,\"reasoning\":1,\"cache\":{\"read\":2,\"write\":0}}}');
     INSERT INTO session_message VALUES
       ('m1', 's1', '{\"model\":{\"providerID\":\"google\",\"id\":\"antigravity-gemini-3-pro\"},\"time\":{\"created\":$(in_ms 0)},\"tokens\":{\"input\":10,\"output\":5,\"reasoning\":1,\"cache\":{\"read\":2,\"write\":0}}}', 'assistant'),
       ('m2', 's2', '{\"model\":{\"providerID\":\"google\",\"id\":\"antigravity-gemini-3-pro\"},\"time\":{\"created\":$(in_ms 0)},\"tokens\":{\"input\":4,\"output\":\"x\"}}', 'assistant');"
  record=$(PI_DIR="$test_tmp/pi-elsewhere" collect "")
  asked >/dev/null
  [[ $(jq -c '{totalPrompts, totalSessions, todayTotalTokens, opencode: .modelUsage["antigravity-gemini-3-pro"].inputTokens}' <<<"$record") == '{"totalPrompts":7,"totalSessions":6,"todayTotalTokens":185,"opencode":14}' ]] ||
    fail "Antigravity collector counts a message in both opencode stores once" "$record"
  pass "Antigravity collector counts a message in both opencode stores once"

  # rg still prints the matches it could read when a session file is
  # unreadable, and only its exit status tells; that partial scan isn't
  # cached for a later --limits-only run to reuse.
  if (( EUID != 0 )); then
    rm -rf "$test_tmp/cache"
    printf '%s\n' "$answer" >"$test_tmp/.omp/agent/sessions/project/locked.jsonl"
    chmod 000 "$test_tmp/.omp/agent/sessions/project/locked.jsonl"
    record=$(PI_DIR="$test_tmp/pi-elsewhere" collect "")
    asked >/dev/null
    scans=$(compgen -G "$test_tmp/cache/omarchy/agent-usage/agy-scan-*.json" || true)
    [[ -z $scans && $(jq '.totalPrompts' <<<"$record") == "7" ]] ||
      fail "Antigravity collector doesn't cache a scan rg couldn't finish" "$scans $record"
    chmod 600 "$test_tmp/.omp/agent/sessions/project/locked.jsonl"
    record=$(PI_DIR="$test_tmp/pi-elsewhere" collect "")
    asked >/dev/null
    [[ -n $(compgen -G "$test_tmp/cache/omarchy/agent-usage/agy-scan-*.json") ]] ||
      fail "Antigravity collector caches a scan that read every session" "$record"
    rm -f "$test_tmp/.omp/agent/sessions/project/locked.jsonl"
    pass "Antigravity collector doesn't cache a scan rg couldn't finish"
  fi
else
  skip "Antigravity collector counts usage from pi, omp, OpenClaw, and opencode's plugin (no rg)"
fi
