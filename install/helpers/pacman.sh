# Configuration staging is shared by online refresh and offline finalization.
# This file only defines functions; sourcing it never changes the system.
omarchy_pacman_validate_channel() {
  case ${1:-} in
    stable|rc|edge) return 0 ;;
    *) echo "Error: Invalid channel '${1:-}'. Must be stable, rc or edge" >&2; return 1 ;;
  esac
}

omarchy_pacman_channel_qualified() {
  omarchy_pacman_validate_channel "$1" || return 1
  if omarchy-hw-apple-silicon; then
    # FIXME: Enable each channel here only after upstream publishes/aliases its
    # aarch64 repository and signed upgrade/reboot qualification passes.
    # Edge database availability alone does not qualify a channel.
    local -a qualified_arm_channels=()
    local channel
    for channel in "${qualified_arm_channels[@]}"; do
      [[ $channel != "$1" ]] || return 0
    done
    echo "Error: Apple Silicon channel '$1' is not qualified; preserving existing repositories." >&2
    return 1
  fi
}

# Render into a caller-owned temporary directory. Never sync or touch /etc.
omarchy_pacman_stage() {
  local channel=$1 destination=$2 templates="$OMARCHY_PATH/default/pacman"
  omarchy_pacman_validate_channel "$channel" || return 1
  if omarchy-hw-apple-silicon; then
    templates+=/aarch64
  fi
  cp "$templates/pacman-$channel.conf" "$destination/pacman.conf" || return 1
  cp "$templates/mirrorlist-$channel" "$destination/mirrorlist" || return 1
}

# Read candidate databases in isolation before touching live configuration.
omarchy_pacman_preflight() {
  local staged=$1 channel=$2
  local -a packages=(omarchy omarchy-settings)
  [[ $channel != "edge" ]] || packages=(omarchy-dev omarchy-settings-dev)
  if omarchy-hw-apple-silicon; then
    packages+=(omarchy-settings-asahi linux-asahi asahi-alarm-keyring)
  fi
  mkdir -p "$staged/db"
  chmod 755 "$staged" "$staged/db"
  sed "s|/etc/pacman.d/mirrorlist|$staged/mirrorlist|g" "$staged/pacman.conf" >"$staged/check.conf"
  sudo pacman --config "$staged/check.conf" --dbpath "$staged/db" --logfile "$staged/pacman.log" -Sy --noconfirm || return 1
  sudo pacman --config "$staged/check.conf" --dbpath "$staged/db" --logfile "$staged/pacman.log" -Sp --noconfirm -- "${packages[@]}" >/dev/null
}

# Finalization must keep the image's online ARM configuration until rolling
# channels are qualified. The ISO restores its pinned online config separately.
omarchy_pacman_finalize() {
  local channel=$1 staged
  omarchy_pacman_validate_channel "$channel" || return 1
  if omarchy-hw-apple-silicon && ! omarchy_pacman_channel_qualified "$channel" 2>/dev/null; then
    return 0
  fi
  staged=$(mktemp -d) || return 1
  if omarchy_pacman_stage "$channel" "$staged" &&
    cp "$staged/pacman.conf" /etc/pacman.conf &&
    cp "$staged/mirrorlist" /etc/pacman.d/mirrorlist; then
    rm -rf "$staged"
  else
    rm -rf "$staged"
    return 1
  fi
}
