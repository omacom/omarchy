# Samsung Galaxy Book4 Edge 14 (X1E-80-100) board setup.

limine_config_dir=${OMARCHY_GALAXY_BOOK4_EDGE_14_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

# The laptop doesn't come back from AOSS sleep: a deep suspend loses UFS on
# resume, and an s2idle one ends in a PMIC power cycle once a full hour of the
# AOP clock passes. linux-omarchy's qcom_aoss keeps the AOSS awake when this
# parameter is set. A kernel without the parameter ignores it.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree samsung,galaxy-book4-edge-14; then
  echo "Detected Samsung Galaxy Book4 Edge 14, applying board-specific support..."

  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/samsung-galaxy-book4-edge-14.conf" <<'CONF'
# Keep the AOSS out of sleep, which this laptop doesn't resume from.
KERNEL_CMDLINE[default]+=" qcom_aoss.prevent_aoss_sleep=1"
CONF
fi
