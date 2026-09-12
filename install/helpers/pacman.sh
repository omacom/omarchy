# Replace offline-install repositories with online defaults during finalization.
# Refreshes preserve the installed ARM configuration instead of using a template.
pacman_write_repository_config() {
  local channel=$1 config=$2 mirrorlist=$3
  local defaults="$OMARCHY_PATH/default/pacman"

  if [[ $channel != "stable" && $channel != "rc" && $channel != "edge" ]]; then
    echo "Error: Invalid channel '$channel'. Must be one of: stable, rc, edge" >&2
    return 1
  fi

  if [[ $(uname -m) == "aarch64" ]]; then
    cp -f "$defaults/pacman-aarch64.conf" "$config" || return 1
    cp -f "$defaults/mirrorlist-aarch64" "$mirrorlist" || return 1

    # Only edge publishes an aarch64 Omarchy repository. Offline stable/RC
    # installs retain ALARM without silently opting into an experimental channel.
    if [[ $channel == "edge" ]]; then
      printf "\n[omarchy]\nServer = https://pkgs.omarchy.org/edge/\$arch\n" >>"$config" || return 1
    fi
  else
    cp -f "$defaults/pacman-$channel.conf" "$config" || return 1
    cp -f "$defaults/mirrorlist-$channel" "$mirrorlist" || return 1
  fi
}
