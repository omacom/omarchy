echo "Tune Intel HWP dynamic boost and energy efficiency with power profiles"

if ! omarchy-hw-intel || [[ ! -e /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost ]]; then
  exit 0
fi

if [[ ! -x /usr/bin/omarchy-powerprofiles-intel ]]; then
  echo "Waiting for omarchy to ship /usr/bin/omarchy-powerprofiles-intel"
  exit 75
fi

if [[ ! -e /etc/systemd/system/omarchy-powerprofiles-intel.service ]]; then
  sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
    source "$OMARCHY_PATH/install/hardware/intel/pstate.sh"
  '
fi

if ! systemctl is-active --quiet omarchy-powerprofiles-intel.service; then
  sudo systemctl start omarchy-powerprofiles-intel.service
fi
