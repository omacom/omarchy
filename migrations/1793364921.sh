echo "Give the ASUS Zenbook A16 (UX3607OA) its DSP firmware, Wi-Fi board data, text-console unlock and suspend to idle"

# See install/hardware/asus/fix-asus-zenbook-a16-firmware.sh and
# fix-asus-zenbook-a16-boot.sh.
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1793364921}"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

omarchy-pkg-add asus-zenbook-a16-firmware

# Setup kept the DSP driver off while its firmware was missing; with the
# package in place the same step now lets it start. An install from before the
# Glymur pin control and interconnect drivers joined the Qualcomm initramfs list
# gets them too. The boot settings change the initramfs and the kernel command
# line, so the image is rebuilt once. The root shell is as strict as this one,
# so a failed step keeps it pending.
sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/qualcomm/initramfs.sh"
  source "$OMARCHY_PATH/install/hardware/qualcomm/firmware.sh"
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-a16-boot.sh"
'

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
if [[ ! -e $rebuild_marker ]]; then
  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
  # That image lacks the unlock drivers, so the migration stays pending.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  sudo install -Dm644 /dev/null "$rebuild_marker"
fi

omarchy-state set reboot-required
