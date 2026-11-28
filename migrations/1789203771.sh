echo "Rebuild the Plymouth theme into the initramfs so the entry-field clamp reaches the boot screen"

# The LUKS prompt is drawn by Plymouth from inside the initramfs, not from the
# on-disk theme, and no pacman hook rebuilds the image when usr/share/plymouth
# changes. The package update already replaced the on-disk theme, including the
# clamped script, so a plain rebuild delivers it. Republishing the packaged
# assets would reset a custom unlock theme instead of just rebuilding.

rebuild_marker=/var/lib/omarchy/migrations/1789203771

# The rebuild is machine-wide, but migrations run once per user: a marker
# records completion so another user's run does not repeat it.
[[ ! -e $rebuild_marker ]] || exit 0

# Theme colours may be customised; the rest must match before a rebuild can
# deliver this checkout's fix and safely record completion.
if ! diff -I '^Window\.SetBackground' "$OMARCHY_PATH/default/plymouth/omarchy.script" /usr/share/plymouth/themes/omarchy/omarchy.script >/dev/null; then
  echo "Waiting for omarchy-settings to provide the current Plymouth script." >&2
  exit 75
fi

# Use the Plymouth setter's fallback for boot loaders Omarchy does not manage.
if [[ $(omarchy-boot-backend) == "none" ]]; then
  rebuild=(mkinitcpio -P)
else
  rebuild=(omarchy-boot-rebuild)
fi

# A failed rebuild leaves the migration pending on either path.
if ! sudo "${rebuild[@]}"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
