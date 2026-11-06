echo "Rebuild the boot image so a non-Latin keyboard layout stays out of the LUKS prompt"

# Since 26.134.222-3, Arch's plymouth hook copies vconsole.conf into the
# initramfs itself, although omarchy_hooks.conf leaves it out of FILES for a
# first layout that types no Latin letters. Plymouth then asks for the LUKS
# passphrase in that layout, and it cannot be typed (#14246).
# omarchy_vconsole.conf now refuses the file unless FILES lists it, but nothing
# rebuilds the boot image when a drop-in changes, so an image built since
# plymouth updated still holds it.

mkinitcpio_conf="${OMARCHY_MKINITCPIO_CONF:-/etc/mkinitcpio.conf}"
conf_dir="${OMARCHY_MKINITCPIO_CONF_DIR:-/etc/mkinitcpio.conf.d}"
vconsole_conf="${OMARCHY_VCONSOLE_CONF:-/etc/vconsole.conf}"
plymouth_hook="${OMARCHY_PLYMOUTH_INSTALL_HOOK:-/usr/lib/initcpio/install/plymouth}"
rebuild_marker="${OMARCHY_VCONSOLE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1791621765}"

omarchy-cmd-present limine-mkinitcpio || exit 0
[[ -f $plymouth_hook ]] || exit 0

# The rebuild is machine-wide: another user's migration must not repeat it.
[[ ! -e $rebuild_marker ]] || exit 0

# Only a plymouth hook that copies the file itself can have put it in the image.
grep -q 'vconsole\.conf' "$plymouth_hook" || exit 0

# Evaluate the configuration the way mkinitcpio does, the main file and then
# every drop-in sourced as one, and rebuild only where its final FILES now
# leaves the file out. Skip conservatively if evaluation fails.
added=$(bash -c '
  unset XKBLAYOUT
  add_file() { echo added; }
  source <(cat -- "$1" "$2"/*.conf 2>/dev/null) || exit 1
  add_file "$3"
' -- "$mkinitcpio_conf" "$conf_dir" "$vconsole_conf") || exit 0
[[ -z $added ]] || exit 0

echo "Rebuilding the boot image without the non-Latin keyboard layout"
rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# That kernel's image keeps the file, so the migration stays pending.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
