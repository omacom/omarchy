echo "Let the DSPs start on Snapdragon machines whose root disk is on a USB-A port"

# See install/hardware/qualcomm/firmware.sh. Starting the DSPs only drops a root
# disk on the USB-C ports, so one on the USB-A ports no longer keeps them off,
# and with them USB-C, sound and the battery reading. The boot image holds the
# blacklist too, so lifting it takes a rebuild. The marker records the rebuild
# as owed before the setup can lift it, so a run cut short between the two still
# rebuilds on the next one; a machine whose disk stays on USB-C owes nothing.
if omarchy-hw-aarch64-qualcomm; then
  adsp_conf=/etc/modprobe.d/qualcomm-adsp-nofw.conf
  rebuild_pending=/var/lib/omarchy/migrations/1794593943-rebuild-pending

  if grep -qF 'attached over USB' "$adsp_conf" 2>/dev/null; then
    sudo install -Dm644 /dev/null "$rebuild_pending" || exit 1
    sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
      source "$OMARCHY_PATH/install/hardware/qualcomm/firmware.sh"
    ' || exit 1
    if grep -qF 'attached over USB' "$adsp_conf" 2>/dev/null; then
      sudo rm -f "$rebuild_pending"
    fi
  fi

  if [[ -e $rebuild_pending ]]; then
    rebuild_log=$(mktemp)
    trap 'rm -f "$rebuild_log"' EXIT
    sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"
    # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
    if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
      echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
      exit 1
    fi

    sudo rm -f "$rebuild_pending"
    omarchy-state set reboot-required
  fi
fi
