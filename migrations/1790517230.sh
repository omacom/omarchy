echo "Boot the DGX Spark without a UKI to skip a 20-second firmware delay"

# Existing installs predate the install-time setting, which Limine only applies
# on a rebuild. The marker stops another user's run from repeating the
# machine-wide rebuild, while a missing marker retries an interrupted one.
limine_config_dir=${OMARCHY_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
rebuild_marker=${OMARCHY_DGX_SPARK_BOOT_MARKER:-/var/lib/omarchy/migrations/1790517230}

omarchy-hw-aarch64-gb10 && omarchy-hw-match "NVIDIA_DGX_Spark" || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0
[[ ! -e $rebuild_marker ]] || exit 0

if [[ ! -f $limine_config_dir/zz-omarchy-dgx-spark.conf ]]; then
  sudo bash "$OMARCHY_PATH/install/hardware/nvidia/dgx-spark-boot.sh"
fi

if ! grep -Fxqs 'ENABLE_UKI=no' "$limine_config_dir/zz-omarchy-dgx-spark.conf"; then
  echo "Couldn't apply the DGX Spark non-UKI setting; leaving the boot migration pending" >&2
  exit 1
fi

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
