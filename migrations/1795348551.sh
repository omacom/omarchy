echo "Keep Panel Replay on for the HP ZBook Ultra G3a 16 display fix"

# See install/hardware/hp/fix-hp-zbook-ultra-g3a-display.sh. Migration
# 1795285870 wrote amdgpu.dcdebugmask=0x402; only the stutter bit (0x2) fixes
# the glitches, so this narrows it to 0x2. A machine that never ran that
# migration gets 0x2 from it directly, so only a drop-in still holding 0x402
# needs the rewrite and a boot image rebuild.
conf="${OMARCHY_ZBOOK_ULTRA_G3A_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}/hp-zbook-ultra-g3a-display.conf"

if [[ ! -f $conf ]] || ! grep -q 'amdgpu.dcdebugmask=0x402' "$conf"; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/hp/fix-hp-zbook-ultra-g3a-display.sh"
'

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# That image still has 0x402, so put it back and leave the migration pending.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  sudo sed -i 's/amdgpu.dcdebugmask=0x2"/amdgpu.dcdebugmask=0x402"/' "$conf"
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

omarchy-state set reboot-required
