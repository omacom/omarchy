# Display backlight fix for Dell XPS 14/16 OLED laptops (Panther Lake / Xe3 iGPU).
#
# Same failure the ASUS Panther Lake fix covers: the VBT says PWM, but the LG
# OLED panel takes brightness over DPCD AUX. Without xe.enable_dpcd_backlight=1,
# intel_backlight sysfs writes succeed and the OSD moves, yet the panel stays
# put. The kernel says as much at boot: "[CONNECTOR:...:eDP-1] Panel is missing
# HDR static metadata ... If your backlight controls don't work try booting
# with i915.enable_dpcd_backlight=3". Confirmed on an XPS 14 DA14260 with the
# LG Display RW24G.140WT2 panel.

drop_in="${OMARCHY_DELL_XPS_OLED_BACKLIGHT_CONF:-/etc/limine-entry-tool.d/dell-xps-oled-display-backlight.conf}"

if omarchy-hw-dell-xps-oled; then
  sudo mkdir -p "$(dirname "$drop_in")"
  sudo tee "$drop_in" >/dev/null <<'EOF'
# Dell XPS OLED (Panther Lake / Xe3) display backlight fix
KERNEL_CMDLINE[default]+=" xe.enable_dpcd_backlight=1"
EOF
fi
