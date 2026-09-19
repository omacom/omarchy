echo "Remove the installer limine hook that overwrites a signed limine_x64.efi"

# The ISO dropped /etc/pacman.d/hooks/99-omarchy-limine.hook, which runs after
# limine-install and copies unsigned BOOTX64.EFI over the just-signed binary.
# On Secure Boot systems a limine-only update then fails the next boot (#10945).
# limine's own 80-limine-efi-deploy.hook already deploys and signs correctly.

hook="${OMARCHY_LIMINE_PACMAN_HOOK:-/etc/pacman.d/hooks/99-omarchy-limine.hook}"
efi="${OMARCHY_LIMINE_EFI:-/boot/EFI/limine/limine_x64.efi}"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

if [[ -e $hook ]]; then
  as_root rm -f -- "$hook"
fi

# Re-sign if sbctl is present and the file still looks unsigned / exists.
if omarchy-cmd-present sbctl && [[ -f $efi ]]; then
  as_root sbctl sign -s "$efi" >/dev/null 2>&1 || true
fi
