#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_CACHE_HOME="$test_tmp/cache"
mkdir -p "$HOME"

collect() {
  "$ROOT/bin/omarchy-agent-usage-agy" "$@"
}

check() {
  if jq -e "$2" <<<"$record" >/dev/null; then
    pass "$1"
  else
    fail "$1" "$record"
  fi
}

record=$(collect)
check "no Antigravity data is not ready and says how to start" '.ready == false and .authHelpText == "Run `agy` to authenticate." and .totalPrompts == 0'

# Timestamps are written in UTC, as Antigravity does, from local wall-clock
# times, so a late-evening prompt lands on the next UTC day.
utc_at() {
  python3 -c 'import datetime as dt, sys; d = dt.datetime.now().astimezone().date() - dt.timedelta(days=int(sys.argv[1])); h, m = map(int, sys.argv[2].split(":")); print(dt.datetime.combine(d, dt.time(h, m)).astimezone().astimezone(dt.timezone.utc).isoformat().replace("+00:00", "Z"))' "$@"
}
today=$(date +%F)
yesterday=$(date -d yesterday +%F)

brain="$HOME/.gemini/antigravity-cli/brain"
mkdir -p "$brain/resumed/.system_generated/logs" "$brain/fresh/.system_generated/logs" "$brain/empty"

cat >"$brain/resumed/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":0,"source":"USER_EXPLICIT","type":"USER_INPUT","created_at":"$(utc_at 1 10:00)"}
{"step_index":1,"source":"MODEL","type":"PLANNER_RESPONSE","created_at":"$(utc_at 1 10:01)"}
{"step_index":2,"source":"USER_EXPLICIT","type":"USER_INPUT","created_at":"$(utc_at 1 23:30)"}
{"step_index":3,"source":"USER_EXPLICIT","type": "USER_INPUT","created_at":"$(utc_at 0 08:00)"}
EOF

cat >"$brain/fresh/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":0,"source":"USER_EXPLICIT","type":"USER_INPUT","created_at":"$(utc_at 0 09:00)"}
{"step_index":1,"source":"MODEL","type":"PLANNER_RESPONSE","text":"mentions USER_INPUT"}
not json USER_INPUT
EOF

record=$(collect)
check "a found brain is ready with no auth help" '.ready == true and .authHelpText == ""'
check "every prompt counts once, whatever the JSON spacing" '.totalPrompts == 4'
check "every conversation directory is a session" '.totalSessions == 3'
check "resuming a conversation leaves earlier prompts on their own day" '.todayPrompts == 2'
check "today counts each conversation prompted today once" '.todaySessions == 2'
check "yesterday keeps its prompts, including late evening" "(.recentDays[] | select(.date == \"$yesterday\") | .messageCount) == 2"
check "today shows in the last week" "(.recentDays[] | select(.date == \"$today\") | .messageCount) == 2"
check "both days are active" ".activeDates == [\"$yesterday\", \"$today\"] and .activeDays == 2"

# Antigravity has no limits to refresh, so the panel's limits-only refresh
# reuses the last scan; a full refresh or --force rereads the transcripts.
cat >>"$brain/fresh/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":2,"source":"USER_EXPLICIT","type":"USER_INPUT","created_at":"$(utc_at 0 09:30)"}
EOF

record=$(collect --limits-only)
check "a limits-only refresh reuses the recent scan" '.todayPrompts == 2 and .totalPrompts == 4'
record=$(collect --limits-only --force)
check "--force rescans even for limits-only" '.todayPrompts == 3 and .totalPrompts == 5'
record=$(collect)
check "a full refresh always rescans" '.todayPrompts == 3'

# A scan saved before midnight is not reused, or yesterday would read as today.
stats_cache="$XDG_CACHE_HOME/omarchy/agent-usage/agy-stats.json"
jq '.day = "2000-01-01"' "$stats_cache" >"$test_tmp/stale.json"
mv "$test_tmp/stale.json" "$stats_cache"
cat >>"$brain/fresh/.system_generated/logs/transcript.jsonl" <<EOF
{"step_index":3,"source":"USER_EXPLICIT","type":"USER_INPUT","created_at":"$(utc_at 0 10:00)"}
EOF
record=$(collect --limits-only)
check "a scan from another day is not reused" '.todayPrompts == 4'
