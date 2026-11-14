echo "Add Surface keyboard modules to the boot image on existing AMD installations"

omarchy-hw-surface || exit 0
omarchy-hw-x86 || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0
pinctrl_module=$(lsmod | grep pinctrl_ || true)
[[ -z $pinctrl_module ]] || exit 0

rebuild_marker="/var/lib/omarchy/migrations/1794106576"
[[ ! -e $rebuild_marker ]] || exit 0

if [[ ! -e /etc/mkinitcpio.conf.d/surface_device_modules.conf ]]; then
  sudo bash -e "$OMARCHY_PATH/install/hardware/fix-surface-keyboard.sh"
fi

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
omarchy-state set reboot-required
