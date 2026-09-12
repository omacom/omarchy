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

# Records for agents whose collectors are all gone are dropped, but only
# after a week so a writer that does not follow the collector naming scheme
# still gets a chance to be caught up by the collectors themselves.
mkdir -p "$TEST_HOME/.config/omarchy/plugins/ghost/scripts"
mkdir -p "$TEST_HOME/.config/omarchy/plugins/hex/bin"
mkdir -p "$TEST_HOME/.config/omarchy/plugins/wrap/scripts"

cat >"$TEST_HOME/.config/omarchy/plugins/ghost/scripts/omarchy-agent-usage-ghost" <<'EOF'
#!/bin/bash
echo '{"id":"ghost"}'
EOF

cat >"$TEST_HOME/.config/omarchy/plugins/hex/bin/omarchy-agent-usage-hex" <<'EOF'
#!/bin/bash
echo '{"id":"hex"}'
EOF

# A wrapper that runs the orchestrator is not itself a collector named
# "update", and a record under that name gets the same treatment.
cat >"$TEST_HOME/.config/omarchy/plugins/wrap/scripts/omarchy-agent-usage-update" <<'EOF'
#!/bin/bash
exec omarchy-agent-usage-update "$@"
EOF

echo '{"id":"old-orphan"}' >"$usage_dir/old-orphan.json"
touch -d "30 days ago" "$usage_dir/old-orphan.json"
echo '{"id":"fresh-orphan"}' >"$usage_dir/fresh-orphan.json"
echo '{"id":"ghost"}' >"$usage_dir/ghost.json"
touch -d "60 days ago" "$usage_dir/ghost.json"
echo '{"id":"hex"}' >"$usage_dir/hex.json"
touch -d "60 days ago" "$usage_dir/hex.json"
echo '{"id":"update"}' >"$usage_dir/update.json"
touch -d "30 days ago" "$usage_dir/update.json"

message=$(HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_HOME/.config" \
  OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" good 2>&1) ||
  fail "update prunes records for agents whose collectors are gone"
pass "update prunes records for agents whose collectors are gone"

[[ ! -e $usage_dir/old-orphan.json ]] ||
  fail "update removes a stale record that no collector can produce"
pass "update removes a stale record that no collector can produce"

[[ -e $usage_dir/fresh-orphan.json ]] ||
  fail "update keeps a record written within the last week, collector or not"
pass "update keeps a record written within the last week, collector or not"

[[ -e $usage_dir/ghost.json && -e $usage_dir/hex.json ]] ||
  fail "update keeps records of plugin collectors under scripts/ and bin/"
pass "update keeps records of plugin collectors under scripts/ and bin/"

[[ ! -e $usage_dir/update.json ]] ||
  fail "update does not take a wrapper script for itself as a collector"
pass "update does not take a wrapper script for itself as a collector"

[[ $message == *"old-orphan"* ]] ||
  fail "update reports the records it removes" "$message"
pass "update reports the records it removed"

