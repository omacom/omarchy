sudo mkdir -p /etc/audit/rules.d

RULES_CONTENT=$(cat <<'EOF'
-w /etc/passwd -p wa -k omarchy-identity
-w /etc/group -p wa -k omarchy-identity
-w /etc/shadow -p wa -k omarchy-identity
-w /etc/gshadow -p wa -k omarchy-identity
-w /etc/sudoers -p wa -k omarchy-sudoers
-w /etc/sudoers.d/ -p wa -k omarchy-sudoers
-w /etc/ufw -p wa -k omarchy-firewall
-w /etc/hosts -p wa -k omarchy-locale
-w /etc/hostname -p wa -k omarchy-locale
-w /etc/sysctl.conf -p wa -k omarchy-sysctl
-w /etc/sysctl.d -p wa -k omarchy-sysctl
-w /etc/modprobe.d -p wa -k omarchy-modules
-w /etc/pam.d/ -p wa -k omarchy-pam
-w /etc/security/access.conf -p wa -k omarchy-pam
-w /etc/security/faillock.conf -p wa -k omarchy-pam
-w /etc/security/pwquality.conf -p wa -k omarchy-pam
EOF
)

if [[ -d /etc/ssh ]]; then
  RULES_CONTENT+=$'\n-w /etc/ssh/sshd_config -p wa -k omarchy-sshd'
  if [[ -d /etc/ssh/sshd_config.d ]]; then
    RULES_CONTENT+=$'\n-w /etc/ssh/sshd_config.d -p wa -k omarchy-sshd'
  fi
fi

RULES_CONTENT+=$'\n-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k omarchy-priv-esc\n-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k omarchy-priv-esc\n-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k omarchy-priv-esc\n-a always,exit -F arch=b32 -S execve -C gid!=egid -F egid=0 -k omarchy-priv-esc'

echo "$RULES_CONTENT" | sudo tee /etc/audit/rules.d/99-omarchy-hardening.rules >/dev/null

if systemctl list-unit-files auditd.service 2>/dev/null | grep -q auditd; then
  sudo systemctl enable auditd.service
fi

if systemctl is-active --quiet auditd.service 2>/dev/null; then
  if command -v augenrules >/dev/null 2>&1; then
    sudo augenrules --load 2>/dev/null || true
  elif command -v auditctl >/dev/null 2>&1; then
    sudo auditctl -R /etc/audit/rules.d/99-omarchy-hardening.rules 2>/dev/null || true
  fi
fi

