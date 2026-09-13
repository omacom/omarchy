#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command flock

test_tmp=$(mktemp -d)
worker_pids=()
cleanup() {
  touch "$test_tmp/document.release"
  for pid in "${worker_pids[@]}"; do kill "$pid" 2>/dev/null || true; done
  for pid in "${worker_pids[@]}"; do wait "$pid" 2>/dev/null || true; done
  rm -rf -- "$test_tmp"
}
trap cleanup EXIT
export OMARCHY_PARENT_CONF="$test_tmp/settings directory/parent.conf"
source "$ROOT/install/helpers/parent.sh"

wait_for_any() {
  local attempt marker
  for (( attempt = 0; attempt < 500; attempt++ )); do
    for marker in "$@"; do
      [[ -f $marker ]] && return 0
    done
    sleep 0.01
  done
  return 1
}

# Stop the default writer immediately after it checks whether wifi exists.
# Without a shared lock, an explicit choice can land before that writer
# appends the default. With the fix, the setter waits and then wins.
mkdir -p "$(dirname "$PARENT_CONF")"
printf '# Existing parent settings\n' >"$PARENT_CONF"
export TEST_CONFIG_RACE="$test_tmp"
bash -euo pipefail -c '
  source "$1"
  grep() {
    local status
    if command grep "$@"; then status=0; else status=$?; fi
    : >"$TEST_CONFIG_RACE/document.checked"
    while [[ ! -f $TEST_CONFIG_RACE/document.release ]]; do sleep 0.01; done
    return "$status"
  }
  conf_document wifi parent "Who may change Wi-Fi networks"
' _ "$ROOT/install/helpers/parent.sh" &
document_pid=$!
worker_pids+=("$document_pid")
wait_for_any "$test_tmp/document.checked" || fail "the default writer reaches the Wi-Fi check"

bash -euo pipefail -c '
  source "$1"
  flock() {
    : >"$TEST_CONFIG_RACE/setter.waiting"
    command flock "$@"
  }
  conf_set wifi kid
  : >"$TEST_CONFIG_RACE/setter.done"
' _ "$ROOT/install/helpers/parent.sh" &
setter_pid=$!
worker_pids+=("$setter_pid")
wait_for_any "$test_tmp/setter.waiting" "$test_tmp/setter.done" || fail "the explicit setter starts"
touch "$test_tmp/document.release"
wait "$document_pid" || fail "the default writer completes"
wait "$setter_pid" || fail "the explicit setter completes"
worker_pids=()
[[ $(conf_get wifi parent) == "kid" && $(grep -c '^wifi=' "$PARENT_CONF") == 1 ]] ||
  fail "concurrent initialization keeps the explicit Wi-Fi choice exactly once" "$(<"$PARENT_CONF")"
pass "concurrent default initialization cannot overwrite the parent's Wi-Fi choice"

# An already-set key survives both initialization APIs without rewriting the
# file or its comments. No module beyond the existing Wi-Fi control is needed.
saved=$(<"$PARENT_CONF")
conf_init
conf_document wifi parent "A later default"
[[ $(<"$PARENT_CONF") == "$saved" ]] || fail "initialization preserves existing settings and comments"
conf_set wifi parent
grep -qx '# Who may change Wi-Fi networks' "$PARENT_CONF" || fail "changing Wi-Fi preserves its documentation"
mode=$(stat -c %a "$PARENT_CONF" 2>/dev/null) || mode=$(stat -f %Lp "$PARENT_CONF")
[[ $mode == "644" ]] || fail "published parent settings remain world-readable" "$mode"
pass "initialization is idempotent and changes preserve comments and public permissions"

# Readers that already opened the file retain the complete old generation;
# readers opening its path after publication get the complete new one.
saved=$(<"$PARENT_CONF")
exec {reader_fd}<"$PARENT_CONF"
original_umask=$(umask)
conf_set wifi kid
[[ $(cat <&"$reader_fd") == "$saved" && $(conf_get wifi parent) == "kid" ]] ||
  fail "publication atomically replaces the settings file"
exec {reader_fd}<&-
[[ $(umask) == "$original_umask" ]] || fail "settings writes preserve the caller's umask"
pass "publication gives readers complete generations without changing the caller's umask"

# Run in conditionals deliberately: errexit is suppressed there, so every
# failed write step must itself stop publication and return failure.
saved=$(<"$PARENT_CONF")
for operation in flock sed mv; do
  (
    eval "$operation() { return 73; }"
    if conf_set wifi parent; then
      fail "a failed $operation reports failure"
    fi
  ) || fail "a failed $operation cannot publish a setting"
  [[ $(<"$PARENT_CONF") == "$saved" ]] || fail "a failed $operation keeps the previous settings"
  if compgen -G "$(dirname "$PARENT_CONF")/.parent.conf.??????" >/dev/null; then
    fail "a failed $operation leaves no staging file behind"
  fi
done
pass "lock, content-generation and publication failures preserve settings and clean up staging files"

# A fresh file has the same header and permission contract through either
# initialization path; creating a default also obeys the writer lock.
PARENT_CONF="$test_tmp/fresh settings/parent.conf"
conf_init
grep -q '^# Omarchy kids mode:' "$PARENT_CONF" || fail "a fresh settings file has the shared header"
conf_document wifi parent "Who may change Wi-Fi networks"
[[ $(conf_get wifi kid) == "parent" ]] || fail "a fresh file receives its default"
conf_set wifi kid
[[ $(conf_get wifi parent) == "kid" ]] || fail "a fresh file remains writable after initialization"
pass "fresh settings initialize correctly and the lock is released after every operation"
