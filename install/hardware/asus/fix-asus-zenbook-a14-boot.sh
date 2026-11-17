# Disk unlock on the ASUS Zenbook A14 UX3407QA (Snapdragon X Plus and X) and
# UX3407RA (Snapdragon X Elite).

mkinitcpio_dir=${OMARCHY_ZENBOOK_A14_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

# The Snapdragon X2 UX3407NA runs a Glymur tree and isn't covered.
if omarchy-hw-aarch64-qualcomm && { omarchy-hw-match "UX3407QA" || omarchy-hw-match "UX3407RA"; }; then
  # The display driver binds only when every output's chain is there, and those
  # load from the real root, so the screen stays black at the unlock prompt.
  # The panel needs its PHY and either the OLED's driver or the LCD's PWM
  # backlight, the USB-C ports' DisplayPort pmic_glink and the PS8833
  # retimers, and the HDMI socket its PS185HDM bridge and connector drivers.
  # pmic_glink stays deferred without the IPC router and PD mapper, and nothing
  # declares that dependency, so they are named too. The X Plus and X models
  # take gpucc_x1p42100, the X Elite gpucc_x1e80100. The ? skips a module a
  # kernel does not have.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/zenbook-a14-initramfs.conf" <<'CONF'
MODULES+=(msm? dispcc_x1e80100? gpucc_x1p42100? gpucc_x1e80100? phy_qcom_edp?
  panel_samsung_atna33xc20? panel_edp? pwm_bl? leds_qcom_lpg? qcom_pbs?
  phy_qcom_qmp_combo? qrtr? qcom_pd_mapper? pmic_glink? pmic_glink_altmode?
  ps883x? display_connector? simple_bridge?)

# The Adreno X1-45's and X1-85's microcode, requested once when the display
# driver loads early. The board-signed zap shader is included by
# qcom-firmware-extract.
for firmware in qcom/gen71500_sqe.fw qcom/gen71500_gmu.bin qcom/gen70500_sqe.fw qcom/gen70500_gmu.bin; do
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
