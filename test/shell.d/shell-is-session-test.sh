#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
session="$test_tmp/omarchy dev"
copy="$test_tmp/copy"
mkdir -p "$fake_bin" "$session" "$copy"
ln -s "$session" "$test_tmp/omarchy-link"

# The manager's raw environment, as busctl reports it.
cat >"$fake_bin/busctl" <<'SH'
#!/bin/bash

[[ ${OMARCHY_TEST_BUSCTL_FAILS:-0} == 1 ]] && exit 1
jq -cn --arg env "$OMARCHY_TEST_SESSION_ENV" '{type: "as", data: ($env | split("\n") | map(select(length > 0)))}'
SH
chmod +x "$fake_bin/busctl"

SESSION=0
NOT_SESSION=1

assert_session() {
  local expected="$1" omarchy_path="$2" session_env="$3" description="$4" busctl_fails="${5:-0}" actual=0

  PATH="$fake_bin:$PATH" \
  OMARCHY_PATH="$omarchy_path" \
  OMARCHY_TEST_SESSION_ENV="$session_env" \
  OMARCHY_TEST_BUSCTL_FAILS="$busctl_fails" \
    "$ROOT/bin/omarchy-shell-is-session" || actual=$?

  (( actual == expected )) || fail "$description" "expected exit $expected, got $actual"
  pass "$description"
}

# The session's tree holds a space, which show-environment would escape.
assert_session $SESSION "$session" \
  "HOME=/home/user"$'\n'"OMARCHY_PATH=$session" \
  "the shell running from the session's tree is the session shell"

# Test copies run the shell out of a temporary tree on the same display.
assert_session $NOT_SESSION "$copy" \
  "OMARCHY_PATH=$session" \
  "a shell running from another tree is not the session shell"

assert_session $SESSION "$test_tmp/omarchy-link/" \
  "OMARCHY_PATH=$session" \
  "the same tree reached through a symlink or trailing slash still matches"

# Nothing to compare against keeps the recovery every shell had before.
assert_session $SESSION "$copy" \
  "HOME=/home/user" \
  "a session without a recorded path leaves the shell in charge"

assert_session $SESSION "$copy" \
  "" \
  "an unreachable user manager leaves the shell in charge" 1
