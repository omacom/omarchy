#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
launch_log="$test_tmp/launch"
mkdir -p "$mock_bin"

# The real getter prints nothing when no agent has been picked, so the stub
# does the same for an empty OMARCHY_TEST_AGENT.
cat >"$mock_bin/omarchy-default-agent" <<'SH'
#!/bin/bash
[[ -n ${OMARCHY_TEST_AGENT:-} ]] && echo "$OMARCHY_TEST_AGENT"
exit 0
SH
cat >"$mock_bin/omarchy-launch-webapp" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >"$OMARCHY_TEST_LAUNCH_LOG"
SH
chmod +x "$mock_bin"/*

launched_url() {
  local agent="$1"

  rm -f "$launch_log"
  OMARCHY_TEST_AGENT="$agent" OMARCHY_TEST_LAUNCH_LOG="$launch_log" PATH="$mock_bin:$PATH" \
    bash "$ROOT/bin/omarchy-launch-ai"
  cat "$launch_log"
}

[[ $(launched_url claude) == "https://claude.ai" ]] || fail "AI launcher opens Claude for the claude agent"
pass "AI launcher opens Claude for the claude agent"

[[ $(launched_url codex) == "https://chatgpt.com" ]] || fail "AI launcher opens ChatGPT for the codex agent"
pass "AI launcher opens ChatGPT for the codex agent"

[[ $(launched_url agy) == "https://gemini.google.com" ]] || fail "AI launcher opens Gemini for the Antigravity agent"
pass "AI launcher opens Gemini for the Antigravity agent"

[[ $(launched_url "") == "https://chatgpt.com" ]] || fail "AI launcher keeps ChatGPT when no default agent is set"
pass "AI launcher keeps ChatGPT when no default agent is set"

[[ $(launched_url pi) == "https://chatgpt.com" ]] || fail "AI launcher keeps ChatGPT for an agent without a web chat"
pass "AI launcher keeps ChatGPT for an agent without a web chat"
