# Use the upstream driver for the Motorcomm YT6801 adapter used by the Slimbook Executive.
if ! yt6801_devices=$(lspci -Dn -d 1f0a:6801); then
  echo "Unable to discover YT6801 adapters." >&2
  return 1
fi

if [[ -n $yt6801_devices ]]; then
  omarchy-pkg-drop yt6801-dkms
fi
