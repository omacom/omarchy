# Lenovo Yoga Slim 7x (14Q8X9, DMI product name 83ED) board-specific setup.

modules_load_dir=${OMARCHY_YOGA_MODULES_LOAD_DIR:-/etc/modules-load.d}
mkinitcpio_dir=${OMARCHY_YOGA_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
limine_config_dir=${OMARCHY_YOGA_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
systemd_dir=${OMARCHY_YOGA_SYSTEMD_DIR:-/etc/systemd/system}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "83ED"; then
  echo "Detected Lenovo Yoga Slim 7x, applying board-specific support..."

  # The Yoga exposes its CPU performance domains through SCMI.
  mkdir -p "$modules_load_dir"
  echo "scmi-cpufreq" >"$modules_load_dir/yoga-slim7x.conf"

  # Initialize the internal keyboard and display before disk unlock.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/yoga-slim7x-initramfs.conf" <<'CONF'
MODULES+=(i2c-hid-of qrtr ps883x pmic_glink_altmode)

# The board-signed zap shader is included by qcom-firmware-extract.
# Search like the kernel does: each suffix in every directory, then the next.
for firmware in \
  qcom/gen70500_sqe.fw \
  qcom/gen70500_gmu.bin; do
  for suffix in '' .zst .xz; do
    for directory in "${OMARCHY_YOGA_FIRMWARE_ROOT:-/usr/lib/firmware}/updates" \
      "${OMARCHY_YOGA_FIRMWARE_ROOT:-/usr/lib/firmware}"; do
      if [[ -f $directory/$firmware$suffix ]]; then
        FILES+=("$directory/$firmware$suffix")
        break 2
      fi
    done
  done
done
unset firmware directory suffix
CONF

  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/yoga-slim7x.conf" <<'CONF'
KERNEL_CMDLINE[default]+=" initcall_blacklist=simpledrm_platform_driver_init"
# Keep Plymouth and the keyboard hooks on the laptop console, not the serial port.
KERNEL_CMDLINE[default]+=" console=tty0"
CONF

  # Start the board's DSP remote processors.
  mkdir -p "$systemd_dir"
  cat >"$systemd_dir/yoga-slim7x-remoteprocs.service" <<'UNIT'
[Unit]
Description=Start the Lenovo Yoga Slim 7x DSPs
ConditionPathExists=!/etc/modprobe.d/qualcomm-adsp-nofw.conf

[Service]
Type=oneshot
ExecStart=/bin/bash /usr/share/omarchy/install/hardware/lenovo/start-yoga-slim7x-remoteprocs.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNIT
  systemctl enable yoga-slim7x-remoteprocs.service
fi
