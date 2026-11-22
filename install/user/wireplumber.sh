# Install the WirePlumber hook that switches to USB audio devices on connect.
# The config that loads it is seeded by /etc/skel; the script itself has to
# live in WirePlumber's data dir.

mkdir -p "$HOME/.local/share/wireplumber/scripts"
cp -f "$OMARCHY_PATH/default/wireplumber/scripts/usb-audio-auto-switch.lua" \
  "$HOME/.local/share/wireplumber/scripts/"

# WirePlumber reads scripts only at startup.
systemctl --user try-restart wireplumber.service 2>/dev/null || true
