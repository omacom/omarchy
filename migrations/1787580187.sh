echo "Remove root-equivalent Docker group access"

# The docker group grants passwordless root (a container can bind-mount / and
# rewrite the host), so remove the current user from it when present. The later
# rootless Docker migration provides unprivileged CLI access and restricts the
# old socket immediately; this historical step still marks the required login
# refresh and stays self-contained after retiring the old toggle commands.
docker_user=$(id -un)
if id -nG "$docker_user" | grep -qw docker; then
  sudo gpasswd -d "$docker_user" docker >/dev/null
  omarchy-state set reboot-required
fi

# Refresh the Docker app entry so it uses the current rootless-aware launcher.
dest="$HOME/.local/share/applications/Docker.desktop"
if [[ -f $dest && -f $OMARCHY_PATH/applications/Docker.desktop ]]; then
  cp "$OMARCHY_PATH/applications/Docker.desktop" "$dest"
fi
