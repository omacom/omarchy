# Apply sudo session isolation and security flags
temp_sudoers=$(mktemp)
cat > "$temp_sudoers" <<'EOF'
Defaults env_reset
Defaults use_pty
EOF

sudo visudo -cf "$temp_sudoers" >/dev/null 2>&1 || { rm -f "$temp_sudoers"; exit 1; }
sudo mkdir -p /etc/sudoers.d
sudo install -m 0440 "$temp_sudoers" /etc/sudoers.d/99-omarchy-hardening
rm -f "$temp_sudoers"


