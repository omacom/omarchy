#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

real="$tmp/real-videos"
link="$tmp/Videos"
nested_real="$tmp/elsewhere"
mkdir -p "$real" "$nested_real"
printf 'media' >"$real/clip.webm"
printf 'nested' >"$nested_real/nested.webm"
ln -s "$nested_real" "$real/nested-link"
ln -s "$real" "$link"

stub="$tmp/bin"
mkdir -p "$stub"
cat >"$stub/omarchy-menu-select" <<'STUB'
#!/bin/bash
# Consume stdin and print paths so the test can assert find -H starting-point behavior.
cat
STUB
chmod +x "$stub/omarchy-menu-select"

output=$(PATH="$stub:$PATH" "$ROOT/bin/omarchy-menu-file" "Select media" "$link" "webm")
[[ $output == *"$link/clip.webm"* ]] || fail "menu-file follows a symlink starting point" "$output"
# find -H must not walk nested symlinks inside the root (would list under -L).
[[ $output != *nested.webm* ]] || fail "menu-file must not follow nested symlinks inside roots" "$output"
pass "menu-file follows a symlink starting point without nested walks"
