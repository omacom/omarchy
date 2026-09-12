echo "Keep Wi-Fi and USB-C working across suspend on 2016-2017 Touch Bar MacBook Pros"

# The install-time fix only reaches machines set up after it shipped. See
# install/hardware/apple/fix-t1-suspend.sh and the two hooks it installs.
OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)"
[[ $product_name =~ MacBookPro13,[123]|MacBookPro14,[123] ]] || exit 0

for hook in brcmfmac-reload thunderbolt-remove-rescan; do
  source="$OMARCHY_PATH/default/systemd/system-sleep/$hook"
  destination="/usr/lib/systemd/system-sleep/$hook"
  # A hook the user already carries with the same content is left alone;
  # anything else is replaced with the packaged copy.
  if [[ -f $destination ]] && cmp -s "$source" "$destination"; then
    continue
  fi
  sudo mkdir -p /usr/lib/systemd/system-sleep
  sudo install -m 0755 -o root -g root -T "$source" "$destination"
done
# The hooks take effect at the next suspend; nothing to restart.
