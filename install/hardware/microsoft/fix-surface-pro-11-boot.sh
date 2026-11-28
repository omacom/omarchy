# Display power management on the Microsoft Surface Pro 11 OLED (Snapdragon X Elite).

limine_config_dir=${OMARCHY_SURFACE_PRO11_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
surface_pro11_soc_id=${OMARCHY_SURFACE_PRO11_SOC_ID:-/sys/devices/soc0/soc_id}

# The live tree alone does not prove the OLED model: an LCD (X Plus) install
# from before surface-pro-11.sh told the models apart still runs the OLED tree
# until it reboots onto its own. As there, the SoC tells them apart: the
# X1P-64-100 reports socinfo ID 615.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree microsoft,denali-oled &&
  [[ -r $surface_pro11_soc_id && $(<"$surface_pro11_soc_id") != "615" ]]; then
  # Enable Panel Self Refresh (msm.psr_enabled=1) on the internal OLED panel so
  # the display controller stops sending frames on a still screen (median
  # 4.62 W to 3.92 W at idle, battery, 120 Hz). PSR1 only; the LCD model is
  # untested and left as it is.
  OMARCHY_BOOT_LIMINE_DROPINS=$limine_config_dir omarchy-boot-cmdline set surface-pro-11 msm.psr_enabled=1
fi
