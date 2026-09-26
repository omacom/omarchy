# Cap Intel CPU package power while on battery: full-turbo spikes can droop a
# discharging battery until the BMS cuts all power (a hard shutdown with
# nothing in the journal). power-saver only hints EPP, it never caps frequency
# or package power.

if omarchy-hw-intel && omarchy-battery-present; then
  sudo install -Dm644 "$OMARCHY_PATH/default/udev/battery-cpu-limit.rules" /etc/udev/rules.d/99-omarchy-battery-cpu-limit.rules
  sudo install -Dm755 "$OMARCHY_PATH/default/systemd/system-sleep/battery-cpu-limit" /usr/lib/systemd/system-sleep/battery-cpu-limit
  sudo udevadm control --reload-rules
  sudo udevadm trigger --subsystem-match=power_supply --action=change
fi
