echo "Embed the machine's own device tree in a Snapdragon boot image"

# See install/hardware/qualcomm/dtb-uki.sh. The boot image carried every
# Snapdragon device tree for systemd-stub to choose from by SMBIOS data; it now
# also carries the one this machine runs on, to fall back on. The Surface Pro 11
# already pins its own tree in microsoft/surface-pro-11.sh. A machine with no
# single matching tree keeps the list alone, so its boot image is left as it is.
uki_config=/etc/kernel/uki.conf
rebuild_marker=/var/lib/omarchy/migrations/1793663784

if omarchy-hw-aarch64-qualcomm && ! omarchy-hw-match-device-tree microsoft,denali-oled; then
  sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
    source "$OMARCHY_PATH/install/hardware/qualcomm/dtb-uki.sh"
  '

  # A marker records the machine-wide rebuild: another user's run must not repeat
  # it, while a missing marker still retries an interrupted rebuild. The config
  # keeps whatever permissions it had, so root reads it; a missing one pinned
  # nothing.
  if [[ ! -e $rebuild_marker ]] && sudo grep -qs '^DeviceTree=' "$uki_config"; then
    rebuild_log=$(mktemp)
    trap 'rm -f "$rebuild_log"' EXIT
    sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

    # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
    if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
      echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again." >&2
      exit 1
    fi

    sudo install -Dm644 /dev/null "$rebuild_marker"
  fi
fi
