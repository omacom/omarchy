# User-side migration: machine state is inspected by the fixed root helper,
# including recovery files that the user cannot read. User paths remain local.
ACCESSORY_ROOT_ADMIN=/usr/bin/omarchy-accessory-authorization-rollback
ACCESSORY_USER_HOME=$HOME

accessory_user_usb_owned() {
  # Migration history survives removal and is also stamped on fresh installs.
  # Only current enrollment can identify USBGuard as Omarchy-managed here.
  [[ -e $ACCESSORY_USER_HOME/.config/systemd/user/omarchy-usb-authorization.service ||
     -L $ACCESSORY_USER_HOME/.config/systemd/user/omarchy-usb-authorization.service ||
     -L $ACCESSORY_USER_HOME/.config/systemd/user/graphical-session.target.wants/omarchy-usb-authorization.service ||
     -d $ACCESSORY_USER_HOME/.local/state/omarchy/usb-authorization ]]
}

accessory_stop_user_unit() {
  local unit=$1 load_state directory link
  local unit_dir=$ACCESSORY_USER_HOME/.config/systemd/user
  load_state=$(systemctl --user show "$unit" --property=LoadState --value) || return 1
  if [[ $load_state != "not-found" ]]; then
    systemctl --user disable --now "$unit" || return 1
  fi
  if systemctl --user is-active --quiet "$unit"; then return 1; fi

  # is-enabled returns not-found for a dangling main link, even if wants links
  # remain. Remove these exact retired units' links without following directories
  # elsewhere or deleting administrator-authored regular files.
  for directory in "$unit_dir"/*.wants "$unit_dir"/*.requires; do
    [[ -d $directory || -L $directory ]] || continue
    link=$directory/$unit
    [[ -e $link || -L $link ]] || continue
    [[ ! -L $directory ]] || return 1
    if [[ -L $link ]]; then
      rm -- "$link" || return 1
    elif [[ -e $link ]]; then
      echo "Refusing to remove a non-link service dependency: $link" >&2
      return 1
    fi
  done
  rm -f -- "$unit_dir/$unit"
}

accessory_authorization_rollback() {
  local usb_owned=0
  if accessory_user_usb_owned; then usb_owned=1; fi
  # Keep both watchers available until all root recovery has completed.
  sudo "$ACCESSORY_ROOT_ADMIN" "$usb_owned" || return 1
  accessory_stop_user_unit omarchy-usb-authorization.service || return 1
  accessory_stop_user_unit omarchy-thunderbolt-authorization.service || return 1
  systemctl --user daemon-reload
}
