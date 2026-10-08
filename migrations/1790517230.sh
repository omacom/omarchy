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
# A drop-in already on disk would do the same on the next kernel rebuild.
direct_boot_status=0
omarchy-boot-direct || direct_boot_status=$?
if (( direct_boot_status == 0 )); then
  # Drop the file here. The hardware leaf exits 0 when a second read fails, and
  # it can write ENABLE_UKI=no again if that read says Direct Boot is gone.
  drop_in=$limine_config_dir/zz-omarchy-dgx-spark.conf
  if [[ -f $drop_in ]]; then
    sudo rm -f "$drop_in"
    if [[ -f $drop_in ]]; then
      echo "Couldn't remove the DGX Spark drop-in that would delete the Direct Boot UKI" >&2
      exit 1
    fi
  fi
  echo "Keeping the UKI because Omarchy Direct Boot is configured"
  exit 0
fi
if (( direct_boot_status != 1 )); then
  exit "$direct_boot_status"
fi

# Only an inactive Omarchy entry is named below. efibootmgr 18 follows each
# label with a tab and the device path, so keep the label field.
efi_labels=$(efibootmgr | cut -f1)

if [[ ! -f $limine_config_dir/zz-omarchy-dgx-spark.conf ]]; then
  sudo bash "$OMARCHY_PATH/install/hardware/nvidia-dgx-spark-boot.sh"
fi

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"

# Setup > Direct Boot doesn't recognise an inactive entry, so name the command.
for boot_num in $(sed -nE 's/^Boot([0-9A-Fa-f]+)[[:space:]]+Omarchy[[:space:]]*$/\1/p' <<<"$efi_labels"); do
  echo "The inactive Omarchy EFI entry $boot_num no longer has a UKI to boot; remove it with: sudo efibootmgr -b $boot_num -B"
done
