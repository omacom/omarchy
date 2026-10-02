echo "Tighten sensitive system and authentication file permissions"

sudo chmod 700 /root
[[ -f /etc/shadow ]] && sudo chmod 600 /etc/shadow
[[ -f /etc/gshadow ]] && sudo chmod 600 /etc/gshadow
[[ -f /etc/passwd ]] && sudo chmod 644 /etc/passwd
[[ -f /etc/group ]] && sudo chmod 644 /etc/group
if [[ -f /etc/ssh/sshd_config ]]; then
  sudo chmod 600 /etc/ssh/sshd_config
fi
