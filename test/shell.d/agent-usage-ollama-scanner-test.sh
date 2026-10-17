#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# A machine that has never used Ollama Cloud must still print a full,
# hidden-by-default record with no status to alarm anyone: the update runner
# writes whatever valid JSON appears on stdout.
no_key=$(env -u PI_CODING_AGENT_DIR HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  OLLAMA_API_KEY="" "$ROOT/bin/omarchy-agent-usage-ollama" --force)

[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + .usageStatusText + ":" + .tierLabel + ":" + (.limits | length | tostring) + ":" + (.hasLocalStats | tostring)' <<<"$no_key") == "ollama:false:::0:false" ]] ||
  fail "Ollama collector prints a valid record without credentials" "$no_key"
[[ $(jq -c '{authHelpText, limitsStale, limitsFetchedAt, totalPrompts, days: (.recentDays | length), modelUsage, activeDates}' <<<"$no_key") == '{"authHelpText":"","limitsStale":false,"limitsFetchedAt":0,"totalPrompts":0,"days":7,"modelUsage":{},"activeDates":[]}' ]] ||
  fail "Ollama collector prints the full, zeroed stats block on an unused machine" "$no_key"
pass "Ollama collector prints an empty, unready record on an unused machine"

# Pi and omp sessions on the ollama-cloud provider are the local stats; other
# providers in the same files must not leak in, and model version tags merge.
PI_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$PI_HOME"' EXIT
mkdir -p "$PI_HOME/.pi/agent/sessions/project" "$PI_HOME/.omp/agent/sessions/project"

timestamp="$(date +%Y-%m-%d)T12:00:00Z"
cat >"$PI_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"pi-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"ollama-cloud","model":"deepseek-v4-pro:0813","usage":{"input":10,"output":4,"cacheRead":3,"cacheWrite":2,"totalTokens":19}}}
{"type":"message","id":"pi-2","timestamp":"$timestamp","message":{"role":"assistant","provider":"ollama-cloud","model":"deepseek-v4-pro:0731","usage":{"input":5,"output":1,"cacheRead":0,"cacheWrite":0,"totalTokens":6}}}
{"type":"message","id":"pi-3","timestamp":"$timestamp","message":{"role":"assistant","provider":"anthropic","model":"claude-test","usage":{"input":999,"output":999}}}
{"type":"message","id":"pi-4","timestamp":"$timestamp","message":{"role":"user","provider":"ollama-cloud","model":"deepseek-v4-pro:0813","usage":{"input":999,"output":999}}}
{"type":"message","id":"pi-5","timestamp":"$timestamp","message":{"role":"assistant","provider":"ollama-cloud","model":"deepseek-v4-pro:0813","usage":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0,"totalTokens":0}}}
EOF
cat >"$PI_HOME/.omp/agent/sessions/project/omp.jsonl" <<EOF
{ "type": "message", "id": "omp-1", "timestamp": "$timestamp", "message": { "role": "assistant", "provider": "ollama-cloud", "model": "kimi-k3", "usage": { "input": 20, "output": 5, "cacheRead": 4, "cacheWrite": 1, "totalTokens": 30 } } }
EOF

result=$(HOME="$PI_HOME" XDG_CONFIG_HOME="$PI_HOME/.config" XDG_CACHE_HOME="$PI_HOME/.cache" \
  OLLAMA_API_KEY="" "$ROOT/bin/omarchy-agent-usage-ollama" --force)

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "55" ]] ||
  fail "Ollama collector counts usage from pi and omp sessions" "$result"
pass "Ollama collector counts usage from pi and omp sessions"

# In use here, but no key to ask for the account's limits.
[[ $(jq -c '{ready, usageStatusText, limitsStale}' <<<"$result") == '{"ready":true,"usageStatusText":"Waiting for auth","limitsStale":false}' ]] ||
  fail "Ollama collector waits for auth when used without a key" "$result"
pass "Ollama collector waits for auth when used without a key"

[[ $(jq -c '.modelUsage' <<<"$result") == '{"deepseek-v4-pro":{"cacheCreationInputTokens":2,"cacheReadInputTokens":3,"inputTokens":15,"outputTokens":5},"kimi-k3":{"cacheCreationInputTokens":1,"cacheReadInputTokens":4,"inputTokens":20,"outputTokens":5}}' ]] ||
  fail "Ollama collector filters to the ollama-cloud provider and merges model tags" "$result"
pass "Ollama collector filters to the ollama-cloud provider and merges model tags"

# A configured model prefix restricts the local stats to matching models.
mkdir -p "$PI_HOME/.config/omarchy/agents"
cat >"$PI_HOME/.config/omarchy/agents/ollama.json" <<'EOF'
{ "modelPrefix": "kimi" }
EOF

result=$(HOME="$PI_HOME" XDG_CONFIG_HOME="$PI_HOME/.config" XDG_CACHE_HOME="$PI_HOME/.cache" \
  OLLAMA_API_KEY="" "$ROOT/bin/omarchy-agent-usage-ollama" --force)

[[ $(jq -c '.modelUsage' <<<"$result") == '{"kimi-k3":{"cacheCreationInputTokens":1,"cacheReadInputTokens":4,"inputTokens":20,"outputTokens":5}}' ]] ||
  fail "Ollama collector honors the configured model prefix" "$result"
pass "Ollama collector honors the configured model prefix"

# A cached scan is reused only on the day it ran and with the filter it
# applied: a changed prefix, or yesterday's scan, means scanning again.
result=$(HOME="$PI_HOME" XDG_CONFIG_HOME="$PI_HOME/.config" XDG_CACHE_HOME="$PI_HOME/.cache" \
  OLLAMA_API_KEY="" "$ROOT/bin/omarchy-agent-usage-ollama" --limits-only)
[[ $(jq -c '.modelUsage | keys' <<<"$result") == '["kimi-k3"]' ]] ||
  fail "Ollama collector reuses a scan made with the same filter today" "$result"
rm "$PI_HOME/.config/omarchy/agents/ollama.json"
result=$(HOME="$PI_HOME" XDG_CONFIG_HOME="$PI_HOME/.config" XDG_CACHE_HOME="$PI_HOME/.cache" \
  OLLAMA_API_KEY="" "$ROOT/bin/omarchy-agent-usage-ollama" --limits-only)
[[ $(jq -c '.modelUsage | keys' <<<"$result") == '["deepseek-v4-pro","kimi-k3"]' ]] ||
  fail "Ollama collector rescans when the model filter changes" "$result"
cache_file=$(ls "$PI_HOME/.cache/omarchy/agent-usage/"ollama-scan-*.json | head -n 1)
jq -c '.scanDate = "2000-01-01" | .stats.todayTotalTokens = 999' "$cache_file" >"$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
result=$(HOME="$PI_HOME" XDG_CONFIG_HOME="$PI_HOME/.config" XDG_CACHE_HOME="$PI_HOME/.cache" \
  OLLAMA_API_KEY="" "$ROOT/bin/omarchy-agent-usage-ollama" --limits-only)
[[ $(jq -r '.todayTotalTokens' <<<"$result") == "55" ]] ||
  fail "Ollama collector rescans past a scan from another day" "$result"
pass "Ollama collector reuses a session scan only for the same day and filter"

# probe_limits reaches Ollama, so the reader that interprets its answer is
# exercised on its own: the collector loads as a module, and a recorded
# payload stands in for the response.
read_limits() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-ollama" PAYLOAD="$1" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

collector.urllib.request.urlopen = lambda request, timeout=None: io.BytesIO(os.environ["PAYLOAD"].encode())

print(json.dumps(collector.probe_limits("key")))
PY
}

limits=$(read_limits '{
  "activity": { "cost": "0.00" },
  "limits": {
    "session": { "usage": 0.434, "models": [{ "name": "deepseek-v4-pro:0813", "request_count": 340 }] },
    "weekly": { "usage": 0.298, "models": [{ "name": "kimi-k3", "request_count": 377 }] }
  }
}')

[[ $(jq -c '[.limits[].label]' <<<"$limits") == '["Session (5-hour)","Weekly (7-day)"]' ]] ||
  fail "Ollama collector reads the session and weekly windows" "$limits"
[[ $(jq -c '[.limits[].percent]' <<<"$limits") == "[0.434,0.298]" ]] ||
  fail "Ollama collector keeps the endpoint's 0..1 fractions" "$limits"
pass "Ollama collector reads the session and weekly fractions"

# The endpoint names no reset times, and none are made up.
[[ $(jq -c '[.limits[].resetsAt]' <<<"$limits") == '["",""]' ]] ||
  fail "Ollama collector leaves reset times it isn't told empty" "$limits"
pass "Ollama collector leaves reset times it isn't told empty"

# A payload with no usable windows explains itself instead of printing none.
empty=$(read_limits '{"limits": {"session": {"usage": "unknown"}, "weekly": null}}')
[[ $(jq -r '.ok' <<<"$empty") == "false" && $(jq -r '.helpText' <<<"$empty") == *"no limits"* ]] ||
  fail "Ollama collector reports a payload without usable limits" "$empty"
pass "Ollama collector reports a payload without usable limits"

# collect_limits drives the probe, the plan lookup, and the cache. A mocked
# urlopen answers both endpoints, and the cache decides reuse and fallback.
CACHE_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$PI_HOME" "$CACHE_HOME"' EXIT

# force, cached-json (seeded for the key "key"), mode, [key]
collect_limits() {
  COLLECTOR="$ROOT/bin/omarchy-agent-usage-ollama" FORCE="$1" CACHED="$2" MODE="$3" KEY="${4:-key}" \
    XDG_CACHE_HOME="$CACHE_HOME" python3 - <<'PY'
import importlib.machinery, importlib.util, io, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

cache = collector.limits_cache_path("key")
cached = os.environ["CACHED"]
if cached:
  cache.write_text(cached, encoding="utf-8")
elif cache.exists():
  cache.unlink()

probes = []

def urlopen(request, timeout=None):
  probes.append(request.full_url)
  mode = os.environ["MODE"]
  if mode == "transport":
    raise OSError("no route to host")
  if mode == "rejected":
    raise collector.urllib.error.HTTPError(request.full_url, 401, "Unauthorized", {}, io.BytesIO(b""))
  if mode == "server":
    raise collector.urllib.error.HTTPError(request.full_url, 500, "Oops", {}, io.BytesIO(b""))
  if request.full_url.endswith("/api/me"):
    if mode == "planless":
      raise OSError("plan lookup timed out")
    return io.BytesIO(b'{"Plan":"pro"}')
  return io.BytesIO(b'{"limits":{"session":{"usage":0.44},"weekly":{"usage":0.11}}}')

collector.urllib.request.urlopen = urlopen
result = collector.collect_limits(os.environ["KEY"], os.environ["FORCE"] == "true")
print(json.dumps({
  "result": result,
  "probes": probes,
  "cached": json.loads(cache.read_text(encoding="utf-8")) if cache.exists() else None,
}))
PY
}

fresh=$(jq -nc --argjson now "$(python3 -c 'import time; print(round(time.time() * 1000))')" '{
  fetchedAtMs: $now,
  limits: [{ label: "Weekly (7-day)", percent: 0.11, resetsAt: "" }],
  plan: "Pro"
}')
stale=$(jq -nc '{
  fetchedAtMs: 1,
  limits: [{ label: "Weekly (7-day)", percent: 0.11, resetsAt: "" }],
  plan: "Pro"
}')

# A live key that cannot reach the endpoint keeps the cached window and asks
# the shell to retry sooner than its regular interval.
unreachable=$(collect_limits false "$stale" transport)
[[ $(jq -c '[.result.limits[].label]' <<<"$unreachable") == '["Weekly (7-day)"]' ]] ||
  fail "Ollama collector falls back to cache when the probe cannot connect" "$unreachable"
[[ $(jq -r '.result.retryAdvised' <<<"$unreachable") == "true" ]] ||
  fail "Ollama collector advises a retry after a transport failure" "$unreachable"
[[ $(jq -c '{live: .result.live, fetchedAtMs: .result.fetchedAtMs, status: .result.usageStatusText}' <<<"$unreachable") == '{"live":false,"fetchedAtMs":1,"status":""}' ]] ||
  fail "Ollama collector marks kept limits stale with when they were fetched, without a status" "$unreachable"
# The endpoint names no reset times, so a kept window is kept as measured:
# never zeroed on a guessed reset, never given a reset time.
[[ $(jq -c '[.result.limits[] | {percent, resetsAt}]' <<<"$unreachable") == '[{"percent":0.11,"resetsAt":""}]' ]] ||
  fail "Ollama collector keeps a window without a reset time as it was measured" "$unreachable"
pass "Ollama collector falls back to cache when the probe cannot connect"

# With nothing kept, a failed check says the limits are unavailable; only a
# transport failure asks for an early retry.
offline=$(collect_limits false "" transport)
[[ $(jq -c '.result | {usageStatusText, retryAdvised}' <<<"$offline") == '{"usageStatusText":"Ollama limits unavailable","retryAdvised":true}' ]] ||
  fail "Ollama collector reports unavailable limits when offline with nothing kept" "$offline"
server=$(collect_limits false "" server)
[[ $(jq -c '.result | {usageStatusText, retryAdvised}' <<<"$server") == '{"usageStatusText":"Ollama limits unavailable","retryAdvised":null}' ]] ||
  fail "Ollama collector does not advise a retry for a server's error status" "$server"
pass "Ollama collector advises a retry only when the endpoint can't be reached"

# A rejected key is a sign-in to redo, and kept limits stay, stale.
rejected=$(collect_limits false "$stale" rejected)
[[ $(jq -r '.result.usageStatusText' <<<"$rejected") == "Sign-in expired" ]] ||
  fail "Ollama collector reports a rejected key as an expired sign-in" "$rejected"
[[ $(jq -r '.result.authHelpText' <<<"$rejected") == *"rejected"* ]] ||
  fail "Ollama collector explains a rejected key" "$rejected"
[[ $(jq -c '{live: .result.live, n: (.result.limits | length)}' <<<"$rejected") == '{"live":false,"n":1}' ]] ||
  fail "Ollama collector keeps the last limits past a rejected key" "$rejected"
pass "Ollama collector reports a rejected key as Sign-in expired"

# Another key never shows this one's numbers or plan.
other=$(collect_limits false "$fresh" transport other-key)
[[ $(jq -c '.result | {n: (.limits | length), tierLabel, usageStatusText}' <<<"$other") == '{"n":0,"tierLabel":"","usageStatusText":"Ollama limits unavailable"}' ]] ||
  fail "Ollama collector keys its limits cache by credential" "$other"
pass "Ollama collector keeps each key's limits and plan apart"

# A cache stamped in the future (the clock went back) is no proof of a recent
# probe, but it is still the last good answer to fall back on.
ahead=$(jq -nc --argjson ms "$(python3 -c 'import time; print(round((time.time() + 86400) * 1000))')" '{
  fetchedAtMs: $ms, limits: [{ label: "Weekly (7-day)", percent: 0.11, resetsAt: "" }], plan: "Pro"
}')
skewed=$(collect_limits false "$ahead" transport)
[[ $(jq -c '{probes: (.probes | length), n: (.result.limits | length), live: .result.live}' <<<"$skewed") == '{"probes":1,"n":1,"live":false}' ]] ||
  fail "Ollama collector re-probes past a future-stamped cache and still falls back on it" "$skewed"
pass "Ollama collector neither trusts nor loses a future-stamped cache"

# A plan lookup that fails keeps the plan last named.
planless=$(collect_limits true "$fresh" planless)
[[ $(jq -r '.result.tierLabel' <<<"$planless") == "Pro" && $(jq -c '[.result.limits[].percent]' <<<"$planless") == "[0.44,0.11]" ]] ||
  fail "Ollama collector keeps the cached plan when the plan lookup fails" "$planless"
pass "Ollama collector keeps the cached plan when the plan lookup fails"

# A fresh cache answers repeated panel opens without a request apiece.
reused=$(collect_limits false "$fresh" normal)
[[ $(jq -r '.probes | length' <<<"$reused") == "0" && $(jq -c '[.result.limits[].percent]' <<<"$reused") == "[0.11]" ]] ||
  fail "Ollama collector reuses a cache younger than the probe interval" "$reused"
pass "Ollama collector reuses a cache younger than the probe interval"

# --force is someone pressing refresh, so the reuse window must not outrank it.
forced=$(collect_limits true "$fresh" normal)
[[ $(jq -r '.probes | length' <<<"$forced") == "2" ]] ||
  fail "Ollama collector re-probes limits and plan on --force despite a fresh cache" "$forced"
[[ $(jq -c '[.result.limits[].percent]' <<<"$forced") == "[0.44,0.11]" && $(jq -r '.result.tierLabel' <<<"$forced") == "Pro" ]] ||
  fail "Ollama collector returns the forced probe's numbers and plan" "$forced"
[[ $(jq -r '.result.live and .result.fetchedAtMs == .cached.fetchedAtMs' <<<"$forced") == "true" ]] ||
  fail "Ollama collector marks a fresh probe live" "$forced"
pass "Ollama collector re-probes on --force despite a fresh cache"

# A probe that lands becomes the next run's fallback.
[[ $(jq -c '[.cached.limits[].percent]' <<<"$forced") == "[0.44,0.11]" && $(jq -r '.cached.plan' <<<"$forced") == "Pro" ]] ||
  fail "Ollama collector caches a successful probe" "$forced"
pass "Ollama collector caches a successful probe"

# Sessions outside the default root: an omp profile, a pi profile, and a pi
# agent dir moved by PI_CODING_AGENT_DIR, all under a $HOME that is a git
# checkout ignoring everything. A forked session repeats its parent's message
# (same id and timestamp) and counts once; lines without an id always count;
# rows whose timestamp or tokens are garbage drop without taking the rest.
ROOTS_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$PI_HOME" "$CACHE_HOME" "$ROOTS_HOME"' EXIT
mkdir -p "$ROOTS_HOME/.git"
printf '*\n' >"$ROOTS_HOME/.gitignore"
mkdir -p "$ROOTS_HOME/.omp/profiles/work/agent/sessions/p" "$ROOTS_HOME/.pi/profiles/home/agent/sessions/p" "$ROOTS_HOME/moved/sessions/p"
line() {
  printf '{"type":"message",%s"timestamp":%s,"message":{"role":"assistant","provider":"ollama-cloud","model":"kimi-k3","usage":{"input":%s}}}\n' "$1" "$2" "$3"
}
{
  line '"id":"parent",' "\"$timestamp\"" 100
  line '' "\"$timestamp\"" 1
  line '' "\"$timestamp\"" 1
} >"$ROOTS_HOME/.omp/profiles/work/agent/sessions/p/a.jsonl"
{
  line '"id":"parent",' "\"$timestamp\"" 100
  line '"id":"child",' "\"$timestamp\"" 10
  line '"id":"bad-ts",' -5 5000
  line '"id":"bad-ts2",' '"not a date"' 5000
  line '"id":"bad-tokens",' "\"$timestamp\"" '"12"'
  line '"id":"huge-tokens",' "\"$timestamp\"" 1e300
} >"$ROOTS_HOME/.pi/profiles/home/agent/sessions/p/fork.jsonl"
line '"id":"moved",' "\"$timestamp\"" 1000 >"$ROOTS_HOME/moved/sessions/p/m.jsonl"

roots=$(HOME="$ROOTS_HOME" PI_CODING_AGENT_DIR="$ROOTS_HOME/moved" XDG_CONFIG_HOME="$ROOTS_HOME/.config" XDG_CACHE_HOME="$ROOTS_HOME/.cache" \
  OLLAMA_API_KEY="" "$ROOT/bin/omarchy-agent-usage-ollama" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$roots") == "1112" && $(jq -r '.totalPrompts' <<<"$roots") == "5" ]] ||
  fail "Ollama collector scans profiles and PI_CODING_AGENT_DIR past ignore rules, dedups forks, counts id-less lines, skips garbage rows" "$roots"
pass "Ollama collector scans every pi/omp root, dedups forks, and skips garbage rows"

# A normal run reuses a scan for a few seconds only to absorb concurrent runs;
# --force always rescans.
line '"id":"later",' "\"$timestamp\"" 7 >>"$ROOTS_HOME/moved/sessions/p/m.jsonl"
again=$(HOME="$ROOTS_HOME" PI_CODING_AGENT_DIR="$ROOTS_HOME/moved" XDG_CONFIG_HOME="$ROOTS_HOME/.config" XDG_CACHE_HOME="$ROOTS_HOME/.cache" \
  OLLAMA_API_KEY="" "$ROOT/bin/omarchy-agent-usage-ollama")
forced=$(HOME="$ROOTS_HOME" PI_CODING_AGENT_DIR="$ROOTS_HOME/moved" XDG_CONFIG_HOME="$ROOTS_HOME/.config" XDG_CACHE_HOME="$ROOTS_HOME/.cache" \
  OLLAMA_API_KEY="" "$ROOT/bin/omarchy-agent-usage-ollama" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$again") == "1112" && $(jq -r '.todayTotalTokens' <<<"$forced") == "1119" ]] ||
  fail "Ollama collector reuses a seconds-old scan on a normal run and rescans on --force" "$again $forced"
pass "Ollama collector reuses a seconds-old scan and rescans on --force"

# A cloud-tagged model reached through the local daemon's `ollama` provider is
# billed by Ollama Cloud and counts here; a model the daemon runs itself is
# the local collector's.
TAGGED_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$PI_HOME" "$CACHE_HOME" "$ROOTS_HOME" "$TAGGED_HOME"' EXIT
mkdir -p "$TAGGED_HOME/.pi/agent/sessions/project"
cat >"$TAGGED_HOME/.pi/agent/sessions/project/pi.jsonl" <<EOF
{"type":"message","id":"tag-1","timestamp":"$timestamp","message":{"role":"assistant","provider":"ollama","model":"glm-4.6:cloud","usage":{"input":7,"output":3}}}
{"type":"message","id":"tag-2","timestamp":"$timestamp","message":{"role":"assistant","provider":"ollama","model":"gpt-oss:120b-cloud","usage":{"input":4,"output":1}}}
{"type":"message","id":"tag-3","timestamp":"$timestamp","message":{"role":"assistant","provider":"ollama","model":"qwen3:8b","usage":{"input":500,"output":500}}}
EOF
tagged=$(HOME="$TAGGED_HOME" XDG_CONFIG_HOME="$TAGGED_HOME/.config" XDG_CACHE_HOME="$TAGGED_HOME/.cache" \
  OLLAMA_API_KEY="" "$ROOT/bin/omarchy-agent-usage-ollama" --force)
[[ $(jq -r '.todayTotalTokens' <<<"$tagged") == "15" ]] ||
  fail "Ollama collector counts cloud models reached through the local daemon" "$tagged"
pass "Ollama collector counts cloud models reached through the local daemon"

# opencode's database, both stores side by side as a migrated install keeps
# them: a row only in the original `message` table (reasoning folds into
# output), a V2 compaction only in `session_message`, a migrated row in both
# under one id (counted once), a fork's copy of its source's message (skipped)
# and what the fork added after (counted), plus a model the local daemon runs
# itself (the local collector's), a user turn and a malformed row, none of
# them counted. 21 + 30 + 40 + 50 = 141.
opencode_fixture() {
  python3 - "$@" <<'PY'
import json, sqlite3, sys, time
db, provider_a, model_a, provider_b, model_b, decoy_provider, decoy_model = sys.argv[1:]
now = int(time.time() * 1000) - 5000
def v1(provider, model, tokens, role="assistant"):
  return json.dumps({"role": role, "providerID": provider, "modelID": model, "tokens": tokens, "time": {"created": now}})
def v2(provider, model, tokens):
  return json.dumps({"model": {"providerID": provider, "id": model}, "tokens": tokens, "time": {"created": now}})
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text, time_created integer, time_updated integer, data text)")
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text, type text, time_created integer, data text)")
conn.execute("CREATE TABLE session_v2 (id text PRIMARY KEY, fork_session_id text, time_created integer)")
conn.execute("INSERT INTO session_v2 VALUES ('ses_fork', 'ses_v2', ?)", (now - 30000,))
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  ("msg_v1", "ses_v1", now, now, v1(provider_a, model_a, {"input": 10, "output": 5, "reasoning": 2, "cache": {"read": 3, "write": 1}})),
  ("msg_both", "ses_v1", now, now, v1(provider_a, model_a, {"input": 40})),
  ("msg_decoy", "ses_v1", now, now, v1(decoy_provider, decoy_model, {"input": 999})),
  ("msg_user", "ses_v1", now, now, v1(provider_a, model_a, {"input": 777}, role="user")),
])
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?)", [
  ("msg_v2", "ses_v2", "compaction", now, v2(provider_b, model_b, {"input": 30})),
  ("msg_both", "ses_v1", "assistant", now, v2(provider_a, model_a, {"input": 40})),
  ("msg_copy", "ses_fork", "assistant", now - 60000, v2(provider_b, model_b, {"input": 1000})),
  ("msg_forked", "ses_fork", "assistant", now - 10000, v2(provider_b, model_b, {"input": 50})),
  ("msg_bad", "ses_v2", "assistant", now, '{"model":{"providerID":"%s"' % provider_b),
])
conn.commit()
conn.close()
PY
}

OC_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$PI_HOME" "$CACHE_HOME" "$ROOTS_HOME" "$TAGGED_HOME" "$OC_HOME"' EXIT
mkdir -p "$OC_HOME/.local/share/opencode"
opencode_fixture "$OC_HOME/.local/share/opencode/opencode.db" ollama-cloud glm-4.6 ollama gpt-oss:120b-cloud ollama qwen3:8b
oc_run() {
  env -u PI_CODING_AGENT_DIR -u XDG_DATA_HOME -u OPENCODE_DB OLLAMA_API_KEY="" "$@" \
    HOME="$OC_HOME" XDG_CONFIG_HOME="$OC_HOME/.config" XDG_CACHE_HOME="$OC_HOME/.cache" \
    "$ROOT/bin/omarchy-agent-usage-ollama" --force
}
oc=$(oc_run)
[[ $(jq -c '[.todayTotalTokens, .totalPrompts, .modelUsage["glm-4.6"].outputTokens, .modelUsage["gpt-oss"].inputTokens]' <<<"$oc") == "[141,4,7,80]" ]] ||
  fail "Ollama collector counts Ollama Cloud rows from both opencode stores once, skipping fork copies and local models" "$oc"
pass "Ollama collector counts Ollama Cloud rows from both opencode stores once"

# OPENCODE_DB names the database opencode reads, a relative name beside the
# default one; opencode-v2.db is read only when opencode.db is absent.
mv "$OC_HOME/.local/share/opencode/opencode.db" "$OC_HOME/.local/share/opencode/custom.db"
oc=$(oc_run OPENCODE_DB=custom.db)
[[ $(jq -r '.todayTotalTokens' <<<"$oc") == "141" ]] ||
  fail "Ollama collector reads the opencode database OPENCODE_DB names" "$oc"
mv "$OC_HOME/.local/share/opencode/custom.db" "$OC_HOME/.local/share/opencode/opencode-v2.db"
oc=$(oc_run)
[[ $(jq -r '.todayTotalTokens' <<<"$oc") == "141" ]] ||
  fail "Ollama collector falls back to opencode-v2.db" "$oc"
pass "Ollama collector honours OPENCODE_DB and the opencode-v2.db fallback"
