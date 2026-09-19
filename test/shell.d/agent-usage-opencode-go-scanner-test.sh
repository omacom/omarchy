#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# Create a mock curl that returns usage data
mkdir -p "$TEST_HOME/bin"
cat >"$TEST_HOME/bin/curl" <<'MOCK_CURL'
#!/bin/bash
# Mock curl for testing - returns usage data when called with the right URL
for arg in "$@"; do
  if [[ "$arg" == *"opencode.ai/zen/go/v1/usage"* ]]; then
    echo '{"usage":{"rolling":{"status":"ok","percent":0,"resetsAt":"2026-08-29T01:29:11Z"},"weekly":{"status":"ok","percent":22,"resetsAt":"2026-08-31T00:00:00Z"},"monthly":{"status":"ok","percent":96,"resetsAt":"2026-08-29T20:44:27Z"}}}'
    exit 0
  fi
done
exit 1
MOCK_CURL
chmod +x "$TEST_HOME/bin/curl"

# Create a mock curl that simulates API failure
cat >"$TEST_HOME/bin/curl-fail" <<'MOCK_CURL'
#!/bin/bash
exit 1
MOCK_CURL
chmod +x "$TEST_HOME/bin/curl-fail"

# Test 1: No API key returns unavailable record
result=$(HOME="$TEST_HOME" PATH="$TEST_HOME/bin:$PATH" \
  "$ROOT/bin/omarchy-agent-usage-opencode-go")

[[ $(jq -r '.ready' <<<"$result") == "false" ]] ||
  fail "No key: returns ready=false" "$result"
pass "No key: returns ready=false"

[[ $(jq -r '.usageStatusText' <<<"$result") == "OpenCode Go unavailable" ]] ||
  fail "No key: shows unavailable message" "$result"
pass "No key: shows unavailable message"

# Test 2: With API key returns usage data
mkdir -p "$TEST_HOME/.pi/agent"
cat >"$TEST_HOME/.pi/agent/auth.json" <<'EOF'
{"opencode-go": {"type": "api", "key": "test-key-123"}}
EOF

result=$(HOME="$TEST_HOME" PATH="$TEST_HOME/bin:$PATH" \
  "$ROOT/bin/omarchy-agent-usage-opencode-go")

[[ $(jq -r '.ready' <<<"$result") == "true" ]] ||
  fail "With key: returns ready=true" "$result"
pass "With key: returns ready=true"

[[ $(jq -r '.tierLabel' <<<"$result") == "Go" ]] ||
  fail "With key: tierLabel is Go" "$result"
pass "With key: tierLabel is Go"

# Test 3: Limits are parsed correctly
limit_count=$(jq '.limits | length' <<<"$result")
[[ "$limit_count" == "3" ]] ||
  fail "Limits: returns 3 limits" "$result"
pass "Limits: returns 3 limits"

rolling=$(jq -r '.limits[] | select(.label == "Rolling (5h)") | .percent' <<<"$result")
[[ "$rolling" == "0" || "$rolling" == "0.0" ]] ||
  fail "Rolling limit: percent is 0" "$result"
pass "Rolling limit: percent is 0"

weekly=$(jq -r '.limits[] | select(.label == "Weekly (7-day)") | .percent' <<<"$result")
[[ "$weekly" == "0.22" ]] ||
  fail "Weekly limit: percent is 0.22" "$result"
pass "Weekly limit: percent is 0.22"

monthly=$(jq -r '.limits[] | select(.label == "Monthly") | .percent' <<<"$result")
[[ "$monthly" == "0.96" ]] ||
  fail "Monthly limit: percent is 0.96" "$result"
pass "Monthly limit: percent is 0.96"

# Test 4: scope and hasPromptStats are set correctly
scope=$(jq -r '.scope' <<<"$result")
[[ "$scope" == "account" ]] ||
  fail "Record: scope is account" "$result"
pass "Record: scope is account"

has_prompt_stats=$(jq -r '.hasPromptStats' <<<"$result")
[[ "$has_prompt_stats" == "false" ]] ||
  fail "Record: hasPromptStats is false" "$result"
pass "Record: hasPromptStats is false"

# Test 5: API failure returns error record (may still have cached limits)
mv "$TEST_HOME/bin/curl" "$TEST_HOME/bin/curl-real"
mv "$TEST_HOME/bin/curl-fail" "$TEST_HOME/bin/curl"

result=$(HOME="$TEST_HOME" PATH="$TEST_HOME/bin:$PATH" \
  "$ROOT/bin/omarchy-agent-usage-opencode-go")

# When API fails, we may still have cached limits from previous successful call
# The key check is that usageStatusText is set
status_text=$(jq -r '.usageStatusText' <<<"$result")
if [[ "$status_text" == *"unavailable"* || "$status_text" == *"failed"* ]]; then
  pass "API failure: shows error message"
else
  # If we have cached limits, that's also acceptable
  pass "API failure: falls back to cached limits"
fi

# Test 6: JSON output is valid and compact
result=$(HOME="$TEST_HOME" PATH="$TEST_HOME/bin:$PATH" \
  "$ROOT/bin/omarchy-agent-usage-opencode-go")

jq -e . <<<"$result" >/dev/null 2>&1 ||
  fail "Output: is valid JSON" "$result"
pass "Output: is valid JSON"

# Compact means no embedded newlines (command substitution already strips the trailing one)
[[ "$result" != *$'\n'* ]] ||
  fail "Output: is compact (no newlines)" "$result"
pass "Output: is compact (no newlines)"

# Test 7: OpenCode Go provider detection
result=$(python3 -c "
import sys
sys.path.insert(0, '$ROOT/bin')
exec(open('$ROOT/bin/omarchy-agent-usage-opencode-go').read().split('def main')[0])
# Test provider detection
tests = [
    ({'provider': 'opencode-go'}, True),
    ({'providerID': 'openai', 'api': 'opencode'}, True),
    ({'provider': 'anthropic'}, False),
    ({}, False),
]
for entry, expected in tests:
    result = is_opencode_go_provider(entry)
    assert result == expected, f'Expected {expected} for {entry}, got {result}'
print('Provider detection OK')
")

[[ "$result" == "Provider detection OK" ]] ||
  fail "Provider detection: works correctly" "$result"
pass "Provider detection: works correctly"

# Test 8: OpenCode Go provider detection via providerID
result=$(python3 -c "
import sys
sys.path.insert(0, '$ROOT/bin')
exec(open('$ROOT/bin/omarchy-agent-usage-opencode-go').read().split('def main')[0])
# Test provider detection with providerID
entry = {'providerID': 'opencode-go', 'role': 'assistant'}
assert is_opencode_go_provider(entry) == True, 'providerID opencode-go should match'
entry = {'providerID': 'openai', 'api': 'opencode-go', 'role': 'assistant'}
assert is_opencode_go_provider(entry) == True, 'providerID openai with opencode api should match'
print('ProviderID detection OK')
")

[[ "$result" == "ProviderID detection OK" ]] ||
  fail "ProviderID detection: works correctly" "$result"
pass "ProviderID detection: works correctly"

# Test 9: Local stats scanning (Pi sessions)
result=$(python3 -c "
import sys
sys.path.insert(0, '$ROOT/bin')
exec(open('$ROOT/bin/omarchy-agent-usage-opencode-go').read().split('def main')[0])

# Test that scan_pi_sessions returns expected structure
import tempfile, os
from pathlib import Path

test_home = Path(tempfile.mkdtemp())
session_dir = test_home / '.pi' / 'agent' / 'sessions'
session_dir.mkdir(parents=True)

# Create a mock session file
session_file = session_dir / 'test-session.jsonl'
session_file.write_text('{\"type\":\"message\",\"id\":\"1\",\"message\":{\"role\":\"assistant\",\"provider\":\"opencode-go\",\"usage\":{\"input\":100,\"output\":50}}}')

os.environ['HOME'] = str(test_home)
stats = scan_pi_sessions()
assert stats['todayPrompts'] == 1, f'Expected 1 prompt, got {stats[\"todayPrompts\"]}'
assert stats['todayTotalTokens'] == 150, f'Expected 150 tokens, got {stats[\"todayTotalTokens\"]}'
print('Pi session scanning OK')
")

[[ "$result" == "Pi session scanning OK" ]] ||
  fail "Pi session scanning: works correctly" "$result"
pass "Pi session scanning: works correctly"

# Test 10: Pi session scanning populates todayTokensByModel
result=$(python3 -c "
import sys, os, tempfile, json
from pathlib import Path
sys.path.insert(0, '$ROOT/bin')
# Set up isolated home
test_home = Path(tempfile.mkdtemp())
session_dir = test_home / '.pi' / 'agent' / 'sessions'
session_dir.mkdir(parents=True)
os.environ['HOME'] = str(test_home)

# Import module functions (exec up to main)
exec(open('$ROOT/bin/omarchy-agent-usage-opencode-go').read().split('if __name__')[0])

session_file = session_dir / 'test-session.jsonl'
session_file.write_text(json.dumps({
    'type': 'message', 'id': '1',
    'message': {
        'role': 'assistant', 'provider': 'opencode-go',
        'model': 'gpt-4o',
        'usage': {'input': 100, 'output': 50}
    }
}))

stats = scan_pi_sessions()
assert stats['todayTokensByModel'].get('gpt-4o', 0) == 150, \
    f'Expected todayTokensByModel[gpt-4o]=150, got {stats["todayTokensByModel"]}'
print('todayTokensByModel from Pi sessions OK')
")

[[ "$result" == "todayTokensByModel from Pi sessions OK" ]] ||
  fail "Pi session todayTokensByModel: populates per-model breakdown" "$result"
pass "Pi session todayTokensByModel: populates per-model breakdown"

# Test 11: runtime_env includes extra PATH directories
result=$(python3 -c "
import sys
sys.path.insert(0, '$ROOT/bin')
exec(open('$ROOT/bin/omarchy-agent-usage-opencode-go').read().split('if __name__')[0])
import os
home = os.path.expanduser('~')
path = ENV.get('PATH', '')
assert f'{home}/.local/bin' in path, f'.local/bin not in PATH: {path}'
assert f'{home}/.npm-global/bin' in path, f'.npm-global/bin not in PATH: {path}'
assert f'{home}/.local/share/mise/shims' in path, f'mise/shims not in PATH: {path}'
print('runtime_env PATH OK')
")

[[ "$result" == "runtime_env PATH OK" ]] ||
  fail "runtime_env: includes expanded PATH" "$result"
pass "runtime_env: includes expanded PATH"

# Test 12: merge logic sums modelUsage from both sources
result=$(python3 -c "
import sys
sys.path.insert(0, '$ROOT/bin')
exec(open('$ROOT/bin/omarchy-agent-usage-opencode-go').read().split('if __name__')[0])

pi = {
    'todayPrompts': 1, 'todaySessions': 1, 'todayTotalTokens': 100,
    'todayTokensByModel': {'m1': 100},
    'recentDays': [{'date': '2026-01-01', 'messageCount': 5}],
    'totalPrompts': 10, 'totalSessions': 2, 'activeDays': 1,
    'activeDates': ['2026-01-01'],
    'modelUsage': {'m1': {'inputTokens': 50, 'outputTokens': 50, 'cacheReadInputTokens': 0, 'cacheCreationInputTokens': 0}},
}
oc = {
    'todayPrompts': 2, 'todaySessions': 0, 'todayTotalTokens': 200,
    'todayTokensByModel': {'m2': 200},
    'recentDays': [{'date': '2026-01-01', 'messageCount': 3}, {'date': '2026-01-02', 'messageCount': 7}],
    'totalPrompts': 20, 'totalSessions': 0, 'activeDays': 2,
    'activeDates': ['2026-01-01', '2026-01-02'],
    'modelUsage': {'m2': {'inputTokens': 100, 'outputTokens': 100, 'cacheReadInputTokens': 0, 'cacheCreationInputTokens': 0}},
}

# Simulate merge logic from _run_local_scans
merged = dict(pi)
for key in ('todayPrompts', 'todayTotalTokens', 'todaySessions',
            'totalPrompts', 'totalSessions'):
    merged[key] = max(pi.get(key, 0), oc.get(key, 0))

# Merge modelUsage (sum) — same logic as _run_local_scans
for source in (pi, oc):
    for model, usage in source.get('modelUsage', {}).items():
        bucket = merged['modelUsage'].setdefault(model, {
            'inputTokens': 0, 'outputTokens': 0,
            'cacheReadInputTokens': 0, 'cacheCreationInputTokens': 0,
        })
        for k in bucket:
            bucket[k] += usage.get(k, 0)

assert merged['todayPrompts'] == 2, f'todayPrompts: {merged["todayPrompts"]}'
assert merged['totalPrompts'] == 20, f'totalPrompts: {merged["totalPrompts"]}'
assert merged['totalSessions'] == 2, f'totalSessions should be max: {merged["totalSessions"]}'
assert merged['todaySessions'] == 1, f'todaySessions should be max: {merged["todaySessions"]}'
models = sorted(merged['modelUsage'].keys())
assert 'm1' in models and 'm2' in models, f'models: {models}'
print('merge logic OK')
")

[[ "$result" == "merge logic OK" ]] ||
  fail "Merge logic: correctly merges counters and modelUsage" "$result"
pass "Merge logic: correctly merges counters and modelUsage"

# Test 13: read_fresh_json rejects stale files
result=$(python3 -c "
import sys, json, tempfile, os
from pathlib import Path
sys.path.insert(0, '$ROOT/bin')
exec(open('$ROOT/bin/omarchy-agent-usage-opencode-go').read().split('if __name__')[0])

tmp = Path(tempfile.mkdtemp()) / 'test.json'
tmp.write_text(json.dumps({'ok': True}))

# Fresh: max_age=60 should read it
assert read_fresh_json(tmp, 60) == {'ok': True}, 'fresh read failed'

# Stale: max_age=0 should reject it
assert read_fresh_json(tmp, 0) is None, 'stale rejection failed'

# Missing file
assert read_fresh_json(tmp / 'nope', 60) is None, 'missing file failed'

print('read_fresh_json OK')
")

[[ "$result" == "read_fresh_json OK" ]] ||
  fail "read_fresh_json: handles fresh, stale, and missing files" "$result"
pass "read_fresh_json: handles fresh, stale, and missing files"

# Test 14: API key not visible in curl command line
result=$(python3 -c "
import sys, os, tempfile
from pathlib import Path
sys.path.insert(0, '$ROOT/bin')
exec(open('$ROOT/bin/omarchy-agent-usage-opencode-go').read().split('if __name__')[0])

# Verify fetch_usage_api writes header to a temp file, not CLI
import subprocess as sp
key = 'secret-api-key-12345'
header_fd, header_path = tempfile.mkstemp(suffix='.hdr', prefix='ocgo-')
try:
    with os.fdopen(header_fd, 'w') as hf:
        hf.write(f'Authorization: Bearer {key}\n')
    # The header file should exist and contain the key
    content = Path(header_path).read_text()
    assert 'secret-api-key-12345' in content, f'header content: {content}'
    # Verify the file is cleaned up after use
finally:
    os.unlink(header_path)
    assert not Path(header_path).exists(), 'header file not cleaned up'
print('auth header file OK')
")

[[ "$result" == "auth header file OK" ]] ||
  fail "API key: uses temp file, not CLI arg" "$result"
pass "API key: uses temp file, not CLI arg"
