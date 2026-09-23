#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

SCRIPT="$ROOT/bin/omarchy-theme-set-browser"
SET_SCRIPT="$ROOT/bin/omarchy-theme-set"

bash -n "$SCRIPT"
bash -n "$SET_SCRIPT"
pass "theme-set and theme-set-browser have valid bash syntax"

if ! grep -qE 'omarchy-theme-switcher --preload.*&$' "$SET_SCRIPT"; then
  fail "theme-set backgrounds the selector preload so theme switch does not block"
fi
pass "theme-set backgrounds the selector preload"

if ! grep -q 'all_unchanged=true' "$SCRIPT"; then
  fail "theme-set-browser skips work when every managed color.json is already correct"
fi
pass "theme-set-browser checks existing color.json before doing work"

if ! grep -q 'pids=()' "$SCRIPT"; then
  fail "theme-set-browser collects browser refresh pids in an array"
fi
pass "theme-set-browser parallelizes browser refreshes with a pids array"

if ! grep -q 'for pid in "${pids\[@\]}"; do' "$SCRIPT"; then
  fail "theme-set-browser waits for parallel browser refreshes"
fi
pass "theme-set-browser waits for parallel browser refreshes"
