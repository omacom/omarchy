#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

# fetch_limits/collect_limits reach Z.ai, so the readers that interpret the
# response are exercised on their own: the collector loads as a module and a
# recorded payload (or a raised error) stands in for the network.
CACHE_HOME=$(mktemp -d)
TEST_HOME=$(mktemp -d)
trap 'rm -rf "$CACHE_HOME" "$TEST_HOME"' EXIT

read_limits() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-zai" PAYLOAD="$1" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

collector.urllib.request.urlopen = lambda request, timeout=None: io.BytesIO(os.environ["PAYLOAD"].encode())
print(json.dumps(collector.fetch_limits("token", "zai")))
PY
}

# force, cached-json, mode (success|transport|http401|http500), payload, [key]
#   -> {result, probes, cached}
drive() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-zai" FORCE="$1" CACHED="$2" MODE="$3" PAYLOAD="$4" KEY="${5:-token}" \
    XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os, urllib.error

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

# Every case seeds the cache of the "token" key; another key must not see it.
cache = collector.limits_cache_paths("token", "zai")[0]
cached = os.environ["CACHED"]
if cached:
  cache.write_text(cached, encoding="utf-8")
elif cache.exists():
  cache.unlink()

probes = []
mode = os.environ["MODE"]

def urlopen(request, timeout=None):
  probes.append(1)
  if mode == "transport":
    raise urllib.error.URLError("no route to host")
  if mode == "http401":
    raise urllib.error.HTTPError("u", 401, "no", {}, None)
  if mode == "http500":
    raise urllib.error.HTTPError("u", 500, "no", {}, None)
  return io.BytesIO(os.environ["PAYLOAD"].encode())

collector.urllib.request.urlopen = urlopen
result = collector.collect_limits(os.environ["KEY"], "zai", os.environ["FORCE"] == "true")
out = {"result": result, "probes": len(probes)}
if cache.exists():
  out["cached"] = json.loads(cache.read_text(encoding="utf-8"))
print(json.dumps(out))
PY
}

now_ms=$(python3 -c 'import time; print(round(time.time() * 1000))')
future_ms=$(python3 -c 'import time; print(round((time.time() + 86400) * 1000))')
soon_ms=$(python3 -c 'import time; print(round((time.time() + 3*3600) * 1000))')
week_sec=$(python3 -c 'import time; print(round(time.time() + 5*86400))')
week_date=$(python3 -c "import datetime; print(datetime.datetime.fromtimestamp($week_sec, datetime.timezone.utc).date().isoformat())")
open_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=3)).isoformat())')
past_at=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=3)).isoformat())')

# The mapped session + weekly windows, then the entries that must drop: a window
# tagged with an unmapped (unit, number), one whose percentage will not parse,
# and one whose percentage is a boolean. nextResetTime is milliseconds for the
# first and plain seconds for the second, to prove a seconds epoch is not
# rendered 1000x in the future.
payload=$(jq -nc --argjson sm "$soon_ms" --argjson ws "$week_sec" '{
  data: { level: "pro", limits: [
    { type: "CREDIT_LIMIT", unit: 3, number: 5, percentage: 42.0, nextResetTime: $sm },
    { type: "TOKENS_LIMIT", unit: 6, number: 1, percentage: 10, nextResetTime: $ws },
    { type: "CREDIT_LIMIT", unit: 9, number: 9, percentage: 5, nextResetTime: $sm },
    { type: "CREDIT_LIMIT", unit: 3, number: 5, percentage: null, nextResetTime: $sm },
    { type: "CREDIT_LIMIT", unit: 3, number: 5, percentage: true, nextResetTime: $sm }
  ] }
}')
limits=$(read_limits "$payload" 2>/dev/null)

[[ $(jq -c '[.limits[] | {label, percent}]' <<<"$limits") == '[{"label":"Session (5-hour)","percent":0.42},{"label":"Weekly (7-day)","percent":0.1}]' ]] ||
  fail "Z.ai collector maps both windows and drops the unmapped and unparseable rows" "$limits"
[[ $(jq -r '.tierLabel' <<<"$limits") == "Pro" ]] ||
  fail "Z.ai collector titles the plan tier" "$limits"
[[ $(jq -r '.limits[1].resetsAt' <<<"$limits") == "$week_date"* ]] ||
  fail "Z.ai collector reads a plain-seconds reset time, not milliseconds" "$limits"
pass "Z.ai collector reads windows, tier, seconds/ms resets, and drops bad rows"

kept=$(jq -nc --arg open "$open_at" --arg past "$past_at" '{
  fetchedAtMs: 1, tierLabel: "Pro", limits: [
    { label: "Session (5-hour)", percent: 0.31, resetsAt: $past },
    { label: "Weekly (7-day)", percent: 0.11, resetsAt: $open }
  ]
}')

# A key with no plan is a pay-as-you-go account: no trouble, no blame on the
# key, and no limits kept from a plan that lapsed.
noplan=$(drive false "$kept" success '{"success":false,"msg":"This API key has no coding plan"}')
[[ $(jq -c '.result | {usageStatusText, authHelpText, retryAdvised, limits, live}' <<<"$noplan") == '{"usageStatusText":"","authHelpText":"","retryAdvised":false,"limits":[],"live":true}' ]] ||
  fail "Z.ai collector treats a key without a coding plan as healthy with no limits" "$noplan"
pass "Z.ai collector treats a no-plan key as healthy, without limits"

# A rejected key is a sign-in to redo, and the kept limits stay, stale.
rejected=$(drive false "$kept" http401 "")
[[ $(jq -r '.result.usageStatusText' <<<"$rejected") == "Sign-in expired" ]] ||
  fail "Z.ai collector reports a rejected key as an expired sign-in" "$rejected"
[[ $(jq -r '.result.authHelpText' <<<"$rejected") == *"rejected the saved API key"* ]] ||
  fail "Z.ai collector blames the key only when the key is rejected" "$rejected"
[[ $(jq -c '{live: .result.live, n: (.result.limits | length), retry: .result.retryAdvised}' <<<"$rejected") == '{"live":false,"n":2,"retry":false}' ]] ||
  fail "Z.ai collector keeps the last limits, stale, past a rejected key" "$rejected"
pass "Z.ai collector reports a rejected key as Sign-in expired"

# A transport failure keeps the last known figures with no status of its own,
# brings the window that already reset back at zero, and asks for a retry.
unreachable=$(drive false "$kept" transport "")
[[ $(jq --arg open "$open_at" '[.result.limits[] | {label, percent, resetsAt}] == [{label: "Session (5-hour)", percent: 0, resetsAt: ""}, {label: "Weekly (7-day)", percent: 0.11, resetsAt: $open}]' <<<"$unreachable") == "true" ]] ||
  fail "Z.ai collector zeroes a kept window that has reset rather than dropping it" "$unreachable"
[[ $(jq -r '.result.tierLabel' <<<"$unreachable") == "Pro" && $(jq -r '.result.retryAdvised' <<<"$unreachable") == "true" ]] ||
  fail "Z.ai collector keeps the cached tier and advises a retry after a transport failure" "$unreachable"
[[ $(jq -c '{live: .result.live, fetchedAtMs: .result.fetchedAtMs, status: .result.usageStatusText}' <<<"$unreachable") == '{"live":false,"fetchedAtMs":1,"status":""}' ]] ||
  fail "Z.ai collector marks kept limits stale with when they were fetched, without a status" "$unreachable"
pass "Z.ai collector serves the last known limits and advises a retry when offline"

# With nothing kept, a failed check says the limits are unavailable; only a
# transport failure asks for an early retry.
offline=$(drive false "" transport "")
[[ $(jq -c '.result | {usageStatusText, retryAdvised, n: (.limits | length)}' <<<"$offline") == '{"usageStatusText":"Z.ai limits unavailable","retryAdvised":true,"n":0}' ]] ||
  fail "Z.ai collector reports unavailable limits when offline with nothing kept" "$offline"
[[ $(jq -r '.result.authHelpText' <<<"$offline") == *"reach"* ]] ||
  fail "Z.ai collector explains an unreachable endpoint" "$offline"
server=$(drive false "" http500 "")
[[ $(jq -c '.result | {usageStatusText, retryAdvised}' <<<"$server") == '{"usageStatusText":"Z.ai limits unavailable","retryAdvised":false}' ]] ||
  fail "Z.ai collector does not advise a retry for a server's error status" "$server"
pass "Z.ai collector reports unavailable limits and advises a retry only for transport failures"

# Repeated panel opens inside the probe interval share one answer; --force does not.
fresh=$(jq -nc --arg open "$open_at" --argjson now "$now_ms" '{
  fetchedAtMs: $now, tierLabel: "Pro", limits: [{ label: "Weekly (7-day)", percent: 0.11, resetsAt: $open }]
}')
success_payload=$(jq -nc --argjson sm "$soon_ms" '{ data: { level: "max", limits: [
  { type: "CREDIT_LIMIT", unit: 3, number: 5, percentage: 44.0, nextResetTime: $sm }
] } }')

reused=$(drive false "$fresh" success "$success_payload")
[[ $(jq -r '.probes' <<<"$reused") == "0" && $(jq -c '[.result.limits[].percent]' <<<"$reused") == "[0.11]" ]] ||
  fail "Z.ai collector reuses a cache younger than the probe interval" "$reused"
pass "Z.ai collector reuses a probe younger than the interval"

forced=$(drive true "$fresh" success "$success_payload")
[[ $(jq -r '.probes' <<<"$forced") == "1" && $(jq -c '[.result.limits[].percent]' <<<"$forced") == "[0.44]" ]] ||
  fail "Z.ai collector re-probes on --force despite a fresh cache" "$forced"
[[ $(jq -c '[.cached.limits[].percent]' <<<"$forced") == "[0.44]" && $(jq -r '.cached.tierLabel' <<<"$forced") == "Max" ]] ||
  fail "Z.ai collector caches a successful probe for the next run" "$forced"
[[ $(jq -r '.result.live' <<<"$forced") == "true" && $(jq -r '.result.fetchedAtMs == .cached.fetchedAtMs' <<<"$forced") == "true" ]] ||
  fail "Z.ai collector marks a fresh probe live" "$forced"
pass "Z.ai collector re-probes on --force and caches the result"

# A cache stamped in the future (the clock went back) is no proof of a recent
# probe, but it is still the last good answer to fall back on.
ahead=$(jq -nc --arg open "$open_at" --argjson ms "$future_ms" '{
  fetchedAtMs: $ms, tierLabel: "Pro", limits: [{ label: "Weekly (7-day)", percent: 0.11, resetsAt: $open }]
}')
skewed=$(drive false "$ahead" transport "")
[[ $(jq -r '.probes' <<<"$skewed") == "1" && $(jq -c '[.result.limits[].percent]' <<<"$skewed") == "[0.11]" && $(jq -r '.result.live' <<<"$skewed") == "false" ]] ||
  fail "Z.ai collector re-probes past a future-stamped cache and still falls back on it" "$skewed"
pass "Z.ai collector neither trusts nor loses a future-stamped cache"

# Another key never shows this one's numbers.
other=$(drive false "$fresh" transport "" other-key)
[[ $(jq -c '.result | {n: (.limits | length), usageStatusText}' <<<"$other") == '{"n":0,"usageStatusText":"Z.ai limits unavailable"}' ]] ||
  fail "Z.ai collector keys its limits cache by credential" "$other"
pass "Z.ai collector keeps each key's limits apart"

# A predictable lock path must not follow and truncate a planted symlink.
lock=$(XDG_CACHE_HOME="$CACHE_HOME" COLLECTOR="$ROOT/bin/omarchy-agent-usage-zai" python3 - <<'PY'
import importlib.machinery, importlib.util, os
loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
print(collector.limits_cache_paths("token", "zai")[1])
PY
)
sentinel="$CACHE_HOME/sentinel"
printf intact >"$sentinel"
rm -f "$lock"
ln -s "$sentinel" "$lock"
drive true "$fresh" success "$success_payload" >/dev/null
[[ $(<"$sentinel") == "intact" ]] ||
  fail "Z.ai collector does not follow a planted lock symlink"
pass "Z.ai collector does not follow a planted lock symlink"

# A machine that has never used Z.ai prints the full, zeroed record the panel
# skips, with no status to alarm anyone.
unused=$(env -u ZAI_API_KEY -u ZHIPU_API_KEY -u ZHIPUAI_API_KEY -u PI_CODING_AGENT_DIR \
  HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  "$ROOT/bin/omarchy-agent-usage-zai")
[[ $(jq -c '{ready, usageStatusText, authHelpText, limits, limitsStale, limitsFetchedAt, totalPrompts, days: (.recentDays | length), modelUsage}' <<<"$unused") == '{"ready":false,"usageStatusText":"","authHelpText":"","limits":[],"limitsStale":false,"limitsFetchedAt":0,"totalPrompts":0,"days":7,"modelUsage":{}}' ]] ||
  fail "Z.ai collector prints an empty, unready record on an unused machine" "$unused"
pass "Z.ai collector prints an empty, unready record on an unused machine"

# A key pi saved with /login counts as a credential.
mkdir -p "$TEST_HOME/.pi/agent"
printf '{"zai":{"type":"api_key","key":"pi-saved"}}' >"$TEST_HOME/.pi/agent/auth.json"
picked=$(env -u ZAI_API_KEY -u ZHIPU_API_KEY -u ZHIPUAI_API_KEY -u PI_CODING_AGENT_DIR HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" \
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-zai" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os
loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
print(json.dumps(collector.credentials()))
PY
)
[[ $picked == '["pi-saved", "zai"]' ]] ||
  fail "Z.ai collector reads the key pi saved in auth.json" "$picked"
pass "Z.ai collector reads the key pi saved in auth.json"
