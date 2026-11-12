# Disk unlock on the Acer Aspire 16 AI A16-11M (Snapdragon X X1-26-100).

mkinitcpio_dir=${OMARCHY_ASPIRE_16_AI_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

# The Aspire 14 AI A14-11M shares the tree's display outputs and has not been
# tested.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "Aspire A16-11M"; then
  # The display driver binds only when every output's chain is there, and those
  # load from the real root, so the screen stays black at the unlock prompt.
  # The panel needs its PHY and PWM backlight, the USB-C ports' DisplayPort
  # pmic_glink and the retimers, and the HDMI socket its bridge and connector
  # drivers. pmic_glink stays deferred without the IPC router and PD mapper,
  # and nothing declares that dependency, so they are named too. The ? skips a
  # module a kernel does not have.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/aspire-16-ai-initramfs.conf" <<'CONF'
MODULES+=(msm? dispcc_x1e80100? gpucc_x1p42100? phy_qcom_edp? panel_edp? pwm_bl?
  leds_qcom_lpg? qcom_pbs? phy_qcom_qmp_combo? qrtr? qcom_pd_mapper? pmic_glink?
  pmic_glink_altmode? ps883x? display_connector? simple_bridge?)

# The Adreno X1-45's microcode, requested once when the display driver loads
# early. The board-signed zap shader is included by qcom-firmware-extract.
for firmware in qcom/gen71500_sqe.fw qcom/gen71500_gmu.bin; do
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
