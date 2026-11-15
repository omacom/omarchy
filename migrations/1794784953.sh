echo "Show the disk unlock prompt on the Lenovo IdeaPad Slim 5x"

# See install/hardware/lenovo/ideapad-slim-5x.sh. The prompt needs the display
# chain in the boot image, so it takes a rebuild. The marker records the
# rebuild as owed before the setup writes the drop-in, so a retry rebuilds even
# when the drop-in is already there.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match-device-tree lenovo,ideapad-slim5x-oled lenovo,ideapad-slim5x-lcd; then
  exit 0
fi

drop_in=/etc/mkinitcpio.conf.d/ideapad-slim-5x-initramfs.conf
rebuild_pending=/var/lib/omarchy/migrations/1794784953-rebuild-pending
if [[ -e $rebuild_pending ]] || [[ ! -f $drop_in ]]; then
  sudo install -Dm644 /dev/null "$rebuild_pending" || exit 1
  sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
    source "$OMARCHY_PATH/install/hardware/lenovo/ideapad-slim-5x.sh"
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
