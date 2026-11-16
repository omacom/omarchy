echo "Boot the LCD Surface Pro 11 (Snapdragon X Plus) on its own device tree"

# See install/hardware/microsoft/surface-pro-11.sh. Installs made before it
# told the models apart pinned the OLED model's tree on the LCD model too, so
# its brightness never changed and six of its ten cores had no cpufreq.
uki_config=/etc/kernel/uki.conf
soc_id=/sys/devices/soc0/soc_id

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match-device-tree microsoft,denali ||
  [[ ! -r $soc_id || $(<"$soc_id") != "615" ]]; then
  exit 0
fi

# The marker records the setup and rebuild as owed before the setup changes
# the pin. The setup pins the tree before it writes the early modules and adds
# the packages, so a retry reruns all of it while the marker is there, not only
# when the pin is missing. Another user's run finds the LCD tree pinned and
# nothing owed.
rebuild_pending=/var/lib/omarchy/migrations/1794228778-rebuild-pending
if [[ -e $rebuild_pending ]] || ! grep -q '^DeviceTree=.*/x1p64100-microsoft-denali\.dtb$' "$uki_config" 2>/dev/null; then
  sudo install -Dm644 /dev/null "$rebuild_pending" || exit 1
  sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
    source "$OMARCHY_PATH/install/hardware/microsoft/surface-pro-11.sh"
  '
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
