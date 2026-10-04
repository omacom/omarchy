echo "Make agent account selection apply to scripts and subprocesses"

# The settings package ships the mise wrapper declarations. Build the dispatch
# links for this user without installing or changing any agent version.
mise reshim

# Repair only the PATH Omarchy supplied; leave administrator-defined paths alone.
legacy_path='PATH DEFAULT=/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
wrapper_path='PATH DEFAULT=@{HOME}/.local/share/mise/command-wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
if grep -Fxq "$legacy_path" /etc/security/pam_env.conf; then
  sudo sed -i "s|^${legacy_path//./\\.}$|$wrapper_path|" /etc/security/pam_env.conf
fi
