# NVIDIA N1x laptop (GB10-class SoC, MediaTek CPU-side peripherals; first seen
# as the Dell XPS 16 DX16263). Runs in the target chroot from
# omarchy-apply-hardware, after the settings package has dropped its Limine and
# mkinitcpio defaults and before the ISO's final limine-update builds the UKIs.

omarchy-hw-aarch64-n1x || return 0

echo "Detected NVIDIA N1x platform, applying platform configuration..."

# The ISO installs linux-omarchy-n1x through archinstall's kernels list; make
# sure its headers are present for DKMS and that no other kernel is left for
# Limine to show.
omarchy-pkg-add linux-omarchy-n1x linux-omarchy-n1x-headers
omarchy-pkg-drop linux linux-headers linux-aarch64 linux-aarch64-headers
# NVIDIA's linux-n1x preceded it. A machine still running it keeps it as its
# way back until it has booted linux-omarchy-n1x.
if [[ $(cat "/usr/lib/modules/$(uname -r)/pkgbase" 2>/dev/null) != "linux-n1x" ]]; then
  omarchy-pkg-drop linux-n1x linux-n1x-headers
fi

# The internal keyboard and touchpad are I2C-HID devices behind the MediaTek
# MT8901 I2C controllers (ACPI NVDA0200). The keyboard hook only pulls in
# drivers/hid, so add the I2C controller and I2C-HID transport to type the disk
# passphrase.
mkdir -p /etc/mkinitcpio.conf.d
cat > /etc/mkinitcpio.conf.d/omarchy-n1x-input.conf <<'CONF'
# N1x: the internal keyboard is I2C-HID behind the MediaTek I2C controllers;
# see install/hardware/n1x.sh.
MODULES+=(i2c_mt65xx i2c_hid_acpi)
CONF

# Console and rescue boot contract.
#
# The firmware publishes an ACPI SPCR serial console at 0x16a00000; without
# acpi=nospcr the kernel adopts it and the LUKS prompt and any initramfs
# emergency shell go to a UART nobody is watching. The ISO installer gives
# every aarch64 install console=tty0 acpi=nospcr (00-omarchy-console.conf). The
# normal entry otherwise boots as quietly as on x86, so Plymouth stays up from
# the LUKS prompt to the login screen; the rescue entry below is the verbose
# one. BOOT_ORDER is a plain assignment where the last file read wins, hence
# the zz- drop-in.
mkdir -p /etc/limine-entry-tool.d

# The firmware advertises PSCI system suspend, so the kernel defaults to "deep"
# sleep, but the call returns at once and the laptop wakes straight back up.
# Suspend to idle instead, as Windows does on this hardware.
cat > /etc/limine-entry-tool.d/00-omarchy-n1x-sleep.conf <<'CONF'
# N1x: the firmware's deep sleep returns at once; suspend to idle instead.
KERNEL_CMDLINE[default]+=" mem_sleep_default=s2idle"
CONF

# USB4: linux-omarchy-n1x drives the USB4 host routers (patches 1070-1081),
# which power_wrap would otherwise release once xHCI is up; the SSPM cannot
# power them again after that. The tunnel root ports are left unconfigured by
# the firmware, so reserve bus numbers and windows for docks behind them. A
# dock or adapter is approved through Omarchy's Thunderbolt authorization
# prompt, like any other accessory.
#
# The ASUS ProArt P14's settings are validated with a CalDigit TS4 on all three
# ports. Other N1x laptops (the Dell XPS 16) set aside fewer bus numbers, as
# tested there with a TS4, and do not get the root-port rule below until it is
# tested on them.
#
# The tunnel root ports (10de:22cf) cannot signal a hotplug from D3hot or
# D3cold, so once one has runtime-suspended, a PCIe tunnel that comes up behind
# it is never enumerated: the dock is authorized but its Ethernet never
# appears, until something happens to read the port's config space. Keep the
# three of them in D0.
if omarchy-hw-match "H7407BA"; then
  cat > /etc/limine-entry-tool.d/00-omarchy-n1x-usb4.conf <<'CONF'
# N1x: keep the USB4 host routers powered and leave room for docks behind them;
# see install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" power_wrap_drv.usb4_release=0 pci=hpbussize=0x80,hpmmiosize=32M,hpmmioprefsize=32G"
CONF
  cat > /etc/udev/rules.d/71-omarchy-n1x-usb4-root-ports.rules <<'RULES'
# N1x: the USB4 tunnel root ports cannot wake for a hotplug, so keep them out of
# runtime suspend; see install/hardware/n1x.sh.
ACTION=="add|bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{device}=="0x22cf", ATTR{power/control}="on"
RULES
else
  cat > /etc/limine-entry-tool.d/00-omarchy-n1x-usb4.conf <<'CONF'
# N1x: keep USB4 powered for the Thunderbolt connection manager, and leave bus
# numbers for docks. See install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" power_wrap_drv.usb4_release=0 pci=hpbussize=0x20"
CONF
fi

# Rescue entry: limine-mkinitcpio-hook builds a fallback UKI for the kernel
# (every module, no autodetect) and keeps it in step with kernel updates. It
# boots with NVIDIA blacklisted, the multi-user target and a verbose console on
# the panel. Limine passes an entry's cmdline as EFI load options and
# systemd-stub prefers those over the UKI's embedded cmdline, so the fallback
# entry gets its whole cmdline, root= included, from KERNEL_CMDLINE[fallback].
# BOOT_ORDER is a plain assignment where the last file read wins, hence the
# zz- drop-in; the snapshot entries leave the fallback out to save ESP space.
root_cmdline=$(cat /etc/kernel/cmdline 2>/dev/null || true)
if [[ -z $root_cmdline || $root_cmdline != *root=* ]]; then
  echo "Error: /etc/kernel/cmdline has no root= (Limine defaults not written yet)" >&2
  return 1
fi
rescue_cmdline="$root_cmdline initramfs_async=0 console=tty0 acpi=nospcr plymouth.enable=0 nomodeset module_blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm,nvidia_peermem,nouveau modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm,nvidia_peermem,nouveau nvidia_drm.modeset=0 systemd.unit=multi-user.target fbcon=map:0 loglevel=7 ignore_loglevel systemd.show_status=1 systemd.log_target=console vt.global_cursor_default=1"
printf '%s\n' \
  '# N1x: a text-console rescue entry sits right below the normal one; see install/hardware/n1x.sh.' \
  'MKINITCPIO_FALLBACK=linux-omarchy-n1x' \
  "KERNEL_CMDLINE[fallback]=\"$rescue_cmdline\"" \
  'EXCLUDE_SNAPSHOT_ENTRIES="Windows*, windows*, *fallback"' \
  'BOOT_ORDER="linux-omarchy-n1x, linux-omarchy-n1x-fallback, *, Snapshots"' \
  > /etc/limine-entry-tool.d/zz-omarchy-n1x-boot-order.conf

mapfile -t n1x_pkgbase_files < <(grep -lFx linux-omarchy-n1x /usr/lib/modules/*/pkgbase 2>/dev/null || true)
if (( ${#n1x_pkgbase_files[@]} != 1 )); then
  echo "Error: expected one installed linux-omarchy-n1x module tree, found ${#n1x_pkgbase_files[@]}" >&2
  return 1
fi
n1x_kernel_version=${n1x_pkgbase_files[0]#/usr/lib/modules/}
n1x_kernel_version=${n1x_kernel_version%/pkgbase}

# GPU policy, decided by the system firmware version.
#
# Dell's pre-release firmware (0.x, e.g. 0.60.1) leaves the GPU's secure boot
# unanswered: the open driver binds 10de:2e06 but cannot boot the GSP (FWSEC
# chain-of-trust timeout), and its dead render node aborts Hyprland. Keep the
# whole stack unloaded there so Hyprland renders in software on the firmware
# framebuffer. install lines also stop explicit modprobe calls (nvidia-smi,
# session start) that a blacklist alone allows.
#
# Release firmware (Dell 1.0.4 and later, ASUS H7407BA.302 and later) boots the
# GSP. There the GPU drives the panel:
# early KMS so the console and LUKS prompt land on nvidia-drm's fbdev, and
# the firmware framebuffer driver is blacklisted (as NVIDIA ships on the
# Spark) so Hyprland sees exactly one DRM device. Verified 2026-09-11:
# eDP-1 at 1920x1200@120 with nothing else configured.
bios_version=$(cat /sys/class/dmi/id/bios_version 2>/dev/null || true)
rm -f /etc/modprobe.d/nvidia.conf /etc/mkinitcpio.conf.d/nvidia.conf /etc/modprobe.d/omarchy-n1x-nvidia-disable.conf
cat > /etc/modprobe.d/omarchy-n1x-nvidiafb.conf <<'CONF'
# The legacy nvidiafb driver also claims this GPU and must never load.
blacklist nvidiafb
install nvidiafb /bin/false
CONF
n1x_gpu_driver=unloaded
if [[ ! $bios_version =~ ^0\. ]]; then
  omarchy-pkg-add nvidia-open-dkms nvidia-utils libva-nvidia-driver
  # Early KMS lists the NVIDIA modules in the initramfs, so a DKMS build that
  # failed for this kernel would fail every UKI build. Fall back to the
  # firmware framebuffer instead: a software-rendered desktop beats no boot.
  if modinfo -k "$n1x_kernel_version" nvidia nvidia_modeset nvidia_uvm nvidia_drm &>/dev/null; then
    n1x_gpu_driver=nvidia
  else
    echo "WARNING: no NVIDIA DKMS modules for $n1x_kernel_version; keeping the NVIDIA stack unloaded" >&2
  fi
else
  echo "N1x firmware $bios_version: GPU firmware cannot boot on this BIOS; keeping the NVIDIA stack unloaded"
fi
if [[ $n1x_gpu_driver == nvidia ]]; then
  echo "N1x firmware $bios_version: GPU drives the panel"
  cat > /etc/modprobe.d/nvidia.conf <<'CONF'
options nvidia_drm modeset=1 fbdev=1
CONF
  cat > /etc/mkinitcpio.conf.d/nvidia.conf <<'CONF'
MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
CONF
  printf '%s\n' \
    '# N1x on firmware >= 1.0: the GPU owns the panel; drop the firmware' \
    '# framebuffer so Hyprland sees one DRM device.' \
    'KERNEL_CMDLINE[default]+=" initcall_blacklist=simpledrm_platform_driver_init"' \
    > /etc/limine-entry-tool.d/00-omarchy-n1x-gpu.conf

  # The panel stays at its dim power-on backlight until the NVIDIA backlight
  # is first written: its DPCD brightness registers read zero and nvidia_0
  # reports 100 regardless. systemd-backlight only writes it once the root
  # filesystem is unlocked, so the LUKS prompt is nearly black. An initramfs
  # hook right after plymouth writes it first.
  mkdir -p /etc/initcpio/install /etc/initcpio/hooks
  cat > /etc/initcpio/install/omarchy-n1x-boot-brightness <<'HOOK'
#!/bin/bash

build() {
    add_runscript
}

help() {
    cat <<HELPEOF
Light the NVIDIA N1x panel for Plymouth's LUKS prompt.
HELPEOF
}
HOOK
  cat > /etc/initcpio/hooks/omarchy-n1x-boot-brightness <<'HOOK'
#!/usr/bin/ash

# The panel stays at its dim power-on backlight until the NVIDIA backlight is
# first written, which systemd-backlight only does once the root filesystem is
# unlocked. Write it here so Plymouth's LUKS prompt is readable;
# systemd-backlight restores the saved level after unlock.
run_hook() {
    if [ -w /sys/class/backlight/nvidia_0/brightness ]; then
        echo 60 > /sys/class/backlight/nvidia_0/brightness
    fi
}
HOOK
  cat > /etc/mkinitcpio.conf.d/zz-omarchy-n1x-boot-brightness.conf <<'CONF'
# N1x: light the panel for Plymouth's LUKS prompt; see install/hardware/n1x.sh.
# Sorts after omarchy_hooks.conf so HOOKS is already set.
_omarchy_n1x_hooks=()
for _omarchy_n1x_hook in "${HOOKS[@]}"; do
  _omarchy_n1x_hooks+=("$_omarchy_n1x_hook")
  [[ $_omarchy_n1x_hook == plymouth ]] && _omarchy_n1x_hooks+=(omarchy-n1x-boot-brightness)
done
HOOKS=("${_omarchy_n1x_hooks[@]}")
unset _omarchy_n1x_hooks _omarchy_n1x_hook
CONF
else
  rm -f /etc/limine-entry-tool.d/00-omarchy-n1x-gpu.conf \
    /etc/mkinitcpio.conf.d/zz-omarchy-n1x-boot-brightness.conf
  cat > /etc/modprobe.d/omarchy-n1x-nvidia-disable.conf <<'CONF'
# N1x: the NVIDIA stack cannot drive this panel here; see install/hardware/n1x.sh.
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
blacklist nvidia_uvm
install nvidia /bin/false
install nvidia_drm /bin/false
install nvidia_modeset /bin/false
install nvidia_uvm /bin/false
CONF
fi

# omarchy-n1x-probe collects hardware and boot evidence on demand, from the
# rescue entry or a running system, and uses lspci.
omarchy-pkg-add pciutils
