echo "Rebuild the boot image for early-boot Thunderbolt dock authorization"

# thunderbolt_dock.conf and the omarchy-thunderbolt-dock initcpio hook authorize
# already-enrolled (policy=auto) Thunderbolt peripheral docks during early boot
# so dock-attached keyboards and mice work at the Plymouth/LUKS unlock prompt.
# omarchy-settings installs the drop-in and hook files, but pacman does not
# rebuild the initramfs for a mkinitcpio drop-in change. Rebuild once on
# machines where the installed configuration activates the hook; non-dock
# machines leave HOOKS untouched and skip the rebuild without invoking sudo.

mkinitcpio_conf="${OMARCHY_MKINITCPIO_CONF:-/etc/mkinitcpio.conf}"
conf_dir="${OMARCHY_MKINITCPIO_CONF_DIR:-/etc/mkinitcpio.conf.d}"
install_hook="${OMARCHY_TB_INSTALL_HOOK:-/etc/initcpio/install/omarchy-thunderbolt-dock}"
rebuild_marker="${OMARCHY_TB_REBUILD_MARKER:-/var/lib/omarchy/migrations/1795097993}"

omarchy-cmd-present limine-mkinitcpio || exit 0
[[ -f $install_hook && -f $conf_dir/thunderbolt_dock.conf ]] || exit 0

# The rebuild is machine-wide: another user's migration must not repeat it.
[[ ! -e $rebuild_marker ]] || exit 0

# Evaluate the configuration the way mkinitcpio does, the main file and then
# every drop-in in LC_ALL=C.UTF-8 order, and rebuild only when the hook is
# active. Skip conservatively if evaluation fails.
hooks=$(bash -c '
  mapfile -d "" conf_files < <(LC_ALL=C.UTF-8 find "$2" -maxdepth 1 -xtype f -name "*.conf" -print0 2>/dev/null |
    LC_ALL=C.UTF-8 sort -zVu)
  source <(cat -- "$1" "${conf_files[@]}" 2>/dev/null) || exit 1
  printf " %s " "${HOOKS[*]}"
' -- "$mkinitcpio_conf" "$conf_dir") || exit 0
[[ $hooks == *" omarchy-thunderbolt-dock "* ]] || exit 0

echo "Rebuilding the boot image with early-boot Thunderbolt dock authorization"
rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# Keep the migration pending if any kernel failed to rebuild.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
