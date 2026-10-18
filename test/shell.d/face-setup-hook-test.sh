#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/install/user/first-run/setup-face.hook"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
log="$test_tmp/calls.log"
copy="$test_tmp/setup-face.hook"
mkdir -p "$stub_bin"

# The setup writes the face limits last on success, whichever of sudo, polkit
# and the lock screen it was asked for, so they mark it done; the lock service
# alone would not after a sudo and polkit setup.
(( $(grep -Fc '/etc/omarchy/face.conf' "$hook") == 1 )) || fail "the hook names the setup's last file once"
! grep -q 'omarchy-lock-face' "$hook" || fail "the hook does not take the optional lock service for the setup's mark"
# The setup installs the driver, so the camera alone earns the invitation.
! grep -q 'hm1092' "$hook" || fail "the hook does not wait for the driver the setup installs"
sed -e "s|/etc/omarchy/face.conf|$test_tmp/face.conf|" "$hook" >"$copy"
pass "the hook reads the setup's mark, and the test drives a retargeted copy"

cat >"$stub_bin/omarchy-hw-dell-xps-ir-camera" <<'SH'
#!/bin/bash
[[ $# == 0 && $TEST_HW == 1 ]]
SH
cat >"$stub_bin/omarchy-done" <<'SH'
#!/bin/bash
[[ $* == "ensure face-setup-invitation" ]]
SH
cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notify %s\n' "$*" >>"$TEST_LOG"
SH
chmod +x "$stub_bin"/*

# invoke <camera fitted: 1 or 0>
invoke() {
  : >"$log"
  TEST_LOG="$log" TEST_HW="$1" PATH="$stub_bin:/usr/bin:/bin" bash "$copy" || fail "the hook never fails the first run"
}

invoke 1
grep -q 'notify .*omarchy-setup-security-face' "$log" || fail "a fitted camera without a setup gets the invitation, driver or not" "$(cat "$log")"
invoke 0
[[ ! -s $log ]] || fail "a machine without the camera gets no invitation" "$(cat "$log")"
: >"$test_tmp/face.conf"
invoke 1
[[ ! -s $log ]] || fail "a finished setup gets no invitation" "$(cat "$log")"
pass "the hook invites to the setup only while a fitted camera is not set up"

# Accounts that finished their first run before the face existed would never
# get the invitation, so a migration installs it for them too, as upstream's
# agent invitation does.
migration=$(grep -lF 'install/user/first-run/setup-face.hook' "$ROOT"/migrations/*.sh 2>/dev/null || true)
(( $(wc -w <<<"$migration") == 1 )) || fail "one migration installs the invitation for existing accounts" "$migration"
[[ $(stat -c %a "$migration") == 644 && $(head -c 2 "$migration") != '#!' && $(head -n 1 "$migration") == echo\ * ]] ||
  fail "the migration follows upstream's format: 0644, no shebang, an echo first" "$(stat -c %a "$migration"; head -n 1 "$migration")"
cat >"$stub_bin/omarchy-hook-install" <<'SH'
#!/bin/bash
printf 'hook-install %s\n' "$*" >>"$TEST_LOG"
SH
chmod +x "$stub_bin/omarchy-hook-install"
: >"$log"
TEST_LOG="$log" OMARCHY_PATH=/opt/omarchy PATH="$stub_bin:/usr/bin:/bin" bash -euo pipefail "$migration" >/dev/null ||
  fail "the migration runs"
[[ $(<"$log") == "hook-install post-update /opt/omarchy/install/user/first-run/setup-face.hook" ]] ||
  fail "the migration installs the invitation as a post-update hook" "$(cat "$log")"
pass "a migration installs the invitation for accounts past their first run"

first_run="$ROOT/bin/omarchy-provision-first-run"
if [[ -f $first_run ]]; then
  # shellcheck disable=SC2016 # the literal is what the first run says
  grep -qF 'omarchy-hook-install post-update "$OMARCHY_PATH/install/user/first-run/setup-face.hook"' "$first_run" ||
    fail "the first run installs the invitation"
  pass "the first run installs the invitation as a post-update hook"
else
  skip "omarchy-provision-first-run is upstream's; the overlay's apply suite checks the line it adds"
fi
