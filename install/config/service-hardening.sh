# Systemd service hardening drop-ins
sudo mkdir -p /etc/systemd/system/sshd.service.d
sudo tee /etc/systemd/system/sshd.service.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
[Service]
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
NoNewPrivileges=yes
RestrictSUIDSGID=yes
ReadWritePaths=/etc/ssh/sshd_config.d /var/log /var/run/sshd /run/sshd
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
[Service]
NoNewPrivileges=yes
EOF

sudo mkdir -p /etc/systemd/system/NetworkManager.service.d
sudo tee /etc/systemd/system/NetworkManager.service.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
[Service]
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
NoNewPrivileges=yes
RestrictSUIDSGID=yes
ReadWritePaths=/etc/NetworkManager /var/lib/NetworkManager /run/NetworkManager
EOF

sudo mkdir -p /etc/systemd/system/avahi-daemon.service.d
sudo tee /etc/systemd/system/avahi-daemon.service.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
[Service]
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
NoNewPrivileges=yes
RestrictSUIDSGID=yes
ReadWritePaths=/var/run/avahi-daemon
EOF

# Disable unused services
for svc in avahi-daemon cups cups-browsed; do
    sudo systemctl disable --now "$svc.service" 2>/dev/null || true
    sudo systemctl disable --now "$svc.socket" 2>/dev/null || true
done

# Disable LLMNR and multicast DNS
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
[Resolve]
LLMNR=no
MulticastDNS=no
EOF
