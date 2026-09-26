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

# Only the Claude Code CLI refreshes the saved token, so between its runs the
# collector can find a lapsed one. Drive collect_limits over a planted cache
# with the network unreachable, so nothing but the credential state decides
# the answer.
CACHE_HOME=$(mktemp -d)
trap 'rm -rf "$CACHE_HOME"' EXIT

collect_limits() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" TOKEN="$1" EXPIRES_AT="$2" CACHED="$3" \
    XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os, pathlib

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

cache = collector.cache_root() / "claude-limits.json"
cached = os.environ["CACHED"]
if cached:
  cache.write_text(cached, encoding="utf-8")
elif cache.exists():
  cache.unlink()

def unreachable(request, timeout=None):
  raise OSError("no route to host")

collector.urllib.request.urlopen = unreachable
print(json.dumps(collector.collect_limits(os.environ["TOKEN"], int(os.environ["EXPIRES_AT"]), False)))
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

# An expired token used to return an empty limits list and no status at all,
# which hides the panel's whole limits section without saying why.
expired=$(collect_limits "token" 1000 "$cache")
[[ $(jq -r '.usageStatusText' <<<"$expired") == "Sign-in expired" ]] ||
  fail "Claude collector reports an expired sign-in" "$expired"
[[ $(jq -r '.authHelpText' <<<"$expired") == *"claude auth login"* ]] ||
  fail "Claude collector says how to refresh an expired sign-in" "$expired"
pass "Claude collector reports an expired sign-in instead of hiding the section"

# The window that has not reset is still true; the one that has is not.
[[ $(jq -c '[.limits[].label]' <<<"$expired") == '["Weekly (7-day)"]' ]] ||
  fail "Claude collector keeps only cached windows that have not reset" "$expired"
pass "Claude collector keeps only cached windows that have not reset"

# Nothing worth showing: the status still explains the silence.
stale=$(collect_limits "token" 1000 "$(jq -c '.limits |= [.[0]]' <<<"$cache")")
[[ $(jq -c '.limits' <<<"$stale") == "[]" && $(jq -r '.usageStatusText' <<<"$stale") == "Sign-in expired" ]] ||
  fail "Claude collector drops a wholly reset cache but keeps explaining itself" "$stale"
[[ $(jq -r '.authHelpText' <<<"$stale") != *"last known"* ]] ||
  fail "Claude collector promises no last-known limits when it has none" "$stale"
pass "Claude collector drops a wholly reset cache but keeps explaining itself"

# A signed-out machine says so, and still shows what it last knew.
signed_out=$(collect_limits "" 0 "$cache")
[[ $(jq -r '.usageStatusText' <<<"$signed_out") == "Waiting for auth" ]] ||
  fail "Claude collector still reports a missing token" "$signed_out"
[[ $(jq -c '[.limits[].label]' <<<"$signed_out") == '["Weekly (7-day)"]' ]] ||
  fail "Claude collector serves open cached windows without a token" "$signed_out"
pass "Claude collector serves open cached windows without a token"

# A live token that cannot reach the endpoint keeps the old contract: the open
# window stands in, and the shell is asked to retry sooner than its interval.
unreachable=$(collect_limits "token" 0 "$cache")
[[ $(jq -c '[.limits[].label]' <<<"$unreachable") == '["Weekly (7-day)"]' ]] ||
  fail "Claude collector falls back to cache when the probe cannot connect" "$unreachable"
[[ $(jq -r '.retryAdvised' <<<"$unreachable") == "true" ]] ||
  fail "Claude collector advises a retry after a transport failure" "$unreachable"
pass "Claude collector falls back to cache when the probe cannot connect"

# Reuse and --force are decided against a cache that is fresh by the clock, so
# the probe is answered rather than refused: what matters is whether it ran.
probe_with_cache() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" FORCE="$1" CACHED="$2" PAYLOAD="$3" \
    XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

cache = collector.cache_root() / "claude-limits.json"
cache.write_text(os.environ["CACHED"], encoding="utf-8")

probes = []

def urlopen(request, timeout=None):
  probes.append(1)
  return io.BytesIO(os.environ["PAYLOAD"].encode())

collector.urllib.request.urlopen = urlopen
result = collector.collect_limits("token", 0, os.environ["FORCE"] == "true")
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
pass "Claude collector reuses a cache younger than the probe interval"

# Inside the reuse window the cache is the answer the last probe gave, credit
# window and all. Only a fallback leaves the money out.
fresh_credits=$(jq -c --arg open "$open_at" '.limits += [{
  label: "Usage credits", title: "Usage credits", percent: 0.92, resetsAt: $open,
  spend: { used: 458.2, limit: 500.0, currency: "EUR" }
}]' <<<"$fresh")
reused_credits=$(probe_with_cache false "$fresh_credits" "$payload")
[[ $(jq -r '.probes' <<<"$reused_credits") == "0" && $(jq -c '[.result.limits[].label]' <<<"$reused_credits") == '["Weekly (7-day)","Usage credits"]' ]] ||
  fail "Claude collector reuses a fresh cache with its credit window" "$reused_credits"
pass "Claude collector reuses a fresh cache with its credit window"

# --force is someone pressing refresh, and its help text promises the caches are
# ignored — so the reuse window must not outrank it.
forced=$(probe_with_cache true "$fresh" "$payload")
[[ $(jq -r '.probes' <<<"$forced") == "1" ]] ||
  fail "Claude collector re-probes on --force despite a fresh cache" "$forced"
[[ $(jq -c '[.result.limits[].percent]' <<<"$forced") == "[0.44]" ]] ||
  fail "Claude collector returns the forced probe's numbers" "$forced"
pass "Claude collector re-probes on --force despite a fresh cache"

# A probe that lands becomes the next run's fallback.
[[ $(jq -c '[.cached.limits[].percent]' <<<"$forced") == "[0.44]" ]] ||
  fail "Claude collector caches a successful probe" "$forced"
pass "Claude collector caches a successful probe"

# The monetary credit allowance rides in the same payload and is read as one
# more window: a percentage of the cap, the amounts behind it, and a reset on
# the first of the coming month.
credits=$(read_limits '{
  "five_hour": { "utilization": 0.0 },
  "spend": {
    "enabled": true,
    "used": { "amount_minor": 45820, "currency": "EUR", "exponent": 2 },
    "limit": { "amount_minor": 50000, "currency": "EUR", "exponent": 2 }
  }
}')

[[ $(jq -c '.limits[-1] | del(.resetsAt)' <<<"$credits") == '{"label":"Usage credits","title":"Usage credits","percent":0.9164,"spend":{"used":458.2,"limit":500.0,"currency":"EUR"}}' ]] ||
  fail "Claude collector reads the usage-credit allowance as a limit window" "$credits"
pass "Claude collector reads the usage-credit allowance as a limit window"

[[ $(jq -r '.limits[-1].resetsAt' <<<"$credits") == *-01T00:00:00* ]] ||
  fail "Claude collector resets the credit window on the first of the coming month" "$credits"
pass "Claude collector resets the credit window on the first of the coming month"

# Spending past the cap is possible; a meter past full is not.
over=$(read_limits '{
  "five_hour": { "utilization": 0.0 },
  "spend": {
    "enabled": true,
    "used": { "amount_minor": 60000, "currency": "EUR", "exponent": 2 },
    "limit": { "amount_minor": 50000, "currency": "EUR", "exponent": 2 }
  }
}')

[[ $(jq -c '.limits[-1].percent' <<<"$over") == "1.0" ]] ||
  fail "Claude collector holds the credit window at full when spending passes the cap" "$over"
pass "Claude collector holds the credit window at full when spending passes the cap"

# Accounts without credits: a plan that never had them says nothing at all,
# one with them switched off says so, and a prepaid ledger names credits
# rather than a cap. None of them earn a window, and none of them may cost
# the account the rate limit windows it does have.
for payload in \
  '{"five_hour":{"utilization":0.0}}' \
  '{"five_hour":{"utilization":0.0},"spend":null}' \
  '{"five_hour":{"utilization":0.0},"spend":{"enabled":false,"used":{"amount_minor":0,"currency":"USD","exponent":2},"limit":{"amount_minor":50000,"currency":"USD","exponent":2}}}' \
  '{"five_hour":{"utilization":0.0},"spend":{"enabled":true,"used":{"amount_minor":100,"currency":"USD","exponent":2},"limit":null}}' \
  '{"five_hour":{"utilization":0.0},"spend":{"enabled":true,"used":{"amount_minor":100,"currency":"USD","exponent":2},"limit":{"amount_minor":0,"currency":"USD","exponent":2}}}' \
  '{"five_hour":{"utilization":0.0},"spend":{"enabled":true,"used":{"amount_minor":100,"currency":"USD","exponent":2},"limit":{"amount_minor":50000,"currency":"EUR","exponent":2}}}' \
  '{"five_hour":{"utilization":0.0},"spend":{"enabled":true,"used":{"amount_minor":100,"currency":"USD"},"limit":{"amount_minor":50000,"currency":"USD","exponent":2}}}' \
  '{"five_hour":{"utilization":0.0},"spend":{"enabled":true,"used":{"amount_minor":"100","currency":"USD","exponent":2},"limit":{"amount_minor":50000,"currency":"USD","exponent":2}}}' \
  '{"five_hour":{"utilization":0.0},"spend":{"enabled":true,"used":{"amount_minor":NaN,"currency":"USD","exponent":2},"limit":{"amount_minor":50000,"currency":"USD","exponent":2}}}'; do
  without=$(read_limits "$payload")
  [[ $(jq -c '[.limits[].label]' <<<"$without") == '["Session (5-hour)"]' ]] ||
    fail "Claude collector adds no credit window to an account without credits" "$payload -> $without"
done
pass "Claude collector adds no credit window to an account without credits"

# A refund can carry the spend below zero. That is an empty meter, not a
# missing window: the panel drops any window whose percent reads negative.
refund=$(read_limits '{
  "five_hour": { "utilization": 0.0 },
  "spend": {
    "enabled": true,
    "used": { "amount_minor": -500, "currency": "EUR", "exponent": 2 },
    "limit": { "amount_minor": 50000, "currency": "EUR", "exponent": 2 }
  }
}')

[[ $(jq -c '.limits[-1] | [.label, .percent]' <<<"$refund") == '["Usage credits",0.0]' ]] ||
  fail "Claude collector empties the credit meter on a refund rather than dropping it" "$refund"
pass "Claude collector empties the credit meter on a refund rather than dropping it"

# A zero-decimal currency states exponent 0 and must not be read as cents.
yen=$(read_limits '{
  "five_hour": { "utilization": 0.0 },
  "spend": {
    "enabled": true,
    "used": { "amount_minor": 25000, "currency": "JPY", "exponent": 0 },
    "limit": { "amount_minor": 50000, "currency": "JPY", "exponent": 0 }
  }
}')

[[ $(jq -c '.limits[-1].spend' <<<"$yen") == '{"used":25000.0,"limit":50000.0,"currency":"JPY"}' ]] ||
  fail "Claude collector reads money in the exponent the payload states" "$yen"
pass "Claude collector reads money in the exponent the payload states"

# The money is only true at the moment it was read, and its window stands for a
# month. A cache replayed for weeks would report spending the account has long
# since passed, so the credit window waits for a probe that reaches the endpoint
# while the rate limit windows still come back.
credit_cache=$(jq -nc --arg open "$open_at" '{
  fetchedAtMs: 1,
  limits: [
    { label: "Weekly (7-day)", percent: 0.11, resetsAt: $open },
    { label: "Usage credits", title: "Usage credits", percent: 0.92, resetsAt: $open,
      spend: { used: 458.2, limit: 500.0, currency: "EUR" } }
  ]
}')

cached_credits=$(collect_limits "token" 1000 "$credit_cache")
[[ $(jq -c '[.limits[].label]' <<<"$cached_credits") == '["Weekly (7-day)"]' ]] ||
  fail "Claude collector does not replay a cached credit figure" "$cached_credits"
pass "Claude collector does not replay a cached credit figure"

# next_month_start is a pure function of the month it is given, so its branches
# are driven directly rather than through whatever month the suite runs in.
month_start() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" WHEN="$1" TZ="${2:-UTC}" python3 - <<'PY'
import datetime as dt, importlib.machinery, importlib.util, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

print(collector.next_month_start(dt.datetime.fromisoformat(os.environ["WHEN"])))
PY
}

# Mid-month, the last day of a month, and December, which is the only month
# that has to carry the year with it. A December that rolled over to month 13
# would raise out of the collector and cost the record every other number in
# it, not just this window.
while read -r when expected; do
  [[ $(month_start "$when") == "$expected"* ]] ||
    fail "Claude collector resets credits on the first of the coming month ($when)" "$(month_start "$when")"
done <<'CASES'
2026-09-17T10:30:00 2026-10-01T00:00:00
2026-09-01T00:00:00 2026-10-01T00:00:00
2026-01-31T12:00:00 2026-02-01T00:00:00
2026-12-31T23:59:00 2027-01-01T00:00:00
2026-12-01T00:00:00 2027-01-01T00:00:00
CASES
pass "Claude collector resets credits on the first of the coming month"

# The reset can land on the far side of a daylight-saving change. Carrying
# today's offset onto it puts the countdown an hour out and closes the cached
# window an hour early.
[[ $(month_start "2026-10-15T12:00:00" "Europe/Stockholm") == "2026-11-01T00:00:00+01:00" ]] ||
  fail "Claude collector dates the credit reset in the offset of the day it lands on" \
    "$(month_start "2026-10-15T12:00:00" "Europe/Stockholm")"
pass "Claude collector dates the credit reset in the offset of the day it lands on"

# The panel reads a window out of a label, and that guess cannot survive a
# model name — "Opus 5 (1M context)" parses as a one-minute window. A collector
# that states the title outright is taken at its word.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const start = source.indexOf('function windowIsLong')
const end = source.indexOf('// The window that decides')
assert(start > 0 && end > start, 'agents panel exposes its limit-window helpers')
eval(source.slice(start, end))

assertDeepEqual(
  limitWindows({ limits: [
    { label: 'Session (5-hour)', percent: 0.78, resetsAt: '' },
    { label: 'Opus 5 (1M context) Weekly', title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetsAt: '' }
  ] }),
  [
    { title: 'Session', percent: 0.78, resetAt: '', spend: null },
    { title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetAt: '', spend: null }
  ],
  'agents panel titles a limit off the collector when it states one'
)

assertDeepEqual(
  limitWindows({ limits: [{ label: 'Weekly (7-day)', percent: 0.12, resetsAt: '' }] }),
  [{ title: 'Weekly', percent: 0.12, resetAt: '', spend: null }],
  'agents panel still reads a window out of a label that carries no title'
)
JS

# The panel formats the amounts; the collector only carries them. A window
# with no allowance behind it renders no money line at all.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const start = source.indexOf('function currencyPrefix')
const end = source.indexOf('// ---------------------------------------------------------------- content')
assert(start > 0 && end > start, 'agents panel exposes its money helpers')
eval(source.slice(start, end))

assertEqual(
  spendDetailText({ used: 458.2, limit: 500, currency: 'EUR' }),
  '€458.20 / €500.00 spent',
  'agents panel writes the credit allowance as money spent of a cap'
)

assertEqual(spendDetailText(null), '', 'agents panel writes no money line for a rate limit window')

assertEqual(
  spendDetailText({ used: -5, limit: 500, currency: 'EUR' }),
  '-€5.00 / €500.00 spent',
  'agents panel writes a refund as a signed amount'
)
JS

run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const start = source.indexOf('function windowIsLong')
const end = source.indexOf('// The window that decides')
assert(start > 0 && end > start, 'agents panel exposes its limit-window helpers')
eval(source.slice(start, end))

assertDeepEqual(
  limitWindows({ limits: [{
    label: 'Usage credits', title: 'Usage credits', percent: 0.92, resetsAt: '',
    spend: { used: 458.2, limit: 500, currency: 'EUR' }
  }] }),
  [{ title: 'Usage credits', percent: 0.92, resetAt: '', spend: { used: 458.2, limit: 500, currency: 'EUR' } }],
  'agents panel carries a credit allowance through to its window'
)

// Nothing usable behind the amounts is the same as no allowance: a window
// that cannot say what it cost says nothing rather than "$0.00 / $0.00".
for (const spend of [null, {}, { used: 10 }, { used: 10, limit: 0 }]) {
  assertEqual(
    limitWindows({ limits: [{ label: 'Usage credits', percent: 0.92, resetsAt: '', spend }] })[0].spend,
    null,
    'agents panel drops an allowance it cannot read: ' + JSON.stringify(spend)
  )
}

assertDeepEqual(
  limitWindows({ limits: [{ label: 'Usage credits', percent: 0, resetsAt: '', spend: { used: -5, limit: 500, currency: 'EUR' } }] })[0].spend,
  { used: -5, limit: 500, currency: 'EUR' },
  'agents panel keeps the money of a refund'
)
JS

# The bar icon's alarm answers "what stops the next prompt". Credits do not:
# running them down returns the account to its rate limit windows, and the
# credit window would otherwise hold the alarm lit until the month rolled over.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const start = source.indexOf('function windowIsLong')
const end = source.indexOf('// ---------------------------------------------------------------- content')
assert(start > 0 && end > start, 'agents panel exposes its window and money helpers')
eval(source.slice(start, end))

const credits = {
  label: 'Usage credits', title: 'Usage credits', percent: 0.92, resetsAt: '',
  spend: { used: 458.2, limit: 500, currency: 'EUR' }
}

assertEqual(
  bindingWindow({ limits: [{ label: 'Weekly (7-day)', percent: 0.11, resetsAt: '' }, credits] }).title,
  'Weekly',
  'agents panel binds the bar to a rate limit window, not the fuller credit window'
)

assertEqual(
  bindingWindow({ limits: [credits] }),
  null,
  'agents panel binds the bar to nothing when only credits are known'
)

assertEqual(
  limitDetailText({ spend: { used: 458.2, limit: 500, currency: 'EUR' } }, 7500000),
  '€458.20 / €500.00 spent · Resets in 2h 5m',
  'agents panel writes the money and the countdown on one line'
)

assertEqual(
  limitDetailText({ spend: { used: 458.2, limit: 500, currency: 'EUR' } }, -1),
  '€458.20 / €500.00 spent',
  'agents panel writes money alone when no reset time is known'
)

assertEqual(
  limitDetailText({ spend: null }, 7500000),
  'Resets in 2h 5m',
  'agents panel leaves a rate limit row reading the way it always did'
)

assertEqual(limitDetailText(null, -1), '', 'agents panel writes nothing under a window with neither')
JS
