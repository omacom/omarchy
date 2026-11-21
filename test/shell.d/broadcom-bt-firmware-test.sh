#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/fix-bcm20702a1-bluetooth.sh"
all="$ROOT/install/hardware/all.sh"
other_packages="$ROOT/install/omarchy-other.packages"
migration="$ROOT/migrations/1792401201.sh"

grep -q 'run_logged .*hardware/fix-bcm20702a1-bluetooth.sh' "$all" ||
  fail "the Broadcom Bluetooth firmware setup runs during hardware setup"
grep -qx 'broadcom-bt-firmware' "$other_packages" ||
  fail "the ISO caches the Broadcom Bluetooth firmware package"
pass "the Broadcom Bluetooth firmware setup and its package are available during offline installation"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
usb_root="$test_tmp/sys/bus/usb/devices"
firmware="$test_tmp/usr/lib/firmware/brcm/BCM20702A1-0a5c-216f.hcd"
mkdir -p "$stub_bin" "$usb_root" "$(dirname "$firmware")"

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-add\t%s\n' "$*" >>"$TEST_LOG"

[[ ${PKG_ADD_FAIL:-0} == 0 ]]
SH

cat >"$stub_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash

(( ${PKG_INSTALLED:-0} == 0 ))
SH

cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash

printf 'omarchy-state\t%s\n' "$*" >>"$TEST_LOG"
SH

cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash

printf 'pacman\t%s\n' "$*" >>"$TEST_LOG"

if [[ ${1:-} == "-Qo" ]]; then
  (( ${FIRMWARE_OWNED:-0} == 1 )) && exit 0
  echo "error: No package owns ${2:-}" >&2
  exit 1
fi
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo\t%s\n' "$*" >>"$TEST_LOG"
"$@"
SH

chmod +x "$stub_bin"/*

# The leaf reads the USB bus from an absolute path, so point it at a fixture.
leaf_copy="$test_tmp/leaf.sh"
sed -e "s|/sys/bus/usb/devices|$usb_root|g" "$leaf" >"$leaf_copy" ||
  fail "copy the Bluetooth firmware leaf for a fixture USB root"

# A bus that carries one device: its own directory, an idVendor and idProduct in
# it, and the interface directories next to it that carry neither.
device() {
  local port="$1" vendor="${2:-}" product="${3:-}"

  rm -rf "${usb_root:?}"/*
  mkdir -p "$usb_root/$port" "$usb_root/$port:1.0" "$usb_root/$port:1.1"
  printf '%s\n' "$vendor" >"$usb_root/$port/idVendor"
  printf '%s\n' "$product" >"$usb_root/$port/idProduct"
  printf 'ff\n' >"$usb_root/$port:1.0/bInterfaceNumber"
}

run_leaf() {
  : >"$calls"

  TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
    bash -euo pipefail -c 'source "$1"' bash "$leaf_copy" >/dev/null
}

device 1-2 0a5c 216f
run_leaf
grep -Fxq $'omarchy-pkg-add\tbroadcom-bt-firmware' "$calls" ||
  fail "the BCM20702A1 controller installs the firmware package" "$(cat "$calls")"
pass "the BCM20702A1 controller installs the firmware package"

# linux-firmware carries no Broadcom Bluetooth firmware at all, so this list is
# what Omarchy covers on purpose, not what is already there.
device 1-2 0a5c 21e8
run_leaf
[[ ! -s $calls ]] || fail "another Broadcom controller is left alone" "$(cat "$calls")"
pass "another Broadcom controller is left alone"

device 1-2 8087 0032
run_leaf
[[ ! -s $calls ]] || fail "a machine with another Bluetooth controller is left alone" "$(cat "$calls")"
pass "a machine with another Bluetooth controller is left alone"

device 1-2
run_leaf
[[ ! -s $calls ]] || fail "a bus with no vendor or product is left alone" "$(cat "$calls")"
pass "a bus with no vendor or product is left alone"

rm -rf "${usb_root:?}"/*
run_leaf
[[ ! -s $calls ]] || fail "a machine with no USB device is left alone" "$(cat "$calls")"
pass "a machine with no USB device is left alone"

# The install-time leaf only reaches machines set up after it shipped, so the
# migration has to reach an existing install.
run_migration() {
  local installed="${1:-0}" owned="${2:-0}" add_fails="${3:-0}"
  : >"$calls"

  PKG_INSTALLED="$installed" FIRMWARE_OWNED="$owned" PKG_ADD_FAIL="$add_fails" TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
    OMARCHY_BCM20702A1_USB_ROOT="$usb_root" \
    OMARCHY_BCM20702A1_FIRMWARE="$firmware" \
    bash -euo pipefail "$migration" >/dev/null
}

device 1-2 0a5c 216f
run_migration
grep -Fxq $'omarchy-pkg-add\tbroadcom-bt-firmware' "$calls" ||
  fail "the migration installs the firmware package" "$(cat "$calls")"
grep -Fxq $'omarchy-state\tset reboot-required' "$calls" ||
  fail "the migration asks for the reboot that loads the firmware" "$(cat "$calls")"
pass "the migration installs the firmware package on an existing install"

printf 'already-there\n' >"$firmware"
run_migration 1
[[ ! -s $calls ]] || fail "an install that already has the package is left untouched" "$(cat "$calls")"
[[ $(<"$firmware") == "already-there" ]] ||
  fail "an install that already has the package keeps the firmware file" "$(cat "$firmware")"
pass "the migration leaves an install that has the package alone"

# Following the ArchWiki page leaves a hand-extracted file at the path the
# package owns, and pacman refuses to install over a file no package owns.
printf 'hand-extracted\n' >"$firmware"
run_migration 0 0
grep -Fxq $'pacman\t-Qo '"$firmware" "$calls" ||
  fail "the migration asks whether the firmware file is owned" "$(cat "$calls")"
grep -Fxq $'sudo\tmv -f '"$firmware $firmware.omarchy-backup" "$calls" ||
  fail "the migration keeps the unowned firmware file as a backup" "$(cat "$calls")"
[[ ! -e $firmware ]] || fail "the unowned firmware file is out of the package's path"
[[ $(<"$firmware.omarchy-backup") == "hand-extracted" ]] ||
  fail "the backup holds what the file did" "$(cat "$firmware.omarchy-backup")"
grep -Fxq $'omarchy-pkg-add\tbroadcom-bt-firmware' "$calls" ||
  fail "the migration installs over the path the hand-extracted file held" "$(cat "$calls")"
pass "the migration hands the path to the package"

# The install can fail because the package is not in the repository yet. The
# hand-extracted file has to be back where the kernel reads it, and the
# migration has to stay pending.
printf 'hand-extracted\n' >"$firmware"
rm -f "$firmware.omarchy-backup"
run_migration 0 0 1 && fail "a failed firmware install leaves the migration pending"
[[ -e $firmware ]] || fail "a failed firmware install puts the hand-extracted file back"
[[ ! -e $firmware.omarchy-backup ]] || fail "a failed firmware install does not leave the firmware aside"
[[ $(<"$firmware") == "hand-extracted" ]] ||
  fail "the restored file is the one the migration moved" "$(cat "$firmware")"
grep -Fxq $'omarchy-pkg-add\tbroadcom-bt-firmware' "$calls" ||
  fail "a failed firmware install had tried to install the package" "$(cat "$calls")"
grep -Fxq $'omarchy-state\tset reboot-required' "$calls" &&
  fail "a failed firmware install does not ask for a reboot" "$(cat "$calls")"
pass "a failed firmware install puts the hand-extracted file back"

# A file the package does own is not touched: it is the firmware the kernel is
# already looking for.
printf 'package-owned\n' >"$firmware"
run_migration 0 1
grep -Fxq $'sudo\tmv -f '"$firmware $firmware.omarchy-backup" "$calls" &&
  fail "the migration moves a file the package owns" "$(cat "$calls")"
[[ -e $firmware ]] || fail "a package-owned firmware file survives the migration"
[[ $(<"$firmware") == "package-owned" ]] ||
  fail "a package-owned firmware file keeps its contents" "$(cat "$firmware")"
pass "the migration leaves a package-owned firmware file in place"

device 1-2 0a5c 21e8
run_migration
[[ ! -s $calls ]] || fail "the migration does nothing on another Broadcom controller" "$(cat "$calls")"
pass "the migration does nothing on another Broadcom controller"
