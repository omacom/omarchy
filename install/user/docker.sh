rootless_state="$HOME/.local/state/omarchy/rootless-docker"

if [[ -f /var/lib/omarchy/rootless-docker/enabled ]]; then
  mkdir -p "$rootless_state" "$HOME/.config/docker"
  touch "$rootless_state/enabled"
  chmod 0600 "$rootless_state/enabled"

  if [[ ! -e $HOME/.config/docker/daemon.json ]]; then
    install -m 0644 "$OMARCHY_PATH/config/docker/daemon.json" "$HOME/.config/docker/daemon.json"
  fi
fi
