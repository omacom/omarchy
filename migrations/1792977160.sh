echo "Make the ASUS ProArt P16 (NVIDIA N1x) touchpad register touches"

# See install/hardware/asus/fix-asus-proart-p16-touchpad.sh: libinput reads the
# haptic pad's force axis as contact size, so light touches never reach its
# touch threshold. The quirk takes effect at the next login, when the
# compositor reloads libinput.
if ! omarchy-hw-match "H7607BA"; then
  exit 0
fi

quirks=/etc/libinput/local-overrides.quirks

if grep -qxF '[ASUS ProArt P16 Touchpad]' "$quirks" 2>/dev/null; then
  exit 0
fi

sudo mkdir -p /etc/libinput
sudo tee -a "$quirks" >/dev/null <<'EOF'

[ASUS ProArt P16 Touchpad]
MatchBus=i2c
MatchUdevType=touchpad
MatchVendor=0x093A
MatchProduct=0x4F01
MatchDMIModalias=dmi:*svnASUS*:pn*H7607BA*
AttrInputProp=+INPUT_PROP_PRESSUREPAD
EOF
