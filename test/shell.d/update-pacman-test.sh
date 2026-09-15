#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$SUDO_CALL_LOG"
STUB
chmod +x "$stub_bin/sudo"

run_helper() {
  PATH="$stub_bin:$PATH" SUDO_CALL_LOG="$test_tmp/call" "$ROOT/bin/omarchy-update-pacman" "$@"
}

# The scope wrapper only applies on a systemd-booted host, so expect what the
# helper's own booted check would decide for this machine.
if [[ -d /run/systemd/system && ! -L /run/systemd/system ]]; then
  expected_scope="systemd-run --scope --quiet --collect "
else
  expected_scope=""
fi

run_helper -Syu --noconfirm
[[ $(cat "$test_tmp/call") == "env OMARCHY_UPDATE_PACMAN=1 ${expected_scope}pacman -Syu --noconfirm" ]] ||
  fail "helper composes the guarded pacman invocation" "$(cat "$test_tmp/call")"
pass "helper composes the guarded pacman invocation"

LC_ALL=C run_helper -Syu
[[ $(cat "$test_tmp/call") == "env OMARCHY_UPDATE_PACMAN=1 LC_ALL=C ${expected_scope}pacman -Syu" ]] ||
  fail "helper forwards LC_ALL to the transaction" "$(cat "$test_tmp/call")"
pass "helper forwards LC_ALL to the transaction"
