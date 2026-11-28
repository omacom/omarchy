# Apply package-owned udev rules for the live install session when possible.
if [[ -r $OMARCHY_PATH/default/udev/shure-mv7plus.rules ]]; then
  sudo install -Dm644 "$OMARCHY_PATH/default/udev/shure-mv7plus.rules" /etc/udev/rules.d/62-shure-mv7plus.rules
fi
sudo udevadm control --reload-rules 2>/dev/null || true
sudo udevadm trigger --subsystem-match=power_supply 2>/dev/null || true
sudo udevadm trigger --subsystem-match=hidraw 2>/dev/null || true
