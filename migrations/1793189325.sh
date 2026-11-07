echo "Add libinput quirk for Apple T2 Mac trackpads"

if ! lspci -nn | grep "106b:180[12]" >/dev/null; then
  exit 0
fi

quirks_file="${OMARCHY_T2_LIBINPUT_QUIRKS:-/etc/libinput/local-overrides.quirks}"

if [[ -f $quirks_file ]] && grep -q '\[Apple Internal Magic Trackpad (T2)\]' "$quirks_file"; then
  exit 0
fi

sudo mkdir -p "$(dirname "$quirks_file")"
sudo touch "$quirks_file"

sudo tee -a "$quirks_file" >/dev/null <<'EOF'

# Apple T2 Internal Keyboard / Trackpad
#
# The T2 internal trackpad uses the Magic Trackpad 2 architecture (hid-magicmouse)
# bridged over USB via t2bce_vhci. libinput's fallback [Apple Touchpads USB] rule
# sets AttrTouchSizeRange=150:130 (calibrated for older bcm5974 hardware). Because the
# Magic Trackpad reports touch contact sizes of 10-20, libinput 1.32+ discards
# touch and motion events as noise while clicks continue to pass.
#
# Override AttrTouchSizeRange to 20:10 matching the Apple Magic Trackpad v2 quirks.
[Apple Internal Magic Trackpad (T2)]
MatchUdevType=touchpad
MatchVendor=0x05AC
MatchName=*Apple Internal Keyboard / Trackpad*
AttrTouchSizeRange=20:10
AttrPalmPressureThreshold=190
AttrPalmSizeThreshold=900
AttrThumbSizeThreshold=800
EOF

# The compositor loads libinput quirks once, so the override applies from the next boot.
omarchy-state set reboot-required
