echo "Rebuild the Plymouth theme into the initramfs so the entry-field clamp reaches the boot screen"

# The LUKS prompt is drawn by Plymouth from inside the initramfs, not from the
# on-disk theme, and no pacman hook rebuilds the image when usr/share/plymouth
# changes. Without this, existing installs keep the old boot script until an
# unrelated kernel or cryptsetup update happens to rebuild the image.
#
# omarchy-refresh-plymouth also reverts a custom unlock theme to the packaged
# default (#6864); whether the delivery path should survive that is the
# maintainer's call.

rebuild_marker="${OMARCHY_PLYMOUTH_CLAMP_REBUILD_MARKER:-/var/lib/omarchy/migrations/1789203771}"

# The rebuild is machine-wide, but migrations run once per user: a marker
# records completion so another user's run does not repeat it.
[[ ! -e $rebuild_marker ]] || exit 0

omarchy-refresh-plymouth
sudo install -Dm644 /dev/null "$rebuild_marker"
