#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

if ! command -v herdr >/dev/null; then
  skip "herdr not installed; skipping agent herdr integration"
  exit 0
fi

test_home=$(mktemp -d)
trap 'rm -rf -- "$test_home"' EXIT
export HOME=$test_home
# Each override points an agent's home outside HOME, at the developer's own.
unset PI_CODING_AGENT_DIR PI_CONFIG_DIR COPILOT_HOME KIMI_CODE_HOME OPENCODE_CONFIG_DIR QWEN_HOME \
  CURSOR_CONFIG_DIR ANTIGRAVITY_CLI_CONFIG_DIR GROK_CONFIG_DIR QODER_CONFIG_DIR HERMES_HOME

integration_state() {
  herdr integration status | awk -v target="$1" -F ': ' '$1 == target { split($2, state, " "); print state[1] }'
}

# A first install from mise names tools by their mise names, before the agent
# has ever run and made the config directory herdr installs into.
MISE_INSTALLED_TOOLS='[{"name":"grok"},{"name":"npm:@moonshot-ai/kimi-code"},{"name":"oh-my-pi"},{"name":"hunk"}]' \
  "$ROOT/bin/omarchy-agent-integrate-herdr" >"$test_home/out.log" 2>&1 || fail "integrating new agents succeeds" "$(cat "$test_home/out.log")"

for target in grok kimi omp; do
  [[ $(integration_state "$target") == "current" ]] || fail "a first mise install integrates $target with herdr" "$(herdr integration status)"
done
[[ ! -s $test_home/out.log ]] || fail "integrating stays quiet in the agent's first screen" "$(cat "$test_home/out.log")"
pass "a first mise install integrates the agent with herdr"

# Updating existing installs only touches agents that have already run.
mkdir -p "$test_home/.qwen"
"$ROOT/bin/omarchy-agent-integrate-herdr" --existing
[[ $(integration_state qwen) == "current" ]] || fail "--existing integrates an agent that has run"
[[ ! -e $test_home/.copilot ]] || fail "--existing leaves agents that never ran alone"
pass "--existing integrates only agents that have run"

# A migration runs --existing, and must stay pending when an install fails.
printf 'not json' >"$test_home/.qwen/settings.json"
if "$ROOT/bin/omarchy-agent-integrate-herdr" --existing 2>/dev/null; then
  fail "--existing reports a failed install"
fi
pass "--existing reports a failed install"
