echo "Install Keychron udev rule regardless of connected devices"

if [[ ! -f /etc/udev/rules.d/50-keychron-rgb.rules ]]; then
  sudo mkdir -p /etc/udev/rules.d
  sudo cp -f "$OMARCHY_PATH/default/udev/keychron-rgb.rules" /etc/udev/rules.d/50-keychron-rgb.rules
fi

sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=hidraw
