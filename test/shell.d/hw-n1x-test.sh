#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# base-test.sh offers pass/fail; wrap them into command-level assertions.
assert_succeeds() {
  local description="${@: -1}"
  if "${@:1:$#-1}" >/dev/null 2>&1; then pass "$description"; else fail "$description"; fi
}
assert_fails() {
  local description="${@: -1}"
  if "${@:1:$#-1}" >/dev/null 2>&1; then fail "$description"; else pass "$description"; fi
}

# omarchy-hw-aarch64-n1x asks omarchy-hw-platform, which reads a fixture sysfs
# root when one is named (never as root) and refuses any machine that is not
# aarch64.
write_sysfs() {
  rm -rf "$tmp_dir/sys"
  mkdir -p "$tmp_dir/sys/bus/acpi/devices" "$tmp_dir/sys/bus/pci/devices"
  local acpi_id
  for acpi_id in $1; do
    mkdir -p "$tmp_dir/sys/bus/acpi/devices/$acpi_id"
  done
  local index=0 spec
  for spec in $2; do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$tmp_dir/sys/bus/pci/devices/$slot"
    printf '%s\n' "${spec%%:*}" >"$tmp_dir/sys/bus/pci/devices/$slot/vendor"
    printf '%s\n' "${spec##*:}" >"$tmp_dir/sys/bus/pci/devices/$slot/device"
    index=$((index + 1))
  done
}

hw_n1x() {
  # Pretend to be aarch64 by shadowing uname on PATH.
  local shim="$tmp_dir/bin"
  mkdir -p "$shim"
  printf '#!/bin/bash\n[[ ${1:-} == -m ]] && { echo aarch64; exit 0; }\nexec /usr/bin/uname "$@"\n' >"$shim/uname"
  chmod +x "$shim/uname"
  PATH="$shim:$ROOT/bin:$PATH" OMARCHY_SYS_ROOT="$tmp_dir/sys" "$ROOT/bin/omarchy-hw-aarch64-n1x" 2>/dev/null
}

if [[ $(uname -m) != aarch64 ]]; then
  assert_fails "$ROOT/bin/omarchy-hw-aarch64-n1x" "non-aarch64 host is never N1x"
fi

# Root reads the live machine, never a fixture.
if (( EUID != 0 )); then
write_sysfs "NVDA0200:00 NVDA0200:03 ARML0002:00" ""
assert_succeeds hw_n1x "MediaTek I2C controllers (NVDA0200) identify N1x"

write_sysfs "PNP0C0D:00" "0x10de:0x2e06"
assert_succeeds hw_n1x "GB20B GPU 10de:2e06 identifies N1x"

write_sysfs "PNP0C0D:00 NVDA0301:00" "0x10de:0x2e12"
assert_fails hw_n1x "a Spark (2e12, Tegra I2C ids) is not N1x"

write_sysfs "" "0x8086:0x1234"
assert_fails hw_n1x "an unrelated machine is not N1x"
fi

hooks_conf="$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf"
# mkinitcpio sources the platform's HOOKS baseline before the adjustments.
hooks_have_plymouth() {
  (
    HOOKS=()
    MODULES=()
    OMARCHY_PCI_DEVICES_PATH="$tmp_dir/pci"
    source "$ROOT/etc/mkinitcpio.conf.d/00-omarchy-hooks.conf"
    source "$hooks_conf"
    [[ " ${HOOKS[*]} " == *" plymouth "* ]]
  )
}
assert_succeeds hooks_have_plymouth "Plymouth stays in the initramfs"
