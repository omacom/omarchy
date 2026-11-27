echo "Re-enable deep sleep (s2idle) on the ASUS Zenbook A16 (UX3607OA)"

# Full APSS + CXSD + AOSD + DDR deep sleep (~0.26 W) with reliable
# Wi-Fi/BT/audio/lid resume requires linux-omarchy-dtbs >= 7.3-75 (s2idle-only
# cluster_cl5 and lid-switch fix) booted on the running kernel, plus
# asus-zenbook-a16-support >= 1-4 (s2idle config, PCIe4 wakeup udev rule, and
# systemd-sleep hook).
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

sleep_config_dir="${OMARCHY_SLEEP_CONFIG_DIR:-/etc/systemd/sleep.conf.d}"
dt_root="${OMARCHY_DT_ROOT:-/sys/firmware/devicetree/base}"

# Nothing to clean up on fresh installs or if another user already migrated.
if [[ ! -e $sleep_config_dir/omarchy-sleep-disabled.conf && ! -e $sleep_config_dir/zenbook-a16.conf ]]; then
  exit 0
fi

omarchy-pkg-add asus-zenbook-a16-support || exit 75

dtbs_ver=$(pacman -Q linux-omarchy-dtbs 2>/dev/null | awk '{print $2}') || dtbs_ver=""
support_ver=$(pacman -Q asus-zenbook-a16-support 2>/dev/null | awk '{print $2}') || support_ver=""

if [[ -z $dtbs_ver ]] || (( $(vercmp "$dtbs_ver" 7.3-75) < 0 )) ||
  [[ -z $support_ver ]] || (( $(vercmp "$support_ver" 1-4) < 0 )); then
  echo "Waiting for linux-omarchy-dtbs >= 7.3-75 and asus-zenbook-a16-support >= 1-4 before re-enabling suspend"
  exit 75
fi

# Packages may be upgraded while the previous device tree is still active in
# memory. Keep suspend disabled and ask for a reboot until the running tree
# carries both the s2idle-only cluster_cl5 state (1000 s = 0x3b9aca00) and the
# switch-lid fix (no wakeup-event-action).
cl5_residency_file="$dt_root/cpus/domain-idle-states/cluster-sleep-0/min-residency-us"
cl5_residency=""
if [[ -r $cl5_residency_file ]]; then
  cl5_residency=$(od -An -tx4 --endian=big "$cl5_residency_file" 2>/dev/null | tr -d '[:space:]') || cl5_residency=""
fi

if [[ $cl5_residency != "3b9aca00" ]] ||
  [[ ! -e $dt_root/psci/power-domain-cpu-cluster0/domain-idle-states ]] ||
  [[ -e $dt_root/gpio-keys/switch-lid/wakeup-event-action ]]; then
  omarchy-state set reboot-required
  echo "Reboot required to load the updated ASUS Zenbook A16 device tree before re-enabling suspend"
  exit 75
fi

sudo rm -f "$sleep_config_dir/omarchy-sleep-disabled.conf" "$sleep_config_dir/zenbook-a16.conf"
sudo udevadm control --reload >/dev/null 2>&1 || true
sudo udevadm trigger --subsystem-match=pci --sysname-match=0004:00:00.0 >/dev/null 2>&1 || true
