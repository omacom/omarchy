# Allow unprivileged access to Keychron keyboards for RGB control and Keychron Launcher.

sudo install -Dm755 "$OMARCHY_PATH/default/udev/keychron-config-check" /usr/lib/udev/omarchy-keychron-config-check

rule_file=/etc/udev/rules.d/50-keychron-rgb.rules
legacy_rule=$'# Keychron keyboards - allow the active user to talk to the raw config channel (RGB / Keychron Launcher).\nSUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", TAG+="uaccess"'

if [[ ! -f $rule_file ]] || [[ $(<"$rule_file") == "$legacy_rule" ]]; then
  sudo mkdir -p /etc/udev/rules.d
  sudo cp -f "$OMARCHY_PATH/default/udev/keychron-rgb.rules" "$rule_file"
  sudo udevadm control --reload
  sudo udevadm trigger --subsystem-match=hidraw
fi
