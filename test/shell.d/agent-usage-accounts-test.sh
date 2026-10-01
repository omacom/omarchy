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
unset CLAUDE_CONFIG_DIR CODEX_HOME

accounts="$XDG_STATE_HOME/omarchy/agents/accounts"
mkdir -p "$HOME/.claude/projects" "$HOME/.codex/sessions" "$accounts/claude/work" "$accounts/claude/old" "$accounts/codex/side"

future_ms=$(( ($(date +%s) + 3600) * 1000 ))
open_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=3)).isoformat())')

credentials() {
  printf '{"claudeAiOauth":{"accessToken":"%s","expiresAt":%s,"rateLimitTier":"%s","subscriptionType":"max"}}\n' "$1" "$2" "$3"
}
credentials token-main "$future_ms" default_claude_max_20x >"$HOME/.claude/.credentials.json"
credentials token-work "$future_ms" default_claude_max_5x >"$accounts/claude/work/.credentials.json"
credentials token-old 1000 default_claude_max_5x >"$accounts/claude/old/.credentials.json"

# A parked account whose sign-in lapsed still has its last numbers on disk.
mkdir -p "$XDG_CACHE_HOME/omarchy/agent-usage"
jq -nc --arg open "$open_at" '{fetchedAtMs: 1, limits: [{label: "Weekly (7-day)", percent: 0.4, resetsAt: $open}]}' \
  >"$XDG_CACHE_HOME/omarchy/agent-usage/claude-limits-old.json"

cat >"$accounts/claude.json" <<JSON
{
  "active": "work",
  "switch": "auto",
  "threshold": 95,
  "accounts": [
    {"id": "main", "label": "Main", "home": "", "primary": true, "email": "me@example.com"},
    {"id": "work", "label": "Work", "home": "$accounts/claude/work", "primary": false, "email": "work@example.com", "accountId": "u-work"},
    {"id": "old", "label": "Old", "home": "$accounts/claude/old", "primary": false, "email": "old@example.com"}
  ]
}
JSON

# Anthropic answers per token, so each account's probe is told apart by the
# credential it carried.
claude_record=$(COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

usage = {"token-main": 97.0, "token-work": 12.0}

def urlopen(request, timeout=None):
  token = request.get_header("Authorization").split(" ", 1)[1]
  return io.BytesIO(json.dumps({"five_hour": {"utilization": usage[token]}, "seven_day": {"utilization": 5.0}}).encode())

collector.urllib.request.urlopen = urlopen
collector.scan_pi_usage = lambda age: None
collector.scan_opencode_usage = lambda age: None
sys.argv = ["omarchy-agent-usage-claude", "--force"]
collector.main()
PY
)

[[ $(jq -c '[.accounts[] | {id, active, plan, stale}]' <<<"$claude_record") == '[{"id":"main","active":false,"plan":"Max 20x","stale":false},{"id":"work","active":true,"plan":"Max 5x","stale":false},{"id":"old","active":false,"plan":"Max 5x","stale":true}]' ]] ||
  fail "Claude record lists every account with its own plan" "$claude_record"
pass "Claude record lists every registered account"

[[ $(jq -c '[.accounts[] | .limits[0].percent]' <<<"$claude_record") == '[0.97,0.12,0.4]' ]] ||
  fail "Claude record probes each account with its own sign-in" "$claude_record"
pass "Claude record probes each account with its own sign-in"

[[ $(jq -r '.accounts[2].usageStatusText' <<<"$claude_record") == "Sign-in expired" ]] ||
  fail "a lapsed account keeps its last-known limits and says why" "$claude_record"
pass "a lapsed account keeps its last-known limits and says why"

[[ $(jq -c '{tierLabel, first: .limits[0].percent}' <<<"$claude_record") == '{"tierLabel":"Max 5x","first":0.12}' ]] ||
  fail "the record's own limits describe the active account" "$claude_record"
pass "the record's own limits describe the active account"

[[ -f $XDG_CACHE_HOME/omarchy/agent-usage/claude-limits.json && -f $XDG_CACHE_HOME/omarchy/agent-usage/claude-limits-u-work.json ]] ||
  fail "each account keeps its own limits cache, keyed by subscription"
pass "each account keeps its own limits cache"

# Once every window a lapsed account last saw has reset, it has its whole
# allowance back: that reads as 0%, not as nothing known.
past_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(minutes=5)).isoformat())')
jq -nc --arg past "$past_at" '{fetchedAtMs: 1, limits: [{label: "Session (5-hour)", percent: 0.99, resetsAt: $past}]}' \
  >"$XDG_CACHE_HOME/omarchy/agent-usage/claude-limits-old.json"
rested=$(COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
collector.urllib.request.urlopen = lambda request, timeout=None: io.BytesIO(b'{"five_hour": {"utilization": 30.0}}')
collector.scan_pi_usage = lambda age: None
collector.scan_opencode_usage = lambda age: None
sys.argv = ["omarchy-agent-usage-claude", "--force"]
collector.main()
PY
)
[[ $(jq -c '.accounts[2] | {stale, limits: [.limits[] | {label, empty: (.percent == 0)}]}' <<<"$rested") == '{"stale":true,"limits":[{"label":"Session (5-hour)","empty":true}]}' ]] ||
  fail "a lapsed account whose windows all reset reads as untouched" "$rested"
pass "a lapsed account whose windows all reset reads as untouched"

# Signing the primary home in to another subscription must not inherit the
# last one's numbers when the first probe for the new one fails.
printf '{"oauthAccount":{"accountUuid":"u-new"}}\n' >"$HOME/.claude.json"
now_ms=$(( $(date +%s) * 1000 ))
jq -nc --arg open "$open_at" --argjson now "$now_ms" '{fetchedAtMs: $now, limits: [{label: "Session (5-hour)", percent: 0.55, resetsAt: $open}]}' \
  >"$XDG_CACHE_HOME/omarchy/agent-usage/claude-limits.json"
resigned=$(COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

def urlopen(request, timeout=None):
  if request.get_header("Authorization").endswith("token-main"):
    raise collector.urllib.error.URLError("down")
  return io.BytesIO(b'{"five_hour": {"utilization": 12.0}}')

collector.urllib.request.urlopen = urlopen
collector.scan_pi_usage = lambda age: None
collector.scan_opencode_usage = lambda age: None
sys.argv = ["omarchy-agent-usage-claude", "--force"]
collector.main()
PY
)
[[ $(jq -c '.accounts[0].limits | map(.percent)' <<<"$resigned") != *0.55* ]] ||
  fail "a primary home signed in to another subscription doesn't inherit its limits" "$resigned"
rm -f "$HOME/.claude.json"
pass "a primary home signed in to another subscription doesn't inherit its limits"

# A registry with one account changes nothing about the record.
jq '.accounts |= [.[0]] | .active = "main"' "$accounts/claude.json" >"$test_tmp/one.json"
mv "$test_tmp/one.json" "$accounts/claude.json"
single=$(COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
collector.urllib.request.urlopen = lambda request, timeout=None: io.BytesIO(b'{"five_hour": {"utilization": 30.0}}')
collector.scan_pi_usage = lambda age: None
collector.scan_opencode_usage = lambda age: None
sys.argv = ["omarchy-agent-usage-claude", "--force"]
collector.main()
PY
)
[[ $(jq 'has("accounts")' <<<"$single") == false && $(jq '.limits[0].percent' <<<"$single") == 0.3 ]] ||
  fail "a single account record carries no accounts list" "$single"
pass "a single account record is unchanged"

[[ $(jq -c '{limitsStale, fresh: (.limitsFetchedAt > 0)}' <<<"$single") == '{"limitsStale":false,"fresh":true}' ]] ||
  fail "limits checked just now aren't stale" "$single"
# A failed probe falls back on hour-old numbers, and the record says so.
hour_ago_ms=$(( ($(date +%s) - 3600) * 1000 ))
jq -nc --arg open "$open_at" --argjson at "$hour_ago_ms" '{fetchedAtMs: $at, limits: [{label: "Session (5-hour)", percent: 0.42, resetsAt: $open}]}' \
  >"$XDG_CACHE_HOME/omarchy/agent-usage/claude-limits.json"
kept=$(COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" python3 - <<'PY'
import importlib.machinery, importlib.util, os, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

def urlopen(request, timeout=None):
  raise collector.urllib.error.URLError("down")

collector.urllib.request.urlopen = urlopen
collector.scan_pi_usage = lambda age: None
collector.scan_opencode_usage = lambda age: None
sys.argv = ["omarchy-agent-usage-claude", "--force"]
collector.main()
PY
)
[[ $(jq -c --argjson at "$hour_ago_ms" '{limitsStale, at: (.limitsFetchedAt == $at), first: .limits[0].percent}' <<<"$kept") == '{"limitsStale":true,"at":true,"first":0.42}' ]] ||
  fail "kept limits are marked stale with when they were measured" "$kept"
pass "the record says when its limits are kept from an earlier check"

# ------------------------------------------------------------------------ codex

# A stand-in app-server that answers for whichever home it was started in.
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/codex" <<'PY'
#!/usr/bin/python3
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
chmod +x "$test_tmp/bin/codex"

cat >"$accounts/codex.json" <<JSON
{
  "active": "main",
  "accounts": [
    {"id": "main", "label": "Main", "home": "", "primary": true},
    {"id": "side", "label": "Side", "home": "$accounts/codex/side", "primary": false}
  ]
}
JSON

codex_record=$(PATH="$test_tmp/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --force)
[[ $(jq -c '[.accounts[] | {id, active, used: .limits[0].percent}]' <<<"$codex_record") == '[{"id":"main","active":true,"used":0.4},{"id":"side","active":false,"used":0.91}]' ]] ||
  fail "Codex record asks each account's own app-server" "$codex_record"
[[ $(jq '.limits[0].percent' <<<"$codex_record") == 0.4 ]] || fail "Codex record's own limits describe the active account" "$codex_record"
pass "Codex record lists every registered account"

inherited=$(CODEX_HOME="$accounts/codex/side" PATH="$test_tmp/bin:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --force)
[[ $(jq -c '[.accounts[] | .limits[0].percent]' <<<"$inherited") == '[0.4,0.91]' ]] ||
  fail "Main's Codex limits come from ~/.codex whatever CODEX_HOME says" "$inherited"
pass "Main's Codex limits come from ~/.codex whatever CODEX_HOME says"
