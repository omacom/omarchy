# Dual-GPU MacBookPro11,3: Hyprland DPMS blanks scanout but Apple gmux PWM
# stays on, leaving a glowing black panel on idle lock, lid close, and blank.
# The NVIDIA upstream bridge's VGA-forwarding bit also drops gmux PWM writes
# until BRIDGE_CONTROL is cleared. Other dual-GPU gmux Macs need confirmation.

if omarchy-hw-match "MacBookPro11,3"; then
  echo "Detected MacBookPro11,3, applying gmux backlight PWM fix..."

  sudo mkdir -p /etc/systemd/system

  # PWM off/on goes through brightnessctl/logind (the active seat). An earlier
  # revision world-wrote these sysfs files; drop that so other accounts cannot
  # blank the panel.
  sudo rm -f /etc/udev/rules.d/99-omarchy-gmux-backlight.rules
  if [[ -e /sys/class/backlight/gmux_backlight/brightness ]]; then
    sudo chmod 644 /sys/class/backlight/gmux_backlight/brightness \
      /sys/class/backlight/gmux_backlight/bl_power 2>/dev/null || true
  fi

  sudo tee /etc/systemd/system/omarchy-gmux-bridge.service >/dev/null <<'EOF'
[Unit]
Description=Unstick Apple gmux backlight PCI bridge (MacBookPro11,3)
After=sysinit.target
Before=display-manager.service

[Service]
Type=oneshot
ExecStart=/usr/bin/setpci -v -H1 -s 00:01.0 BRIDGE_CONTROL=0
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl enable omarchy-gmux-bridge.service
  sudo systemctl start omarchy-gmux-bridge.service 2>/dev/null || true
fi
