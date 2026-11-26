echo "Enable Panel Self Refresh on the ASUS Zenbook A16 (UX3607OA)"

# See install/hardware/asus/fix-asus-zenbook-a16-boot.sh. Adds msm.psr_enabled=1
# to the zenbook-a16 boot drop-in and rebuilds the boot image once per machine.
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1795725833}"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-a16-boot.sh"
'

if [[ ! -e $rebuild_marker ]]; then
  if ! sudo omarchy-boot-rebuild; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  sudo install -Dm644 /dev/null "$rebuild_marker"
  omarchy-state set reboot-required
fi
