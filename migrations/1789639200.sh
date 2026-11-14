echo "Remove the installer limine hook that overwrites a signed limine_x64.efi"

# The ISO dropped /etc/pacman.d/hooks/99-omarchy-limine.hook. On UEFI that hook
# copies unsigned BOOTX64.EFI over the just-signed binary after limine-install,
# so a limine-only update fails the next Secure Boot (#10945). BIOS installs use
# the same filename for a bios-install / limine-bios.sys deploy — leave that
# variant alone. limine's 80-limine-efi-deploy.hook already deploys and signs
# the UEFI path correctly.

hook="${OMARCHY_LIMINE_PACMAN_HOOK:-/etc/pacman.d/hooks/99-omarchy-limine.hook}"
efi="${OMARCHY_LIMINE_EFI:-/boot/EFI/limine/limine_x64.efi}"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

if [[ -e $hook ]] && as_root grep -Fq 'BOOTX64.EFI' "$hook"; then
  as_root rm -f -- "$hook"
fi

# Re-sign if sbctl is present. On a root-only ESP the invoking user cannot
# see the file; probe and sign as root.
if omarchy-cmd-present sbctl && as_root test -f "$efi"; then
  as_root sbctl sign -s "$efi" >/dev/null 2>&1 || true
fi
