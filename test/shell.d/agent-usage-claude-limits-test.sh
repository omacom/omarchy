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

cache = collector.cache_root() / "claude-limits.json"
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

# A lapsed saved token is not the end of the story: omp and pi hold Claude
# subscriptions too and refresh their own tokens. Both are stubbed on PATH so
# the real subprocess path runs — omp with two accounts it selects by
# position, pi with a third — and each logs what it was asked. Anthropic is
# answered per token: the profile endpoint says whose a token is, the usage
# endpoint how much it has used.
SIBLINGS="$CACHE_HOME/siblings"
SIBLING_LOG="$SIBLINGS/calls.log"
mkdir -p "$SIBLINGS/bin"
cat >"$SIBLINGS/bin/omp" <<'SH'
#!/bin/bash
echo "omp $*" >>"$SIBLING_LOG"
case "$*" in
  "token anthropic --list") printf '1. a@example.com (Org A)\n2. b@example.com (Org B)\n' ;;
  "token anthropic --account 1") echo sk-ant-oat01-a ;;
  "token anthropic --account 2") echo sk-ant-oat01-b ;;
  *) exit 1 ;;
esac
SH
cat >"$SIBLINGS/bin/pi" <<'SH'
#!/bin/bash
echo "pi $*" >>"$SIBLING_LOG"
if [[ $* == "auth print-bearer-token --provider anthropic" ]]; then
  echo sk-ant-oat01-p
else
  exit 1
fi
SH
chmod +x "$SIBLINGS/bin/omp" "$SIBLINGS/bin/pi"
cat >"$SIBLINGS/anthropic.py" <<'PY'
import io, json, urllib.error

OWNERS = {
  "sk-ant-oat01-a": ("user-a", "org-a"),
  "sk-ant-oat01-b": ("user-b", "org-b"),
  "sk-ant-oat01-p": ("user-p", "org-p"),
}
USED = {"sk-ant-oat01-a": 11.0, "sk-ant-oat01-b": 22.0, "sk-ant-oat01-p": 33.0}

def install(collector):
  probes = []
  def urlopen(request, timeout=None):
    token = request.get_header("Authorization").split(" ", 1)[1]
    if request.full_url == collector.PROFILE_ENDPOINT:
      if token not in OWNERS:
        raise urllib.error.HTTPError(request.full_url, 401, "unauthorized", None, None)
      user, org = OWNERS[token]
      return io.BytesIO(json.dumps({"account": {"uuid": user}, "organization": {"uuid": org}}).encode())
    probes.append(token)
    return io.BytesIO(json.dumps({"five_hour": {"utilization": USED.get(token, 0.0)}}).encode())
  collector.urllib.request.urlopen = urlopen
  return probes
PY

borrow_limits() {
  : >"$SIBLING_LOG"
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" TOKEN="$1" EXPIRES_AT="$2" REFRESH_EXPIRES_AT="$3" \
    IDENTITY="$4" SIBLINGS="$SIBLINGS" SIBLING_LOG="$SIBLING_LOG" PATH="$SIBLINGS/bin:$PATH" \
    XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
sys.path.insert(0, os.environ["SIBLINGS"])
import anthropic

(collector.cache_root() / "claude-limits.json").unlink(missing_ok=True)
probes = anthropic.install(collector)
identity = tuple(os.environ["IDENTITY"].split("/")) if os.environ["IDENTITY"] else ("", "")
result = collector.collect_limits(
  os.environ["TOKEN"],
  int(os.environ["EXPIRES_AT"]),
  int(os.environ["REFRESH_EXPIRES_AT"]),
  False,
  identity=identity,
)
print(json.dumps({"result": result, "probes": probes}))
PY
}

# omp's second account is the one this home is signed in as: the first is
# asked, shown to belong to someone else, and passed over.
paused_borrow=$(borrow_limits "lapsed" 1000 "$live_refresh" "user-b/org-b")
[[ $(jq -c '.probes' <<<"$paused_borrow") == '["sk-ant-oat01-b"]' ]] ||
  fail "a paused home probes with the sibling token that is its own" "$paused_borrow"
[[ $(jq -c '[.result.usageStatusText, .result.live, [.result.limits[].percent]]' <<<"$paused_borrow") == '["",true,[0.22]]' ]] ||
  fail "a borrowed token's limits are live, with nothing to report" "$paused_borrow"
pass "a paused home probes with the sibling token that is its own"

# A lapsed refresh token borrows the same way, and pi stands in when omp holds
# nothing for this home.
expired_borrow=$(borrow_limits "lapsed" 1000 1000 "user-p/org-p")
[[ $(jq -c '[.probes, .result.usageStatusText]' <<<"$expired_borrow") == '[["sk-ant-oat01-p"],""]' ]] ||
  fail "an expired home borrows pi's token when it is the home's own" "$expired_borrow"
pass "an expired home borrows pi's token when it is the home's own"

# Nothing saved at all, but a profile that names the account: still answerable.
unsaved_borrow=$(borrow_limits "" 0 0 "user-a/org-a")
[[ $(jq -c '[.probes, .result.usageStatusText]' <<<"$unsaved_borrow") == '[["sk-ant-oat01-a"],""]' ]] ||
  fail "a home with no saved token borrows its own sibling token" "$unsaved_borrow"
pass "a home with no saved token borrows its own sibling token"

# The same account in another organization is another subscription, so its
# token is not this home's: no probe, and the home still says it is paused.
other_org=$(borrow_limits "lapsed" 1000 "$live_refresh" "user-a/org-b")
[[ $(jq -c '[.probes, .result.usageStatusText]' <<<"$other_org") == '[[],"Limits paused"]' ]] ||
  fail "a sibling token for another organization is never borrowed" "$other_org"
pass "a sibling token for another organization is never borrowed"

# A home that does not say who it is signed in as cannot be matched, so no
# sibling is so much as asked.
unknown=$(borrow_limits "lapsed" 1000 1000 "")
[[ $(jq -c '[.probes, .result.usageStatusText]' <<<"$unknown") == '[[],"Sign-in expired"]' && ! -s $SIBLING_LOG ]] ||
  fail "a home with no identity never asks a sibling CLI" "$unknown $(cat "$SIBLING_LOG")"
pass "a home with no identity never asks a sibling CLI"

# Every registered account is matched on its own. Two lapsed homes, siblings
# holding only the first one's subscription: the first reads live numbers,
# the second keeps its own status rather than the first's allowance.
account_borrow=$(COLLECTOR="$ROOT/bin/omarchy-agent-usage-claude" SIBLINGS="$SIBLINGS" SIBLING_LOG="$SIBLING_LOG" \
  PATH="$SIBLINGS/bin:$PATH" XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os, pathlib, sys

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
sys.path.insert(0, os.environ["SIBLINGS"])
import anthropic

homes = pathlib.Path(os.environ["SIBLINGS"]) / "homes"
for name, user, org in (("main", "user-a", "org-a"), ("work", "user-c", "org-c")):
  home = homes / name
  home.mkdir(parents=True, exist_ok=True)
  login = {"accessToken": "lapsed-" + name, "expiresAt": 1000, "refreshTokenExpiresAt": 1000, "subscriptionType": "max"}
  (home / ".credentials.json").write_text(json.dumps({"claudeAiOauth": login}))
  (home / ".claude.json").write_text(json.dumps({"oauthAccount": {"accountUuid": user, "organizationUuid": org}}))

probes = anthropic.install(collector)
accounts = [
  collector.account_limits({"id": name, "home": str(homes / name), "active": name == "main"}, False)
  for name in ("main", "work")
]
print(json.dumps({
  "accounts": [{"id": a["id"], "status": a["usageStatusText"], "used": [l["percent"] for l in a["limits"]]} for a in accounts],
  "probes": probes,
}, separators=(",", ":")))
PY
)
[[ $account_borrow == '{"accounts":[{"id":"main","status":"","used":[0.11]},{"id":"work","status":"Sign-in expired","used":[]}],"probes":["sk-ant-oat01-a"]}' ]] ||
  fail "each registered account borrows only its own subscription's token" "$account_borrow"
pass "each registered account borrows only its own subscription's token"

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

cache = collector.cache_root() / "claude-limits.json"
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
