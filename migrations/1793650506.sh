echo "Install the OEM firmware package for Snapdragon machines that lack their DSP and GPU firmware"

# See install/hardware/qualcomm/oem-firmware.sh. A machine installed without
# Windows to copy from has no sound, battery reading or GPU acceleration until
# its firmware is there. Installing a package rebuilds the boot image through
# mkinitcpio's hook; qualcomm/firmware.sh then runs again so the DSP driver is
# no longer held back, which needs one more rebuild.
if omarchy-hw-aarch64-qualcomm; then
  missing_before=$(qcom-firmware-extract --list-missing)
  if [[ -n $missing_before ]]; then
    sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
      source "$OMARCHY_PATH/install/hardware/qualcomm/oem-firmware.sh"
    '

    if [[ $(qcom-firmware-extract --list-missing) != "$missing_before" ]]; then
      sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
        source "$OMARCHY_PATH/install/hardware/qualcomm/firmware.sh"
      '

      rebuild_log=$(mktemp)
      trap 'rm -f "$rebuild_log"' EXIT
      sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"
      # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
      if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
        echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
        exit 1
      fi

      omarchy-state set reboot-required
    fi
  fi
fi
