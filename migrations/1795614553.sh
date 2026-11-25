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
# PAM is shared by every user; some have not migrated their dispatchers yet.
new_path='PATH DEFAULT=@{HOME}/.local/state/omarchy/agent-accounts/bin:@{HOME}/.local/share/omarchy/agent-accounts/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
if grep -qxF "$old_path" "$pam_env"; then
  sudo sed -i "s|^${old_path//./\\.}\$|${new_path}|" "$pam_env"
fi

omarchy-agent-account-dispatch

# The dispatchers a fresh install wrote in the old place can't go yet. Apps and
# shells already running have that directory on PATH and no other, and without
# them would start the CLI as the primary account whichever one is selected.
# Nothing from before the move is left running after a restart, so a hook
# clears them on the first start of the desktop after one, then removes itself.
# Only an exact copy of Omarchy's dispatcher goes, and behind the link an
# upgraded install keeps there is nothing of the user's to clear.
old_root="$HOME/.local/share/omarchy"
old_dispatchers=0
if [[ ! -L $old_root ]]; then
  for agent in claude codex grok; do
    if [[ -f $old_root/agent-accounts/bin/$agent ]]; then
      old_dispatchers=1
    fi
  done
fi

if (( old_dispatchers )); then
  cleanup_hook="$HOME/.config/omarchy/hooks/post-boot.d/cleanup-moved-agent-account-dispatchers"
  mkdir -p "${cleanup_hook%/*}"
  cat >"$cleanup_hook" <<CLEANUP_HOOK
#!/bin/bash
# Written by Omarchy when the agent account dispatchers moved to
# ~/.local/state/omarchy. Clears the old ones once the machine has restarted.
[[ \$(</proc/sys/kernel/random/boot_id) != "$(</proc/sys/kernel/random/boot_id)" ]] || exit 0
old_root="\$HOME/.local/share/omarchy"
if [[ ! -L \$old_root ]]; then
  for agent in claude codex grok; do
    old_dispatcher="\$old_root/agent-accounts/bin/\$agent"
    if [[ -f \$old_dispatcher ]] && grep -qxF "exec omarchy-agent-account-exec \$agent \"\\\$@\"" "\$old_dispatcher"; then
      rm -f "\$old_dispatcher"
    fi
  done
  rmdir "\$old_root/agent-accounts/bin" "\$old_root/agent-accounts" "\$old_root" 2>/dev/null || true
fi
rm -f "\$0"
CLEANUP_HOOK
fi
