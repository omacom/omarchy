#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

write_pci() {
  rm -rf "$tmp/devices"
  mkdir -p "$tmp/devices"
  local index=0 spec slot
  for spec in "$@"; do
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$tmp/devices/$slot"
    printf '%s\n' "${spec%%:*}" >"$tmp/devices/$slot/vendor"
    printf '%s\n' "$(cut -d: -f2 <<<"$spec")" >"$tmp/devices/$slot/device"
    printf '%s\n' "${spec##*:}" >"$tmp/devices/$slot/class"
    index=$((index + 1))
  done
}

hw_t2() {
  OMARCHY_PCI_DEVICES_PATH="$tmp/devices" "$ROOT/bin/omarchy-hw-t2"
}

write_pci 0x106b:0x1801:0x068000
hw_t2 || fail "T2 chip 1801 is detected"
pass "Apple T2 device 1801 is detected from sysfs"

write_pci 0x106b:0x1802:0x068000
hw_t2 || fail "T2 chip 1802 is detected"
pass "Apple T2 device 1802 is detected from sysfs"

write_pci 0x106b:0x1803:0x068000
hw_t2 && fail "a different Apple PCI id is not a T2 chip"
pass "other Apple PCI functions are not treated as T2"

write_pci 0x8086:0x1801:0x068000
hw_t2 && fail "the device ID under a different vendor is rejected"
pass "matching device IDs under unrelated vendors are rejected"

write_pci
hw_t2 && fail "empty PCI space is not T2"
pass "a machine with no PCI devices is not T2"

mkdir -p "$tmp/bin" "$tmp/etc"
export PKGS="$tmp/pkgs" SERVICES="$tmp/services" PCI_CALLS="$tmp/pci-calls"
printf '#!/bin/bash\nprintf "%%s\n" "$@" >> "$PKGS"\n' > "$tmp/bin/omarchy-pkg-add"
printf '#!/bin/bash\nprintf "%%s\n" "$*" >> "$SERVICES"\n' > "$tmp/bin/systemctl"
printf '#!/bin/bash\necho called >> "$PCI_CALLS"\nexit 1\n' > "$tmp/bin/lspci"
chmod +x "$tmp/bin/"*
sed "s|/etc/|$tmp/etc/|g" "$ROOT/install/hardware/apple/fix-t2.sh" > "$tmp/fix-t2.sh"
sed "s|/etc/|$tmp/etc/|g" "$ROOT/install/hardware/pacman.sh" > "$tmp/pacman.sh"
run_install() {
  : > "$PKGS"
  : > "$SERVICES"
  : > "$tmp/etc/pacman.conf"
  for script in "$tmp/fix-t2.sh" "$tmp/pacman.sh"; do
    OMARCHY_PCI_DEVICES_PATH="$tmp/devices" PATH="$tmp/bin:$ROOT/bin:$PATH" \
      bash "$script" > "$tmp/output"
  done
}
write_pci 0x106b:0x1801:0x068000
run_install
[[ $(cat "$PKGS") == $'linux-t2\nlinux-t2-headers\napple-t2-audio-config\napple-bcm-firmware-fetcher\nt2fanrd' ]] || fail "T2 hardware installs its support packages"
[[ $(cat "$SERVICES") == "enable t2fanrd.service" ]] || fail "T2 fan service is enabled"
grep -qxF '[arch-mact2]' "$tmp/etc/pacman.conf" || fail "T2 repository is enabled"
[[ -f $tmp/etc/modules-load.d/t2.conf ]] || fail "T2 modules are configured"
write_pci 0x106b:0x1803:0x068000
run_install
[[ ! -s $PKGS && ! -s $SERVICES && ! -s $tmp/etc/pacman.conf && ! -e $PCI_CALLS ]] || fail "non-T2 hardware skips support and repository changes without lspci"
pass "T2 installer and repository selection follow the sysfs fixture"
