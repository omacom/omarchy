echo "Drop the N1x rescue entry and pacman hook that the fallback entry replaces"

# Installs that ran the n1x-xps16 branch built the N1x rescue entry as its own
# UKI (linux-omarchy-n1x-rescue) and rebuilt it from a pacman hook running
# omarchy-refresh-n1x-rescue. limine-mkinitcpio-hook's fallback entry replaces
# both (1791077437), and that command is gone, so the hook would fail on every
# kernel update while the old entry kept booting the kernel it was built from.
hook="${OMARCHY_N1X_RESCUE_HOOK:-/etc/pacman.d/hooks/zz-omarchy-n1x-rescue.hook}"

[[ -f $hook ]] || exit 0

sudo limine-entry-tool --remove-uki linux-omarchy-n1x-rescue --quiet 2>/dev/null || true
sudo rm -f "$hook"
