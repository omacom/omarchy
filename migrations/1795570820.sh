echo "Stop the DSPs and Wi-Fi around hibernation on every Snapdragon X1 laptop, not only the Yoga Slim 7x"

omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree qcom,x1e80100 qcom,x1p42100 || exit 0
[[ ! -e /etc/systemd/system/omarchy-qualcomm-hibernate.service ]] || exit 0

# The Yoga Slim 7x had a unit of its own, which the family's replaces.
if [[ -e /etc/systemd/system/yoga-slim7x-hibernate.service ]]; then
  sudo systemctl disable yoga-slim7x-hibernate.service
  sudo rm -f /etc/systemd/system/yoga-slim7x-hibernate.service /usr/lib/systemd/system-sleep/yoga-slim7x-hibernate-recover
fi

sudo OMARCHY_PATH="$OMARCHY_PATH" bash "$OMARCHY_PATH/install/hardware/qualcomm/hibernation.sh"
sudo systemctl daemon-reload
