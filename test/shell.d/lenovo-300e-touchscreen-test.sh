#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/lenovo/fix-300e-touchscreen-resume.sh"
all="$ROOT/install/hardware/all.sh"
hook="$ROOT/default/systemd/system-sleep/lenovo-300e-touchscreen"

grep -q 'run_logged .*hardware/lenovo/fix-300e-touchscreen-resume.sh' "$all" ||
  fail "the 300e touchscreen quirk runs during hardware setup"
pass "the 300e touchscreen quirk runs during hardware setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
sudo_log="$test_tmp/sudo.log"

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash

[[ ${TEST_HW_MATCH:-0} == 1 ]]
SH

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$SUDO_LOG"
SH

chmod +x "$test_tmp/bin"/*

run_leaf() {
  : >"$sudo_log"
  SUDO_LOG="$sudo_log" \
    PATH="$test_tmp/bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    TEST_HW_MATCH="$1" \
    bash -eE -c 'source "$1"' bash "$leaf"
}

run_leaf 0
if [[ -s $sudo_log ]]; then
  fail "the 300e touchscreen quirk stays off other machines"
fi
pass "the 300e touchscreen quirk stays off other machines"

run_leaf 1
grep -q '/usr/lib/systemd/system-sleep/lenovo-300e-touchscreen' "$sudo_log" ||
  fail "the 300e touchscreen quirk installs the resume hook"
pass "the 300e touchscreen quirk installs the resume hook"

# Run the hook against a fake sysfs tree. The fake driver links and unlinks
# the device the way the kernel does when bind and unbind are written.
fake_sysfs="$test_tmp/sysfs"
fake_hook="$test_tmp/lenovo-300e-touchscreen"
sed 's|^  sysfs="/sys/bus/i2c"$|  sysfs="$FAKE_SYSFS"|' "$hook" >"$fake_hook"
grep -q 'sysfs="$FAKE_SYSFS"' "$fake_hook" ||
  fail "the resume hook reads sysfs from one place"

cat >"$test_tmp/bin/logger" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$LOGGER_LOG"
SH

cat >"$test_tmp/bin/sleep" <<'SH'
#!/bin/bash
SH

chmod +x "$test_tmp/bin"/*

reset_sysfs() {
  rm -rf "$fake_sysfs"
  mkdir -p "$fake_sysfs/devices/i2c-ELAN238E:00" "$fake_sysfs/devices/i2c-SYNA2392:00" \
    "$fake_sysfs/drivers/i2c_hid_acpi"
  : >"$fake_sysfs/drivers/i2c_hid_acpi/unbind"
  : >"$fake_sysfs/drivers/i2c_hid_acpi/bind"
  : >"$test_tmp/logger.log"
}

bind_device() {
  ln -s "../../devices/$1" "$fake_sysfs/drivers/i2c_hid_acpi/$1"
}

run_hook() {
  LOGGER_LOG="$test_tmp/logger.log" FAKE_SYSFS="$fake_sysfs" \
    PATH="$test_tmp/bin:$PATH" bash "$fake_hook" "$1"
}

reset_sysfs
bind_device i2c-ELAN238E:00
bind_device i2c-SYNA2392:00
run_hook pre
if [[ -s $fake_sysfs/drivers/i2c_hid_acpi/unbind || -s $test_tmp/logger.log ]]; then
  fail "the resume hook does nothing before suspend"
fi
pass "the resume hook does nothing before suspend"

run_hook post
[[ $(<"$fake_sysfs/drivers/i2c_hid_acpi/unbind") == "i2c-ELAN238E:00" ]] ||
  fail "the resume hook unbinds the touchscreen after resume"
[[ $(<"$fake_sysfs/drivers/i2c_hid_acpi/bind") == "i2c-ELAN238E:00" ]] ||
  fail "the resume hook binds the touchscreen again after resume"
grep -q 'rebound i2c-ELAN238E:00' "$test_tmp/logger.log" ||
  fail "the resume hook logs the rebind"
pass "the resume hook rebinds the ELAN238E touchscreen after resume"

# A failed bind on an earlier resume leaves the device present but unbound.
reset_sysfs
bind_device i2c-SYNA2392:00
run_hook post
[[ $(<"$fake_sysfs/drivers/i2c_hid_acpi/unbind") == "" ]] ||
  fail "the resume hook only unbinds a bound touchscreen"
[[ $(<"$fake_sysfs/drivers/i2c_hid_acpi/bind") == "i2c-ELAN238E:00" ]] ||
  fail "the resume hook binds an unbound touchscreen again"
grep -q 'rebound i2c-ELAN238E:00' "$test_tmp/logger.log" ||
  fail "the resume hook logs the retried bind"
pass "the resume hook retries a touchscreen left unbound by an earlier resume"

reset_sysfs
bind_device i2c-SYNA2392:00
rm "$fake_sysfs/drivers/i2c_hid_acpi/bind"
mkdir "$fake_sysfs/drivers/i2c_hid_acpi/bind"
run_hook post 2>/dev/null
grep -q 'failed to rebind i2c-ELAN238E:00' "$test_tmp/logger.log" ||
  fail "the resume hook logs a failed rebind"
pass "the resume hook logs a failed rebind"

reset_sysfs
bind_device i2c-SYNA2392:00
rm -rf "$fake_sysfs/devices/i2c-ELAN238E:00"
run_hook post
if [[ -s $fake_sysfs/drivers/i2c_hid_acpi/bind || -s $test_tmp/logger.log ]]; then
  fail "the resume hook skips a machine without the touchscreen"
fi
[[ -L $fake_sysfs/drivers/i2c_hid_acpi/i2c-SYNA2392:00 && ! -s $fake_sysfs/drivers/i2c_hid_acpi/unbind ]] ||
  fail "the resume hook leaves the touchpad bound"
pass "the resume hook leaves other devices alone"
