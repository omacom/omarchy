echo "Keep the Snapdragon device tree list current when a kernel update brings new trees"

# See install/hardware/qualcomm/dtb-uki.sh. Installs made before it list the
# trees their first kernel had, so a later kernel's new or renamed tree never
# reaches the boot image and a machine whose hardware IDs moved to it boots
# without one.
uki_config=/etc/kernel/uki.conf
boot_hook=/etc/boot/hooks/pre.d/20-omarchy-qualcomm-device-trees

if ! omarchy-hw-aarch64-qualcomm || ! grep -Fqx "# BEGIN OMARCHY QUALCOMM DEVICE TREES" "$uki_config" 2>/dev/null; then
  exit 0
fi

if [[ ! -L $boot_hook ]]; then
  sudo mkdir -p "$(dirname "$boot_hook")"
  sudo ln -sfn /usr/bin/omarchy-update-qualcomm-device-trees "$boot_hook"
fi

listed=$(<"$uki_config")
sudo omarchy-update-qualcomm-device-trees

# A changed list needs one rebuild. The marker keeps that owed across an
# interrupted run, while another user's run finds the list current and skips it.
rebuild_pending=/var/lib/omarchy/migrations/1793989240-rebuild-pending
if [[ $(<"$uki_config") != "$listed" ]]; then
  sudo install -Dm644 /dev/null "$rebuild_pending"
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
