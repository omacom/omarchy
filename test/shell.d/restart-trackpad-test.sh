#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

restart="$ROOT/bin/omarchy-restart-trackpad"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
drivers="$test_tmp/drivers"
writes="$test_tmp/writes"
mkdir -p "$stub_bin"

# udev's properties for an input device, kept beside it in the fixture.
cat >"$stub_bin/udevadm" <<'SH'
#!/bin/bash

cat "${!#}/udev" 2>/dev/null
SH

# Record each privileged write as "<driver>/<file> <device>" instead of touching
# sysfs.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

echo "$(basename "$(dirname "${!#}")")/$(basename "${!#}") $(cat)" >>"$WRITES"
SH

printf '#!/bin/bash\n' >"$stub_bin/sleep"
printf '#!/bin/bash\n' >"$stub_bin/lsmod"
printf '#!/bin/bash\n' >"$stub_bin/omarchy-toggle-input-device"
chmod +x "$stub_bin"/*

# An I2C HID device bound to i2c_hid_acpi, with one input device and what udev
# made of it.
i2c_device() {
  mkdir -p "$drivers/i2c_hid_acpi/$1/0018:0000:0000.0001/input/input1"
  printf '%s\n' "$2" >"$drivers/i2c_hid_acpi/$1/0018:0000:0000.0001/input/input1/udev"
}

# elan_i2c registers its input device on the I2C device itself.
elan_device() {
  mkdir -p "$drivers/elan_i2c/$1/input/input2"
  printf '%s\n' "$2" >"$drivers/elan_i2c/$1/input/input2/udev"
}

# Real driver directories also hold these; they are never devices to rebind.
mkdir -p "$drivers/i2c_hid_acpi" "$drivers/elan_i2c"
touch "$drivers"/{i2c_hid_acpi,elan_i2c}/{bind,unbind,uevent}

# The XPS 16 (N1x) puts its keyboard and touchscreen on i2c_hid_acpi beside the
# touchpad; resetting the trackpad must leave them bound.
i2c_device i2c-DELL06CB:00 "ID_INPUT_TOUCHPAD=1"
i2c_device i2c-HIMX5200:00 "ID_INPUT_TOUCHSCREEN=1"
i2c_device i2c-NCT9640:00 "ID_INPUT_KEYBOARD=1"
# ASUS laptops often drive the touchpad with elan_i2c instead. Without an ACPI
# companion, as for the ELAN SMBus companion psmouse creates, the device is
# named <bus>-<addr>.
elan_device 0-0015 "ID_INPUT_TOUCHPAD=1"

WRITES="$writes" OMARCHY_I2C_DRIVERS_PATH="$drivers" PATH="$stub_bin:$PATH" bash "$restart" >/dev/null

expected=$'i2c_hid_acpi/unbind i2c-DELL06CB:00\ni2c_hid_acpi/bind i2c-DELL06CB:00\nelan_i2c/unbind 0-0015\nelan_i2c/bind 0-0015'
[[ $(<"$writes") == "$expected" ]] ||
  fail "only the touchpads are unbound and rebound, on either driver" "$(<"$writes")"
pass "only the touchpads are unbound and rebound, on either driver"
