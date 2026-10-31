# ASUS Zenbook 14 (UX3480QA, Snapdragon X X1-26-100) board-specific setup.

mkinitcpio_dir=${OMARCHY_ZENBOOK_UX3480QA_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3480QA"; then
  echo "Detected ASUS Zenbook 14 UX3480QA, applying board-specific support..."

  # msm binds the panel only once both USB-C DisplayPort controllers have
  # their bridges, which need pmic_glink's altmode and its SBU muxes: without
  # them in the initramfs the panel stays dark until the disk is unlocked.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/asus-zenbook-14-ux3480qa.conf" <<'CONF'
MODULES+=(qrtr pmic_glink_altmode gpio_sbu_mux)
CONF
fi
