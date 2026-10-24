#!/bin/bash
#
# First run asks the account to update the system once the network is up. Only
# an administrator can install updates, so the prompt goes to them alone; the
# Wi-Fi prompt is everyone's.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/nm-online" <<'SH'
#!/bin/bash
# -x asks whether a connection is up right now.
if [[ $* == *-x* ]]; then
  [[ $TEST_ONLINE == "yes" ]]
fi
SH
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_NOTIFICATIONS"
SH
cat >"$mock_bin/omarchy-sudo-allowed" <<'SH'
#!/bin/bash
[[ $TEST_ADMIN == "yes" ]]
SH
# There is always something to update; the check is logged, since it syncs the
# package databases.
cat >"$mock_bin/checkupdates" <<'SH'
#!/bin/bash
echo checkupdates >>"$TEST_NOTIFICATIONS"
exit 0
SH
chmod +x "$mock_bin"/*

notifications="$test_tmp/notifications"

run_first_run_step() { # ADMIN ONLINE
  : >"$notifications"
  # The step detaches its work; wait for it rather than racing it.
  env PATH="$mock_bin:$PATH" TEST_ADMIN="$1" TEST_ONLINE="$2" TEST_NOTIFICATIONS="$notifications" \
    bash -c 'source "$1"; wait' _ "$ROOT/install/user/first-run/wifi.sh"
}

run_first_run_step yes yes
grep -F 'Update System' "$notifications" >/dev/null || fail "an administrator is asked to update" "$(cat "$notifications")"
pass "an administrator is asked to update the system"

run_first_run_step no yes
grep -F 'Update System' "$notifications" >/dev/null && fail "an account that isn't an administrator is not asked to update" "$(cat "$notifications")"
grep -Fx checkupdates "$notifications" >/dev/null && fail "an account that isn't an administrator doesn't check for updates" "$(cat "$notifications")"
pass "other accounts are not asked to update, and don't check for one"

run_first_run_step no no
grep -F 'Setup Wi-Fi' "$notifications" >/dev/null || fail "every account is offered Wi-Fi setup when offline" "$(cat "$notifications")"
grep -F 'Update System' "$notifications" >/dev/null && fail "the update prompt still skips other accounts after the network comes up"
pass "the Wi-Fi prompt is everyone's"
