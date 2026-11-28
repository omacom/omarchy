echo "Re-enable the HP ZBook Ultra G3a's internal Bluetooth USB port"

# The removed 60-omarchy-hp-zbook-ultra-g3a-usb.rules mistook the warm-reboot
# wedged MediaTek MT7925 Bluetooth adapter on port 5 for a phantom device.
# Warm-reboot teardown is now handled by omarchy-mt7925-bluetooth-shutdown.service.
if ! omarchy-hw-match "ZBook Ultra G3a"; then
  exit 0
fi

rule=/etc/udev/rules.d/60-omarchy-hp-zbook-ultra-g3a-usb.rules
if [[ -e $rule ]]; then
  echo "Waiting for the omarchy-settings package that removes $rule" >&2
  exit 75
fi

shopt -s nullglob
disabled_ports=()
for pci in /sys/bus/pci/devices/*; do
  [[ -r $pci/vendor && -r $pci/device ]] || continue
  [[ $(<"$pci/vendor") == "0x1022" && $(<"$pci/device") == "0x1588" ]] || continue
  for port in "$pci"/usb*/*-0:1.0/usb*-port5; do
    if [[ -r $port/disable && $(<"$port/disable") == "1" ]]; then
      disabled_ports+=("$port")
    fi
  done
done

if (( ${#disabled_ports[@]} == 0 )); then
  exit 0
fi

sudo udevadm control --reload
for port in "${disabled_ports[@]}"; do
  printf '0\n' | sudo tee "$port/disable" >/dev/null
done
