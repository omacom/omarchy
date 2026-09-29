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

# A collector dropped in the user directory: $OMARCHY_PATH/bin is
# package-owned, so this is the only place a third party can ship one.
collector_dir="$TEST_HOME/.config/omarchy/agents/collectors"
mkdir -p "$collector_dir"

cat >"$collector_dir/omarchy-agent-usage-dropped" <<'EOF'
#!/bin/bash
echo '{"schemaVersion":1,"id":"dropped","name":"Dropped Agent"}'
EOF

# Same name as a packaged collector: the packaged one must win.
cat >"$collector_dir/omarchy-agent-usage-good" <<'EOF'
#!/bin/bash
echo '{"schemaVersion":1,"id":"good","name":"Shadowed Agent"}'
EOF

chmod +x "$collector_dir/"omarchy-agent-usage-*

HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" XDG_CONFIG_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" dropped good ||
  fail "update runs collectors dropped in the user directory"

[[ $(jq -r '.name' "$usage_dir/dropped.json") == "Dropped Agent" ]] ||
  fail "update runs collectors dropped in the user directory"
pass "update runs collectors dropped in the user directory"

[[ $(jq -r '.name' "$usage_dir/good.json") == "Good Agent" ]] ||
  fail "a dropped-in collector cannot shadow a packaged one"
pass "a dropped-in collector cannot shadow a packaged one"

rm -f "$usage_dir/dropped.json"
HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" XDG_CONFIG_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" --except dropped 2>/dev/null
[[ ! -e $usage_dir/dropped.json ]] ||
  fail "dropped-in collectors honor --except"
pass "dropped-in collectors honor --except"

# A non-executable file is not a collector, however it is named.
cat >"$collector_dir/omarchy-agent-usage-inert" <<'EOF'
#!/bin/bash
echo '{"id":"inert"}'
EOF
chmod -x "$collector_dir/omarchy-agent-usage-inert"

HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" XDG_CONFIG_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" inert
[[ ! -e $usage_dir/inert.json ]] ||
  fail "update ignores non-executable files in the user directory"
pass "update ignores non-executable files in the user directory"

# No user directory at all is the common case and must stay silent.
EMPTY_HOME=$(mktemp -d)
HOME="$EMPTY_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" XDG_CONFIG_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" good 2>"$EMPTY_HOME/stderr" ||
  fail "update succeeds when no user collector directory exists"
[[ ! -s $EMPTY_HOME/stderr ]] ||
  fail "update stays quiet when no user collector directory exists" "$(cat "$EMPTY_HOME/stderr")"
rm -rf "$EMPTY_HOME"
pass "update succeeds when no user collector directory exists"
