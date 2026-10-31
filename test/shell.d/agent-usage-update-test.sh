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

# A manually seeded record must not make a missing collector look refreshed.
printf '%s\n' '{"id":"missing","totalPrompts":17}' >"$usage_dir/missing.json"
cp "$usage_dir/missing.json" "$TEST_HOME/previous.json"
if HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" missing 2>"$TEST_HOME/error"; then
  fail "update fails when a requested collector is missing"
fi
[[ $(cat "$TEST_HOME/error") == "omarchy-agent-usage-update: missing collector not found or not executable" ]] ||
  fail "update identifies the missing collector"
cmp -s "$usage_dir/missing.json" "$TEST_HOME/previous.json" ||
  fail "update preserves the last record when its collector is missing"
pass "update reports a missing collector without changing its last record"

# Available collectors still run when another requested collector is absent.
rm "$usage_dir/good.json"
if HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" missing good 2>/dev/null; then
  fail "update reports partial failure for mixed available and missing collectors"
fi
[[ $(jq -r '.totalPrompts' "$usage_dir/good.json") == "3" ]] ||
  fail "update runs available collectors despite a missing requested collector"
pass "update runs available collectors and reports partial failure"

# Discovery must match what actually ran, including executability and the
# updater's reserved name; --except continues to take precedence.
cp "$FAKE_OMARCHY/bin/omarchy-agent-usage-good" "$FAKE_OMARCHY/bin/omarchy-agent-usage-disabled"
chmod -x "$FAKE_OMARCHY/bin/omarchy-agent-usage-disabled"
for agent in disabled update; do
  if HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
    "$ROOT/bin/omarchy-agent-usage-update" "$agent" 2>/dev/null; then
    fail "update rejects a requested non-collector: $agent"
  fi
done
pass "update rejects non-executable collectors and its own reserved name"

HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" --except missing missing good ||
  fail "update does not require an explicitly excluded collector"
pass "update does not require an explicitly excluded collector"
