# The region's session environment, such as China's Node and npm mirrors
# (docs/regions.md).
environment="$OMARCHY_PATH/default/regions/$(omarchy-region)/environment.conf"
if [[ -f $environment ]]; then
  install -D -m 644 "$environment" /etc/environment.d/60-omarchy-region.conf
else
  rm -f /etc/environment.d/60-omarchy-region.conf
fi

# The region's default packages, installed once the machine is online.
if [[ -f $OMARCHY_PATH/default/regions/$(omarchy-region)/packages ]]; then
  install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-region-packages.service" \
    /etc/systemd/system/omarchy-region-packages.service
  systemctl enable omarchy-region-packages.service
fi
