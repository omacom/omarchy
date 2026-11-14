# Display backlight fix for the ASUS ROG Zephyrus G16 GU605MY (Meteor Lake iGPU).
# Other GU605M variants likely share the panel but need confirmation first.
#
# The OLED panel lacks HDR static metadata, so i915 drives it through PWM and
# brightness changes have no visible effect. The driver itself suggests
# i915.enable_dpcd_backlight=3, which switches to the Intel DPCD interface.

if omarchy-hw-match "GU605MY"; then
  backlight_conf="${OMARCHY_GU605MY_BACKLIGHT_CONF:-/etc/limine-entry-tool.d/asus-gu605my-display-backlight.conf}"

  sudo mkdir -p "${backlight_conf%/*}"
  sudo tee "$backlight_conf" >/dev/null <<'EOF'
# ASUS ROG Zephyrus G16 GU605MY display backlight fix
KERNEL_CMDLINE[default]+=" i915.enable_dpcd_backlight=3"
EOF
fi
