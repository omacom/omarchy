# BlueZ never sends Broadcom's vendor-specific ACL-priority command for A2DP
# links, so audio stutters badly under any concurrent scan/inquiry. See
# bt-a2dp-priority.sh for the mechanism.

: "${OMARCHY_PATH:=/usr/share/omarchy}"
: "${OMARCHY_INSTALL:=$OMARCHY_PATH/install}"
# shellcheck source=bt-a2dp-priority.sh
source "$OMARCHY_INSTALL/hardware/apple/bt-a2dp-priority.sh"

if ! bt_a2dp_priority_needed; then
  return 0
fi
if bt_a2dp_priority_installed; then
  return 0
fi

echo "Wiring up the Bluetooth A2DP ACL-priority fix"
bt_a2dp_priority_install
