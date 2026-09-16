# Restrict sensitive system and authentication file permissions
sudo chmod 700 /root
sudo chmod 600 /etc/shadow 2>/dev/null
sudo chmod 600 /etc/gshadow 2>/dev/null
sudo chmod 644 /etc/passwd
sudo chmod 644 /etc/group
sudo chmod 600 /etc/ssh/sshd_config 2>/dev/null
