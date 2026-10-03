echo "Restore missing mise stubs from the canonical install list"

# 1784909971.sh rewrote wrappers by walking ~/.local/bin. Once that directory
# is empty the glob matches nothing, so later updates never recreate gh and
# the other documented lazy stubs.
#
# Only recreate stubs that are actually missing, and skip the whole list when
# the user already ran omarchy-remove-preinstalls (preinstalls-removed).

mise_leaf="${OMARCHY_PATH:-/usr/share/omarchy}/install/user/mise.sh"

if [[ -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  echo "preinstalls-removed is set; leaving removed stubs alone"
  exit 0
fi

mise() { :; }

omarchy-mise-install() {
  local command=${2:-$1}

  # -e is false for a dangling symlink. A user-owned launcher with a missing
  # target must still be left alone; only a truly absent path gets a stub.
  if [[ -e $HOME/.local/bin/$command || -L $HOME/.local/bin/$command ]]; then
    return 0
  fi

  command omarchy-mise-install "$@"
}

# shellcheck disable=SC1090
source "$mise_leaf"
