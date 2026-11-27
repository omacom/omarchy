echo "Enable intel-lpmd dynamic WLT optimization on Meteor Lake laptops"

if ! omarchy-hw-intel || ! omarchy-battery-present; then
  exit 0
fi

cpu_model=$(grep -m1 "^model[[:space:]]*:" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | tr -d ' ')
[[ $cpu_model == "170" ]] || exit 0

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/intel/lpmd.sh"
  systemctl daemon-reload
  systemctl try-restart intel_lpmd.service
'
