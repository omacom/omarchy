#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT

HOME="$SCRATCH" XDG_CACHE_HOME="$SCRATCH/.cache" python3 - "${1:-$ROOT/bin/omarchy-agent-usage-codex}" <<'PY'
import json
import os
import runpy
import sys
from pathlib import Path

collector = sys.argv[1]
home = Path.home()
codex_home = home / ".codex"
codex_home.mkdir()
(codex_home / "auth.json").write_text("{}")
bin_dir = home / "bin"
bin_dir.mkdir()
stub = bin_dir / "codex"
stub.write_text("#!" + sys.executable + "\n" + '''
import json
import os
import sys
from pathlib import Path

for line in sys.stdin:
  request = json.loads(line)
  method = request["method"]
  if "id" not in request:
    continue
  if method == "account/read":
    with Path(os.environ["RPC_CALLS"]).open("a") as log:
      log.write(method + "\\n")
    reply = {"account": {"planType": "plus"}}
  elif method == "account/rateLimits/read":
    reply = json.loads(os.environ["RPC_LIMITS"])
  else:
    reply = {}
  print(json.dumps({"id": request["id"], "result": reply}), flush=True)
''')
stub.chmod(0o755)
calls = home / "calls"
os.environ.update(PATH=str(bin_dir) + os.pathsep + os.environ["PATH"],
                  CODEX_HOME=str(codex_home), RPC_CALLS=str(calls))


def window(percent, minutes=300):
  return {"usedPercent": percent, "windowDurationMins": minutes}


def check(name, payload, expected, plan="pro", account_read=False, reset_credits=None):
  calls.write_text("")
  os.environ["RPC_LIMITS"] = json.dumps(payload)
  loaded = runpy.run_path(collector, run_name="limits_test")
  record = loaded["fetch_codex_rpc"](codex_home)
  assert record["usageStatusText"] == "", (name, record)
  assert record["authHelpText"] == "", (name, record)
  assert record["tierLabel"] == plan, (name, record)
  assert record["limits"] == expected, (name, record)
  assert bool(calls.read_text()) == account_read, (name, calls.read_text())
  assert record.get("resetCredits") == reset_credits, (name, record)
  print("ok - " + name)


def entry(percent, label="5h window", title=None):
  result = {"label": label, "percent": percent / 100, "resetsAt": ""}
  if title:
    result["title"] = title
  return result


legacy = {"planType": "pro", "primary": window(12)}
check("legacy single-bucket limits keep their display shape", {"rateLimits": legacy}, [entry(12)])
check("map-only limits supply both windows and the plan", {
  "rateLimitsByLimitId": {"codex": {"planType": "pro", "primary": window(25),
                                    "secondary": window(42, 10080)}}
}, [entry(25), entry(42, "Weekly (7-day)")])
check("multi-bucket limits supersede the legacy view without duplicates", {
  "rateLimits": legacy,
  "rateLimitsByLimitId": {"codex": {"planType": "pro", "primary": window(36)}}
}, [entry(36)])
check("named buckets are titled for their model and window, general Codex limits first", {
  "rateLimits": {"planType": "plus", "primary": window(99)},
  "rateLimitsByLimitId": {
    "codex_other": {"planType": "plus", "limitName": "Other model", "primary": window(80, 60)},
    "codex": {"planType": "pro", "primary": window(25)}}
}, [entry(25), entry(80, "1h window", "Other model Session")])
check("a single named bucket keeps its model label", {
  "rateLimitsByLimitId": {"codex_other": {"planType": "pro", "limitName": "Other model",
                                          "primary": window(80)}}
}, [entry(80, title="Other model Session")])
check("unnamed model buckets are titled with their identifiers", {
  "rateLimitsByLimitId": {"codex": legacy, "codex_other": {"primary": window(80)}}
}, [entry(12), entry(80, title="codex_other Session")])
for unavailable in (None, {}, {"codex": None}, []):
  check("unavailable multi-bucket view falls back to legacy: " + repr(unavailable), {
    "rateLimits": legacy, "rateLimitsByLimitId": unavailable
  }, [entry(12)])
check("invalid map entries do not hide valid buckets", {
  "rateLimitsByLimitId": {"invalid": None, "codex": legacy}
}, [entry(12)])
check("legacy plan metadata is retained when map buckets omit it", {
  "rateLimits": legacy, "rateLimitsByLimitId": {"codex": {"primary": window(33)}}
}, [entry(33)])
check("account metadata remains an optional plan fallback", {
  "rateLimitsByLimitId": {"codex": {"primary": window(33)}}
}, [entry(33)], plan="plus", account_read=True)
check("malformed legacy metadata does not erase valid map limits", {
  "rateLimits": [], "rateLimitsByLimitId": {"codex": {"primary": window(33)}}
}, [entry(33)], plan="plus", account_read=True)
check("a weekly model bucket attaches to the weekly window", {
  "rateLimitsByLimitId": {"codex": legacy, "codex_spark": {"limitName": "Spark", "secondary": window(30, 10080)}}
}, [entry(12), entry(30, "Weekly (7-day)", "Spark Weekly")])
check("an untrusted percentage or reset time costs only that window or field", {
  "rateLimits": {"planType": "pro", "primary": {"usedPercent": "lots", "windowDurationMins": 300},
                 "secondary": {"usedPercent": 250, "windowDurationMins": 10080, "resetsAt": -5}}
}, [entry(100, "Weekly (7-day)")])
check("multi-bucket limits retain earned reset credits", {
  "rateLimitsByLimitId": {"codex": legacy},
  "rateLimitResetCredits": {"credits": [{"status": "available", "expiresAt": 1900000000}]}
}, [entry(12)], reset_credits={"available": 1, "nextExpiresAt": "2030-03-17T17:46:40+00:00"})
PY

require_command jq

test_tmp="$SCRATCH/probe"
mkdir -p "$test_tmp"
export HOME="$test_tmp/home"
export XDG_STATE_HOME="$test_tmp/state"
export XDG_CACHE_HOME="$test_tmp/cache"
export XDG_DATA_HOME="$test_tmp/data"
unset CODEX_HOME CODEX_ACCESS_TOKEN OPENCODE_DB PI_CODING_AGENT_DIR PI_CODING_AGENT_SESSION_DIR

# A scratch copy of the collector with its 8s RPC timeout shortened, so a
# stalled app-server gives up quickly.
collector="$test_tmp/omarchy-agent-usage-codex"
sed 's/timeout=8/timeout=0.5/g' "$ROOT/bin/omarchy-agent-usage-codex" >"$collector"
chmod +x "$collector"

mkdir -p "$test_tmp/bin" "$test_tmp/empty-bin"

# A machine that never ran Codex prints an empty record the panel skips.
unused=$(PATH="$test_tmp/empty-bin:/usr/bin:/bin" "$collector" --force)
[[ $(jq -c '{ready, limits, limitsStale, limitsFetchedAt, totalPrompts, todayTotalTokens, recentDays: (.recentDays | length), modelUsage, retry: (.retryAdvised // false), status: .usageStatusText, help: .authHelpText}' <<<"$unused") == '{"ready":false,"limits":[],"limitsStale":false,"limitsFetchedAt":0,"totalPrompts":0,"todayTotalTokens":0,"recentDays":7,"modelUsage":{},"retry":false,"status":"","help":""}' ]] ||
  fail "a machine that never ran Codex prints an empty record" "$unused"
pass "a machine that never ran Codex prints an empty record"

mkdir -p "$HOME/.codex/sessions"

# A Codex home puts Codex in use, so a missing CLI is then worth saying.
missing=$(PATH="$test_tmp/empty-bin:/usr/bin:/bin" "$collector" --force)
[[ $(jq -c '{status: .usageStatusText, help: .authHelpText}' <<<"$missing") == '{"status":"Codex limits unavailable","help":"codex not found in PATH"}' ]] ||
  fail "a Codex home without the CLI says the CLI is missing" "$missing"
pass "a Codex home without the CLI says the CLI is missing"

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
# backend error, a sign-out, dying with or without saying why, or never
# answering. Every start is logged, so a reused probe can be told apart.
cat >"$test_tmp/bin/codex" <<'PY'
#!/usr/bin/python3
import json, os, sys, time
mode = os.environ.get("CODEX_FAKE", "ok")
with open(os.environ["CODEX_STARTS"], "a") as log:
  log.write(mode + "\n")
now = int(time.time())
for line in sys.stdin:
  message = json.loads(line)
  if "id" not in message:
    continue
  if message["method"] == "account/rateLimits/read":
    if mode == "died":
      print("error sending request for url (https://chatgpt.com/backend-api/wham/usage)", file=sys.stderr)
      sys.exit(1)
    if mode == "crashed":
      print("thread 'main' panicked at config.rs: unexpected argument", file=sys.stderr)
      sys.exit(1)
    if mode == "silent":
      sys.exit(0)
    if mode == "stall":
      time.sleep(5)
      continue
    if mode == "backend":
      print(json.dumps({"id": message["id"], "error": {"code": -32603, "message": "failed to fetch codex rate limits"}}), flush=True)
      continue
    if mode == "empty":
      print(json.dumps({"id": message["id"], "result": {"rateLimits": None, "rateLimitsByLimitId": {}}}), flush=True)
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
export CODEX_STARTS="$test_tmp/starts"

collect() {
  local mode=$1
  shift
  CODEX_FAKE="$mode" CODEX_LOGIN="$test_tmp/login" PATH="$test_tmp/bin:$PATH" "$collector" "${@---force}"
}

starts() {
  wc -l <"$CODEX_STARTS" 2>/dev/null || echo 0
}

fresh=$(collect ok)
[[ $(jq -c '{ready, limitsStale, fresh: (.limitsFetchedAt > 0), used: [.limits[].percent], tierLabel, usageStatusText, authHelpText}' <<<"$fresh") == '{"ready":true,"limitsStale":false,"fresh":true,"used":[0.4,0.7],"tierLabel":"pro","usageStatusText":"","authHelpText":""}' ]] ||
  fail "fresh Codex limits are live and say when they were measured" "$fresh"
pass "fresh Codex limits are live and say when they were measured"
fetched_at=$(jq '.limitsFetchedAt' <<<"$fresh")

# A panel opened again within the probe interval reuses the answer rather than
# starting another app-server; a person pressing refresh does not.
before=$(starts)
reused=$(collect backend --limits-only)
[[ $(starts) == "$before" ]] || fail "a Codex probe this recent is reused" "$(cat "$CODEX_STARTS")"
[[ $(jq -c --argjson at "$fetched_at" '{limitsStale, at: (.limitsFetchedAt == $at), used: [.limits[].percent], tierLabel, authHelpText}' <<<"$reused") == '{"limitsStale":false,"at":true,"used":[0.4,0.7],"tierLabel":"pro","authHelpText":""}' ]] ||
  fail "a reused Codex probe reads as current" "$reused"
collect ok >/dev/null
[[ $(starts) == $((before + 1)) ]] || fail "--force probes Codex past the reuse window" "$(cat "$CODEX_STARTS")"
pass "a recent Codex probe is reused, and --force probes again"
fetched_at=$(jq '.fetchedAtMs' <"$(ls "$XDG_CACHE_HOME"/omarchy/agent-usage/codex-limits-*.json)")

# Let the weekly window reset before the next probe fails.
sleep 3

for mode in backend died crashed empty; do
  kept=$(collect "$mode")
  [[ $(jq -c --argjson at "$fetched_at" '{limitsStale, at: (.limitsFetchedAt == $at), used: [.limits[].percent * 100 | round], resets: [.limits[].resetsAt == ""], status: .usageStatusText, tierLabel}' <<<"$kept") == '{"limitsStale":true,"at":true,"used":[40,0],"resets":[false,true],"status":"","tierLabel":"pro"}' ]] ||
    fail "a failed Codex probe ($mode) keeps the last limits, stale, with an elapsed window at zero" "$kept"
  [[ $(jq -r '.authHelpText' <<<"$kept") != "" ]] || fail "a failed Codex probe ($mode) says what went wrong" "$kept"
done
pass "a failed Codex probe keeps the last limits, stale, with an elapsed window at zero"

# Only a network that isn't there yet asks the panel to retry soon: a stalled
# app-server, or one that died unable to reach OpenAI. A refusal, or a crash
# of its own, would only fail again.
for mode in stall died; do
  retry=$(collect "$mode")
  [[ $(jq -c '{retryAdvised, limitsStale, kept: (.limits | length)}' <<<"$retry") == '{"retryAdvised":true,"limitsStale":true,"kept":2}' ]] ||
    fail "an unreachable Codex backend ($mode) advises a retry" "$retry"
done
for mode in backend crashed auth empty; do
  refused=$(collect "$mode")
  [[ $(jq -r '.retryAdvised // false' <<<"$refused") == false ]] ||
    fail "a Codex backend that answered ($mode) advises no retry" "$refused"
done
pass "only an unreachable Codex backend advises a retry"

auth=$(collect auth)
[[ $(jq -c '{status: .usageStatusText, limitsStale, kept: (.limits | length)}' <<<"$auth") == '{"status":"Waiting for auth","limitsStale":true,"kept":2}' ]] ||
  fail "a Codex sign-out is reported beside the last limits" "$auth"
pass "a Codex sign-out is reported beside the last limits"

for who in "ws-two user-a" "ws-one user-b"; do
  login $who
  other=$(collect backend)
  [[ $(jq -c '{limits, status: .usageStatusText}' <<<"$other") == '{"limits":[],"status":"Codex limits unavailable"}' ]] ||
    fail "a home signed in to someone else never shows the last one's limits ($who)" "$other"
done
pass "a home signed in to someone else, in another workspace or the same one, never shows the last one's limits"
login ws-one user-a

# The login auth.json names is only who answers when nothing overrides it.
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
login ws-one user-a
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
