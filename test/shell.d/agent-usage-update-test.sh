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

# A refresh runs while something else may hold the CPU, so the collectors take
# turns instead of all starting at once.
PARALLEL_OMARCHY=$(mktemp -d)
RUNNING_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$FAKE_OMARCHY" "$PARALLEL_OMARCHY" "$RUNNING_DIR"' EXIT
mkdir -p "$PARALLEL_OMARCHY/bin" "$RUNNING_DIR/now"

for i in 1 2 3 4 5 6 7 8; do
  cat >"$PARALLEL_OMARCHY/bin/omarchy-agent-usage-slow$i" <<COLLECTOR
#!/bin/bash
touch "$RUNNING_DIR/now/\$\$"
ls "$RUNNING_DIR/now" | wc -l >>"$RUNNING_DIR/counts"
sleep 0.2
rm "$RUNNING_DIR/now/\$\$"
echo '{"id":"slow$i"}'
COLLECTOR
done
chmod +x "$PARALLEL_OMARCHY/bin/"omarchy-agent-usage-*

rm -rf "$usage_dir"
HOME="$TEST_HOME" OMARCHY_PATH="$PARALLEL_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" 2>/dev/null ||
  fail "update succeeds with more collectors than run at once"
most=$(sort -n "$RUNNING_DIR/counts" | tail -1)
written=$(find "$usage_dir" -name 'slow*.json' | wc -l)
(( most <= 4 && written == 8 )) ||
  fail "update runs at most four collectors at a time and still runs them all" "most at once: $most, records: $written"
pass "update runs at most four collectors at a time and still runs them all"
