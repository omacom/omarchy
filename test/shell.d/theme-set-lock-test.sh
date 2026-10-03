#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"; rm -f /tmp/omarchy-theme-set.lock' EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home/.local/state/omarchy/current" "$test_tmp/state"

# Headless + skip-background: reach the serialization lock, apply the theme
# swap, and return without the post-theme app-retint fan-out.
run_no_runtime_dir() {
  env -u XDG_RUNTIME_DIR \
    HOME="$test_home" XDG_STATE_HOME="$test_tmp/state" \
    OMARCHY_PATH="$ROOT" OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
    PATH="$ROOT/bin:$PATH" \
    timeout 30 omarchy-theme-set tokyo-night
}

# A fixed lock name in world-writable /tmp is a name any other local account
# can pre-create. As a symlink it redirects the truncating open.
echo precious >"$test_tmp/victim"
ln -s "$test_tmp/victim" /tmp/omarchy-theme-set.lock
run_no_runtime_dir >/dev/null 2>&1
rm -f /tmp/omarchy-theme-set.lock
[[ $(cat "$test_tmp/victim") == "precious" ]] || fail "lock open follows a pre-planted /tmp symlink" "victim file was truncated"
pass "lock open ignores a pre-planted /tmp symlink"

# Held by another account, the same lock starves every theme change forever.
exec 8>/tmp/omarchy-theme-set.lock
flock 8
if run_no_runtime_dir >/dev/null 2>&1; then
  flock -u 8
  exec 8>&-
  rm -f /tmp/omarchy-theme-set.lock
  pass "a lock held by another account cannot starve theme set"
else
  flock -u 8
  exec 8>&-
  rm -f /tmp/omarchy-theme-set.lock
  fail "a lock held by another account cannot starve theme set" "run timed out waiting on the /tmp lock"
fi

# The fixed lock still serializes: it lives under the per-user runtime dir.
[[ -f $test_tmp/state/omarchy/omarchy-theme-set.lock ]] || fail "lock lands in the per-user runtime dir"
pass "lock lands in the per-user runtime dir"
