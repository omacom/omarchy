echo "Move the agent account dispatchers to ~/.local/state/omarchy, out from under the ~/.local/share/omarchy link upgraded installs keep"

# An install that came up from Omarchy 3 has ~/.local/share/omarchy as a link
# to /usr/share/omarchy, so dispatchers written under it landed in root's
# package tree and failed. They live in the user's state directory now.

# PATH comes from the settings package, which shells read at this fixed path
# even when OMARCHY_PATH is a dev checkout. Until it names the new directory,
# stay pending: new sessions would still look only in the old one.
if ! grep -qF '.local/state/omarchy/agent-accounts/bin' /usr/share/omarchy/default/bash/env-bootstrap; then
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

# The dispatchers a fresh install wrote in the old place stay. Apps and shells
# already running have that directory on PATH and no other, and without them
# would start the CLI as the primary account whichever one is selected. Each
# goes with its CLI, like the ones written here.
omarchy-agent-account-dispatch
