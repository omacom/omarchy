# Keep Wi-Fi and USB-C working across suspend on the 2016-2017 Touch Bar
# MacBook Pros (Apple T1 generation: Alpine Ridge Thunderbolt, BCM43602 Wi-Fi).
#
# Two system-sleep hooks, both measured on a MacBookPro14,2:
# - brcmfmac-reload: the BCM43602 firmware sometimes dies in S3 while its
#   registers stay readable, and brcmfmac's hot-resume path then leaves Wi-Fi
#   down until a reload. Unloading before sleep and reloading after makes every
#   resume take the working path.
# - thunderbolt-remove-rescan: the firmware powers the Thunderbolt controllers
#   off in S3, the kernel cannot re-allocate their bridge windows on resume, and
#   USB-C is dead until a power cycle. Removing the upstream ports before sleep
#   and rescanning after brings the tree back. See the hooks for the details and
#   the measured limits.
product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)"

if [[ $product_name =~ MacBookPro13,[123]|MacBookPro14,[123] ]]; then
  echo "Detected $product_name; installing the suspend hooks for Wi-Fi and USB-C"

  sudo mkdir -p /usr/lib/systemd/system-sleep
  for hook in brcmfmac-reload thunderbolt-remove-rescan; do
    sudo install -m 0755 -o root -g root -T \
      "${OMARCHY_PATH:-/usr/share/omarchy}/default/systemd/system-sleep/$hook" \
      "/usr/lib/systemd/system-sleep/$hook"
  done
fi
