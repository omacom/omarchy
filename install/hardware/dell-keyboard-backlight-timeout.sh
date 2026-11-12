# Let Trigger > Hardware change how long a Dell keyboard backlight stays on.

if omarchy-hw-dell-keyboard-backlight-timeout; then
  sudo install -Dm644 "$OMARCHY_PATH/default/udev/dell-keyboard-backlight-timeout.rules" /etc/udev/rules.d/60-omarchy-dell-keyboard-backlight-timeout.rules
  sudo udevadm trigger --action=add --subsystem-match=leds --sysname-match='dell::kbd_backlight' || true
fi
