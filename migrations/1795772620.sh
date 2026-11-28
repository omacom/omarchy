echo "Install and enable intel-lpmd on Arrow Lake-U and Wildcat Lake Intel laptops"

if ! omarchy-hw-intel || ! omarchy-battery-present; then
  exit 0
fi

cpu_model=$(grep -m1 "^model\s*:" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | tr -d ' ')
if [[ ! $cpu_model =~ ^(181|213)$ ]]; then
  exit 0
fi

omarchy-pkg-add intel-lpmd

if ! systemctl is-enabled --quiet intel_lpmd.service 2>/dev/null ||
  ! systemctl is-active --quiet intel_lpmd.service 2>/dev/null; then
  sudo systemctl enable --now intel_lpmd.service
fi
