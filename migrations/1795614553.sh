echo "Move the agent account dispatchers to ~/.local/state/omarchy, out from under the ~/.local/share/omarchy link upgraded installs keep"

# An install that came up from Omarchy 3 has ~/.local/share/omarchy as a link
# to /usr/share/omarchy, so dispatchers written under it landed in root's
# package tree and failed. They live in the user's state directory now.

# PATH comes from the settings package. Until it names the new directory, stay
# pending: the dispatchers would move to where no session looks for them.
if ! grep -qF '.local/state/omarchy/agent-accounts/bin' "$OMARCHY_PATH/default/bash/env-bootstrap"; then
  echo "Waiting for the omarchy-settings package that puts the moved account dispatchers on PATH" >&2
  exit 75
fi

# SSH commands that run no shell take PATH from PAM. Only the exact line
# Omarchy wrote is changed.
pam_env=/etc/security/pam_env.conf
old_path='PATH DEFAULT=@{HOME}/.local/share/omarchy/agent-accounts/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
new_path='PATH DEFAULT=@{HOME}/.local/state/omarchy/agent-accounts/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
if grep -qxF "$old_path" "$pam_env"; then
  sudo sed -i "s|^${old_path//./\\.}\$|${new_path}|" "$pam_env"
fi

# The dispatchers a fresh install wrote in the old place go, and the directories
# made for them when nothing else is in there. Behind the link there is nothing
# of the user's to clear.
old_root="$HOME/.local/share/omarchy"
if [[ ! -L $old_root ]]; then
  for agent in claude codex grok; do
    old_dispatcher="$old_root/agent-accounts/bin/$agent"
    if [[ -f $old_dispatcher ]] && grep -qxF "exec omarchy-agent-account-exec $agent \"\$@\"" "$old_dispatcher"; then
      rm -f "$old_dispatcher"
    fi
  done
  rmdir "$old_root/agent-accounts/bin" "$old_root/agent-accounts" "$old_root" 2>/dev/null || true
fi

omarchy-agent-account-dispatch
