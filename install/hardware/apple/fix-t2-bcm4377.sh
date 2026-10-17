# BCM4377 combo (Wi-Fi 14e4:4488, Bluetooth 14e4:5fa0) flakes on first Bluetooth
# probe and cannot enter D3, which aborts suspend. Other T2 chips do not share
# this; gate on the combo PCI IDs, not the T2 bridge. See
# https://github.com/omacom/omarchy/issues/11264
#
# Unload happens in a Before=sleep.target oneshot so NetworkManager can release
# the interface. The oneshot is RequiredBy=sleep.target: a failed unload must
# abort suspend, because ExecStop does not run for a start that failed and a
# bound hci_bcm4377 is what DPC-isolates the chip. Wi-Fi is loaded again from
# ExecStop, once the Wi-Fi function is back in D0.
systemd_dir="${OMARCHY_T2_BCM4377_SYSTEMD_DIR:-/etc/systemd/system}"
sleep_hook="${OMARCHY_T2_BCM4377_SLEEP_HOOK:-/usr/lib/systemd/system-sleep/t2-wifi-suspend}"
omarchy_path="${OMARCHY_PATH:-/usr/share/omarchy}"
unit_dir="$omarchy_path/default/systemd/system"
leaf_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
known_hook_dir="$leaf_dir/bcm4377-known-sleep-hooks"

# The published austinsomer hooks (the v3 transient unit and the v4 named
# unit) race this leaf and are safe to delete. Anything else under that
# filename is someone else's hook: systemd-sleep runs every executable in
# the directory, so keep the body but drop the executable bit and the name
# that sits in the hook path.
retire_sleep_hook() {
  local known retired n=1
  [[ -e $sleep_hook ]] || return 0

  if [[ -d $known_hook_dir ]]; then
    for known in "$known_hook_dir"/*; do
      [[ -f $known ]] || continue
      if cmp -s "$sleep_hook" "$known"; then
        rm -f "$sleep_hook"
        return 0
      fi
    done
  fi

  retired="${sleep_hook}.disabled"
  while [[ -e $retired ]]; do
    retired="${sleep_hook}.disabled.$n"
    n=$((n + 1))
  done
  mv "$sleep_hook" "$retired"
  chmod a-x "$retired"
  echo "Kept custom ${sleep_hook##*/} as ${retired##*/}; it is no longer executable, so systemd-sleep will not run it"
}

if lspci -nn | grep -E "14e4:(4488|5fa0)" >/dev/null; then
  echo "Detected BCM4377 Wi-Fi/Bluetooth; installing boot rebind and suspend unload"

  mkdir -p "$systemd_dir"
  install -m 644 "$unit_dir/omarchy-t2-bcm4377-rebind.service" \
    "$systemd_dir/omarchy-t2-bcm4377-rebind.service"
  install -m 644 "$unit_dir/omarchy-t2-bcm4377-suspend.service" \
    "$systemd_dir/omarchy-t2-bcm4377-suspend.service"
  install -m 644 "$unit_dir/omarchy-t2-bcm4377-reload.service" \
    "$systemd_dir/omarchy-t2-bcm4377-reload.service"
  install -m 644 "$unit_dir/omarchy-t2-bcm4377-recover.service" \
    "$systemd_dir/omarchy-t2-bcm4377-recover.service"

  # Community workarounds that race these units on resume (immediate brcmfmac
  # reload, or a second boot rebind). Disable only; a unit file with the same
  # name and local edits is left on disk.
  systemctl disable --now t2-brcmfmac-suspend.service >/dev/null 2>&1 || true
  systemctl disable --now bt-bcm4377-rebind.service >/dev/null 2>&1 || true
  systemctl disable --now t2-wifi-suspend.service >/dev/null 2>&1 || true
  systemctl disable --now t2-wifi-reload.service >/dev/null 2>&1 || true
  retire_sleep_hook

  systemctl daemon-reload
  systemctl enable omarchy-t2-bcm4377-rebind.service
  systemctl enable omarchy-t2-bcm4377-suspend.service

  # ISO finalization is a chroot, where is-system-running reports offline.
  # degraded is a working boot (a failed unit is enough) and still wants the
  # rebind now, rather than waiting for the next reboot.
  system_state=$(systemctl is-system-running 2>/dev/null || true)
  if [[ $system_state != offline ]]; then
    systemctl start omarchy-t2-bcm4377-rebind.service >/dev/null 2>&1 || true
  fi
fi
