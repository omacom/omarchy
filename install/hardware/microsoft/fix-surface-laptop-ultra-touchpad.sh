# Touchpad quirk for the Microsoft Surface Laptop Ultra (NVIDIA N1x, ELAN
# 04F3:3358 haptic touchpad on i2c-hid).
#
# The pad advertises ABS_MT_PRESSURE 0-2048, but a resting finger reads only
# 1-40. libinput's default pressure thresholds (204:245 here) sit far above
# that, so no touch ever registers and the pointer never moves. Mark it a
# pressure pad, like the Elan 04F3:3355 and the other haptic touchpads in
# libinput's own quirks, so libinput ignores the pressure axis.
#
# libinput reads only local-overrides.quirks from /etc/libinput, so append a
# section there instead of writing a file of our own.

if omarchy-hw-match "Surface Laptop Ultra"; then
  quirks=/etc/libinput/local-overrides.quirks

  if ! grep -qxF '[Surface Laptop Ultra Touchpad]' "$quirks" 2>/dev/null; then
    mkdir -p /etc/libinput
    cat >>"$quirks" <<'QUIRKS'

[Surface Laptop Ultra Touchpad]
MatchBus=i2c
MatchUdevType=touchpad
MatchVendor=0x04F3
MatchProduct=0x3358
MatchDMIModalias=dmi:*svnMicrosoftCorporation:*pnMicrosoftSurfaceLaptopUltra*
AttrInputProp=+INPUT_PROP_PRESSUREPAD
QUIRKS
  fi
fi
