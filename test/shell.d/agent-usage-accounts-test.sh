#!/bin/bash

# Several accounts registered with `omarchy agent account`: the Claude and
# Codex records list each one with its own plan and limits, asked with its
# own sign-in, while the record's own fields describe the active account.
# Grok's accounts are covered in its own test, and the registry's reading in
# the shared test.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

# A mise shim cannot find the installed Node after the sandbox changes HOME.
if command -v node >/dev/null; then
  node_binary=$(node -p 'process.execPath')
  PATH="${node_binary%/*}:$PATH"
fi
agent_sandbox

# ------------------------------------------------------------------- claude

python3 - <<'PY'
from agent_usage_fixtures import *

sandbox()
accounts = state_home() / "omarchy" / "agents" / "accounts"


def credentials(directory, token, expires, tier):
  write_json(Path(directory) / ".credentials.json", {"claudeAiOauth": {"accessToken": token, "expiresAt": expires, "rateLimitTier": tier, "subscriptionType": "max"}})


credentials(home() / ".claude", "token-main", ms_in(3600), "default_claude_max_20x")
credentials(accounts / "claude" / "work", "token-work", ms_in(3600), "default_claude_max_5x")
credentials(accounts / "claude" / "old", "token-old", 1000, "default_claude_max_5x")
(home() / ".claude" / "projects").mkdir()

# A parked account whose sign-in lapsed still has its last numbers on disk.
write_json(cache_root() / "claude-limits-old.json", {"fetchedAtMs": 1, "limits": [{"label": "Weekly (7-day)", "percent": 0.4, "resetsAt": iso_in(3 * 3600)}]})

registry("claude", [
  {"id": "main", "label": "Main", "home": "", "primary": True, "email": "me@example.com"},
  {"id": "work", "label": "Work", "home": str(accounts / "claude" / "work"), "primary": False, "email": "work@example.com", "accountId": "u-work"},
  {"id": "old", "label": "Old", "home": str(accounts / "claude" / "old"), "primary": False, "email": "old@example.com"},
], active="work", switch="auto", threshold=95)

# Anthropic answers per token, so each account's probe is told apart by the
# credential it carried.
USAGE = {"token-main": 97.0, "token-work": 12.0}


def per_token(request):
  token = request.get_header("Authorization").split(" ", 1)[1]
  if token not in USAGE:
    return urllib.error.URLError("down")
  return {"five_hour": {"utilization": USAGE[token]}, "seven_day": {"utilization": 5.0}}


def claude(routes=None):
  with FakeHttp(routes or {"api.anthropic.com": per_token}):
    return collect("claude", "--force")


record = claude()
expect("Claude identifies the registered subscription", [record["accountRegistryStatus"], record["accounts"][1]["accountId"]], ["available", "u-work"])
expect("Claude record lists every registered account with its own plan",
       [{key: account[key] for key in ("id", "active", "plan", "stale")} for account in record["accounts"]],
       [{"id": "main", "active": False, "plan": "Max 20x", "stale": False},
        {"id": "work", "active": True, "plan": "Max 5x", "stale": False},
        {"id": "old", "active": False, "plan": "Max 5x", "stale": True}], record)
expect("Claude record probes each account with its own sign-in", [account["limits"][0]["percent"] for account in record["accounts"]], [0.97, 0.12, 0.4], record)
expect("a lapsed account keeps its last-known limits and says why", record["accounts"][2]["usageStatusText"], "Sign-in expired", record)
expect("the record's own limits describe the active account", [record["tierLabel"], record["limits"][0]["percent"]], ["Max 5x", 0.12], record)
expect("each account keeps its own limits cache, keyed by subscription",
       [(cache_root() / name).is_file() for name in ("claude-limits.json", "claude-limits-u-work.json")], [True, True])

# Once every window a lapsed account last saw has reset, it has its whole
# allowance back: that reads as 0%, not as nothing known.
ANY = {"api.anthropic.com": {"five_hour": {"utilization": 30.0}}}
old_cache = write_json(cache_root() / "claude-limits-old.json", {"fetchedAtMs": 1, "limits": [{"label": "Session (5-hour)", "percent": 0.99, "resetsAt": iso_in(-300)}]})


def rested(record):
  account = record["accounts"][2]
  return {"stale": account["stale"], "limits": [{"label": entry["label"], "empty": entry["percent"] == 0} for entry in account["limits"]]}


record = claude(ANY)
expect("a lapsed account whose windows all reset reads as untouched", rested(record), {"stale": True, "limits": [{"label": "Session (5-hour)", "empty": True}]}, record)

# A cache stamped ahead of a clock that later stepped back is still what the
# account last saw, so its reset windows still read as untouched.
future = time.time() + 3600
os.utime(old_cache, (future, future))
record = claude(ANY)
expect("a future-dated cache of reset windows still reads as untouched", rested(record), {"stale": True, "limits": [{"label": "Session (5-hour)", "empty": True}]}, record)

# Signing the primary home in to another subscription must not inherit the
# last one's numbers when the first probe for the new one fails.
write_json(home() / ".claude.json", {"oauthAccount": {"accountUuid": "u-new"}})
write_json(cache_root() / "claude-limits.json", {"fetchedAtMs": ms_in(0), "limits": [{"label": "Session (5-hour)", "percent": 0.55, "resetsAt": iso_in(3 * 3600)}]})
USAGE.pop("token-main")
record = claude()
check("a primary home signed in to another subscription doesn't inherit its limits",
      0.55 not in [entry["percent"] for entry in record["accounts"][0]["limits"]], record)
expect("a changed Claude sign-in owns its reset deadlines", record["accounts"][0]["accountId"], "u-new")
(home() / ".claude.json").unlink()

# A registry with one account changes nothing about the record.
registry("claude", [{"id": "main", "label": "Main", "home": "", "primary": True, "email": "me@example.com"}], active="main", switch="auto", threshold=95)
record = claude(ANY)
expect("a single account record is unchanged, and limits checked just now aren't stale",
       ["accounts" in record, record["limits"][0]["percent"], record["limitsStale"], record["limitsFetchedAt"] > 0], [False, 0.3, False, True], record)

(accounts / "claude.json").write_text("{")
record = claude(ANY)
expect("an unreadable Claude registry retains limits for the configured home",
       [record["accountRegistryStatus"], record["fallbackAccountLabel"], "accounts" in record, record["limits"][0]["percent"]],
       ["unreadable", "Configured home", False, 0.3])

# A failed probe falls back on hour-old numbers, and the record says so.
hour_ago = ms_in(-3600)
write_json(cache_root() / "claude-limits.json", {"fetchedAtMs": hour_ago, "limits": [{"label": "Session (5-hour)", "percent": 0.42, "resetsAt": iso_in(3 * 3600)}]})
with FakeHttp(mode="down"):
  record = collect("claude", "--force")
expect("the record says when its limits are kept from an earlier check",
       [record["limitsStale"], record["limitsFetchedAt"], record["limits"][0]["percent"]], [True, hour_ago, 0.42], record)
PY

# -------------------------------------------------------------------- codex

home=$(new_home codex)
accounts="$home/.local/state/omarchy/agents/accounts"
mkdir -p "$home/.codex/sessions" "$accounts/codex/side"
touch "$home/.codex/auth.json" "$accounts/codex/side/auth.json"
cat >"$accounts/codex.json" <<JSON
{
  "active": "main",
  "accounts": [
    {"id": "main", "accountId": "codex-main", "label": "Main", "home": "", "primary": true},
    {"id": "side", "accountId": "codex-side", "label": "Side", "home": "$accounts/codex/side", "primary": false}
  ]
}
JSON

# A stand-in app-server that answers for whichever home it was started in.
stub_cli "$home" codex >/dev/null <<PY
#!$(command -v python3)
import json, os, sys
used = 91 if os.environ.get("CODEX_HOME", "").endswith("/side") else 40
for line in sys.stdin:
  message = json.loads(line)
  if "id" not in message:
    continue
  result = {}
  if message["method"] == "account/rateLimits/read":
    result = {"rateLimits": {"planType": "pro", "primary": {"usedPercent": used, "windowDurationMins": 300}}}
  print(json.dumps({"id": message["id"], "result": result}), flush=True)
PY

record=$(run_collector "$home" codex)
expect_jq "Codex record asks each account's own app-server" '[.accounts[] | {id, active, used: .limits[0].percent}]' \
  '[{"id":"main","active":true,"used":0.4},{"id":"side","active":false,"used":0.91}]' "$record"
expect_jq "Codex record's own limits describe the active account" '.limits[0].percent' '0.4' "$record"

record=$(run_collector "$home" codex CODEX_HOME="$accounts/codex/side")
expect_jq "Main's Codex limits come from ~/.codex whatever CODEX_HOME says" '[.accounts[] | .limits[0].percent]' '[0.4,0.91]' "$record"

expect_jq "Codex exposes subscription identities for reset deadlines" '[.accountRegistryStatus, .accounts[].accountId]' '["available","codex-main","codex-side"]' "$record"

# A secondary home nobody signed in to is waiting for auth, even while
# ~/.codex holds a login, and its app-server is never started.
rm "$accounts/codex/side/auth.json"
record=$(run_collector "$home" codex)
expect_jq "a signed-out Codex home waits for auth on its own" '[.accounts[] | {id, used: .limits[0].percent, status: .usageStatusText}]' \
  '[{"id":"main","used":0.4,"status":""},{"id":"side","used":null,"status":"Waiting for auth"}]' "$record"

printf '{' >"$accounts/codex.json"
record=$(run_collector "$home" codex)
expect_jq "an unreadable Codex registry retains limits for the configured home" \
  '[.accountRegistryStatus, .fallbackAccountLabel, has("accounts"), .limits[0].percent]' '["unreadable","Configured home",false,0.4]' "$record"

# ------------------------------------------------------------------ harness

# run_collector carries the caller's TZ into its bare environment. In a zone
# whose day differs from the system zone's (+14 and -12 hours are never both
# on it), a collector run that way dates its record by that zone; the days
# either side of the run cover one straddling that zone's midnight.
zone=Pacific/Kiritimati
if [[ $(TZ=$zone date +%F) == "$(env -u TZ date +%F)" ]]; then
  zone=Etc/GMT+12
fi
before=$(TZ=$zone date +%F)
record=$(TZ=$zone run_collector "$(new_home)" codex)
after=$(TZ=$zone date +%F)
day=$(jq -r '.recentDays[-1].date' <<<"$record")
if [[ $day == "$before" || $day == "$after" ]]; then
  pass "run_collector hands the collector the caller's TZ"
else
  fail "run_collector hands the collector the caller's TZ" "TZ=$zone day $before, record ends $day"
fi

# Both sandboxes drop the same developer variables, MISE_DATA_DIR (where
# Codex looks for mise's shims) among them.
if python3 -c '
import os, sys
os.environ["MISE_DATA_DIR"] = "/developer/mise"
import agent_usage_fixtures as f
shell = sys.argv[1].removeprefix("^(").removesuffix(")").split("|")
f.sandbox()
sys.exit(sorted(shell) != sorted(f.DEVELOPER_PREFIXES) or "MISE_DATA_DIR" in os.environ)
' "$AGENT_DEVELOPER_PREFIXES" && [[ MISE_DATA_DIR =~ $AGENT_DEVELOPER_PREFIXES ]]; then
  pass "both sandboxes drop the same developer variables, mise's included"
else
  fail "both sandboxes drop the same developer variables, mise's included"
fi

test_tmp="$SANDBOX/reset-identity"
mkdir -p "$test_tmp"
# Refresh the real registry, run the real per-account collectors, then feed
# their records to the reset model. Only provider network calls are stubbed.
python3 - "$ROOT" "$test_tmp" <<'PY'
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import sys
from unittest.mock import patch

root, temporary = map(Path, sys.argv[1:])
os.environ.update(HOME=str(temporary / "home"), XDG_STATE_HOME=str(temporary / "state"), XDG_CACHE_HOME=str(temporary / "cache"))

def load(name):
  loader = importlib.machinery.SourceFileLoader(name, str(root / "bin" / name))
  spec = importlib.util.spec_from_loader(loader.name, loader)
  module = importlib.util.module_from_spec(spec)
  loader.exec_module(module)
  return module

registry = load("omarchy-agent-account-state")
collectors = {provider: load("omarchy-agent-usage-" + provider) for provider in ["codex", "claude"]}
limits = [{"label": "weekly", "resetsAt": "2030-01-01T00:10:00Z"}]
collectors["codex"].fetch_codex_rpc = lambda *args: dict(limits=limits, tierLabel="", usageStatusText="", authHelpText="")
collectors["claude"].oauth_login = lambda *args: ("", 0, 0, "")
collectors["claude"].collect_limits = lambda *args: dict(limits=limits, live=False, fetchedAtMs=0, usageStatusText="", authHelpText="")

traces = []
for provider, collector in collectors.items():
  home = registry.primary_home(provider)
  home.mkdir(parents=True, exist_ok=True)
  path = registry.claude_account_file(home) if provider == "claude" else home / "auth.json"
  def credentials(identity):
    return {"oauthAccount": {"accountUuid": identity}} if provider == "claude" else {"tokens": {"account_id": identity}}
  path.write_text(json.dumps(credentials("original")))
  data = registry.empty_registry(provider)
  data["accounts"] = [registry.primary_entry(provider), {"id": "other", "label": "Other", "home": str(temporary / provider), "accountId": ""}]
  registry.save(provider, data)
  def record():
    registry.refresh(provider)
    status, accounts = collector.account_registry(provider)
    values = [collector.account_limits(a, True) for a in accounts]
    return dict(id=provider, name=provider, accountRegistryStatus=status, accounts=values)
  original = record()
  for failure in ["permission", "truncated", "invalid-shape", "invalid-account-shape"]:
    path.write_text(json.dumps(credentials("original")))
    registry.refresh(provider)
    read_text = Path.read_text
    def unreadable(current, *args, **kwargs):
      if current == path:
        raise PermissionError("simulated temporary identity read failure")
      return read_text(current, *args, **kwargs)
    if failure == "permission":
      with patch.object(Path, "read_text", unreadable):
        unavailable = record()
    else:
      if failure == "truncated": path.write_text('{')
      elif failure == "invalid-shape": path.write_text('[]')
      else: path.write_text(json.dumps({"oauthAccount" if provider == "claude" else "tokens": []}))
      unavailable = record()
    traces.append(dict(provider=provider, failure=failure, original=original, unavailable=unavailable))
  path.write_text(json.dumps(credentials("replacement")))
  replacement = record()
  path.write_text('{}')
  cleared = record()
  path.write_text(json.dumps(credentials("original")))
  registry.refresh(provider)
  path.unlink()
  missing = record()
  traces.append(dict(provider=provider, original=original, replacement=replacement, cleared=cleared, missing=missing))
(temporary / "traces.json").write_text(json.dumps(traces))
PY

export OMARCHY_IDENTITY_TRACES="$test_tmp/traces.json"
run_node_test <<'JS'
const fs = require('fs')
const model = requireFromRoot('shell/plugins/agents/LimitResetModel.js')
const traces = JSON.parse(fs.readFileSync(process.env.OMARCHY_IDENTITY_TRACES, 'utf8'))
const now = Date.parse('2030-01-01T00:00:00Z')
const due = Date.parse('2030-01-01T00:11:00Z')
const enabled = () => true
for (const trace of traces) {
  const pending = model.schedule({}, [trace.original], now, true, enabled)
  assertEqual(Object.keys(pending).length, 1, `${trace.provider} queues the original subscription deadline`)
  if (trace.failure) {
    const next = model.schedule(pending, [trace.unavailable], due, true, enabled)
    assertEqual(trace.unavailable.accounts[0].accountId, 'original', `${trace.provider} ${trace.failure} retains the last known identity`)
    const result = model.announce(next, due, true, enabled)
    assertEqual(result.notifications.length, 1, `${trace.provider} ${trace.failure} still announces a reset due during the read failure`)
    assertEqual(model.announce(result.pending, due, true, enabled).notifications.length, 0, `${trace.provider} ${trace.failure} announces only once`)
  } else {
    for (const state of ['replacement', 'cleared', 'missing']) {
      const next = model.schedule(pending, [trace[state]], due, true, enabled)
      assertEqual(model.announce(next, due, true, enabled).notifications.length, 0, `${trace.provider} ${state} retires the original subscription deadline`)
    }
  }
}
JS
