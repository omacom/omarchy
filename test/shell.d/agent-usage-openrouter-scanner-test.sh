#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3
require_command sqlite3

COLLECTOR="$ROOT/bin/omarchy-agent-usage-openrouter"

[[ -x $COLLECTOR ]] || fail "collector missing/executable" "$COLLECTOR"

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

export HOME="$TEST_HOME"
export XDG_CONFIG_HOME="$TEST_HOME/.config"
export XDG_DATA_HOME="$TEST_HOME/.local/share"
export XDG_CACHE_HOME="$TEST_HOME/.cache"
export XDG_STATE_HOME="$TEST_HOME/.local/state"
export OPENROUTER_API_KEY=""
export OPENROUTER_MANAGEMENT_KEY=""
unset OPENCODE_DB PI_CODING_AGENT_DIR
# Bucket dates resolve in local time, so pin the zone or the fixtures below
# would shift by a day depending on where the test runs.
export TZ="UTC"

# 1. Without credentials: valid record, ready=false
no_key=$("$COLLECTOR")
[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + .tierLabel' <<<"$no_key") == "openrouter:false:" ]] ||
  fail "prints a valid record without credentials" "$no_key"
pass "prints a valid record without credentials"
[[ $(jq -c '{usageStatusText, authHelpText, limits, balance, limitsStale, limitsFetchedAt}' <<<"$no_key") == '{"usageStatusText":"","authHelpText":"","limits":[],"balance":null,"limitsStale":false,"limitsFetchedAt":0}' ]] ||
  fail "an unused machine reports no trouble" "$no_key"
pass "an unused machine reports no trouble"
[[ $(jq -c '[.todayPrompts, .todaySessions, .todayTotalTokens, .todayTokensByModel, .totalPrompts, .totalSessions, .activeDays, .activeDates, .modelUsage]' <<<"$no_key") == '[0,0,0,{},0,0,0,[],{}]' ]] ||
  fail "an unused machine prints the full empty stats block" "$no_key"
[[ $(jq -c '[.recentDays | length, (map(.messageCount) | add), .[-1].date]' <<<"$no_key") == "[7,0,\"$(date +%Y-%m-%d)\"]" ]] ||
  fail "an unused machine prints the full empty stats block" "$no_key"
pass "an unused machine prints the full empty stats block"

# 2. Fixture opencode DB: 2 assistant rows (openrouter) + 1 other provider (ignored)
mkdir -p "$XDG_DATA_HOME/opencode"
sqlite3 "$XDG_DATA_HOME/opencode/opencode.db" <<'SQL'
CREATE TABLE message (id TEXT PRIMARY KEY, session_id TEXT NOT NULL, time_created INTEGER NOT NULL, time_updated INTEGER NOT NULL, data TEXT NOT NULL);
INSERT INTO message VALUES
 ('m1','ses_aaa',1787000000000,1787000000000,'{"role":"assistant","providerID":"openrouter","modelID":"openai/gpt-4o-mini","tokens":{"input":100,"output":20,"reasoning":5,"cache":{"read":10,"write":0}},"time":{"created":1787000000000}}'),
 ('m2','ses_aaa',1787000001000,1787000001000,'{"role":"user","providerID":"openrouter","modelID":"openai/gpt-4o-mini","time":{"created":1787000001000}}'),
 ('m3','ses_bbb',1787000002000,1787000002000,'{"role":"assistant","providerID":"openai","modelID":"gpt-5","tokens":{"input":999,"output":999},"time":{"created":1787000002000}}');
SQL

result=$(python3 - "$COLLECTOR" <<'PY'
import importlib.machinery, importlib.util, json, sys
from datetime import datetime, timezone
from pathlib import Path
loader = importlib.machinery.SourceFileLoader("or_collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)

today = datetime.now().astimezone()
scan = mod.Stats()
complete = mod.scan_opencode(scan)
stats = scan.snapshot()

# /activity fold: prompt+reasoning -> input, completion -> output
activity = mod.summarize_activity([
  {"date": today.strftime("%Y-%m-%d"), "model": "openai/gpt-4o-mini",
   "prompt_tokens": 50, "completion_tokens": 25, "reasoning_tokens": 10},
  {"date": "2020-01-01", "model": "x/y-model",
   "prompt_tokens": 7, "completion_tokens": 3, "reasoning_tokens": 0},
  "garbage-row",
], today)

out = {
  "complete": complete,
  "totalPrompts": stats["totalPrompts"],
  "totalTokens": stats["todayTotalTokens"] + sum(d["messageCount"] for d in stats["recentDays"] if d["date"] != today.strftime("%Y-%m-%d")),
  "model": sorted(stats["modelUsage"].keys()),
  "hasPromptStats_tier1": True,
  "activityToday": activity["todayTotalTokens"],
  "activityModels": sorted(activity["modelUsage"].keys()),
  "activityOldDay": activity["activeDates"],
  "keyMeterEmpty": mod.key_limit_meter({}) == [],
  "keyMeter": mod.key_limit_meter({"limit": 10, "limit_remaining": 4, "limit_reset": "weekly"}),
  "scopeNote": "scope set only in tier2 path",
}
print(json.dumps(out))
PY
)

check() {
  local actual="$1" expected="$2" label="$3"
  [[ $actual == "$expected" ]] || fail "$label (got: $actual, want: $expected)" "$result"
  pass "$label"
}

check "$(jq -r .complete <<<"$result")" "true" "opencode scan completes"
check "$(jq -r .totalPrompts <<<"$result")" "1" "counts only openrouter assistant rows"
check "$(jq -r '.model | join(",")' <<<"$result")" "gpt-4o-mini" "strips provider prefix from model"
check "$(jq -r .activityToday <<<"$result")" "85" "activity folds prompt+completion+reasoning"
check "$(jq -r '.activityModels | join(",")' <<<"$result")" "gpt-4o-mini,y-model" "activity keeps per-model buckets"
check "$(jq -r '.activityOldDay | length' <<<"$result")" "2" "activity tracks active dates"
check "$(jq -r .keyMeterEmpty <<<"$result")" "true" "no meter without key limit"
check "$(jq -r '.keyMeter[0].percent' <<<"$result")" "0.6" "key meter drains toward empty"
check "$(jq -r '.keyMeter[0].label + ":" + .keyMeter[0].resetsAt' <<<"$result")" "Weekly key limit:" "key meter names its period, not a reset time"

# 3. Tier-2 path sets scope=account + hasPromptStats=false (stub api_get)
scope_check=$(python3 - "$COLLECTOR" <<'PY'
import importlib.machinery, importlib.util, json, sys
from datetime import datetime
loader = importlib.machinery.SourceFileLoader("or_collector2", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)

captured = {}
def fake_api_get(path, key):
    captured[path] = key
    if path == "/activity":
        return {"data": [{"date": "2026-09-08", "model": "a/b", "prompt_tokens": 10,
                           "completion_tokens": 5, "reasoning_tokens": 0}]}
    if path == "/key":
        return {"data": {"limit": None, "limit_remaining": None}}
    if path == "/credits":
        return {"data": {"total_credits": 10, "total_usage": 1}}
    raise AssertionError(path)
mod.api_get = fake_api_get

class Args: force = True; limits_only = False
import os
os.environ["OPENROUTER_API_KEY"] = "sk-test"
os.environ["OPENROUTER_MANAGEMENT_KEY"] = "sk-mgmt"
rec = mod.scan(Args())
print(json.dumps({"scope": rec.get("scope"), "hasPromptStats": rec.get("hasPromptStats"),
                  "balance": rec.get("balance", {}).get("remaining"),
                  "called": sorted(captured.keys())}))
PY
)
check "$(jq -r .scope <<<"$scope_check")" "account" "tier-2 record is scope=account"
check "$(jq -r .hasPromptStats <<<"$scope_check")" "false" "tier-2 hides prompt counts"
check "$(jq -r .balance <<<"$scope_check")" "9.0" "tier-2 keeps balance from /credits"
check "$(jq -r '.called | join(",")' <<<"$scope_check")" "/activity,/credits,/key" "tier-2 probes activity + key + credits"

# 4. A failed /key lookup keeps the last good meter, marked stale.
stale_check=$(python3 - "$COLLECTOR" <<'PY'
import importlib.machinery, importlib.util, json, os, sys
loader = importlib.machinery.SourceFileLoader("or_collector3", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)

state = {"up": True}
def fake_api_get(path, key):
  if not state["up"]:
    raise mod.OpenRouterTransportError("Could not reach the OpenRouter API")
  if path == "/key":
    return {"data": {"limit": 10, "limit_remaining": 4, "limit_reset": "monthly"}}
  if path == "/credits":
    return {"data": {"total_credits": 10, "total_usage": 1}}
  raise AssertionError(path)
mod.api_get = fake_api_get

class Args: force = True; limits_only = False
os.environ["OPENROUTER_API_KEY"] = "sk-test"
os.environ["OPENROUTER_MANAGEMENT_KEY"] = ""
live = mod.scan(Args())
state["up"] = False
stale = mod.scan(Args())
pick = lambda r: {"stale": r["limitsStale"], "fetchedAt": r["limitsFetchedAt"], "percent": r["limits"][0]["percent"] if r["limits"] else None, "ready": r["ready"], "tier": r["tierLabel"]}
print(json.dumps({"live": pick(live), "stale": pick(stale), "status": stale["usageStatusText"]}))
PY
)
check "$(jq -c '.live | {stale, percent, tier}' <<<"$stale_check")" '{"stale":false,"percent":0.6,"tier":"Prepaid"}' "a live key meter is fresh"
check "$(jq -c '.stale | {stale, percent, ready}' <<<"$stale_check")" '{"stale":true,"percent":0.6,"ready":true}' "a failed lookup keeps the last meter, marked stale"
check "$(jq -r '.stale.fetchedAt == .live.fetchedAt and .live.fetchedAt > 0' <<<"$stale_check")" "true" "stale meter keeps when it was fetched"
check "$(jq -r .status <<<"$stale_check")" "" "a failed lookup that kept the meter leaves the status to limitsStale"

# 5. A read that times out (headers or body) is a transport failure: the
# record keeps its stats and last meter instead of going blank.
timeout_check=$(python3 - "$COLLECTOR" <<'PY'
import importlib.machinery, importlib.util, json, os, sys
loader = importlib.machinery.SourceFileLoader("or_collector4", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)

class StalledBody:
  def __enter__(self): return self
  def __exit__(self, *args): return False
  def read(self, *args): raise TimeoutError("The read operation timed out")

results = {}
for name, opener in (
  ("headers", lambda request, timeout=None: (_ for _ in ()).throw(TimeoutError("timed out"))),
  ("body", lambda request, timeout=None: StalledBody()),
):
  mod.urllib.request.urlopen = opener
  try:
    mod.api_get("/key", "sk-test")
    results[name] = "no error"
  except mod.OpenRouterTransportError:
    results[name] = "transport"
  except Exception as error:
    results[name] = type(error).__name__

class Args: force = True; limits_only = False
os.environ["OPENROUTER_API_KEY"] = "sk-test"
os.environ["OPENROUTER_MANAGEMENT_KEY"] = ""
record = mod.scan(Args())
results["record"] = {"ready": record["ready"], "stale": record["limitsStale"], "meter": bool(record["limits"]), "retry": record.get("retryAdvised", False), "prompts": record["totalPrompts"]}
print(json.dumps(results))
PY
)
check "$(jq -r '.headers + ":" + .body' <<<"$timeout_check")" "transport:transport" "read timeouts are transport failures"
check "$(jq -c .record <<<"$timeout_check")" '{"ready":true,"stale":true,"meter":true,"retry":true,"prompts":1}' "a timed-out probe keeps stats and the last meter and asks for a retry"

# 6. A management key alone still collects: the 30-day history and the
# balance, with no inference key's meter to show.
manager_check=$(python3 - "$COLLECTOR" <<'PY'
import importlib.machinery, importlib.util, json, os, sys
loader = importlib.machinery.SourceFileLoader("or_collector5", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)

calls = []
def fake_api_get(path, key):
  calls.append(f"{path}={key}")
  if path == "/activity":
    return {"data": [{"date": "2026-09-08", "model": "a/b", "prompt_tokens": 10, "completion_tokens": 5}]}
  if path == "/credits":
    return {"data": {"total_credits": 10, "total_usage": 4}}
  raise AssertionError(path)
mod.api_get = fake_api_get

class Args: force = True; limits_only = False
os.environ["OPENROUTER_API_KEY"] = ""
os.environ["OPENROUTER_MANAGEMENT_KEY"] = "sk-mgmt"
record = mod.scan(Args())
print(json.dumps({"ready": record["ready"], "scope": record.get("scope"), "balance": record.get("balance", {}).get("remaining"), "limits": record["limits"], "status": record["usageStatusText"], "calls": sorted(calls)}))
PY
)
check "$(jq -c '{ready, scope, balance, limits, status}' <<<"$manager_check")" '{"ready":true,"scope":"account","balance":6.0,"limits":[],"status":""}' "a management key alone collects history and balance"
check "$(jq -r '.calls | join(",")' <<<"$manager_check")" "/activity=sk-mgmt,/credits=sk-mgmt" "a management key alone skips the inference key's meter"

# The remaining checks drive the collector module with a stubbed API. Each
# starts from an empty cache so one check's answers never feed another's.
cat >"$TEST_HOME/prelude.py" <<'PY'
import importlib.machinery, importlib.util, json, os, shutil, sys, time
from pathlib import Path
loader = importlib.machinery.SourceFileLoader("or_collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)
shutil.rmtree(os.environ["XDG_CACHE_HOME"], ignore_errors=True)

class Args:
  def __init__(self, force=False, limits_only=False):
    self.force = force
    self.limits_only = limits_only

calls = []
answers = {}
def fake_api_get(path, key):
  calls.append(f"{path}={key}")
  answer = answers.get((path, key), answers.get(path))
  if isinstance(answer, Exception):
    raise answer
  if answer is None:
    raise AssertionError(path)
  return answer
mod.api_get = fake_api_get
os.environ["OPENROUTER_API_KEY"] = "sk-test"
os.environ["OPENROUTER_MANAGEMENT_KEY"] = ""
METER = {"data": {"limit": 10, "limit_remaining": 4, "limit_reset": "monthly"}}
CREDITS = {"data": {"total_credits": 10, "total_usage": 1}}
UNREACHABLE = mod.OpenRouterTransportError("Couldn't reach the OpenRouter API. Retrying shortly.")
pick = lambda r: {k: r.get(k) for k in ("ready", "usageStatusText", "authHelpText", "limits", "limitsStale", "limitsFetchedAt", "balance", "retryAdvised")}
PY
run_py() {
  cat "$TEST_HOME/prelude.py" - | python3 - "$COLLECTOR"
}

# 7. A key nothing was spent through, with no credits and no limit, is an
# unused machine: ready=false and no status from outside the vocabulary.
idle=$(run_py <<'PY'
answers.update({"/key": {"data": {"limit": None}}, "/credits": {"data": {"total_credits": 0, "total_usage": 0}}})
os.environ["XDG_DATA_HOME"] = "/nonexistent"
print(json.dumps(pick(mod.scan(Args()))))
PY
)
check "$(jq -c '{ready, usageStatusText, authHelpText}' <<<"$idle")" '{"ready":false,"usageStatusText":"","authHelpText":""}' "a key with nothing to show is an unused machine"

# 8. Probes are reused for PROBE_MIN_INTERVAL_SECONDS, and --force skips that.
reuse=$(run_py <<'PY'
answers.update({"/key": METER, "/credits": CREDITS})
mod.scan(Args())
first = len(calls)
mod.scan(Args())
reused = len(calls) - first
mod.scan(Args(limits_only=True))
limits_only = len(calls) - first - reused
mod.scan(Args(force=True))
forced = len(calls) - first - reused - limits_only
print(json.dumps({"first": first, "reused": reused, "limitsOnly": limits_only, "forced": forced}))
PY
)
check "$(jq -c . <<<"$reuse")" '{"first":2,"reused":0,"limitsOnly":0,"forced":2}' "a recent probe is reused and --force probes again"

# 9. Each key keeps its own meter: another key whose check fails never shows
# this one's numbers.
per_key=$(run_py <<'PY'
answers.update({"/key": METER, "/credits": CREDITS})
mod.scan(Args(force=True))
answers.update({"/key": mod.OpenRouterError("OpenRouter's API returned status 500."), "/credits": mod.OpenRouterError("OpenRouter's API returned status 500.")})
os.environ["OPENROUTER_API_KEY"] = "sk-other"
other = mod.scan(Args(force=True))
files = sorted(p.name for p in mod.cache_root().glob("openrouter-limits-*.json"))
print(json.dumps({"other": pick(other), "files": len(files)}))
PY
)
check "$(jq -c '.other | {limits, usageStatusText, retryAdvised}' <<<"$per_key")" '{"limits":[],"usageStatusText":"OpenRouter limits unavailable","retryAdvised":null}' "another key never shows this key's meter"
check "$(jq -r .other.authHelpText <<<"$per_key")" "OpenRouter's API returned status 500." "a failed check with nothing kept says what failed"
check "$(jq -r .files <<<"$per_key")" "1" "the meter is cached per key"

# 10. A refused key is a sign-in to redo, never a raw status code, and is not
# worth a sooner retry.
for code in 401 403; do
  refused=$(CODE=$code run_py <<'PY'
answers.update({"/key": METER, "/credits": CREDITS})
mod.scan(Args(force=True))
code = int(os.environ["CODE"])
answers.update({"/key": mod.OpenRouterAuthError(code), "/credits": mod.OpenRouterAuthError(code)})
print(json.dumps(pick(mod.scan(Args(force=True)))))
PY
)
  check "$(jq -c '{usageStatusText, limitsStale, retryAdvised, meter: (.limits | length), ready}' <<<"$refused")" '{"usageStatusText":"Sign-in expired","limitsStale":true,"retryAdvised":null,"meter":1,"ready":true}' "a $code keeps the last meter and asks to sign in again"
  [[ $(jq -r .authHelpText <<<"$refused") == "OpenRouter refused the API key. "* ]] ||
    fail "a $code explains itself without a raw status" "$refused"
  pass "a $code explains itself without a raw status"
done

# 11. A failed /credits keeps the last good balance, marked stale; with none
# kept, the balance says it is unavailable.
balance=$(run_py <<'PY'
answers.update({"/key": METER, "/credits": CREDITS})
mod.scan(Args(force=True))
answers["/credits"] = mod.OpenRouterError("OpenRouter's API returned status 502.")
kept = mod.scan(Args(force=True))
for path in mod.cache_root().glob("openrouter-credits-*.json"):
  path.unlink()
missing = mod.scan(Args(force=True))
print(json.dumps({"kept": pick(kept), "missing": pick(missing)}))
PY
)
check "$(jq -c '.kept | {remaining: .balance.remaining, limitsStale, usageStatusText}' <<<"$balance")" '{"remaining":9.0,"limitsStale":true,"usageStatusText":""}' "a failed balance check keeps the last balance, stale"
check "$(jq -c '.missing | {balance, limitsStale, usageStatusText}' <<<"$balance")" '{"balance":null,"limitsStale":true,"usageStatusText":"Balance unavailable"}' "a failed balance check with nothing kept says so"

# 11b. A /credits answer without both totals is a failed check, not an empty
# balance: it never overwrites the last good one, so a later failure still
# has it to keep.
incomplete=$(run_py <<'PY'
answers.update({"/key": METER, "/credits": CREDITS})
mod.scan(Args(force=True))
answers["/credits"] = {"data": {"total_usage": 1}}
partial = mod.scan(Args(force=True))
answers["/credits"] = mod.OpenRouterError("OpenRouter's API returned status 502.")
later = mod.scan(Args(force=True))
print(json.dumps({"partial": pick(partial), "later": pick(later)}))
PY
)
check "$(jq -c '.partial | {remaining: .balance.remaining, limitsStale, usageStatusText, retryAdvised}' <<<"$incomplete")" '{"remaining":9.0,"limitsStale":true,"usageStatusText":"","retryAdvised":null}' "an incomplete balance answer keeps the last balance, stale"
check "$(jq -c '.later | {remaining: .balance.remaining, limitsStale}' <<<"$incomplete")" '{"remaining":9.0,"limitsStale":true}' "an incomplete balance answer never replaces the cached balance"

# 12. retryAdvised marks only a service that couldn't be reached at all.
retry=$(run_py <<'PY'
answers.update({"/key": UNREACHABLE, "/credits": CREDITS})
unreachable = mod.scan(Args(force=True))
answers.update({"/key": mod.OpenRouterError("OpenRouter's API returned status 500.")})
server = mod.scan(Args(force=True))
answers.update({"/key": METER})
healthy = mod.scan(Args(force=True))
print(json.dumps({"unreachable": unreachable.get("retryAdvised"), "server": server.get("retryAdvised"), "healthy": pick(healthy)}))
PY
)
check "$(jq -c '[.unreachable, .server]' <<<"$retry")" '[true,null]' "retryAdvised marks only an unreachable service"
check "$(jq -c '.healthy | {usageStatusText, authHelpText, limitsStale}' <<<"$retry")" '{"usageStatusText":"","authHelpText":"","limitsStale":false}' "a healthy check clears the help text"

# 13. A kept window whose reset has passed comes back at zero, never dropped.
elapsed=$(run_py <<'PY'
cache = mod.LimitsCache(mod.AGENT_ID, "sk-test").path
mod.write_json(cache, {"fetchedAtMs": round(time.time() * 1000) - 3_600_000, "limits": [
  {"label": "Daily key limit", "title": "Daily key limit", "percent": 0.7, "resetsAt": "2020-01-01T00:00:00Z"},
  {"label": "Key limit", "title": "Key limit", "percent": 0.4, "resetsAt": ""},
]})
answers.update({"/key": UNREACHABLE, "/credits": CREDITS})
print(json.dumps(pick(mod.scan(Args()))))
PY
)
check "$(jq -c '[.limits[] | {percent, resetsAt}]' <<<"$elapsed")" '[{"percent":0.0,"resetsAt":""},{"percent":0.4,"resetsAt":""}]' "an elapsed kept window comes back at zero"

# 14. A cache written under a clock that later went back is still the last
# good answer, but never counts as a recent probe.
clock=$(run_py <<'PY'
cache = mod.LimitsCache(mod.AGENT_ID, "sk-test").path
mod.write_json(cache, {"fetchedAtMs": round(time.time() * 1000) + 3_600_000, "limits": [{"label": "Key limit", "title": "Key limit", "percent": 0.4, "resetsAt": ""}]})
answers.update({"/key": METER, "/credits": CREDITS})
record = mod.scan(Args())
print(json.dumps({"probed": any(c.startswith("/key=") for c in calls), "percent": record["limits"][0]["percent"]}))
PY
)
check "$(jq -c . <<<"$clock")" '{"probed":true,"percent":0.6}' "a future-dated probe cache is not reused"

# 15. Rows with broken timestamps or tokens are skipped, never filed under
# today, and never take the record down.
sqlite3 "$XDG_DATA_HOME/opencode/opencode.db" <<'SQL'
INSERT INTO message VALUES
 ('b1','ses_bad',0,0,'{"role":"assistant","providerID":"openrouter","modelID":"a/bad-time","tokens":{"input":50},"time":{"created":true}}'),
 ('b2','ses_bad',0,0,'{"role":"assistant","providerID":"openrouter","modelID":"a/bad-time","tokens":{"input":50},"time":{"created":-5}}'),
 ('b3','ses_bad',0,0,'{"role":"assistant","providerID":"openrouter","modelID":"a/bad-time","tokens":{"input":50},"time":{"created":"garbage"}}'),
 ('b4','ses_bad',0,0,'{"role":"assistant","providerID":"openrouter","modelID":"a/bad-time","tokens":{"input":50},"time":{"created":1e300}}'),
 ('b5','ses_bad',0,0,'{"role":"assistant","providerID":"openrouter","modelID":"a/bad-tokens","tokens":{"input":true,"output":-3,"reasoning":1e300,"cache":{"read":"NaN"}},"time":{"created":1787000000000}}');
SQL
robust=$(run_py <<'PY'
from datetime import datetime
scan = mod.Stats()
complete = mod.scan_opencode(scan)
stats = scan.snapshot()
print(json.dumps({"complete": complete, "prompts": stats["totalPrompts"], "models": sorted(stats["modelUsage"])}))
PY
)
check "$(jq -c . <<<"$robust")" '{"complete":true,"prompts":1,"models":["gpt-4o-mini"]}' "broken timestamps and tokens skip their row"

# 16. pi and omp sessions on the openrouter provider count, a forked
# session's repeated messages count once, a line without an id always counts,
# and a $HOME that is a git checkout doesn't hide them.
today_iso=$(date -u +%Y-%m-%dT12:00:00.000Z)
mkdir -p "$HOME/.pi/agent/sessions/--p--" "$HOME/.omp/profiles/work/agent/sessions/--q--"
printf '.pi/\n.omp/\n' >"$HOME/.gitignore"
git -C "$HOME" init -q
cat >"$HOME/.pi/agent/sessions/--p--/a-parent.jsonl" <<EOF
{"type":"session","id":"s1","timestamp":"$today_iso"}
{"type":"message","id":"a1","timestamp":"$today_iso","message":{"role":"assistant","provider":"openrouter","model":"anthropic/claude-test","usage":{"input":100,"output":10,"cacheRead":0,"cacheWrite":0}}}
{"type":"message","id":"a2","timestamp":"$today_iso","message":{"role":"assistant","provider":"anthropic","model":"claude-test","usage":{"input":999,"output":999}}}
EOF
cat >"$HOME/.pi/agent/sessions/--p--/b-fork.jsonl" <<EOF
{"type":"message","id":"a1","timestamp":"$today_iso","message":{"role":"assistant","provider":"openrouter","model":"anthropic/claude-test","usage":{"input":100,"output":10,"cacheRead":0,"cacheWrite":0}}}
{"type":"message","timestamp":"$today_iso","message":{"role":"assistant","provider":"openrouter","model":"anthropic/claude-test","usage":{"input":5,"output":5}}}
EOF
cat >"$HOME/.omp/profiles/work/agent/sessions/--q--/omp.jsonl" <<EOF
{"type":"message","id":"o1","timestamp":"$today_iso","message":{"role":"assistant","provider":"openrouter","model":"qwen/qwen-test","usage":{"input":7,"output":3}}}
EOF
pi_check=$(run_py <<'PY'
from datetime import datetime
scan = mod.Stats()
complete = mod.scan_pi(scan)
stats = scan.snapshot()
print(json.dumps({"complete": complete, "prompts": stats["totalPrompts"], "sessions": stats["totalSessions"], "today": stats["todayTotalTokens"], "models": sorted(stats["modelUsage"])}))
PY
)
check "$(jq -c . <<<"$pi_check")" '{"complete":true,"prompts":3,"sessions":3,"today":130,"models":["claude-test","qwen-test"]}' "pi and omp openrouter sessions count once each"
rm -rf "$HOME/.git" "$HOME/.gitignore"

# 17. A normal run reuses a local scan for SCAN_REUSE_SECONDS, --limits-only
# for LIMITS_ONLY_REUSE_SECONDS, and --force never.
scan_reuse=$(run_py <<'PY'
answers.update({"/key": METER, "/credits": CREDITS})
base = mod.scan(Args(force=True))["totalPrompts"]
cache_file, _ = mod.scan_cache_paths()
cached = json.loads(cache_file.read_text())
cached["stats"]["totalPrompts"] = 999
cached["scannedAtMs"] = int((time.time() - 120) * 1000)
mod.write_json(cache_file, cached)
limits_only = mod.scan(Args(limits_only=True))["totalPrompts"]
normal = mod.scan(Args())["totalPrompts"] == base
mod.write_json(cache_file, cached)
forced_record = mod.scan(Args(force=True))
forced = forced_record["totalPrompts"] == base and forced_record["hasLocalStats"]
print(json.dumps({"normal": normal, "limitsOnly": limits_only, "forced": forced}))
PY
)
check "$(jq -c . <<<"$scan_reuse")" '{"normal":true,"limitsOnly":999,"forced":true}' "scan reuse follows --limits-only and --force"

# 18. The local scan is rebuilt under its lock, so a concurrent run waits for
# the scan in progress instead of reading the database a second time.
lock_wait=$(run_py <<'PY'
import fcntl, subprocess
from datetime import datetime
cache_file, lock_file = mod.scan_cache_paths()
holder = subprocess.Popen([sys.executable, "-c", "import fcntl,sys,time; f=open(sys.argv[1],'w'); fcntl.flock(f, fcntl.LOCK_EX); print('locked', flush=True); time.sleep(1.5)", str(lock_file)], stdout=subprocess.PIPE, text=True)
holder.stdout.readline()
started = time.time()
mod.cached_local_stats(0)
waited = time.time() - started
holder.wait()
print(json.dumps({"waited": waited >= 1.0}))
PY
)
check "$(jq -r .waited <<<"$lock_wait")" "true" "the local scan is rebuilt under its lock"

# 19. The 30-day history is reused like a scan, and when /activity can't be
# reached, today's last answer stands in for it.
activity=$(run_py <<'PY'
from datetime import datetime
today = datetime.now().astimezone().strftime("%Y-%m-%d")
os.environ["OPENROUTER_MANAGEMENT_KEY"] = "sk-mgmt"
answers.update({"/activity": {"data": [{"date": today, "model": "a/b", "prompt_tokens": 10, "completion_tokens": 5}]}, "/key": METER, "/credits": CREDITS})
mod.scan(Args(force=True))
calls.clear()
reused = mod.scan(Args())
reused_calls = [c for c in calls if c.startswith("/activity")]
answers["/activity"] = UNREACHABLE
kept = mod.scan(Args(force=True))
print(json.dumps({"reusedCalls": len(reused_calls), "reusedScope": reused.get("scope"), "keptScope": kept.get("scope"), "keptToday": kept["todayTotalTokens"], "retry": kept.get("retryAdvised")}))
PY
)
check "$(jq -c . <<<"$activity")" '{"reusedCalls":0,"reusedScope":"account","keptScope":"account","keptToday":15,"retry":true}' "the activity history is reused and kept past an unreachable check"

# 20. Without any key, what pi, omp and opencode spent through OpenRouter
# here still shows, waiting for a key for the balance and meter.
keyless=$(run_py <<'PY'
os.environ["OPENROUTER_API_KEY"] = ""
record = mod.scan(Args(force=True))
print(json.dumps(dict(pick(record), tierLabel=record["tierLabel"], prompts=record["totalPrompts"], local=record["hasLocalStats"], calls=len(calls))))
PY
)
check "$(jq -c '{ready, usageStatusText, tierLabel, limits, balance, local, calls}' <<<"$keyless")" '{"ready":true,"usageStatusText":"Waiting for auth","tierLabel":"","limits":[],"balance":null,"local":true,"calls":0}' "local usage without a key makes the record ready and waits for auth"
check "$(jq -r '.prompts > 0 and (.authHelpText | startswith("Set OPENROUTER_API_KEY"))' <<<"$keyless")" "true" "local usage without a key is counted and says how to add one"

# 21. The key pi or omp saved with /login is used, a `$VAR` or `!command`
# entry is left to pi, and PI_CODING_AGENT_DIR moves pi's.
saved=$(run_py <<'PY'
os.environ["OPENROUTER_API_KEY"] = ""
home = Path(os.environ["HOME"])
pi_auth = home / ".pi" / "agent" / "auth.json"
omp_auth = home / ".omp" / "agent" / "auth.json"
moved_auth = home / "moved" / "auth.json"
for path in (pi_auth, omp_auth, moved_auth):
  path.parent.mkdir(parents=True, exist_ok=True)
pi_auth.write_text(json.dumps({"openrouter": {"type": "api_key", "key": "sk-pi"}}))
omp_auth.write_text(json.dumps({"openrouter": {"type": "api_key", "key": "sk-omp"}}))
moved_auth.write_text(json.dumps({"openrouter": {"type": "api_key", "key": "$OPENROUTER_KEY"}}))
pi = mod.api_key({})
os.environ["PI_CODING_AGENT_DIR"] = str(moved_auth.parent)
omp = mod.api_key({})
del os.environ["PI_CODING_AGENT_DIR"]
answers.update({"/key": METER, "/credits": CREDITS})
record = mod.scan(Args(force=True))
for path in (pi_auth, omp_auth, moved_auth):
  path.unlink()
print(json.dumps({"pi": pi, "omp": omp, "probed": sorted(calls), "tier": record["tierLabel"]}))
PY
)
check "$(jq -c . <<<"$saved")" '{"pi":"sk-pi","omp":"sk-omp","probed":["/credits=sk-pi","/key=sk-pi"],"tier":"Prepaid"}' "pi's and omp's saved OpenRouter key is used"

# 22. OpenCode V2 nests the provider under `model` and spends tokens on
# compactions too. A message migrated into both stores counts once, and a
# fork's copies of its source's messages don't count again. OPENCODE_DB
# points at the database the way opencode itself reads it.
python3 - "$TEST_HOME/elsewhere/opencode-dev.db" <<'PY'
import json
import sqlite3
import sys
import time
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL, time_created integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE TABLE session_v2 (id text PRIMARY KEY, fork_session_id text, time_created integer NOT NULL)")
now_ms = int(time.time() * 1000)
forked_ms = now_ms - 1000

def v2(id, session, kind, provider, input, created=now_ms):
  return (id, session, kind, created, json.dumps({
    "model": {"providerID": provider, "id": "qwen/qwen-v2"},
    "tokens": {"input": input, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": created},
  }))

conn.executemany("INSERT INTO session_v2 VALUES (?, ?, ?)", [("ses_a", None, now_ms - 5000), ("ses_b", "ses_a", forked_ms)])
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?)", [
  v2("msg_1", "ses_a", "assistant", "openrouter", 100, now_ms - 4000),
  v2("msg_2", "ses_a", "compaction", "openrouter", 10, now_ms - 3000),
  v2("msg_3", "ses_a", "assistant", "openrouter-proxy", 999),
  v2("msg_4", "ses_b", "assistant", "openrouter", 100, forked_ms - 4000),
  v2("msg_5", "ses_b", "assistant", "openrouter", 1),
])
conn.execute("INSERT INTO message VALUES ('msg_1', 'ses_a', ?, ?, ?)", (now_ms, now_ms, json.dumps({
  "role": "assistant", "providerID": "openrouter", "modelID": "qwen/qwen-v2",
  "tokens": {"input": 100, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
  "time": {"created": now_ms - 4000},
})))
conn.commit()
conn.close()
PY
v2=$(OPENCODE_DB="$TEST_HOME/elsewhere/opencode-dev.db" run_py <<'PY'
from datetime import datetime
scan = mod.Stats()
complete = mod.scan_opencode(scan)
stats = scan.snapshot()
print(json.dumps({"complete": complete, "today": stats["todayTotalTokens"], "prompts": stats["totalPrompts"], "sessions": stats["totalSessions"], "models": sorted(stats["modelUsage"])}))
PY
)
check "$(jq -c . <<<"$v2")" '{"complete":true,"today":111,"prompts":3,"sessions":2,"models":["qwen-v2"]}' "opencode V2 records count once each, without fork copies"

# Only a build whose channel was "v2" wrote opencode-v2.db; it is read when
# the usual database is missing.
legacy=$(run_py <<'PY'
from datetime import datetime
home = Path(os.environ["HOME"])
os.environ["XDG_DATA_HOME"] = str(home / "legacy")
(home / "legacy" / "opencode").mkdir(parents=True)
shutil.copy(home / "elsewhere" / "opencode-dev.db", home / "legacy" / "opencode" / "opencode-v2.db")
scan = mod.Stats()
mod.scan_opencode(scan)
print(scan.snapshot()["todayTotalTokens"])
PY
)
check "$legacy" "111" "opencode-v2.db is read when opencode.db is missing"

pass "ALL OPENROUTER SCANNER TESTS PASSED"
