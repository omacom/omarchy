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

rm -rf "$usage_dir"
if output=$(HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" --except '' 2>&1); then
  fail "update refuses an empty --except"
fi
[[ $output == "--except needs an agent" && ! -e $usage_dir/good.json ]] ||
  fail "update refuses an empty --except before collecting anything" "$output"
pass "update refuses an empty --except before collecting anything"

# A limits-only refresh leaves out agents whose last record the panel hides as
# unused; a full refresh and a named agent still run them.
cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-idle" <<'EOF2'
#!/bin/bash
touch "$HOME/idle-ran"
echo '{"schemaVersion":1,"id":"idle","ready":false,"limits":[],"totalPrompts":0}'
EOF2
chmod +x "$FAKE_OMARCHY/bin/omarchy-agent-usage-idle"
rm -f "$FAKE_OMARCHY/bin/omarchy-agent-usage-noisy"
mkdir -p "$usage_dir"
echo '{"id":"idle","ready":false,"limits":[],"totalPrompts":0}' >"$usage_dir/idle.json"
echo '{"id":"good","totalPrompts":3,"name":"Old"}' >"$usage_dir/good.json"

run_update() {
  rm -f "$TEST_HOME/idle-ran"
  HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
    "$ROOT/bin/omarchy-agent-usage-update" "$@" 2>/dev/null
}

run_update --limits-only
[[ ! -e $TEST_HOME/idle-ran && $(jq -r '.name' "$usage_dir/good.json") == "Good Agent" ]] ||
  fail "a limits-only update skips unused agents and runs used ones"
pass "a limits-only update skips unused agents and runs used ones"

run_update --limits-only idle
[[ -e $TEST_HOME/idle-ran ]] || fail "a limits-only update runs an unused agent it names"
pass "a limits-only update runs an unused agent it names"

run_update
[[ -e $TEST_HOME/idle-ran ]] || fail "a full update still runs unused agents"
pass "a full update still runs unused agents"

run_update --force --limits-only
[[ -e $TEST_HOME/idle-ran ]] || fail "a forced limits-only update still runs unused agents"
pass "a forced limits-only update still runs unused agents"

touch -d '2 hours ago' "$usage_dir/idle.json"
run_update --limits-only
[[ -e $TEST_HOME/idle-ran ]] || fail "a limits-only update runs an unused agent whose record is over an hour old"
pass "a limits-only update runs an unused agent whose record is over an hour old"
