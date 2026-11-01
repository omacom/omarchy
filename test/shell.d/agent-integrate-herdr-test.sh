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
# herdr honors each of these over HOME, which would reach the developer's own agent homes.
unset PI_CODING_AGENT_DIR PI_CONFIG_DIR COPILOT_HOME KIMI_CODE_HOME OPENCODE_CONFIG_DIR QWEN_HOME \
  CURSOR_CONFIG_DIR ANTIGRAVITY_CLI_CONFIG_DIR GROK_CONFIG_DIR QODER_CONFIG_DIR HERMES_HOME XDG_CONFIG_HOME

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

