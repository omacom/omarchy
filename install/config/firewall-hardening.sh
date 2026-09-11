if ! pacman -Q ufw &>/dev/null; then
    sudo pacman -S --noconfirm --needed ufw
fi

sudo ufw --force reset 2>/dev/null || true
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 53317/udp
sudo ufw allow 53317/tcp
sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'
sudo ufw allow in proto udp from 192.168.0.0/16 to 172.17.0.1 port 53 comment 'allow-docker-dns'
sudo ufw --force enable
sudo systemctl enable ufw

if command -v ufw-docker &>/dev/null; then
    sudo ufw-docker install 2>/dev/null || true
    sudo ufw reload
fi
