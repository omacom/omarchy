# Disk unlock on the ASUS Zenbook 14 UX3480QA (Snapdragon X X1-26-100).

mkinitcpio_dir=${OMARCHY_ZENBOOK_UX3480QA_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3480QA"; then
  # msm lights the panel only once both USB-C DisplayPort controllers have
  # their bridges, which come from pmic_glink's altmode through the ports' SBU
  # muxes. Without these in the initramfs the panel stays dark at the unlock
  # prompt. The ? skips a module a kernel does not have.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/zenbook-14-ux3480qa-initramfs.conf" <<'CONF'
MODULES+=(qrtr? pmic_glink_altmode? gpio_sbu_mux?)
CONF
fi
