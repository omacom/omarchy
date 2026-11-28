echo "Put mise shims ahead of system binaries for SSH commands, as in a desktop session"

# A tool version pinned with mise lost to a system copy in SSH commands: the
# PAM PATH listed mise's shims after /usr/bin. Only the exact line Omarchy wrote is changed.
pam_env=/etc/security/pam_env.conf
old_path='PATH DEFAULT=@{HOME}/.local/share/omarchy/agent-accounts/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
new_path='PATH DEFAULT=@{HOME}/.local/share/omarchy/agent-accounts/bin:@{HOME}/.local/share/mise/shims:/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/bin'
if grep -qxF "$old_path" "$pam_env"; then
  sudo sed -i "s|^${old_path//./\\.}\$|${new_path}|" "$pam_env"
fi
