echo "Install the GB10 power telemetry driver, so whole-system power shows in hwmon"

# Existing GB10 installs predate spark-hwmon-dkms in the GB10 package list.
omarchy-hw-aarch64-gb10 || exit 0
omarchy-pkg-add spark-hwmon-dkms

# udev loads the module for the NVDA8800 firmware device only at boot. DKMS
# builds it for the installed kernels, so a running kernel that was replaced
# in the same update has no copy, and the sensors wait for the reboot.
[[ -d /sys/module/spbm ]] && exit 0
if modinfo spbm &>/dev/null; then
  sudo modprobe spbm
else
  omarchy-state set reboot-required
fi
