echo "Move NVIDIA N1x laptops to linux-omarchy-n1x and drop the bring-up scaffolding"

# See install/hardware/n1x.sh, which sets up new installs the same way.
limine_conf_dir="${OMARCHY_LIMINE_ENTRY_TOOL_DIR:-/etc/limine-entry-tool.d}"
mkinitcpio_conf_dir="${OMARCHY_MKINITCPIO_CONF_DIR:-/etc/mkinitcpio.conf.d}"
modules_dir="${OMARCHY_MODULES_DIR:-/usr/lib/modules}"
kernel_cmdline="${OMARCHY_KERNEL_CMDLINE:-/etc/kernel/cmdline}"
probe_unit="${OMARCHY_N1X_PROBE_UNIT:-/etc/systemd/system/omarchy-n1x-probe.service}"
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1791077437}"

omarchy-hw-aarch64-n1x || exit 0

# Everything below is machine-wide. The marker lets another user's run skip it,
# while a missing marker still retries an interrupted run.
[[ ! -e $rebuild_marker ]] || exit 0

omarchy-pkg-add linux-omarchy-n1x linux-omarchy-n1x-headers

mapfile -t pkgbase_files < <(grep -lFx linux-omarchy-n1x "$modules_dir"/*/pkgbase 2>/dev/null || true)
if (( ${#pkgbase_files[@]} != 1 )); then
  echo "Error: expected one installed linux-omarchy-n1x module tree, found ${#pkgbase_files[@]}" >&2
  exit 1
fi
kernel_version=${pkgbase_files[0]#"$modules_dir"/}
kernel_version=${kernel_version%/pkgbase}

# Early KMS lists the NVIDIA modules in the initramfs. Leave the boot order alone
# until DKMS has built every one of them for the new kernel.
if [[ -f $mkinitcpio_conf_dir/nvidia.conf ]] &&
  ! modinfo -k "$kernel_version" nvidia nvidia_modeset nvidia_uvm nvidia_drm &>/dev/null; then
  echo "Error: no NVIDIA DKMS modules for $kernel_version yet; run 'omarchy update' again once they build" >&2
  exit 1
fi

root_cmdline=$(sudo cat "$kernel_cmdline" 2>/dev/null || true)
if [[ $root_cmdline != *root=* ]]; then
  echo "Error: $kernel_cmdline has no root=" >&2
  exit 1
fi

sudo install -Dm644 /dev/stdin "$mkinitcpio_conf_dir/omarchy-n1x-input.conf" <<'EOF'
# N1x: the internal keyboard is I2C-HID behind the MediaTek I2C controllers;
# see install/hardware/n1x.sh.
MODULES+=(i2c_mt65xx i2c_hid_acpi)
EOF

sudo install -Dm644 /dev/stdin "$limine_conf_dir/00-omarchy-n1x-sleep.conf" <<'EOF'
# N1x: the firmware's deep sleep returns at once; suspend to idle instead.
KERNEL_CMDLINE[default]+=" mem_sleep_default=s2idle"
EOF

if omarchy-hw-match "H7407BA"; then
  sudo install -Dm644 /dev/stdin "$limine_conf_dir/00-omarchy-n1x-usb4.conf" <<'EOF'
# N1x: keep the USB4 host routers powered and leave room for docks behind them;
# see install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" power_wrap_drv.usb4_release=0 pci=hpbussize=0x80,hpmmiosize=32M,hpmmioprefsize=32G"
EOF
fi

rescue_cmdline="$root_cmdline initramfs_async=0 console=tty0 acpi=nospcr plymouth.enable=0 nomodeset module_blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm,nvidia_peermem,nouveau modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm,nvidia_peermem,nouveau nvidia_drm.modeset=0 systemd.unit=multi-user.target fbcon=map:0 loglevel=7 ignore_loglevel systemd.show_status=1 systemd.log_target=console vt.global_cursor_default=1"
printf '%s\n' \
  '# N1x: a text-console rescue entry sits right below the normal one; see install/hardware/n1x.sh.' \
  'MKINITCPIO_FALLBACK=linux-omarchy-n1x' \
  "KERNEL_CMDLINE[fallback]=\"$rescue_cmdline\"" \
  'EXCLUDE_SNAPSHOT_ENTRIES="Windows*, windows*, *fallback"' \
  'BOOT_ORDER="linux-omarchy-n1x, linux-omarchy-n1x-fallback, *, Snapshots"' |
  sudo install -Dm644 /dev/stdin "$limine_conf_dir/zz-omarchy-n1x-boot-order.conf"

# The probe now runs on demand.
if [[ -f $probe_unit ]]; then
  sudo systemctl disable "$(basename "$probe_unit")" 2>/dev/null || true
  sudo rm -f "$probe_unit"
  sudo systemctl daemon-reload
fi

# Free the ESP before the fallback UKI is built: the one-off rescue UKI goes,
# and so does linux-n1x unless this boot is still running it.
sudo limine-entry-tool --remove-uki linux-n1x-rescue --quiet 2>/dev/null || true
if [[ $(cat "$modules_dir/$(uname -r)/pkgbase" 2>/dev/null) != "linux-n1x" ]]; then
  omarchy-pkg-drop linux-n1x linux-n1x-headers
else
  echo "linux-n1x stays installed until this machine has booted linux-omarchy-n1x; remove it then with: omarchy-pkg-drop linux-n1x linux-n1x-headers"
fi

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
