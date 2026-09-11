# Secure critical file permissions
sudo chmod 700 /root
sudo chmod 600 /etc/shadow
sudo chmod 600 /etc/gshadow
sudo chmod 644 /etc/passwd
sudo chmod 644 /etc/group
sudo chmod 750 /etc/ssh
sudo chmod 600 /etc/ssh/sshd_config 2>/dev/null || true
sudo chmod 600 /etc/ssh/ssh_config 2>/dev/null || true
sudo chmod 644 /etc/ssh/*.conf 2>/dev/null || true
sudo chmod 750 /home/* 2>/dev/null || true
sudo chmod 750 /home/*/Documents /home/*/Downloads /home/*/Desktop 2>/dev/null || true
