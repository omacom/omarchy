# Block unused and risky kernel modules
sudo tee /etc/modprobe.d/omarchy-disable-usb-storage.conf >/dev/null <<'EOF'
install usb-storage /bin/true
blacklist usb-storage
EOF

sudo tee /etc/modprobe.d/omarchy-disable-protocols.conf >/dev/null <<'EOF'
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
EOF

sudo tee /etc/modprobe.d/omarchy-disable-firewire.conf >/dev/null <<'EOF'
blacklist firewire-core
blacklist firewire-ohci
blacklist firewire-sbp2
EOF

sudo tee /etc/modprobe.d/omarchy-disable-ramfs.conf >/dev/null <<'EOF'
blacklist cramfs
blacklist freevxfs
blacklist hfs
blacklist hfsplus
blacklist jffs2
blacklist udf
EOF
