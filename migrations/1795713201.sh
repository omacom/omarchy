echo "Enable Panther Lake low-power mode in intel-lpmd"

omarchy-hw-intel && omarchy-battery-present || exit 0
omarchy-pkg-present intel-lpmd || exit 0
systemctl is-enabled --quiet intel_lpmd.service || exit 0

cpu_model=$(grep -m1 "^model\s*:" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | tr -d ' ')
[[ $cpu_model == "204" ]] || exit 0

sudo env PATH="$OMARCHY_PATH/bin:$PATH" OMARCHY_PATH="$OMARCHY_PATH" OMARCHY_LPMD_CONFIG_ONLY=1 bash -e "$OMARCHY_PATH/install/hardware/intel/lpmd.sh"

if sudo systemctl is-active --quiet intel_lpmd.service; then
  sudo systemctl restart intel_lpmd.service
fi
