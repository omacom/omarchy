echo "Enable Intel HWP dynamic boost for snappier I/O wakeups"

boost=/sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost
dropin=/etc/tmpfiles.d/omarchy-intel-hwp-boost.conf

[[ -r $boost ]] || exit 0

# A dev checkout can run ahead of omarchy-settings: stay pending until the
# drop-in lands so the setting persists across reboots too.
if [[ ! -r $dropin ]]; then
  echo "Waiting for omarchy-settings to ship $dropin"
  exit 75
fi

current=$(<"$boost")
if [[ $current == "1" ]]; then
  exit 0
fi

sudo systemd-tmpfiles --create --boot "$dropin"
