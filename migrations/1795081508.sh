echo "Remove the retired Direct Boot EFI entry so the machine boots through Limine"

# Setup > Direct Boot labeled its entry exactly "Omarchy"; Limine's own is
# "Limine". Without readable EFI variables there was never an entry to remove.
efi_labels=$(efibootmgr 2>/dev/null | cut -f1) || exit 0

for boot_num in $(sed -nE 's/^Boot([0-9A-Fa-f]+)\*?[[:space:]]+Omarchy[[:space:]]*$/\1/p' <<<"$efi_labels"); do
  sudo efibootmgr --bootnum "$boot_num" --delete-bootnum >/dev/null
done
