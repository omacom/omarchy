echo "Install the MSI GS65 Stealth Wi-Fi resume hook"

# See install/hardware/fix-msi-gs65-wifi.sh. Existing machines never rerun
# hardware setup, and a hook already there is left as the administrator has it.
hook_dst=/usr/lib/systemd/system-sleep/msi-gs65-wifi

if omarchy-hw-match "^GS65 Stealth" && [[ ! -e $hook_dst ]]; then
  sudo install -Dm755 -o root -g root \
    "$OMARCHY_PATH/default/systemd/system-sleep/msi-gs65-wifi" \
    "$hook_dst"
fi
