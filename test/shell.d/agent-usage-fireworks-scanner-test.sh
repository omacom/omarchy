#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT
# The collector caches its last good answers; keep them out of the real cache.
export XDG_CACHE_HOME="$TEST_HOME/.cache"

auth_file="$TEST_HOME/auth.ini"
cat >"$auth_file" <<'EOF'
[default]
api_key = fw_test
account_id = example
EOF

mkdir -p "$TEST_HOME/.config/omarchy/agents"
cat >"$TEST_HOME/.config/omarchy/agents/fireworks.json" <<'EOF'
{
  "accountId": "example",
  "fundedAmount": 20,
  "fundedAt": "2026-07-01"
}
EOF

# Without credentials the collector must still print a full, hidden-by-default
# record: the update runner writes whatever valid JSON appears on stdout.
no_key=$(HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" XDG_DATA_HOME="$TEST_HOME/.local/share" \
  PI_CODING_AGENT_DIR="$TEST_HOME/.pi/agent" FIREWORKS_API_KEY="" FIREWORKS_AUTH_PATH="$TEST_HOME/missing.ini" "$ROOT/bin/omarchy-agent-usage-fireworks")

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + (.hasPromptStats | tostring)' <<<"$no_key") == "fireworks:false:false" ]] ||
  fail "Fireworks collector prints a valid record without credentials" "$no_key"
pass "Fireworks collector prints a valid record without credentials"

# An unused machine is not trouble: no status, no help, no balance.
[[ $(jq -c '{usageStatusText, authHelpText, tierLabel, limits, balance, limitsStale, limitsFetchedAt}' <<<"$no_key") == '{"usageStatusText":"","authHelpText":"","tierLabel":"","limits":[],"balance":null,"limitsStale":false,"limitsFetchedAt":0}' ]] ||
  fail "Fireworks collector reports no trouble on an unused machine" "$no_key"
pass "Fireworks collector reports no trouble on an unused machine"
# The last seven local days ending today, none with messages: an unused
# record still carries the full week, zeroed.
empty_week=$(for offset in 6 5 4 3 2 1 0; do date -d "$(date +%F) 12:00 $offset days ago" +%F; done | jq -Rsc 'split("\n")[:-1] | map({date: ., messageCount: 0})')
[[ $(jq -c '[.todayPrompts, .todaySessions, .todayTotalTokens, .todayTokensByModel, .recentDays, .totalPrompts, .totalSessions, .activeDays, .activeDates, .modelUsage]' <<<"$no_key") == "[0,0,0,{},$empty_week,0,0,0,[],{}]" ]] ||
  fail "Fireworks collector prints the full empty stats block on an unused machine" "$no_key"
pass "Fireworks collector prints the full empty stats block on an unused machine"

result=$(python3 - "$ROOT/bin/omarchy-agent-usage-fireworks" "$auth_file" "$TEST_HOME/.config" "$TEST_HOME/.local/share" "$TEST_HOME/.pi/agent" <<'PY'
import importlib.machinery
import importlib.util
import io
import json
import os
import sys
import time
from datetime import date
from decimal import Decimal
from pathlib import Path

collector_path = str(Path(sys.argv[1]))
auth_path = Path(sys.argv[2])
os.environ["XDG_CONFIG_HOME"] = sys.argv[3]
os.environ["XDG_DATA_HOME"] = sys.argv[4]

# Bucket dates resolve in local time, so pin the zone or the fixtures below
# would shift by a day depending on where the test runs. The env account id
# would override the config file, so it must not leak in from the runner.
os.environ["TZ"] = "UTC"
time.tzset()
os.environ.pop("FIREWORKS_ACCOUNT_ID", None)

loader = importlib.machinery.SourceFileLoader("fireworks_collector", collector_path)
spec = importlib.util.spec_from_loader(loader.name, loader)
scanner = importlib.util.module_from_spec(spec)
loader.exec_module(scanner)
RealFireworksClient = scanner.FireworksClient

payload = {
  "serverlessCosts": [
    {
      "startTime": "2026-07-31T00:00:00Z",
      "promptTokens": "100",
      "cachedPromptTokens": "40",
      "uncachedPromptTokens": "60",
      "completionTokens": "20",
      "group": {"model_name": "accounts/fireworks/models/kimi-k2p5"},
    },
    {
      "startTime": "2026-07-30T00:00:00Z",
      "promptTokens": "300",
      "cachedPromptTokens": "0",
      "completionTokens": "50",
      "group": {"model_name": "accounts/fireworks/models/deepseek-v3p2"},
    },
    {
      "startTime": "2026-07-20T00:00:00Z",
      "promptTokens": "500",
      "cachedPromptTokens": "0",
      "completionTokens": "100",
      "group": {"model_name": "accounts/fireworks/models/kimi-k2p5"},
    },
  ]
}

summary = scanner.summarize_usage(payload, date(2026, 7, 31))
api_key, account_id = scanner.read_auth_file(auth_path)
summary["apiKey"] = api_key
summary["accountId"] = account_id
summary["money"] = float(scanner.money_value({"units": "12", "nanos": 430000000}))

# The opencode key only wins when no explicit key, firectl login, or pi
# login exists. Pin the pi dir first so a developer's real ~/.pi/agent
# credentials cannot leak into the fixture run.
pi_dir = Path(sys.argv[5])
os.environ["PI_CODING_AGENT_DIR"] = str(pi_dir)
data_home = Path(os.environ["XDG_DATA_HOME"])
opencode_auth = data_home / "opencode" / "auth.json"
opencode_auth.parent.mkdir(parents=True, exist_ok=True)
opencode_auth.write_text(json.dumps({"fireworks-ai": {"type": "api", "key": "fw_opencode"}}))
os.environ.pop("FIREWORKS_API_KEY", None)
opencode_key, _ = scanner.credentials(Path("/nonexistent/auth.ini"), {})
firectl_key, _ = scanner.credentials(auth_path, {})
summary["opencodeFallback"] = opencode_key == "fw_opencode" and firectl_key == "fw_test"

# A pi login is the next rung below firectl, above opencode.
pi_dir.mkdir(parents=True, exist_ok=True)
(pi_dir / "auth.json").write_text(json.dumps({"fireworks": {"type": "api_key", "key": "fw_pi"}}))
pi_key, _ = scanner.credentials(Path("/nonexistent/auth.ini"), {})
firectl_still_wins, _ = scanner.credentials(auth_path, {})
summary["piFallback"] = pi_key == "fw_pi" and firectl_still_wins == "fw_test"

# pi key syntax: $ENV references resolve, missing ones stay unresolved, and
# !command lookups are skipped and fall through to opencode.
os.environ["FW_TEST_ENV_KEY"] = "fw_from_env"
summary["piEnvKey"] = scanner.resolve_pi_key("$FW_TEST_ENV_KEY") == "fw_from_env"
summary["piMissingEnvKey"] = scanner.resolve_pi_key("$FW_DEFINITELY_MISSING") == ""
(pi_dir / "auth.json").write_text(json.dumps({"fireworks": {"type": "api_key", "key": "!secret-tool lookup fw"}}))
command_key, _ = scanner.credentials(Path("/nonexistent/auth.ini"), {})
summary["piCommandKeySkipped"] = command_key == "fw_opencode"

class WorkingClient:
  def __init__(self, api_key, base_url):
    pass

  def request(self, path, query=None, body=None):
    raise scanner.FireworksError("The Fireworks API key cannot read billing data")

  def usage(self, account_id, start_day, end_day):
    return payload

  def account(self, account_id):
    return {}

  def spent(self, account_id, start_at, end_at):
    return Decimal("8.60")

class BalanceFailureClient(WorkingClient):
  def spent(self, account_id, start_at, end_at):
    raise scanner.FireworksError("Billing scope denied")

class LiveBalanceClient(WorkingClient):
  def request(self, path, query=None, body=None):
    assert path.endswith(":getBalance")
    return {"balance": {"units": "12", "nanos": 500000000}}

os.environ["FIREWORKS_API_KEY"] = "fw_test"

scanner.FireworksClient = WorkingClient
record = scanner.scan("https://example.invalid", auth_path, force=True)
summary["record"] = {
  "schemaVersion": record["schemaVersion"],
  "id": record["id"],
  "ready": record["ready"],
  "hasPromptStats": record["hasPromptStats"],
  "scope": record["scope"],
  "tierLabel": record["tierLabel"],
  "limits": record["limits"],
  "balance": record["balance"],
}

# billingUsage pages long ranges; usage() must follow continuation tokens.
pages = {
  "": {"serverlessCosts": [{"startTime": "2026-07-30T00:00:00Z"}], "nextPageToken": "p2"},
  "p2": {"serverlessCosts": [{"startTime": "2026-07-31T00:00:00Z"}]},
}
paging_client = RealFireworksClient("fw_test", "https://example.invalid")
paging_queries = []
def paged_request(path, query=None, body=None):
  paging_queries.append(dict(query or {}))
  return pages[str((query or {}).get("pageToken") or "")]
paging_client.request = paged_request
merged = paging_client.usage("example", date(2026, 7, 1), date(2026, 8, 1))
summary["paginationMerges"] = (
  len(merged["serverlessCosts"]) == 2
  and len(paging_queries) == 2
  and paging_queries[0]["startTime"] == "2026-07-01T00:00:00Z"
)

# A reply that isn't an object, or usage rows that aren't a list, fail the
# check rather than passing for an idle account; a missing list is an idle
# month, since the API leaves empty lists out.
def raises_fireworks_error(call):
  try:
    call()
  except scanner.FireworksError:
    return True
  return False
real_urlopen = scanner.urllib.request.urlopen
scanner.urllib.request.urlopen = lambda request, timeout=None: io.BytesIO(b"[]")
odd_client = RealFireworksClient("fw_test", "https://example.invalid")
summary["oddShapes"] = [raises_fireworks_error(lambda: odd_client.request("/v1/accounts"))]
scanner.urllib.request.urlopen = real_urlopen
odd_pages = iter([{"serverlessCosts": "rows"}, {}])
odd_client.request = lambda path, query=None, body=None: next(odd_pages)
summary["oddShapes"].append(raises_fireworks_error(lambda: odd_client.usage("example", date(2026, 7, 1), date(2026, 8, 1))))
summary["oddShapes"].append(odd_client.usage("example", date(2026, 7, 1), date(2026, 8, 1)) == {"serverlessCosts": []})

scanner.FireworksClient = LiveBalanceClient
live = scanner.scan("https://example.invalid", auth_path, force=True)
summary["liveBalance"] = live["balance"]

# A failed balance check keeps the last good balance, stale, with the status
# left to limitsStale; with nothing kept it says the balance is unavailable.
scanner.FireworksClient = BalanceFailureClient
kept = scanner.scan("https://example.invalid", auth_path, force=True)
summary["balanceFailureKeepsBalance"] = (
  kept["balance"] == live["balance"]
  and kept["limitsStale"] is True
  and kept["usageStatusText"] == ""
  and kept["authHelpText"] == "Billing scope denied"
  and kept.get("retryAdvised") is None
)
for cached in scanner.cache_root().glob("fireworks-limits-*.json"):
  cached.unlink()
scanned = scanner.scan("https://example.invalid", auth_path, force=True)
summary["balanceFailurePreservesTokens"] = (
  scanned["ready"] is True
  and "balance" not in scanned
  and scanned["modelUsage"]["kimi-k2.5"]["outputTokens"] == 120
  and scanned["usageStatusText"] == "Balance unavailable"
  and scanned["limitsStale"] is True
)

# East of Greenwich, a local-midnight bucket starts on the previous UTC date;
# the row must still land on the local day it names, and the query window
# must ask for local midnights expressed in UTC.
os.environ["TZ"] = "Etc/GMT-2"
time.tzset()
summary["bucketDayIsLocal"] = scanner.row_date({"startTime": "2026-07-30T22:00:00Z"}) == "2026-07-31"
summary["windowIsLocalMidnight"] = scanner.local_midnight_utc(date(2026, 7, 31)) == "2026-07-30T22:00:00Z"
print(json.dumps(summary, separators=(",", ":")))
PY
)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "120" ]] ||
  fail "Fireworks collector totals today's uncached, cached, and output tokens once" "$result"
pass "Fireworks collector totals today's token categories once"

[[ $(jq -c '.modelUsage["kimi-k2.5"]' <<<"$result") == '{"inputTokens":560,"outputTokens":120,"cacheReadInputTokens":40,"cacheCreationInputTokens":0}' ]] ||
  fail "Fireworks collector keeps cache separate in model totals" "$result"
pass "Fireworks collector keeps cache separate in model totals"

[[ $(jq -r '.recentDays[-1].messageCount' <<<"$result") == "120" ]] ||
  fail "Fireworks collector builds the seven-day token series" "$result"
pass "Fireworks collector builds the seven-day token series"

[[ $(jq -r '.activeDays' <<<"$result") == "3" ]] ||
  fail "Fireworks collector retains the 30-day model window" "$result"
pass "Fireworks collector retains the 30-day model window"

[[ $(jq -r '.apiKey + ":" + .accountId' <<<"$result") == "fw_test:example" ]] ||
  fail "Fireworks collector reads firectl credentials" "$result"
pass "Fireworks collector reads firectl credentials"

[[ $(jq -r '.money' <<<"$result") == "12.43" ]] ||
  fail "Fireworks collector parses Money units and nanos" "$result"
pass "Fireworks collector parses Money units and nanos"

[[ $(jq -c '.record | {schemaVersion, id, ready, hasPromptStats, scope, tierLabel, limits}' <<<"$result") == '{"schemaVersion":1,"id":"fireworks","ready":true,"hasPromptStats":false,"scope":"account","tierLabel":"Prepaid","limits":[]}' ]] ||
  fail "Fireworks collector prints the display-ready record contract" "$result"
pass "Fireworks collector prints the display-ready record contract"

[[ $(jq -r '.paginationMerges' <<<"$result") == "true" ]] ||
  fail "Fireworks collector follows billingUsage continuation tokens" "$result"
pass "Fireworks collector follows billingUsage continuation tokens"

[[ $(jq -c '.oddShapes' <<<"$result") == "[true,true,true]" ]] ||
  fail "Fireworks collector fails a reply of the wrong shape, and reads a missing usage list as idle" "$result"
pass "Fireworks collector fails a reply of the wrong shape, and reads a missing usage list as idle"

[[ $(jq -r '.windowIsLocalMidnight' <<<"$result") == "true" ]] ||
  fail "Fireworks collector requests local-midnight windows in UTC" "$result"
pass "Fireworks collector requests local-midnight windows in UTC"

[[ $(jq -c '.record.balance' <<<"$result") == '{"remaining":11.4,"funded":20.0,"spent":8.6,"currency":"USD","estimated":true}' ]] ||
  fail "Fireworks collector estimates the balance from configured funding" "$result"
pass "Fireworks collector estimates the balance from configured funding"

[[ $(jq -c '.liveBalance' <<<"$result") == '{"remaining":12.5,"funded":20.0,"spent":7.5,"currency":"USD","estimated":false}' ]] ||
  fail "Fireworks collector prefers the live getBalance ledger when the key can read it" "$result"
pass "Fireworks collector prefers the live getBalance ledger when the key can read it"

[[ $(jq -r '.balanceFailureKeepsBalance' <<<"$result") == "true" ]] ||
  fail "Fireworks collector keeps the last balance, stale, when the check fails" "$result"
pass "Fireworks collector keeps the last balance, stale, when the check fails"

[[ $(jq -r '.balanceFailurePreservesTokens' <<<"$result") == "true" ]] ||
  fail "Fireworks collector preserves tokens when balance lookup fails" "$result"
pass "Fireworks collector preserves tokens when balance lookup fails"

[[ $(jq -r '.bucketDayIsLocal' <<<"$result") == "true" ]] ||
  fail "Fireworks collector dates buckets by local day east of Greenwich" "$result"
pass "Fireworks collector dates buckets by local day east of Greenwich"

[[ $(jq -r '.opencodeFallback' <<<"$result") == "true" ]] ||
  fail "Fireworks collector falls back to the opencode key last" "$result"
pass "Fireworks collector falls back to the opencode key last"

[[ $(jq -r '.piFallback' <<<"$result") == "true" ]] ||
  fail "Fireworks collector falls back to the pi login before opencode" "$result"
pass "Fireworks collector falls back to the pi login before opencode"

[[ $(jq -r '.piEnvKey' <<<"$result") == "true" ]] ||
  fail "Fireworks collector resolves env-var pi keys" "$result"
pass "Fireworks collector resolves env-var pi keys"

[[ $(jq -r '.piMissingEnvKey' <<<"$result") == "true" ]] ||
  fail "Fireworks collector treats missing env references as unresolved" "$result"
pass "Fireworks collector treats missing env references as unresolved"

[[ $(jq -r '.piCommandKeySkipped' <<<"$result") == "true" ]] ||
  fail "Fireworks collector skips command-lookup pi keys and falls through" "$result"
pass "Fireworks collector skips command-lookup pi keys and falls through"

# The cache contract: last good answers per key, reused briefly, kept stale
# past a failed check. Each check starts from an empty cache.
contract=$(python3 - "$ROOT/bin/omarchy-agent-usage-fireworks" "$auth_file" "$TEST_HOME" <<'PY'
import importlib.machinery, importlib.util, json, os, shutil, sys, time
from decimal import Decimal
from pathlib import Path

home = Path(sys.argv[3])
os.environ["XDG_CONFIG_HOME"] = str(home / ".config")
os.environ["XDG_DATA_HOME"] = str(home / ".local/share")
os.environ["PI_CODING_AGENT_DIR"] = str(home / ".pi/agent")
os.environ["TZ"] = "UTC"
time.tzset()
os.environ.pop("FIREWORKS_ACCOUNT_ID", None)
os.environ["FIREWORKS_API_KEY"] = "fw_test"
auth_path = Path(sys.argv[2])

loader = importlib.machinery.SourceFileLoader("fireworks_contract", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
scanner = importlib.util.module_from_spec(spec)
loader.exec_module(scanner)

today = time.strftime("%Y-%m-%d")
ROWS = {"serverlessCosts": [{"startTime": today + "T00:00:00Z", "promptTokens": "100", "completionTokens": "20", "group": {"model_name": "accounts/fireworks/models/kimi-k2p5"}}]}
LIVE = {"balance": {"units": "12", "nanos": 500000000}}
state = {"usage": ROWS, "balance": LIVE, "calls": []}

class StubClient:
  def __init__(self, api_key, base_url):
    self.api_key = api_key
  def answer(self, kind):
    state["calls"].append(kind)
    value = state[kind]
    if isinstance(value, Exception):
      raise value
    return value
  def request(self, path, query=None, body=None):
    return self.answer("balance")
  def usage(self, account_id, start_day, end_day):
    return self.answer("usage")
  def account(self, account_id):
    return {}
  def spent(self, account_id, start_at, end_at):
    return Decimal("0")
scanner.FireworksClient = StubClient

def fresh_cache():
  shutil.rmtree(scanner.cache_root(), ignore_errors=True)
  state.update(usage=ROWS, balance=LIVE, calls=[])

def run(**flags):
  return scanner.scan("https://example.invalid", auth_path, **flags)

def pick(r):
  picked = {k: r.get(k) for k in ("ready", "usageStatusText", "authHelpText", "limitsStale", "retryAdvised", "todayTotalTokens", "hasLocalStats")}
  picked["balance"] = (r.get("balance") or {}).get("remaining")
  picked["fetched"] = r.get("limitsFetchedAt", 0) > 0
  return picked

out = {}
UNREACHABLE = scanner.FireworksTransportError("Could not reach the Fireworks API")
SERVER = scanner.FireworksError("Fireworks API returned HTTP 500")
REFUSED = scanner.FireworksAuthError("Fireworks rejected the API key")

fresh_cache()
out["fresh"] = pick(run(force=True))

# Usage and balance both fail: the last good stats and balance stand, stale.
state.update(usage=UNREACHABLE, balance=UNREACHABLE)
out["stale"] = pick(run(force=True))

# A server error is no reason for a sooner retry.
state.update(usage=SERVER, balance=SERVER)
out["serverError"] = pick(run(force=True))

# Nothing kept: the stats source is unavailable.
fresh_cache()
state.update(usage=UNREACHABLE, balance=UNREACHABLE)
out["nothingKept"] = pick(run(force=True))

# A refused key asks for a new one.
fresh_cache()
run(force=True)
state.update(usage=REFUSED, balance=REFUSED)
out["refused"] = pick(run(force=True))

# Answers are reused briefly and --force reuses nothing; --limits-only keeps
# the usage rows for 15 minutes but re-checks a balance older than the probe
# interval.
fresh_cache()
run()
first = list(state["calls"])
state["calls"].clear()
run()
reused = list(state["calls"])
run(force=True)
forced = list(state["calls"])
state["calls"].clear()
for path in scanner.cache_root().glob("fireworks-*.json"):
  cached = json.loads(path.read_text())
  cached["fetchedAtMs"] -= 60_000
  path.write_text(json.dumps(cached))
run(limits_only=True)
limits_only = list(state["calls"])
state["calls"].clear()
run()
normal = list(state["calls"])
out["reuse"] = {"first": first, "reused": reused, "forced": forced, "limitsOnly": limits_only, "normal": normal}

# A cache dated in the future (the clock went back) is kept but never counts
# as recent.
fresh_cache()
run(force=True)
for path in scanner.cache_root().glob("fireworks-*.json"):
  cached = json.loads(path.read_text())
  cached["fetchedAtMs"] += 3_600_000
  path.write_text(json.dumps(cached))
state["calls"].clear()
run()
out["futureCache"] = sorted(set(state["calls"]))

# Another key, or the same key now pointed at another account, never shows
# these numbers.
fresh_cache()
run(force=True)
state.update(usage=UNREACHABLE, balance=UNREACHABLE)
os.environ["FIREWORKS_API_KEY"] = "fw_other"
out["otherKey"] = pick(run(force=True))
os.environ["FIREWORKS_API_KEY"] = "fw_test"
os.environ["FIREWORKS_ACCOUNT_ID"] = "elsewhere"
out["otherAccount"] = pick(run(force=True))
os.environ.pop("FIREWORKS_ACCOUNT_ID")

# Untrusted token fields skip, never crash or inflate.
out["robust"] = scanner.summarize_usage({"serverlessCosts": [
  {"startTime": today + "T00:00:00Z", "promptTokens": True, "completionTokens": "NaN", "group": {"model_name": "a"}},
  {"startTime": today + "T00:00:00Z", "promptTokens": 1e300, "completionTokens": "inf", "group": {"model_name": "b"}},
  {"startTime": today + "T00:00:00Z", "promptTokens": -5, "completionTokens": 7, "group": {"model_name": "c"}},
]})["modelUsage"]
print(json.dumps(out, separators=(",", ":")))
PY
)

check_contract() {
  local filter="$1" expected="$2" label="$3" actual
  actual=$(jq -c "$filter" <<<"$contract")
  [[ $actual == "$expected" ]] || fail "$label (got: $actual)" "$contract"
  pass "$label"
}

check_contract '.fresh' '{"ready":true,"usageStatusText":"","authHelpText":"","limitsStale":false,"retryAdvised":null,"todayTotalTokens":120,"hasLocalStats":true,"balance":12.5,"fetched":true}' "Fireworks collector reports a fresh check as healthy"
check_contract '.stale' '{"ready":true,"usageStatusText":"","authHelpText":"Could not reach the Fireworks API","limitsStale":true,"retryAdvised":true,"todayTotalTokens":120,"hasLocalStats":true,"balance":12.5,"fetched":true}' "Fireworks collector keeps the last stats and balance, stale, past an unreachable API"
check_contract '.serverError | {limitsStale, retryAdvised, usageStatusText}' '{"limitsStale":true,"retryAdvised":null,"usageStatusText":""}' "Fireworks collector asks for a sooner retry only when the API is unreachable"
check_contract '.nothingKept | {ready, usageStatusText, limitsStale, retryAdvised, balance}' '{"ready":true,"usageStatusText":"Fireworks unavailable","limitsStale":true,"retryAdvised":true,"balance":null}' "Fireworks collector says it is unavailable when nothing was kept"
check_contract '.refused | {usageStatusText, limitsStale, balance}' '{"usageStatusText":"Sign-in expired","limitsStale":true,"balance":12.5}' "Fireworks collector reads a rejected key as an expired sign-in"
check_contract '.reuse' '{"first":["usage","balance"],"reused":[],"forced":["usage","balance"],"limitsOnly":["balance"],"normal":["usage"]}' "Fireworks collector reuses recent answers and --force re-fetches"
check_contract '.futureCache' '["balance","usage"]' "Fireworks collector never treats a future-dated cache as recent"
check_contract '.otherKey | {balance, todayTotalTokens, usageStatusText}' '{"balance":null,"todayTotalTokens":0,"usageStatusText":"Fireworks unavailable"}' "Fireworks collector keeps each key's answers apart"
check_contract '.otherAccount | {balance, todayTotalTokens}' '{"balance":null,"todayTotalTokens":0}' "Fireworks collector keeps each account's answers apart"
check_contract '.robust' '{"c":{"inputTokens":0,"outputTokens":7,"cacheReadInputTokens":0,"cacheCreationInputTokens":0}}' "Fireworks collector skips untrusted token fields"
