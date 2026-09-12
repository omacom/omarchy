echo "Mark T2 MacBook built-in trackpads as internal"

source_hwdb="$OMARCHY_PATH/install/hardware/apple/t2-trackpad.hwdb"
target_hwdb="${OMARCHY_T2_TRACKPAD_HWDB:-/etc/udev/hwdb.d/71-omarchy-t2-trackpad.hwdb}"

# Existing T2 installs already passed the hardware installer, so repair them on
# update. Keep the same PCI gate as fix-t2.sh and only rebuild the hwdb when the
# shipped rule differs from what is installed.
if lspci -nn | grep "106b:180[12]" >/dev/null; then
  if ! cmp -s "$source_hwdb" "$target_hwdb"; then
    sudo install -Dm644 "$source_hwdb" "$target_hwdb"
    sudo systemd-hwdb update
    # A failed live retrigger is non-fatal. Even a successful action=change may
    # not recreate libinput's existing device, so a new session is the reliable
    # point at which the static integration property is consumed.
    sudo udevadm trigger --subsystem-match=input --action=change || true
    echo "Log out and back in or reboot to activate disable-while-typing on the internal trackpad."
  fi
fi
