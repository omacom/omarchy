#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq

TEST_HOME=$(mktemp -d)
FAKE_OMARCHY=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$FAKE_OMARCHY"' EXIT

mkdir -p "$FAKE_OMARCHY/bin"

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-good" <<'EOF'
#!/bin/bash
echo '{"schemaVersion":1,"id":"good","name":"Good Agent","totalPrompts":3}'
EOF

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-noisy" <<'EOF'
#!/bin/bash
echo "this is not json"
EOF

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-skipped" <<'EOF'
#!/bin/bash
echo '{"id":"skipped"}'
EOF

# The updater itself lives in the same namespace as the collectors it globs.
cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-update" <<'EOF'
#!/bin/bash
echo '{"id":"update"}'
EOF

chmod +x "$FAKE_OMARCHY/bin/"omarchy-agent-usage-*

usage_dir="$TEST_HOME/.local/state/omarchy/agents/usage"

HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" --except skipped 2>/dev/null && fail "update reports a failing collector"
pass "update reports a failing collector"

[[ $(jq -r '.name' "$usage_dir/good.json") == "Good Agent" ]] ||
  fail "update writes each collector's record to the usage directory"
pass "update writes each collector's record to the usage directory"

[[ ! -e $usage_dir/noisy.json ]] ||
  fail "update refuses records that are not valid JSON"
pass "update refuses records that are not valid JSON"

[[ ! -e $usage_dir/skipped.json ]] ||
  fail "update skips agents excluded with --except"
pass "update skips agents excluded with --except"

[[ ! -e $usage_dir/update.json ]] ||
  fail "update does not treat itself as a collector"
pass "update does not treat itself as a collector"

HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" skipped 2>/dev/null ||
  fail "update succeeds when the requested collectors all pass"
pass "update succeeds when the requested collectors all pass"

[[ -e $usage_dir/skipped.json && ! -e $usage_dir/noisy.json ]] ||
  fail "update with agent arguments only runs the named collectors"
pass "update with agent arguments only runs the named collectors"

# Limits carry samples of their window from record to record, stamped with
# when they were measured, for the panel's recent burn rate.
cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-limited" <<'EOF2'
#!/bin/bash
cat "$LIMITED_RECORD"
EOF2
chmod +x "$FAKE_OMARCHY/bin/omarchy-agent-usage-limited"

LIMITED_RECORD="$TEST_HOME/limited-record.json"
export LIMITED_RECORD
minute=60000
t0=1790000000000

# limited <percent> <limitsFetchedAt> [resetsAt] [active account]
limited() {
  jq -n --argjson percent "$1" --argjson at "$2" --arg reset "${3-2026-10-27T22:00:00.5+00:00}" --arg active "${4:-}" '{
    id: "limited", limitsFetchedAt: $at,
    limits: [{label: "Session (5-hour)", percent: $percent, resetsAt: $reset}],
    accounts: (if $active == "" then [] else [
      {id: "work", active: ($active == "work"), fetchedAt: $at, limits: [{label: "Weekly (7-day)", percent: $percent, resetsAt: "2026-10-30T11:00:00+00:00"}]},
      {id: "home", active: ($active == "home"), fetchedAt: 0, limits: [{label: "Weekly (7-day)", percent: 0.5, resetsAt: "2026-10-30T11:00:00+00:00"}]}
    ] end)
  }' >"$LIMITED_RECORD"
  HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
    "$ROOT/bin/omarchy-agent-usage-update" limited 2>/dev/null || fail "update writes a record with limits"
}

history() {
  jq -c "${1:-.limits[0].history}" "$usage_dir/limited.json"
}

limited 0.1 "$t0"
[[ $(history) == "[[$t0,0.1]]" ]] || fail "a limit starts its history with the sample it was measured at ($(history))"
pass "a limit starts its history with the sample it was measured at"

limited 0.1 "$t0"
[[ $(history) == "[[$t0,0.1]]" ]] || fail "a cached or stale answer adds no sample ($(history))"
pass "a cached or stale answer adds no sample"

limited 0.2 $((t0 + 10 * minute))
limited 0.21 $((t0 + 12 * minute))
limited 0.22 $((t0 + 14 * minute))
[[ $(history) == "[[$t0,0.1],[$((t0 + 10 * minute)),0.2],[$((t0 + 14 * minute)),0.22]]" ]] ||
  fail "samples stay five minutes apart except the newest ($(history))"
pass "samples stay five minutes apart except the newest"

limited 0.3 $((t0 + 27 * 60 * minute))
[[ $(history) == "[[$((t0 + 27 * 60 * minute)),0.3]]" ]] || fail "samples older than 26 hours fall away ($(history))"
pass "samples older than 26 hours fall away"

limited 0.05 $((t0 + 28 * 60 * minute)) "2026-10-28T03:00:00.7+00:00"
[[ $(history) == "[[$((t0 + 28 * 60 * minute)),0.05]]" ]] || fail "a reset that moved starts the history over ($(history))"
pass "a reset that moved starts the history over"

limited 0.1 "$t0" "" work
limited 0.2 $((t0 + 10 * minute)) "" work
[[ $(history '.accounts[0].limits[0].history | length') == 2 && $(history '.accounts[1].limits[0].history') == "[]" ]] ||
  fail "each account carries its own samples, stamped with its own fetch ($(history '.accounts'))"
pass "each account carries its own samples, stamped with its own fetch"
[[ $(history) == "[[$((t0 + 10 * minute)),0.2]]" ]] || fail "a reset that is not a timestamp carries no samples ($(history))"
pass "a reset that is not a timestamp carries no samples"

limited 0.3 $((t0 + 20 * minute)) "2026-10-27T22:00:00+00:00" work
limited 0.4 $((t0 + 30 * minute)) "2026-10-27T22:00:00+00:00" home
[[ $(history) == "[[$((t0 + 30 * minute)),0.4]]" && $(history '.accounts[0].limits[0].history | length') == 4 ]] ||
  fail "another active account starts the record's own history over ($(history))"
pass "another active account starts the record's own history over"

echo '{"id":"limited","limits":"broken"}' >"$usage_dir/limited.json"
limited 0.5 $((t0 + 40 * minute))
[[ $(history) == "[[$((t0 + 40 * minute)),0.5]]" ]] || fail "a previous record that can't be read costs only its history ($(history))"
pass "a previous record that can't be read costs only its history"
