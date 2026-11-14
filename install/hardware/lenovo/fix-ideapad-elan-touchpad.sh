# Auto-recover ELAN I2C Touchpad on Lenovo IdeaPad
#
# The Lenovo IdeaPad Slim 5 14IAH8 (machine type 83BF) has a firmware DSDT bug
# that requests an unsupported 400kHz I2C bus speed. When Linux clamps this to 100kHz,
# the Intel I2C bus controller (i2c_designware) occasionally times out during boot
# with error -110 ("can't add hid device: -110"), leaving the touchpad undetected.
#
# Rebinding the i2c_designware adapter unfreezes the bus and recovers the ELAN touchpad.

if omarchy-hw-match "83BF"; then
  sudo mkdir -p /etc/systemd/system
  sudo tee /etc/systemd/system/omarchy-ideapad-touchpad-fix.service >/dev/null <<'EOF'
[Unit]
Description=Recover ELAN Touchpad on Lenovo IdeaPad
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c '\
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
