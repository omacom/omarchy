# Auto-recover ELAN I2C Touchpad on Lenovo IdeaPad
#
# Some Lenovo IdeaPads (e.g. IdeaPad Slim 5 14IAH8 / 83BF) have a firmware DSDT bug
# that requests an unsupported 400kHz I2C bus speed. When Linux clamps this to 100kHz,
# the Intel I2C bus controller (i2c_designware) occasionally times out during boot
# with error -110 ("can't add hid device: -110"), leaving the touchpad undetected.
#
# Keeping runtime power management "on" for the host controller bridge and rebinding
# the i2c_designware adapter unfreezes the bus and recovers the ELAN touchpad.

if omarchy-hw-match "IdeaPad Slim 5" || omarchy-hw-match "83BF"; then
  sudo mkdir -p /etc/systemd/system
  sudo tee /etc/systemd/system/omarchy-ideapad-touchpad-fix.service >/dev/null <<'EOF'
[Unit]
Description=Recover ELAN Touchpad on Lenovo IdeaPad
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c '\
    echo on > /sys/devices/pci0000:00/0000:00:15.0/power/control 2>/dev/null; \
    echo on > /sys/devices/pci0000:00/0000:00:15.0/i2c_designware.0/power/control 2>/dev/null; \
    has_touchpad() { \
        local class_path="${OMARCHY_INPUT_CLASS_PATH:-/sys/class/input}"; \
        for dev in "$class_path"/event*; do \
            [[ -e $dev ]] || continue; \
            if udevadm info --query=property "$dev" 2>/dev/null | grep -Fxq "ID_INPUT_TOUCHPAD=1"; then \
                return 0; \
            fi; \
        done; \
        return 1; \
    }; \
    if ! has_touchpad; then \
        echo i2c_designware.0 > /sys/bus/platform/drivers/i2c_designware/unbind 2>/dev/null; \
        sleep 1; \
        echo i2c_designware.0 > /sys/bus/platform/drivers/i2c_designware/bind 2>/dev/null; \
        sleep 1; \
        /usr/bin/modprobe -r i2c_hid_acpi 2>/dev/null; \
        sleep 1; \
        /usr/bin/modprobe i2c_hid_acpi 2>/dev/null; \
    fi'

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable omarchy-ideapad-touchpad-fix.service

  # An image's first boot runs hardware setup after multi-user.target has queued,
  # so start the service with --no-block so first-boot image users get recovery immediately.
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    sudo systemctl start --no-block omarchy-ideapad-touchpad-fix.service || true
  fi
fi
