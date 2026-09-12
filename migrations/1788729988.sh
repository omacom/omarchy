echo "Put user-level tool paths ahead of /usr/bin in the PAM PATH"

# SSH commands inherit PATH only from PAM. The original line listed mise shims
# and ~/.local/bin after /usr/bin, so a distro node/python hid the user one.
# Rewrite only that exact Omarchy line; a hand-edited PATH is left alone.
pam_env="${OMARCHY_PAM_ENV_CONF:-/etc/security/pam_env.conf}"
old_path='PATH DEFAULT=/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
new_path='PATH DEFAULT=@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin'

if grep -qxF "$new_path" "$pam_env" 2>/dev/null; then
  :
elif grep -qxF "$old_path" "$pam_env" 2>/dev/null || ! grep -qE '^PATH[[:space:]]' "$pam_env" 2>/dev/null; then
  sudo env OMARCHY_PAM_ENV_CONF="$pam_env" bash -euo pipefail "$OMARCHY_PATH/install/config/ssh-command-path.sh"
fi
