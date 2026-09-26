#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

real="$tmp/real-videos"
link="$tmp/Videos"
mkdir -p "$real"
printf 'media' >"$real/clip.webm"
ln -s "$real" "$link"

stub="$tmp/bin"
mkdir -p "$stub"
cat >"$stub/omarchy-menu-select" <<'EOF'
#!/bin/bash
# Consume stdin and print paths so the test can assert find -L worked.
cat
EOF
chmod +x "$stub/omarchy-menu-select"

output=$(PATH="$stub:$PATH" "$ROOT/bin/omarchy-menu-file" "Select media" "$link" "webm")
[[ $output == *"$link/clip.webm"* ]] || fail "menu-file follows a symlink starting point" "$output"
pass "menu-file follows a symlink starting point"
