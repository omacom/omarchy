#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hw="$ROOT/bin/omarchy-hw-dell-xps-ir-camera"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
acpi="$test_tmp/acpi"
leds="$test_tmp/leds"
mkdir -p "$stub_bin"

# The DMI match is its own command; stand in for it so the suite does not
# depend on the machine it runs on.
cat >"$stub_bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_DMI:-} == *"$1"* ]]
SH
chmod +x "$stub_bin/omarchy-hw-match"

reset_sysfs() {
  rm -rf "$acpi" "$leds"
  mkdir -p "$acpi" "$leds"
}

acpi_device() {
  mkdir -p "$acpi/$1"
  printf '%s\n' "$2" >"$acpi/$1/status"
}

led() {
  mkdir -p "$leds/$1"
  printf '0\n' >"$leds/$1/brightness"
}

run_hw() {
  OMARCHY_TEST_DMI="${dmi:-XPS 14 DA14260}" \
    OMARCHY_ACPI_DEVICES_PATH="$acpi" \
    OMARCHY_LEDS_PATH="$leds" \
    PATH="$stub_bin:$PATH" \
    "$hw" "$@"
}

assert_detects() {
  local description="$1"
  shift

  run_hw "$@" || fail "$description"
  pass "$description"
}

assert_rejects() {
  local description="$1"
  shift

  if run_hw "$@"; then
    fail "$description"
  fi
  pass "$description"
}

# A fitted module as the XPS 14 reports it: the sensor enabled, an unfitted
# sibling id listed with status 0, and the flood LED from the INT3472 driver.
reset_sysfs
acpi_device HIMX1092:00 15
acpi_device OVTI01AF:00 0
led "HIMX1092_00::ir_flood_led"
led "OVTI08F4_00::privacy_led"
assert_detects "an enabled HM1092 with its flood LED is detected"

dmi="Latitude 7450" assert_rejects "the same camera in a non-XPS Dell is not matched"

reset_sysfs
acpi_device HIMX1092:00 0
led "HIMX1092_00::ir_flood_led"
assert_rejects "a sensor the firmware reports absent is not detected"

reset_sysfs
acpi_device HIMX1092:00 15
assert_rejects "a sensor without its flood LED is not detected"

reset_sysfs
led "HIMX1092_00::ir_flood_led"
assert_rejects "a flood LED without the sensor is not detected"

# Like every hw- command, a predicate and nothing else: the face setup checks
# the driver and the relay device itself, at the paths the driver package owns.
metadata=$(grep '^# omarchy:' "$hw")
grep -qx '# omarchy:hidden=true' <<<"$metadata" || fail "the predicate is hidden like omarchy-hw-fingerprint" "$metadata"
! grep -qE '^# omarchy:(args|examples)=' <<<"$metadata" || fail "the predicate takes no arguments" "$metadata"
pass "the predicate is a hidden, argument-free hw- command"

reset_sysfs
acpi_device HIMX1092:00 15
led "HIMX1092_00::ir_flood_led"
assert_detects "the match holds before any camera driver is installed"
[[ -z $(run_hw 2>&1) ]] || fail "the predicate prints nothing" "$(run_hw 2>&1)"
pass "the predicate answers silently"
