sudo chmod 700 /root
[[ -f /etc/shadow ]] && sudo chmod 600 /etc/shadow
[[ -f /etc/gshadow ]] && sudo chmod 600 /etc/gshadow
[[ -f /etc/passwd ]] && sudo chmod 644 /etc/passwd
[[ -f /etc/group ]] && sudo chmod 644 /etc/group
if [[ -d /etc/ssh ]]; then
  sudo chmod 750 /etc/ssh
  [[ -f /etc/ssh/sshd_config ]] && sudo chmod 600 /etc/ssh/sshd_config
  [[ -f /etc/ssh/ssh_config ]] && sudo chmod 644 /etc/ssh/ssh_config
fi

