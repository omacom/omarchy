# Blacklist uncommon network transport protocols
sudo tee /etc/modprobe.d/omarchy-disable-protocols.conf >/dev/null <<'EOF'
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
EOF

# Blacklist firewire modules to prevent DMA attacks
sudo tee /etc/modprobe.d/omarchy-disable-firewire.conf >/dev/null <<'EOF'
blacklist firewire-core
blacklist firewire-ohci
blacklist firewire-sbp2
EOF

# Blacklist legacy or uncommon filesystem drivers
sudo tee /etc/modprobe.d/omarchy-disable-legacy-fs.conf >/dev/null <<'EOF'
blacklist cramfs
blacklist freevxfs
blacklist hfs
blacklist hfsplus
blacklist jffs2
EOF
