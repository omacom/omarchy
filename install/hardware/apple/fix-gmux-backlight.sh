# Dual-GPU MacBookPro11,3: Hyprland DPMS blanks scanout but Apple gmux PWM
# stays on, leaving a glowing black panel on idle lock, lid close, and blank.
# The NVIDIA upstream bridge's VGA-forwarding bit also drops gmux PWM writes
# until BRIDGE_CONTROL is cleared. Other dual-GPU gmux Macs need confirmation.

if omarchy-hw-match "MacBookPro11,3"; then
  echo "Detected MacBookPro11,3, applying gmux backlight PWM fix..."

  sudo mkdir -p /etc/udev/rules.d /etc/systemd/system

  sudo tee /etc/udev/rules.d/99-omarchy-gmux-backlight.rules >/dev/null <<'EOF'
# MacBookPro11,3: the seat writes gmux brightness and bl_power so lock/idle can
# turn PWM off with the panel. See install/hardware/apple/fix-gmux-backlight.sh.
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="gmux_backlight", RUN+="/bin/chmod a+w /sys/class/backlight/%k/brightness /sys/class/backlight/%k/bl_power"
EOF

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

  # udev applies the chmod on the next add; do it now so a live migration can
  # write PWM without a reboot.
  if [[ -e /sys/class/backlight/gmux_backlight/brightness ]]; then
    sudo chmod a+w /sys/class/backlight/gmux_backlight/brightness \
      /sys/class/backlight/gmux_backlight/bl_power 2>/dev/null || true
  fi
fi
