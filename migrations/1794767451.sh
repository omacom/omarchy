echo "Boot the LCD IdeaPad Slim 5x on its own device tree"

# See install/hardware/lenovo/ideapad-slim-5x.sh. Installs made before it told
# the models apart boot the LCD model on the OLED tree, so its brightness
# never changes.
uki_config=/etc/kernel/uki.conf

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match-device-tree lenovo,ideapad-slim5x-oled lenovo,ideapad-slim5x-lcd; then
  exit 0
fi

# The marker records the setup and rebuild as owed before the setup changes the
# pin, so a retry reruns both while it is there, not only when the pin is
# missing. The setup pins nothing on the OLED model, which then owes nothing.
rebuild_pending=/var/lib/omarchy/migrations/1794767451-rebuild-pending
lcd_pinned() {
  grep -q '^DeviceTree=.*/x1p42100-lenovo-ideapad-slim5x-lcd\.dtb$' "$uki_config" 2>/dev/null
}
if [[ -e $rebuild_pending ]] || ! lcd_pinned; then
  sudo install -Dm644 /dev/null "$rebuild_pending" || exit 1
  sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
    source "$OMARCHY_PATH/install/hardware/lenovo/ideapad-slim-5x.sh"
  '
  if ! lcd_pinned; then
    sudo rm -f "$rebuild_pending"
  fi
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
