#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_CACHE_HOME="$test_tmp/cache"
unset CURSOR_API_KEY

reset_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(days=3)).strftime("%Y-%m-%dT%H:%M:%S.%fZ"))')

# A JWT whose subject names the account, as Cursor's sign-in tokens do.
jwt() {
  printf 'h.%s.s' "$(printf '{"sub":"%s"}' "$1" | base64 -w0 | tr '+/' '-_' | tr -d '=')"
}

cli_signed_in() {
  mkdir -p "$XDG_CONFIG_HOME/cursor"
  jq -n --arg token "$(jwt "$1")" '{accessToken: $token}' >"$XDG_CONFIG_HOME/cursor/auth.json"
}

# ANSWER is the dashboard's JSON reply, an HTTP status code to fail with, or
# cut/reset for a connection that breaks mid-reply. With EXPECT set, any other
# token is refused, as Cursor would refuse it.
collect() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-grokbot" python3 - <<'PY'
import http.client, importlib.machinery, importlib.util, io, os, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

def urlopen(request, timeout=None):
  assert request.full_url == collector.USAGE_URL
  answer = os.environ["ANSWER"]
  expected = os.environ.get("EXPECT")
  if expected and request.get_header("Authorization") != f"Bearer {expected}":
    answer = "401"
  if answer == "cut":
    raise http.client.IncompleteRead(b"{")
  if answer == "reset":
    raise ConnectionResetError()
  if answer.isdigit():
    raise collector.urllib.error.HTTPError(request.full_url, int(answer), "", {}, None)
  return io.BytesIO(answer.encode())

collector.urllib.request.urlopen = urlopen
sys.argv = ["omarchy-agent-usage-grokbot", "--limits-only"]
collector.main()
PY
}

record=$(ANSWER='{}' collect)
[[ $(jq -c '{id, ready, limits}' <<<"$record") == '{"id":"grokbot","ready":false,"limits":[]}' ]] ||
  fail "a machine signed in to Cursor nowhere gives an empty record" "$record"
pass "a machine signed in to Cursor nowhere gives an empty record"

cli_signed_in u-main
answer=$(jq -nc --arg at "$reset_at" '{usagePercent: 42.5, nextResetTimestampUtc: $at, hasNonZeroIncludedLimit: true, grokPlanLabel: "Pro"}')
record=$(ANSWER="$answer" collect)
[[ $(jq -c '{ready, tierLabel, stale: .limitsStale, label: .limits[0].label, percent: .limits[0].percent, help: .authHelpText}' <<<"$record") == '{"ready":true,"tierLabel":"Pro","stale":false,"label":"Weekly","percent":0.425,"help":""}' ]] ||
  fail "Grok Bot's weekly allowance comes from the Cursor sign-in" "$record"
python3 -c 'import datetime as dt, sys; d = dt.datetime.fromisoformat(sys.argv[1]) - dt.datetime.now(dt.timezone.utc); sys.exit(0 if dt.timedelta(days=2) < d < dt.timedelta(days=3) else 1)' "$(jq -r '.limits[0].resetsAt' <<<"$record")" ||
  fail "the weekly window says when it resets" "$record"
pass "Grok Bot's weekly allowance comes from the Cursor sign-in"

# Failed checks keep the last good limit, dimmed, and say why when it's auth.
record=$(ANSWER=500 collect)
[[ $(jq -c '{ready, tierLabel, stale: .limitsStale, percent: .limits[0].percent, status: .usageStatusText}' <<<"$record") == '{"ready":true,"tierLabel":"Pro","stale":true,"percent":0.425,"status":""}' ]] ||
  fail "a failed check keeps the last limit, marked stale" "$record"
record=$(ANSWER=401 collect)
[[ $(jq -c '{stale: .limitsStale, percent: .limits[0].percent, status: .usageStatusText}' <<<"$record") == '{"stale":true,"percent":0.425,"status":"Waiting for auth"}' ]] ||
  fail "a refused sign-in keeps the last limit and says so" "$record"
for broken in cut reset; do
  record=$(ANSWER=$broken collect)
  [[ $(jq -c '{stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"stale":true,"percent":0.425}' ]] ||
    fail "a connection that breaks mid-reply ($broken) keeps the last limit" "$record"
done
pass "failed checks keep the last limit, marked stale"

# A cache that can't be written never costs the live answer.
chmod a-w "$XDG_CACHE_HOME/omarchy/agent-usage"
record=$(ANSWER="$answer" collect)
chmod u+w "$XDG_CACHE_HOME/omarchy/agent-usage"
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == '{"ready":true,"stale":false,"percent":0.425}' ]] ||
  fail "an unwritable cache still gives the live limit" "$record"
pass "an unwritable cache still gives the live limit"

# Another account's limit never stands in for this one's.
cli_signed_in u-other
record=$(ANSWER=500 collect)
[[ $(jq -c '{ready, limits}' <<<"$record") == '{"ready":false,"limits":[]}' ]] ||
  fail "another account's cached limit is never shown" "$record"
pass "another account's cached limit is never shown"

# Protobuf JSON leaves out zero and false: an untouched week reads 0%, and an
# account with no included limit has no Grok Bot, so the panel skips it.
answer=$(jq -nc --arg at "$reset_at" '{nextResetTimestampUtc: $at, hasNonZeroIncludedLimit: true}')
record=$(ANSWER="$answer" collect)
[[ $(jq -c '.limits[0] | {label, percent}' <<<"$record") == '{"label":"Weekly","percent":0.0}' ]] ||
  fail "an untouched week reads as 0%" "$record"
record=$(ANSWER='{"usagePercent": 10}' collect)
[[ $(jq -c '{ready, limits}' <<<"$record") == '{"ready":false,"limits":[]}' ]] ||
  fail "a Cursor account without Grok Bot gives an empty record" "$record"
pass "an untouched week reads 0%, and no allowance means no Grok Bot"

# A limit with no known end shows while live, but is never kept through a
# failed check, where it could stand for a week long gone.
cli_signed_in u-no-reset
record=$(ANSWER='{"usagePercent": 5, "hasNonZeroIncludedLimit": true}' collect)
[[ $(jq -c '{ready, percent: .limits[0].percent, resetsAt: .limits[0].resetsAt}' <<<"$record") == '{"ready":true,"percent":0.05,"resetsAt":""}' ]] ||
  fail "a limit with no known reset still shows while live" "$record"
record=$(ANSWER=500 collect)
[[ $(jq -c '{ready, limits}' <<<"$record") == '{"ready":false,"limits":[]}' ]] ||
  fail "a limit with no known reset is not kept through a failed check" "$record"
pass "a limit with no known reset is never kept through a failed check"

# The same account the Cursor collector reads: an exported key, then the CLI's
# sign-in, then the editor's, with all three present and each asked with its
# own token.
cli_signed_in p-cli
state_db="$XDG_CONFIG_HOME/Cursor/User/globalStorage/state.vscdb"
mkdir -p "$(dirname "$state_db")"
python3 - "$state_db" "$(jwt p-editor)" <<'PY'
import sqlite3, sys
conn = sqlite3.connect(sys.argv[1])
conn.execute("CREATE TABLE ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB)")
conn.execute("INSERT INTO ItemTable VALUES ('cursorAuth/accessToken', ?)", (sys.argv[2],))
conn.commit()
PY
answer=$(jq -nc --arg at "$reset_at" '{usagePercent: 7, nextResetTimestampUtc: $at, hasNonZeroIncludedLimit: true}')
live='{"ready":true,"stale":false,"percent":0.07}'
record=$(CURSOR_API_KEY="$(jwt p-key)" EXPECT="$(jwt p-key)" ANSWER="$answer" collect)
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == "$live" ]] ||
  fail "an exported CURSOR_API_KEY wins over both sign-ins" "$record"
record=$(EXPECT="$(jwt p-cli)" ANSWER="$answer" collect)
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == "$live" ]] ||
  fail "the Cursor CLI's sign-in wins over the editor's" "$record"
rm -f "$XDG_CONFIG_HOME/cursor/auth.json"
record=$(EXPECT="$(jwt p-editor)" ANSWER="$answer" collect)
[[ $(jq -c '{ready, stale: .limitsStale, percent: .limits[0].percent}' <<<"$record") == "$live" ]] ||
  fail "the Cursor editor's sign-in stands in for the CLI's" "$record"
pass "the sign-in is the one the Cursor collector reads, in the same order"
