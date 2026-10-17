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

[[ $(jq -r '.hasPromptStats' <<<"$result") == "false" ]] ||
  fail "Copilot collector keeps billed requests out of the prompt totals" "$result"
pass "Copilot collector keeps billed requests out of the prompt totals"

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
# Once the kept answer's window has reset, its usage is back at zero.
for cache in collector.cache_root().glob("copilot-limits-*.json"):
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

[[ $(jq -c '.lapsed | {label: .limits[0].label, zero: (.limits[0].percent == 0), resetsAt: .limits[0].resetsAt, stale: .limitsStale, tierLabel}' <<<"$result") == '{"label":"Monthly allowance","zero":true,"resetsAt":"","stale":true,"tierLabel":"Business"}' ]] ||
  fail "Copilot collector resets a kept allowance once its window ends" "$result"
pass "Copilot collector resets a kept allowance once its window ends"

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

[[ $(jq -r '.hasPromptStats' <<<"$result") == "true" ]] ||
  fail "Copilot transcript fallback offers its prompts to the panel" "$result"
pass "Copilot transcript fallback offers its prompts to the panel"

[[ $(jq -c '.modelUsage["claude-sonnet-4.6"]' <<<"$result") == '{"inputTokens":500,"outputTokens":340,"cacheReadInputTokens":900,"cacheCreationInputTokens":100}' ]] ||
  fail "Copilot transcript fallback reads shutdown usage once" "$result"
pass "Copilot transcript fallback reads shutdown usage once"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "1840" ]] ||
  fail "Copilot transcript fallback sums today's tokens" "$result"
pass "Copilot transcript fallback sums today's tokens"

[[ $(jq -r '.limits[0].percent' <<<"$result") == "0.002" ]] ||
  fail "Copilot transcript fallback estimates spend from shutdown cost" "$result"
pass "Copilot transcript fallback estimates spend from shutdown cost"

# A store that is there but can't be snapshotted leaves only the transcripts,
# and that short scan isn't cached for the runs after it.
[[ -n $(find "$TRANSCRIPT_HOME/.cache" -name 'copilot-scan-*.json') ]] ||
  fail "Copilot collector caches a complete scan" "$(find "$TRANSCRIPT_HOME/.cache")"
find "$TRANSCRIPT_HOME/.cache" -name 'copilot-scan-*.json' -delete
printf 'not a database' >"$TRANSCRIPT_HOME/.copilot/session-store.db"
result=$(run_collector_in "$TRANSCRIPT_HOME")
[[ $(jq -r '.todayPrompts' <<<"$result") == "3" && -z $(find "$TRANSCRIPT_HOME/.cache" -name 'copilot-scan-*.json') ]] ||
  fail "Copilot collector doesn't cache a scan its store couldn't join" "$result"
pass "Copilot collector doesn't cache a scan its store couldn't join"
rm "$TRANSCRIPT_HOME/.copilot/session-store.db"

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

# The quota as gh's account sees it: a fake gh logs every run, and hosts.yml
# names who it is signed in as, so a reused answer needs no gh at all.
mkdir -p "$TEST_HOME/fakebin" "$TEST_HOME/nogh" "$TEST_HOME/gh"
cat >"$TEST_HOME/fakebin/gh" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$GH_LOG"
[[ $1 == "auth" && $2 == "token" ]] && echo "gh-token"
EOF
chmod +x "$TEST_HOME/fakebin/gh"
mkdir -p "$TEST_HOME/brokengh"
printf '#!/bin/bash\nexit 1\n' >"$TEST_HOME/brokengh/gh"
chmod +x "$TEST_HOME/brokengh/gh"
printf 'github.com:\n    users:\n        tester:\n    git_protocol: ssh\n    user: tester\n' >"$TEST_HOME/gh/hosts.yml"
printf '{"monthlyCredits": 3000}' >"$TEST_HOME/.config/omarchy/agents/copilot.json"

result=$(HOME="$TEST_HOME" COPILOT_HOME="$TEST_HOME/.copilot" XDG_CONFIG_HOME="$TEST_HOME/.config" \
  XDG_CACHE_HOME="$TEST_HOME/.cache-limits" GH_CONFIG_DIR="$TEST_HOME/gh" GH_LOG="$TEST_HOME/gh.log" \
  FAKEBIN="$TEST_HOME/fakebin" NOGH="$TEST_HOME/nogh" BROKENGH="$TEST_HOME/brokengh" \
  python3 - "$ROOT/bin/omarchy-agent-usage-copilot" <<'PY'
import datetime as dt
import hashlib
import importlib.machinery
import importlib.util
import io
import json
import os
import sys
import time
from pathlib import Path

for var in ("COPILOT_QUOTA_TOKEN", "GH_TOKEN", "GITHUB_TOKEN"):
  os.environ.pop(var, None)
os.environ["PATH"] = os.environ["FAKEBIN"] + ":" + os.environ["PATH"]

loader = importlib.machinery.SourceFileLoader("collector", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)

reset = (dt.datetime.now(dt.timezone.utc) + dt.timedelta(days=10)).replace(microsecond=0)
payload = {
  "copilot_plan": "individual",
  "quota_reset_date_utc": reset.strftime("%Y-%m-%dT%H:%M:%S.000Z"),
  "quota_snapshots": {"premium_interactions": {"unlimited": False, "entitlement": 300, "credits_used": 30}},
}
gh_log = Path(os.environ["GH_LOG"])
asked = []


def answer(request, timeout=None):
  asked.append(request.get_header("Authorization"))
  return io.BytesIO(json.dumps(payload).encode())


def offline(request, timeout=None):
  raise collector.urllib.error.URLError("offline")


def status(code):
  def urlopen(request, timeout=None):
    raise collector.urllib.error.HTTPError(request.full_url, code, "", {}, None)
  return urlopen


def unasked(request, timeout=None):
  raise AssertionError("the quota should not have been asked")


def run(urlopen, *args):
  collector.urllib.request.urlopen = urlopen
  out = io.StringIO()
  sys.argv = ["omarchy-agent-usage-copilot", *args]
  sys.stdout, real_stdout = out, sys.stdout
  collector.main()
  sys.stdout = real_stdout
  record = json.loads(out.getvalue())
  return {
    "limits": [[limit["label"], limit["percent"], limit["resetsAt"] != ""] for limit in record["limits"]],
    "stale": record["limitsStale"],
    "status": record["usageStatusText"],
    "help": record["authHelpText"],
    "retry": record.get("retryAdvised", False),
    "tier": record["tierLabel"],
    "gh": len(gh_log.read_text().splitlines()) if gh_log.exists() else 0,
  }


out = {}
out["live"] = run(answer, "--force")
out["reused"] = run(unasked)
out["limitsOnly"] = run(unasked, "--limits-only")
out["forced"] = run(answer, "--force")
out["asked"] = sorted(set(asked))
out["offline"] = run(offline, "--force")

# A cache stamped in the future (the clock went back) is still the answer
# kept past a failed check.
cache = next(collector.cache_root().glob("copilot-limits-*.json"))
future = time.time() + 86400
os.utime(cache, (future, future))
out["future"] = run(offline, "--force")
out["status500"] = run(status(500), "--force")

# Another gh account has nothing kept; how it failed decides what it says.
(Path(os.environ["GH_CONFIG_DIR"]) / "hosts.yml").write_text("github.com:\n    user: someone-else\n")
out["otherOffline"] = run(offline, "--force")
out["other500"] = run(status(500), "--force")
out["other401"] = run(status(401), "--force")

# gh still signed in to the first account but failing to hand over its token
# keeps that account's last allowance, stale.
(Path(os.environ["GH_CONFIG_DIR"]) / "hosts.yml").write_text("github.com:\n    user: tester\n")
fake_path = os.environ["PATH"]
os.environ["PATH"] = os.environ["BROKENGH"] + ":" + fake_path
out["ghFailed"] = run(unasked, "--force")
os.environ["PATH"] = fake_path

# No token anywhere, with the CLI in use: waiting for a sign-in.
os.environ["PATH"] = os.environ["NOGH"]
out["noToken"] = run(unasked, "--force")

# An answer under the old copilot-quota-* name is adopted once.
os.environ["COPILOT_QUOTA_TOKEN"] = "legacy-token"
legacy = collector.cache_root() / f"copilot-quota-{hashlib.sha256(b'legacy-token').hexdigest()[:16]}.json"
legacy.write_text(json.dumps({"available": True, "entitlement": 100, "used": 40, "resetsAt": reset.isoformat(), "planLabel": "Pro", "fetchedAtMs": 1000}))
out["legacy"] = run(offline, "--force")
out["legacyMoved"] = [legacy.exists(), (collector.cache_root() / f"copilot-limits-{hashlib.sha256(b'legacy-token').hexdigest()[:16]}.json").exists()]
print(json.dumps(out))
PY
)

[[ $(jq -c '.live' <<<"$result") == '{"limits":[["Monthly allowance",0.1,true]],"stale":false,"status":"","help":"","retry":false,"tier":"Pro","gh":1}' ]] ||
  fail "Copilot collector asks the quota as gh's account" "$result"
pass "Copilot collector asks the quota as gh's account"

[[ $(jq -c '[.reused, .limitsOnly] | map({limits, stale, help, gh})' <<<"$result") == '[{"limits":[["Monthly allowance",0.1,true]],"stale":false,"help":"","gh":1},{"limits":[["Monthly allowance",0.1,true]],"stale":false,"help":"","gh":1}]' ]] ||
  fail "Copilot collector reuses a recent quota answer without running gh" "$result"
[[ $(jq -c '{gh: .forced.gh, asked}' <<<"$result") == '{"gh":2,"asked":["Bearer gh-token"]}' ]] ||
  fail "Copilot collector asks again on --force" "$result"
pass "Copilot collector reuses a recent quota answer without running gh, and --force asks again"

[[ $(jq -c '.offline | {stale, status, retry, kept: (.limits | length), help: (.help | test("Retrying"))}' <<<"$result") == '{"stale":true,"status":"","retry":true,"kept":1,"help":true}' ]] ||
  fail "Copilot collector advises a retry when GitHub can't be reached" "$result"
[[ $(jq -c '.status500 | {stale, retry, help: (.help | test("500"))}' <<<"$result") == '{"stale":true,"retry":false,"help":true}' ]] ||
  fail "Copilot collector doesn't advise a retry for an error status" "$result"
pass "Copilot collector advises a retry only when GitHub can't be reached"

[[ $(jq -c '.future | {stale, kept: (.limits | length)}' <<<"$result") == '{"stale":true,"kept":1}' ]] ||
  fail "Copilot collector keeps a cache whose file time is in the future" "$result"
pass "Copilot collector keeps a cache whose file time is in the future"

[[ $(jq -c '[.otherOffline, .other500, .other401] | map({status, retry, help: (.help != "")})' <<<"$result") == '[{"status":"Copilot limits unavailable","retry":true,"help":true},{"status":"Copilot limits unavailable","retry":false,"help":true},{"status":"Sign-in expired","retry":false,"help":true}]' ]] ||
  fail "Copilot collector says what failed when nothing is kept" "$result"
[[ $(jq -r '.other500.help' <<<"$result") == *"status 500"* && $(jq -r '.other500.help' <<<"$result") != *"gh auth login"* ]] ||
  fail "Copilot collector gives an error status as the detail, not a sign-in hint" "$result"
pass "Copilot collector says what failed when nothing is kept"

[[ $(jq -c '.ghFailed | {limits, stale, status, retry, help: (.help | test("gh auth status"))}' <<<"$result") == '{"limits":[["Monthly allowance",0.1,true]],"stale":true,"status":"","retry":false,"help":true}' ]] ||
  fail "Copilot collector keeps the last allowance when gh can't hand over its token" "$result"
pass "Copilot collector keeps the last allowance when gh can't hand over its token"

[[ $(jq -c '.noToken | {status, help: (.help | test("gh auth login"))}' <<<"$result") == '{"status":"Waiting for auth","help":true}' ]] ||
  fail "Copilot collector waits for a GitHub sign-in" "$result"
pass "Copilot collector waits for a GitHub sign-in"

[[ $(jq -c '{limits: .legacy.limits, stale: .legacy.stale, moved: .legacyMoved}' <<<"$result") == '{"limits":[["Monthly allowance",0.4,true]],"stale":true,"moved":[false,true]}' ]] ||
  fail "Copilot collector adopts an answer cached under the old name" "$result"
pass "Copilot collector adopts an answer cached under the old name"
