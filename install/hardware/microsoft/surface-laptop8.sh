# Microsoft Surface Laptop 8 (13.8-inch, Snapdragon X2 Elite) board-specific setup.

mkinitcpio_dir=${OMARCHY_SURFACE_LAPTOP8_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree microsoft,surface-laptop-8-13p8; then
  echo "Detected Microsoft Surface Laptop 8, applying board-specific support..."

  # Bring up the panel and the keyboard before disk unlock. As in
  # qualcomm/initramfs.sh, the ? skips a module a kernel does not have, so its
  # image still builds.
  # - msm needs the GPU and its clock and power controllers before the panel
  #   comes up, and none of these is a module dependency of it.
  # - The display waits for the pmic_glink alternate-mode bridges and the USB4
  #   host mux, which thunderbolt_qcom registers from linux-omarchy 7.3-5 (in
  #   thunderbolt before that); the panel waits for its PWM backlight.
  # - pmic_glink runs on the SOCCP, which the boot firmware starts and
  #   qcom_q6v5_pas attaches to. Unlike the Surface Pro 11, the panel needs it,
  #   so it is listed here. firmware.sh's blacklist for a USB root disk still
  #   applies in the initramfs, so with the root disk on USB the panel has no
  #   pmic_glink at disk unlock.
  # - The keyboard is a HID device behind the Surface Aggregator Module.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/surface-laptop8-initramfs.conf" <<'CONF'
MODULES+=(msm? panel_edp? phy_qcom_edp? gpucc_glymur? gxclkctl_kaanapali?
  qrtr? qcom_q6v5_pas? thunderbolt? thunderbolt_qcom? thunderbolt_platform? pmic_glink? pmic_glink_altmode?
  ucsi_glink? leds_qcom_lpg? pwm_bl? surface_aggregator? surface_aggregator_registry?
  surface_hid_core? surface_hid? nvme?)

# qcom_q6v5_pas starts the ADSP and CDSP from the initramfs and does not retry
# once the root filesystem is up, so their firmware, which qcom-firmware-extract
# copies from Windows, goes in the image too. msm requests the GPU's startup
# pair when the display starts but declares no firmware for this GPU.
# Search like the kernel does: each suffix in every directory, then the next.
for firmware in \
  qcom/gen80100_sqe.fw \
  qcom/gen80100_gmu.bin \
  qcom/glymur/microsoft/surface-laptop8/qcadsp8480.mbn \
  qcom/glymur/microsoft/surface-laptop8/adsp_dtbs.elf \
  qcom/glymur/microsoft/surface-laptop8/qccdsp8480.mbn \
  qcom/glymur/microsoft/surface-laptop8/cdsp_dtbs.elf; do
  for suffix in '' .zst .xz; do
    for directory in "${OMARCHY_SURFACE_LAPTOP8_FIRMWARE_ROOT:-/usr/lib/firmware}/updates" \
      "${OMARCHY_SURFACE_LAPTOP8_FIRMWARE_ROOT:-/usr/lib/firmware}"; do
      if [[ -f $directory/$firmware$suffix ]]; then
        FILES+=("$directory/$firmware$suffix")
        break 2
      fi
    done
  done
done
unset firmware directory suffix
CONF

  # Wi-Fi board data, audio, the device tree's hardware ID, sleep and touchpad.
  omarchy-pkg-add surface-laptop-8-support

  # USB4 docks: the router firmware is copied out of the Windows USB4 driver;
  # thunderbolt_qcom declares it, so mkinitcpio adds it to the image. Without
  # Windows on the disk it is not found and USB4 stays off.
  surface-laptop8-usb4-firmware --no-rebuild || true
fi
