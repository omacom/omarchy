echo "Stop the Lenovo Yoga Slim 7x DSPs and Wi-Fi around hibernation, so it resumes"

# Existing installs predate the hibernation service the board setup installs.
omarchy-hw-aarch64-qualcomm && omarchy-hw-match "83ED" || exit 0
[[ ! -e /etc/systemd/system/yoga-slim7x-hibernate.service ]] || exit 0

sudo OMARCHY_PATH="$OMARCHY_PATH" bash "$OMARCHY_PATH/install/hardware/lenovo/yoga-slim7x.sh"
sudo systemctl daemon-reload
