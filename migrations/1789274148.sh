echo "Remove the MacBook NVMe suspend fix from Macs where it disabled D3cold on the GPU or Wi-Fi instead of the drive"

# The leaf used to match the MacBook8,1 and the 15-inch MacBookPro13,3 and 14,3, whose 01:00.0 is Wi-Fi or the GPU.
# It now needs Apple's controller there, so remove the service everywhere that is not.
unit="${OMARCHY_NVME_SUSPEND_UNIT:-/etc/systemd/system/omarchy-nvme-suspend-fix.service}"
pci_vendor="${OMARCHY_NVME_SUSPEND_PCI_VENDOR:-/sys/bus/pci/devices/0000:01:00.0/vendor}"

[[ -f $unit && ! -L $unit ]] || exit 0
[[ $(cat "$pci_vendor" 2>/dev/null || true) != "0x106b" ]] || exit 0

# Remove only the unit the leaf wrote, with or without its escaped colons. An edited one is the administrator's.
generated="[Unit]
Description=Omarchy NVMe Suspend Fix for MacBook

[Service]
ExecStart=/bin/bash -c 'echo 0 > /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed'

[Install]
WantedBy=multi-user.target"
contents=$(cat "$unit" 2>/dev/null || true)

if [[ ${contents//'\:'/:} == "$generated" ]]; then
  sudo systemctl disable omarchy-nvme-suspend-fix.service
  sudo rm -f "$unit"
  sudo systemctl daemon-reload
else
  echo "Leaving $unit in place: it was changed after Omarchy wrote it"
fi
