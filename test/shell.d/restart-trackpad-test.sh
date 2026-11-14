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

echo "$(basename "${!#}") $(cat)" >>"$WRITES"
SH

printf '#!/bin/bash\n' >"$stub_bin/sleep"
printf '#!/bin/bash\n' >"$stub_bin/lsmod"
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
