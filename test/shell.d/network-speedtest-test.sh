#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export PATH="$ROOT/bin:$PATH"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Test 1: Bad direction exits with code 2
set +e
"$ROOT/bin/omarchy-network-speedtest" invalid >"$tmp_dir/out" 2>"$tmp_dir/err"
code=$?
set -e
(( code == 2 )) || fail "invalid direction exits with 2 (got $code)"
grep -q "Usage: omarchy-network-speedtest" "$tmp_dir/err" || fail "invalid direction prints usage"
pass "invalid direction exits with 2 and prints usage"

# Test 2: Missing direction exits with code 2
set +e
"$ROOT/bin/omarchy-network-speedtest" >"$tmp_dir/out" 2>"$tmp_dir/err"
code=$?
set -e
(( code == 2 )) || fail "missing direction exits with 2 (got $code)"
grep -q "Usage: omarchy-network-speedtest" "$tmp_dir/err" || fail "missing direction prints usage"
pass "missing direction exits with 2 and prints usage"

# Test 3: Verify fast.com fallback when fast.com is unreachable (e.g. 403 or blocked)
mkdir -p "$tmp_dir/bin"
cat >"$tmp_dir/bin/curl" <<EOF
#!/bin/bash
for arg in "\$@"; do
  if [[ \$arg == *"api.fast.com"* ]]; then
    # Simulate HTTP 403 geo-blocked fast.com API
    exit 22
  fi
  if [[ \$arg == *"speed.cloudflare.com"* ]]; then
    touch "$tmp_dir/cloudflare_hit"
    exit 0
  fi
done
exec /usr/bin/curl "\$@"
EOF
chmod +x "$tmp_dir/bin/curl"

# Test that fallback to Cloudflare occurs for download
PATH="$tmp_dir/bin:$PATH" timeout 2 "$ROOT/bin/omarchy-network-speedtest" down >/dev/null 2>&1 || true
[[ -f "$tmp_dir/cloudflare_hit" ]] || fail "falls back to Cloudflare when fast.com returns 403 on download"
pass "falls back to Cloudflare when fast.com returns 403 on download"

# Test that fallback to Cloudflare occurs for upload
rm -f "$tmp_dir/cloudflare_hit"
PATH="$tmp_dir/bin:$PATH" timeout 2 "$ROOT/bin/omarchy-network-speedtest" up >/dev/null 2>&1 || true
[[ -f "$tmp_dir/cloudflare_hit" ]] || fail "falls back to Cloudflare when fast.com returns 403 on upload"
pass "falls back to Cloudflare when fast.com returns 403 on upload"
