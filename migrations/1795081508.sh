echo "Remove the retired Direct Boot EFI entry so the machine boots through Limine"

# Setup > Direct Boot needed EFI and efibootmgr, and never ran on Apple Silicon.
[[ -d /sys/firmware/efi ]] || exit 0
omarchy-cmd-present efibootmgr || exit 0
omarchy-hw-aarch64-apple && exit 0

# Setup > Direct Boot labeled its entry exactly "Omarchy" and pointed it at the
# UKI in \EFI\Linux. Match both: a Limine entry can carry the same label.
# efibootmgr 18 follows each label with a tab and the device path.
efi_entries=$(efibootmgr)
direct_boot_nums=$(sed -nE 's/^Boot([0-9A-Fa-f]+)\*?[[:space:]]+Omarchy\t.*\\EFI\\Linux\\omarchy[^\\]*\.efi.*$/\1/Ip' <<<"$efi_entries")

# Deleting Direct Boot is only safe while the firmware has a Limine entry in its
# boot order to fall back to. Without one, keep it: the UKI it loads is the one
# Limine keeps current.
boot_order=$(sed -n 's/^BootOrder: //p' <<<"$efi_entries")
limine_in_order=0
for boot_num in $(sed -nE 's/^Boot([0-9A-Fa-f]+)\*.*\\EFI\\limine\\.*$/\1/Ip' <<<"$efi_entries"); do
  if [[ ,$boot_order, == *,$boot_num,* ]]; then
    limine_in_order=1
  fi
done

keep_direct_boot=0
if [[ -n $direct_boot_nums ]] && (( limine_in_order == 0 )); then
  keep_direct_boot=1
  echo "Keeping the Direct Boot entry: no Limine boot entry is in the firmware's boot order"
else
  for boot_num in $direct_boot_nums; do
    sudo efibootmgr --bootnum "$boot_num" --delete-bootnum >/dev/null
  done
fi

# A DGX Spark that kept Direct Boot left 1790517230 before its rebuild and
# marker, keeping a UKI that Limine now loads with a 20-second firmware delay.
# Finish that rebuild; the marker comes last, so an interrupted one retries.
# A Direct Boot entry kept above still loads the UKI, so keep building it.
spark_marker=/var/lib/omarchy/migrations/1790517230
if (( keep_direct_boot == 0 )) && omarchy-hw-aarch64-gb10 && omarchy-hw-match "NVIDIA_DGX_Spark" &&
  omarchy-cmd-present limine-mkinitcpio && [[ ! -e $spark_marker ]]; then
  sudo bash "$OMARCHY_PATH/install/hardware/nvidia/dgx-spark-boot.sh"
  sudo limine-mkinitcpio
  sudo install -Dm644 /dev/null "$spark_marker"
fi
