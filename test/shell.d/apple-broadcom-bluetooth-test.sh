#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-broadcom-bluetooth.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1791949600.sh"
detector="$ROOT/bin/omarchy-hw-apple-bluetooth"
reset="$ROOT/bin/omarchy-hw-apple-bluetooth-reset"
setup="$ROOT/bin/omarchy-hw-apple-bluetooth-setup"
unit="$ROOT/default/systemd/system/omarchy-apple-broadcom-bluetooth.service"
hook="$ROOT/default/systemd/system-sleep/apple-broadcom-bluetooth"

grep -q 'apple/fix-broadcom-bluetooth.sh' "$all" ||
  fail "the Broadcom Bluetooth quirk runs during hardware setup"
grep -Fq 'omarchy-hw-apple-bluetooth-setup' "$leaf" ||
  fail "hardware setup installs the recovery"
grep -Fq 'omarchy-hw-apple-bluetooth-setup' "$migration" ||
  fail "existing installs get the recovery from the migration"
grep -Fq 'omarchy-hw-aarch64-apple' "$setup" ||
  fail "Apple Silicon is excluded from the Intel Mac quirk"
grep -Fq 'ExecStart=/usr/bin/omarchy-hw-apple-bluetooth-reset' "$unit" ||
  fail "the boot unit runs the recovery command"
! grep -Eq '(^|[[:space:]])usbreset([[:space:]]|$)' "$reset" ||
  fail "recovery does not invoke usbreset"
pass "the quirk is wired into setup, the migration, and the boot unit"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

cat >"$stub_bin/omarchy-hw-aarch64-apple" <<'SH'
#!/bin/bash
(( ${APPLE_SILICON:-0} == 1 ))
SH

cat >"$stub_bin/omarchy-hw-apple-bluetooth" <<'SH'
#!/bin/bash
(( ${HAS_CHIP:-0} == 1 ))
SH

cat >"$stub_bin/omarchy-bluetooth-power" <<'SH'
#!/bin/bash
printf 'power %s\n' "$1" >"$BT_POWER_LOG"
SH

cat >"$stub_bin/bluetoothctl" <<'SH'
#!/bin/bash
if [[ -f $BT_UP ]]; then
  echo "Controller 28:F0:76:21:54:CB (public)"
else
  echo "No default controller available"
fi
SH

chmod +x "$stub_bin"/* "$detector" "$reset" "$setup" "$hook"

make_usb() {
  local root="$1"
  mkdir -p "$root/1-6" "$root/1-5" "$root/1-6:1.2" "$root/port6"
  printf '05ac' >"$root/1-6/idVendor"
  printf '8294' >"$root/1-6/idProduct"
  ln -s "$root/port6" "$root/1-6/port"
  : >"$root/port6/disable"
  : >"$root/1-6/reset"
  printf '05ac' >"$root/1-5/idVendor"
  printf '8511' >"$root/1-5/idProduct"
  printf '05ac' >"$root/1-6:1.2/idVendor"
  printf '8294' >"$root/1-6:1.2/idProduct"
}

empty="$test_tmp/empty-usb"
mkdir -p "$empty"
found=$(OMARCHY_USB_DEVICES_PATH="$empty" "$detector") && fail "a machine without the chip is not detected"
[[ -z $found ]] || fail "a miss prints nothing"

usb="$test_tmp/usb"
make_usb "$usb"
found=$(OMARCHY_USB_DEVICES_PATH="$usb" "$detector") || fail "05ac:8294 is detected"
[[ $found == "$usb/1-6" ]] || fail "detection returns the device, not an interface" "$found"
pass "only the verified Apple Bluetooth controller is detected"

run_reset() {
  local up="${1:-0}"
  local power_log="$test_tmp/power.log"
  rm -f "$power_log"
  : >"$usb/port6/disable"
  : >"$usb/1-6/reset"
  if (( up == 1 )); then
    touch "$test_tmp/up"
  else
    rm -f "$test_tmp/up"
  fi

  BT_UP="$test_tmp/up" \
  BT_POWER_LOG="$power_log" \
  OMARCHY_USB_DEVICES_PATH="$usb" \
  OMARCHY_APPLE_BT_PROBE_WAIT=0 \
  OMARCHY_APPLE_BT_RECOVER_WAIT=0 \
  OMARCHY_APPLE_BT_SETTLE=0 \
  PATH="$stub_bin:$PATH" \
    "$reset"
}

run_reset 1
[[ ! -s $usb/port6/disable ]] || fail "an adapter that is already up is left alone"
[[ ! -s $test_tmp/power.log ]] || fail "an adapter that is already up is not power-cycled"
pass "a working adapter is not reset"

# The stub treats a written reset attribute as the controller coming back.
cat >"$stub_bin/bluetoothctl" <<'SH'
#!/bin/bash
if [[ -f $BT_UP || $(cat "$BT_DEV/reset" 2>/dev/null) == 1 ]]; then
  echo "Controller 28:F0:76:21:54:CB (public)"
else
  echo "No default controller available"
fi
SH
BT_DEV="$usb/1-6" run_reset 0
[[ $(<"$usb/port6/disable") == 0 ]] || fail "port power is restored after the cycle"
[[ $(<"$usb/1-6/reset") == 1 ]] || fail "the device is reset when the probe failed"
[[ $(<"$test_tmp/power.log") == "power on" ]] || fail "Bluetooth is powered on after recovery"
pass "a wedged controller is power-cycled and reset"

OMARCHY_USB_DEVICES_PATH="$empty" OMARCHY_APPLE_BT_PROBE_WAIT=0 PATH="$stub_bin:$PATH" "$reset"
pass "recovery no-ops when the controller is absent"

run_setup() {
  local apple_silicon="${1:-0}" has_chip="${2:-0}"
  rm -rf "$test_tmp/etc" "$test_tmp/sleep" "$test_tmp/calls.log"
  mkdir -p "$test_tmp/etc" "$test_tmp/sleep"
  : >"$test_tmp/calls.log"

  APPLE_SILICON="$apple_silicon" \
  HAS_CHIP="$has_chip" \
  TEST_LOG="$test_tmp/calls.log" \
  OMARCHY_PATH="$ROOT" \
  OMARCHY_APPLE_BT_UNIT_DST="$test_tmp/etc/omarchy-apple-broadcom-bluetooth.service" \
  OMARCHY_APPLE_BT_SLEEP_DST="$test_tmp/sleep/apple-broadcom-bluetooth" \
  PATH="$stub_bin:$PATH" \
    "$setup"
}

run_setup 1 1
[[ ! -e $test_tmp/etc/omarchy-apple-broadcom-bluetooth.service ]] ||
  fail "Apple Silicon does not get the Intel Mac unit"
pass "Apple Silicon does not get the quirk"

run_setup 0 0
[[ ! -e $test_tmp/etc/omarchy-apple-broadcom-bluetooth.service ]] ||
  fail "a machine without the chip does not get the unit"
pass "a machine without the chip does not get the quirk"

run_setup 0 1
cmp -s "$unit" "$test_tmp/etc/omarchy-apple-broadcom-bluetooth.service" ||
  fail "setup installs the boot unit"
cmp -s "$hook" "$test_tmp/sleep/apple-broadcom-bluetooth" ||
  fail "setup installs the resume hook"
grep -q $'systemctl\tenable\tomarchy-apple-broadcom-bluetooth.service' "$test_tmp/calls.log" ||
  fail "setup enables the boot unit"
printf 'admin\n' >"$test_tmp/etc/omarchy-apple-broadcom-bluetooth.service"
APPLE_SILICON=0 HAS_CHIP=1 TEST_LOG="$test_tmp/calls.log" OMARCHY_PATH="$ROOT" \
  OMARCHY_APPLE_BT_UNIT_DST="$test_tmp/etc/omarchy-apple-broadcom-bluetooth.service" \
  OMARCHY_APPLE_BT_SLEEP_DST="$test_tmp/sleep/apple-broadcom-bluetooth" \
  PATH="$stub_bin:$PATH" \
  "$setup"
[[ $(<"$test_tmp/etc/omarchy-apple-broadcom-bluetooth.service") == "admin" ]] ||
  fail "an existing unit is left for the administrator"
pass "setup installs the recovery once and leaves later edits alone"

: >"$test_tmp/calls.log"
PATH="$stub_bin:$PATH" TEST_LOG="$test_tmp/calls.log" "$hook" pre
[[ ! -s $test_tmp/calls.log ]] || fail "the resume hook ignores the pre-suspend call"
PATH="$stub_bin:$PATH" TEST_LOG="$test_tmp/calls.log" "$hook" post
grep -q $'systemctl\t--no-block\trestart\tomarchy-apple-broadcom-bluetooth.service' "$test_tmp/calls.log" ||
  fail "resume enqueues recovery instead of waiting" "$(cat "$test_tmp/calls.log")"
pass "resume enqueues recovery and does not block on it"
