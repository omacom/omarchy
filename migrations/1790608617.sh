echo "Repair USB approval prompts and enable portable device approvals"

# Preserve an explicit opt-out. Existing users with an active/enabled daemon
# need a working watcher even if their old checkout link has become dangling.
if systemctl is-enabled --quiet usbguard.service || systemctl is-active --quiet usbguard.service; then
  omarchy-setup-security-usb-authorization --yes
fi
