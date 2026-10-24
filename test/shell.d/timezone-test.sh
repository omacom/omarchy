#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

timezone_menu="$ROOT/bin/omarchy-menu-timezone"
sudoers_file="$ROOT/etc/sudoers.d/omarchy-tzupdate"

grep -F '%wheel ALL=(root) NOPASSWD: /usr/bin/timedatectl ^set-timezone [A-Za-z0-9_+][A-Za-z0-9_+.-]*(/[A-Za-z0-9_+][A-Za-z0-9_+.-]*)*$' "$sudoers_file" >/dev/null ||
  fail "timezone sudoers rule allows passwordless timedatectl timezone changes"

! grep -F 'set-timezone *' "$sudoers_file" >/dev/null ||
  fail "timezone sudoers rule uses a bare wildcard that admits extra arguments like -H and -M"

! grep -F 'tzupdate' "$sudoers_file" >/dev/null ||
  fail "timezone sudoers rule does not grant passwordless tzupdate"

grep -F 'sudo timedatectl set-timezone "$timezone"' "$timezone_menu" >/dev/null ||
  fail "timezone menu uses the passwordless sudoers timedatectl rule"

! grep -F 'pkexec timedatectl set-timezone "$timezone"' "$timezone_menu" >/dev/null ||
  fail "timezone menu does not wrap timedatectl in pkexec"

! grep -F 'pkexec /usr/bin/timedatectl set-timezone "$timezone"' "$timezone_menu" >/dev/null ||
  fail "timezone menu does not wrap timedatectl in pkexec"

! grep -F 'sudo /usr/bin/timedatectl set-timezone "$timezone"' "$timezone_menu" >/dev/null ||
  fail "timezone menu lets sudo resolve timedatectl from its secure path"

! grep -Fx 'timedatectl set-timezone "$timezone"' "$timezone_menu" >/dev/null ||
  fail "timezone menu does not use bare timedatectl, which triggers polkit"

grep -F 'omarchy-shell -q omarchy.clock refresh' "$timezone_menu" >/dev/null ||
  fail "timezone menu refreshes the namespaced clock IPC target"

! grep -F 'omarchy-shell -q Clock refresh' "$timezone_menu" >/dev/null ||
  fail "timezone menu no longer refreshes the retired Clock IPC target"

pass "timezone menu refreshes clock after timezone changes"

# The time zone is machine-wide: an account outside wheel is told so before the
# picker opens, instead of picking a zone and seeing nothing happen.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
for command in omarchy-menu-select sudo timedatectl omarchy-shell; do
  printf '#!/bin/bash\necho "%s $*" >>"$TEST_CALLS"\n' "$command" >"$test_tmp/bin/$command"
done
printf '#!/bin/bash\necho "notify $*" >>"$TEST_CALLS"\n' >"$test_tmp/bin/omarchy-notification-send"
printf '#!/bin/bash\n[[ $TEST_ADMIN == "yes" ]]\n' >"$test_tmp/bin/omarchy-sudo-allowed"
chmod +x "$test_tmp/bin"/*
: >"$test_tmp/calls"
if PATH="$test_tmp/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_LANGUAGE_FILE=/nonexistent TEST_ADMIN=no TEST_CALLS="$test_tmp/calls" \
  bash "$timezone_menu"; then
  fail "the timezone menu reports success for an account outside wheel"
fi
grep -Fx "notify Only an administrator can change the time zone" "$test_tmp/calls" >/dev/null &&
  ! grep -q -E "^(omarchy-menu-select|sudo|timedatectl) " "$test_tmp/calls" ||
  fail "an account outside wheel is told, before the picker" "$(cat "$test_tmp/calls")"
pass "an account outside wheel is told the time zone takes an administrator"

