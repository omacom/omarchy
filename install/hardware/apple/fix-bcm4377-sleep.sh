# BCM4377 (PCI 14e4:4488) firmware does not acknowledge HOST_D3_INFORM, so
# brcmfmac returns EIO and the kernel aborts suspend. The sleep unit unloads
# that driver first, holds the Apple NVMe controller and the T2 functions out
# of d3cold for the sleep, and restores the previous d3cold values afterwards.
#
# BCM4364 (14e4:4464) is a different firmware bug and is left bound. This leaf
# does not select a sleep mode. Machines that already sleep deeply keep doing so.

if omarchy-hw-aarch64-apple; then
  return 0
fi

if ! lspci -nn | grep '14e4:4488' >/dev/null; then
  return 0
fi

echo "Detected BCM4377; installing the sleep workaround"

systemd_dir=${OMARCHY_WIFI_BCM4377_SYSTEMD_DIR:-/etc/systemd/system}
unit_name=omarchy-wifi-bcm4377-sleep.service
unit_src="$OMARCHY_PATH/default/systemd/system/$unit_name"

mkdir -p "$systemd_dir"
install -m 644 "$unit_src" "$systemd_dir/$unit_name"
systemctl enable "$unit_name"
