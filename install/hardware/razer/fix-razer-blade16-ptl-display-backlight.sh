# Display backlight fix for the Razer Blade 16 RZ09-0581 (Intel Panther Lake iGPU).
# Other Blade models need confirmation first, since #8330 shows this option can
# black-screen hardware it was not verified on.
#
# xe takes the backlight type from VBT (which says PWM), but the Samsung OLED
# panel wants DPCD AUX backlight. Without xe.enable_dpcd_backlight=1,
# intel_backlight accepts writes but the panel stays at full brightness.

if omarchy-hw-match "RZ09-0581" && omarchy-hw-intel-ptl; then
  sudo mkdir -p /etc/limine-entry-tool.d
  sudo tee /etc/limine-entry-tool.d/razer-blade16-ptl-display-backlight.conf >/dev/null <<'CONF'
# Razer Blade 16 RZ09-0581 display backlight fix
KERNEL_CMDLINE[default]+=" xe.enable_dpcd_backlight=1"
CONF
fi
