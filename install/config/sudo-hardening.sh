# Apply sudo session isolation and security flags
sudo tee /etc/sudoers.d/99-omarchy-hardening >/dev/null <<'EOF'
Defaults env_reset
Defaults mail_badpass
Defaults use_pty
EOF
sudo chmod 440 /etc/sudoers.d/99-omarchy-hardening
sudo visudo -cf /etc/sudoers.d/99-omarchy-hardening >/dev/null 2>&1 || sudo rm -f /etc/sudoers.d/99-omarchy-hardening
