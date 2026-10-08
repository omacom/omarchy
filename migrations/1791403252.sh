echo "Make the Surface keyboard modules append to MODULES so earlier modules stay in the initramfs"

# The installer wrote surface_device_modules.conf as MODULES=(...), which sorts
# after nvidia.conf and so dropped its nvidia modules from every initramfs (#7111).

surface_conf="${OMARCHY_SURFACE_MKINITCPIO_CONF:-/etc/mkinitcpio.conf.d/surface_device_modules.conf}"
rebuild_marker="${OMARCHY_SURFACE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1791403252}"

[[ -f $surface_conf ]] || exit 0

# Only the file the installer wrote, one or more pinctrl modules included; a
# hand-written one is left as its author meant it.
installer_modules="surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw"
installer_pattern="^MODULES(\+?)=\(pinctrl_[[:alnum:]_]+([[:space:]]+pinctrl_[[:alnum:]_]+)* ${installer_modules}\)$"
[[ $(<"$surface_conf") =~ $installer_pattern ]] || exit 0

if [[ -z ${BASH_REMATCH[1]} ]]; then
  sudo sed -i '1s/^MODULES=(/MODULES+=(/' "$surface_conf"
fi

# The marker lets another user's run skip a finished rebuild while still
# retrying an interrupted one.
[[ ! -e $rebuild_marker ]] || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
