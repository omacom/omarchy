#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

# 1. Command metadata
bin_file="$ROOT/bin/omarchy-agent-usage-agy"
[[ -x $bin_file ]] || fail "omarchy-agent-usage-agy is executable"
grep -q '^# omarchy:summary=' "$bin_file" || fail "declares summary"
grep -q '^# omarchy:hidden=true' "$bin_file" || fail "declares hidden flag"
pass "omarchy-agent-usage-agy has valid metadata"

# 2. Manifest and assets
manifest="$ROOT/shell/plugins/agents/manifest.json"
jq -e '.barWidget.defaults.providers.agy.enabled == true' "$manifest" >/dev/null || fail "manifest enables agy by default"
[[ -f "$ROOT/shell/plugins/agents/assets/agy.svg" ]] || fail "agy.svg asset exists"
[[ -f "$ROOT/shell/plugins/agents/assets/agy-light.svg" ]] || fail "agy-light.svg asset exists"
pass "manifest registers agy and assets are present"

# 3. Isolated test environment
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT

TEST_HOME="$SCRATCH/home"
mkdir -p "$TEST_HOME/bin" "$TEST_HOME/.cache" "$TEST_HOME/.local/state/omarchy/agents/usage"
mkdir -p "$TEST_HOME/.gemini/antigravity-cli/brain/session-01/.system_generated/logs"

# Mock agy binary
cat >"$TEST_HOME/bin/agy" <<'EOF'
#!/bin/bash
if [[ ${1:-} == "-p" && ${2:-} == "/usage" ]]; then
  pct_5h=${MOCK_5H_REMAINING:-40%}
  pct_wk=${MOCK_WK_REMAINING:-85%}
  printf 'Gemini Models\tFive Hour Limit Remaining\t%s\t2026-10-05T20:00:00Z\n' "$pct_5h"
  printf 'Gemini Models\tWeekly Limit Remaining\t%s\t2026-10-10T12:00:00Z\n' "$pct_wk"
  printf 'Claude and GPT models\tFive Hour Limit Remaining\t100%%\t2026-10-05T20:00:00Z\n'
  exit 0
fi
exit 1
EOF
chmod +x "$TEST_HOME/bin/agy"

# Mock active Google account
echo '{"active": "alpha@example.com"}' >"$TEST_HOME/.gemini/google_accounts.json"

today=$(date +%Y-%m-%d)
now_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Mock transcript with:
# - Valid prompt and response
# - A step with invalid non-numeric token to verify error resilience (Finding 4)
# - Another valid step to prove the transcript was not dropped
transcript="$TEST_HOME/.gemini/antigravity-cli/brain/session-01/.system_generated/logs/transcript.jsonl"
cat >"$transcript" <<EOF
{"type": "USER_INPUT", "created_at": "$now_utc", "content": "Initial prompt"}
{"type": "PLANNER_RESPONSE", "created_at": "$now_utc", "input_tokens": 100, "output_tokens": 50, "cache_read_tokens": 20, "cache_write_tokens": 0, "content": "The user changed setting \`Model Selection\` from None to Gemini 3.8 Flash. No need to comment"}
{"type": "PLANNER_RESPONSE", "created_at": "$now_utc", "input_tokens": "invalid_tokens_not_an_int", "output_tokens": null}
{"type": "PLANNER_RESPONSE", "created_at": "$now_utc", "input_tokens": 30, "output_tokens": 10, "cache_read_tokens": 0, "cache_write_tokens": 0}
EOF

# Run collector in isolated sandbox
record=$(HOME="$TEST_HOME" \
  PATH="$TEST_HOME/bin:$PATH" \
  GEMINI_DIR="$TEST_HOME/.gemini" \
  XDG_CACHE_HOME="$TEST_HOME/.cache" \
  XDG_STATE_HOME="$TEST_HOME/.local/state" \
  "$bin_file")

echo "$record" | jq -e . >/dev/null || fail "prints valid JSON"
[[ $(jq -r '.id' <<<"$record") == "agy" ]] || fail "id matches agy"
[[ $(jq -r '.tierLabel' <<<"$record") == "Google (alpha@example.com)" ]] || fail "tierLabel has active account"
[[ $(jq -r '.totalPrompts' <<<"$record") == "1" ]] || fail "totalPrompts counted"
# 100+50+20 + 30+10 = 210 tokens (resilient past invalid token step)
[[ $(jq -r '.todayTotalTokens' <<<"$record") == "210" ]] || fail "todayTotalTokens computed past malformed step"
[[ $(jq -r '.limits[0].title' <<<"$record") == "Session" ]] || fail "limits includes Session"
[[ $(jq -r '.limits[0].percent' <<<"$record") == "0.6" ]] || fail "Session percent used is 0.6 (100-40%)"
[[ $(jq -r '.limits[1].title' <<<"$record") == "Weekly" ]] || fail "limits includes Weekly"
[[ $(jq -r '.limits[1].percent' <<<"$record") == "0.15" ]] || fail "Weekly percent used is 0.15 (100-85%)"
pass "collector parses isolated transcripts and limits correctly"

# 4. Test --limits-only path reuses base record (Finding 3)
state_file="$TEST_HOME/.local/state/omarchy/agents/usage/agy.json"
echo "$record" >"$state_file"

# Remove transcripts to prove --limits-only reuses base_record
rm -rf "$TEST_HOME/.gemini/antigravity-cli/brain"

limits_only_record=$(HOME="$TEST_HOME" \
  PATH="$TEST_HOME/bin:$PATH" \
  GEMINI_DIR="$TEST_HOME/.gemini" \
  XDG_CACHE_HOME="$TEST_HOME/.cache" \
  XDG_STATE_HOME="$TEST_HOME/.local/state" \
  "$bin_file" --limits-only)

[[ $(jq -r '.todayTotalTokens' <<<"$limits_only_record") == "210" ]] || fail "limits-only preserves base record stats"
[[ $(jq -r '.limits[0].title' <<<"$limits_only_record") == "Session" ]] || fail "limits-only returns limits"
pass "limits-only path reuses base record without rescanning transcripts"

# 5. Test account boundary cache invalidation (Finding 1)
# Switch active account to beta@example.com
echo '{"active": "beta@example.com"}' >"$TEST_HOME/.gemini/google_accounts.json"

export MOCK_5H_REMAINING="10%"
export MOCK_WK_REMAINING="50%"

switch_record=$(HOME="$TEST_HOME" \
  PATH="$TEST_HOME/bin:$PATH" \
  GEMINI_DIR="$TEST_HOME/.gemini" \
  XDG_CACHE_HOME="$TEST_HOME/.cache" \
  XDG_STATE_HOME="$TEST_HOME/.local/state" \
  MOCK_5H_REMAINING="10%" \
  MOCK_WK_REMAINING="50%" \
  "$bin_file" --force)

[[ $(jq -r '.tierLabel' <<<"$switch_record") == "Google (beta@example.com)" ]] || fail "switched account reflected in tierLabel"
# 100 - 10% = 0.9, 100 - 50% = 0.5
[[ $(jq -r '.limits[0].percent' <<<"$switch_record") == "0.9" ]] || fail "limits reprobed for new account"
[[ $(jq -r '.limits[1].percent' <<<"$switch_record") == "0.5" ]] || fail "weekly reprobed for new account"
pass "limits cache invalidates across account boundaries"
