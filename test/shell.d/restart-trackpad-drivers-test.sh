#!/bin/bash
#
# The trackpad reset rebinds touchpads on each I2C driver that can own one,
# not only i2c_hid_acpi. sysfs is replaced by a scratch tree and sudo records
# what would have been written.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/drivers/i2c_hid_acpi" "$scratch/drivers/elan_i2c"
# Real driver directories also hold these entries; they must never be rebound.
touch "$scratch/drivers/"{i2c_hid_acpi,elan_i2c}/{bind,unbind,uevent}
export CALL_LOG="$scratch/calls"
export PATH="$scratch/bin:$PATH"

printf '#!/bin/bash\n[[ $1 == tee ]] && printf "%%s < %%s\\n" "$2" "$(cat)" >> "$CALL_LOG"\nexit 0\n' > "$scratch/bin/sudo"
printf '#!/bin/bash\nexit 0\n' > "$scratch/bin/sleep"
printf '#!/bin/bash\nexit 0\n' > "$scratch/bin/lsmod"
chmod +x "$scratch/bin/"*

script="$scratch/omarchy-restart-trackpad"
sed "s|/sys/bus/i2c/drivers|$scratch/drivers|g" "$ROOT/bin/omarchy-restart-trackpad" > "$script"

run_reset() {
  : > "$CALL_LOG"
  bash "$script" > "$scratch/out" 2>&1
}

mkdir "$scratch/drivers/elan_i2c/i2c-ELAN1000:00"
run_reset
[[ $(<"$CALL_LOG") == "$scratch/drivers/elan_i2c/unbind < i2c-ELAN1000:00
$scratch/drivers/elan_i2c/bind < i2c-ELAN1000:00" ]] ||
  fail "an elan_i2c touchpad is unbound and rebound" "$(<"$CALL_LOG")"
pass "an elan_i2c touchpad is unbound and rebound"

rmdir "$scratch/drivers/elan_i2c/i2c-ELAN1000:00"
mkdir "$scratch/drivers/i2c_hid_acpi/i2c-SYNA2BA6:00"
run_reset
[[ $(<"$CALL_LOG") == "$scratch/drivers/i2c_hid_acpi/unbind < i2c-SYNA2BA6:00
$scratch/drivers/i2c_hid_acpi/bind < i2c-SYNA2BA6:00" ]] ||
  fail "an i2c_hid_acpi touchpad is still unbound and rebound" "$(<"$CALL_LOG")"
pass "an i2c_hid_acpi touchpad is still unbound and rebound"

rmdir "$scratch/drivers/i2c_hid_acpi/i2c-SYNA2BA6:00"
mkdir "$scratch/drivers/elan_i2c/0-0015"
run_reset
[[ $(<"$CALL_LOG") == "$scratch/drivers/elan_i2c/unbind < 0-0015
$scratch/drivers/elan_i2c/bind < 0-0015" ]] ||
  fail "an elan_i2c SMBus touchpad named <bus>-<addr> is unbound and rebound" "$(<"$CALL_LOG")"
pass "an elan_i2c SMBus touchpad named <bus>-<addr> is unbound and rebound"
