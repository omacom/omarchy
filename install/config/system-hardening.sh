if ! grep -q '^tmpfs /run/shm tmpfs' /etc/fstab; then
    echo 'tmpfs /run/shm tmpfs defaults,noexec,nosuid,mode=1777 0 0' | sudo tee -a /etc/fstab
fi

sudo tee /etc/profile.d/omarchy-umask.sh >/dev/null <<'EOF'
umask 077
EOF

sudo mkdir -p /etc/systemd/system.conf.d
sudo tee /etc/systemd/system.conf.d/99-omarchy-umask.conf >/dev/null <<'EOF'
[Manager]
UMask=077
EOF

sudo mkdir -p /etc/systemd/journald.conf.d
sudo tee /etc/systemd/journald.conf.d/99-omarchy-security.conf >/dev/null <<'EOF'
[Journal]
SystemMaxUse=500M
SystemMaxRetentionSec=30day
Compress=yes
EOF
sudo systemctl restart systemd-journald 2>/dev/null || true

sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/99-omarchy-security.conf >/dev/null <<'EOF'
[main]
no-auto-default=*

[connection]
ipv4.dhcp-timeout = 10

[logging]
level=INFO
EOF
