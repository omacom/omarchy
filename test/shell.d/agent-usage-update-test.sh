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


# Both a scoped account refresh and a full refresh must wait, then collect
# their own scope rather than losing it behind the active scan.
for kind in scoped full; do
  exec {update_lock_fd}>"$usage_dir/.update.lock"
  flock "$update_lock_fd"
  rm -f "$usage_dir/good.json" "$usage_dir/skipped.json"
  args=()
  [[ $kind == "scoped" ]] && args=(--force good)
  HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
    "$ROOT/bin/omarchy-agent-usage-update" "${args[@]}" 2>/dev/null &
  queued_pid=$!
  sleep 0.1
  kill -0 "$queued_pid" 2>/dev/null || fail "$kind refresh waits for the active scan"
  [[ ! -e $usage_dir/good.json && ! -e $usage_dir/skipped.json ]] || fail "$kind refresh does not overlap the active scan"
  flock -u "$update_lock_fd"
  exec {update_lock_fd}>&-
  status=0
  wait "$queued_pid" || status=$?
  [[ -e $usage_dir/good.json ]] || fail "$kind refresh runs after the active scan"
  if [[ $kind == "scoped" ]]; then
    (( status == 0 )) && [[ ! -e $usage_dir/skipped.json ]] || fail "queued account refresh preserves its scope"
  else
    (( status == 1 )) && [[ -e $usage_dir/skipped.json ]] || fail "queued full refresh still collects every agent"
  fi
  pass "$kind refresh waits and then collects its own scope"
done

rm -rf "$usage_dir"
if output=$(HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" --except '' 2>&1); then
  fail "update refuses an empty --except"
fi
[[ $output == "--except needs an agent" && ! -e $usage_dir/good.json ]] ||
  fail "update refuses an empty --except before collecting anything" "$output"
pass "update refuses an empty --except before collecting anything"
