# Disk unlock on the Lenovo IdeaCentre Mini 01Q8X10 (Snapdragon X Elite and X Plus).

mkinitcpio_dir=${OMARCHY_IDEACENTRE_MINI_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

# Both models share the chassis tree, so their display outputs are the same.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "IdeaCentre Mini 01Q8X10"; then
  # The display driver binds only when every output's chain is there, and those
  # load from the real root, so the screen stays black at the unlock prompt.
  # The USB-C port's DisplayPort needs pmic_glink and its retimer, the
  # DisplayPort socket the connector driver, and the HDMI socket the bridge
  # driver. pmic_glink stays deferred without the IPC router and PD mapper, and
  # nothing declares that dependency, so they are named too. The ? skips a
  # module a kernel does not have.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/ideacentre-mini-initramfs.conf" <<'CONF'
MODULES+=(msm? dispcc_x1e80100? gpucc_x1e80100? gpucc_x1p42100? phy_qcom_qmp_combo?
  qrtr? qcom_pd_mapper? pmic_glink? pmic_glink_altmode? ps883x? display_connector?
  simple_bridge?)

# The Adreno microcode of the X Elite and X Plus models, requested once when
# the display driver loads early. The board-signed zap shader is included by
# qcom-firmware-extract.
for firmware in qcom/gen70500_sqe.fw qcom/gen70500_gmu.bin qcom/gen71500_sqe.fw qcom/gen71500_gmu.bin; do
  for suffix in '' .zst .xz; do
    for directory in /usr/lib/firmware/updates /usr/lib/firmware; do
      if [[ -f $directory/$firmware$suffix ]]; then
        FILES+=("$directory/$firmware$suffix")
        break 2
      fi
    done
  done
done
unset firmware directory suffix
CONF
fi
