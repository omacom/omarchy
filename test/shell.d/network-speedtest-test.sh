#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Test argument validation
if "$ROOT/bin/omarchy-network-speedtest" 2>/dev/null; then
  fail "speedtest requires argument"
fi
pass "speedtest requires argument"

if "$ROOT/bin/omarchy-network-speedtest" invalid 2>/dev/null; then
  fail "speedtest rejects invalid direction"
fi
pass "speedtest rejects invalid direction"

# Mock curl to simulate Fast.com 403 failure and verify fallback
mkdir -p "$TMPDIR/bin"

cat >"$TMPDIR/bin/curl" <<'SH'
#!/bin/bash
for arg in "$@"; do
  if [[ $arg == *"api.fast.com"* ]]; then
    # Simulate 403 Forbidden
    exit 22
  fi
  if [[ $arg == *"fast.com"* ]]; then
    # Simulate JS bundle fetch failure
    exit 22
  fi
done
# For other URLs (e.g. Cloudflare endpoint), return success
exit 0
SH

chmod +x "$TMPDIR/bin/curl"

# Test that when Fast.com fails, the script falls back to Cloudflare without erroring
output=$(PATH="$TMPDIR/bin:$PATH" timeout 1 "$ROOT/bin/omarchy-network-speedtest" down 2>&1 || true)
if [[ $output == *"Failed to fetch speed test endpoints"* ]]; then
  fail "speedtest fails when fast.com is unavailable instead of falling back"
fi
pass "speedtest falls back to alternative endpoints when Fast.com fails"
