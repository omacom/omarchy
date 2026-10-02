#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

# Fixtures are stamped in UTC and checked against the local day and the UTC
# allowance month; pinning the zone keeps both on the same date at any hour.
export TZ=UTC

TEST_HOME=$(mktemp -d)
EMPTY_HOME=$(mktemp -d)
TRANSCRIPT_HOME=$(mktemp -d)
MIDNIGHT_HOME=$(mktemp -d)
HISTORY_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$EMPTY_HOME" "$TRANSCRIPT_HOME" "$MIDNIGHT_HOME" "$HISTORY_HOME"' EXIT

for home in "$TEST_HOME" "$EMPTY_HOME" "$TRANSCRIPT_HOME" "$MIDNIGHT_HOME" "$HISTORY_HOME"; do
  mkdir -p "$home/.copilot/session-state" "$home/.config/omarchy/agents" "$home/.cache"
  printf '{"monthlyCredits": 1500, "remote": false}' >"$home/.config/omarchy/agents/copilot.json"
done
rm -rf "$EMPTY_HOME/.copilot"

# Every collector run below re-derives "today" and the allowance month from
# the clock, and compares them with the stamps taken here. Starting too close to
# UTC midnight (under TZ=UTC also the month boundary) lets them diverge mid-run,
# so wait for the new day instead.
seconds_to_midnight=$(( 86400 - $(date -u +%s) % 86400 ))
if (( seconds_to_midnight < 120 )); then
  sleep "$seconds_to_midnight"
fi

now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
yesterday=$(date -u -d '1 day ago' +%Y-%m-%dT%H:%M:%SZ)
today=$(date +%F)

run_collector_in() {
  local home=$1
  shift
  HOME="$home" COPILOT_HOME="$home/.copilot" XDG_CONFIG_HOME="$home/.config" \
    XDG_CACHE_HOME="$home/.cache" "$ROOT/bin/omarchy-agent-usage-copilot" --force "$@"
}

# The session store carries one row per billed assistant request. As in the
# real CLI, input_tokens is the whole prompt (cache reads and writes included)
# and output_tokens already includes reasoning_tokens.
python3 - "$TEST_HOME/.copilot/session-store.db" "$now" <<'PY'
import sqlite3
import sys

db = sys.argv[1]
stamp = sys.argv[2]
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE assistant_usage_events (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id TEXT, created_at TEXT, model TEXT, total_nano_aiu INTEGER, input_tokens INTEGER, output_tokens INTEGER, cache_read_tokens INTEGER, cache_write_tokens INTEGER, reasoning_tokens INTEGER, duration_ms INTEGER)")
conn.executemany(
  "INSERT INTO assistant_usage_events (session_id, created_at, model, total_nano_aiu, input_tokens, output_tokens, cache_read_tokens, cache_write_tokens, reasoning_tokens, duration_ms) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
  [
    ("sess-a", stamp, "claude-sonnet-4-5", 500_000_000, 1600, 300, 400, 0, 50, 3000),
    ("sess-a", stamp, "claude-sonnet-4-5", 500_000_000, 900, 200, 100, 0, 0, 2000),
    ("sess-b", stamp, "gpt-5.2", 500_000_000, 1900, 700, 100, 300, 100, 5000),
  ],
)
conn.commit()
conn.close()
PY

result=$(run_collector_in "$TEST_HOME")

[[ $(jq -r '.id' <<<"$result") == "copilot" ]] ||
  fail "Copilot collector identifies itself" "$result"
pass "Copilot collector identifies itself"

[[ $(jq -r '.ready' <<<"$result") == "true" ]] ||
  fail "Copilot collector is ready with usage" "$result"
pass "Copilot collector is ready with usage"

[[ $(jq -r '.todayPrompts' <<<"$result") == "3" ]] ||
  fail "Copilot collector counts billed requests" "$result"
pass "Copilot collector counts billed requests"

[[ $(jq -r '.todaySessions' <<<"$result") == "2" ]] ||
  fail "Copilot collector counts distinct sessions" "$result"
pass "Copilot collector counts distinct sessions"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "5600" ]] ||
  fail "Copilot collector sums each token once" "$result"
pass "Copilot collector sums each token once"

[[ $(jq -c '.modelUsage["claude-sonnet-4-5"]' <<<"$result") == '{"inputTokens":2000,"outputTokens":500,"cacheReadInputTokens":500,"cacheCreationInputTokens":0}' ]] ||
  fail "Copilot collector keeps reasoning inside output" "$result"
pass "Copilot collector keeps reasoning inside output"

[[ $(jq -c '.modelUsage["gpt-5.2"]' <<<"$result") == '{"inputTokens":1500,"outputTokens":700,"cacheReadInputTokens":100,"cacheCreationInputTokens":300}' ]] ||
  fail "Copilot collector splits cached tokens off the prompt" "$result"
pass "Copilot collector splits cached tokens off the prompt"

[[ $(jq -r '.recentDays[-1].date' <<<"$result") == "$today" ]] ||
  fail "Copilot collector reports today's day row" "$result"
pass "Copilot collector reports today's day row"

[[ $(jq -r '.limits[0].label' <<<"$result") == "Monthly allowance (est.)" ]] ||
  fail "Copilot collector labels the local estimate" "$result"
pass "Copilot collector labels the local estimate"

[[ $(jq -r '.limits[0].percent' <<<"$result") == "0.001" ]] ||
  fail "Copilot collector divides month credits by allowance" "$result"
pass "Copilot collector divides month credits by allowance"

[[ $(jq -r '.limits[0].resetsAt' <<<"$result") != "" ]] ||
  fail "Copilot collector sets an allowance reset time" "$result"
pass "Copilot collector sets an allowance reset time"

# Without the live quota or a budget there is no plan and no meter, while the
# local stats still show.
printf '{"remote": false}' >"$TEST_HOME/.config/omarchy/agents/copilot.json"
result=$(run_collector_in "$TEST_HOME")

[[ $(jq -r '.ready' <<<"$result") == "true" && $(jq -r '.tierLabel' <<<"$result") == "" && $(jq -c '.limits' <<<"$result") == "[]" ]] ||
  fail "Copilot collector shows no meter without the quota or a budget" "$result"
pass "Copilot collector shows no meter without the quota or a budget"

printf '{"monthlyCredits": 3000, "remote": false}' >"$TEST_HOME/.config/omarchy/agents/copilot.json"
result=$(run_collector_in "$TEST_HOME")

[[ $(jq -r '.tierLabel' <<<"$result") == "" && $(jq -r '.limits[0].percent' <<<"$result") == "0.0005" ]] ||
  fail "Copilot collector estimates from a monthlyCredits budget" "$result"
pass "Copilot collector estimates from a monthlyCredits budget"

# The live quota answers in AI credits, account-wide; it wins over the local
# estimate and supplies the plan and reset date. A failed check after it
# keeps that answer, marked stale.
printf '{"monthlyCredits": 3000}' >"$TEST_HOME/.config/omarchy/agents/copilot.json"
result=$(HOME="$TEST_HOME" COPILOT_HOME="$TEST_HOME/.copilot" XDG_CONFIG_HOME="$TEST_HOME/.config" \
  XDG_CACHE_HOME="$TEST_HOME/.cache" COPILOT_QUOTA_TOKEN="test-token" EMPTY_HOME="$EMPTY_HOME" \
  python3 - "$ROOT/bin/omarchy-agent-usage-copilot" <<'PY'
import datetime as dt
import importlib.machinery
import importlib.util
import io
import json
import os
import sys

loader = importlib.machinery.SourceFileLoader("collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

reset = (dt.datetime.now(dt.timezone.utc) + dt.timedelta(days=10)).replace(microsecond=0)
payload = {
  "copilot_plan": "business",
  "quota_reset_date_utc": reset.strftime("%Y-%m-%dT%H:%M:%S.000Z"),
  "quota_snapshots": {
    "premium_interactions": {
      "unlimited": False,
      "token_based_billing": True,
      "entitlement": 1900,
      "credits_used": 475,
      "remaining": 1425,
    }
  },
}
def run(*extra):
  out = io.StringIO()
  sys.argv = ["omarchy-agent-usage-copilot", "--force", *extra]
  sys.stdout, real_stdout = out, sys.stdout
  collector.main()
  sys.stdout = real_stdout
  return json.loads(out.getvalue())


def offline(request, timeout=None):
  raise collector.urllib.error.URLError("offline")


def unasked(request, timeout=None):
  raise AssertionError("the quota should not have been asked")


collector.urllib.request.urlopen = lambda request, timeout=None: io.BytesIO(json.dumps(payload).encode())
record = run()
collector.urllib.request.urlopen = offline
stale = run()
# Once the kept answer's window has reset, its usage no longer applies.
for cache in collector.cache_root().glob("copilot-quota-*.json"):
  kept = json.loads(cache.read_text())
  cache.write_text(json.dumps(dict(kept, resetsAt="2020-01-01T00:00:00.000Z")))
lapsed = run()
# gh signed in on a machine that never ran the Copilot CLI: nothing is asked.
collector.urllib.request.urlopen = unasked
clean = run("--copilot-home", os.path.join(os.environ["EMPTY_HOME"], ".copilot"))
print(json.dumps({"record": record, "stale": stale, "lapsed": lapsed, "clean": clean, "reset": reset.isoformat()}))
PY
)

[[ $(jq -c '{fresh: .record.limitsStale, stamped: (.record.limitsFetchedAt > 0)}' <<<"$result") == '{"fresh":false,"stamped":true}' ]] ||
  fail "Copilot collector stamps the live allowance" "$result"
pass "Copilot collector stamps the live allowance"

[[ $(jq -c '{same: (.stale.limits == .record.limits), stale: .stale.limitsStale, stamp: (.stale.limitsFetchedAt == .record.limitsFetchedAt), tier: .stale.tierLabel}' <<<"$result") == '{"same":true,"stale":true,"stamp":true,"tier":"Business"}' ]] ||
  fail "Copilot collector keeps the last live allowance, stale, after a failed check" "$result"
pass "Copilot collector keeps the last live allowance, stale, after a failed check"

[[ $(jq -c '.lapsed | {label: .limits[0].label, stale: .limitsStale, tierLabel}' <<<"$result") == '{"label":"Monthly allowance (est.)","stale":false,"tierLabel":""}' ]] ||
  fail "Copilot collector drops a kept allowance once its window resets" "$result"
pass "Copilot collector drops a kept allowance once its window resets"

[[ $(jq -c '.clean | {ready, tierLabel, limits}' <<<"$result") == '{"ready":false,"tierLabel":"","limits":[]}' ]] ||
  fail "Copilot collector doesn't ask GitHub where the CLI never ran" "$result"
pass "Copilot collector doesn't ask GitHub where the CLI never ran"

[[ $(jq -r '.record.limits[0].label' <<<"$result") == "Monthly allowance" && $(jq -r '.record.limits[0].percent' <<<"$result") == "0.25" ]] ||
  fail "Copilot collector reads the live allowance in credits" "$result"
pass "Copilot collector reads the live allowance in credits"

[[ $(jq -r '.record.tierLabel' <<<"$result") == "Business" ]] ||
  fail "Copilot collector takes the plan from the live quota" "$result"
pass "Copilot collector takes the plan from the live quota"

[[ $(jq -r '.record.limits[0].resetsAt' <<<"$result") == $(jq -r '.reset' <<<"$result") ]] ||
  fail "Copilot collector takes the reset time from the live quota" "$result"
pass "Copilot collector takes the reset time from the live quota"

# Lifetime totals cover the whole store, however many rows it holds.
python3 - "$HISTORY_HOME/.copilot/session-store.db" "$now" <<'PY'
import datetime as dt
import sqlite3
import sys

db = sys.argv[1]
stamp = sys.argv[2]
old = (dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=100)).strftime("%Y-%m-%dT%H:%M:%SZ")
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE assistant_usage_events (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id TEXT, created_at TEXT, model TEXT, total_nano_aiu INTEGER, input_tokens INTEGER, output_tokens INTEGER, cache_read_tokens INTEGER, cache_write_tokens INTEGER, reasoning_tokens INTEGER)")
rows = [(f"old-{n % 7}", old, "gpt-5.2", 0, 10, 1, 0, 0, 0) for n in range(25_000)]
rows.append(("new", stamp, "gpt-5.2", 0, 10, 1, 0, 0, 0))
conn.executemany(
  "INSERT INTO assistant_usage_events (session_id, created_at, model, total_nano_aiu, input_tokens, output_tokens, cache_read_tokens, cache_write_tokens, reasoning_tokens) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
  rows,
)
conn.commit()
conn.close()
PY

result=$(run_collector_in "$HISTORY_HOME")

[[ $(jq -r '.totalPrompts' <<<"$result") == "25001" && $(jq -r '.totalSessions' <<<"$result") == "8" && $(jq -r '.activeDays' <<<"$result") == "2" ]] ||
  fail "Copilot collector counts lifetime totals from the full store" "$(jq -c '{totalPrompts, totalSessions, activeDays}' <<<"$result")"
pass "Copilot collector counts lifetime totals from the full store"

# Without a usage table the transcripts stand in. Shutdown metrics are
# cumulative across resumes and already include cached and reasoning tokens;
# replies after the last shutdown count on their output tokens alone.
mkdir -p "$TRANSCRIPT_HOME/.copilot/session-state/sess-t"
jq -nc --arg ts "$now" '
  def ev($type; $data): {type: $type, data: $data, id: "x", timestamp: $ts};
  def metrics($in; $out; $read; $write; $nano): {
    "claude-sonnet-4.6": {
      requests: {count: 1, cost: 1},
      usage: {inputTokens: $in, outputTokens: $out, cacheReadTokens: $read, cacheWriteTokens: $write, reasoningTokens: 20},
      totalNanoAiu: $nano
    }
  };
  ev("session.start"; {sessionId: "sess-t"}),
  ev("user.message"; {content: "first prompt"}),
  ev("user.message"; {content: "injected", source: "skill-demo"}),
  ev("assistant.message"; {model: "claude-sonnet-4.6", outputTokens: 100}),
  ev("session.shutdown"; {shutdownType: "routine", modelMetrics: metrics(1000; 200; 600; 100; 2000000000)}),
  ev("session.resume"; {}),
  ev("user.message"; {content: "second prompt", source: "user"}),
  ev("assistant.message"; {model: "claude-sonnet-4.6", outputTokens: 50}),
  ev("session.shutdown"; {shutdownType: "routine", modelMetrics: metrics(1500; 300; 900; 100; 3000000000)}),
  ev("user.message"; {content: "third prompt"}),
  ev("assistant.message"; {model: "claude-sonnet-4.6", outputTokens: 40})
' >"$TRANSCRIPT_HOME/.copilot/session-state/sess-t/events.jsonl"

result=$(run_collector_in "$TRANSCRIPT_HOME")

[[ $(jq -r '.ready' <<<"$result") == "true" && $(jq -r '.todayPrompts' <<<"$result") == "3" && $(jq -r '.todaySessions' <<<"$result") == "1" ]] ||
  fail "Copilot transcript fallback counts the user's prompts" "$result"
pass "Copilot transcript fallback counts the user's prompts"

[[ $(jq -c '.modelUsage["claude-sonnet-4.6"]' <<<"$result") == '{"inputTokens":500,"outputTokens":340,"cacheReadInputTokens":900,"cacheCreationInputTokens":100}' ]] ||
  fail "Copilot transcript fallback reads shutdown usage once" "$result"
pass "Copilot transcript fallback reads shutdown usage once"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "1840" ]] ||
  fail "Copilot transcript fallback sums today's tokens" "$result"
pass "Copilot transcript fallback sums today's tokens"

[[ $(jq -r '.limits[0].percent' <<<"$result") == "0.002" ]] ||
  fail "Copilot transcript fallback estimates spend from shutdown cost" "$result"
pass "Copilot transcript fallback estimates spend from shutdown cost"

# A segment that spans midnight books its shutdown totals on the days its
# replies landed on: output by each day's reply output (40 / 60), everything
# else by reply count (2 / 1).
mkdir -p "$MIDNIGHT_HOME/.copilot/session-state/sess-m"
jq -nc --arg ts "$now" --arg before "$yesterday" '
  def ev($type; $data; $at): {type: $type, data: $data, id: "x", timestamp: $at};
  ev("user.message"; {content: "late prompt"}; $before),
  ev("assistant.message"; {model: "claude-sonnet-4.6", outputTokens: 30}; $before),
  ev("assistant.message"; {model: "claude-sonnet-4.6", outputTokens: 10}; $before),
  ev("assistant.message"; {model: "claude-sonnet-4.6", outputTokens: 60}; $ts),
  ev("session.shutdown"; {shutdownType: "routine", modelMetrics: {
    "claude-sonnet-4.6": {
      usage: {inputTokens: 1300, outputTokens: 100, cacheReadTokens: 600, cacheWriteTokens: 100, reasoningTokens: 0},
      totalNanoAiu: 0
    }
  }}; $ts)
' >"$MIDNIGHT_HOME/.copilot/session-state/sess-m/events.jsonl"

result=$(run_collector_in "$MIDNIGHT_HOME")

[[ $(jq -r '.recentDays[-2].messageCount' <<<"$result") == "906" && $(jq -r '.recentDays[-1].messageCount' <<<"$result") == "494" && $(jq -r '.todayTotalTokens' <<<"$result") == "494" ]] ||
  fail "Copilot transcript fallback books a midnight-spanning segment on both days" "$(jq -c '{recentDays, todayTotalTokens}' <<<"$result")"
pass "Copilot transcript fallback books a midnight-spanning segment on both days"

[[ $(jq -c '.modelUsage["claude-sonnet-4.6"]' <<<"$result") == '{"inputTokens":600,"outputTokens":100,"cacheReadInputTokens":600,"cacheCreationInputTokens":100}' ]] ||
  fail "Copilot transcript fallback keeps a split segment's totals whole" "$result"
pass "Copilot transcript fallback keeps a split segment's totals whole"

# A machine that never ran the CLI reports nothing and stays hidden: no meter,
# no ready.
result=$(run_collector_in "$EMPTY_HOME")

[[ $(jq -r '.ready' <<<"$result") == "false" && $(jq -c '.limits' <<<"$result") == "[]" ]] ||
  fail "Copilot collector stays hidden on a clean machine" "$result"
pass "Copilot collector stays hidden on a clean machine"
