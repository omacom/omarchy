#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

theme_set="$ROOT/bin/omarchy-theme-set"

if grep -Fq '${XDG_RUNTIME_DIR:-/tmp}/omarchy-theme-set.lock' "$theme_set"; then
  fail "theme-set flock must not fall back to world-writable /tmp"
fi
grep -Fq '${XDG_RUNTIME_DIR:-/tmp/omarchy-$UID}' "$theme_set" ||
  fail "theme-set flock falls back to a 0700 /tmp/omarchy-\$UID directory"
grep -Fq 'mkdir -m 700 -p "$THEME_SET_LOCK_DIR"' "$theme_set" ||
  fail "theme-set creates the flock directory with mode 0700"
grep -Fq 'THEME_SET_LOCK="$THEME_SET_LOCK_DIR/omarchy-theme-set.lock"' "$theme_set" ||
  fail "theme-set keeps the flock file name"
pass "theme-set flock is not in world-writable /tmp"
