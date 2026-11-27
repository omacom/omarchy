# Display power management on the Microsoft Surface Pro 11 OLED (Snapdragon X Elite).

limine_config_dir=${OMARCHY_SURFACE_PRO11_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree microsoft,denali-oled; then
  # Enable Panel Self Refresh (msm.psr_enabled=1) on the internal OLED panel so
  # the display controller stops sending frames on a still screen (median
  # 4.62 W to 3.92 W at idle, battery, 120 Hz). PSR1 only; the LCD model,
  # which boots its own tree, is untested and left as it is.
  OMARCHY_BOOT_LIMINE_DROPINS=$limine_config_dir omarchy-boot-cmdline set surface-pro-11 msm.psr_enabled=1
fi
