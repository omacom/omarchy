# Stop Intel Alpine Ridge Thunderbolt 3 from waking 2016–2017 MacBook Pros
# out of S3. These machines are T1 (no T2 chip). Keep deep sleep; s2idle is
# the heat path. Do not set pm_async=off (that serializes D3 timeouts into a
# minute-long black screen) and do not blacklist thunderbolt (USB-C docks).

MACBOOK_MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)

if [[ ! $MACBOOK_MODEL =~ MacBookPro13,[123]|MacBookPro14,[123] ]]; then
  return 0 2>/dev/null || exit 0
fi

echo "Detected $MACBOOK_MODEL; disabling Alpine Ridge S3 wakeup"

udev_rules=/etc/udev/rules.d/99-omarchy-alpine-ridge-wakeup.rules
limine_conf=/etc/limine-entry-tool.d/alpine-ridge-suspend.conf
service=/etc/systemd/system/omarchy-alpine-ridge-wakeup.service

sudo mkdir -p /etc/udev/rules.d /etc/limine-entry-tool.d /etc/systemd/system /etc/omarchy

# S3 resume on these parts is ~7s, so lid-close waits 20s (see
# omarchy-system-lid-suspend) instead of the 3s default. Leave an admin-set
# value alone.
if [[ ! -f /etc/omarchy/lid-suspend-delay ]]; then
  printf '20\n' | sudo tee /etc/omarchy/lid-suspend-delay >/dev/null
fi

sudo tee "$udev_rules" >/dev/null <<'EOF'
# Alpine Ridge NHI (8086:15d2) and xHCI (8086:15d4) must not wake S3.
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x15d2", ATTR{power/wakeup}="disabled"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x15d4", ATTR{power/wakeup}="disabled"
EOF

sudo tee "$limine_conf" >/dev/null <<'EOF'
# Alpine Ridge ports do not return from D3; skip PCIe port power management.
KERNEL_CMDLINE[default]+=" pcie_port_pm=off"
EOF

sudo tee "$service" >/dev/null <<'EOF'
[Unit]
Description=Disable Alpine Ridge Thunderbolt wakeup from S3
After=sysinit.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/omarchy-hw-alpine-ridge-wakeup

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now omarchy-alpine-ridge-wakeup.service

if ! grep -Eq '(^| )pcie_port_pm=off( |$)' /proc/cmdline 2>/dev/null; then
  if command -v limine-mkinitcpio >/dev/null; then
    sudo limine-mkinitcpio
  fi
fi
