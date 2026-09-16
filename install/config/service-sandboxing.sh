# Apply systemd sandboxing drop-ins for SSH daemon
sudo mkdir -p /etc/systemd/system/sshd.service.d
sudo tee /etc/systemd/system/sshd.service.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
[Service]
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
NoNewPrivileges=yes
RestrictSUIDSGID=yes
ReadWritePaths=/etc/ssh /var/log /var/run/sshd /run/sshd
EOF

# Apply systemd sandboxing drop-ins for NetworkManager
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

# Harden systemd-resolved against local name resolution poisoning
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
[Resolve]
LLMNR=no
MulticastDNS=no
EOF
