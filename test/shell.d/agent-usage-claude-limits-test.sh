#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

# probe_limits reaches Anthropic, so the reader that interprets its answer is
# exercised on its own: the collector loads as a module, and a recorded payload
# stands in for the response.
read_limits() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" PAYLOAD="$1" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

collector.urllib.request.urlopen = lambda request, timeout=None: io.BytesIO(os.environ["PAYLOAD"].encode())

print(json.dumps(collector.probe_limits("token")))
PY
}

# The two flat buckets, then every scoped shape that matters: a model's weekly
# window, a second window for that same model, a model that names only an id,
# and — dropped — a repeat of a window already read, a blank name, and a
# percent that will not parse.
limits=$(read_limits '{
  "five_hour": { "utilization": 78.0 },
  "seven_day": { "utilization": 12.0 },
  "seven_day_opus": null,
  "limits": [
    { "kind": "session", "percent": 78, "scope": null },
    { "kind": "weekly_all", "percent": 12, "scope": null },
    { "kind": "weekly_scoped", "percent": 17, "resets_at": "2026-08-15T03:00:00+00:00",
      "scope": { "model": { "id": "claude-fable-5", "display_name": "Fable" }, "surface": null } },
    { "kind": "weekly_scoped", "percent": 99, "scope": { "model": { "display_name": "Fable" } } },
    { "kind": "five_hour_scoped", "percent": 95, "scope": { "model": { "display_name": "Fable" } } },
    { "kind": "weekly_scoped", "percent": 42, "scope": { "model": { "id": "claude-opus-5", "display_name": null } } },
    { "kind": "weekly_scoped", "percent": 5, "scope": { "model": { "display_name": "  " } } },
    { "kind": "weekly_scoped", "percent": "unknown", "scope": { "model": { "display_name": "Opus" } } }
  ]
}')

expected='[{"label":"Session (5-hour)","percent":0.78,"resetsAt":""},{"label":"Weekly (7-day)","percent":0.12,"resetsAt":""},{"label":"Fable Weekly","title":"Fable Weekly","percent":0.17,"resetsAt":"2026-08-15T03:00:00+00:00"},{"label":"Fable Session","title":"Fable Session","percent":0.95,"resetsAt":""},{"label":"claude-opus-5 Weekly","title":"claude-opus-5 Weekly","percent":0.42,"resetsAt":""}]'
[[ $(jq -c '.limits' <<<"$limits") == "$expected" ]] ||
  fail "Claude collector reads every model-scoped window once and drops unusable entries" "$limits"
pass "Claude collector reads every model-scoped window once and drops unusable entries"

# A payload that speaks fractions says so in its buckets, and the scoped
# entries are read on the same scale rather than assuming percentages.
fractions=$(read_limits '{
  "five_hour": { "utilization": 0.78 },
  "limits": [
    { "kind": "session", "percent": 0.78, "scope": null },
    { "kind": "weekly_scoped", "percent": 0.42, "scope": { "model": { "display_name": "Fable" } } }
  ]
}')

[[ $(jq -c '[.limits[].percent]' <<<"$fractions") == "[0.78,0.42]" ]] ||
  fail "Claude collector reads scoped percentages on the payload's own scale" "$fractions"
pass "Claude collector reads scoped percentages on the payload's own scale"

# An account with no model-scoped allowance, and an endpoint that never grew
# the array, both keep the session and weekly windows they always had.
for payload in '{"five_hour":{"utilization":78.0},"limits":[{"kind":"session","percent":78,"scope":null}]}' \
  '{"five_hour":{"utilization":78.0},"seven_day":{"utilization":12.0}}'; do
  [[ $(jq -c '[.limits[].label]' <<<"$(read_limits "$payload")") != *" Weekly"* ]] ||
    fail "Claude collector adds no limit when the payload scopes none" "$payload"
done
pass "Claude collector adds no limit when the payload scopes none"

# The saved login carries two plan facts: the subscription and the rate-limit
# tier it runs under. Read the label off a planted credential store so the
# whole path is exercised, not just the formatter.
plan_label() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" TIER="$1" SUBSCRIPTION="$2" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os, pathlib, tempfile

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

claude_dir = pathlib.Path(tempfile.mkdtemp())
(claude_dir / ".credentials.json").write_text(json.dumps({"claudeAiOauth": {
  "accessToken": "token", "expiresAt": 1,
  "rateLimitTier": os.environ["TIER"], "subscriptionType": os.environ["SUBSCRIPTION"],
}}), encoding="utf-8")
print(collector.oauth_login(claude_dir)[-1])
PY
}

# A Team premium seat runs on the Max 5x rate-limit tier, and the tier alone
# used to label it "Max 5x" — the plan the seat is not on.
[[ $(plan_label default_claude_max_5x team) == "Team 5x" ]] ||
  fail "Claude collector labels a Team seat by its subscription, not its rate-limit tier" "$(plan_label default_claude_max_5x team)"
pass "Claude collector labels a Team seat by its subscription, not its rate-limit tier"

# Max keeps its multiplier, with or without a subscription type alongside the
# tier, and a plan whose tier names no multiplier is just the plan.
[[ $(plan_label default_claude_max_20x max) == "Max 20x" && $(plan_label default_claude_max_5x "") == "Max 5x" ]] ||
  fail "Claude collector still labels Max by its multiplier" "$(plan_label default_claude_max_20x max) / $(plan_label default_claude_max_5x "")"
[[ $(plan_label default_claude_pro pro) == "Pro" && $(plan_label "" team) == "Team" ]] ||
  fail "Claude collector labels a plan without a multiplier by its subscription alone" "$(plan_label default_claude_pro pro) / $(plan_label "" team)"
pass "Claude collector keeps Max multipliers and plain plan names"

# Only the Claude Code CLI refreshes the saved tokens, so between its runs the
# collector can find the access token lapsed while the refresh token behind it
# is still good. Drive collect_limits over a planted cache with the network
# unreachable, so nothing but the credential state decides the answer.
CACHE_HOME=$(mktemp -d)
trap 'rm -rf "$CACHE_HOME"' EXIT

collect_limits() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" TOKEN="$1" EXPIRES_AT="$2" \
    REFRESH_EXPIRES_AT="$3" CACHED="$4" CACHE_MTIME_OFFSET="${5:-0}" \
    XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os, pathlib, time

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

digest = __import__("hashlib").sha1(str(collector.config_dir()).encode("utf-8")).hexdigest()[:16]
cache = collector.cache_root() / f"claude-limits-{digest}.json"
cached = os.environ["CACHED"]
if cached:
  cache.write_text(cached, encoding="utf-8")
  offset = float(os.environ["CACHE_MTIME_OFFSET"])
  if offset:
    timestamp = time.time() + offset
    os.utime(cache, (timestamp, timestamp))
elif cache.exists():
  cache.unlink()

def unreachable(request, timeout=None):
  raise OSError("no route to host")

collector.urllib.request.urlopen = unreachable
print(json.dumps(collector.collect_limits(
  os.environ["TOKEN"],
  int(os.environ["EXPIRES_AT"]),
  int(os.environ["REFRESH_EXPIRES_AT"]),
  False,
)))
PY
}

# An open window and one that already reset, cached long enough ago that a live
# token would re-probe rather than reuse them.
open_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=3)).isoformat())')
past_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=3)).isoformat())')
cache=$(jq -nc --arg open "$open_at" --arg past "$past_at" '{
  fetchedAtMs: 1,
  limits: [
    { label: "Session (5-hour)", percent: 0.31, resetsAt: $past },
    { label: "Weekly (7-day)", percent: 0.11, resetsAt: $open }
  ]
}')

# Both tokens lapsed is a genuine sign-out. It used to return an empty limits
# list and no status at all, which hides the panel's whole limits section
# without saying why.
expired=$(collect_limits "token" 1000 1000 "$cache")
[[ $(jq -r '.usageStatusText' <<<"$expired") == "Sign-in expired" ]] ||
  fail "Claude collector reports an expired sign-in" "$expired"
[[ $(jq -r '.authHelpText' <<<"$expired") == *"claude auth login"* ]] ||
  fail "Claude collector says how to refresh an expired sign-in" "$expired"
pass "Claude collector reports an expired sign-in instead of hiding the section"

# The elapsed session resets to zero while the weekly usage stays intact.
[[ $(jq -c '[.limits[].label]' <<<"$expired") == '["Session (5-hour)","Weekly (7-day)"]' ]] ||
  fail "Claude collector keeps cached windows and resets elapsed ones" "$expired"
[[ $(jq '[.limits[].percent] == [0,0.11]' <<<"$expired") == "true" && $(jq -r '.limits[0].resetsAt' <<<"$expired") == "" ]] ||
  fail "Claude collector resets just the elapsed window" "$expired"
pass "Claude collector keeps cached windows and resets elapsed ones"

# A wholly reset cache still shows the empty allowance.
stale=$(collect_limits "token" 1000 1000 "$(jq -c '.limits |= [.[0]]' <<<"$cache")")
[[ $(jq '.limits | map(.percent) == [0]' <<<"$stale") == "true" && $(jq -r '.usageStatusText' <<<"$stale") == "Sign-in expired" ]] ||
  fail "Claude collector resets a wholly elapsed cache to zero" "$stale"
[[ $(jq -r '.authHelpText' <<<"$stale") == *"last known"* ]] ||
  fail "Claude collector keeps the timestamp and guidance for a reset cache" "$stale"
pass "Claude collector resets a wholly elapsed cache to zero"

# The access token lives about eight hours; the refresh token behind it lives
# about thirty days, and the CLI mints a new access token from it on its next
# run. A machine left overnight finds the first lapsed and the second fine --
# routine, and nothing a person fixes by signing in again.
live_refresh=$(python3 -c 'import time; print(round((time.time() + 30 * 86400) * 1000))')
paused=$(collect_limits "token" 1000 "$live_refresh" "$cache")
[[ $(jq -r '.usageStatusText' <<<"$paused") == "Limits paused" ]] ||
  fail "Claude collector calls a lapsed access token paused, not signed out" "$paused"
[[ $(jq -r '.authHelpText' <<<"$paused") != *"claude auth login"* ]] ||
  fail "Claude collector does not send a signed-in machine back through login" "$paused"
[[ $(jq -c '[.limits[].label]' <<<"$paused") == '["Session (5-hour)","Weekly (7-day)"]' ]] ||
  fail "Claude collector keeps open cached windows while the access token is stale" "$paused"
pass "Claude collector calls a lapsed access token paused, not signed out"

# A signed-out machine says so, and still shows what it last knew.
signed_out=$(collect_limits "" 0 0 "$cache")
[[ $(jq -r '.usageStatusText' <<<"$signed_out") == "Waiting for auth" ]] ||
  fail "Claude collector still reports a missing token" "$signed_out"
[[ $(jq -c '[.limits[].label]' <<<"$signed_out") == '["Session (5-hour)","Weekly (7-day)"]' ]] ||
  fail "Claude collector serves open cached windows without a token" "$signed_out"
pass "Claude collector serves open cached windows without a token"

# The limits cache is a last-known fallback governed by each window's reset
# time, not by the file's age. A backwards clock correction must not discard
# an otherwise open fallback when no token is available to replace it.
future_fallback=$(collect_limits "" 0 0 "$cache" 3600)
[[ $(jq -c '[.limits[].label]' <<<"$future_fallback") == '["Session (5-hour)","Weekly (7-day)"]' ]] ||
  fail "Claude collector keeps open fallback limits after a backwards clock correction" "$future_fallback"
pass "Claude collector keeps open fallback limits after a backwards clock correction"

# A live token that cannot reach the endpoint keeps the old contract: the open
# window stands in, and the shell is asked to retry sooner than its interval.
unreachable=$(collect_limits "token" 0 0 "$cache")
[[ $(jq -c '[.limits[].label]' <<<"$unreachable") == '["Session (5-hour)","Weekly (7-day)"]' ]] ||
  fail "Claude collector falls back to cache when the probe cannot connect" "$unreachable"
[[ $(jq -r '.retryAdvised' <<<"$unreachable") == "true" ]] ||
  fail "Claude collector advises a retry after a transport failure" "$unreachable"
pass "Claude collector falls back to cache when the probe cannot connect"

# Reuse and --force are decided against a cache that is fresh by the clock, so
# the probe is answered rather than refused: what matters is whether it ran.
probe_with_cache() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" FORCE="$1" CACHED="$2" PAYLOAD="$3" CACHE_MTIME_OFFSET="${4:-0}" \
    XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, time

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

digest = __import__("hashlib").sha1(str(collector.config_dir()).encode("utf-8")).hexdigest()[:16]
cache = collector.cache_root() / f"claude-limits-{digest}.json"
cache.write_text(os.environ["CACHED"], encoding="utf-8")
offset = float(os.environ["CACHE_MTIME_OFFSET"])
if offset:
  timestamp = time.time() + offset
  os.utime(cache, (timestamp, timestamp))

probes = []

def urlopen(request, timeout=None):
  probes.append(1)
  return io.BytesIO(os.environ["PAYLOAD"].encode())

collector.urllib.request.urlopen = urlopen
result = collector.collect_limits("token", 0, 0, os.environ["FORCE"] == "true")
print(json.dumps({
  "result": result,
  "probes": len(probes),
  "cached": json.loads(cache.read_text(encoding="utf-8")),
}))
PY
}

fresh=$(jq -nc --arg open "$open_at" --argjson now "$(python3 -c 'import time; print(round(time.time() * 1000))')" '{
  fetchedAtMs: $now,
  limits: [{ label: "Weekly (7-day)", percent: 0.11, resetsAt: $open }]
}')
payload='{"five_hour":{"utilization":44.0}}'

# Repeated panel opens share one answer rather than one request apiece.
reused=$(probe_with_cache false "$fresh" "$payload")
[[ $(jq -r '.probes' <<<"$reused") == "0" && $(jq -c '[.result.limits[].percent]' <<<"$reused") == "[0.11]" ]] ||
  fail "Claude collector reuses a cache younger than the probe interval" "$reused"
[[ $(jq -r '.result.authHelpText' <<<"$reused") == "" ]] ||
  fail "Claude collector clears login guidance when reusing authenticated limits" "$reused"
pass "Claude collector reuses a cache younger than the probe interval"

# An early boot probe can be stamped ahead of corrected wall time when NTP
# moves the clock backwards. That cache must not suppress live probes until
# the clock catches up.
future=$(jq -nc --arg open "$open_at" --argjson future "$(python3 -c 'import time; print(round((time.time() + 3600) * 1000))')" '{
  fetchedAtMs: $future,
  limits: [{ label: "Weekly (7-day)", percent: 0.11, resetsAt: $open }]
}')

# If the clock correction makes a probe necessary but that probe cannot
# connect, the cache remains the last-known answer. Its reset time, rather than
# its future mtime, decides whether the fallback is still usable.
future_unreachable=$(collect_limits "token" 0 0 "$future" 3600)
[[ $(jq -c '[.limits[].percent]' <<<"$future_unreachable") == "[0.11]" && $(jq -r '.retryAdvised' <<<"$future_unreachable") == "true" ]] ||
  fail "Claude collector keeps future-dated fallback when the re-probe fails" "$future_unreachable"
pass "Claude collector keeps future-dated fallback when the re-probe fails"

# Numbers stamped in the future have no age to trust, so a kept fallback is
# reported as stale rather than as measured just now.
[[ $(jq -r '.live' <<<"$future_unreachable") == "false" ]] ||
  fail "Claude collector marks a future-dated fallback stale" "$future_unreachable"
pass "Claude collector marks a future-dated fallback stale"

corrected=$(probe_with_cache false "$future" "$payload" 3600)
[[ $(jq -r '.probes' <<<"$corrected") == "1" && $(jq -c '[.result.limits[].percent]' <<<"$corrected") == "[0.44]" ]] ||
  fail "Claude collector re-probes after a backwards clock correction" "$corrected"
pass "Claude collector re-probes after a backwards clock correction"

# --force is someone pressing refresh, and its help text promises the caches are
# ignored — so the reuse window must not outrank it.
forced=$(probe_with_cache true "$fresh" "$payload")
[[ $(jq -r '.probes' <<<"$forced") == "1" ]] ||
  fail "Claude collector re-probes on --force despite a fresh cache" "$forced"
[[ $(jq -c '[.result.limits[].percent]' <<<"$forced") == "[0.44]" ]] ||
  fail "Claude collector returns the forced probe's numbers" "$forced"
[[ $(jq -r '.result.authHelpText' <<<"$forced") == "" ]] ||
  fail "Claude collector clears login guidance after a successful probe" "$forced"
pass "Claude collector re-probes on --force despite a fresh cache"

# A probe that lands becomes the next run's fallback.
[[ $(jq -c '[.cached.limits[].percent]' <<<"$forced") == "[0.44]" ]] ||
  fail "Claude collector caches a successful probe" "$forced"
pass "Claude collector caches a successful probe"

# Two CLAUDE_CONFIG_DIR accounts must not share a limits cache: each config
# directory gets its own digests file, and a leftover unkeyed file is dropped
# so it cannot keep leaking the last account that wrote it.
isolate_limits=$(COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import hashlib
import importlib.machinery
import importlib.util
import io
import json
import os
from pathlib import Path

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

root = Path(os.environ["XDG_CACHE_HOME"]) / "omarchy" / "agent-usage"
root.mkdir(parents=True, exist_ok=True)
legacy = root / "claude-limits.json"
legacy.write_text('{"fetchedAtMs":1,"limits":[{"label":"Weekly (7-day)","percent":0.99,"resetsAt":""}]}', encoding="utf-8")
legacy.chmod(0o644)

def payload_for(percent):
  return json.dumps({"five_hour": {"utilization": percent}}).encode()

paths = []
for name, percent in (("account-a", 10.0), ("account-b", 80.0)):
  config = Path(os.environ["XDG_CACHE_HOME"]) / name
  config.mkdir(parents=True, exist_ok=True)
  os.environ["CLAUDE_CONFIG_DIR"] = str(config)
  collector.urllib.request.urlopen = lambda request, timeout=None, percent=percent: io.BytesIO(payload_for(percent))
  collector.collect_limits("token", 0, 0, True, "claude-limits.json" if name == "account-a" else None)
  digest = hashlib.sha1(str(collector.config_dir()).encode("utf-8")).hexdigest()[:16]
  path = root / f"claude-limits-{digest}.json"
  paths.append(str(path))
  assert path.is_file(), path
  assert (path.stat().st_mode & 0o777) == 0o600, oct(path.stat().st_mode)
  cached = json.loads(path.read_text(encoding="utf-8"))
  assert cached["limits"][0]["percent"] == percent / 100.0, cached

print(json.dumps({
  "paths": paths,
  "distinct": paths[0] != paths[1],
  "legacyGone": not legacy.exists(),
  "dirMode": oct(root.stat().st_mode & 0o777),
}))
PY
)

[[ $(jq -r '.distinct' <<<"$isolate_limits") == "true" ]] ||
  fail "Claude collector keys limits caches by CLAUDE_CONFIG_DIR" "$isolate_limits"
[[ $(jq -r '.legacyGone' <<<"$isolate_limits") == "true" ]] ||
  fail "Claude collector removes the unkeyed limits cache" "$isolate_limits"
[[ $(jq -r '.dirMode' <<<"$isolate_limits") == "0o700" ]] ||
  fail "Claude collector keeps the usage cache directory owner-only" "$isolate_limits"
pass "Claude collector isolates limits caches across CLAUDE_CONFIG_DIR"

# The panel reads a window out of a label, and that guess cannot survive a
# model name — "Opus 5 (1M context)" parses as a one-minute window. A collector
# that states the title outright is taken at its word.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const panelRoot = { nowMs: Date.now() }
const start = source.indexOf('function windowIsLong')
const end = source.indexOf('// The window that decides')
assert(start > 0 && end > start, 'agents panel exposes its limit-window helpers')
eval(source.slice(start, end).replaceAll('root.nowMs', 'panelRoot.nowMs'))
eval(source.slice(source.indexOf('function needsSignIn'), source.indexOf('// Sign an account')))

const paused = { usageStatusText: 'Limits paused', limits: [] }
assertEqual(pausedWithoutLimits(paused), true, 'paused usage without a cache shows a recovery placeholder')
assertEqual(otherTrouble(paused), '', 'paused usage never puts the confusing status in the header')
assertEqual(pausedWithoutLimits({ ...paused, limits: [{ label: 'Session (5-hour)', percent: 0, resetsAt: '' }] }), false, 'cached usage replaces the recovery placeholder')
assertEqual(pausedWithoutLimits({ usageStatusText: 'Sign-in expired', limits: [] }), false, 'expired sign-ins retain their sign-in action')
assertEqual(pausedWithoutLimits(null), false, 'missing records do not show a paused-usage placeholder')

assertDeepEqual(
  limitWindows({ limits: [
    { label: 'Session (5-hour)', percent: 0.78, resetsAt: '' },
    { label: 'Opus 5 (1M context) Weekly', title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetsAt: '' }
  ] }),
  [
    { title: 'Session', percent: 0.78, resetAt: '' },
    { title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetAt: '' }
  ],
  'agents panel titles a limit off the collector when it states one'
)

assertDeepEqual(
  limitWindows({ limits: [{ label: 'Weekly (7-day)', percent: 0.12, resetsAt: '' }] }),
  [{ title: 'Weekly', percent: 0.12, resetAt: '' }],
  'agents panel still reads a window out of a label that carries no title'
)

const resetAt = new Date(panelRoot.nowMs + 1000).toISOString()
const measured = { limits: [{ label: 'Session (5-hour)', percent: 0.78, resetsAt: resetAt }] }
assertEqual(limitWindows(measured)[0].percent, 0.78, 'usage remains until the reset time')
panelRoot.nowMs += 1000
assertDeepEqual(limitWindows(measured), [{ title: 'Session', percent: 0, resetAt: '' }], 'usage resets at the deadline while the panel stays open')
assertEqual(measured.limits[0].percent, 0.78, 'display reset leaves the measured record intact')

// A model's weekly allowance rides under the Weekly row; one whose window has
// no row of its own keeps a row.
assertDeepEqual(
  displayWindows({ limits: [
    { label: 'Session (5-hour)', percent: 0.94, resetsAt: '' },
    { label: 'Weekly (7-day)', percent: 0.25, resetsAt: 'w' },
    { label: 'Fable Weekly', title: 'Fable Weekly', percent: 0.09, resetsAt: 'w' },
    { label: 'Opus Monthly', title: 'Opus Monthly', percent: 0.5, resetsAt: '' }
  ] }),
  [
    { title: 'Session', percent: 0.94, resetAt: '', scoped: [] },
    { title: 'Weekly', percent: 0.25, resetAt: 'w', scoped: [{ title: 'Fable', percent: 0.09, resetAt: 'w' }] },
    { title: 'Opus Monthly', percent: 0.5, resetAt: '', scoped: [] }
  ],
  'agents panel shows a model-scoped window under the window it runs on'
)
JS

# Anthropic rate-limits its usage endpoint readily. A refused re-check of
# numbers measured minutes ago still describes the account; only older numbers
# count as stale, and either way the record says when they were measured.
rate_limited() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" FETCHED_AGO="$1" XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import datetime as dt, importlib.machinery, importlib.util, json, os, time, urllib.error

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

reset = (dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=3)).isoformat()
fetched = round((time.time() - float(os.environ["FETCHED_AGO"])) * 1000)
(collector.cache_root() / "claude-limits-rate.json").write_text(json.dumps(
  {"fetchedAtMs": fetched, "limits": [{"label": "Session (5-hour)", "percent": 0.4, "resetsAt": reset}]}))

def refused(request, timeout=None):
  raise urllib.error.HTTPError(request.full_url, 429, "Too Many Requests", {}, None)

collector.urllib.request.urlopen = refused
result = collector.collect_limits("token", int((time.time() + 3600) * 1000), 0, True, "claude-limits-rate.json")
print(json.dumps({"live": result["live"], "percent": result["limits"][0]["percent"], "fetched": result["fetchedAtMs"] == fetched}))
PY
}

[[ $(rate_limited 60) == '{"live": true, "percent": 0.4, "fetched": true}' ]] ||
  fail "a refused re-check of numbers a minute old still counts as current" "$(rate_limited 60)"
[[ $(rate_limited 1800) == '{"live": false, "percent": 0.4, "fetched": true}' ]] ||
  fail "a refused re-check of half-hour-old numbers counts as stale" "$(rate_limited 1800)"
pass "a rate-limited check only goes stale once the numbers are old"
