#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_home=$(mktemp -d)
test_bin=$(mktemp -d)
fake_omarchy=$(mktemp -d)
log_file=$(mktemp)

cleanup() {
  rm -rf "$test_home" "$test_bin" "$fake_omarchy"
  rm -f "$log_file"
}
trap cleanup EXIT

mkdir -p "$test_home/.config/omarchy/defaults"
mkdir -p "$test_home/.local/state/omarchy/agents/usage"
mkdir -p "$fake_omarchy/bin"

# Mock omarchy-launch-tui and mock agents
cat >"$test_bin/omarchy-launch-tui" <<'EOF'
#!/bin/bash
echo "LAUNCHED:$*" >>"$TEST_LOG"
EOF

for mock_agent in claude codex cursor-agent opencode agy copilot grok pi omp hermes crush muse openclaw; do
  cat >"$test_bin/$mock_agent" <<EOF
#!/bin/bash
echo "AGENT_RAN:$mock_agent \$*" >>"\$TEST_LOG"
EOF
done
chmod +x "$test_bin/"*

# Mock coredumpctl for crash test
cat >"$test_bin/coredumpctl" <<'EOF'
#!/bin/bash
if [[ $1 == "list" ]]; then
  echo "Wed 2026-09-16 08:00:00 EDT 12345 1000 1000 11 /usr/bin/someapp"
fi
EOF
chmod +x "$test_bin/coredumpctl"

run_agent() {
  HOME="$test_home" \
  PATH="$test_bin:$ROOT/bin:$PATH" \
  OMARCHY_PATH="$ROOT" \
  XDG_STATE_HOME="$test_home/.local/state" \
  TEST_LOG="$log_file" \
  "$ROOT/bin/omarchy-agent" "$@"
}

run_crash() {
  HOME="$test_home" \
  PATH="$test_bin:$ROOT/bin:$PATH" \
  OMARCHY_PATH="$ROOT" \
  XDG_STATE_HOME="$test_home/.local/state" \
  TEST_LOG="$log_file" \
  "$ROOT/bin/omarchy-agent-crash" "$@"
}

usage_dir="$test_home/.local/state/omarchy/agents/usage"

# Case 1: Default agent has valid available quota -> kept as default
printf 'codex\n' >"$test_home/.config/omarchy/defaults/agent"
cat >"$usage_dir/codex.json" <<'EOF'
{"ready":true,"usageStatusText":"","limits":[{"label":"5h window","percent":0.20}]}
EOF
: >"$log_file"

run_agent --fallback --inline
grep -q 'AGENT_RAN:codex' "$log_file" || fail "agent with available quota is retained when --fallback is passed"
pass "agent with available quota is retained when --fallback is passed"

# Case 2: Default agent (codex) is exhausted (100% limit used) -> falls back to available agent (cursor-agent)
cat >"$usage_dir/codex.json" <<'EOF'
{"ready":true,"usageStatusText":"","limits":[{"label":"5h window","percent":1.0}]}
EOF
cat >"$usage_dir/cursor.json" <<'EOF'
{"ready":true,"usageStatusText":"","limits":[{"label":"Included total","percent":0.05}]}
EOF
: >"$log_file"

run_agent --fallback --inline
grep -q 'AGENT_RAN:cursor-agent' "$log_file" || fail "agent falls back to cursor-agent when default agent limit is exhausted"
pass "agent falls back to cursor-agent when default agent limit is exhausted"

# Case 3: Default agent has expired sign-in -> falls back to agent with valid session
cat >"$usage_dir/codex.json" <<'EOF'
{"ready":true,"usageStatusText":"Sign-in expired","limits":[]}
EOF
: >"$log_file"

run_agent --fallback --inline
grep -q 'AGENT_RAN:cursor-agent' "$log_file" || fail "agent falls back when default agent sign-in is expired"
pass "agent falls back when default agent sign-in is expired"

# Case 4: Preferred agent with highest remaining quota headroom wins
cat >"$usage_dir/claude.json" <<'EOF'
{"ready":true,"usageStatusText":"","limits":[{"label":"Weekly","percent":0.80}]}
EOF
cat >"$usage_dir/cursor.json" <<'EOF'
{"ready":true,"usageStatusText":"","limits":[{"label":"Included total","percent":0.10}]}
EOF
: >"$log_file"

run_agent --fallback --inline
grep -q 'AGENT_RAN:cursor-agent' "$log_file" || fail "agent with lowest percent used is chosen as fallback"
pass "agent with lowest percent used is chosen as fallback"

# Case 5: omarchy-agent-crash passes --fallback and invokes available fallback agent
: >"$log_file"
run_crash 12345 "someapp" "/usr/bin/someapp" "SIGSEGV"
grep -q 'LAUNCHED:--app-id=org.omarchy.agent cursor-agent' "$log_file" ||
  fail "omarchy-agent-crash uses --fallback and launches available agent"
pass "omarchy-agent-crash uses --fallback and launches available agent"

# Case 6: prompt flag is forwarded correctly to fallback agent
: >"$log_file"
run_agent --fallback --inline --prompt "Diagnose crash"
grep -q 'AGENT_RAN:cursor-agent --yolo --trust agent -- Diagnose crash' "$log_file" ||
  fail "prompt is forwarded to fallback agent"
pass "prompt is forwarded to fallback agent"

# Case 7: omarchy-agent-prompt passes --fallback through to omarchy-agent
: >"$log_file"
HOME="$test_home" \
PATH="$test_bin:$ROOT/bin:$PATH" \
OMARCHY_PATH="$ROOT" \
XDG_STATE_HOME="$test_home/.local/state" \
TEST_LOG="$log_file" \
"$ROOT/bin/omarchy-agent-prompt" --inline --fallback "Diagnose prompt"
grep -q 'AGENT_RAN:cursor-agent --yolo --trust agent -- Diagnose prompt' "$log_file" ||
  fail "omarchy-agent-prompt forwards --fallback to fallback agent"
pass "omarchy-agent-prompt forwards --fallback to fallback agent"
