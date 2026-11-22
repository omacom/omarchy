# Keep USB-C working across suspend on the 2016-2017 MacBook Pros
# (MacBookPro13,x and 14,x, Alpine Ridge Thunderbolt).
#
# One system-sleep hook, measured on a MacBookPro14,2: the firmware powers the
# Thunderbolt controllers off in S3, the kernel cannot re-allocate their bridge
# windows on resume, and USB-C is dead until a power cycle. Removing the
# upstream ports before sleep and rescanning after brings the tree back. See
# thunderbolt-remove-rescan for the details and the measured limits.
product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)"

if [[ $product_name =~ MacBookPro13,[123]|MacBookPro14,[123] ]]; then
  echo "Detected $product_name; installing the suspend hook for USB-C"

  sudo mkdir -p /usr/lib/systemd/system-sleep
  sudo install -m 0755 -o root -g root -T \
    "${OMARCHY_PATH:-/usr/share/omarchy}/default/systemd/system-sleep/thunderbolt-remove-rescan" \
    /usr/lib/systemd/system-sleep/thunderbolt-remove-rescan
fi
