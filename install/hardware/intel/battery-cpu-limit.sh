# Cap Intel CPU package power while on battery: full-turbo spikes can droop a
# discharging battery until the BMS cuts all power (a hard shutdown with
# nothing in the journal). power-saver only hints EPP, it never caps frequency
# or package power.

if omarchy-hw-intel && omarchy-battery-present; then
  rule_src="$OMARCHY_PATH/default/udev/battery-cpu-limit.rules"
  hook_src="$OMARCHY_PATH/default/systemd/system-sleep/battery-cpu-limit"
  rule_dest=/etc/udev/rules.d/99-omarchy-battery-cpu-limit.rules
  hook_dest=/usr/lib/systemd/system-sleep/battery-cpu-limit

  # Machine-wide repair through a per-user runner (migration): no-op once
  # another user already published the files, so later users never prompt for
  # sudo or block behind an already-applied repair.
  if ! cmp -s "$rule_src" "$rule_dest" || ! cmp -s "$hook_src" "$hook_dest"; then
    sudo install -Dm644 "$rule_src" "$rule_dest"
    sudo install -Dm755 "$hook_src" "$hook_dest"
    sudo udevadm control --reload-rules
    sudo udevadm trigger --subsystem-match=power_supply --action=change
  fi
fi
