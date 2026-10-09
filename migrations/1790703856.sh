echo "Preserve docked lid handling during logout and at the login screen"

sudo bash -euo pipefail "$OMARCHY_PATH/install/config/docked-lid-inhibit.sh" --start
