# Pacman repository templates. Every platform has a pacman.conf and mirrorlist
# for each channel it offers, copied into place whole, as x86's always were:
# x86's in default/pacman, each ARM platform's in a directory named for it.
# Sourcing this file only defines functions; it never changes the system.

# The directory holding <platform>'s pacman-<channel>.conf and
# mirrorlist-<channel>. A channel without both files isn't offered there.
omarchy_pacman_templates() {
  case ${1:-} in
    x86) echo "$OMARCHY_PATH/default/pacman" ;;
    aarch64 | aarch64-apple) echo "$OMARCHY_PATH/default/pacman/$1" ;;
    *)
      echo "Error: Unknown platform '${1:-}'." >&2
      return 1
      ;;
  esac
}

# The channel a machine takes when none is named: stable, except on aarch64.
# Omarchy publishes aarch64 packages on edge alone so far, and the stable and rc
# packages there are the release line, which has no aarch64 support, so ARM
# platforms have edge templates only until a release does.
omarchy_pacman_default_channel() {
  case ${1:-} in
    x86) echo stable ;;
    aarch64 | aarch64-apple) echo edge ;;
    *)
      echo "Error: Unknown platform '${1:-}'." >&2
      return 1
      ;;
  esac
}
