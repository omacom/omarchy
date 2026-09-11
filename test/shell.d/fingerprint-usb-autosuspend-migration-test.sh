#!/bin/bash
#
# Backfills the USB-autosuspend override onto machines that configured
# lock-screen fingerprint auth before omarchy-setup-security-fingerprint
# started writing it itself.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789133955.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/devices/1-0/power"
export CALL_LOG="$scratch/calls"
export OMARCHY_USB_DEVICES_PATH="$scratch/devices"
export OMARCHY_FINGERPRINT_UDEV_RULE_PATH="$scratch/fingerprint-no-autosuspend.rules"
export OMARCHY_LOCK_FINGERPRINT_PAM_PATH="$scratch/omarchy-lock-fingerprint"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

printf '%s\n' 27c6 >"$scratch/devices/1-0/idVendor"
printf '%s\n' 609c >"$scratch/devices/1-0/idProduct"
printf '%s\n' "Goodix Fingerprint USB Device" >"$scratch/devices/1-0/product"
printf '%s\n' auto >"$scratch/devices/1-0/power/control"

cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
case "$1" in
  tee) shift; exec tee "$@" ;;
  *) echo "Unexpected privileged call: $*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
chmod +x "$scratch/bin/"*

run_migration() {
  : > "$CALL_LOG"
  OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration"
}

# A machine that never configured lock-screen fingerprint auth has nothing to
# backfill; the real setup command writes the rule for anyone who does.
run_migration
[[ ! -f $OMARCHY_FINGERPRINT_UDEV_RULE_PATH ]] || fail "a machine without lock-screen fingerprint auth gets no rule"
[[ -z $(<"$CALL_LOG") ]] || fail "a machine without lock-screen fingerprint auth makes no privileged calls"
pass "a machine without lock-screen fingerprint auth is left alone"

touch "$OMARCHY_LOCK_FINGERPRINT_PAM_PATH"
run_migration

[[ -f $OMARCHY_FINGERPRINT_UDEV_RULE_PATH ]] || fail "an existing fingerprint lock-screen setup gets the rule backfilled"
grep -qx 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="609c", TEST=="power/control", ATTR{power/control}="on"' \
  "$OMARCHY_FINGERPRINT_UDEV_RULE_PATH" || fail "the backfilled rule names the detected reader's own IDs" "$(cat "$OMARCHY_FINGERPRINT_UDEV_RULE_PATH")"
pass "an existing fingerprint lock-screen setup gets the rule backfilled"

[[ $(<"$scratch/devices/1-0/power/control") == "on" ]] ||
  fail "the backfill switches off autosuspend on the currently plugged-in reader"
pass "the backfill switches off autosuspend on the currently plugged-in reader"

run_migration
[[ -z $(<"$CALL_LOG") ]] || fail "a rerun with the rule already in place makes no privileged calls" "$(cat "$CALL_LOG")"
pass "a rerun with the rule already in place makes no privileged calls"

# A reader matched only by product string carries no idVendor/idProduct
# guarantee; the migration must skip it rather than write a broken rule.
rm -rf "$scratch/devices"/*
mkdir -p "$scratch/devices/1-0"
printf '%s\n' "FPC Sensor Controller L:0002 FW:25.26.23.14" >"$scratch/devices/1-0/product"
rm -f "$OMARCHY_FINGERPRINT_UDEV_RULE_PATH"
run_migration
[[ ! -f $OMARCHY_FINGERPRINT_UDEV_RULE_PATH ]] || fail "no rule is backfilled when the matched device has no idVendor/idProduct"
pass "no rule is backfilled when the matched device has no idVendor/idProduct"
