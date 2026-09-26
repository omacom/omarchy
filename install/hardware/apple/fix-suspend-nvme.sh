# Fix NVMe suspend issues on MacBook models
# Apple's own NVMe controller fails to wake from D3cold, so keep it out of that state.
# Only the 12-inch MacBooks and the 13-inch MacBook Pros carry that controller, always at 01:00.0.
# The 15-inch MacBookPro13,3 and 14,3 ship a standard NVMe drive at 02:00.0 and put the AMD GPU
# at 01:00.0, so they must not match: the fix would land on the GPU instead.
MACBOOK_MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
NVME_PCI="/sys/bus/pci/devices/0000:01:00.0"

if [[ $MACBOOK_MODEL =~ MacBook(8,1|9,1|10,1)|MacBookPro13,[12]|MacBookPro14,[12] ]]; then
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
