#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export test_tmp
mkdir -p "$test_tmp/home/.ssh"
printf '%s\n' 'test authorized key' > "$test_tmp/home/.ssh/authorized_keys"

sudo() {
  printf '%s\n' "$*" >> "$test_tmp/calls"
  if [[ $1 == "systemctl" && ${STOP_RESULT:-0} != "0" ]]; then
    echo "stub: could not disable sshd" >&2
    return "$STOP_RESULT"
  fi
}
omarchy-cmd-present() { return 0; }
gum() { printf '%s\n' 'asked about keys' >> "$test_tmp/calls"; return 1; }
export -f sudo omarchy-cmd-present gum

run_remove() {
  HOME="$test_tmp/home" bash "$ROOT/bin/omarchy-remove-security-sshd" > "$test_tmp/output" 2> "$test_tmp/errors"
}
if STOP_RESULT=1 run_remove; then
  fail "failed service disable must not report success"
fi
grep -q 'could not disable sshd' "$test_tmp/errors" || fail "service errors remain visible"
[[ $(<"$test_tmp/calls") == "systemctl disable --now sshd.service" ]] || fail "failed disable stops before firewall and key changes"
[[ $(<"$test_tmp/home/.ssh/authorized_keys") == "test authorized key" ]] || fail "failed disable preserves keys"
if grep -q 'has been disabled' "$test_tmp/output"; then
  fail "failed disable must not print the success message"
fi
pass "service disable failures are visible and stop further cleanup"

run_remove || fail "successful disable can finish"
grep -q 'ufw --force delete limit 22/tcp' "$test_tmp/calls" || fail "successful disable still closes the firewall"
grep -q 'asked about keys' "$test_tmp/calls" || fail "successful disable still offers key removal"
grep -q 'has been disabled' "$test_tmp/output" || fail "successful disable reports completion"
pass "successful disable retains firewall cleanup and optional key removal"
