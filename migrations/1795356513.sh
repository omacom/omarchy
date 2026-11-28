echo "Auto-switch default audio to newly connected USB devices"

script="wireplumber/scripts/usb-audio-auto-switch.lua"
data_home=${XDG_DATA_HOME:-$HOME/.local/share}

mkdir -p "$data_home/wireplumber/scripts"
cp -f "$OMARCHY_PATH/default/$script" "$data_home/$script"

omarchy-refresh-config wireplumber/wireplumber.conf.d/usb-audio-auto-switch.conf

# WirePlumber reads conf.d and script files only at startup.
systemctl --user try-restart wireplumber.service 2>/dev/null || true
