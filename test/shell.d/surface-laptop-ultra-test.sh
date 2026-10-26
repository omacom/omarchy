#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

boot="$ROOT/install/hardware/microsoft/fix-surface-laptop-ultra-boot.sh"
touchpad="$ROOT/install/hardware/microsoft/fix-surface-laptop-ultra-touchpad.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -lF '[Surface Laptop Ultra Touchpad]' "$ROOT"/migrations/*.sh)

for script in "$boot" "$touchpad" "$migration"; do
  bash -n "$script" || fail "$(basename "$script") parses"
done

grep -Fq 'if omarchy-hw-aarch64-n1x && omarchy-hw-match "Surface Laptop Ultra"; then' "$boot" ||
  fail "Surface Laptop Ultra boot settings are gated on the N1x model"
grep -Fq 'if omarchy-hw-match "Surface Laptop Ultra"; then' "$touchpad" ||
  fail "Surface Laptop Ultra touchpad quirk is gated on the model"
grep -Fq 'if ! omarchy-hw-match "Surface Laptop Ultra"; then' "$migration" ||
  fail "Surface Laptop Ultra touchpad migration is gated on the model"

# The rescue entry's cmdline is a plain assignment in n1x.sh's zz- drop-in, so
# the Surface drop-in must sort after it and its setup must run after n1x.sh.
[[ zz-omarchy-n1x-boot-order.conf < zz-omarchy-surface-laptop-ultra.conf ]] ||
  fail "Surface Laptop Ultra drop-in sorts after the N1x rescue entry"
n1x_line=$(grep -n 'hardware/n1x.sh"' "$all" | cut -d: -f1)
boot_line=$(grep -n 'fix-surface-laptop-ultra-boot.sh"' "$all" | cut -d: -f1)
[[ -n $n1x_line && -n $boot_line && $n1x_line -lt $boot_line ]] ||
  fail "Surface Laptop Ultra boot settings run after n1x.sh"
grep -Fq 'fix-surface-laptop-ultra-touchpad.sh"' "$all" ||
  fail "Surface Laptop Ultra touchpad quirk is wired into hardware setup"

# Both entries get the arguments, the rescue one on top of n1x.sh's.
conf=$(sed -n "/<<'CONF'/,/^CONF/p" "$boot" | sed '1d;$d')
cmdlines=$(
  declare -A KERNEL_CMDLINE=([default]="quiet" [fallback]="root=/dev/x systemd.unit=multi-user.target")
  eval "$conf"
  printf '%s\n%s\n' "${KERNEL_CMDLINE[default]}" "${KERNEL_CMDLINE[fallback]}"
)
[[ $cmdlines == $'quiet acpi_osi=! modprobe.blacklist=gpio_keys\nroot=/dev/x systemd.unit=multi-user.target acpi_osi=! modprobe.blacklist=gpio_keys' ]] ||
  fail "Surface Laptop Ultra arguments reach the default and rescue entries"

# Install and migration write the same quirk section.
quirk_of() { sed -n '/^\[Surface Laptop Ultra Touchpad\]/,/^QUIRKS/p' "$1" | sed '$d'; }
[[ -n $(quirk_of "$touchpad") && $(quirk_of "$touchpad") == "$(quirk_of "$migration")" ]] ||
  fail "Surface Laptop Ultra touchpad install and migration write the same quirk"
quirk_of "$touchpad" | grep -Fxq 'AttrInputProp=+INPUT_PROP_PRESSUREPAD' ||
  fail "Surface Laptop Ultra touchpad is marked a pressure pad"

pass "Surface Laptop Ultra hardware setup"
