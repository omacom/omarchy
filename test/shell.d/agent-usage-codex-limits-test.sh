#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_STATE_HOME="$test_tmp/state"
export XDG_CACHE_HOME="$test_tmp/cache"
export XDG_DATA_HOME="$test_tmp/data"
unset CODEX_HOME CODEX_ACCESS_TOKEN

mkdir -p "$HOME/.codex/sessions" "$test_tmp/bin"

# Signs ~/.codex in as a user of a workspace, the way Codex writes it: the
# workspace as account_id, the user in the ID token's claims.
cat >"$test_tmp/login" <<'PY'
#!/usr/bin/python3
import base64, json, os, sys
claims = {"https://api.openai.com/auth": {"chatgpt_account_id": sys.argv[1], "chatgpt_user_id": sys.argv[2]}}
payload = base64.urlsafe_b64encode(json.dumps(claims).encode("utf-8", "surrogatepass")).decode().rstrip("=")
home = os.environ.get("CODEX_HOME") or os.path.expanduser("~/.codex")
with open(os.path.join(home, "auth.json"), "w") as handle:
  json.dump({"tokens": {"id_token": f"e30.{payload}.sig", "account_id": sys.argv[1]}}, handle)
PY
chmod +x "$test_tmp/login"
login() {
  "$test_tmp/login" "$@"
}
login ws-one user-a

# A stand-in app-server whose rate-limit answer CODEX_FAKE picks: limits, a
# backend error, a sign-out, or dying with or without saying why.
cat >"$test_tmp/bin/codex" <<'PY'
#!/usr/bin/python3
import json, os, sys, time
mode = os.environ.get("CODEX_FAKE", "ok")
now = int(time.time())
for line in sys.stdin:
  message = json.loads(line)
  if "id" not in message:
    continue
  if message["method"] == "account/rateLimits/read":
    if mode == "died":
      print("error sending request for url (https://chatgpt.com/backend-api/wham/usage)", file=sys.stderr)
      sys.exit(1)
    if mode == "silent":
      sys.exit(0)
    if mode == "backend":
      print(json.dumps({"id": message["id"], "error": {"code": -32603, "message": "failed to fetch codex rate limits"}}), flush=True)
      continue
    if mode == "switch":
      os.system(os.environ["CODEX_LOGIN"] + " ws-three user-c")
    if mode == "auth":
      print(json.dumps({"id": message["id"], "error": {"code": -32603, "message": "not authenticated"}}), flush=True)
      continue
    print(json.dumps({"id": message["id"], "result": {"rateLimits": {"planType": "pro",
      "primary": {"usedPercent": 55 if mode == "switch" else 40, "windowDurationMins": 300, "resetsAt": now + 3600},
      "secondary": {"usedPercent": 70, "windowDurationMins": 10080, "resetsAt": now + 2}}}}), flush=True)
    continue
  print(json.dumps({"id": message["id"], "result": {}}), flush=True)
PY
chmod +x "$test_tmp/bin/codex"

collect() {
  CODEX_FAKE="$1" CODEX_LOGIN="$test_tmp/login" PATH="$test_tmp/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --force
}

fresh=$(collect ok)
[[ $(jq -c '{limitsStale, fresh: (.limitsFetchedAt > 0), used: [.limits[].percent], tierLabel}' <<<"$fresh") == '{"limitsStale":false,"fresh":true,"used":[0.4,0.7],"tierLabel":"pro"}' ]] ||
  fail "fresh Codex limits are live and say when they were measured" "$fresh"
pass "fresh Codex limits are live and say when they were measured"
fetched_at=$(jq '.limitsFetchedAt' <<<"$fresh")

# Let the weekly window reset before the next probe fails.
sleep 3

for mode in backend died; do
  kept=$(collect "$mode")
  [[ $(jq -c --argjson at "$fetched_at" '{limitsStale, at: (.limitsFetchedAt == $at), used: [.limits[].percent * 100 | round], status: .usageStatusText, tierLabel}' <<<"$kept") == '{"limitsStale":true,"at":true,"used":[40,0],"status":"","tierLabel":"pro"}' ]] ||
    fail "a failed Codex probe ($mode) keeps the last limits, marked stale" "$kept"
  pass "a failed Codex probe ($mode) keeps the last limits, marked stale"
done

for mode in auth silent; do
  dropped=$(collect "$mode")
  [[ $(jq -c '{limitsStale, limits}' <<<"$dropped") == '{"limitsStale":true,"limits":[]}' && $(jq -r '.usageStatusText' <<<"$dropped") != "" ]] ||
    fail "a Codex sign-out ($mode) is reported, not hidden behind old limits" "$dropped"
  pass "a Codex sign-out ($mode) is reported, not hidden behind old limits"
done

for who in "ws-two user-a" "ws-one user-b"; do
  login $who
  other=$(collect backend)
  [[ $(jq -c '{limits, status: .usageStatusText}' <<<"$other") == '{"limits":[],"status":"Codex limits unavailable"}' ]] ||
    fail "a home signed in to someone else never shows the last one's limits ($who)" "$other"
done
pass "a home signed in to someone else, in another workspace or the same one, never shows the last one's limits"

# The login auth.json names is only who answers when nothing overrides it.
collect ok >/dev/null
token=$(CODEX_ACCESS_TOKEN=another collect backend)
[[ $(jq -c '.limits' <<<"$token") == '[]' ]] ||
  fail "an access token in the environment never shows auth.json's account's limits" "$token"
pass "an access token in the environment never shows auth.json's account's limits"

printf 'cli_auth_credentials_store = "keyring"\n' >"$HOME/.codex/config.toml"
keyring=$(collect backend)
[[ $(jq -c '.limits' <<<"$keyring") == '[]' ]] ||
  fail "a keyring login, which can't be told apart, keeps no limits" "$keyring"
rm "$HOME/.codex/config.toml"
pass "a keyring login, which can't be told apart, keeps no limits"

file=$(collect backend)
[[ $(jq -c '{limitsStale, used: (.limits[0].percent * 100 | round)}' <<<"$file") == '{"limitsStale":true,"used":40}' ]] ||
  fail "the file store's own account keeps its limits" "$file"
pass "the file store's own account keeps its limits"

# Signed in to someone else while the probe ran: the answer is shown, but kept
# for neither login.
switched=$(collect switch)
[[ $(jq '.limitsStale' <<<"$switched") == false ]] || fail "a probe across a login change still reports what it got" "$switched"
after=$(collect backend)
[[ $(jq -c '.limits' <<<"$after") == '[]' ]] ||
  fail "limits from a probe across a login change are kept for neither login" "$after"
login ws-one user-b
before=$(collect backend)
[[ $(jq '.limits[0].percent * 100 | round' <<<"$before") == 40 ]] ||
  fail "limits from a probe across a login change are kept for neither login" "$before"
pass "limits from a probe across a login change are kept for neither login"

login ws-one $'\xed\xa0\x80'
for auth in '{"tokens":["unexpected"]}' '{"tokens":{"account_id":"ws-one"}}' "$(cat "$HOME/.codex/auth.json")"; do
  printf '%s\n' "$auth" >"$HOME/.codex/auth.json"
  odd=$(collect backend) || fail "an auth.json of another shape still gives a record ($auth)"
  [[ $(jq -r '.usageStatusText' <<<"$odd") == "Codex limits unavailable" ]] ||
    fail "an auth.json of another shape still gives a record ($auth)" "$odd"
done
pass "an auth.json of another shape still gives a record"
