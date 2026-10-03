# Scroll with the Steam Deck's back buttons. steam-devices lets the logged-in
# user read the controller's raw reports and write the virtual mouse wheel
# through /dev/uinput, which the paddle reader does with python-evdev.

if omarchy-hw-steam-deck; then
  omarchy-pkg-add python-evdev steam-devices
fi
