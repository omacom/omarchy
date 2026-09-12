echo "Rebind BCM4377 Bluetooth after boot and unload the combo chip around suspend"

# Existing T2 installs load hci_bcm4377 but leave a hung adapter (Powered: yes,
# class 0x00000000) and cannot suspend: brcmfmac times out entering D3. Gate on
# the combo PCI IDs so other T2 chips are left alone. See
# install/hardware/apple/fix-t2-bcm4377.sh and omacom/omarchy#11264.

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

if ! lspci -nn | grep -E "14e4:(4488|5fa0)" >/dev/null; then
  exit 0
fi

as_root env \
  OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}" \
  OMARCHY_T2_BCM4377_SYSTEMD_DIR="${OMARCHY_T2_BCM4377_SYSTEMD_DIR:-/etc/systemd/system}" \
  OMARCHY_T2_BCM4377_SLEEP_HOOK="${OMARCHY_T2_BCM4377_SLEEP_HOOK:-/usr/lib/systemd/system-sleep/t2-wifi-suspend}" \
  bash -euo pipefail -c 'source "$1"' bash "$OMARCHY_PATH/install/hardware/apple/fix-t2-bcm4377.sh"
