echo "Move monitors.lua's defaults and saved monitor scales over to the monitor panel's settings"

# Omarchy's monitor defaults now live in default/hypr/monitors.lua and the
# panel's choices are saved per monitor, so hypr/monitors.lua becomes the new
# template plus whatever else it held. The old file is kept as a backup.
omarchy-hyprland-monitor-config-upgrade
