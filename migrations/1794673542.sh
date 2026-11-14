echo "Drop the N1x rescue boot entry"

# N1x laptops booted a text-console rescue entry from a fallback UKI built with
# every module, which cost about a minute on every kernel update and install.
# Release firmware boots the GPU, and snapshots cover recovery. A rebuild with
# no fallback configured removes the fallback UKI and its menu entry.
conf="${OMARCHY_N1X_BOOT_ORDER_CONF:-/etc/limine-entry-tool.d/zz-omarchy-n1x-boot-order.conf}"

[[ -f $conf ]] || exit 0

sudo rm -f "$conf"
sudo limine-mkinitcpio
