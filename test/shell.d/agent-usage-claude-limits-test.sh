#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

# probe_limits reaches Anthropic, so the reader that interprets its answer is
# exercised on its own: the collector loads as a module, and a recorded payload
# stands in for the response.
read_limits() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" PAYLOAD="$1" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, pathlib

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

cache = collector.cache_root() / ("claude-limits-" + collector.hashlib.sha1(b"/unused-claude").hexdigest()[:16] + ".json")
cached = os.environ["CACHED"]
if cached:
  cache.write_text(cached, encoding="utf-8")
elif cache.exists():
  cache.unlink()

def unreachable(request, timeout=None):
  raise OSError("no route to host")

collector.urllib.request.urlopen = unreachable
print(json.dumps(collector.collect_limits(os.environ["TOKEN"], int(os.environ["EXPIRES_AT"]), False, pathlib.Path("/unused-claude"))))
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

# A lapsed expiresAt is not a missing login: still probe. An unreachable
# endpoint then falls back the same way a live token does.
lapsed=$(collect_limits "token" 1000 "$cache")
[[ $(jq -r '.usageStatusText' <<<"$lapsed") == "" ]] ||
  fail "Claude collector does not treat a lapsed expiresAt as a signed-out login" "$lapsed"
[[ $(jq -c '[.limits[].label]' <<<"$lapsed") == '["Weekly (7-day)"]' ]] ||
  fail "Claude collector keeps only cached windows that have not reset" "$lapsed"
[[ $(jq -r '.retryAdvised' <<<"$lapsed") == "true" ]] ||
  fail "Claude collector advises a retry after a transport failure on a lapsed token" "$lapsed"
pass "Claude collector still probes when the saved token's expiresAt has lapsed"

# Nothing worth showing and no route: transport failure, not a fake logout.
stale=$(collect_limits "token" 1000 "$(jq -c '.limits |= [.[0]]' <<<"$cache")")
[[ $(jq -c '.limits' <<<"$stale") == "[]" && $(jq -r '.usageStatusText' <<<"$stale") == "Claude limits unavailable" ]] ||
  fail "Claude collector drops a wholly reset cache without calling it a logout" "$stale"
pass "Claude collector drops a wholly reset cache without calling it a logout"

# A signed-out machine says so, and still shows what it last knew.
signed_out=$(collect_limits "" 0 "$cache")
[[ $(jq -r '.usageStatusText' <<<"$signed_out") == "Waiting for auth" ]] ||
  fail "Claude collector still reports a missing token" "$signed_out"
[[ $(jq -c '[.limits[].label]' <<<"$signed_out") == '["Weekly (7-day)"]' ]] ||
  fail "Claude collector serves open cached windows without a token" "$signed_out"
pass "Claude collector serves open cached windows without a token"

collect_limits_http() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" TOKEN="token" EXPIRES_AT="1000" HTTP="$1" CACHED="$2" \
    XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, pathlib, urllib.error

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

cache = collector.cache_root() / ("claude-limits-" + collector.hashlib.sha1(b"/unused-claude").hexdigest()[:16] + ".json")
cached = os.environ["CACHED"]
if cached:
  cache.write_text(cached, encoding="utf-8")
elif cache.exists():
  cache.unlink()

def unauthorized(request, timeout=None):
  raise urllib.error.HTTPError(
    "https://api.anthropic.com/api/oauth/usage",
    int(os.environ["HTTP"]),
    "Unauthorized",
    None,
    io.BytesIO(b""),
  )

collector.urllib.request.urlopen = unauthorized
print(json.dumps(collector.collect_limits(os.environ["TOKEN"], int(os.environ["EXPIRES_AT"]), False, pathlib.Path("/unused-claude"))))
PY
}

unauthorized=$(collect_limits_http 401 "$cache")
[[ $(jq -r '.usageStatusText' <<<"$unauthorized") == "Sign-in expired" ]] ||
  fail "Claude collector reports expired only after HTTP 401" "$unauthorized"
[[ $(jq -r '.authHelpText' <<<"$unauthorized") == *"claude auth login"* ]] ||
  fail "Claude collector says how to refresh after HTTP 401" "$unauthorized"
[[ $(jq -c '[.limits[].label]' <<<"$unauthorized") == '["Weekly (7-day)"]' ]] ||
  fail "Claude collector keeps open cached windows after HTTP 401" "$unauthorized"
pass "Claude collector reports an expired sign-in after HTTP 401"

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
import importlib.machinery, importlib.util, io, json, os, pathlib

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

cache = collector.cache_root() / ("claude-limits-" + collector.hashlib.sha1(b"/unused-claude").hexdigest()[:16] + ".json")
cache.write_text(os.environ["CACHED"], encoding="utf-8")

probes = []

def urlopen(request, timeout=None):
  probes.append(1)
  return io.BytesIO(os.environ["PAYLOAD"].encode())

collector.urllib.request.urlopen = urlopen
result = collector.collect_limits("token", 0, os.environ["FORCE"] == "true", pathlib.Path("/unused-claude"))
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
JS
