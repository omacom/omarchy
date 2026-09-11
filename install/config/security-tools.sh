SECURITY_PKGS=(usbguard apparmor aide fail2ban lynis rkhunter)
for pkg in "${SECURITY_PKGS[@]}"; do
    if pacman -Si "$pkg" &>/dev/null; then
        sudo pacman -S --noconfirm --needed "$pkg"
    fi
done

if pacman -Q usbguard &>/dev/null; then
    sudo mkdir -p /etc/usbguard
    sudo usbguard generate-policy > /etc/usbguard/rules.conf
    sudo systemctl enable usbguard.service
fi

if pacman -Q apparmor &>/dev/null; then
    sudo systemctl enable apparmor.service
fi

if pacman -Q aide &>/dev/null; then
    sudo aide --init 2>/dev/null || true
    sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db 2>/dev/null || true
fi

if pacman -Q fail2ban &>/dev/null; then
    sudo tee /etc/fail2ban/jail.local >/dev/null <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
ignoreip = 127.0.0.1/8 ::1
backend = systemd

[sshd]
enabled = true
port = ssh
filter = sshd
maxretry = 3
EOF
    sudo systemctl enable fail2ban.service
fi

sudo mkdir -p /etc/cron.weekly
sudo tee /etc/cron.weekly/omarchy-security-audit.sh >/dev/null <<'AUDITEOF'
#!/bin/bash
if command -v aide &>/dev/null; then
    aide --check >> /var/log/aide-audit.log 2>&1
fi
if command -v rkhunter &>/dev/null; then
    rkhunter --check --skip-keypress --report-warnings-only >> /var/log/rkhunter-audit.log 2>&1
fi
AUDITEOF
sudo chmod 755 /etc/cron.weekly/omarchy-security-audit.sh
