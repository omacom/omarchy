echo "Fix ASUS ExpertBook B9406 touchpad quirk (takes effect at next login)"

omarchy-hw-asus-expertbook-b9406 || exit 0

stale_quirks=/etc/libinput/asus-expertbook-b9406.quirks
dropin_quirks=/usr/share/libinput/99-omarchy-asus-b9406-touchpad.quirks

# Machine-wide, so a second user finds it applied and never needs sudo. The mask
# is the drop-in's last line, so a write cut short still counts as unapplied.
if [[ -e $stale_quirks ]] || ! grep -qsx 'AttrEventCode=-ABS_MT_PRESSURE;-ABS_PRESSURE;' "$dropin_quirks"; then
  sudo rm -f $stale_quirks
  sudo env OMARCHY_PATH="$OMARCHY_PATH" PATH="$PATH" \
    bash -euo pipefail "$OMARCHY_PATH/install/hardware/asus/fix-asus-ptl-b9406-touchpad.sh"
fi
