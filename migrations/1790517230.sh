echo "Boot the DGX Spark without a UKI to skip a 20-second firmware delay"

# Existing installs predate the install-time setting, which Limine only applies
# on a rebuild. The marker stops another user's run from repeating the
# machine-wide rebuild, while a missing marker retries an interrupted one.
limine_config_dir=${OMARCHY_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
rebuild_marker=${OMARCHY_DGX_SPARK_BOOT_MARKER:-/var/lib/omarchy/migrations/1790517230}

omarchy-hw-dgx-spark || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0
[[ ! -e $rebuild_marker ]] || exit 0

# Direct Boot loads the UKI through firmware. Rebuilding without a UKI would
# delete its boot target; leave that choice intact, including its boot files.
# An inactive entry (no *) isn't booted. efibootmgr 18 follows each label with
# a tab and the device path.
efi_labels=$(efibootmgr | cut -f1)
if grep -Eq '^Boot[0-9A-Fa-f]+\*[[:space:]]+Omarchy[[:space:]]*$' <<<"$efi_labels"; then
  echo "Keeping the UKI because Omarchy Direct Boot is configured"
  exit 0
fi

if [[ ! -f $limine_config_dir/zz-omarchy-dgx-spark.conf ]]; then
  sudo bash "$OMARCHY_PATH/install/hardware/nvidia-dgx-spark-boot.sh"
fi

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
