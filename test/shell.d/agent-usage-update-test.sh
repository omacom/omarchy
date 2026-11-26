#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq

TEST_HOME=$(mktemp -d)
FAKE_OMARCHY=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$FAKE_OMARCHY"' EXIT

mkdir -p "$FAKE_OMARCHY/bin"

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-good" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$HOME/good.calls"
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

# A second panel refresh must not start another set of full local scans while
# the first refresh still holds the updater lock.
exec {update_lock_fd}>"$usage_dir/.update.lock"
flock -n "$update_lock_fd" || fail "test could not hold the updater lock"
rm -f "$TEST_HOME/good.calls"
HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" 2>/dev/null ||
  fail "a concurrent refresh is skipped successfully"
[[ ! -e $usage_dir/skipped.json ]] || fail "a concurrent refresh does not start collectors"
pass "a concurrent refresh does not start collectors"

# An account operation carries an explicit scope and --force. Preserve it by
# waiting for the active scan, then collecting with the requested arguments.
HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" --force good 2>/dev/null &
queued_update_pid=$!
sleep 0.1
kill -0 "$queued_update_pid" 2>/dev/null || fail "an explicit refresh waits for the active scan"
[[ ! -e $TEST_HOME/good.calls ]] || fail "a queued refresh does not overlap the active scan"
pass "an explicit refresh waits for the active scan"
flock -u "$update_lock_fd"
exec {update_lock_fd}>&-
wait "$queued_update_pid" || fail "the queued explicit refresh succeeds"
[[ $(<"$TEST_HOME/good.calls") == "--force" ]] || fail "the queued refresh preserves its force flag and agent scope"
pass "the queued refresh preserves its force flag and agent scope"

HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" skipped 2>/dev/null ||
  fail "update succeeds when the requested collectors all pass"
pass "update succeeds when the requested collectors all pass"

[[ -e $usage_dir/skipped.json && ! -e $usage_dir/noisy.json ]] ||
  fail "update with agent arguments only runs the named collectors"
pass "update with agent arguments only runs the named collectors"

rm -rf "$usage_dir"
if output=$(HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" --except '' 2>&1); then
  fail "update refuses an empty --except"
fi
[[ $output == "--except needs an agent" && ! -e $usage_dir/good.json ]] ||
  fail "update refuses an empty --except before collecting anything" "$output"
pass "update refuses an empty --except before collecting anything"
