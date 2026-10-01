#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# Session counting walks ~/.omp/agent/sessions; pin HOME so the collector
# reads the fixture, not the developer's real omp state.
mkdir -p "$TEST_HOME/.omp/agent/sessions"
printf '{}\n' > "$TEST_HOME/.omp/agent/sessions/session-a.jsonl"
printf '{}\n' > "$TEST_HOME/.omp/agent/sessions/session-b.jsonl"

# Fake omp binaries for run_stats: one healthy, one failing, one non-JSON.
mkdir -p "$TEST_HOME/bin"
cat > "$TEST_HOME/bin/omp-stats-ok" <<'EOF'
#!/bin/sh
printf '%s' '{"overall":{"totalRequests":1},"byModel":[],"timeSeries":[]}'
EOF
cat > "$TEST_HOME/bin/omp-stats-fail" <<'EOF'
#!/bin/sh
exit 3
EOF
cat > "$TEST_HOME/bin/omp-stats-badjson" <<'EOF'
#!/bin/sh
printf '%s' 'not json'
EOF
chmod +x "$TEST_HOME/bin/omp-stats-ok" "$TEST_HOME/bin/omp-stats-fail" "$TEST_HOME/bin/omp-stats-badjson"

# Without an omp binary on PATH the collector must still print a valid,
# hidden-by-default record.
no_omp=$(HOME="$TEST_HOME" PATH="$TEST_HOME/bin" "$ROOT/bin/omarchy-agent-usage-omp")
[[ $(jq -r '.id + ":" + (.ready | tostring) + ":" + .usageStatusText' <<<"$no_omp") == "omp:false:omp unavailable" ]] ||
  fail "omp collector prints a valid record without an omp binary" "$no_omp"
pass "omp collector prints a valid record without an omp binary"

result=$(HOME="$TEST_HOME" python3 - "$ROOT/bin/omarchy-agent-usage-omp" "$TEST_HOME" <<'PY'
import importlib.machinery
import importlib.util
import json
import os
import subprocess
import sys
import time
from datetime import datetime, time as dtime, timedelta
from pathlib import Path

collector_path = str(Path(sys.argv[1]))
test_home = Path(sys.argv[2])
os.environ["HOME"] = str(test_home)

# Date bucketing resolves in local time; pin the zone so the today/yesterday
# fixtures land on the intended calendar days no matter where the test runs.
os.environ["TZ"] = "UTC"
time.tzset()

loader = importlib.machinery.SourceFileLoader("omp_collector", collector_path)
spec = importlib.util.spec_from_loader(loader.name, loader)
scanner = importlib.util.module_from_spec(spec)
loader.exec_module(scanner)

# ---- summarize() mapping ----
now_ms = int(time.time() * 1000)
yesterday_ms = now_ms - 86400 * 1000
# A second hourly bucket for today (01:00): omp emits one bucket per hour for
# its 24-hour window, and today's prompt count must sum them, not keep only
# the first.
today_hour1_ms = int((datetime.combine(datetime.now().date(), dtime.min) + timedelta(hours=1)).timestamp() * 1000)
data = {
  "overall": {"totalRequests": 5},
  "byModel": [
    # Same model through two providers: byModel groups by (model, provider),
    # so the two entries must accumulate, not overwrite.
    {"model": "deepseek-chat", "provider": "deepseek",
     "totalInputTokens": 100, "totalOutputTokens": 20,
     "totalCacheReadTokens": 5, "totalCacheWriteTokens": 2},
    {"model": "deepseek-chat", "provider": "fireworks",
     "totalInputTokens": 40, "totalOutputTokens": 10,
     "totalCacheReadTokens": 3, "totalCacheWriteTokens": 1},
    {"model": "claude-sonnet-4", "provider": "anthropic",
     "totalInputTokens": 200, "totalOutputTokens": 40,
     "totalCacheReadTokens": 20, "totalCacheWriteTokens": 5},
  ],
  "timeSeries": [
    {"timestamp": now_ms, "requests": 3, "tokens": 120},
    {"timestamp": today_hour1_ms, "requests": 5, "tokens": 80},
    {"timestamp": yesterday_ms, "requests": 1, "tokens": 40},
  ],
}
stats = scanner.summarize(data)
summary = {
  "totalPrompts": stats["totalPrompts"],
  "todayPrompts": stats["todayPrompts"],
  "todayTotalTokens": stats["todayTotalTokens"],
  "todaySessions": stats["todaySessions"],
  "totalSessions": stats["totalSessions"],
  "activeDays": stats["activeDays"],
  "modelUsage": stats["modelUsage"],
  "recentDaysLast": stats["recentDays"][-1]["messageCount"],
  "recentDaysPrev": stats["recentDays"][-2]["messageCount"],
}

# ---- run_stats failure modes ----
bin_dir = test_home / "bin"
summary["runStatsOk"] = isinstance(scanner.run_stats(str(bin_dir / "omp-stats-ok")), dict)
summary["runStatsNonZero"] = scanner.run_stats(str(bin_dir / "omp-stats-fail")) is None
summary["runStatsBadJson"] = scanner.run_stats(str(bin_dir / "omp-stats-badjson")) is None
summary["runStatsMissing"] = scanner.run_stats("/nonexistent/omp-binary") is None

# A timeout must degrade to no-stats, not raise through main().
original_run = scanner.subprocess.run
def timeout_run(*args, **kwargs):
    raise subprocess.TimeoutExpired(args[0] if args else ["omp"], 120)
scanner.subprocess.run = timeout_run
summary["runStatsTimeout"] = scanner.run_stats(str(bin_dir / "omp-stats-ok")) is None
scanner.subprocess.run = original_run

# ---- fetch_deepseek_balance() ----
class FakeResponse:
    def __init__(self, payload):
        self._payload = payload
    def read(self):
        return json.dumps(self._payload).encode("utf-8")
    def __enter__(self):
        return self
    def __exit__(self, *exc):
        return False

class FakeProc:
    def __init__(self, stdout):
        self.stdout = stdout

def with_balance(payload):
    scanner.subprocess.run = lambda *a, **k: FakeProc("ds_test_key\n")
    scanner.urllib.request.urlopen = lambda *a, **k: FakeResponse(payload)

with_balance({"balance_infos": [{"currency": "USD", "total_balance": "110.00",
                                  "granted_balance": "10.00", "topped_up_balance": "100.00"}]})
summary["balance"] = scanner.fetch_deepseek_balance("/fake/omp")

# An exhausted account still surfaces a zero balance, not no balance at all.
with_balance({"balance_infos": [{"currency": "USD", "total_balance": "0.00",
                                  "granted_balance": "0.00", "topped_up_balance": "0.00"}]})
summary["zeroBalance"] = scanner.fetch_deepseek_balance("/fake/omp")

# No stored key means no balance rather than a fabricated number.
scanner.subprocess.run = lambda *a, **k: FakeProc("")
scanner.urllib.request.urlopen = lambda *a, **k: FakeResponse(
    {"balance_infos": [{"currency": "USD", "total_balance": "1.00"}]})
summary["noKeyBalance"] = scanner.fetch_deepseek_balance("/fake/omp")

# ---- read_history() full-history mapping ----
# `omp stats --json` is capped at 24h; the seven-day series and all-time
# totals must come from omp's stats database instead. Build a fixture DB with
# messages spanning today, yesterday, and eight days ago (outside the 7-day
# window but still all-time).
import sqlite3
db_path = test_home / ".omp" / "stats.db"
db_path.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db_path)
conn.execute(
    "CREATE TABLE messages (model TEXT, timestamp INTEGER, input_tokens INTEGER, "
    "output_tokens INTEGER, cache_read_tokens INTEGER, cache_write_tokens INTEGER, "
    "total_tokens INTEGER)"
)
def at_ms(date, hour=12):
    return int(datetime.combine(date, dtime(hour)).timestamp() * 1000)
today = datetime.now().date()
conn.executemany(
    "INSERT INTO messages VALUES (?,?,?,?,?,?,?)",
    [
        ("deepseek-chat", at_ms(today, 10), 100, 20, 5, 2, 127),
        ("deepseek-chat", at_ms(today, 11), 40, 10, 3, 1, 54),
        ("claude-sonnet-4", at_ms(today - timedelta(days=1)), 200, 40, 20, 5, 265),
        ("claude-sonnet-4", at_ms(today - timedelta(days=8)), 300, 60, 30, 5, 395),
    ],
)
conn.commit()
conn.close()
hist = scanner.read_history(db_path)
summary["histMissing"] = scanner.read_history(test_home / ".omp" / "no-such.db") is None
summary["histTotalPrompts"] = hist["totalPrompts"]
summary["histTodayPrompts"] = hist["todayPrompts"]
summary["histTodayTotalTokens"] = hist["todayTotalTokens"]
summary["histActiveDays"] = hist["activeDays"]
summary["histModelUsage"] = hist["modelUsage"]["deepseek-chat"]
summary["histRecentLast"] = hist["recentDays"][-1]["messageCount"]
summary["histRecentPrev"] = hist["recentDays"][-2]["messageCount"]
summary["histRecentTotal"] = sum(day["messageCount"] for day in hist["recentDays"])

# ---- main() balance gate: a quiet DeepSeek account still surfaces balance ----
# The balance ledger belongs to the account, not the last 24 hours of usage.
# With no DeepSeek entry in the 24-hour byModel (a quiet day) but a stored key,
# main() must still emit the balance instead of skipping the fetch.
import contextlib
import io

scanner.find_omp = lambda: "/fake/omp"
scanner.run_stats = lambda binary: {
    "overall": {"totalRequests": 0},
    "byModel": [{"model": "claude-sonnet-4", "provider": "anthropic",
                 "totalInputTokens": 1, "totalOutputTokens": 1,
                 "totalCacheReadTokens": 0, "totalCacheWriteTokens": 0}],
    "timeSeries": [],
}
scanner.read_history = lambda db: {
    "todayPrompts": 0, "todayTotalTokens": 0,
    "recentDays": [{"date": "2000-01-01", "messageCount": 0}],
    "totalPrompts": 5, "activeDays": 1, "activeDates": ["2000-01-01"],
    "modelUsage": {},
}
scanner.subprocess.run = lambda *a, **k: FakeProc("ds_test_key\n")
scanner.urllib.request.urlopen = lambda *a, **k: FakeResponse(
    {"balance_infos": [{"currency": "USD", "total_balance": "42.00",
                         "granted_balance": "0.00", "topped_up_balance": "42.00"}]})

_argv = sys.argv
sys.argv = ["omp"]
try:
    _buf = io.StringIO()
    with contextlib.redirect_stdout(_buf):
        scanner.main()
    _quiet = json.loads(_buf.getvalue())
finally:
    sys.argv = _argv
summary["quietBalanceRemaining"] = _quiet.get("balance", {}).get("remaining")

# ---- main() stats failure preserves history instead of erasing it ----
# A transient omp stats timeout must not overwrite the last good record with
# zeros: when the stats DB is readable it still backs the historical fields.
scanner.find_omp = lambda: "/fake/omp"
scanner.run_stats = lambda binary: None
scanner.read_history = lambda db: {
    "todayPrompts": 2, "todayTotalTokens": 181,
    "recentDays": [{"date": "2000-01-01", "messageCount": 181}],
    "totalPrompts": 4, "activeDays": 3,
    "activeDates": ["2000-01-01", "2000-01-02", "2000-01-03"],
    "modelUsage": {"deepseek-chat": {"inputTokens": 140, "outputTokens": 30,
                                     "cacheReadInputTokens": 8, "cacheCreationInputTokens": 3}},
}
scanner.subprocess.run = lambda *a, **k: FakeProc("")

_argv = sys.argv
sys.argv = ["omp"]
try:
    _buf = io.StringIO()
    with contextlib.redirect_stdout(_buf):
        scanner.main()
    _degraded = json.loads(_buf.getvalue())
finally:
    sys.argv = _argv
summary["statsFailKeepsHistory"] = [
    _degraded.get("ready"),
    _degraded.get("totalPrompts"),
    _degraded.get("usageStatusText"),
    _degraded.get("authHelpText"),
]

# With no stats and no DB there is nothing to show; the collector must emit
# nothing and exit non-zero so the update runner leaves the previous record.
scanner.read_history = lambda db: None
_argv = sys.argv
sys.argv = ["omp"]
try:
    _buf = io.StringIO()
    with contextlib.redirect_stdout(_buf):
        _rc = scanner.main()
    _out = _buf.getvalue()
finally:
    sys.argv = _argv
summary["statsFailNoDb"] = [str(_rc), "1" if _out == "" else "0"]

print(json.dumps(summary, separators=(",", ":")))
PY
)

[[ $(jq -r '.totalPrompts' <<<"$result") == "5" ]] ||
  fail "omp collector maps totalRequests to totalPrompts" "$result"
pass "omp collector maps totalRequests to totalPrompts"

[[ $(jq -r '.todayPrompts' <<<"$result") == "8" ]] ||
  fail "omp collector sums today's request count across hourly buckets" "$result"
pass "omp collector sums today's request count across hourly buckets"

[[ $(jq -r '.todayTotalTokens' <<<"$result") == "200" ]] ||
  fail "omp collector totals today's tokens across hourly buckets" "$result"
pass "omp collector totals today's tokens across hourly buckets"

[[ $(jq -r '[.todaySessions, .totalSessions] | map(tostring) | join(":")' <<<"$result") == "2:2" ]] ||
  fail "omp collector counts sessions from ~/.omp/agent/sessions" "$result"
pass "omp collector counts sessions from ~/.omp/agent/sessions"

[[ $(jq -r '.activeDays' <<<"$result") == "2" ]] ||
  fail "omp collector counts active days" "$result"
pass "omp collector counts active days"

[[ $(jq -c '.modelUsage["deepseek-chat"]' <<<"$result") == '{"inputTokens":140,"outputTokens":30,"cacheReadInputTokens":8,"cacheCreationInputTokens":3}' ]] ||
  fail "omp collector accumulates per-model buckets across providers" "$result"
pass "omp collector accumulates per-model buckets across providers"

[[ $(jq -r '[.recentDaysLast, .recentDaysPrev] | map(tostring) | join(":")' <<<"$result") == "200:40" ]] ||
  fail "omp collector builds the seven-day token series" "$result"
pass "omp collector builds the seven-day token series"

[[ $(jq -r '[.runStatsOk, .runStatsNonZero, .runStatsBadJson, .runStatsMissing, .runStatsTimeout] | map(tostring) | join(":")' <<<"$result") == "true:true:true:true:true" ]] ||
  fail "omp collector degrades to no-stats on failure, missing binary, and timeout" "$result"
pass "omp collector degrades to no-stats on failure, missing binary, and timeout"

[[ $(jq -c '.balance' <<<"$result") == '{"remaining":110.0,"funded":0.0,"spent":0.0,"currency":"USD","estimated":false}' ]] ||
  fail "omp collector reports remaining-only balance, not a fabricated spend" "$result"
pass "omp collector reports remaining-only balance, not a fabricated spend"

[[ $(jq -c '.zeroBalance' <<<"$result") == '{"remaining":0.0,"funded":0.0,"spent":0.0,"currency":"USD","estimated":false}' ]] ||
  fail "omp collector keeps an exhausted zero balance" "$result"
pass "omp collector keeps an exhausted zero balance"

[[ $(jq -r '.noKeyBalance' <<<"$result") == "null" ]] ||
  fail "omp collector reports no balance without a stored key" "$result"
pass "omp collector reports no balance without a stored key"

[[ $(jq -r '.histMissing' <<<"$result") == "true" ]] ||
  fail "omp collector returns None from a missing stats database" "$result"
pass "omp collector returns None from a missing stats database"

[[ $(jq -r '.histTotalPrompts' <<<"$result") == "4" ]] ||
  fail "omp collector reads all-time prompt count from the database" "$result"
pass "omp collector reads all-time prompt count from the database"

[[ $(jq -r '.histTodayPrompts' <<<"$result") == "2" ]] ||
  fail "omp collector counts today's prompts from the database" "$result"
pass "omp collector counts today's prompts from the database"

[[ $(jq -r '.histTodayTotalTokens' <<<"$result") == "181" ]] ||
  fail "omp collector totals today's tokens from the database" "$result"
pass "omp collector totals today's tokens from the database"

[[ $(jq -r '.histActiveDays' <<<"$result") == "3" ]] ||
  fail "omp collector counts active days across full history" "$result"
pass "omp collector counts active days across full history"

[[ $(jq -c '.histModelUsage' <<<"$result") == '{"inputTokens":140,"outputTokens":30,"cacheReadInputTokens":8,"cacheCreationInputTokens":3}' ]] ||
  fail "omp collector accumulates per-model buckets from the database" "$result"
pass "omp collector accumulates per-model buckets from the database"

[[ $(jq -r '[.histRecentLast, .histRecentPrev] | map(tostring) | join(":")' <<<"$result") == "181:265" ]] ||
  fail "omp collector builds the seven-day series from the database" "$result"
pass "omp collector builds the seven-day series from the database"

[[ $(jq -r '.histRecentTotal' <<<"$result") == "446" ]] ||
  fail "omp collector excludes history older than seven days from the series" "$result"
pass "omp collector excludes history older than seven days from the series"

[[ $(jq -r '.quietBalanceRemaining' <<<"$result") == "42.0" ]] ||
  fail "omp collector surfaces balance for a quiet DeepSeek account" "$result"
pass "omp collector surfaces balance for a quiet DeepSeek account"

[[ $(jq -r '.statsFailKeepsHistory | map(tostring) | join(":")' <<<"$result") == 'true:4:omp stats unavailable:`omp stats` is unavailable — showing saved history.' ]] ||
  fail "omp collector keeps history when omp stats fails" "$result"
pass "omp collector keeps history when omp stats fails"

[[ $(jq -r '.statsFailNoDb | join(":")' <<<"$result") == "1:1" ]] ||
  fail "omp collector leaves the previous record when stats and DB both fail" "$result"
pass "omp collector leaves the previous record when stats and DB both fail"
