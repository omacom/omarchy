echo "Install dell-xps-touchpad-haptics on Dell XPS systems with the N1x Synaptics haptic touchpad"

omarchy-hw-dell-xps-haptic-touchpad || exit 0
omarchy-pkg-missing dell-xps-touchpad-haptics || exit 0

if ! pacman -Si dell-xps-touchpad-haptics &>/dev/null; then
  echo "Waiting for dell-xps-touchpad-haptics to be published for this architecture" >&2
  exit 75
fi

omarchy-pkg-add dell-xps-touchpad-haptics
