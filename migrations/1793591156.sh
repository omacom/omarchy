echo "Make the Dell G15 5530 touchpad bind at boot"

# See install/hardware/dell-g15-touchpad.sh.
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1793591156}"

if ! omarchy-hw-x86 || ! omarchy-hw-match "G15 5530"; then
  exit 0
fi

# A marker records the machine-wide repair: another user's run must do nothing,
# while a missing marker still retries an interrupted rebuild.
if [[ -e $rebuild_marker ]]; then
  exit 0
fi

source "$OMARCHY_PATH/install/hardware/dell-g15-touchpad.sh"

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
omarchy-state set reboot-required
