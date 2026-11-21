#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

installer="$ROOT/bin/omarchy-install-gaming-xbox-controllers"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# Every privileged call the installer makes is recorded rather than performed,
# so the assertions below are about what it would do to the system.
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${SUDO_CALLS:?}"
case "$1" in
  tee) cat >/dev/null ;;
esac
STUB
cat >"$stub_bin/usermod" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${USERMOD_CALLS:?}"
STUB
cat >"$stub_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${PKG_CALLS:?}"
STUB
cat >"$stub_bin/id" <<'STUB'
#!/bin/bash
printf '%s\n' "${STUB_GROUPS:-wheel}"
STUB
cat >"$stub_bin/lsmod" <<'STUB'
#!/bin/bash
printf '%s\n' "${STUB_LSMOD:-}"
STUB
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${GUM_CALLS:?}"
exit 1
STUB
chmod +x "$stub_bin"/*

sudo_calls="$test_dir/sudo-calls"
usermod_calls="$test_dir/usermod-calls"
pkg_calls="$test_dir/pkg-calls"
gum_calls="$test_dir/gum-calls"

run_installer() {
  rm -f "$sudo_calls" "$usermod_calls" "$pkg_calls" "$gum_calls"
  : >"$sudo_calls"
  USER=tester STUB_GROUPS="${1:-wheel}" STUB_LSMOD="${2:-}" \
    SUDO_CALLS="$sudo_calls" USERMOD_CALLS="$usermod_calls" \
    PKG_CALLS="$pkg_calls" GUM_CALLS="$gum_calls" \
    PATH="$stub_bin:$PATH" bash -euo pipefail "$installer"
}

run_installer >/dev/null

# A controller is reached through systemd's 70-uaccess.rules, which ACLs every
# ID_INPUT_JOYSTICK device to the seat's active user. Membership of `input`
# would instead grant read access to every input device including the keyboard,
# which is what migration 1787865477 removed from the default install.
[[ ! -s $usermod_calls ]] ||
  fail "installer does not put the user in the input group" "$(cat "$usermod_calls")"
if grep -q 'usermod' "$sudo_calls"; then
  fail "installer does not put the user in the input group" "$(cat "$sudo_calls")"
fi
pass "installer does not put the user in the input group"

grep -qxF "xpadneo-dkms" "$pkg_calls" ||
  fail "installer still installs the controller driver" "$(cat "$pkg_calls")"
pass "installer still installs the controller driver"

grep -q 'tee /etc/modprobe.d/blacklist-xpad.conf' "$sudo_calls" ||
  fail "installer still blacklists the conflicting xpad driver" "$(cat "$sudo_calls")"
grep -q 'tee /etc/modules-load.d/xpadneo.conf' "$sudo_calls" ||
  fail "installer still arranges for hid_xpadneo to load" "$(cat "$sudo_calls")"
pass "installer still swaps xpad for hid_xpadneo"

# Nothing about the driver swap needs a reboot once the group grant is gone, so
# a machine with no xpad loaded should finish without prompting.
[[ ! -s $gum_calls ]] ||
  fail "installer does not prompt for a reboot when nothing needs one" "$(cat "$gum_calls")"
grep -q 'modprobe hid_xpadneo' "$sudo_calls" ||
  fail "installer loads hid_xpadneo when no reboot is needed" "$(cat "$sudo_calls")"
pass "installer finishes without a reboot prompt when xpad is not loaded"

# With the stale xpad driver loaded, removing it is what may need the reboot.
run_installer wheel "xpad 20480 0" >/dev/null
grep -q 'modprobe -r xpad' "$sudo_calls" ||
  fail "installer unloads a conflicting xpad driver" "$(cat "$sudo_calls")"
pass "installer unloads a conflicting xpad driver"
