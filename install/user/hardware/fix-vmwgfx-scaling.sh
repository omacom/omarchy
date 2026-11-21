# Start a guest on the SVGA adapter at 1x. Its virtual display reports a 0x0 mm
# physical size, so Hyprland's "auto" scale computes an infinite PPI and picks
# 2x, leaving a 640x400 desktop in a 1280x800 window. Only the shipped defaults
# are rewritten; a scale the user already chose stays as it is.

if omarchy-hw-vmwgfx; then
  monitors="$HOME/.config/hypr/monitors.lua"

  if [[ -f $monitors ]] && grep -qx 'local omarchy_monitor_scale = "auto"' "$monitors"; then
    echo "Detected a virtual display on vmwgfx. Setting the monitor scale to 1x, since it reports no physical size."

    sed -i -E \
      -e 's|^local omarchy_monitor_scale = "auto"$|local omarchy_monitor_scale = 1|' \
      -e 's|^local omarchy_gdk_scale = 2$|local omarchy_gdk_scale = 1|' \
      "$monitors"
  fi
fi
