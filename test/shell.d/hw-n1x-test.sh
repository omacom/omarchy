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

# hardware/n1x.sh contract: guarded by the detector, on linux-omarchy-n1x,
# console pinned, the normal entry left quiet, a maintained rescue entry with
# its own cmdline, NVIDIA kept unloaded only on pre-release firmware, and wired
# before nvidia.sh.
n1x="$ROOT/install/hardware/n1x.sh"
assert_succeeds bash -n "$n1x" "n1x.sh parses"
assert_succeeds grep -Fq 'omarchy-hw-aarch64-n1x || return 0' "$n1x" "n1x.sh is gated on the detector"
assert_succeeds grep -Fq 'omarchy-pkg-add linux-omarchy-n1x linux-omarchy-n1x-headers' "$n1x" "N1x runs linux-omarchy-n1x"
assert_fails grep -Eq 'pacman -R' "$n1x" "kernels are removed through omarchy-pkg-drop"
assert_succeeds grep -Fq 'MODULES+=(i2c_mt65xx i2c_hid_acpi)' "$n1x" "the internal keyboard works at the LUKS prompt"
assert_succeeds grep -Fq 'KERNEL_CMDLINE[default]+=" mem_sleep_default=s2idle"' "$n1x" "suspend to idle instead of the firmware's deep sleep"
assert_succeeds grep -Fq 'power_wrap_drv.usb4_release=0 pci=hpbussize=0x80,hpmmiosize=32M,hpmmioprefsize=32G' "$n1x" "USB4 host routers stay powered with room for docks"
assert_succeeds grep -Fq 'if omarchy-hw-match "H7407BA"; then' "$n1x" "the ProArt keeps the USB4 settings validated on it"
assert_succeeds grep -Fq 'KERNEL_CMDLINE[default]+=" power_wrap_drv.usb4_release=0 pci=hpbussize=0x20"' "$n1x" "other N1x laptops keep USB4 powered with the bus numbers tested on the XPS 16"
assert_succeeds grep -Fq 'ATTR{vendor}=="0x10de", ATTR{device}=="0x22cf", ATTR{power/control}="on"' "$n1x" "USB4 tunnel root ports stay awake for docks plugged in later"
assert_fails grep -Fq 'KERNEL_CMDLINE[default]+=" console=tty0' "$n1x" "the installer pins the console on every aarch64 install, not n1x.sh again"
assert_succeeds grep -Fq 'console=tty0 acpi=nospcr plymouth.enable=0' "$n1x" "the rescue entry pins the panel console itself"
assert_succeeds grep -Fq 'rescue_cmdline="$root_cmdline initramfs_async=0 ' "$n1x" "the rescue entry unpacks its initramfs before init, like every other entry"
assert_succeeds grep -Fq "'MKINITCPIO_FALLBACK=linux-omarchy-n1x'" "$n1x" "rescue entry is the hook-maintained fallback UKI"
assert_succeeds grep -Fq 'KERNEL_CMDLINE[fallback]=' "$n1x" "rescue entry has its own cmdline key"
assert_succeeds grep -Fq 'BOOT_ORDER="linux-omarchy-n1x, linux-omarchy-n1x-fallback, *, Snapshots"' "$n1x" "normal entry boots by default, rescue next"
assert_succeeds grep -Fq 'EXCLUDE_SNAPSHOT_ENTRIES="Windows*, windows*, *fallback"' "$n1x" "snapshots leave the rescue entry out"
assert_succeeds grep -Fq 'install nvidia_drm /bin/false' "$n1x" "NVIDIA stack blocked against explicit loads on pre-release firmware"
assert_succeeds grep -Fq 'options nvidia_drm modeset=1 fbdev=1' "$n1x" "GPU drives the panel on release firmware"
assert_succeeds grep -Fq 'initcall_blacklist=simpledrm_platform_driver_init' "$n1x" "firmware framebuffer dropped when the GPU owns the panel"
assert_succeeds grep -Fq 'MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' "$n1x" "early KMS on release firmware"
assert_succeeds grep -Fq '_omarchy_n1x_hooks+=(omarchy-n1x-boot-brightness)' "$n1x" "panel is lit right after plymouth for the LUKS prompt"
assert_succeeds grep -Fq 'if [[ ! $bios_version =~ ^0\. ]]; then' "$n1x" "only pre-release firmware keeps the GPU stack unloaded"
assert_fails grep -Fq 'sort -V' "$n1x" "firmware policy does not version-sort vendor strings"
assert_fails grep -Fq -- '--add-uki' "$n1x" "no one-off rescue UKI that kernel updates leave behind"
assert_fails grep -Fq 'systemctl enable' "$n1x" "the probe runs on demand, not on every boot"
assert_fails grep -Fq 'systemd-networkd.service' "$n1x" "n1x.sh does not fight network.sh over networkd"
assert_succeeds grep -Fq 'modinfo -k "$n1x_kernel_version" nvidia nvidia_modeset nvidia_uvm nvidia_drm' "$n1x" "early KMS only when DKMS built every early-loaded module"
assert_fails grep -Eq 'authorized_keys|recovery key|n1x-recovery' "$ROOT/bin/omarchy-n1x-probe" "the probe reports sshd state instead of claiming a key"
assert_fails grep -Eq 'authorized_keys|sshd' "$n1x" "remote access is left to the development ISO"
assert_succeeds grep -Fq 'Server = https://pkgs.omarchy.org/edge/$arch' "$ROOT/default/pacman/aarch64/pacman-edge.conf" "installed aarch64 systems track Omarchy edge"
all="$ROOT/install/hardware/all.sh"
n1x_line=$(grep -n 'hardware/n1x.sh' "$all" | cut -d: -f1)
nvidia_line=$(grep -n 'hardware/nvidia.sh' "$all" | cut -d: -f1)
[[ -n $n1x_line && -n $nvidia_line && $n1x_line -lt $nvidia_line ]] || fail "n1x.sh must run before nvidia.sh"
assert_succeeds grep -Fq 'if omarchy-hw-aarch64-n1x; then' "$ROOT/install/hardware/nvidia.sh" "nvidia.sh defers to the N1x policy"
hooks_conf="$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf"
assert_fails grep -Fq 'uname -m' "$hooks_conf" "initramfs hooks are the same on every architecture"
assert_fails grep -Fq 'i2c_mt65xx' "$hooks_conf" "N1x input modules stay out of the shared hooks"
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

