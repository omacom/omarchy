echo "Strip Optional TrustAll from [omarchy] if an upgrade reintroduced it"

# migrations/1787589206.sh already dropped SigLevel = Optional TrustAll once.
# omarchy-upgrade-to-quattro used to rewrite that override when repointing the
# channel, so installs that ran the first migration and then upgraded again
# (or finished upgrade before the packaging fix) can still have it. Strip any
# remaining copy so [omarchy] inherits Required DatabaseOptional.

omarchy_sig_override='SigLevel = Optional TrustAll'

if [[ -f /etc/pacman.conf ]] &&
  sed -n '/^\[omarchy\]/,/^\[/p' /etc/pacman.conf | grep -qxF "$omarchy_sig_override"; then
  # Requiring signatures with an untrusted packaging key would fail every
  # omarchy transaction, including the one that could repair it.
  if omarchy-pkg-missing omarchy-keyring ||
    ! sudo pacman-key --list-keys 40DFB630FF42BCFFB047046CF0134EE680CAC571 &>/dev/null; then
    omarchy-update-keyring
  fi

  sudo sed -i "/^\[omarchy\]/,/^\[/{/^$omarchy_sig_override$/d}" /etc/pacman.conf
fi
