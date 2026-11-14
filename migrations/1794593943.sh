echo "Let the DSPs start on Snapdragon machines whose root disk is on a USB-A port"

# See install/hardware/qualcomm/firmware.sh. Starting the DSPs only drops a root
# disk on the USB-C ports, so one on the USB-A ports no longer keeps them off,
# and with them USB-C, sound and the battery reading. A marker keeps the boot
# image rebuild pending until it succeeds.
if omarchy-hw-aarch64-qualcomm; then
  adsp_conf=/etc/modprobe.d/qualcomm-adsp-nofw.conf
  pending="$HOME/.local/state/omarchy/qcom-adsp-usb-a-pending"

  if grep -qF 'attached over USB' "$adsp_conf" 2>/dev/null; then
    sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
      source "$OMARCHY_PATH/install/hardware/qualcomm/firmware.sh"
    '
    if [[ ! -f $adsp_conf ]]; then
      omarchy-state set qcom-adsp-usb-a-pending
    fi
  fi

  if [[ -f $pending ]]; then
    rebuild_log=$(mktemp)
    trap 'rm -f "$rebuild_log"' EXIT
    sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"
    # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
    if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
      echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
      exit 1
    fi

    omarchy-state set reboot-required
    omarchy-state clear qcom-adsp-usb-a-pending
  fi
fi
