echo "Make the ASUS Zenbook A16 keyboard's top row send media keys by default"

# See install/hardware/asus/fix-asus-zenbook-a16-fkeys.sh.
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1793545066}"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-a16-fkeys.sh"
'

# An administrator's own hid_asus.conf was left alone, so there is nothing to rebuild.
if ! grep -qx 'options hid_asus fnlock_default=0' /etc/modprobe.d/hid_asus.conf; then
  exit 0
fi

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
if [[ ! -e $rebuild_marker ]]; then
  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again." >&2
    exit 1
  fi

  sudo install -Dm644 /dev/null "$rebuild_marker"
fi
