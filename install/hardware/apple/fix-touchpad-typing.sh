# The internal bcm5974 trackpad on MacBookPro11,3 (05ac:0263) reports unknown
# USB removability. systemd's 65-integration.rules labels it external, making
# libinput's disable-while-typing unavailable despite the compositor setting.
# This hardware database override bridges the missing upstream device entry.
# Skip it when systemd or a local override already marks the trackpad internal.
macbook_touchpad_hwdb_changed=0

if ! omarchy-hw-match "^MacBookPro11,3$"; then
  return 0
fi

if systemd-hwdb query "touchpad:usb:v05acp0263:name:bcm5974:" |
  grep -Fx "ID_INPUT_TOUCHPAD_INTEGRATION=internal" >/dev/null; then
  return 0
fi

macbook_touchpad_hwdb="/etc/udev/hwdb.d/71-omarchy-macbook-touchpad.hwdb"
# Preserve administrator-authored files, including dangling symlinks.
if [[ -e $macbook_touchpad_hwdb || -L $macbook_touchpad_hwdb ]]; then
  return 0
fi

echo "Enable touchpad typing suppression on MacBookPro11,3"
sudo mkdir -p /etc/udev/hwdb.d
sudo tee "$macbook_touchpad_hwdb" >/dev/null <<'EOF'
# The built-in Apple USB trackpad is incorrectly classified as external.
touchpad:usb:v05acp0263:name:bcm5974:*
 ID_INPUT_TOUCHPAD_INTEGRATION=internal
EOF

if ! sudo systemd-hwdb update --strict; then
  # Leave a failed migration retryable instead of treating the file as applied.
  sudo rm -f "$macbook_touchpad_hwdb"
  return 1
fi

macbook_touchpad_hwdb_changed=1
