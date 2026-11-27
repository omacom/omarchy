# Raspberry Pi 4 Model B board setup.

limine_config_dir=${OMARCHY_RASPBERRY_PI_4_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

# vc4 scans out of the CMA pool, which must sit in the first GiB of RAM. The
# firmware's device tree reserves 64 MiB, and a 2560x1440 desktop does not fit
# in it, so Hyprland falls back to a lower mode. 512 MiB, as on Raspberry Pi
# OS, can fail here: the EFI stub places the kernel at a random address, and
# once it landed inside that first GiB, leaving no free run of 512 MiB. The
# disk unlock prompt then never reached the screen. 256 MiB still fit with the
# kernel near the middle of the free span, and a 1440p desktop uses about
# 56 MiB of it.
if omarchy-hw-match-device-tree raspberrypi,4-model-b; then
  echo "Detected Raspberry Pi 4 Model B, applying board-specific support..."

  # Room for vc4's scanout buffers in the first GiB, next to a randomly placed kernel.
  OMARCHY_BOOT_LIMINE_DROPINS=$limine_config_dir omarchy-boot-cmdline set raspberry-pi-4 cma=256M

  # Raspberry Pi's patch for the CYW43455's Bluetooth, which linux-firmware
  # lacks. Without it the controller runs its ROM firmware and reports the
  # placeholder address AA:AA:AA:AA:AA:AA.
  omarchy-pkg-add raspberry-pi-4-bluetooth-firmware

  # Without access to the HDMI DDC buses, ddcutil fails with EACCES and the
  # brightness keys leave an external monitor unchanged.
  sudo install -Dm644 "$OMARCHY_PATH/default/udev/raspberry-pi-4-ddc.rules" \
    /etc/udev/rules.d/70-raspberry-pi-4-ddc.rules

  # An image's first boot runs this after udev has added the I2C devices, so
  # the rule would only apply from the next boot. Only there, as in
  # install/hardware/bluetooth.sh: an install writes it before the first boot.
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    sudo udevadm control --reload || true
    sudo udevadm trigger --action=add --subsystem-match=i2c-dev || true
  fi
fi
