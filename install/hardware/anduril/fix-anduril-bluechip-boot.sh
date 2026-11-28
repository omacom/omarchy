# Display power management on the Anduril BlueChip (NY4P9, Snapdragon X2 Elite / Glymur).

limine_config_dir=${OMARCHY_BLUECHIP_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree anduril,bluechip; then
  # Enable Panel Self Refresh (msm.psr_enabled=1) on the Samsung ATNA40HQ08-0
  # 120 Hz OLED panel (DPCD 0x70 = 0x04, PSR2+ET) so the display controller
  # suspends on static screens (~1.5-1.7 W saved at idle).
  OMARCHY_BOOT_LIMINE_DROPINS=$limine_config_dir omarchy-boot-cmdline set bluechip msm.psr_enabled=1
fi
