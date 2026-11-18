echo "Mark the T2 Mac t2bce_vhci initramfs module optional so other kernels build"

# Only linux-t2 ships t2bce, so a bare t2bce_vhci in MODULES fails the initramfs
# build for linux-omarchy installed next to it and leaves that kernel's UKI stale.
# The 4.5.0 installer then wrote zz-omarchy-kernel-modules.conf, which takes a
# module out of every image when any kernel lacks it, so linux-t2 lost it too
# and the internal keyboard was gone at the LUKS prompt. That filter matches
# exact names, so t2bce_vhci? stays in the linux-t2 image.

conf="${OMARCHY_T2_MKINITCPIO_CONF:-/etc/mkinitcpio.conf.d/apple-t2.conf}"
rebuild_pending="${OMARCHY_T2_REBUILD_PENDING:-/var/lib/omarchy/migrations/1793464570.rebuild-pending}"

# The marker goes down before the edit and comes off only after a clean
# rebuild, so a rebuild that fails or is interrupted runs again next time.
# The trailing space matches the bare name fix-t2.sh wrote, and skips the
# "apple-bce? t2bce_vhci? " that migration 1785273276 wrote.
if [[ -f $conf ]] && grep -q 't2bce_vhci ' "$conf"; then
  sudo install -Dm644 /dev/null "$rebuild_pending"
  sudo sed -i 's/t2bce_vhci /t2bce_vhci? /' "$conf"
fi
[[ -e $rebuild_pending ]] || exit 0

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
if omarchy-cmd-present limine-mkinitcpio; then
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"
else
  sudo mkinitcpio -P 2>&1 | tee "$rebuild_log"
fi

# limine-mkinitcpio reports a kernel it could not rebuild and may still exit 0.
# A failed mkinitcpio -P exits non-zero and stops the migration above.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo rm -f "$rebuild_pending"
