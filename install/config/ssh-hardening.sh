# SSH server hardening
sudo mkdir -p /etc/ssh/sshd_config.d
sudo tee /etc/ssh/sshd_config.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
MaxSessions 4
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
PermitTunnel no
PermitUserEnvironment no
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 20
StrictModes yes
AuthenticationMethods publickey
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
EOF
sudo chmod 600 /etc/ssh/sshd_config.d/99-omarchy-hardening.conf

# SSH client hardening
sudo mkdir -p /etc/ssh/ssh_config.d
sudo tee /etc/ssh/ssh_config.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
Host *
    KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
    HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256
EOF
sudo chmod 644 /etc/ssh/ssh_config.d/99-omarchy-hardening.conf

if systemctl is-active sshd 2>/dev/null | grep -q active; then
    sudo sshd -t && sudo systemctl reload sshd
fi
