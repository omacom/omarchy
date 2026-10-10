echo "Add Surface keyboard modules to the boot image on existing AMD installations"

omarchy-hw-surface || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0
pinctrl_module=$(lsmod | grep pinctrl_ || true)
[[ -z $pinctrl_module ]] || exit 0

rebuild_marker="/var/lib/omarchy/migrations/1791345415"
[[ ! -e $rebuild_marker ]] || exit 0

if [[ ! -e /etc/mkinitcpio.conf.d/surface_device_modules.conf ]]; then
  sudo bash -e "$OMARCHY_PATH/install/hardware/fix-surface-keyboard.sh"
fi

# A failed kernel build can be skipped without failing limine-mkinitcpio.
rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"
if grep -q -e "ERROR:" -e "WARNING: failed to process kernel" "$rebuild_log" ||
  ! grep -q -e "Initcpio image generation successful" -e "Unified kernel image generation successful" "$rebuild_log"; then
  echo "Surface boot image rebuild did not complete. Rerun omarchy-migrate after fixing the build." >&2
  exit 1
fi
sudo install -Dm644 /dev/null "$rebuild_marker"
