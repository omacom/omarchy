echo "Show the Samsung Galaxy Book4 Edge 14's disk unlock prompt and add its keyboard and Bluetooth support"

# See install/hardware/samsung/galaxy-book4-edge-14.sh. The initramfs hook and
# the kernel command line are in the boot image, so they take a rebuild. The
# marker records the rebuild as owed before the setup runs, so a retry rebuilds
# even when the files are already there.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match-device-tree samsung,galaxy-book4-edge-14; then
  exit 0
fi

drop_in=/etc/limine-entry-tool.d/samsung-galaxy-book4-edge-14.conf
hook=/etc/initcpio/install/samsung-galaxy-book4-edge-14
rebuild_pending=/var/lib/omarchy/migrations/1794909082-rebuild-pending
if [[ -e $rebuild_pending ]] || [[ ! -f $hook ]] ||
  ! grep -q 'usbcore.autosuspend=-1' "$drop_in" 2>/dev/null ||
  omarchy-pkg-missing samsung-galaxy-book4-edge-14-support; then
  sudo install -Dm644 /dev/null "$rebuild_pending" || exit 1
  sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
    source "$OMARCHY_PATH/install/hardware/samsung/galaxy-book4-edge-14.sh"
  '
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

  # Ask for the reboot before clearing the marker, so a run cut short in
  # between still asks on the next one.
  omarchy-state set reboot-required
  sudo rm -f "$rebuild_pending"
fi
