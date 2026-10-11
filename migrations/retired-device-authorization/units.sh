# Shared cleanup for retired system and user units, including running units whose files were removed by pacman.
da_remove_unit_links() {
  local directory=$1 unit=$2 dependency link
  for dependency in "$directory/"*.wants "$directory/"*.requires; do
    link=$dependency/$unit
    [[ -e $link || -L $link ]] || continue
    # Remove only known links; a redirected directory or regular dependency
    # needs manual repair before this migration can report success.
    [[ ! -L $dependency && -L $link ]] || return 1
    rm -- "$link" || return 1
  done
}

da_stop_unit() {
  local unit=$1 scope=${2:-system} root=${3:-} active fragment directory
  local -a manager=() directories=("$root/etc/systemd/system" "$root/run/systemd/system")
  if [[ $scope == "user" ]]; then
    manager=(--user)
    directories=("$HOME/.config/systemd/user" "${XDG_RUNTIME_DIR:-/run/user/$UID}/systemd/user")
  fi
  active=$(systemctl "${manager[@]}" show -p ActiveState --value "$unit") || return 1
  if [[ -n $active && $active != "inactive" ]]; then
    systemctl "${manager[@]}" stop "$unit" || return 1
  fi
  fragment=$(systemctl "${manager[@]}" show -p FragmentPath --value "$unit") || return 1
  if [[ -n $fragment && -f $fragment ]]; then
    systemctl "${manager[@]}" disable "$unit" || return 1
  fi
  for directory in "${directories[@]}"; do
    da_remove_unit_links "$directory" "$unit" || return 1
  done
  if systemctl "${manager[@]}" is-active --quiet "$unit" || systemctl "${manager[@]}" is-enabled --quiet "$unit"; then
    echo "$unit is still active or enabled; rollback is incomplete." >&2
    return 1
  fi
}

da_archive() {
  local path=$1
  [[ -e $path || -L $path ]] || return 0
  if [[ -e $path.retired || -L $path.retired ]]; then
    cmp -s -- "$path" "$path.retired" || return 1
    rm -- "$path"
  else
    mv -- "$path" "$path.retired"
  fi
}
