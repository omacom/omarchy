echo "Keep Panel Replay on for the HP ZBook Ultra G3a 16 display fix"

# See install/hardware/hp/fix-hp-zbook-ultra-g3a-display.sh. Migration
# 1795285870 wrote amdgpu.dcdebugmask=0x402; only the stutter bit (0x2) fixes
# the glitches, so the leaf now writes 0x2. The drop-in's contents can't tell
# whether the boot image has caught up: 1795285870 skips its rebuild for a
# second user and writes 0x2 without rebuilding. So this rebuilds once per
# machine on its own marker, which is only set after the rebuild succeeds.
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1795348551}"

if ! omarchy-hw-x86 || ! omarchy-hw-match "ZBook Ultra G3a 16"; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/hp/fix-hp-zbook-ultra-g3a-display.sh"
'

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries a failed or interrupted rebuild.
if [[ ! -e $rebuild_marker ]]; then
  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
  # That image keeps the old option, so the migration stays pending.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  sudo install -Dm644 /dev/null "$rebuild_marker"
  omarchy-state set reboot-required
fi
