# Touchpad quirk for the ASUS ProArt P16 H7607BA (NVIDIA N1x, PixArt 093A:4F01
# haptic touchpad on i2c-hid).
#
# The pad reports each contact's force on ABS_MT_PRESSURE, in grams from 0 to
# 1000 (its HID descriptor), without declaring itself a pressure pad. libinput
# then reads the axis as contact size and starts a touch only above 12% of its
# range, 120 g, so light touches do not register. Mark it a pressure pad, as
# fix-asus-proart-p14-touchpad.sh does for the P14's 093A:4F02, so libinput
# ignores the pressure axis. Match the model number: "ProArt P16" alone would
# also match the x86 H7606 models.
#
# libinput reads only local-overrides.quirks from /etc/libinput, so append a
# section there instead of writing a file of our own.

if omarchy-hw-match "H7607BA"; then
  quirks=/etc/libinput/local-overrides.quirks

  if ! grep -qxF '[ASUS ProArt P16 Touchpad]' "$quirks" 2>/dev/null; then
    mkdir -p /etc/libinput
    cat >>"$quirks" <<'EOF'

[ASUS ProArt P16 Touchpad]
MatchBus=i2c
MatchUdevType=touchpad
MatchVendor=0x093A
MatchProduct=0x4F01
MatchDMIModalias=dmi:*svnASUS*:pn*H7607BA*
AttrInputProp=+INPUT_PROP_PRESSUREPAD
EOF
  fi
fi
