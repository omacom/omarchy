echo "Make the ASUS ProArt P14 (NVIDIA N1x) touchpad register touches"

# See install/hardware/asus/fix-asus-proart-p14-touchpad.sh: the haptic pad's
# pressure axis never reaches libinput's default touch threshold. The quirk
# takes effect at the next login, when the compositor reloads libinput.
if ! omarchy-hw-match "H7407BA"; then
  exit 0
fi

quirks=/etc/libinput/local-overrides.quirks

if grep -qxF '[ASUS ProArt P14 Touchpad]' "$quirks" 2>/dev/null; then
  exit 0
fi

sudo mkdir -p /etc/libinput
sudo tee -a "$quirks" >/dev/null <<'EOF'

[ASUS ProArt P14 Touchpad]
MatchBus=i2c
MatchUdevType=touchpad
MatchVendor=0x093A
MatchProduct=0x4F02
MatchDMIModalias=dmi:*svnASUS*:pn*H7407BA*
AttrInputProp=+INPUT_PROP_PRESSUREPAD
EOF
