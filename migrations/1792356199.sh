echo "Make the Microsoft Surface Laptop Ultra (NVIDIA N1x) touchpad register touches"

# See install/hardware/microsoft/fix-surface-laptop-ultra-touchpad.sh: the
# haptic pad's pressure axis never reaches libinput's default touch threshold.
# The quirk takes effect at the next login, when the compositor reloads
# libinput.
if ! omarchy-hw-match "Surface Laptop Ultra"; then
  exit 0
fi

quirks=/etc/libinput/local-overrides.quirks

if grep -qxF '[Surface Laptop Ultra Touchpad]' "$quirks" 2>/dev/null; then
  exit 0
fi

sudo mkdir -p /etc/libinput
sudo tee -a "$quirks" >/dev/null <<'QUIRKS'

[Surface Laptop Ultra Touchpad]
MatchBus=i2c
MatchUdevType=touchpad
MatchVendor=0x04F3
MatchProduct=0x3358
MatchDMIModalias=dmi:*svnMicrosoftCorporation:*pnMicrosoftSurfaceLaptopUltra*
AttrInputProp=+INPUT_PROP_PRESSUREPAD
QUIRKS
