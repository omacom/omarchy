product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
sys_vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null)

if [[ $sys_vendor == "Apple Inc." && $product_name =~ ^MacBookPro(13,[23]|14,[23])$ ]]; then
  source "$OMARCHY_INSTALL/hardware/apple/t1-preflight.sh"
  t1bridge_install_preflight || return 1

  echo "Detected MacBook with T1 chip. Installing T1Bridge support..."

  # The ISO installs the stock Arch kernel on T1 Macs. DKMS needs its matching
  # headers in this transaction; merely caching them in the ISO is not enough.
  omarchy-pkg-add linux-headers t1bridge-dkms t1bridge libfprint-t1bridge fprintd-t1bridge

  provisioning_dir="${OMARCHY_PROVISIONING_DIR:-/var/lib/omarchy/provisioning}"
  mkdir -p "$provisioning_dir"
  grep -qxF t1bridge "$provisioning_dir/groups" 2>/dev/null || echo t1bridge >>"$provisioning_dir/groups"
  if [[ -n ${OMARCHY_INSTALL_USER:-} ]] && getent passwd "$OMARCHY_INSTALL_USER" >/dev/null; then
    usermod -aG t1bridge "$OMARCHY_INSTALL_USER"
  fi

  install -Dm644 \
    "$OMARCHY_PATH/default/systemd/user/t1-touchbar.service.d/20-omarchy-desktop-provider.conf" \
    /etc/systemd/user/t1-touchbar.service.d/20-omarchy-desktop-provider.conf

  # Name only the link matched by T1Bridge's driver-specific .link file.
  # This keeps the persistent firewall exception off every other interface.
  install -Dm644 \
    "$OMARCHY_INSTALL/hardware/apple/20-omarchy-private-link.conf" \
    /etc/systemd/network/50-t1bridge-ncm.link.d/20-omarchy-private-link.conf
  ufw allow in on t1bridge0 proto tcp from fe80::aede:48ff:fe33:4455 to any port 61500 \
    comment "omarchy-t1bridge" >/dev/null

  install -d -m 0755 -o root -g root /var/lib/omarchy/t1bridge-import
  printf '%s\n' enabled >/var/lib/omarchy/t1bridge-import/enabled
  chmod 0644 /var/lib/omarchy/t1bridge-import/enabled

  install -Dm644 \
    "$OMARCHY_INSTALL/hardware/apple/omarchy-t1bridge-import.service" \
    /etc/systemd/system/omarchy-t1bridge-import.service
  install -Dm644 \
    "$OMARCHY_INSTALL/hardware/apple/20-omarchy-machine-data-import.conf" \
    /etc/systemd/system/t1-xart-storage@.service.d/20-omarchy-machine-data-import.conf
  systemctl daemon-reload
fi
