echo "Enable CPU frequency limits for power profiles on Intel CPUs without HWP"

if omarchy-hw-intel-no-hwp && omarchy-battery-present; then
  source "$OMARCHY_PATH/install/hardware/intel/cpu-profile-limits.sh"
  sudo systemctl start omarchy-powerprofiles-intel-no-hwp-watch.service
fi
