echo "Stop the DSPs and Wi-Fi around hibernation on every Snapdragon X1 laptop, not only the Yoga Slim 7x"

omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree qcom,x1e80100 qcom,x1p42100 || exit 0

unit=/etc/systemd/system/omarchy-qualcomm-hibernate.service
hook=/usr/lib/systemd/system-sleep/omarchy-qualcomm-hibernate-recover

# Set up means the unit, enabled, and the hook that stops it after a failed
# hibernation. A run that stopped half way does the rest on the next try.
set_up() {
  [[ -f $unit && -x $hook ]] && systemctl is-enabled --quiet omarchy-qualcomm-hibernate.service
}

if set_up && [[ ! -e /etc/systemd/system/yoga-slim7x-hibernate.service ]]; then
  exit 0
fi

# The hook comes with omarchy-settings, which can land after this package.
# Until it has, this stays pending.
if [[ ! -f $OMARCHY_PATH/default/systemd/system-sleep/omarchy-qualcomm-hibernate-recover ]]; then
  echo "Waiting for the omarchy-settings package that ships the Snapdragon X1 hibernation hook" >&2
  exit 75
fi

# The Yoga Slim 7x had a unit of its own, which the family's replaces.
if [[ -e /etc/systemd/system/yoga-slim7x-hibernate.service ]]; then
  sudo systemctl disable yoga-slim7x-hibernate.service
  sudo rm -f /etc/systemd/system/yoga-slim7x-hibernate.service /usr/lib/systemd/system-sleep/yoga-slim7x-hibernate-recover
fi

# Under errexit, as the installer runs it, so a failed step stops here.
sudo OMARCHY_PATH="$OMARCHY_PATH" bash -e "$OMARCHY_PATH/install/hardware/qualcomm/hibernation.sh"
sudo systemctl daemon-reload

if ! set_up; then
  echo "The Snapdragon X1 hibernation unit isn't fully set up yet" >&2
  exit 1
fi
