# China gets Node and npm packages from Alibaba's npmmirror: mise's Node builds,
# the tools mise installs from npm, and npm itself (docs/regions.md).
if omarchy-region-cn; then
  install -D -m 644 "$OMARCHY_PATH/default/regions/cn/environment.conf" /etc/environment.d/60-omarchy-region.conf
else
  rm -f /etc/environment.d/60-omarchy-region.conf
fi
