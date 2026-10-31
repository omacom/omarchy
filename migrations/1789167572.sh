echo "Support unlocking and mounting internal and LVM-backed drives"

omarchy-pkg-add udisks2-lvm2

if [[ ! -f /etc/polkit-1/rules.d/10-udisks2.rules ]]; then
  sudo mkdir -p /etc/polkit-1/rules.d
  sudo install -Dm644 "$OMARCHY_PATH/etc/polkit-1/rules.d/10-udisks2.rules" /etc/polkit-1/rules.d/10-udisks2.rules
fi

if systemctl is-active --quiet udisks2.service 2>/dev/null; then
  sudo systemctl restart udisks2.service
fi
