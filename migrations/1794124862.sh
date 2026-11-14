echo "Lower the CPU power limits in power-saver on AMD Raven, Picasso and Dali laptops"

if omarchy-hw-amd-raven && omarchy-battery-present; then
  source "$OMARCHY_PATH/install/hardware/amd/raven-power-saver-limits.sh"
  sudo systemctl start omarchy-cpu-limits.service
fi
