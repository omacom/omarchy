# Shared helpers for the Broadcom A2DP ACL-priority fix (install leaf + migration).
#
# BlueZ never sends Broadcom's vendor-specific Write_High_Priority_Connection
# command for an A2DP link, so audio stutters badly under any concurrent
# scan/inquiry. See bin/omarchy-hw-apple-bt-a2dp-priority for the fix itself.
#
# Gated on the same PCI ID Omarchy already uses to detect a T2 Mac (see
# fix-t2.sh) — every T2 Mac's Bluetooth is a member of this Broadcom family,
# driven by hci_bcm4377.

bt_a2dp_priority_needed() {
  lspci -nn 2>/dev/null | grep -q "106b:180[12]"
}

bt_a2dp_priority_installed() {
  systemctl is-enabled --quiet omarchy-bt-a2dp-priority.service 2>/dev/null
}

bt_a2dp_priority_install() {
  omarchy-pkg-add bluez-deprecated-tools
  sudo systemctl enable --now omarchy-bt-a2dp-priority.service
}
