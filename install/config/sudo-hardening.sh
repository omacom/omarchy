sudo tee /etc/sudoers.d/99-omarchy-hardening >/dev/null <<'EOF'
Defaults env_reset
Defaults mail_badpass
Defaults use_pty
Defaults log_input,log_output
Defaults iolog_dir=/var/log/sudo
Defaults passwd_timeout=2
Defaults timestamp_timeout=3
EOF
sudo chmod 440 /etc/sudoers.d/99-omarchy-hardening
sudo visudo -cf /etc/sudoers.d/99-omarchy-hardening >/dev/null 2>&1 || sudo rm -f /etc/sudoers.d/99-omarchy-hardening

echo 'Defaults passwd_tries=3' | sudo tee /etc/sudoers.d/99-omarchy-passwd-tries >/dev/null
sudo chmod 440 /etc/sudoers.d/99-omarchy-passwd-tries
