echo "Let UPower notice the charger being plugged in or out on Snapdragon laptops"

# See install/hardware/qualcomm/charger-events.sh, which sets up new installs the same way.
rules="${OMARCHY_QUALCOMM_CHARGER_RULES:-/etc/udev/rules.d/71-omarchy-qualcomm-charger-events.rules}"
power_supply_path="${OMARCHY_POWER_SUPPLY_PATH:-/sys/class/power_supply}"

# True when UPower's idea of a charger supply differs from the kernel's, which
# is what the rule prevents from now on.
upower_charger_stale() {
  local supply online upower_online
  for supply in qcom-battmgr-ac qcom-battmgr-usb qcom-battmgr-wls; do
    [[ -r $power_supply_path/$supply/online ]] || continue
    online=$(<"$power_supply_path/$supply/online")
    upower_online=$(upower -i "/org/freedesktop/UPower/devices/line_power_${supply//-/_}" 2>/dev/null | awk '/online:/ { print $2 }')
    if [[ $online == "1" && $upower_online != "yes" ]] || [[ $online == "0" && $upower_online == "yes" ]]; then
      return 0
    fi
  done
  return 1
}

if ! omarchy-hw-aarch64-qualcomm; then
  exit 0
fi

if [[ ! -f $rules ]]; then
  sudo install -Dm644 /dev/stdin "$rules" <<'RULES'
# Qualcomm: qcom_battmgr only announces the battery, so replay a change event on
# its charger supplies for UPower; see install/hardware/qualcomm/charger-events.sh.
# Never match the battery itself here, or the replay loops.
ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="qcom-battmgr-bat", RUN+="/usr/bin/udevadm trigger --action=change --subsystem-match=power_supply --sysname-match=qcom-battmgr-ac --sysname-match=qcom-battmgr-usb --sysname-match=qcom-battmgr-wls"
RULES
fi

# UPower may already hold a stale charger state, so have it read the charger
# supplies again now instead of at the battery's next report. Checking the state
# rather than whether this run wrote the rule also covers a run that stopped in
# between, and leaves another user's run with nothing to do.
if upower_charger_stale; then
  sudo udevadm control --reload
  sudo udevadm trigger --action=change --subsystem-match=power_supply --sysname-match=qcom-battmgr-ac --sysname-match=qcom-battmgr-usb --sysname-match=qcom-battmgr-wls
fi
