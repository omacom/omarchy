# Fix NVMe suspend issues on MacBook models
# Apple's own NVMe controller fails to wake from D3cold, so keep it out of that state where it sits at 01:00.0.
# The MacBook8,1 (Wi-Fi there, its controller at 03:00.0) and the 15-inch 13,3 and 14,3 (the AMD GPU there) must not match.
MACBOOK_MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
NVME_PCI="/sys/bus/pci/devices/0000:01:00.0"

if [[ $MACBOOK_MODEL =~ MacBook(9,1|10,1)|MacBookPro13,[12]|MacBookPro14,[12] ]]; then
  echo "Detected MacBook model: $MACBOOK_MODEL"

  if [[ $(cat "$NVME_PCI/vendor" 2>/dev/null || true) == "0x106b" ]]; then
    echo "Applying NVMe suspend fix..."

    sudo mkdir -p /etc/systemd/system
    sudo tee /etc/systemd/system/omarchy-nvme-suspend-fix.service >/dev/null <<'EOF'
[Unit]
Description=Omarchy NVMe Suspend Fix for MacBook

[Service]
ExecStart=/bin/bash -c 'echo 0 > /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed'

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl enable omarchy-nvme-suspend-fix.service
  else
    echo "Warning: Apple NVMe controller not found at expected PCI address (0000:01:00.0)"
    echo "This fix may not be needed for this MacBook model"
  fi
fi
