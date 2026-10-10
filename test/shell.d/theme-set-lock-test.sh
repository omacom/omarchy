#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_lock=/tmp/omarchy-theme-set.lock
planted=0

test_tmp=$(mktemp -d)
cleanup() {
  rm -rf "$test_tmp"
  if (( planted )); then
    rm -f "$tmp_lock"
  fi
}
trap cleanup EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home/.local/state/omarchy/current" "$test_tmp/state"

# Headless + skip-background: reach the serialization lock, apply the theme
# swap, and return without the post-theme app-retint fan-out.
run_no_runtime_dir() {
  env -u XDG_RUNTIME_DIR \
    HOME="$test_home" XDG_STATE_HOME="$test_tmp/state" \
    OMARCHY_PATH="$ROOT" OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
    PATH="$ROOT/bin:$PATH" \
    timeout "${1:-30}" omarchy-theme-set tokyo-night
}

# A fixed lock name in world-writable /tmp is a name any other local account
# can pre-create. Leave one this test did not plant alone.
if [[ -e $tmp_lock || -L $tmp_lock ]]; then
  skip "lock open ignores a pre-planted /tmp symlink ($tmp_lock already exists)"
  skip "a lock held in /tmp cannot starve theme set ($tmp_lock already exists)"
else
  echo precious >"$test_tmp/victim"
  ln -s "$test_tmp/victim" "$tmp_lock"
  planted=1
  run_no_runtime_dir >/dev/null 2>&1
  rm -f "$tmp_lock"
  [[ $(cat "$test_tmp/victim") == "precious" ]] || fail "lock open ignores a pre-planted /tmp symlink" "victim file was truncated"
  pass "lock open ignores a pre-planted /tmp symlink"

  exec 8>"$tmp_lock"
  flock 8
  if run_no_runtime_dir >/dev/null 2>&1; then
    result=pass
  else
    result=fail
  fi
  flock -u 8
  exec 8>&-
  rm -f "$tmp_lock"
  planted=0
  [[ $result == "pass" ]] || fail "a lock held in /tmp cannot starve theme set" "run timed out waiting on the /tmp lock"
  pass "a lock held in /tmp cannot starve theme set"
fi

# The lock still serializes, and beside the theme state it guards rather than
# under XDG_STATE_HOME: a run waits while it is held.
state_lock="$test_home/.local/state/omarchy/omarchy-theme-set.lock"
rm -f "$state_lock"
run_no_runtime_dir >/dev/null 2>&1 || fail "theme set waits on the lock beside its state" "an unlocked run failed"
[[ -f $state_lock ]] || fail "theme set waits on the lock beside its state" "no lock at $state_lock"
exec 7>"$state_lock"
flock 7
status=0
run_no_runtime_dir 3 >/dev/null 2>&1 || status=$?
flock -u 7
exec 7>&-
(( status == 124 )) || fail "theme set waits on the lock beside its state" "exit $status, expected a timeout"
pass "theme set waits on the lock beside its state"

# Another account that can reach the lock can hold it, read-only or not.
chmod 755 "$test_home/.local/state/omarchy"
run_no_runtime_dir >/dev/null 2>&1 || fail "the fallback lock dir is private" "theme set failed"
[[ $(stat -c %a "$test_home/.local/state/omarchy") == "700" ]] || fail "the fallback lock dir is private" "mode $(stat -c %a "$test_home/.local/state/omarchy")"
pass "the fallback lock dir is private"
