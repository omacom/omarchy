echo "Remove the retired Direct Boot EFI entry so the machine boots through Limine"

# Setup > Direct Boot needed EFI and efibootmgr, and never ran on Apple Silicon.
[[ -d /sys/firmware/efi ]] || exit 0
omarchy-cmd-present efibootmgr || exit 0
omarchy-hw-aarch64-apple && exit 0

# Setup > Direct Boot labeled its entry exactly "Omarchy"; Limine's own is
# "Limine". efibootmgr 18 follows each label with a tab and the device path.
efi_labels=$(efibootmgr | cut -f1)

for boot_num in $(sed -nE 's/^Boot([0-9A-Fa-f]+)\*?[[:space:]]+Omarchy[[:space:]]*$/\1/p' <<<"$efi_labels"); do
  sudo efibootmgr --bootnum "$boot_num" --delete-bootnum >/dev/null
done

# A DGX Spark that kept Direct Boot through 1790517230 also kept its UKI, which
# Limine now loads with a 20-second firmware delay. Boot it without one.
limine_config_dir=/etc/limine-entry-tool.d
if omarchy-hw-aarch64-gb10 && omarchy-hw-match "NVIDIA_DGX_Spark" && omarchy-cmd-present limine-mkinitcpio &&
  ! grep -Fxqs 'ENABLE_UKI=no' "$limine_config_dir/zz-omarchy-dgx-spark.conf"; then
  sudo bash "$OMARCHY_PATH/install/hardware/nvidia/dgx-spark-boot.sh"
  sudo limine-mkinitcpio
fi
