echo "Enable intel-lpmd dynamic WLT optimization on Meteor Lake laptops"

if ! omarchy-hw-intel || ! omarchy-battery-present; then
  exit 0
fi

cpu_model=$(grep -m1 "^model\s*:" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | tr -d ' ')
[[ $cpu_model == "170" ]] || exit 0

config=/etc/intel_lpmd/omarchy-mtl.xml
dropin=/etc/systemd/system/intel_lpmd.service.d/10-omarchy-mtl.conf

# A dev checkout can run ahead of omarchy-settings: stay pending until the
# shipped config file lands so the service override points at an existing file.
if [[ ! -r $config ]]; then
  echo "Waiting for omarchy-settings to ship $config"
  exit 75
fi

if [[ -f $dropin ]] && systemctl is-enabled --quiet intel_lpmd.service 2>/dev/null &&
  systemctl show -p ExecStart --value intel_lpmd.service 2>/dev/null | grep -qF "$config"; then
  if ! systemctl is-active --quiet intel_lpmd.service; then
    exit 0
  fi
  main_pid=$(systemctl show -p MainPID --value intel_lpmd.service 2>/dev/null || true)
  if [[ -n $main_pid && $main_pid != "0" && -r /proc/$main_pid/cmdline ]] &&
    tr '\0' ' ' <"/proc/$main_pid/cmdline" | grep -qF -- "-c $config"; then
    exit 0
  fi
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/intel/lpmd.sh"
  systemctl daemon-reload
  systemctl try-restart intel_lpmd.service
'
