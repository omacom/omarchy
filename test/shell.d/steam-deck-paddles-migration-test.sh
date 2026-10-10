#!/bin/bash
#
# The Steam Deck back-button migration must install the paddle reader's
# packages only on a Deck, and apply steam-devices' udev rules to both
# /dev/uinput and the controller's hidraw node right away, so the reader can
# open them from the next login rather than the next boot. A failed re-trigger
# must not fail the migration: the rules still apply at boot.
#
# Only the hardware check, package helper and privileged calls are stubbed.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1790937569.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
calls="$test_dir/calls"
mkdir -p "$stub_bin"

# omarchy-hw-steam-deck answers from STUB_DECK; the package helper and sudo
# record their calls instead of touching the system, and sudo fails any call
# matching STUB_SUDO_FAIL.
cat >"$stub_bin/omarchy-hw-steam-deck" <<'STUB'
#!/bin/bash
[[ ${STUB_DECK:-0} == "1" ]]
STUB
cat >"$stub_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
echo "pkg-add $*" >>"${CALLS:?}"
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
echo "sudo $*" >>"${CALLS:?}"
[[ -z ${STUB_SUDO_FAIL:-} || $* != *"$STUB_SUDO_FAIL"* ]]
STUB
chmod +x "$stub_bin"/*

run_migration() {
  rm -f "$calls"
  PATH="$stub_bin:$PATH" CALLS="$calls" bash -euo pipefail "$migration" >/dev/null 2>&1
}

STUB_DECK=0 run_migration || fail "migration completes off a Steam Deck"
[[ ! -e $calls ]] || fail "migration does nothing off a Steam Deck" "$(<"$calls")"
pass "migration does nothing off a Steam Deck"

STUB_DECK=1 run_migration || fail "migration completes on a Steam Deck"
expected="pkg-add python-evdev steam-devices
sudo udevadm control --reload-rules
sudo udevadm trigger --action=change --name-match=uinput
sudo udevadm trigger --action=change --subsystem-match=hidraw"
[[ $(<"$calls") == "$expected" ]] || fail "migration installs the packages and applies the udev rules to uinput and hidraw" "$(<"$calls")"
pass "migration installs the packages and applies the udev rules to uinput and hidraw"

for failing in "--name-match=uinput" "--subsystem-match=hidraw"; do
  STUB_DECK=1 STUB_SUDO_FAIL="$failing" run_migration || fail "migration survives a failed re-trigger ($failing)"
  [[ $(<"$calls") == "$expected" ]] || fail "migration still runs every re-trigger after one fails ($failing)" "$(<"$calls")"
done
pass "migration survives a failed udev re-trigger"
