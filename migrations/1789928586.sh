echo "Retain the installed ARM Limine recovery packages during orphan cleanup"

[[ $(uname -m) == "aarch64" && -f ${OMARCHY_LIMINE_CONF:-/etc/default/limine} ]] || exit 0

# ARM also supports boot stacks such as Asahi's, so the runtime package cannot
# depend on Limine unconditionally. The ISO installs its chosen stack explicitly;
# older ARM installations can still have these packages marked as dependencies.
# Preserve only installed packages, without installing a different boot stack.
mapfile -t recovery_packages < <(pacman -Qqd limine limine-mkinitcpio-hook limine-snapper-sync snapper 2>/dev/null)

if (( ${#recovery_packages[@]} )); then
  sudo pacman -D --asexplicit "${recovery_packages[@]}"
fi
