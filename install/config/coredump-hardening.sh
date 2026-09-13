sudo mkdir -p /etc/security/limits.d
sudo tee /etc/security/limits.d/99-no-core.conf >/dev/null <<'EOF'
* hard core 0
* soft core 0
EOF

sudo mkdir -p /etc/systemd/system.conf.d
sudo tee /etc/systemd/system.conf.d/99-no-core.conf >/dev/null <<'EOF'
[Manager]
DefaultLimitCORE=0
EOF

sudo mkdir -p /etc/systemd/coredump.conf.d
sudo tee /etc/systemd/coredump.conf.d/99-no-core.conf >/dev/null <<'EOF'
[Coredump]
Storage=none
ProcessSizeMax=0
EOF
