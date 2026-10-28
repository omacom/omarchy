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

# Rebind hid-magicmouse driver so the quirk takes effect immediately without a reboot
rebound=0
for dev in /sys/bus/hid/drivers/magicmouse/*:05AC:02[78][0-9A-Fa-f]*; do
  if [[ -d $dev ]]; then
    dev_name=$(basename "$dev")
    if echo "$dev_name" | sudo tee /sys/bus/hid/drivers/magicmouse/unbind >/dev/null 2>&1; then
      if echo "$dev_name" | sudo tee /sys/bus/hid/drivers/magicmouse/bind >/dev/null 2>&1; then
        rebound=1
      else
        echo "Error: Failed to rebind $dev_name to hid-magicmouse driver." >&2
        echo "A system reboot is required to restore trackpad input." >&2
        omarchy-state set reboot-required 2>/dev/null || true
        rebound=1
      fi
    fi
  fi
done

if (( ! rebound )); then
  omarchy-state set reboot-required 2>/dev/null || true
fi
