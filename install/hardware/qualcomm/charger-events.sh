# Let UPower notice the charger on Snapdragon laptops. qcom_battmgr updates the
# charger supplies' online state from the battery status reply but only
# announces the battery, so UPower keeps the charger state it read at startup:
# a laptop booted on the charger never goes on battery, and Omarchy keeps its
# AC power profile. Replay a change event on the charger supplies whenever the
# battery reports. Remove this once qcom_battmgr announces the charger supplies
# itself; that fix belongs in the kernel.

rules_dir=${OMARCHY_QUALCOMM_UDEV_RULES_DIR:-/etc/udev/rules.d}

if omarchy-hw-aarch64-qualcomm; then
  mkdir -p "$rules_dir"
  cat >"$rules_dir/71-omarchy-qualcomm-charger-events.rules" <<'RULES'
# Qualcomm: qcom_battmgr only announces the battery, so replay a change event on
# its charger supplies for UPower; see install/hardware/qualcomm/charger-events.sh.
# Never match the battery itself here, or the replay loops.
ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="qcom-battmgr-bat", RUN+="/usr/bin/udevadm trigger --action=change --subsystem-match=power_supply --sysname-match=qcom-battmgr-ac --sysname-match=qcom-battmgr-usb --sysname-match=qcom-battmgr-wls"
RULES
fi
