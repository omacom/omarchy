# Shared memory hardening
if ! grep -q '^tmpfs /run/shm tmpfs' /etc/fstab; then
    echo 'tmpfs /run/shm tmpfs defaults,noexec,nosuid,mode=1777 0 0' | sudo tee -a /etc/fstab
fi

# Strict default umask
sudo tee /etc/profile.d/omarchy-umask.sh >/dev/null <<'EOF'
umask 027
EOF

# Systemd manager umask
sudo mkdir -p /etc/systemd/system.conf.d
sudo tee /etc/systemd/system.conf.d/99-omarchy-umask.conf >/dev/null <<'EOF'
[Manager]
UMask=027
EOF

# Log protection
sudo tee /etc/logrotate.d/omarchy-security >/dev/null <<'EOF'
/var/log/auth.log
/var/log/syslog
/var/log/kern.log
/var/log/ufw.log
{
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    create 640 root adm
    sharedscripts
    postrotate
        /usr/bin/systemctl kill -s HUP systemd-journald 2>/dev/null || true
    endscript
}
EOF

# NetworkManager security
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/99-omarchy-security.conf >/dev/null <<'EOF'
[main]
no-auto-default=*

[connection]
ipv4.dhcp-timeout = 10

[logging]
level=INFO
EOF
