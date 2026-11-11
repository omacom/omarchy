echo "Unlock 120/144/240/360Hz on the Razer Blade 15 Advanced (Mid 2021) 360Hz panel"

# See install/hardware/razer/fix-razer-blade15-360hz-edid.sh, which sets up new
# installs the same way. The corrected EDID loads from the initramfs, so the
# boot image is rebuilt and the new modes appear after the next reboot.
rebuild_marker="${OMARCHY_RAZER_BLADE15_EDID_MARKER:-/var/lib/omarchy/migrations/1794330313}"

omarchy-hw-razer-blade15-360hz || exit 0

# The setup and rebuild are machine-wide: another user's migration must not repeat them.
[[ ! -e $rebuild_marker ]] || exit 0

# Plain bash would drop the runner's -e, so a failed EDID copy would still
# write boot settings naming missing firmware.
sudo OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail "$OMARCHY_PATH/install/hardware/razer/fix-razer-blade15-360hz-edid.sh"

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# That kernel's image lacks the EDID, so the migration stays pending.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"

echo "Reboot to load the corrected panel EDID, then pick a refresh rate in ~/.config/hypr/monitors.lua."
