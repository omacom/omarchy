# SSH commands (ssh host cmd) run without a login or interactive shell, so on
# Arch the PAM environment is the only place they can inherit PATH from. Put
# the user-level tool paths first so remote tools (herdr, editors, agent CLIs)
# find mise-managed installs ahead of /usr/bin. @{HOME} expands per-user from
# passwd. Keep the directories in sync with default/bash/env-bootstrap.

pam_env="${OMARCHY_PAM_ENV_CONF:-/etc/security/pam_env.conf}"
old_path='PATH DEFAULT=/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
new_path='PATH DEFAULT=@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin'

if grep -qxF "$new_path" "$pam_env" 2>/dev/null; then
  :
elif grep -qxF "$old_path" "$pam_env" 2>/dev/null; then
  tmp=$(mktemp)
  while IFS= read -r line || [[ -n $line ]]; do
    if [[ $line == "$old_path" ]]; then
      printf '%s\n' "$new_path"
    else
      printf '%s\n' "$line"
    fi
  done <"$pam_env" >"$tmp"
  cat "$tmp" >"$pam_env"
  rm -f "$tmp"
elif ! grep -qE '^PATH[[:space:]]' "$pam_env" 2>/dev/null; then
  printf '\n%s\n%s\n' \
    '# Omarchy: give SSH commands and other non-shell logins the user-level tool paths' \
    "$new_path" >>"$pam_env"
fi
