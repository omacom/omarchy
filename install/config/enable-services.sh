# Enable services only. Installs are followed by reboot, so don't start/reload
# daemons mid-install. UFW and hardware-gated services stay in their own scripts.
# CUPS and Docker are socket-activated so neither daemon stays resident until
# needed. Kill one runaway app scope (systemd-oomd.service) instead of letting
# reclaim thrashing take the whole session down; [Install] pulls in
# systemd-oomd.socket via Also=. omarchy-shutdown-ramfs.timer builds
# /run/initramfs in the background after boot so shutdown skips mkinitcpio.
systemctl enable \
  cups.socket \
  cups.path \
  avahi-daemon.service \
  linux-modules-cleanup.service \
  docker.socket \
  systemd-resolved.service \
  NetworkManager.service \
  power-profiles-daemon.service \
  systemd-oomd.service \
  omarchy-shutdown-ramfs.timer

# Don't let network-online.target hold up graphical.target waiting for
# DHCP/Wi-Fi association. Nothing in the session needs to block on the network.
# Mirrors the systemd-networkd-wait-online mask in install/hardware/network.sh.
systemctl mask NetworkManager-wait-online.service
