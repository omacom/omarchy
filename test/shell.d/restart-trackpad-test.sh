#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
drivers="$test_tmp/drivers"
mkdir -p "$stub_bin"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

exec "$@"
SH

cat >"$stub_bin/sleep" <<'SH'
#!/bin/bash
SH

cat >"$stub_bin/lsmod" <<'SH'
#!/bin/bash

printf '%s\n' ${LSMOD:-}
SH

cat >"$stub_bin/modprobe" <<'SH'
#!/bin/bash

echo "$*" >>"$MODPROBE_LOG"
[[ $* != "${MODPROBE_FAIL:-}" ]]
SH

chmod +x "$stub_bin"/*

# A driver directory as sysfs shows it, holding the named devices.
bound_devices() {
  rm -rf "$drivers"
  mkdir -p "$drivers/i2c_hid_acpi" "$drivers/elan_i2c"
  local spec
  for spec in "$@"; do
    mkdir -p "$drivers/${spec%%/*}/${spec#*/}"
  done
}

restart_trackpad() {
  PATH="$stub_bin:$PATH" OMARCHY_I2C_DRIVERS_PATH="$drivers" MODPROBE_LOG="$test_tmp/modprobe.log" \
    "$ROOT/bin/omarchy-restart-trackpad"
}

assert_rebound() {
  local driver="$1" device="$2" description="$3"

  [[ $(<"$drivers/$driver/unbind") == "$device" ]] || fail "$description: not unbound"
  [[ $(<"$drivers/$driver/bind") == "$device" ]] || fail "$description: not rebound"
  pass "$description"
}

bound_devices i2c_hid_acpi/i2c-DLL0945:00
restart_trackpad >/dev/null || fail "an i2c_hid_acpi touchpad resets successfully"
assert_rebound i2c_hid_acpi i2c-DLL0945:00 "an i2c_hid_acpi touchpad is unbound and rebound"

bound_devices elan_i2c/i2c-ELAN1000:00
restart_trackpad >/dev/null || fail "an elan_i2c touchpad resets successfully"
assert_rebound elan_i2c i2c-ELAN1000:00 "an elan_i2c touchpad is unbound and rebound"

bound_devices
rm -f "$test_tmp/modprobe.log"
LSMOD="intel_quicki2c" restart_trackpad >/dev/null || fail "a THC touchpad resets successfully"
[[ $(<"$test_tmp/modprobe.log") == $'-r intel_quicki2c\nintel_quicki2c' ]] || fail "intel_quicki2c is reloaded"
pass "a THC touchpad is reset by reloading intel_quicki2c"

bound_devices i2c_hid_acpi/i2c-DLL0945:00 elan_i2c/i2c-ELAN1000:00
restart_trackpad >/dev/null || fail "touchpads on both drivers reset successfully"
assert_rebound i2c_hid_acpi i2c-DLL0945:00 "the i2c_hid_acpi touchpad beside an elan_i2c one is rebound"
assert_rebound elan_i2c i2c-ELAN1000:00 "the elan_i2c touchpad beside an i2c_hid_acpi one is rebound"

# A directory where the sysfs file belongs makes the write fail.
for step in unbind bind; do
  bound_devices elan_i2c/i2c-ELAN1000:00
  mkdir "$drivers/elan_i2c/$step"
  if output=$(restart_trackpad 2>&1); then
    fail "a failed $step exits non-zero"
  fi
  [[ $output == *"Failed to reset i2c-ELAN1000:00"* && $output != *"Done"* ]] || fail "a failed $step says so"
  pass "a failed $step fails loudly"
done

bound_devices
for step in "-r intel_quicki2c" "intel_quicki2c"; do
  rm -f "$test_tmp/modprobe.log"
  if output=$(LSMOD="intel_quicki2c" MODPROBE_FAIL="$step" restart_trackpad 2>&1); then
    fail "a failed modprobe $step exits non-zero"
  fi
  [[ $output == *"Failed to reload intel_quicki2c"* ]] || fail "a failed modprobe $step says so"
  pass "a failed modprobe $step fails loudly"
done

bound_devices
if output=$(restart_trackpad 2>&1); then
  fail "no trackpad to reset exits non-zero"
fi
[[ $output == *"No trackpad found"* ]] || fail "no trackpad to reset says so"
pass "no trackpad to reset fails loudly"
