echo "Show the disk unlock prompt on the Lenovo IdeaPad Slim 5x"

# See install/hardware/lenovo/ideapad-slim-5x.sh. The prompt needs the display
# chain in the boot image, so it takes a rebuild. The drop-in alone doesn't
# show the image has it: 1794767451 runs the same setup, which writes the
# drop-in, and on the OLED model rebuilds nothing. So a machine-wide marker,
# written only after a rebuild, records that this one is done, and a retry
# after a failed rebuild runs the setup and the rebuild again.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match-device-tree lenovo,ideapad-slim5x-oled lenovo,ideapad-slim5x-lcd; then
  exit 0
fi

done_marker=/var/lib/omarchy/migrations/1794784953-done
if [[ -e $done_marker ]]; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/lenovo/ideapad-slim-5x.sh"
' || exit 1

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$done_marker"
omarchy-state set reboot-required
