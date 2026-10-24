# Touchpad quirk for the ASUS ProArt P14 H7407BA (NVIDIA N1x, PixArt 093A:4F02
# haptic touchpad on i2c-hid).
#
# The pad reports ABS_MT_PRESSURE as force in small physical units (a resting
# finger reads 0-150) on a 0-65535 logical range. libinput's default pressure
# thresholds sit at 10-12% of that range, so no touch ever registers and the
# touchpad does nothing. Mark it a pressure pad, like the other PixArt haptic
# touchpads in libinput's own quirks, so libinput ignores the pressure axis.
#
# libinput reads only local-overrides.quirks from /etc/libinput, so append a
# section there instead of writing a file of our own.

if omarchy-hw-match "H7407BA"; then
  quirks=/etc/libinput/local-overrides.quirks

  if ! grep -qxF '[ASUS ProArt P14 Touchpad]' "$quirks" 2>/dev/null; then
    mkdir -p /etc/libinput
    cat >>"$quirks" <<'EOF'

[ASUS ProArt P14 Touchpad]
MatchBus=i2c
MatchUdevType=touchpad
MatchVendor=0x093A
MatchProduct=0x4F02
MatchDMIModalias=dmi:*svnASUS*:pn*H7407BA*
AttrInputProp=+INPUT_PROP_PRESSUREPAD
EOF
  fi
fi
