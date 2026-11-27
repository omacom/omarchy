echo "Enable early-boot Thunderbolt dock sync and rebuild the boot image if needed"

# thunderbolt_dock.conf and the omarchy-thunderbolt-dock initcpio hook authorize
# already-enrolled (policy=auto) Thunderbolt peripheral docks during early boot
# so dock-attached keyboards and mice work at the Plymouth/LUKS unlock prompt.
# omarchy-thunderbolt-dock-sync.path watches /var/lib/boltd/devices so later
# enrollments, policy changes, and revocations keep the boot image in sync.
#
# Run the sync helper as root so enrollment is read with the same access as
# mkinitcpio (including root-only /var/lib/boltd stores). Machines with no
# policy=auto peripherals skip the boot image rebuild cleanly.

unit_file="${OMARCHY_TB_SYNC_PATH_UNIT:-/etc/systemd/system/omarchy-thunderbolt-dock-sync.path}"
rebuild_marker="${OMARCHY_TB_REBUILD_MARKER:-/var/lib/omarchy/migrations/1795549499}"
sync_cmd="${OMARCHY_TB_SYNC_CMD:-$(command -v omarchy-device-thunderbolt-sync 2>/dev/null || true)}"

if [[ ! -f $unit_file || -z $sync_cmd || ! -x $sync_cmd ]]; then
  echo "Waiting for the omarchy-settings package that ships early-boot Thunderbolt dock sync" >&2
  exit 75
fi

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# Enable the watcher once per machine so future boltd changes stay synced.
if ! systemctl is-enabled --quiet omarchy-thunderbolt-dock-sync.path 2>/dev/null; then
  if [[ -d /run/systemd/system ]]; then
    as_root systemctl daemon-reload >/dev/null 2>&1 || true
    as_root systemctl enable --now omarchy-thunderbolt-dock-sync.path >/dev/null 2>&1 || {
      echo "Could not enable omarchy-thunderbolt-dock-sync.path." >&2
      exit 1
    }
  else
    as_root systemctl enable omarchy-thunderbolt-dock-sync.path >/dev/null 2>&1 || {
      echo "Could not enable omarchy-thunderbolt-dock-sync.path." >&2
      exit 1
    }
  fi
elif [[ -d /run/systemd/system ]] && ! systemctl is-active --quiet omarchy-thunderbolt-dock-sync.path 2>/dev/null; then
  as_root systemctl start omarchy-thunderbolt-dock-sync.path >/dev/null 2>&1 || true
fi

# The initial boot-image sync is machine-wide: another user's migration must
# not repeat it, while a failed sync leaves the marker absent so it retries.
[[ ! -e $rebuild_marker ]] || exit 0

as_root "$sync_cmd"
as_root install -Dm644 /dev/null "$rebuild_marker"
