echo "Make the Surface keyboard modules append to MODULES so earlier modules stay in the initramfs"

# The installer wrote surface_device_modules.conf as MODULES=(...), which sorts
# after nvidia.conf and so dropped its nvidia modules from every initramfs (#7111).

surface_conf=/etc/mkinitcpio.conf.d/surface_device_modules.conf
rebuild_marker=/var/lib/omarchy/migrations/1793487813

[[ -f $surface_conf ]] || exit 0

# Only a file an installer wrote, with or without pinctrl modules; a
# hand-written one is left as its author meant it.
installer_modules="surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw"
installer_pattern="^MODULES(\+?)=\((pinctrl_[[:alnum:]_]+([[:space:]]+pinctrl_[[:alnum:]_]+)*)? ${installer_modules}\)$"
[[ $(<"$surface_conf") =~ $installer_pattern ]] || exit 0

if [[ -z ${BASH_REMATCH[1]} ]]; then
  sudo sed -i '1s/^MODULES=(/MODULES+=(/' "$surface_conf"
fi

# The marker lets another user's run skip a finished rebuild while still
# retrying an interrupted one.
[[ ! -e $rebuild_marker ]] || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# That kernel's image still lacks the NVIDIA modules, so the migration stays pending.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
