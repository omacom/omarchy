echo "Keep USB-C working across suspend on 2016-2017 MacBook Pros"

# The install-time fix only reaches machines set up after it shipped. See
# install/hardware/apple/fix-t1-suspend.sh and the hook it installs.
OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)"
[[ $product_name =~ MacBookPro13,[123]|MacBookPro14,[123] ]] || exit 0

# Installed unconditionally, so a copy the user carries is also reset to
# root:root 0755 (see 1788662350.sh for why that matters here).
sudo mkdir -p /usr/lib/systemd/system-sleep
sudo install -m 0755 -o root -g root -T \
  "$OMARCHY_PATH/default/systemd/system-sleep/thunderbolt-remove-rescan" \
  /usr/lib/systemd/system-sleep/thunderbolt-remove-rescan
# The hook takes effect at the next suspend; nothing to restart.
