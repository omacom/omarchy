# Microsoft Surface Laptop 7 15" (Snapdragon X Elite) board-specific setup.
# The 13.8" model runs another device tree and has not been tested.

mkinitcpio_dir=${OMARCHY_SURFACE_LAPTOP7_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree microsoft,romulus15; then
  echo "Detected Microsoft Surface Laptop 7 15\", applying board-specific support..."

  # Bring up the panel and the keyboard before disk unlock. Without this the
  # unlock prompt is black and takes no keys from the built-in keyboard. As in
  # qualcomm/initramfs.sh, the ? skips a module a kernel does not have, so its
  # image still builds.
  # - The display driver waits for the USB-C DisplayPort chain, so that loads
  #   early too, with the IPC router and PD mapper pmic_glink needs.
  # - The panel is a generic eDP one lit by a PWM backlight, whose PWM comes
  #   from the PMIC's LPG block.
  # - The keyboard is a HID device behind the Surface Aggregator Module.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/surface-laptop-7-initramfs.conf" <<'CONF'
MODULES+=(msm? dispcc_x1e80100? gpucc_x1e80100? phy_qcom_edp? panel_edp?
  pwm_bl? leds_qcom_lpg? phy_qcom_qmp_combo? ps883x? qrtr? qcom_pd_mapper?
  pmic_glink? pmic_glink_altmode? surface_aggregator?
  surface_aggregator_registry? surface_hid_core? surface_hid?)

# The Adreno X1's microcode, requested once when the display driver loads
# early. The board-signed zap shader is included by qcom-firmware-extract.
# Search like the kernel does: each suffix in every directory, then the next.
for firmware in qcom/gen70500_sqe.fw qcom/gen70500_gmu.bin; do
  for suffix in '' .zst .xz; do
    for directory in "${OMARCHY_SURFACE_LAPTOP7_FIRMWARE_ROOT:-/usr/lib/firmware}/updates" \
      "${OMARCHY_SURFACE_LAPTOP7_FIRMWARE_ROOT:-/usr/lib/firmware}"; do
      if [[ -f $directory/$firmware$suffix ]]; then
        FILES+=("$directory/$firmware$suffix")
        break 2
      fi
    done
  done
done
unset firmware directory suffix
CONF

  # microsoft-surface-snapdragon-addresses gives Wi-Fi and Bluetooth the
  # laptop's own addresses: without it Wi-Fi takes a new placeholder address on
  # every boot and Bluetooth has no controller. iptsd gives the touchpad
  # two-finger scroll, pinch and two-finger tap, which the kernel alone, running
  # the pad as a mouse, does not; pressing the pad stops registering as a click.
  omarchy-pkg-add microsoft-surface-snapdragon-addresses iptsd
fi
