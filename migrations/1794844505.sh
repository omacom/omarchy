echo "Build Snapdragon boot images with a stub that holds every device tree"

# linux-omarchy-dtbs 7.3-42 ships more Snapdragon device trees than Arch Linux
# ARM's systemd stub has header room for, so ukify stops building the boot
# image. systemd-stub-omarchy is the same stub with room for all of them, and
# omarchy-update-qualcomm-device-trees names it in the UKI configuration once
# it is installed. The image is rebuilt, as the last kernel update's build may
# have failed. The marker records the rebuild as owed before the package is
# added, so a retry rebuilds even when the package is already there.
if ! omarchy-hw-aarch64-qualcomm || ! grep -Fqx '# BEGIN OMARCHY QUALCOMM DEVICE TREES' /etc/kernel/uki.conf 2>/dev/null; then
  exit 0
fi

rebuild_pending=/var/lib/omarchy/migrations/1794844505-rebuild-pending
if [[ -e $rebuild_pending ]] || omarchy-pkg-missing systemd-stub-omarchy; then
  sudo install -Dm644 /dev/null "$rebuild_pending" || exit 1
  omarchy-pkg-add systemd-stub-omarchy || exit 1
fi

if [[ -e $rebuild_pending ]]; then
  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  sudo rm -f "$rebuild_pending"
  omarchy-state set reboot-required
fi
