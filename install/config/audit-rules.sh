# Provision baseline Linux audit subsystem rules
sudo mkdir -p /etc/audit/rules.d
sudo tee /etc/audit/rules.d/99-omarchy-hardening.rules >/dev/null <<'EOF'
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/sudoers -p wa -k sudoers
-w /etc/ssh/sshd_config -p wa -k sshd
-w /etc/sysctl.conf -p wa -k sysctl
-w /etc/sysctl.d -p wa -k sysctl
-w /etc/modprobe.d -p wa -k modules
-w /etc/security/faillock.conf -p wa -k pam
-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k privilege_escalation
-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k privilege_escalation
EOF

if systemctl list-unit-files auditd.service 2>/dev/null | grep -q auditd; then
  sudo systemctl enable auditd.service
  sudo systemctl restart auditd.service 2>/dev/null
fi
sudo auditctl -R /etc/audit/rules.d/99-omarchy-hardening.rules 2>/dev/null || true
