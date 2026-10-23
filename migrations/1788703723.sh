echo "Wire up the Bluetooth A2DP ACL-priority fix for existing installs"

: "${OMARCHY_PATH:=/usr/share/omarchy}"
: "${OMARCHY_INSTALL:=$OMARCHY_PATH/install}"
# shellcheck source=../install/hardware/apple/bt-a2dp-priority.sh
source "$OMARCHY_INSTALL/hardware/apple/bt-a2dp-priority.sh"

if ! bt_a2dp_priority_needed; then
  exit 0
fi
if bt_a2dp_priority_installed; then
  exit 0
fi

bt_a2dp_priority_install
