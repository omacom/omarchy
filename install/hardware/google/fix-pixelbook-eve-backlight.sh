# Display backlight fix for the 2017 Google Pixelbook (Eve).
#
# Writes to intel_backlight succeed, but the panel's brightness doesn't change.
# With i915.enable_dpcd_backlight=1, i915 drives the panel's eDP DPCD (AUX)
# backlight instead, and brightness works.

if omarchy-hw-google-pixelbook-eve; then
  sudo mkdir -p /etc/limine-entry-tool.d
  sudo tee /etc/limine-entry-tool.d/google-pixelbook-eve-backlight.conf >/dev/null <<'CONF'
# Google Pixelbook (Eve) display backlight fix
KERNEL_CMDLINE[default]+=" i915.enable_dpcd_backlight=1"
CONF
fi
