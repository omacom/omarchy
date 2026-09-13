echo "Move this install to the opt-in docker group default (the group is root-equivalent)"

# Keep this historical repair self-contained after retiring Docker commands.
if id -nG "$USER" | grep -qw docker; then
  sudo gpasswd -d "$USER" docker >/dev/null
  omarchy-state set reboot-required
fi

# The Docker app entry copied into ~/.local/share/applications used to run
# lazydocker directly; it now needs the wrapper that prompts for daemon access
# (or runs directly under sudoless Docker). Refresh just that file.
dest="$HOME/.local/share/applications/Docker.desktop"
if [[ -f $dest && -f $OMARCHY_PATH/applications/Docker.desktop ]]; then
  cp "$OMARCHY_PATH/applications/Docker.desktop" "$dest"
fi
