echo "Enable PCI Runtime Power Management for all devices"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

as_root mkdir -p /etc/udev/rules.d
cat << 'RULE' | as_root tee /etc/udev/rules.d/80-pci-pm.rules >/dev/null
# Enable autonomous Runtime Power Management for all PCI devices
ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
RULE

as_root udevadm control --reload 2>/dev/null || true
as_root udevadm trigger --subsystem-match=pci 2>/dev/null || true
