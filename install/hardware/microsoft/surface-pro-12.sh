# Microsoft Surface Pro 12in (Snapdragon X Plus, x1p42100) keyboard support
# before disk unlock.

mkinitcpio_dir=${OMARCHY_SURFACE_PRO12_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree microsoft,surface-pro-12in; then
  echo "Detected Microsoft Surface Pro 12in, applying board-specific support..."

  # The keyboard works after the system boots, but needs its Surface HID and
  # Qualcomm I2C modules in the initramfs to accept the disk-unlock password.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/surface-pro-12-initramfs.conf" <<'CONF'
MODULES+=(surface_aggregator? surface_aggregator_registry? surface_hid?
  surface_hid_core? i2c_hid_of? i2c_qcom_geni? hid_multitouch?)
CONF
fi
