# Start VMware guests at 1x. The virtual display reports a 0x0 mm physical
# size, so Hyprland's "auto" scale computes an infinite PPI and picks 2x,
# leaving a 640x400 desktop in a 1280x800 window. Only the shipped defaults
# are rewritten; a scale the user already chose stays as it is.

if omarchy-hw-vmware; then
  monitors="$HOME/.config/hypr/monitors.lua"

  if [[ -f $monitors ]] && grep -qx 'local omarchy_monitor_scale = "auto"' "$monitors"; then
    echo "Detected a VMware guest. Setting the monitor scale to 1x, since the virtual display reports no physical size."

    sed -i -E \
      -e 's|^local omarchy_monitor_scale = "auto"$|local omarchy_monitor_scale = 1|' \
      -e 's|^local omarchy_gdk_scale = 2$|local omarchy_gdk_scale = 1|' \
      "$monitors"
  fi
fi
