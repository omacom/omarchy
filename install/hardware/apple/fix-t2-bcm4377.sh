# BCM4377 combo (Wi-Fi 14e4:4488, Bluetooth 14e4:5fa0) flakes on first Bluetooth
# probe and cannot enter D3, which aborts suspend. Other T2 chips do not share
# this; gate on the combo PCI IDs, not the T2 bridge. See
# https://github.com/omacom/omarchy/issues/11264
#
# Unload happens in a Before=sleep.target oneshot so NetworkManager can release
# the interface. A systemd-sleep hook runs after user.slice is frozen, and
# reloading brcmfmac the instant the machine wakes has hard-crashed this chip.
systemd_dir="${OMARCHY_T2_BCM4377_SYSTEMD_DIR:-/etc/systemd/system}"
sleep_hook="${OMARCHY_T2_BCM4377_SLEEP_HOOK:-/usr/lib/systemd/system-sleep/t2-wifi-suspend}"
omarchy_path="${OMARCHY_PATH:-/usr/share/omarchy}"
unit_dir="$omarchy_path/default/systemd/system"

if lspci -nn | grep -E "14e4:(4488|5fa0)" >/dev/null; then
  echo "Detected BCM4377 Wi-Fi/Bluetooth; installing boot rebind and suspend unload"

  mkdir -p "$systemd_dir"
  install -m 644 "$unit_dir/omarchy-t2-bcm4377-rebind.service" \
    "$systemd_dir/omarchy-t2-bcm4377-rebind.service"
  install -m 644 "$unit_dir/omarchy-t2-bcm4377-suspend.service" \
    "$systemd_dir/omarchy-t2-bcm4377-suspend.service"

  # Community workarounds that race these units on resume (immediate brcmfmac
  # reload) or duplicate the boot rebind.
  systemctl disable --now t2-brcmfmac-suspend.service >/dev/null 2>&1 || true
  systemctl disable --now bt-bcm4377-rebind.service >/dev/null 2>&1 || true
  systemctl disable --now t2-wifi-suspend.service >/dev/null 2>&1 || true
  rm -f "$sleep_hook"

  systemctl daemon-reload
  systemctl enable omarchy-t2-bcm4377-rebind.service
  systemctl enable omarchy-t2-bcm4377-suspend.service

  # ISO finalization is a chroot; starting the oneshot there cannot talk to a
  # real adapter. On a live system, unstick Bluetooth without waiting for reboot.
  if systemctl is-system-running >/dev/null 2>&1; then
    systemctl start omarchy-t2-bcm4377-rebind.service >/dev/null 2>&1 || true
  fi
fi
