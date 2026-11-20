# Disk unlock on the HP OmniBook X 14 (14-fe0, Snapdragon X Elite).

mkinitcpio_dir=${OMARCHY_OMNIBOOK_X14_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

# The X Plus model and the NVIDIA N1x OmniBook X 14 report other product
# names and have not been tested.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "OmniBook X Laptop 14-fe0"; then
  # The display driver is in the image but binds only after unlock, since it
  # waits for the USB-C DisplayPort chain and the backlight, so the unlock
  # prompt stays black. Load pmic_glink's chain and the backlight drivers
  # early. pmic_glink stays deferred without the IPC router, and nothing
  # declares that dependency, so it is named too. The ? skips a module a
  # kernel does not have.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/omnibook-x14-initramfs.conf" <<'CONF'
MODULES+=(qrtr? pwm_bl? leds_qcom_lpg? qcom_pbs? pmic_glink? pmic_glink_altmode?
  ps883x? gpio_sbu_mux?)

# The Adreno X1's microcode, requested once when the display driver loads
# early. The board-signed zap shader is included by qcom-firmware-extract.
for firmware in qcom/gen70500_sqe.fw qcom/gen70500_gmu.bin; do
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
