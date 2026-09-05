echo "Rebuild the Plymouth theme into the initramfs so the entry-field clamp reaches the boot screen"

# The LUKS prompt is drawn by Plymouth from inside the initramfs, not from the
# on-disk theme, and no pacman hook rebuilds the image when usr/share/plymouth
# changes. Without this, existing installs keep the old boot script until an
# unrelated kernel or cryptsetup update happens to rebuild the image.
#
# omarchy-refresh-plymouth also reverts a custom unlock theme to the packaged
# default (#6864); whether the delivery path should survive that is the
# maintainer's call.
omarchy-refresh-plymouth
