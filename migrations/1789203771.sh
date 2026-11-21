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

if omarchy-cmd-present limine-mkinitcpio; then
  # limine-mkinitcpio reports kernels it could not rebuild and still exits 0,
  # so a successful exit proves nothing. A marker over a failed build would
  # hide the off-screen entry field from every later run.
  build_log=$(mktemp)
  trap 'rm -f "$build_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$build_log"
  if grep -q 'mkinitcpio failed for kernel' "$build_log"; then
    echo "The boot image rebuild failed; rerun omarchy-migrate once the build is fixed." >&2
    exit 1
  fi
else
  sudo mkinitcpio -P
fi
sudo install -Dm644 /dev/null "$rebuild_marker"
