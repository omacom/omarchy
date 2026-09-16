# Configure baseline firewall rules with UFW
if omarchy-pkg-missing ufw; then
  omarchy-pkg-add ufw
fi

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 53317/udp comment 'localsend'
sudo ufw allow 53317/tcp comment 'localsend'
sudo ufw --force enable
sudo systemctl enable ufw.service
