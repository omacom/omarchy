#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

# 1. Check command metadata comments
bin_file="$ROOT/bin/omarchy-agent-usage-agy"
[[ -x $bin_file ]] || fail "omarchy-agent-usage-agy is executable"
grep -q '^# omarchy:summary=' "$bin_file" || fail "declares summary"
grep -q '^# omarchy:hidden=true' "$bin_file" || fail "declares hidden flag"
pass "omarchy-agent-usage-agy has valid metadata"

# 2. Check JSON output contract
record=$("$bin_file" --limits-only)
echo "$record" | jq -e . >/dev/null || fail "prints valid JSON"
[[ $(echo "$record" | jq -r '.id') == "agy" ]] || fail "id matches agy"
[[ $(echo "$record" | jq -r '.name') == "Antigravity" ]] || fail "name matches Antigravity"
[[ $(echo "$record" | jq -r '.schemaVersion') == "1" ]] || fail "schemaVersion is 1"
pass "omarchy-agent-usage-agy satisfies record contract"

# 3. Check manifest includes agy provider
manifest="$ROOT/shell/plugins/agents/manifest.json"
jq -e '.barWidget.defaults.providers.agy.enabled == true' "$manifest" >/dev/null || fail "manifest enables agy by default"
pass "agents manifest registers agy provider"

# 4. Check assets exist
[[ -f "$ROOT/shell/plugins/agents/assets/agy.svg" ]] || fail "agy.svg asset exists"
[[ -f "$ROOT/shell/plugins/agents/assets/agy-light.svg" ]] || fail "agy-light.svg asset exists"
pass "agy SVG marks are present"
