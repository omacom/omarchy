echo "Install the OEM firmware package on Snapdragon machines that have one"

# See install/hardware/qualcomm/oem-firmware.sh. A machine installed without
# Windows has no sound, battery reading or GPU acceleration until its firmware
# is there, and one set up from Windows moves to the package's known set.
# Installing a package rebuilds the boot image through mkinitcpio's hook, and
# qcom-firmware-extract's retire hook removes the Windows copies the package
# covers. qualcomm/firmware.sh then runs again so the DSP driver is no longer
# held back, which needs one more rebuild.
#
# Once a package is in, a rerun no longer sees the package list change, so a
# marker keeps the firmware setup and the rebuild pending until both finish.
if omarchy-hw-aarch64-qualcomm; then
  pending="$HOME/.local/state/omarchy/qcom-oem-firmware-pending"
  packages_before=$(pacman -Qq)
  status=0
  bash -euo pipefail -c 'source "$OMARCHY_PATH/install/hardware/qualcomm/oem-firmware.sh"' || status=$?

  if [[ $(pacman -Qq) != "$packages_before" ]]; then
    omarchy-state set qcom-oem-firmware-pending
  fi

  if ((status != 0)); then
    exit "$status"
  elif [[ -f $pending ]]; then
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
    omarchy-state clear qcom-oem-firmware-pending
  fi
fi
