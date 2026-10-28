echo "Keep the ASUS ProArt P14's USB4 tunnel root ports awake so a dock's Ethernet appears"

# See install/hardware/n1x.sh, which sets up new installs the same way.
rules="${OMARCHY_N1X_USB4_ROOT_PORT_RULES:-/etc/udev/rules.d/71-omarchy-n1x-usb4-root-ports.rules}"
pci_devices="${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"

if ! omarchy-hw-aarch64-n1x || ! omarchy-hw-match "H7407BA"; then
  exit 0
fi

if [[ ! -f $rules ]]; then
  sudo install -Dm644 /dev/stdin "$rules" <<'EOF'
# N1x: the USB4 tunnel root ports cannot wake for a hotplug, so keep them out of
# runtime suspend; see install/hardware/n1x.sh.
ACTION=="add|bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{device}=="0x22cf", ATTR{power/control}="on"
EOF
fi

# udev only applies the rule to new events, so replay one for any port that is
# still allowed to suspend. Once they are all on, another user's run is a no-op.
for port in "$pci_devices"/*; do
  [[ $(cat "$port/vendor" 2>/dev/null) == "0x10de" && $(cat "$port/device" 2>/dev/null) == "0x22cf" ]] || continue
  [[ $(cat "$port/power/control" 2>/dev/null) != "on" ]] || continue
  sudo udevadm control --reload
  sudo udevadm trigger --action=add --subsystem-match=pci --attr-match=vendor=0x10de --attr-match=device=0x22cf
  break
done
