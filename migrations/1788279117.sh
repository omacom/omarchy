echo "Replace the YT6801 vendor DKMS driver with the upstream kernel driver"

if ! yt6801_pci=$(lspci -Dn -d 1f0a:6801); then
  echo "Unable to discover YT6801 adapters; rerun omarchy-migrate." >&2
  exit 1
fi

yt6801_devices=()
while read -r device _; do
  [[ -n $device ]] || continue
  if [[ ! $device =~ ^[[:xdigit:]]{4}:[[:xdigit:]]{2}:[[:xdigit:]]{2}\.[0-7]$ ]]; then
    echo "Invalid YT6801 PCI address: $device" >&2
    exit 1
  fi
  yt6801_devices+=("$device")
done <<< "$yt6801_pci"

yt6801_uses_upstream() {
  local driver
  driver=$(readlink -f "/sys/bus/pci/devices/$1/driver") &&
    [[ $driver == "/sys/bus/pci/drivers/dwmac-motorcomm" ]]
}

yt6801_check_binding() {
  local device
  for device in "${yt6801_devices[@]}"; do
    if ! yt6801_uses_upstream "$device"; then
      echo "YT6801 device $device did not bind to dwmac-motorcomm." >&2
      echo "Reboot into the latest Omarchy kernel and rerun omarchy-migrate." >&2
      exit 1
    fi
  done
}

# Check discovery before changing hardware or packages. A failed query must not
# turn into an empty list and mark the migration complete.
installed_packages=$(pacman -Qq)
loaded_modules=$(lsmod)

yt6801_pending=()
for device in "${yt6801_devices[@]}"; do
  if ! yt6801_uses_upstream "$device"; then
    yt6801_pending+=("$device")
  fi
done

if (( ${#yt6801_pending[@]} > 0 )); then
  if ! aliases=$(modinfo -F alias dwmac-motorcomm) ||
    ! grep -Fxq 'pci:v00001F0Ad00006801sv*sd*bc*sc*i*' <<< "$aliases"; then
    echo "The running kernel does not provide YT6801 support in dwmac-motorcomm." >&2
    echo "Reboot into the latest Omarchy kernel and rerun omarchy-migrate." >&2
    exit 1
  fi

  # Validate the replacement before unloading the installed fallback. Already
  # migrated machines need no module load or privilege prompt for later users.
  sudo modprobe dwmac-motorcomm
fi

if grep -Eq '^yt6801[[:space:]]' <<< "$loaded_modules"; then
  # rmmod also works on retries after DKMS has deleted the module files and
  # lookup index. Never force removal of a module that is still busy.
  sudo rmmod yt6801
fi

for device in "${yt6801_pending[@]}"; do
  if ! yt6801_uses_upstream "$device"; then
    printf '%s\n' "$device" | sudo tee /sys/bus/pci/drivers_probe >/dev/null
  fi
done
yt6801_check_binding

# Keep the package available until the live cutover succeeds. Package removal
# invokes DKMS/depmod hooks, so unloading must happen before this transaction.
if grep -Fxq 'yt6801-dkms' <<< "$installed_packages"; then
  omarchy-pkg-drop yt6801-dkms
fi

installed_packages=$(pacman -Qq)
loaded_modules=$(lsmod)
if grep -Fxq 'yt6801-dkms' <<< "$installed_packages" ||
  grep -Eq '^yt6801[[:space:]]' <<< "$loaded_modules"; then
  echo "The YT6801 vendor package or module is still present; rerun omarchy-migrate." >&2
  exit 1
fi
yt6801_check_binding
