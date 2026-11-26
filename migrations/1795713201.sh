echo "Enable Panther Lake low-power mode in intel-lpmd"

omarchy-hw-intel && omarchy-battery-present || exit 0

cpu_model=$(grep -m1 "^model\s*:" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | tr -d ' ')
[[ $cpu_model == "204" ]] || exit 0

sudo env PATH="$OMARCHY_PATH/bin:$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -e "$OMARCHY_PATH/install/hardware/intel/lpmd.sh"

if sudo systemctl is-active --quiet intel_lpmd.service; then
  sudo systemctl restart intel_lpmd.service
else
  sudo systemctl start intel_lpmd.service
fi
