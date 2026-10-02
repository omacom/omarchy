echo "Add audit rules for sensitive files and privilege changes"

sudo mkdir -p /etc/audit/rules.d

RULES_CONTENT=$(cat <<'EOF'
-w /etc/passwd -p wa -k omarchy-identity
-w /etc/group -p wa -k omarchy-identity
-w /etc/shadow -p wa -k omarchy-identity
-w /etc/gshadow -p wa -k omarchy-identity
-w /etc/sudoers -p wa -k omarchy-sudoers
-w /etc/sudoers.d/ -p wa -k omarchy-sudoers
-w /etc/pam.d/ -p wa -k omarchy-pam
-w /etc/security/faillock.conf -p wa -k omarchy-pam
-w /etc/sysctl.d -p wa -k omarchy-sysctl
-w /etc/modprobe.d -p wa -k omarchy-modules
EOF
)

if [[ -f /etc/sysctl.conf ]]; then
  RULES_CONTENT+=$'\n-w /etc/sysctl.conf -p wa -k omarchy-sysctl'
fi

if [[ -d /etc/ssh ]]; then
  RULES_CONTENT+=$'\n-w /etc/ssh/sshd_config -p wa -k omarchy-sshd'
  if [[ -d /etc/ssh/sshd_config.d ]]; then
    RULES_CONTENT+=$'\n-w /etc/ssh/sshd_config.d -p wa -k omarchy-sshd'
  fi
fi

RULES_CONTENT+=$'\n-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k omarchy-priv-esc\n-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k omarchy-priv-esc'

echo "$RULES_CONTENT" | sudo tee /etc/audit/rules.d/99-omarchy-hardening.rules >/dev/null

if omarchy-cmd-present systemctl && systemctl list-unit-files auditd.service 2>/dev/null | grep -q auditd; then
  sudo systemctl enable auditd.service
fi

if omarchy-cmd-present systemctl && systemctl is-active --quiet auditd.service; then
  if omarchy-cmd-present augenrules; then
    sudo augenrules --load
  elif omarchy-cmd-present auditctl; then
    sudo auditctl -R /etc/audit/rules.d/99-omarchy-hardening.rules
  fi
fi

