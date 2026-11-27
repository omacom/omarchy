echo "Stop horizontal-line display glitches on the HP ZBook Ultra G3a 16"

# See install/hardware/hp/fix-hp-zbook-ultra-g3a-display.sh.
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1795285870}"

if ! omarchy-hw-x86 || ! omarchy-hw-match "ZBook Ultra G3a 16"; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/hp/fix-hp-zbook-ultra-g3a-display.sh"
'

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
if [[ ! -e $rebuild_marker ]]; then
  # A failed rebuild leaves the kernel option out of the boot image, so the
  # migration stays pending.
  if ! sudo omarchy-boot-rebuild; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  sudo install -Dm644 /dev/null "$rebuild_marker"
  omarchy-state set reboot-required
fi
