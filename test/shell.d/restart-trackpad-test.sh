#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

restart="$ROOT/bin/omarchy-restart-trackpad"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
driver="$test_tmp/i2c_hid_acpi"
writes="$test_tmp/writes"
mkdir -p "$stub_bin"

# udev's properties for an input device, kept beside it in the fixture.
cat >"$stub_bin/udevadm" <<'SH'
#!/bin/bash

cat "${!#}/udev" 2>/dev/null
SH

# Record each privileged write as "<file> <device>" instead of touching sysfs.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

if [[ $1 == "modprobe" ]]; then
  printf '%s\n' "$*" >>"$WRITES"
  [[ $* != "${FAIL_MODPROBE:-}" ]] || exit 7
else
  echo "$(basename "${!#}") $(cat)" >>"$WRITES"
fi
SH

printf '#!/bin/bash\n' >"$stub_bin/sleep"
cat >"$stub_bin/lsmod" <<'SH'
#!/bin/bash
if [[ ${THC_LOADED:-0} == 1 ]]; then echo 'intel_quicki2c 1 0'; fi
SH
printf '#!/bin/bash\n' >"$stub_bin/omarchy-toggle-input-device"
chmod +x "$stub_bin"/*

# An I2C HID device bound to i2c_hid_acpi, with one input device and what udev
# made of it.
i2c_device() {
  mkdir -p "$driver/$1/0018:0000:0000.0001/input/input1"
  printf '%s\n' "$2" >"$driver/$1/0018:0000:0000.0001/input/input1/udev"
}

# The XPS 16 (N1x) puts its keyboard and touchscreen on i2c_hid_acpi beside the
# touchpad; resetting the trackpad must leave them bound.
i2c_device i2c-DELL06CB:00 "ID_INPUT_TOUCHPAD=1"
i2c_device i2c-HIMX5200:00 "ID_INPUT_TOUCHSCREEN=1"
i2c_device i2c-NCT9640:00 "ID_INPUT_KEYBOARD=1"

WRITES="$writes" OMARCHY_I2C_HID_DRIVER_PATH="$driver" PATH="$stub_bin:$PATH" bash "$restart" >/dev/null

expected=$'unbind i2c-DELL06CB:00\nbind i2c-DELL06CB:00'
[[ $(<"$writes") == "$expected" ]] ||
  fail "only the touchpad is unbound and rebound" "$(<"$writes")"
pass "only the touchpad is unbound and rebound"

# No bound touchpad and no THC module must fail without privileged writes.
empty_driver="$test_tmp/no-trackpad"
mkdir -p "$empty_driver"
if WRITES="$writes" OMARCHY_I2C_HID_DRIVER_PATH="$empty_driver" PATH="$stub_bin:$PATH" \
  bash "$restart" >"$test_tmp/output" 2>"$test_tmp/error"; then
  fail "a reset without a supported trackpad must fail"
fi
grep -F "No supported trackpad driver" "$test_tmp/error" >/dev/null ||
  fail "an unsupported trackpad must be explained"
[[ $(<"$writes") == "$expected" ]] || fail "unsupported hardware must not trigger privileged writes"
pass "a missing supported trackpad fails clearly without privileged writes"

for failure in "modprobe -r intel_quicki2c" "modprobe intel_quicki2c"; do
  : > "$writes"
  result=0
  WRITES="$writes" THC_LOADED=1 FAIL_MODPROBE="$failure" \
    OMARCHY_I2C_HID_DRIVER_PATH="$empty_driver" PATH="$stub_bin:$PATH" \
    bash "$restart" >"$test_tmp/output" 2>"$test_tmp/error" || result=$?
  (( result == 7 )) || fail "a failed $failure must retain its failure status"
  expected_calls="modprobe -r intel_quicki2c"
  if [[ $failure == "modprobe intel_quicki2c" ]]; then
    expected_calls+=$'\nmodprobe intel_quicki2c'
  fi
  [[ $(<"$writes") == "$expected_calls" ]] || fail "reload must stop at the failing command"
  pass "failure of $failure propagates"
done

: > "$writes"
WRITES="$writes" THC_LOADED=1 OMARCHY_I2C_HID_DRIVER_PATH="$empty_driver" \
  PATH="$stub_bin:$PATH" bash "$restart" >"$test_tmp/output"
[[ $(<"$writes") == $'modprobe -r intel_quicki2c\nmodprobe intel_quicki2c' ]] ||
  fail "a successful THC reset must unload and reload the module"
pass "a successful THC reset still succeeds"
