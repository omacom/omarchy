# Pacman repository templates. Every platform has a pacman.conf and mirrorlist
# for each channel it offers, copied into place whole, as x86_64's always were:
# x86_64's in default/pacman, each ARM platform's in a directory of its own. Sourcing this
# file only defines functions; it never changes the system.

# The directory holding <platform>'s pacman-<channel>.conf and
# mirrorlist-<channel>. A channel without both files isn't offered there.
omarchy_pacman_templates() {
  case ${1:-} in
    generic) echo "$OMARCHY_PATH/default/pacman" ;;
    qualcomm | generic-aarch64) echo "$OMARCHY_PATH/default/pacman/aarch64" ;;
    apple-silicon) echo "$OMARCHY_PATH/default/pacman/apple-silicon" ;;
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
    generic) echo stable ;;
    qualcomm | generic-aarch64 | apple-silicon) echo edge ;;
    *)
      echo "Error: Unknown platform '${1:-}'." >&2
      return 1
      ;;
  esac
}
