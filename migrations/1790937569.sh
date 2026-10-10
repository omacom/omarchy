echo "Scroll with the Steam Deck back buttons"

if omarchy-hw-steam-deck; then
  omarchy-pkg-add python-evdev steam-devices

  # steam-devices opens /dev/uinput and the controller's hidraw node to the
  # logged-in user through udev rules. Apply them to both now so the paddle
  # reader works from the next login, not the next boot.
  sudo udevadm control --reload-rules
  sudo udevadm trigger --action=change --name-match=uinput || true
  sudo udevadm trigger --action=change --subsystem-match=hidraw || true
fi
