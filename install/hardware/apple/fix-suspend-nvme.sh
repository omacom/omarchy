# Fix NVMe suspend issues on MacBook models
# This prevents NVMe drives from failing to wake from sleep properly
MACBOOK_MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)

find_nvme_pci_device() {
  local sys_root="${1:-/sys}"
  local controller=""
  local device_path=""
  local pci_device=""

  for controller in "$sys_root"/class/nvme/nvme*; do
    [[ -e $controller/device ]] || continue

    device_path=$(readlink -f "$controller/device" 2>/dev/null) || continue
    pci_device=${device_path##*/}

    [[ $pci_device =~ ^[0-9A-Fa-f]{4}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}\.[0-7]$ ]] || continue
    [[ -f $sys_root/bus/pci/devices/$pci_device/d3cold_allowed ]] || continue

    printf '%s\n' "$pci_device"
    return 0
  done

  return 1
}

if [[ $MACBOOK_MODEL =~ MacBook(8,1|9,1|10,1)|MacBookPro13,[123]|MacBookPro14,[123] ]]; then
  echo "Detected MacBook model: $MACBOOK_MODEL"

  NVME_PCI=$(find_nvme_pci_device || true)

  if [[ -n $NVME_PCI ]]; then
    NVME_DEVICE="/sys/bus/pci/devices/$NVME_PCI/d3cold_allowed"
    SERVICE_FILE="/etc/systemd/system/omarchy-nvme-suspend-fix.service"
    LEGACY_PCI="0000:01:00.0"
    LEGACY_DEVICE="/sys/bus/pci/devices/$LEGACY_PCI/d3cold_allowed"

    echo "Applying NVMe suspend fix to $NVME_PCI..."

    # Older Omarchy installs always targeted 01:00.0. On dGPU MacBooks that can
    # be the graphics controller instead of the NVMe. Only undo that setting
    # when the existing Omarchy unit proves it contains the legacy target.
    if [[ $NVME_PCI != "$LEGACY_PCI" && -f $LEGACY_DEVICE && -f $SERVICE_FILE ]] &&
      { grep -Fq '0000\:01\:00.0/d3cold_allowed' "$SERVICE_FILE" ||
        grep -Fq '0000:01:00.0/d3cold_allowed' "$SERVICE_FILE"; }; then
      echo "Restoring D3cold on legacy non-NVMe PCI target $LEGACY_PCI..."
      echo 1 | sudo tee "$LEGACY_DEVICE" >/dev/null
    fi

    sudo mkdir -p /etc/systemd/system
    sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=Omarchy NVMe Suspend Fix for MacBook

[Service]
ExecStart=/bin/bash -c 'echo 0 > $NVME_DEVICE'

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable omarchy-nvme-suspend-fix.service
  else
    echo "Warning: No PCI NVMe controller with d3cold_allowed was found"
    echo "This fix may not be needed for this MacBook model"
  fi
fi
