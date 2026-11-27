echo "Re-enable deep sleep (s2idle) on the ASUS Zenbook A16 (UX3607OA)"

# See install/hardware/asus/fix-asus-zenbook-a16-boot.sh. Full APSS + CXSD +
# AOSD + DDR deep sleep (~0.26 W) with reliable Wi-Fi/BT/audio resume requires
# linux-omarchy-dtbs >= 7.3-75 (s2idle-only cluster_cl5 and lid-switch fix) and
# asus-zenbook-a16-support >= 1-4 (s2idle config, PCIe4 wakeup udev rule, and
# systemd-sleep hook).
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

if omarchy-pkg-missing asus-zenbook-a16-support; then
  omarchy-pkg-add asus-zenbook-a16-support
fi

dtbs_ver=$(pacman -Q linux-omarchy-dtbs 2>/dev/null | awk '{print $2}') || dtbs_ver=""
support_ver=$(pacman -Q asus-zenbook-a16-support 2>/dev/null | awk '{print $2}') || support_ver=""

if [[ -z $dtbs_ver ]] || (( $(vercmp "$dtbs_ver" 7.3-75) < 0 )) ||
  [[ -z $support_ver ]] || (( $(vercmp "$support_ver" 1-4) < 0 )); then
  echo "Waiting for linux-omarchy-dtbs >= 7.3-75 and asus-zenbook-a16-support >= 1-4 before re-enabling suspend"
  exit 75
fi

if [[ ! -e /etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf && ! -e /etc/systemd/sleep.conf.d/zenbook-a16.conf ]]; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-a16-boot.sh"
  udevadm control --reload >/dev/null 2>&1 || true
  udevadm trigger --subsystem-match=pci --sysname-match=0004:00:00.0 >/dev/null 2>&1 || true
'
