echo "Configure baseline firewall rules with UFW"

if ! command -v ufw >/dev/null 2>&1; then
  exit 0
fi

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 53317/udp comment 'localsend'
sudo ufw allow 53317/tcp comment 'localsend'
sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'
sudo ufw allow in proto udp from 192.168.0.0/16 to 172.17.0.1 port 53 comment 'allow-docker-dns'

if [[ -z ${OMARCHY_CHROOT_INSTALL:-} ]]; then
  sudo ufw --force enable
fi

if omarchy-cmd-present ufw-docker; then
  sudo ufw-docker install
  sudo ufw reload
fi

if omarchy-cmd-present systemctl; then
  sudo systemctl enable ufw.service
fi

