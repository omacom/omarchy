# ASUS Zenbook A16 (UX3607OA / glymur) board-specific setup.

zenbook_a16_compatible=""
compatible_path=${OMARCHY_ZENBOOK_COMPATIBLE_PATH:-/sys/firmware/devicetree/base/compatible}
modules_load_dir=${OMARCHY_ZENBOOK_MODULES_LOAD_DIR:-/etc/modules-load.d}
mkinitcpio_dir=${OMARCHY_ZENBOOK_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
limine_config_dir=${OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
systemd_dir=${OMARCHY_ZENBOOK_SYSTEMD_DIR:-/etc/systemd/system}

if [[ -r $compatible_path ]]; then
  zenbook_a16_compatible=$(tr '\0' '\n' <"$compatible_path")
fi

if omarchy-hw-aarch64-qualcomm &&
  { grep -qiE '^(asus,zenbook-a16-ux3607oa|asus,ux3607oa)$' <<<"$zenbook_a16_compatible" ||
    omarchy-hw-match 'UX3607OA'; }; then
  echo "Detected ASUS Zenbook A16 UX3607OA, applying board-specific support..."

  # The Zenbook A16 exposes its CPU performance domains through SCMI.
  mkdir -p "$modules_load_dir"
  echo "scmi-cpufreq" >"$modules_load_dir/zenbook-a16.conf"

  # Initialize the keyboard, embedded controller, and display before disk unlock.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/zenbook-a16-initramfs.conf" <<'CONF'
# The EC driver is still landing upstream; '?' keeps stock kernels buildable.
MODULES+=(hid-asus asus_glymur_ec? i2c-hid-of qrtr ps883x pmic_glink_altmode)

# The board-signed zap shader is included by qcom-firmware-extract.
for firmware in \
  qcom/gen70500_sqe.fw \
  qcom/gen70500_gmu.bin \
  qcom/gen80100_sqe.fw \
  qcom/gen80100_gmu.bin; do
  for suffix in '' .zst .xz; do
    for directory in "${OMARCHY_ZENBOOK_FIRMWARE_ROOT:-/usr/lib/firmware}/updates" \
      "${OMARCHY_ZENBOOK_FIRMWARE_ROOT:-/usr/lib/firmware}"; do
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
  cat >"$limine_config_dir/zenbook-a16.conf" <<'CONF'
# Keep display and power domains alive; skip suspend-breaking PCI bridge 5; mask TPM lockups.
KERNEL_CMDLINE[default]+=" glymur_pci_skip=5 console=tty0 panic=10 systemd.mask=dev-tpm0.device systemd.mask=dev-tpmrm0.device plymouth.enable=0 systemd.show_status=true vt.global_cursor_default=1"
CONF

  # Start the board's DSP remote processors.
  mkdir -p "$systemd_dir"
  cat >"$systemd_dir/zenbook-a16-remoteprocs.service" <<'UNIT'
[Unit]
Description=Start the ASUS Zenbook A16 DSPs
ConditionPathExists=!/etc/modprobe.d/qualcomm-adsp-nofw.conf

[Service]
Type=oneshot
ExecStart=/bin/bash /usr/share/omarchy/install/hardware/asus/start-zenbook-a16-remoteprocs.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNIT
  systemctl enable zenbook-a16-remoteprocs.service

  # The mkinitcpio and Limine drop-ins above must be reflected in the boot
  # artifacts before the first reboot, otherwise the internal keyboard,
  # display firmware and board kernel parameters are missing at disk unlock.
fi
