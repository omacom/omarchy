# Disk unlock on the Snapdragon X machines: Hamoa (X Elite and the larger X
# Plus) and Purwa (the 8-core X Plus and X). Every one of their device trees
# ends in one of the two SoC names.

mkinitcpio_dir=${OMARCHY_QUALCOMM_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree qcom,x1e80100 qcom,x1p42100; then
  # The display driver binds only when every output's chain is there, and those
  # drivers load from the real root, so the screen stays black at the unlock
  # prompt. Model after model needed the same set named, so it is named once:
  # - the display and GPU clocks (Hamoa takes gpucc_x1e80100, Purwa
  #   gpucc_x1p42100), the panel's PHY, and the OLED's driver or the LCD's with
  #   its PWM backlight, whose PWM comes from the PMIC's LPG block;
  # - the USB-C ports' DisplayPort chain: pmic_glink with the IPC router and PD
  #   mapper it stays deferred without, the combo PHY, the PS883x retimers, the
  #   SBU mux and the eUSB2 repeater;
  # - an HDMI socket's bridge and connector drivers.
  # As in initramfs.sh, the ? skips a module a kernel or a model does not have,
  # so its image still builds. A model's own setup adds what only it has, like
  # the Surface keyboard.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/qualcomm-hamoa-display.conf" <<'CONF'
MODULES+=(msm? dispcc_x1e80100? gpucc_x1e80100? gpucc_x1p42100? phy_qcom_edp?
  panel_edp? panel_samsung_atna33xc20? pwm_bl? leds_qcom_lpg? qcom_pbs?
  phy_qcom_qmp_combo? qrtr? qcom_pd_mapper? pmic_glink? pmic_glink_altmode?
  ps883x? gpio_sbu_mux? phy_nxp_ptn3222? display_connector? simple_bridge?)

# The Adreno X1-85's and X1-45's microcode, requested once when the display
# driver loads early. The board-signed zap shader is included by
# qcom-firmware-extract. Search like the kernel does: each suffix in every
# directory, then the next.
for firmware in qcom/gen70500_sqe.fw qcom/gen70500_gmu.bin qcom/gen71500_sqe.fw qcom/gen71500_gmu.bin; do
  for suffix in '' .zst .xz; do
    for directory in "${OMARCHY_QUALCOMM_FIRMWARE_ROOT:-/usr/lib/firmware}/updates" \
      "${OMARCHY_QUALCOMM_FIRMWARE_ROOT:-/usr/lib/firmware}"; do
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
