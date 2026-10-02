# Configure hardened OpenSSH server defaults
sudo mkdir -p /etc/ssh/sshd_config.d
sudo tee /etc/ssh/sshd_config.d/10-omarchy-hardening.conf >/dev/null <<'EOF'
PermitRootLogin no
PubkeyAuthentication yes
MaxAuthTries 5
MaxSessions 4
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
StrictModes yes
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
EOF
sudo chmod 600 /etc/ssh/sshd_config.d/10-omarchy-hardening.conf

# Configure hardened OpenSSH client defaults
sudo mkdir -p /etc/ssh/ssh_config.d
sudo tee /etc/ssh/ssh_config.d/10-omarchy-hardening.conf >/dev/null <<'EOF'
Host *
  Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
EOF
sudo chmod 644 /etc/ssh/ssh_config.d/10-omarchy-hardening.conf

if [[ -f /etc/ssh/sshd_config ]] && omarchy-cmd-present sshd; then
  sudo sshd -t
fi

if omarchy-cmd-present systemctl && systemctl is-active --quiet sshd; then
  sudo systemctl reload sshd
fi


