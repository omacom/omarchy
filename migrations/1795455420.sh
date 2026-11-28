echo "Fix Intel I219-V Ethernet boot probe failures on the Lenovo ThinkCentre M90n-1"

# See install/hardware/lenovo/fix-thinkcentre-m90n-ethernet.sh.
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1795455420}"

if ! omarchy-hw-x86 || ! omarchy-hw-match "ThinkCentre M90n-1" || ! omarchy-hw-pci --class 0200 8086:15be; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/lenovo/fix-thinkcentre-m90n-ethernet.sh"
'

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
if [[ ! -e $rebuild_marker ]]; then
  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
  # That image lacks the kernel option, so the migration stays pending.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  sudo install -Dm644 /dev/null "$rebuild_marker"
  omarchy-state set reboot-required
fi
