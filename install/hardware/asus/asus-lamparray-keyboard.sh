# Allow unprivileged access to ASUS LampArray keyboards so the theme can set their color.

if omarchy-hw-asus-lamparray-keyboard; then
  sudo install -Dm644 "$OMARCHY_PATH/default/udev/asus-lamparray-keyboard.rules" /etc/udev/rules.d/61-asus-lamparray-keyboard.rules
fi
