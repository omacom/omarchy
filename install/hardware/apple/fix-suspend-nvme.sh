# Fix suspend on 2016-2017 MacBooks with Apple's S3X NVMe.
#
# Turning off D3cold is not enough for MacBookPro14,1. Firmware S3 resume does
# not come back, and on s2idle the 106b:2003 controller is left in a power
# state it cannot leave. The kernel parameters below resumed that machine from
# a short sleep and from a lid close. intel_idle.max_cstate=1 was part of that
# combo and was not tested alone; it uses more power while the machine is awake.
# The udev rule matches 106b:2003, so it does not write D3cold onto the GPU at
# 0000:01:00.0 on the 15-inch MacBookPro13,3 and 14,3.
MACBOOK_MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)

if [[ $MACBOOK_MODEL =~ MacBook(8,1|9,1|10,1)|MacBookPro13,[123]|MacBookPro14,[123] ]]; then
  echo "Detected MacBook model: $MACBOOK_MODEL"

  sudo mkdir -p /etc/udev/rules.d
  sudo tee /etc/udev/rules.d/99-omarchy-apple-nvme-d3cold.rules >/dev/null <<'EOF'
# Keep the Apple S3X NVMe out of D3cold wherever it is enumerated.
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x106b", ATTR{device}=="0x2003", ATTR{d3cold_allowed}="0"
EOF

  sudo mkdir -p /etc/limine-entry-tool.d
  sudo tee /etc/limine-entry-tool.d/apple-s3x-suspend.conf >/dev/null <<'EOF'
# 2016-2017 MacBooks with Apple's S3X NVMe do not resume from S3.
# intel_idle.max_cstate=1 raises idle power use.
KERNEL_CMDLINE[default]+=" mem_sleep_default=s2idle nvme_core.default_ps_max_latency_us=0 intel_idle.max_cstate=1"
EOF

  NVME_DEVICE="/sys/bus/pci/devices/0000:01:00.0/d3cold_allowed"

  if [[ -f $NVME_DEVICE ]]; then
    echo "Applying NVMe suspend fix..."

    sudo mkdir -p /etc/systemd/system
    sudo tee /etc/systemd/system/omarchy-nvme-suspend-fix.service >/dev/null <<'EOF'
[Unit]
Description=Omarchy NVMe Suspend Fix for MacBook

[Service]
ExecStart=/bin/bash -c 'echo 0 > /sys/bus/pci/devices/0000\:01\:00.0/d3cold_allowed'

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl enable omarchy-nvme-suspend-fix.service
  else
    echo "Warning: NVMe device not found at expected PCI address (0000:01:00.0)"
    echo "This fix may not be needed for this MacBook model"
  fi
fi
