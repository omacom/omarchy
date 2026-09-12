# Display backlight fix for Lenovo Yoga Pro 7 15IPH11 (Panther Lake / Xe3 iGPU).
#
# Lenovo's VBT specifies PWM backlight control, but the OLED panel
# (EDO EF25QBA63.B) uses DPCD AUX backlight over eDP. Without
# xe.enable_dpcd_backlight=1, brightness controls have no effect.
#
# Additionally, the OLED panel's 9-bit DPCD register overflows when written
# with max_brightness=512, dropping the screen to minimum brightness at 100%.
# Capping maximum brightness at 500 prevents the register overflow.

if omarchy-hw-match "83SN" || omarchy-hw-match "Yoga Pro 7 15IPH11"; then
  sudo mkdir -p /etc/limine-entry-tool.d
  sudo tee /etc/limine-entry-tool.d/lenovo-yoga-pro7-display-backlight.conf >/dev/null <<'EOF'
# Lenovo Yoga Pro 7 15IPH11 display backlight fix
KERNEL_CMDLINE[default]+=" xe.enable_dpcd_backlight=1"
EOF

  sudo mkdir -p /etc/omarchy
  echo "500" | sudo tee /etc/omarchy/backlight-cap >/dev/null
fi
