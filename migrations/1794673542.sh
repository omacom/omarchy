echo "Drop the N1x rescue boot entry"

# N1x laptops booted a text-console rescue entry from a fallback UKI built with
# every module, which cost about a minute on every kernel update and install.
# Release firmware boots the GPU, and snapshots cover recovery. A rebuild with
# no fallback configured removes the fallback UKI and its menu entry.
conf="${OMARCHY_N1X_BOOT_ORDER_CONF:-/etc/limine-entry-tool.d/zz-omarchy-n1x-boot-order.conf}"
# Removing the drop-in also removes what this migration looks for, so a marker
# keeps the rebuild pending until it finishes: an interrupted run retries it.
pending="${OMARCHY_N1X_RESCUE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1794673542.pending}"

if [[ -f $conf ]]; then
  sudo install -Dm644 /dev/null "$pending"
  sudo rm -f "$conf"
fi

[[ -e $pending ]] || exit 0

sudo limine-mkinitcpio
sudo rm -f "$pending"
