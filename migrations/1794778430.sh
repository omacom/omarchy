echo "Keep the Samsung Galaxy Book4 Edge 14 from sleeping the AOSS"

# See install/hardware/samsung/galaxy-book4-edge-14.sh. The kernel command line
# is in the boot image, so it takes a rebuild. The marker records the rebuild as
# owed before the setup writes the drop-in, so a retry rebuilds even when the
# drop-in is already there.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match-device-tree samsung,galaxy-book4-edge-14; then
  exit 0
fi

drop_in=/etc/limine-entry-tool.d/samsung-galaxy-book4-edge-14.conf
rebuild_pending=/var/lib/omarchy/migrations/1794778430-rebuild-pending
if [[ -e $rebuild_pending ]] || ! grep -q 'qcom_aoss.prevent_aoss_sleep=1' "$drop_in" 2>/dev/null; then
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

  sudo rm -f "$rebuild_pending"
  omarchy-state set reboot-required
fi
