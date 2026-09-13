#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/bin/omarchy-brightness-display-ddc"

if grep -Fq '${XDG_RUNTIME_DIR:-/tmp}/omarchy-brightness-display-ddc' "$script"; then
  fail "DDC brightness no longer caches under world-writable /tmp"
fi

grep -Fq 'private_cache_root' "$script" || fail "DDC brightness resolves a private cache root"
grep -Fq 'XDG_STATE_HOME' "$script" || fail "DDC brightness falls back to XDG_STATE_HOME when runtime dir is unset"
grep -Fq 'chmod 700' "$script" || fail "DDC brightness enforces mode 0700 on the private cache root"
pass "DDC brightness cache path avoids world-writable /tmp"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

stub_bin="$tmp/bin"
mkdir -p "$stub_bin" "$tmp/home" "$tmp/state"
cat >"$stub_bin/ddcutil" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$stub_bin/ddcutil"

export PATH="$stub_bin:$PATH"
export HOME="$tmp/home"
unset XDG_RUNTIME_DIR
export XDG_STATE_HOME="$tmp/state"

bash "$script" DP-1 >/dev/null 2>&1 || true

[[ -d $XDG_STATE_HOME/omarchy/omarchy-brightness-display-ddc ]] ||
  fail "creates cache under XDG_STATE_HOME/omarchy" "$(find "$tmp" -type d)"
mode=$(stat -c '%a' "$XDG_STATE_HOME/omarchy" 2>/dev/null || stat -f '%Lp' "$XDG_STATE_HOME/omarchy")
[[ $mode == 700 ]] || fail "private cache root is mode 0700" "mode=$mode"
[[ ! -e /tmp/omarchy-brightness-display-ddc ]] ||
  fail "does not create /tmp/omarchy-brightness-display-ddc"
pass "DDC brightness stages cache under a private state directory"
